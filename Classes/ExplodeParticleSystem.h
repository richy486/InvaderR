//
//  ParticleSystem.h
//  InvaderR
//
//  Created by Richard Adem on 21/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#pragma once
#ifndef _EXPLODE_PARTICLE_SYSTEM_H_
#define _EXPLODE_PARTICLE_SYSTEM_H_

#include "consts.h"
#include "ParticleSystem.h"

class GameProjectileObject;

class ExplodeParticleSystem : public ParticleSystem
{
public:
	ExplodeParticleSystem();
	virtual ~ExplodeParticleSystem();
	
	virtual void Init();
	virtual void Update(float seconds);
	virtual void Draw();
	virtual void ShutDown();
	
	virtual void StartParticles(Point2D pos);
	virtual void StartParticles(Point2D pos, bool* img, int imgSize = 25);
	virtual void KillAllParticles();
	
private:
	GameProjectileObject* m_baseProjectile;
};

#endif // _EXPLODE_PARTICLESYSTEM_H_