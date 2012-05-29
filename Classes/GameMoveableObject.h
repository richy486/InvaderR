//
//  GameMoveableObject.h
//  InvaderR
//
//  Created by Richard Adem on 4/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#pragma once
#ifndef _GAME_MOVEABLE_OBJECT_H_
#define _GAME_MOVEABLE_OBJECT_H_

#include "GameObject.h"

class GameMoveableObject : public GameObject 
{
public:
	GameMoveableObject();
	virtual ~GameMoveableObject();
	
	virtual void setPos(Point2D p);
	virtual void setPos(float x, float y);
	virtual Point2D getPos();

protected:
	Point2D m_pos;
};

#endif // _GAME_MOVEABLE_OBJECT_H_
