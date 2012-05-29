//
//  GameStats.mm
//  InvaderR
//
//  Created by Richard Adem on 8/02/11.
//  Copyright 2011 vorticity. All rights reserved.
//

#import "GameStats.h"
#include "Game.h"

GameStats::GameStats()
: m_shotsHit(0)
, m_shotsMissed(0)
, m_replayCount(0)
, m_gameStartTime(0.0)
, m_levelCount(-1)
{}
GameStats::~GameStats()
{}

void GameStats::ResetShots()
{
	m_shotsHit = 0;
	m_shotsMissed = 0;
}
void GameStats::AddShot(bool didHit)
{
	didHit ? m_shotsHit++ : m_shotsMissed++;
}
float GameStats::GetShotPercentage01()
{
	float total = m_shotsHit + m_shotsMissed;
	if (total > 0.0f)
	{
		return m_shotsHit / total;
	}
	else 
	{
		return 0.0f;
	}

}

void GameStats::ResetReaplys()
{
	m_replayCount = 0;
}
void GameStats::AddReplay()
{
	m_replayCount++;
}
int GameStats::GetReplayCount()
{
	return m_replayCount;
}

void GameStats::ResetGameTime()
{
	m_gameStartTime = (int) Game::GetInstance()->DoublePrecisionSeconds();
}
int GameStats::GetCurrentGameTime()
{
	double now = Game::GetInstance()->DoublePrecisionSeconds();
	return (int)(now - m_gameStartTime);
}

void GameStats::ResetLevel()
{
	m_levelCount = -1;
}
void GameStats::AddLevel()
{
	m_levelCount++;
}
int GameStats::GetLevelCount()
{
	return m_levelCount;
}
