//
//  StateGame.h
//  Invader
//
//  Created by Richard Adem on 27/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#pragma once
#ifndef _STATE_GAME_H_
#define _STATE_GAME_H_

#include "State.h"
#include "shooter.h"
#include "Text.h"
#include "Sprite.h"

class StateGame : public State
{
public:
	StateGame();
	virtual ~StateGame();
	
	void Init();
	void Update(float seconds);
	void Draw();
	void End();
	
private:
	Shooter* m_shooter;
	TextBox* m_scoreText;
#ifdef USE_BACKGROUNDS
	Sprite* m_background;
#endif
};

#endif // _STATE_GAME_H_