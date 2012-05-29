/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#pragma once
#ifndef _INVADER_H_
#define _INVADER_H_

#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "consts.h"
#include "GameCharacterObject.h"

//#define USE_VBO

class Invader : public GameCharacterObject
{
public:
	Invader(void);
	virtual ~Invader(void);

	virtual void Init();
	virtual void Draw();
	
	virtual void setPreviousPosition(Point2D pos);
	virtual void setPreviousPosition(float x, float y);
	virtual Point2D getPreviousPosition();
	
	void Update(float seconds);
	void Fire();
	
	void SetDead(bool dead) { m_isDead = dead; }
	bool IsDead() { return m_isDead; }
	
	bool* GetImage();
	
private:
	void SetColour(int r, int g, int b);
	
	bool m_justFired;
	float m_timeSinceFired;
	
	Point2D m_previousPosition;

	
	GLubyte m_coloursNormal[25][4][4];
	GLubyte m_coloursFire[25][4][4];

	bool m_isDead;
};

#endif //_INVADER_H_