/*
 *  projectile.h
 *  InvaderR
 *
 *  Created by Richard Adem on 30/01/10.
 *  Copyright 2010 vorticity. All rights reserved.
 *
 */

#pragma once
#ifndef _PROJECTILE_H_
#define _PROJECTILE_H_

struct Projectile
{
	Point2D m_position;
	Point2D m_previousPosition;
	bool m_isDead;
};

#endif