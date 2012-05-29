//
//  Music.mm
//  InvaderR
//
//  Created by Richard Adem on 17/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#include "Music.h"
#include "consts.h"

Music::Music()
{}
Music::~Music()
{}

void Music::Load()
{
#ifndef DISABLE_MUSIC
	if (IsMusicEnabled())
	{
		NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/music.caf", [[NSBundle mainBundle] resourcePath]]];
	
		NSError *error;
		m_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
		m_audioPlayer.numberOfLoops = -1;
		m_audioPlayer.volume = 0.8; // 0.0 - no volume; 1.0 full volume
		
		if (m_audioPlayer == nil)
			Log(@"%@", [error description]);
	}
#endif

}

void Music::Play()
{
#ifndef DISABLE_MUSIC
	if (IsMusicEnabled())
	{
		[m_audioPlayer play];
	}
#endif
}

void Music::ShutDown()
{
#ifndef DISABLE_MUSIC
	if (IsMusicEnabled())
	{
		[m_audioPlayer release];
	}
#endif
}

bool Music::IsMusicEnabled()
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL enabled = [defaults boolForKey:@"enabled_music"];
	
	return enabled == YES;	
}
