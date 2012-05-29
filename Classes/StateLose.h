//
//  StateLose.h
//  Invader
//
//  Created by Richard Adem on 31/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#pragma once
#ifndef _STATE_LOSE_H_
#define _STATE_LOSE_H_

#include "State.h"
#include "Text.h"
#include "Sprite.h"

class StateLose : public State
{
public:
	StateLose();
	virtual ~StateLose();
	
	void Init();
	void Update(float seconds);
	void Draw();
	void End();
	
private:
	TextBox* m_message;
	TextBox* m_newHighScore;
	TextBox* m_finalScore;
	TextBox* m_highScore;
	TextBox* m_waves;
	TextBox* m_continueText;
#ifdef USE_GAMECENTER
    TextBox* m_gameCentreText;
#endif
#ifdef USE_BACKGROUNDS
	Sprite* m_background;
#endif
	
	float m_elapsedTime; // wait before you can continue;
};

#endif // _STATE_LOSE_H_