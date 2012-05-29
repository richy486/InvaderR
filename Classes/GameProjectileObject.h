//
//  GameProjectileObject.h
//  InvaderR
//
//  Created by Richard Adem on 4/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#pragma once
#ifndef _GAME_PROJECTILE_OBJECT_H_
#define _GAME_PROJECTILE_OBJECT_H_

#include "GameMoveableObject.h"
#include "consts.h"
#include "Projectile.h"

class GameProjectileObject : public GameMoveableObject
{
public:
	GameProjectileObject();
	virtual ~GameProjectileObject();
	
	virtual void Init();
	virtual void Draw();

	// This must be called before setUpVBOs()
	virtual void SetColour(GLuint red, GLuint green, GLuint blue, GLuint alpha);
	
	virtual void setPreviousPosition(Point2D pos);
	virtual void setPreviousPosition(float x, float y);
	virtual Point2D getPreviousPosition();
	
	virtual void setDead(bool isDead);
	virtual bool isDead();
	

protected:
	GLuint m_colRed, m_colGreen, m_colBlue, m_colAlpha;
	
	GLuint m_vertexBufferObject;
	GLuint m_indexBufferObject;
	
	Point2D m_previousPosition;
	bool m_isDead;
	
	virtual void setUpVBOs();	
	virtual void destroyVBOs();

	virtual void drawVBOs();	
};

#endif // _GAME_PROJECTILE_OBJECT_H_

