//
//  GameMoveableObject.mm
//  InvaderR
//
//  Created by Richard Adem on 4/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#import "GameMoveableObject.h"

GameMoveableObject::GameMoveableObject()
: GameObject()
, m_pos(100.0f, 100.0f)
{}
GameMoveableObject::~GameMoveableObject()
{}

void GameMoveableObject::setPos(Point2D p)
{
	m_pos = p;
}
void GameMoveableObject::setPos(float x, float y)
{
	m_pos.x = x;
	m_pos.y = y;
}
Point2D GameMoveableObject::getPos()
{
	return m_pos;
}