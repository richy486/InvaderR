/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#include "InvaderSet.h"
#include "Score.h"
#include "Game.h"
#import "___PROJECTNAMEASIDENTIFIER___AppDelegate.h"
#include "consts.h"

#define STAT_TRACKER Game::GetInstance()->StatTracker()

static const float s_maxSecondsFire = 0.01f;

InvaderSet::InvaderSet(void)
: m_accumSecondsFire(0.0f)
, m_xSpeed(100.0f)
, m_ySpeed(25.0f)
, m_secondsTillFire(0.01f)
{
	side = true;
	side2side = 0;
	m_state = INVADERS_STATE::INTRO;
	m_gameOver = false;
	
	m_particles = new ExplodeParticleSystem();
	m_particles->Init();
}

InvaderSet::~InvaderSet(void)
{
	if (m_particles)
	{
		m_particles->ShutDown();
		delete m_particles;
	}
}
InvaderSet* InvaderSet::getInstance()
{
	static InvaderSet instance;
    return &instance;
}
// Fill up the list with 50 invaders.
void InvaderSet::spawnNewSet()
{
	Log(@"Spawning new set of Invaders");
	int index = 0;
	for(int i = 0; i < s_invRowCount; i++)
	{
		for(int j = 0; j < s_invColCount; j++)
		{
			m_invaders[index].setPos(Point2D(j * 30.0f + 160.0f, i * 30.0f + 340.0f));
			m_invaders[index].SetDead(false);
			m_invaders[index].Init();
			//Log(@"pos: %.02f %.02f", id, m_invaders[(i * s_invRowCount) + j].getPos().x, m_invaders[(i * s_invRowCount) + j].getPos().y);
			index++;
		}
		//Log(@"-----------------------");
	}
	
	Game::GetInstance()->AddLevel();
	m_xSpeed = 100.0f;
	m_ySpeed = 25.0f;
	
#ifdef USE_SPEEDUP
	int level = Game::GetInstance()->GetLevelCount();
	float speedUp = 3.0f * (float)level;
	m_xSpeed += speedUp;
	m_ySpeed += speedUp;
#endif
	
	m_secondsTillFire = s_maxSecondsFire;
#ifdef USE_SPEEDUP
	m_secondsTillFire = s_maxSecondsFire / (level + 1);
#endif
	
	Log(@"m_xSpeed: %f", m_xSpeed);
	Log(@"m_ySpeed: %f", m_ySpeed);
	Log(@"m_secondsTillFire: %f", m_secondsTillFire);
	
	m_gameOver = false;
}

// Test if a players shot has hit an invader.
bool InvaderSet::testHits(Point2D p)
{
	if (m_state == INVADERS_STATE::PLAYING)
	{
		int index = 0;
		for(int i = 0; i < s_invRowCount; i++)
		{
			for(int j = 0; j < s_invColCount; j++)
			{
				if (!m_invaders[index].IsDead())
				{
					Point2D pos = m_invaders[index].getPos();
					
					if(p.x >= pos.x && p.x <= pos.x+(IPS*5) && 
					   p.y >= pos.y && p.y <= pos.y+(IPS*5))
					{
						m_particles->StartParticles(pos, (m_invaders[index].GetImage()), 25);
						
						m_invaders[index].SetDead(true);
						Score::GetInstance()->AddToScore(s_scoreKill);
						return true;
					}
				}
				index++;
			}
		}
	}
	return false;
}

// Move the invaders adding slop,
// Also have the invaders shoot
// The less invaders the larger the change they will shoot.
INVADERS_STATE::INVADERS_STATE InvaderSet::Update(float seconds)
{
	switch (m_state)
	{
		case INVADERS_STATE::INTRO:
			UpdateIntro(seconds);
			break;
		case INVADERS_STATE::PLAYING:
			UpdatePlaying(seconds);
			break;
		case INVADERS_STATE::VICTORY:
			UpdateVictory(seconds);
			break;
		case INVADERS_STATE::LOSE:
			break;
		default:
			assert("invalid state" && false);
			break;
	}

	m_particles->Update(seconds);

	return m_state;
}
// Start a new game.
void InvaderSet::restart()
{
	killAll();
	m_particles->KillAllParticles();
	
	side2side = 0;
	side = true;
}

// Kill all the invaders.
void InvaderSet::killAll()
{
	int index = 0;
	for(int i = 0; i < s_invRowCount; i++)
	{
		for(int j = 0; j < s_invColCount; j++)
		{
			m_invaders[index].SetDead(true);
			index++;
		}
	}
}

// Call the drawing function for all the invaders.
void InvaderSet::drawSet()
{
	int index = 0;
	for(int i = 0; i < s_invRowCount; i++)
	{
		for(int j = 0; j < s_invColCount; j++)
		{
			if (!m_invaders[index].IsDead())
			{
				m_invaders[index].Draw();
			}
			index++;
		}
	}
	
	m_particles->Draw();
}

float g_introDistance = 0.0f;
void InvaderSet::UpdateIntro(float seconds)
{
	//if (m_invaders.empty())
	if (IsAllDead())
	{
		side = true;
		side2side = 0;
		g_introDistance = 0.0f;
		
		spawnNewSet();
	}
	
	g_introDistance += seconds * 100.0f;
	if (g_introDistance < 160.0f)
	{
		Point2D pos;
		
		int index = 0;
		for(int i = 0; i < s_invRowCount; i++)
		{
			for(int j = 0; j < s_invColCount; j++)
			{
				pos.x = m_invaders[index].getPos().x;
				pos.y = m_invaders[index].getPos().y - seconds * 100.0f;
				
				m_invaders[index].setPos(pos);
				index++;
			}
		}
	}
	else 
	{
		m_state = INVADERS_STATE::PLAYING;
	}
}

void InvaderSet::UpdatePlaying(float seconds)
{
	//if (m_invaders.empty())
	int aliveCount = GetAliveCount();
	if (aliveCount <= 0)
	{
		m_state = INVADERS_STATE::INTRO;
	}

	// wtf??
	float x;
	if (side == true)
	{
		side2side++;
		x = -1;
		if(side2side >= 75)
		{
			side2side = 0;
			side = false;
		}
	}
	else
	{
		side2side++;
		x = 1;
		if(side2side >= 75)
		{
			side2side = 0;
			side = true;
		}
	}
	
	Point2D pos;
	list<Invader>::iterator iter;
	
	int index = 0;
	for(int i = 0; i < s_invRowCount; i++)
	{
		for(int j = 0; j < s_invColCount; j++)
		{
			if (!m_invaders[index].IsDead())
			{
				pos = m_invaders[index].getPos();
				
				pos.x += x * ((float)((rand()%5)+15)/10);
				

				
				if(pos.x > 460)
					pos.x -= ((float)((rand()%10)+10)/10) * seconds * m_xSpeed;
				if(pos.x < 20)
					pos.x += ((float)((rand()%10)+10)/10) * seconds * m_xSpeed;
				
				pos.y -= (((float)(rand()%20)/100) * seconds * m_ySpeed);
				

				
				m_invaders[index].setPos(pos);
				
				if(pos.y <= 0 && m_playing)
				{
					Log(@"death by out of screen");

					m_playing = false;
					m_gameOver = true;
					GameObject::s_sounds->PlaySound(Sounds::HIT_PLAYER);
					
#ifndef DISABLE_STATS
					BOOL sendStats = [[NSUserDefaults standardUserDefaults] boolForKey:@"sendStats"];
					if (sendStats)
					{
						/*
						std::string* code = new std::string("go_cause");
						std::string* cause = new std::string("out_of_screen");
						STAT_TRACKER->Event(Game::GetInstance()->Sig()
																  , Game::GetInstance()->Key()
																  , code
																  , cause);
						 */
						[STAT_TRACKER SendEvent: @"go_cause"
										  value: @"out_of_screen"
										andTime: Game::GetInstance()->unixEpoch()];
					}
#endif
				}
				
				m_accumSecondsFire += seconds;
				if (m_accumSecondsFire >= m_secondsTillFire)
				{
					if (rand() % (aliveCount * 20) == 1)
					{
						m_invaders[index].Fire();
					}
					m_accumSecondsFire = 0.0f;
				}
				
				m_invaders[index].Update(seconds);
			}
			index++;
		}
	}
}
void InvaderSet::UpdateVictory(float seconds)
{
}

bool InvaderSet::IsAllDead()
{
	int index = 0;
	for(int i = 0; i < s_invRowCount; i++)
	{
		for(int j = 0; j < s_invColCount; j++)
		{
			if (!m_invaders[index].IsDead())
			{
				return false;
			}
			index++;
		}
	}
	return true;
}

int InvaderSet::GetAliveCount()
{
	int index = 0;
	int aliveCount = 0;
	for(int i = 0; i < s_invRowCount; i++)
	{
		for(int j = 0; j < s_invColCount; j++)
		{
			if (!m_invaders[index].IsDead())
			{
				aliveCount++;
			}
			index++;
		}
	}
	return aliveCount;
}