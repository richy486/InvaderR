//
//  ProjectileEmitter.h
//  InvaderR
//
//  Created by Richard Adem on 4/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#pragma once
#ifndef _PROJECTILE_EMITTER_H_
#define _PROJECTILE_EMITTER_H_

#include "GameObject.h"
#include "GameProjectileObject.h"

class ProjectileEmitter : public GameObject
{
public:
	ProjectileEmitter(const int projectleCount);
	virtual ~ProjectileEmitter();
	
	virtual void Init();
	virtual void Draw();
	
	virtual void killAll();
	virtual void setMovementMultiplier(float multiplier);
	virtual void fire(Point2D pos);
	virtual void update(float seconds);
	
	virtual void setHurtsPlayer(bool hurts);
	virtual void setHurtsInvaders(bool hurts);
	virtual void setHurtsBases(bool hurts);
	
protected:
	int m_lastProjectile;
	int m_projectileCount;
	Projectile* m_projectiles;
	GameProjectileObject* m_baseProjectile;
	
	bool m_hurtsPlayer;
	bool m_hurtsInvaders;
	bool m_hurtsBases;
	
	float m_movementMultiplier;
	
	BOOL m_showTrails;

	virtual int getNextProjectile();
};

#endif // _PROJECTILE_EMITTER_H_