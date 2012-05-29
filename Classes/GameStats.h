//
//  GameStats.h
//  InvaderR
//
//  Created by Richard Adem on 8/02/11.
//  Copyright 2011 vorticity. All rights reserved.
//

class GameStats
{
private:
	int m_shotsHit;
	int m_shotsMissed;
	
	int m_replayCount;
	
	double m_gameStartTime;
	
	int m_levelCount;
public:
	GameStats();
	virtual ~GameStats();
	
	void ResetShots();
	void AddShot(bool didHit);
	float GetShotPercentage01();
	
	void ResetReaplys();
	void AddReplay();
	int GetReplayCount();
	
	void ResetGameTime();
	int GetCurrentGameTime();
	
	void ResetLevel();
	void AddLevel();
	int GetLevelCount();
};