/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#include "invader.h"
#include "Bomber.h"
#include "InvaderSet.h"
#include "Game.h"

#define BASECLASS GameCharacterObject

#define PIXEL_COUNT 25
#define NUMBER_OF_CUBE_VERTICES 4 * PIXEL_COUNT
#define NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX 3
#define NUMBER_OF_CUBE_COLORS 4 * PIXEL_COUNT
#define NUMBER_OF_CUBE_COMPONENTS_PER_COLOR 4

#define STAT_TRACKER Game::GetInstance()->StatTracker()

static const float s_firedGlowMaxSeconds = 0.5f;

Invader::Invader(void)
: GameCharacterObject()
, m_previousPosition(0.0f, 0.0f)
, m_isDead(false)
{
	m_bufferedDataUsage = GL_DYNAMIC_DRAW;
}

Invader::~Invader(void)
{
}


void Invader::Init()
{
	// 3 to 10 pixels
	const int minPixels = 3;
	const int maxPixels = 10;
	
	int randDifference = rand() % (maxPixels - minPixels);
	int pixelsInThisInvader = randDifference + minPixels;
	
	int bagOfFifteen[15];
	for (int i = 0; i < 15; ++i)
	{
		bagOfFifteen[i] = i;
	}
	
	// shuffle bag
	const int suffleTimes = 50;
	for (int i = 0; i < suffleTimes; ++i)
	{
		int firstNumber = rand()%15;
		int secondNumber = rand()%14;
		if (firstNumber == secondNumber)
		{
			if (firstNumber == 14)
				secondNumber = 0;
			else
				secondNumber++;
		}
		
		// swap numbers
		int temp = bagOfFifteen[firstNumber];
		bagOfFifteen[firstNumber] = bagOfFifteen[secondNumber];
		bagOfFifteen[secondNumber] = temp;
	}
	
	// enable the first [pixelsInThisInvader] elements after shuffle
	for (int i = 0; i < 25; ++i)
	{
		if (i < 15)
		{
			m_image[bagOfFifteen[i]] = (i < pixelsInThisInvader);
			
		}
		else if (i >= 15 && i < 20)
		{
			m_image[i] = m_image[i - 10];
		}
		else if (i >= 20)
		{
			m_image[i] = m_image[i - 20];
		}
	}
	
#if 0
	Log(@"testing less than three");
	
	int count = 0;
	for(int i = 0; i < 25; i++)
	{
		if (m_image[i])
			count++;
		Log(@"%d", m_image[i]);
	}
	if (count < 3)
	{
		Log(@"less than 3 in invader!!!");
	}
#endif	

	
	BASECLASS::Init();
	
	for (int i = 0; i < PIXEL_COUNT; ++i)
	{
		int offsetter = getImgIndexOffsetToStrip(i);
		for (int j = 0; j < 4; ++j)
		{
			if(m_image[i] == true)
			{
				m_coloursNormal[offsetter][j][0] = 255;
				m_coloursFire[offsetter][j][0] = 255;
				
				m_coloursNormal[offsetter][j][1] = 255;
				m_coloursFire[offsetter][j][1] = 128;
				
				m_coloursNormal[offsetter][j][2] = 255;
				m_coloursFire[offsetter][j][2] = 0;
				
				m_coloursFire[offsetter][j][3] = m_coloursNormal[offsetter][j][3] = 255;
			}
			else
			{
				m_coloursFire[offsetter][j][0] = m_coloursNormal[offsetter][j][0] = 255;
				m_coloursFire[offsetter][j][1] = m_coloursNormal[offsetter][j][1] = 255;
				m_coloursFire[offsetter][j][2] = m_coloursNormal[offsetter][j][2] = 255;
				m_coloursFire[offsetter][j][3] = m_coloursNormal[offsetter][j][3] = 0;
			}
		}
	}
}

void Invader::setPreviousPosition(Point2D pos)
{
	m_previousPosition = pos;
}
void Invader::setPreviousPosition(float x, float y)
{
	m_previousPosition.x = x;
	m_previousPosition.y = y;
}
Point2D Invader::getPreviousPosition()
{
	return m_previousPosition;
}

void Invader::Update(float seconds)
{
	// change colour back to normal after invader has fired
	if (m_justFired)
	{
		if (m_timeSinceFired >= s_firedGlowMaxSeconds)
		{
			//SetColour(255, 255, 255);
			
			const GLsizeiptr vertex_size = NUMBER_OF_CUBE_VERTICES * NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX * sizeof(GLfloat);
			const GLsizeiptr colour_size = NUMBER_OF_CUBE_COLORS * NUMBER_OF_CUBE_COMPONENTS_PER_COLOR * sizeof(GLubyte);
			glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferObject);
			glBufferSubData(GL_ARRAY_BUFFER, vertex_size, colour_size, m_coloursNormal);
			 
			m_justFired = false;
		}
		else 
		{
			m_timeSinceFired += seconds;
		}
	}
	
	// test collisions between invader and base
	if (m_pos.y <= 50 + (5 * IPS))
	{
		for (int i = 0; i < 25; ++i)
		{
			float iOfFive = i / 5;
			float iModFive = i % 5;
			float xBlockOffset = iOfFive * IPS;
			float yBlockOffset = iModFive * IPS;
			
			Point2D currentPos(m_pos.x + yBlockOffset, m_pos.y + xBlockOffset);
			Point2D previousPos(m_previousPosition.x + yBlockOffset, m_previousPosition.y + xBlockOffset);
			
			if (currentPos.y >= 0 && InvaderSet::getInstance()->getPlaying())
			{
				BaseSet::getInstance()->checkHits(currentPos, previousPos);
				if (Player::getInstance()->testHit(currentPos))
				{
					Log(@"death by collision");
					
					InvaderSet::getInstance()->setPlaying(false);
					
#ifndef DISABLE_STATS
					BOOL sendStats = [[NSUserDefaults standardUserDefaults] boolForKey:@"sendStats"];
					if (sendStats)
					{
						/*
						std::string* code = new std::string("go_cause");
						std::string* cause = new std::string("collision");
						STAT_TRACKER->Event(Game::GetInstance()->Sig()
																  , Game::GetInstance()->Key()
																  , code
																  , cause);
						 */
						[STAT_TRACKER SendEvent: @"go_cause"
										  value: @"collision"
										andTime: Game::GetInstance()->unixEpoch()];
					}
#endif
				}
			}
		}
	}
}

// Draws the invader at its position.
void Invader::Draw()
{
	// colour based on height.
/*	const int posFraction = 1700;
	const int mult = 2;
	glColor4f(1 - (m_pos.y / posFraction) * mult, 
			  1 - (m_pos.y / posFraction) * mult, 
			  1 - (m_pos.y / posFraction) * mult, 
			  1.0f);*/

	BASECLASS::Draw();
}




void Invader::Fire()
{
	Bomber::getInstance()->fire(Point2D(m_pos.x + (2.5f * IPS), m_pos.y));

	//SetColour(0, 255, 255);
	const GLsizeiptr vertex_size = NUMBER_OF_CUBE_VERTICES * NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX * sizeof(GLfloat);
	const GLsizeiptr colour_size = NUMBER_OF_CUBE_COLORS * NUMBER_OF_CUBE_COMPONENTS_PER_COLOR * sizeof(GLubyte);
	glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferObject);
	glBufferSubData(GL_ARRAY_BUFFER, vertex_size, colour_size, m_coloursFire);
	
	m_justFired = true;
	m_timeSinceFired = 0.0f;
}

void Invader::SetColour(int r, int g, int b)
{
	/*
	const GLsizeiptr vertex_size = NUMBER_OF_CUBE_VERTICES * NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX * sizeof(GLfloat);
	const GLsizeiptr colour_size = NUMBER_OF_CUBE_COLORS * NUMBER_OF_CUBE_COMPONENTS_PER_COLOR * sizeof(GLubyte);
	
	glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferObject);
	glBufferSubData(GL_ARRAY_BUFFER, vertex_size, colour_size, colours);
	
	GLenum gl_error = glGetError();
	if(GL_NO_ERROR != gl_error)
	{
		Log(@"Error: %d", gl_error);
	}
	 */
}

bool* Invader::GetImage()
{ 
	return *(&m_image); 
}


