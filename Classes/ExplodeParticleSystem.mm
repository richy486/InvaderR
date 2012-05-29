//
//  ExplodeParticleSystem.mm
//  InvaderR
//
//  Created by Richard Adem on 21/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#include "ExplodeParticleSystem.h"
#include "GameProjectileObject.h"
#include "consts.h"

static const int s_particleCount = 25;


ExplodeParticleSystem::ExplodeParticleSystem()
: ParticleSystem()
{
}

ExplodeParticleSystem::~ExplodeParticleSystem()
{
}

void ExplodeParticleSystem::Init()
{
	for (int iPool = 0; iPool < s_poolSize; ++iPool)
	{
		m_particles[iPool].resize(s_particleCount);
		m_availablePools[iPool] = true;
	}
	
	m_baseProjectile = new GameProjectileObject();
	m_baseProjectile->SetColour(128, 128, 128, 255);
	m_baseProjectile->Init();
}
void ExplodeParticleSystem::Update(float seconds)
{
	for (int iPool = 0; iPool < s_poolSize; ++iPool)
	{
		if (!m_availablePools[iPool]) // not available means its active
		{
			bool allDead = true;
			
			for (int iParticle = 0; iParticle < s_particleCount; ++iParticle)
			{
				if (!m_particles[iPool][iParticle].m_isDead)
				{
					Point2D dir = m_particles[iPool][iParticle].m_direction;
					float speed = m_particles[iPool][iParticle].m_speed;
					
					m_particles[iPool][iParticle].m_position.x += dir.x * speed * seconds;
					m_particles[iPool][iParticle].m_position.y += dir.y * speed * seconds;
						
					// check if out of screen
					Point2D pos = m_particles[iPool][iParticle].m_position;
					
					if (pos.x < 0.0f || pos.y < 0.0f
						|| pos.x > GAME_WIDTH || pos.y > GAME_HEIGHT)
					{
						m_particles[iPool][iParticle].m_isDead = true;
					}
					else
					{
						allDead = false;
					}
				}
			}
			
			if (allDead)
			{
				m_availablePools[iPool] = true;
			}
		}
	}
}
void ExplodeParticleSystem::Draw()
{
#ifndef DISABLE_PARTICALES_DRAW
	for (int iPool = 0; iPool < s_poolSize; ++iPool)
	{
		if (!m_availablePools[iPool]) // not available means its active
		{
			for (int iParticle = 0; iParticle < s_particleCount; ++iParticle)
			{
				if (!m_particles[iPool][iParticle].m_isDead)
				{
					m_baseProjectile->setPos(m_particles[iPool][iParticle].m_position);
					m_baseProjectile->Draw();
				}
			}
		}
	}
#endif
}
void ExplodeParticleSystem::ShutDown()
{
	if (m_baseProjectile)
	{
		delete m_baseProjectile;
	}
}

void ExplodeParticleSystem::StartParticles(Point2D pos)
{
	int pool = GetAvailablePool();
	if (pool < 0)
	{
		return;
	}

	//Log(@"New particles at: %.02f , %.02f, pool: %d", pos.x, pos.y, pool);
	m_availablePools[pool] = false;
	for (int iParticle = 0; iParticle < s_particleCount; ++iParticle)
	{
		float x = ((iParticle % 5) * IPS);
		float y = ((iParticle / 5) * IPS);
		m_particles[pool][iParticle].m_position = Point2D(x + pos.x, y + pos.y);
		m_particles[pool][iParticle].m_direction = Point2D(x - (2.5f * IPS), y - (2.5f * IPS));
		m_particles[pool][iParticle].m_speed = 25.0f;
		m_particles[pool][iParticle].m_isDead = false;
	}
}

void ExplodeParticleSystem::StartParticles(Point2D pos, bool* img, int imgSize)
{
	assert(img != NULL && "img is invalid");
	assert(imgSize == 25 && "function not setup for anything but size of 25");
	
	int pool = GetAvailablePool();
	if (pool < 0)
	{
		return;
	}
	
	//Log(@"New particles at: %.02f , %.02f, pool: %d", pos.x, pos.y, pool);
	m_availablePools[pool] = false;
	for (int iParticle = 0; iParticle < s_particleCount; ++iParticle)
	{
#ifdef LESS_PARTICLES
		if ((iParticle >= 6 && iParticle <= 8) 
			|| (iParticle >= 11 && iParticle <= 13)
			|| (iParticle >= 16 && iParticle <= 18))
		{
			continue;
		}
#endif
			
		
		float y = ((iParticle % 5) * IPS);
		float x = ((iParticle / 5) * IPS);
		m_particles[pool][iParticle].m_position = Point2D(x + pos.x, y + pos.y);
		m_particles[pool][iParticle].m_direction = Point2D(x - (2.5f * IPS), y - (2.5f * IPS));
		m_particles[pool][iParticle].m_speed = 25.0f;

		if (img[iParticle])
		{
			m_particles[pool][iParticle].m_isDead = false;
		}
		else
		{
			m_particles[pool][iParticle].m_isDead = true;
		}
	}
}

void ExplodeParticleSystem::KillAllParticles()
{
	for (int iPool = 0; iPool < s_poolSize; ++iPool)
	{
		if (!m_availablePools[iPool]) // not available means its active
		{
			for (int iParticle = 0; iParticle < s_particleCount; ++iParticle)
			{
				if (!m_particles[iPool][iParticle].m_isDead)
				{
					m_particles[iPool][iParticle].m_isDead = true;
				}
			}
			m_availablePools[iPool] = true;
		}
	}
}