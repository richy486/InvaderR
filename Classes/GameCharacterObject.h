//
//  GameCharacterObject.h
//  Invader
//
//  Created by Richard Adem on 25/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#pragma once
#ifndef _GAME_CHARACTER_OBJECT_H_
#define _GAME_CHARACTER_OBJECT_H_

#include "consts.h"
#include "GameMoveableObject.h"

class GameCharacterObject : public GameMoveableObject
{
public:
	GameCharacterObject();
	virtual ~GameCharacterObject();

	virtual void Init();
	virtual void Draw();


protected:
	bool m_image[25];
	GLenum m_bufferedDataUsage;
	
	virtual int getImgIndexOffsetToStrip(int index);
	
	GLuint m_vertexBufferObject;
	GLuint m_indexBufferObject;
	int m_red, m_green, m_blue, m_alpha;

private:
	void setUpVBOs();
	void destroyVBOs();
	void drawVBOs();
	
};


#endif // _GAME_CHARACTER_OBJECT_H_