//
//  ParticleSystem.h
//  InvaderR
//
//  Created by Richard Adem on 21/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#pragma once
#ifndef _PARTICLE_SYSTEM_H_
#define _PARTICLE_SYSTEM_H_

#include "consts.h"
#include <vector>

static const int s_poolSize = 50;

struct Particle
{
	Point2D m_position;
	Point2D m_direction;
	float m_speed;
	bool m_isDead;
};

class ParticleSystem
{
public:
	ParticleSystem() {}
	virtual ~ParticleSystem() {}
	
	virtual void Init() = 0;
	virtual void Update(float seconds) = 0;
	virtual void Draw() = 0;
	virtual void ShutDown() = 0;
	
	virtual void StartParticles(Point2D pos) = 0;
	virtual void KillAllParticles() = 0;
	
	virtual int GetAvailablePool()
	{
		for (int i = 0; i < s_poolSize; ++i)
		{
			if (m_availablePools[i])
			{
				return i;
			}
		}
		//assert(false && "no pools available");
		Log(@"GetAvailablePool: no pools available");
		return -1;
	}
	
protected:
	std::vector<Particle> m_particles[s_poolSize];
	bool m_availablePools[s_poolSize];
};

#endif // _PARTICLE_SYSTEM_H_