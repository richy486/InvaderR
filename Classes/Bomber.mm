/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#include "bomber.h"
#include "OpenGLCommon.h"

Bomber::Bomber(const int projectleCount)
: ProjectileEmitter(projectleCount)
{
	m_baseProjectile->SetColour(255, 0, 0, 255);
	m_baseProjectile->Init();

	for (int i = 0; i < m_projectileCount; ++i)
	{
		//m_projectiles[i].SetColour(255, 0, 0, 255);
		m_projectiles[i].m_isDead = true;
		//m_projectiles[i].Init();
	}
	
	m_gameProjectileObjectBomb = new GameProjectileObjectBomb();
	m_gameProjectileObjectBomb->SetColour(255, 0, 0, 128);
	m_gameProjectileObjectBomb->Init();
	m_gameProjectileObjectBomb->setDead(false);
}

Bomber::~Bomber(void)
{
	delete m_gameProjectileObjectBomb;
}
Bomber* Bomber::getInstance()
{
	static Bomber instance(64);
	
	// not the best place for this, should remove singleton
	instance.setHurtsPlayer(true);
	instance.setHurtsInvaders(false);
	instance.setHurtsBases(true);
	instance.setMovementMultiplier(-100.0f);

    return &instance;
}

void Bomber::fire(Point2D pos)
{
	ProjectileEmitter::fire(pos);
	s_sounds->PlaySound(Sounds::SHOOT_INVADER);
}

void Bomber::Draw()
{
	if (m_showTrails)
	{
		for (int i = 0; i < m_projectileCount; ++i)
		{
			if (!m_projectiles[i].m_isDead)
			{
				m_gameProjectileObjectBomb->setPos(m_projectiles[i].m_position);
				m_gameProjectileObjectBomb->Draw();

				//m_baseProjectile->setPos(m_projectiles[i].m_position);
				//m_baseProjectile->Draw();
			}
		}
	}
	ProjectileEmitter::Draw();
}

