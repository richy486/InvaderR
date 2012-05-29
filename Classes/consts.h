/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#pragma once
#ifndef _CONSTS_H_
#define _CONSTS_H_

#if defined USE_GLUT
	#include <GL/glut.h>
#elif defined WINDOWS
	#include <windows.h>
	#include <gl\gl.h>
	#include <gl\glu.h>
#else
	#import <OpenGLES/EAGL.h>
	#import <OpenGLES/ES1/gl.h>
	#import <OpenGLES/ES1/glext.h>

	#import <Foundation/Foundation.h>
#endif

#include <stdio.h>
#include <time.h>
#include <iostream>
#include <sstream>
#include "md5.h"
#import <mach/mach.h>
#import <mach/mach_time.h>

// size of a invader pixel
#define IPS 3
// size of a win/loose pixel
#define TPS 50
// time between glutTimerFunc calls
#define FRAMERATE 15
//position on the screen
struct Point2D
{
	Point2D()
	: x(0.0f)
	, y(0.0f)
	{}
	
	Point2D(float inX, float inY)
	: x(inX)
	, y(inY)
	{}
	
	float x;
	float y;
};

#ifndef RELEASE
#define Log(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define Log(format, ...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define GAME_WIDTH 480
#define GAME_HEIGHT 320

// debug defines
//#define TURN_OFF_ALL_BUT_GAME_CHARACTER_OBJECTS
#define USE_VBO
//#define USE_TEST_OBJECTS
//#define USE_BACKGROUNDS
//#define DISABLE_SOUNDS
#define DISABLE_MUSIC
//#define GOD_MODE
#define DISABLE_TWITTER
//#define SHOW_FPS_ONSCREEN
#define LESS_PARTICLES
//#define DISABLE_TEXT_DRAW
//#define DISABLE_PARTICALES_DRAW
#define DISABLE_STATS
#define USE_SPEEDUP
//#define USE_GAMECENTER

#endif // _CONSTS_H_