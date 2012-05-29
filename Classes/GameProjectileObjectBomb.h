//
//  GameProjectileObject.h
//  InvaderR
//
//  Created by Richard Adem on 4/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#pragma once
#ifndef _GAME_PROJECTILE_OBJECT_BOMB_H_
#define _GAME_PROJECTILE_OBJECT_BOMB_H_

#include "GameProjectileObject.h"
#include "consts.h"

class GameProjectileObjectBomb : public GameProjectileObject
{
public:
	GameProjectileObjectBomb();
	virtual ~GameProjectileObjectBomb();

protected:
	void setUpVBOs();	
};

#endif // _GAME_PROJECTILE_OBJECT_BOMB_H_

