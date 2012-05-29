/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#pragma once
#ifndef _PLAYER_H_
#define _PLAYER_H_

#include "consts.h"
#include "GameCharacterObject.h"

class Player : public GameCharacterObject
{
public:
	Player(void);
	virtual ~Player(void);
	static Player* getInstance();

	void start();
	bool testHit(Point2D p);
	
	virtual void Init();
	virtual void Draw();

	virtual void update(float seconds, float controllerInX);

private:
	float m_lastControllerInX;
	float m_accel;
	BOOL m_oldControls;
};

#endif // _PLAYER_H_