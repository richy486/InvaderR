//
//  StateTitle.h
//  Invader
//
//  Created by Richard Adem on 27/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#pragma once
#ifndef _STATE_TITLE_H_
#define _STATE_TITLE_H_

#include "State.h"
#include "Text.h"
#include "Sprite.h"


class StateTitle : public State
{
public:
	StateTitle();
	virtual ~StateTitle();
	
	void Init();
	void Update(float seconds);
	void Draw();
	void End();
	
private:
	TextBox* m_titleText;
	TextBox* m_continueText;
	TextBox* m_instructionsText;
#ifdef USE_GAMECENTER
    TextBox* m_gameCentreText;
#endif
#ifdef USE_BACKGROUNDS
	Sprite* m_background;
#endif
};

#endif // _STATE_TITLE_H_