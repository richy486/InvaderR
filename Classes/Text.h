/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#pragma once
#ifndef _TEXT_H_
#define _TEXT_H_

#include "GameObject.h"
#include "consts.h"
#include <list>
#include <vector>

struct GLPoint2D
{
	GLPoint2D(GLfloat X, GLfloat Y) 
	: x(X), y(Y) {}
	GLfloat x;
	GLfloat y;
};

namespace TEXTSIZE
{
	enum TEXTSIZE
	{
		EIGHT,
		SIXTEEN,
		COUNT
	};
}

class TextBox;

class TextController
{
public:
	~TextController();
	static TextController* GetInstance();
	
	//TextBox* CreateText(float x, float y, TEXTSIZE::TEXTSIZE size, const wchar_t* fmt, ...);
	TextBox* CreateText(float x, float y, TEXTSIZE::TEXTSIZE size, const wchar_t* text);

	void DeleteText(TextBox* textBox);
	void DeleteAll();
	
private:
	TextController();
	std::list<TextBox*> m_textBoxes;
};


#include "GameMoveableObject.h"

static const int s_maxTextLength = 64;

class TextBox : public GameMoveableObject
{
	friend class TextController;

public:
	virtual ~TextBox();
	
	static void InitTexture(); // Must be called before Draw()
	
	virtual void Draw();
	//void SetText(const wchar_t* fmt, ...);
	void SetText(const wchar_t* text);
	const wchar_t* GetText();
	void SetSize(TEXTSIZE::TEXTSIZE size);
	
private:
	TextBox();
	
	wchar_t m_text[s_maxTextLength];
	TEXTSIZE::TEXTSIZE m_size;
	
};

#endif // _TEXT_H_

#import <Foundation/Foundation.h>


@interface UTextConverter : NSObject 
{
	
}

+ (wchar_t*) ConvertUText:(NSString*) text;

@end