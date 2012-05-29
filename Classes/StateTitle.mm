//
//  StateTitle.mm
//  Invader
//
//  Created by Richard Adem on 27/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include "StateTitle.h"
#include "Game.h"
#include "StateGame.h"
#import <GameKit/GameKit.h>

// RA - testing
#ifdef USE_TEST_OBJECTS
#include "test.h"
Test* g_test = NULL;
//Test* g_test2 = NULL;
#include "Invader.h"
Invader* g_invaderTest = NULL;
Invader* g_invaderTest2 = NULL;
#include "GameProjectileObject.h"
GameProjectileObject* g_projectile;
#endif

StateTitle::StateTitle()
: State()
#ifdef USE_BACKGROUNDS
, m_background(NULL)
#endif
{
}
StateTitle::~StateTitle()
{
	
}

void StateTitle::Init()
{
	State::Init();
	m_titleText = TextController::GetInstance()->CreateText(150.0f, 250.0f, TEXTSIZE::SIXTEEN, [UTextConverter ConvertUText:NSLocalizedString(@"title", @"")]);
	m_continueText = TextController::GetInstance()->CreateText(300.0f, 10.0f, TEXTSIZE::EIGHT, [UTextConverter ConvertUText:NSLocalizedString(@"continue", @"")]); // "Tap to continue..."
	m_instructionsText = TextController::GetInstance()->CreateText(10.0f, 10.0f, TEXTSIZE::EIGHT, [UTextConverter ConvertUText:NSLocalizedString(@"instructions", @"")]);
#ifdef USE_GAMECENTER
    m_gameCentreText = TextController::GetInstance()->CreateText(370.0f, 300.0f, TEXTSIZE::EIGHT, [UTextConverter ConvertUText:NSLocalizedString(@"gameCentre", @"")]);
#endif
#ifdef USE_BACKGROUNDS
	NSString *file = [[NSString alloc] initWithString:@"background_512.png"];
	m_background = Sprite::Create(0.0f, 0.0f, file);
	[file release];
#endif
	
#ifdef USE_TEST_OBJECTS
	g_test = new Test();
	//g_test2 = new Test();
	g_invaderTest = new Invader();
	g_invaderTest->Init();
	g_invaderTest2 = new Invader();
	g_invaderTest2->Init();
	Point2D testpos;
	testpos.x = 250.0f;
	testpos.y = 100.0f;
	g_invaderTest2->setPos(testpos);
	
	g_projectile = new GameProjectileObject();
	g_projectile->SetColour(255, 0, 0, 255);
	g_projectile->setPos(70.0f, 70.0f);
	g_projectile->Init();
#endif	
}

void StateTitle::Update(float seconds)
{
    Input input = Game::GetInstance()->GetLastInputState();
	if (input.m_pressed)
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
            StateGame* stateGame = new StateGame();
            stateGame->Init();
            Game::GetInstance()->PushState(stateGame);
        }
	}
}
void StateTitle::Draw()
{
#ifdef USE_BACKGROUNDS
	m_background->Draw();
#endif
	m_titleText->Draw();
	m_continueText->Draw();
	m_instructionsText->Draw();
#ifdef USE_GAMECENTER
    m_gameCentreText->Draw();
#endif
#ifdef USE_TEST_OBJECTS
	//g_test->Draw();
	//g_test2->Draw();
	g_invaderTest->Draw();
	g_invaderTest2->Draw();
	g_projectile->Draw();
#endif
	
}
void StateTitle::End()
{
#ifdef USE_BACKGROUNDS
	if (m_background != NULL)
	{
		delete m_background;
		m_background = NULL;
	}
#endif

	TextController::GetInstance()->DeleteText(m_titleText);
	TextController::GetInstance()->DeleteText(m_continueText);
	TextController::GetInstance()->DeleteText(m_instructionsText);
#ifdef USE_GAMECENTER
    TextController::GetInstance()->DeleteText(m_gameCentreText);
#endif
#ifdef USE_TEST_OBJECTS

	if (g_test)
		delete g_test;
	
	/*if (g_test2)
		delete g_test2;
	*/
	if (g_invaderTest)
		delete g_invaderTest;
	
	if (g_invaderTest2)
		delete g_invaderTest2;
	
	if (g_projectile)
		delete g_projectile;
	
#endif
	State::End();
	
}