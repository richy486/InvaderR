/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#pragma once
#ifndef _INVADER_SET_H_
#define _INVADER_SET_H_

#include <stdlib.h>
#include <time.h>
#include <list>
using namespace std;
#include "invader.h"
#include "bomber.h"
#include "ExplodeParticleSystem.h"

static const int s_invRowCount = 5;
static const int s_invColCount = 10;

namespace INVADERS_STATE
{
	enum INVADERS_STATE
	{
		INTRO,
		PLAYING,
		VICTORY,
		LOSE,
		COUNT
	};
}

class InvaderSet
{
private:
	InvaderSet(void);

public:
	~InvaderSet(void);
	static InvaderSet* getInstance();

	void setPlaying(bool val){m_playing = val;}
	bool getPlaying(){return m_playing;}

	void spawnNewSet();
	bool testHits(Point2D p);
	INVADERS_STATE::INVADERS_STATE Update(float seconds);
	void restart();
	void killAll();

	void drawSet();
	
protected:
	//list<Invader> m_invaders;
	Invader m_invaders[s_invRowCount * s_invColCount];
	int side2side;
	bool side; //true = left, false = right
	bool m_playing;
	
private:
	INVADERS_STATE::INVADERS_STATE m_state;
	void UpdateIntro(float seconds);
	void UpdatePlaying(float seconds);
	void UpdateVictory(float seconds);
	bool IsAllDead();
	int GetAliveCount();
	
	bool m_gameOver;
	float m_accumSecondsFire; // seconds since last fire
	ExplodeParticleSystem* m_particles;

	float m_xSpeed;
	float m_ySpeed;
	float m_secondsTillFire;
};

#endif // _INVADER_SET_H_