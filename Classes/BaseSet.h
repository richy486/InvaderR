/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#pragma once
#ifndef _BASE_SET_H_
#define _BASE_SET_H_

#include "base.h"
#include "projectile.h"

static const int s_baseCount = 5;

enum RELATIVE_POSITION
{
	ABOVE,
	INSIDE,
	BELOW,
	COUNT
};

class BaseSet
{
protected:
	Base base[s_baseCount];
public:
	BaseSet(void);
	~BaseSet(void);
	static BaseSet* getInstance();

	void makeBases();
	bool checkHits(Point2D& currentPos, Point2D& previousPosition);

	void drawBases();
	
private:
	RELATIVE_POSITION GetRelativePosition(float y);
};
#endif //_BASE_SET_H_