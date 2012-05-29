//
//  StateLose.mm
//  Invader
//
//  Created by Richard Adem on 31/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include "StateLose.h"
#include "Score.h"
#include "Game.h" // RA - hacktastic
#ifndef DISABLE_STATS
#import "PebbleCubeSDK.h"
#endif

#define STAT_TRACKER Game::GetInstance()->StatTracker()

static const int s_waitTime = 1.0f;

StateLose::StateLose()
: State()
, m_finalScore(NULL)
, m_highScore(NULL)
, m_waves(NULL)
, m_message(NULL)
, m_continueText(NULL)
, m_elapsedTime(0.0f)
#ifdef USE_BACKGROUNDS
, m_background(NULL)
#endif
{
}
StateLose::~StateLose()
{
}

void StateLose::Init()
{
	State::Init();

#ifdef USE_BACKGROUNDS
	m_background = Sprite::Create(0.0f, 0.0f, @"background_512.png");
#endif
	
	bool newHighScore = Score::GetInstance()->CheckChangeHighScore();
	int finalScore = Score::GetInstance()->GetCurrentActualScore();
	int highScore = Score::GetInstance()->GetHighScore();
	
	
	if (newHighScore)
	{
		// Send game center score
		Game::GetInstance()->SetStatusUpdate(true);
		// [UTextConverter ConvertUText:[NSString stringWithFormat: @"%d", 0]
		m_message = TextController::GetInstance()->CreateText(160.0f, 250.0f, TEXTSIZE::SIXTEEN, [UTextConverter ConvertUText:NSLocalizedString(@"gameover1", @"")]);
		m_newHighScore = TextController::GetInstance()->CreateText(110.0f, 200.0f, TEXTSIZE::SIXTEEN, [UTextConverter ConvertUText:NSLocalizedString(@"newhighscore", @"")]);
	}
	else
	{
		m_message = TextController::GetInstance()->CreateText(160.0f, 250.0f, TEXTSIZE::SIXTEEN, [UTextConverter ConvertUText:NSLocalizedString(@"gameover2", @"")]);
		m_newHighScore = TextController::GetInstance()->CreateText(110.0f, 200.0f, TEXTSIZE::SIXTEEN, [UTextConverter ConvertUText:@""]);
	}
	
	int level = Game::GetInstance()->GetLevelCount();
	m_finalScore = TextController::GetInstance()->CreateText(10.0f, 60.0f, TEXTSIZE::SIXTEEN, [UTextConverter ConvertUText:[NSString stringWithFormat: @"%@ %d", NSLocalizedString(@"finalscore", @""), finalScore]]);
	m_highScore = TextController::GetInstance()->CreateText(10.0f, 30.0f, TEXTSIZE::SIXTEEN, [UTextConverter ConvertUText:[NSString stringWithFormat: @"%@ %d", NSLocalizedString(@"highscore", @""), highScore]]);
	m_waves = TextController::GetInstance()->CreateText(10.0f, 90.0f, TEXTSIZE::SIXTEEN, [UTextConverter ConvertUText:[NSString stringWithFormat: @"%@ %d", NSLocalizedString(@"waves", @""), level]]);
	m_continueText = TextController::GetInstance()->CreateText(300.0f, 10.0f, TEXTSIZE::EIGHT, [UTextConverter ConvertUText:NSLocalizedString(@"continue", @"")]);
#ifdef USE_GAMECENTER
	m_gameCentreText = TextController::GetInstance()->CreateText(370.0f, 300.0f, TEXTSIZE::EIGHT, [UTextConverter ConvertUText:NSLocalizedString(@"gameCentre", @"")]);
#endif
    
	m_elapsedTime = 0;
	
	
	
#ifndef DISABLE_STATS
	BOOL sendStats = [[NSUserDefaults standardUserDefaults] boolForKey:@"sendStats"];
	if (sendStats)
	{
		/*
		std::string* code = new std::string("go_score");
		STAT_TRACKER->Event(Game::GetInstance()->Sig()
												  , Game::GetInstance()->Key()
												  , code
												  , finalScore);
		 */
		[STAT_TRACKER SendEvent: @"go_score"
						  value: [NSNumber numberWithInt:finalScore]
						andTime: Game::GetInstance()->unixEpoch()];
		
		float hitPercent = Game::GetInstance()->GetShotPercentage01();
		Log(@"hitPercent: %f", hitPercent);
		/*
		std::string* code2 = new std::string("accuracy");
		STAT_TRACKER->Event(Game::GetInstance()->Sig()
												  , Game::GetInstance()->Key()
												  , code2
												  , hitPercent);
		*/
		[STAT_TRACKER SendEvent: @"accuracy"
						  value: [NSNumber numberWithFloat:hitPercent]
						andTime: Game::GetInstance()->unixEpoch()];
		
		int level = Game::GetInstance()->GetLevelCount();
		Log(@"level Reached: %d", level);
		/*
		std::string* code3 = new std::string("go_level_reached");
		STAT_TRACKER->Event(Game::GetInstance()->Sig()
												  , Game::GetInstance()->Key()
												  , code3
												  , level);
		 */
		[STAT_TRACKER SendEvent: @"go_level_reached"
						  value: [NSNumber numberWithInt:level]
						andTime: Game::GetInstance()->unixEpoch()];
	}
#endif
	Game::GetInstance()->ResetShots();
	Game::GetInstance()->ResetLevel();

	
	// 
	
	
}
void StateLose::Update(float seconds)
{
	m_elapsedTime += seconds;
    Input input = Game::GetInstance()->GetLastInputState();
	if (input.m_pressed && m_elapsedTime >= s_waitTime)
	{
#ifdef USE_GAMECENTER
        if (input.m_locX > 250.0f && input.m_locY > 360.0f)
        {
            Log(@"goto GC!!!!");
            Game::GetInstance()->SetGotoGameCentre(true);
        }
        else
#endif
        {
            Game::GetInstance()->AddReplay();
            
#ifndef DISABLE_STATS
            BOOL sendStats = [[NSUserDefaults standardUserDefaults] boolForKey:@"sendStats"];
            if (sendStats)
            {
                int replays = Game::GetInstance()->GetReplayCount();
                Log(@"replays: %d", replays);
                /*
                std::string* code3 = new std::string("go_replay_count");
                STAT_TRACKER->Event(Game::GetInstance()->Sig()
                                                          , Game::GetInstance()->Key()
                                                          , code3
                                                          , replays);
                 */
                [STAT_TRACKER SendEvent: @"go_replay_count"
                                  value: [NSNumber numberWithInt:replays]
                                andTime: Game::GetInstance()->unixEpoch()];
            }
#endif
            
            
            End();
        }
	}
}
void StateLose::Draw()
{
#ifdef USE_BACKGROUNDS
	m_background->Draw();
#endif
	m_message->Draw();
	m_newHighScore->Draw();
	m_finalScore->Draw();
	m_highScore->Draw();
	m_waves->Draw();
    
	if (m_elapsedTime >= s_waitTime)
	{
		m_continueText->Draw();
#ifdef USE_GAMECENTER
        m_gameCentreText->Draw();
#endif
	}
}
void StateLose::End()
{
#ifdef USE_BACKGROUNDS
	if (m_background != NULL)
	{
		delete m_background;
		m_background = NULL;
	}
#endif
#ifdef DISABLE_TWITTER
	// this is done in GLViewController resumeAfterStatusUpdate when using twitter
#ifndef USE_GAMECENTER
	Score::GetInstance()->ResetScore();
#endif
#endif
	TextController::GetInstance()->DeleteText(m_message);
	TextController::GetInstance()->DeleteText(m_newHighScore);
	TextController::GetInstance()->DeleteText(m_finalScore);
	TextController::GetInstance()->DeleteText(m_highScore);
	TextController::GetInstance()->DeleteText(m_waves);
	TextController::GetInstance()->DeleteText(m_continueText);
#ifdef USE_GAMECENTER
    TextController::GetInstance()->DeleteText(m_gameCentreText);
#endif
	
	State::End();
}