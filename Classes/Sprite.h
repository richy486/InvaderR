//
//  Sprite.h
//  InvaderR
//
//  Created by Richard Adem on 28/01/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#pragma once
#ifndef _SPRITE_H_
#define _SPRITE_H_

#include "GameMoveableObject.h"
#include "consts.h"

class Sprite : public GameMoveableObject
{
public:
	static Sprite* Create(float x, float y, NSString* file);

	virtual ~Sprite();
		
	virtual void Draw();
	
private:
	Sprite(float x, float y, NSString* file);
	
	void Load(NSString* file);

protected:
	GLuint m_glTexture;
	GLuint m_width;
	GLuint m_height;
	
	GLuint m_vertexBufferObject;
	GLuint m_indexBufferObject;

	Sprite();
	virtual void SetupVBO(); // called after load
};

#endif // _SPRITE_H_