//
//  Score.mm
//  Invader
//
//  Created by Richard Adem on 30/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include "Score.h"

static Score* s_instance = NULL;
Score::~Score()
{
	
}

Score* Score::GetInstance()
{
	if (s_instance == NULL)
	{
		s_instance = new Score();
		s_instance->LoadHighScore();
	}
	return s_instance;
}

void Score::Update(float seconds)
{
	if (m_visualScore < m_currentActualScore)
	{
		m_visualScore += (int)(seconds * 250.0f);
	}
	else if (m_visualScore > m_currentActualScore)
	{
		m_visualScore = m_currentActualScore;
	}

}

void Score::Draw()
{
	
}

void Score::AddToScore(int val)
{
	m_visualScore = m_currentActualScore;
	m_currentActualScore += val;
}

void Score::ResetScore()
{
	m_currentActualScore = 0;
	m_visualScore = 0;
}

int Score::GetCurrentActualScore()
{
	return m_currentActualScore;
}
int Score::GetVisualScore()
{
	return m_visualScore;
}

int Score::GetHighScore()
{
	return m_highScore;
}

bool Score::CheckChangeHighScore()
{
	LoadHighScore();
	if (m_currentActualScore > m_highScore)
	{
		m_highScore = m_currentActualScore;
		SaveHighScore();
		return true;
	}
	else
	{
		return false;
	}
}

Score::Score()
: m_currentActualScore(0)
, m_visualScore(0)
, m_highScore(0)
{
	
}

void Score::SaveHighScore()
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setInteger:m_highScore forKey:@"highScoreKey"];
	[prefs synchronize];
	
}

void Score::LoadHighScore()
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSInteger highScore = [prefs integerForKey:@"highScoreKey"];
	m_highScore = highScore;
}
