//
//  Sounds.h
//  InvaderR
//
//  Created by Richard Adem on 17/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#pragma once
#ifndef _SOUNDS_H_
#define _SOUNDS_H_

#include <AudioToolbox/AudioServices.h>

class Sounds
{
public:
	enum SOUNDS
	{
		SHOOT_PLAYER,
		SHOOT_INVADER,
		HIT_PLAYER,
		HIT_INVADER,
		HIT_BASE,
		COUNT
	};
	
	Sounds();
	~Sounds();
	
	void LoadSounds();
	void PlaySound(SOUNDS sound);
	bool IsSoundEnabled();
	
private:
	SystemSoundID m_soundIDs[COUNT];
};

#endif // _SOUNDS_H_
