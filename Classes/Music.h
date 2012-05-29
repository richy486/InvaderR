//
//  Music.h
//  InvaderR
//
//  Created by Richard Adem on 17/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#pragma once
#ifndef _MUSIC_H_
#define _MUSIC_H_

#include <AVFoundation/AVFoundation.h>

class Music
{
public:
	Music();
	~Music();
	
	void Load();
	void Play();
	void ShutDown();
	bool IsMusicEnabled();
	
private:
	AVAudioPlayer *m_audioPlayer;
};

#endif // _MUSIC_H_