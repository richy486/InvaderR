//
//  SpriteCharacterObject.h
//  InvaderR
//
//  Created by Richard Adem on 20/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#pragma once
#ifndef _SPRITE_CHARACTER_OBJECT_
#define _SPRITE_CHARACTER_OBJECT_

#include "Sprite.h"

class CharacterObject;

class SpriteCharacterObject : public Sprite
{
public:
	static SpriteCharacterObject* Create(float x, float y, CharacterObject* characterObject);
	virtual ~SpriteCharacterObject();
	
private:
	SpriteCharacterObject(float x, float y, CharacterObject* characterObject);

	SpriteCharacterObject() : Sprite() {}
	static SpriteCharacterObject* Create(float x, float y, NSString* file) { return NULL; }
	void Load(CharacterObject* characterObject);
	
};

#endif // _SPRITE_CHARACTER_OBJECT_
