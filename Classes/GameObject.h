/*
 *  GameObject.h
 *  ___PROJECTNAME___
 *
 *  Created by Richard Adem on 23/12/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#pragma once
#ifndef _GAME_OBJECT_H_
#define _GAME_OBJECT_H_

#include "consts.h"

#include "Sounds.h"

class GameObject
{
public:
	GameObject();
	virtual ~GameObject();
	
	
	virtual void Init();
	virtual void Draw();
	
public:
	//static Sounds* getSounds();
	static Sounds* s_sounds;
	
};
#endif _GAME_OBJECT_H_