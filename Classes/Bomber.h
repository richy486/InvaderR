/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#pragma once
#ifndef _BOMBER_H_
#define _BOMBER_H_

#include "GameObject.h"
#include <list>
using namespace std;
#include "consts.h"
#include "player.h"
#include "baseset.h"
#include "ProjectileEmitter.h"
#include "GameProjectileObject.h"
#include "GameProjectileObjectBomb.h"

class Bomber : public ProjectileEmitter
{
public:
	Bomber(const int projectleCount);
	virtual ~Bomber(void);
	static Bomber* getInstance();
	
	virtual void fire(Point2D pos);
	
	virtual void Draw();
	
private:
	GameProjectileObjectBomb* m_gameProjectileObjectBomb;
};
#endif //_BOMBER_H_