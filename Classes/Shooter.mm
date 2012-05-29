/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#include "shooter.h"
#include "OpenGLCommon.h"

Shooter::Shooter(const int projectleCount)
: ProjectileEmitter(projectleCount)
{
	m_baseProjectile->SetColour(0, 0, 255, 255);
	m_baseProjectile->Init();
	for (int i = 0; i < m_projectileCount; ++i)
	{
		// use memcopy ?
		m_projectiles[i].m_isDead = true;
	}

	m_gameProjectileObjectShot = new GameProjectileObjectShot();
	m_gameProjectileObjectShot->SetColour(0, 0, 255, 128);
	m_gameProjectileObjectShot->Init();
	m_gameProjectileObjectShot->setDead(false);	
}

Shooter::~Shooter(void)
{
	delete m_gameProjectileObjectShot;
}

void Shooter::fire(Point2D pos)
{
	ProjectileEmitter::fire(pos);
	s_sounds->PlaySound(Sounds::SHOOT_PLAYER);
}

void Shooter::Draw()
{
	if (m_showTrails)
	{
		for (int i = 0; i < m_projectileCount; ++i)
		{
			if (!m_projectiles[i].m_isDead)
			{
				m_gameProjectileObjectShot->setPos(m_projectiles[i].m_position);
				m_gameProjectileObjectShot->Draw();
				
				//m_baseProjectile->setPos(m_projectiles[i].m_position);
				//m_baseProjectile->Draw();
			}
		}
	}
	ProjectileEmitter::Draw();
}
