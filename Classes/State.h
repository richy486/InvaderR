//
//  State.h
//  Invader
//
//  Created by Richard Adem on 27/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#pragma once
#ifndef _STATE_H_
#define _STATE_H_

class State
{
public:
	State() : m_ended(true) {}
	virtual ~State() {}
	
	void Init() { m_ended = false; }
	virtual void Update(float seconds) = 0;
	virtual void Draw() = 0;
	void End() { m_ended = true; }
	
	bool IsEnded() { return m_ended; }
private:
	bool m_ended;
};

#endif // _STATE_H_