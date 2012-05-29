//
//  Sounds.mm
//  InvaderR
//
//  Created by Richard Adem on 17/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#include "Sounds.h"
#include "consts.h"

#ifndef DISABLE_SOUNDS
static const char* s_fileNames[] = 
{
	"shootPlayer.wav",	//SHOOT_PLAYER,
	"shootInvader.wav",	//SHOOT_INVADER,
	"hitPlayer.wav",	//HIT_PLAYER,
	"hitInvader.wav",	//HIT_INVADER,
	"hitBase.wav",		//HIT_BASE,
};
#endif


Sounds::Sounds()
{
	//LoadSounds();
}
Sounds::~Sounds()
{}

void Sounds::LoadSounds()
{
#ifndef DISABLE_SOUNDS
	if (IsSoundEnabled())
	{
		for (int i = 0; i < COUNT; ++i)
		{
			NSString *path = [NSString stringWithFormat:@"%@/%s",
							  [[NSBundle mainBundle] resourcePath],
							  s_fileNames[i]];
			
			Log(@"%@", path);
			
			NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
			
			OSStatus status = AudioServicesCreateSystemSoundID((CFURLRef)filePath, &m_soundIDs[i]);
			Log(@"      m_soundIDs[i]: %d, status: %d", m_soundIDs[i], status);
		}
	}
#endif
}
void Sounds::PlaySound(SOUNDS sound)
{
	assert(sound < COUNT && "sound is invalid");
	
#ifndef DISABLE_SOUNDS
	if (IsSoundEnabled())
	{	
		AudioServicesPlaySystemSound(m_soundIDs[sound]);
	}
#endif
}

bool Sounds::IsSoundEnabled()
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL enabled = [defaults boolForKey:@"enabled_sound"];
	
	return enabled == YES;
}
