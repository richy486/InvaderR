//
//  Score.h
//  Invader
//
//  Created by Richard Adem on 30/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

// For storing score and updating the visual score.
#pragma once
#ifndef _SCORE_H_
#define _SCORE_H_



static const int s_scoreKill = 50;

class Score
{
public:
	~Score();
	static Score* GetInstance();
	
	void Update(float seconds);
	void Draw();
	
	void AddToScore(int val);
	void ResetScore();
	
	int GetCurrentActualScore();
	int GetVisualScore();
	int GetHighScore();
	
	bool CheckChangeHighScore(); // returns if there is a new high score.
	
private:
	Score();

	int m_currentActualScore; // this is the real score, as soon as you get points this is correct.
	int m_visualScore; // this is the score that is displayed on screen, so it can count up and look nice.
	int m_highScore;
	
	void LoadHighScore();
	void SaveHighScore();
};

#endif // _SCORE_H_