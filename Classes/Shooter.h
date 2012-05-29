/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#pragma once
#ifndef _SHOOTER_H_
#define _SHOOTER_H_

#include "GameObject.h"

#include <list>
using namespace std;
#include "consts.h"
#include "baseset.h"
#include "projectile.h"
#include "ProjectileEmitter.h"
#include "GameProjectileObject.h"
#include "GameProjectileObjectShot.h"

class Shooter : public ProjectileEmitter
{
public:
	Shooter(const int projectleCount);
	virtual ~Shooter(void);
	
	virtual void fire(Point2D pos);
	virtual void Draw();
	
private:
	GameProjectileObjectShot* m_gameProjectileObjectShot;
};

#endif // _SHOOTER_H_