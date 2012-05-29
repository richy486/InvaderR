#pragma once
#ifndef _BASE_H_
#define _BASE_H_

#include "consts.h"
#include "GameCharacterObject.h"
#include "projectile.h"

class Base : public GameCharacterObject
{
public:
	Base(void);
	virtual ~Base(void);

	bool TestHit(Point2D& currentPos, Point2D& previousPos);

	virtual void Init();
	virtual void Draw();
	
private:
	void updateVBO();
};
#endif //_BASE_H_