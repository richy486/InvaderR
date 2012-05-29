/*
 *  GameObject.cpp
 *  ___PROJECTNAME___
 *
 *  Created by Richard Adem on 23/12/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include "GameObject.h"

#include "OpenGLCommon.h"

GameObject::GameObject()
{
}


GameObject::~GameObject()
{
}

Sounds* GameObject::s_sounds = new Sounds();

void GameObject::Init()
{
}

void GameObject::Draw()
{
}

/*Sounds* GameObject::getSounds()
{
	static Sounds instance;
    return &instance;
}*/