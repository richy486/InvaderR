//
//  Game.mm
//  Invader
//
//  Created by Richard Adem on 25/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include "Game.h"

#include "consts.h"
#include "player.h"
#include "text.h"
#include "bomber.h"
#include "baseset.h"

#include "StateGame.h"
#include "StateTitle.h"

//#import "UIDeviceHardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#include "OpenGLCommon.h"


static Game* g_Instance = NULL;

#define TICK_RATE			60.0
#define MINIMUM_FRAME_RATE	0.0000001

#define STAT_TRACKER Game::GetInstance()->StatTracker()

// timing variables
static double	gPrevFrameTime;
static double	gTimeLeftOver;
static double	gMaxTimeAllowed;
static double	gLastFPSUpdate;
static float	gFPS;
static unsigned	gFrameCount;

// delta time, used everywhere
double			dt = 0.0;

// local function declarations


double Game::DoublePrecisionSeconds(void)
{
	static uint64_t		timebase = 0;
	uint64_t			time, nanos;
	double				seconds;
	
	// calculate the time base for this platform, only on the first time through
	if (timebase == 0)
	{
		mach_timebase_info_data_t	timebaseInfo;
		mach_timebase_info(&timebaseInfo);
		timebase = timebaseInfo.numer / timebaseInfo.denom;
	}
	
	// calculate time
	time = mach_absolute_time();
	nanos = time * timebase;
	
	// convert from nanoseconds to seconds
	seconds = (double)nanos * 1.0e-9;
	
	return seconds;
}

Game::Game()
: GameStats()
, m_music(NULL)
, m_updateStatus(false)
#ifndef DISABLE_STATS
, m_statTracker(NULL)
#endif
, m_gotoGameCentre(false)
{
	m_seconds = 0.01f;
	m_input.m_moveX = 0.0f;
	m_input.m_pressed = false;
	m_input.m_released = false;
    m_input.m_locX = -1.0f;
    m_input.m_locY = -1.0f;
}
Game::~Game()
{
#ifndef DISABLE_STATS
	if (m_statTracker)
    {
		//delete m_statTracker;
        [m_statTracker release];
    }
#endif
}

Game* Game::GetInstance()
{
	if (g_Instance == NULL)
	{
		g_Instance = new Game();
	}
	return g_Instance;
}



void Game::Init()
{
	srand((unsigned int)time(NULL));

	// stats
#ifndef DISABLE_STATS
	m_statTracker = [[PebbleCubeSDK alloc] initWithSaveToStorage: NO];
	
	std::string md5Sig = md5("");
	api_sig = [[NSString stringWithCString:md5Sig.c_str() encoding:[NSString defaultCStringEncoding]] retain];
	api_key = [@"" retain];
	
	//Log(@"api_sig: %@", api_sig);
	//Log(@"api_key: %@", api_key);
	
	version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] retain];
#endif
	//Log(@"api_sig: %c", api_sig);
	m_pause = false;
	
	double		currTime;
	
	// init timing
	currTime = DoublePrecisionSeconds();
	dt = 1.0 / TICK_RATE;
	gPrevFrameTime = currTime;
	gTimeLeftOver = 0.0;
	gMaxTimeAllowed = (TICK_RATE / MINIMUM_FRAME_RATE) * dt;
	gLastFPSUpdate = currTime;
	gFPS = 0.0f;
	gFrameCount = 0;
	
#ifdef SHOW_FPS_ONSCREEN
	m_fps = TextController::GetInstance()->CreateText(390.0f, 300.0f, TEXTSIZE::EIGHT, "0");
#endif
	m_pausedText = TextController::GetInstance()->CreateText(10.0f, 30.0f, TEXTSIZE::EIGHT, [UTextConverter ConvertUText:NSLocalizedString(@"paused", @"")]);
	
	CheckAndPlayMusic();
	GameObject::s_sounds->LoadSounds();
	
	StateTitle* stateTitle = new StateTitle();
	stateTitle->Init();
	m_states.push(stateTitle);
}


void Game::Update()
{
	double	currTime, frameRateDelta;
	
	currTime = DoublePrecisionSeconds();
	
	
	// calculate frame rate (optional, added for fun)
	gFrameCount++;
	frameRateDelta = currTime - gLastFPSUpdate;
	if (frameRateDelta > 0.5)
	{
		gFPS = gFrameCount / frameRateDelta;
		gFrameCount = 0;
		gLastFPSUpdate = currTime;
		//Log(@"fps: %0.1f", gFPS);
#ifdef SHOW_FPS_ONSCREEN
		m_fps->SetText("%0.1f", gFPS);
#endif
	}
	
	// update the game world at a constant tick rate
	m_seconds = currTime - gPrevFrameTime;
	gPrevFrameTime = currTime;
	
	if (!m_pause)
	{
		// ----- update here ------
		m_states.top()->Update(m_seconds);
		
		if (m_states.top()->IsEnded())
		{
			State* popedState = m_states.top();
			m_states.pop();
			delete popedState;
		}
	}
	else 
	{
		if (Game::GetInstance()->GetLastInputState().m_pressed)
		{
			Pause(false);
		}
	}


	// ------------------------
	
	if (m_seconds < 0.01f)
	{
		Log(@" delta: %f", m_seconds);
	}

	// reset input at end of update
	m_input.m_moveX = 0.0f;
	m_input.m_pressed = false;
	m_input.m_released = false;
}
void Game::Draw()
{
    m_states.top()->Draw();
    
#ifdef SHOW_FPS_ONSCREEN
    m_fps->Draw();
#endif
    if (m_pause)
    {
        m_pausedText->Draw();
    }
}
void Game::ShutDown()
{
	Log(@"shutting down");
	
#ifdef SHOW_FPS_ONSCREEN
	TextController::GetInstance()->DeleteText(m_fps);
#endif
	TextController::GetInstance()->DeleteText(m_pausedText);
	
	while (!m_states.empty())
	{
		State* top = m_states.top();
		top->End();
		
		m_states.pop();
		
		delete top;
	}
	
	if (m_music)
		m_music->ShutDown();
#ifndef DISABLE_STATS	
	[api_sig release];
	[api_key release];
	[version release];
#endif
}


void Game::Press(float x, float y)
{
	m_input.m_pressed = true;
    m_input.m_locX = x;
    m_input.m_locY = y;
}
void Game::Release()
{
	m_input.m_released = true;
}

void Game::MoveX(float NegPos1)
{
	m_input.m_moveX = NegPos1;
}

void Game::PushState(State* state)
{
	m_states.push(state);
}
void Game::PopState()
{
	State* top = m_states.top();
	m_states.pop();
	
	delete top;
}

Input& Game::GetLastInputState()
{
	return m_input;
}

void Game::CheckAndPlayMusic()
{
	UInt32		propertySize, audioIsAlreadyPlaying;
	
	// do not open the track if the audio hardware is already in use (could be the iPod app playing music)
	propertySize = sizeof(UInt32);
	
	AudioSessionInitialize(NULL,NULL,NULL,NULL);
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &audioIsAlreadyPlaying);
	if (audioIsAlreadyPlaying != 0)
	{
		//gOtherAudioIsPlaying = YES;
		Log(@"other audio is playing");
		
		UInt32	sessionCategory = kAudioSessionCategory_AmbientSound;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
		AudioSessionSetActive(YES);
	}
	else
	{
		Log(@"no other audio is playing ...");
		
		//gOtherAudioIsPlaying = NO;
		
		// since no other audio is *supposedly* playing, then we will make darn sure by changing the audio session category temporarily
		// to kick any system remnants out of hardware (iTunes (or the iPod App, or whatever you wanna call it) sticks around)
		UInt32	sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
		AudioSessionSetActive(YES);
		
		// now change back to ambient session category so our app honors the "silent switch"
		sessionCategory = kAudioSessionCategory_SoloAmbientSound;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);

		// play game music
		m_music = new Music();
		m_music->Load();
		m_music->Play();
	}
}

void Game::Pause(bool pause)
{
	m_pause = pause;
}

void Game::Suspend()
{
	Log(@"Suspend");
	
	Pause(true);
	
#ifndef DISABLE_STATS
	BOOL sendStats = [[NSUserDefaults standardUserDefaults] boolForKey:@"sendStats"];
	if (sendStats)
	{
		[m_statTracker CloseConnection: api_sig
							  withKey: api_key
							  andTime: Game::GetInstance()->unixEpoch()];
	}
#endif
	
}
void Game::UnSuspend()
{
	Log(@"UnSuspend");
	
#ifndef DISABLE_STATS	
	BOOL sendStats = [[NSUserDefaults standardUserDefaults] boolForKey:@"sendStats"];
	if (sendStats)
	{
		Log(@"api_sig: %c", api_sig);
		
		[m_statTracker MakeConnection: api_sig
							  withKey: api_key
						   andVersion: version
							  andTime: Game::GetInstance()->unixEpoch()];
	}
#endif
}

