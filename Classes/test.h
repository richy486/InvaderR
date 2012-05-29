//
//  test.h
//  InvaderR
//
//  Created by Richard Adem on 2/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#pragma once
#ifndef _TEST_H_
#define _TEST_H_

#include "consts.h"

class Test
{
public:
	Test();
	~Test();

	void Draw();
	
private:
	GLuint cubeVBO;
	GLuint cubeIBO;
};

#endif // _TEST_H_
