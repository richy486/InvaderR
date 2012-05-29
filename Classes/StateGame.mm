//
//  StateGame.mm
//  Invader
//
//  Created by Richard Adem on 27/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include "StateGame.h"
#include "Text.h"
#include "Game.h"
#include "Score.h"
#include "StateLose.h"
#include "InvaderSet.h"

#include "test.h"
Test* g_test3;

StateGame::StateGame()
: State()
, m_shooter(NULL)
, m_scoreText(NULL)
#ifdef USE_BACKGROUNDS
, m_background(NULL)
#endif
{
}
StateGame::~StateGame()
{
}

void StateGame::Init()
{
	State::Init();
	
	Log(@"Starting State: Game");

#ifdef USE_BACKGROUNDS
	m_background = Sprite::Create(0.0f, 0.0f, @"background_512_dark.png");
#endif
	
	m_shooter = new Shooter(32);
	m_shooter->Init();
	m_shooter->setHurtsPlayer(false);
	m_shooter->setHurtsInvaders(true);
	m_shooter->setHurtsBases(true);
	m_shooter->setMovementMultiplier(200.0f);

	Bomber::getInstance()->Init();
	
	BaseSet::getInstance()->makeBases();
	InvaderSet::getInstance()->setPlaying(true);
	InvaderSet::getInstance()->restart();
	
	Player::getInstance()->Init();
	Player::getInstance()->start();
	
	Game::GetInstance()->ResetShots();
	Game::GetInstance()->ResetGameTime();
	
	
	m_scoreText = TextController::GetInstance()->CreateText(5.0f, 300.0f, TEXTSIZE::EIGHT, [UTextConverter ConvertUText:[NSString stringWithFormat: @"%d", 0]]);
#ifdef USE_TEST_OBJECTS
	g_test3 = new Test();
#endif
	
	
}

bool g_PressedShoot = false; // This wont be used in any other function but Update
void StateGame::Update(float seconds)
{
	float moveX = Game::GetInstance()->GetLastInputState().m_moveX;
	//Log(@"moveX: %f", moveX);
	Player::getInstance()->update(seconds, moveX);

	bool gameOver = false;
	INVADERS_STATE::INVADERS_STATE invaderState = INVADERS_STATE::COUNT; // default
	if (InvaderSet::getInstance()->getPlaying())
	{
		m_shooter->update(seconds);
		Bomber::getInstance()->update(seconds);
		
		invaderState = InvaderSet::getInstance()->Update(seconds);
		if (invaderState == INVADERS_STATE::LOSE)
		{
			gameOver = true;
		}
		else if (invaderState == INVADERS_STATE::INTRO)
		{
			m_shooter->killAll();
			Bomber::getInstance()->killAll();
		}
			
	}
	else
	{
		// lose
		gameOver = true;
	}
	
	// shooting, after invader update to get invaderState
	if (Game::GetInstance()->GetLastInputState().m_pressed)
	{
		if (invaderState == INVADERS_STATE::PLAYING)
		{
			if (!g_PressedShoot)
			{
				g_PressedShoot = true;
				
				Point2D pos = Player::getInstance()->getPos();
				pos.x += (2.5f * IPS) - 1.5f;
				pos.y += (5.0f * IPS);
				
				m_shooter->fire(pos);
			}
		}
	}
	if (Game::GetInstance()->GetLastInputState().m_released)
	{
		g_PressedShoot = false;
	}
	
	Score::GetInstance()->Update(seconds);
	int level = Game::GetInstance()->GetLevelCount();
	m_scoreText->SetText([UTextConverter ConvertUText:[NSString stringWithFormat: @"%d | %d", level, Score::GetInstance()->GetVisualScore()]]);
	
	if (gameOver)
	{
		BaseSet::getInstance()->makeBases();
		InvaderSet::getInstance()->setPlaying(true);
		InvaderSet::getInstance()->restart();
		Player::getInstance()->start();
		
		m_shooter->killAll();
		Bomber::getInstance()->killAll();
		
		StateLose* stateLose = new StateLose();
		stateLose->Init();
		Game::GetInstance()->PushState(stateLose);
	}
}
void StateGame::Draw()
{
	//glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	// Clear Screen And Depth Buffer
	glLoadIdentity();									// Reset The Current Modelview Matrix

	if(InvaderSet::getInstance()->getPlaying())
	{
#ifdef USE_BACKGROUNDS
		m_background->Draw();
#endif
		InvaderSet::getInstance()->drawSet();
		
		BaseSet::getInstance()->drawBases();
		Bomber::getInstance()->Draw();
		m_shooter->Draw();
		Player::getInstance()->Draw();
	}
	else
	{
		m_shooter->killAll();
		Bomber::getInstance()->killAll();
		InvaderSet::getInstance()->killAll();
	}
	
	m_scoreText->Draw();
	
	//glFlush();
#ifdef USE_TEST_OBJECTS
	//g_test3->Draw();
#endif

}
void StateGame::End()
{
#ifdef USE_BACKGROUNDS
	if (m_background != NULL)
	{
		delete m_background;
		m_background = NULL;
	}
#endif
	
	TextController::GetInstance()->DeleteText(m_scoreText);
	
	delete m_shooter;
	
#ifdef USE_TEST_OBJECTS
	if (g_test3)
		delete g_test3;
#endif
	State::End();
	

}