//
//  SpriteCharacterObject.mm
//  InvaderR
//
//  Created by Richard Adem on 20/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#include "SpriteCharacterObject.h"

SpriteCharacterObject::SpriteCharacterObject(float x, float y, CharacterObject* characterObject)
: Sprite()

{
	Point2D point;
	point.x = x;
	point.y = y;
	setPos(point);
	
	Load(characterObject);
	SetupVBO();
}

SpriteCharacterObject::~SpriteCharacterObject()
{}

SpriteCharacterObject* SpriteCharacterObject::Create(float x, float y, CharacterObject* characterObject)
{
	SpriteCharacterObject* sprite = new SpriteCharacterObject(x, y, characterObject);
	return sprite;
}

void SpriteCharacterObject::Load(CharacterObject* characterObject)
{
	
	
}