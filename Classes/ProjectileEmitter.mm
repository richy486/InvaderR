//
//  ProjectileEmitter.mm
//  InvaderR
//
//  Created by Richard Adem on 4/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#include "ProjectileEmitter.h"
#include "Player.h"
#include "InvaderSet.h"
#include "BaseSet.h"
#include "Game.h"

#define STAT_TRACKER Game::GetInstance()->StatTracker()

ProjectileEmitter::ProjectileEmitter(const int projectleCount)
: GameObject()
, m_lastProjectile(projectleCount - 1)
, m_projectileCount(projectleCount)
, m_projectiles(NULL)
, m_baseProjectile(NULL)
, m_movementMultiplier(0.0f)
, m_hurtsPlayer(false)
, m_hurtsInvaders(false)
, m_hurtsBases(false)
, m_showTrails(YES)
{
	m_baseProjectile = new GameProjectileObject();
	m_projectiles = new Projectile[projectleCount];
}

ProjectileEmitter::~ProjectileEmitter()
{
	if (m_projectiles) 
	{
		delete[] m_projectiles;
	}
	
	if (m_baseProjectile)
	{
		delete m_baseProjectile;
	}
}

void ProjectileEmitter::Init()
{
	m_showTrails = [[NSUserDefaults standardUserDefaults] boolForKey:@"showTrails"];
	Log(@"m_showTrails: %d", m_showTrails);
}
void ProjectileEmitter::Draw()
{
	for (int i = 0; i < m_projectileCount; ++i)
	{
		if (!m_projectiles[i].m_isDead)
		{
			m_baseProjectile->setPos(m_projectiles[i].m_position);
			m_baseProjectile->Draw();
			//m_projectiles[i].Draw();
		}
	}
}

void ProjectileEmitter::killAll()
{
	for (int i = 0; i < m_projectileCount; ++i)
	{
		m_projectiles[i].m_isDead = true;
	}			
}

void ProjectileEmitter::setMovementMultiplier(float multiplier)
{
	m_movementMultiplier = multiplier;
}

void ProjectileEmitter::fire(Point2D pos)
{
	int currProjectile = getNextProjectile();
	m_projectiles[currProjectile].m_isDead = false;
	m_projectiles[currProjectile].m_position.x = pos.x;
	m_projectiles[currProjectile].m_position.y = pos.y;
	m_projectiles[currProjectile].m_previousPosition.x = pos.x;
	m_projectiles[currProjectile].m_previousPosition.y = pos.y;
}
void ProjectileEmitter::update(float seconds)
{
	for (int i = 0; i < m_projectileCount; ++i)
	{
		// out of screen (top and bottom)
		if (!m_projectiles[i].m_isDead)
		{
			if(m_projectiles[i].m_position.y >= 320) // out on the top
			{
				m_projectiles[i].m_isDead = true;
				Game::GetInstance()->AddShot(false); // missed
			}
			else if (m_projectiles[i].m_position.y < 0) // out on the bottom
			{
				m_projectiles[i].m_isDead = true;
			}
		}

		// hits player
		if (!m_projectiles[i].m_isDead && InvaderSet::getInstance()->getPlaying())
		{
			if (m_hurtsPlayer)
			{
				if (m_projectiles[i].m_position.y <= 50 + (5 * IPS) && Player::getInstance()->testHit(m_projectiles[i].m_position))
				{
					Log(@"death by bomb");

					m_projectiles[i].m_isDead = true;
					InvaderSet::getInstance()->setPlaying(false);

#ifndef DISABLE_STATS
					BOOL sendStats = [[NSUserDefaults standardUserDefaults] boolForKey:@"sendStats"];
					if (sendStats)
					{
						/*
						std::string* code = new std::string("go_cause");
						std::string* cause = new std::string("bomb");
						STAT_TRACKER->Event(Game::GetInstance()->Sig()
																  , Game::GetInstance()->Key()
																  , code
																  , cause);
						 */
						[STAT_TRACKER SendEvent: @"go_cause"
										  value: @"bomb"
										andTime: Game::GetInstance()->unixEpoch()];
					}
#endif
				}
			}
		}
		
		// hits base
		if (!m_projectiles[i].m_isDead)
		{
			if (m_hurtsBases)
			{
				if (m_projectiles[i].m_position.y <= 50 + (5 * IPS))
				{
					Point2D currentPos = m_projectiles[i].m_position;
					Point2D previousPos = m_projectiles[i].m_previousPosition;
					if (m_projectiles[i].m_position.y <= 0 || BaseSet::getInstance()->checkHits(currentPos, previousPos))
					{
						m_projectiles[i].m_isDead = true;
						s_sounds->PlaySound(Sounds::HIT_BASE);
					}
				}
			}
		}
		
		// hits invader
		if (!m_projectiles[i].m_isDead)
		{
			if (m_hurtsInvaders)
			{
				if (InvaderSet::getInstance()->testHits(m_projectiles[i].m_position))
				{
					m_projectiles[i].m_isDead = true;
					s_sounds->PlaySound(Sounds::HIT_INVADER);
					Game::GetInstance()->AddShot(true); // hit
				}
			}
		}
		
		// move
		if (!m_projectiles[i].m_isDead)
		{
			m_projectiles[i].m_previousPosition = m_projectiles[i].m_position;
			
			Point2D pos = m_projectiles[i].m_position;
			m_projectiles[i].m_position.x = pos.x;
			m_projectiles[i].m_position.y = pos.y + m_movementMultiplier * seconds;
		}
	}
}

void ProjectileEmitter::setHurtsPlayer(bool hurts)
{
	m_hurtsPlayer = hurts;
}
void ProjectileEmitter::setHurtsInvaders(bool hurts)
{
	m_hurtsInvaders = hurts;
}
void ProjectileEmitter::setHurtsBases(bool hurts)
{
	m_hurtsBases = hurts;
}
	
int ProjectileEmitter::getNextProjectile()
{
	int currentProjectile = m_lastProjectile;
	
	while (++m_lastProjectile != currentProjectile)
	{
		if (m_lastProjectile >= m_projectileCount)
			m_lastProjectile = 0;
		
		if (m_projectiles[m_lastProjectile].m_isDead)
			return m_lastProjectile;
	}
	assert(false && "Ran out of bombs");
	return -1;
}
