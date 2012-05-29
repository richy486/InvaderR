//
//  Game.h
//  Invader
//
//  Created by Richard Adem on 25/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#pragma once
#ifndef _GAME_H_
#define _GAME_H_

#include <stack>
#include "consts.h"
#include "GameStats.h"
#include "State.h"
#include "Music.h"

//#ifdef SHOW_FPS_ONSCREEN
#include "Text.h"
//#endif

#ifndef DISABLE_STATS
#import "PebbleCubeSDK.h"
#endif
//using namespace PebbleCubeSDK;

struct Input
{
	float m_moveX;
	bool m_pressed;
	bool m_released;
    
    float m_locX;
    float m_locY;
};

class Game : public GameStats
{
public:
	static Game* GetInstance();
	~Game();
	
	void Init();
	void Update();
	void Draw();
	void ShutDown();
	
	void Press(float x, float y);
	void Release();
	void MoveX(float NegPos1);
	
	void PushState(State* state);
	void PopState();
	Input& GetLastInputState();
	
	void CheckAndPlayMusic();

#ifndef DISABLE_STATS
	PebbleCubeSDK* StatTracker() { return m_statTracker; };
	NSString* Sig() { return api_sig; }
	NSString* Key() { return api_key; }
	NSString* Version() { return version; }
#endif
	
	NSString* unixEpoch()
	{
		NSTimeInterval today = [[NSDate date] timeIntervalSince1970];
		NSString *intervalString = [NSString stringWithFormat:@"%d", (int)floor(today)];
		return intervalString;
	}
	
	void SetStatusUpdate(bool update) { m_updateStatus = update; }
	bool GetStatusUpdate() { return m_updateStatus; }
    void SetGotoGameCentre(bool go) { m_gotoGameCentre = go; }
	bool GetGotoGameCentre() { return m_gotoGameCentre; }
	
	void Pause(bool pause);
	
	void Suspend();
	void UnSuspend();
	
	static double DoublePrecisionSeconds(void);
	
private:
	Game();
	float m_seconds;
	
	std::stack<State*> m_states;
	Input m_input;
	
	Music* m_music;
	
	bool m_updateStatus;
	bool m_pause;
    bool m_gotoGameCentre;
	
#ifdef SHOW_FPS_ONSCREEN
	TextBox* m_fps;
#endif
	
	TextBox* m_pausedText;
#ifndef DISABLE_STATS	
	PebbleCubeSDK *m_statTracker;
	NSString* api_sig;
	NSString* api_key;
	NSString* version;
#endif
};

#endif // _GAME_H_