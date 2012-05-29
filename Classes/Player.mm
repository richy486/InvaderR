/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#include "player.h"

#define BASECLASS GameCharacterObject

static const float s_decay = 0.8f;

Player::Player(void)
: GameCharacterObject()
, m_lastControllerInX(0.0f)
, m_accel(0.0f)
, m_oldControls(NO)
{
}

Player::~Player(void)
{
}
Player* Player::getInstance()
{
	static Player instance;
    return &instance;
}

// Put the player in the start position.
void Player::start()
{
	m_pos.x = 230;
	m_pos.y = 10;
	m_lastControllerInX = 0.0f;
	m_accel = 0.0f;
}
// Test if the player was hit by an invader's bomb, or invader.
bool Player::testHit(Point2D p)
{
	if(p.x >= m_pos.x-1 && p.x <= m_pos.x+(IPS*5)-1 
	   && p.y >= m_pos.y && p.y <= m_pos.y+(IPS*5))
	{
#ifndef	GOD_MODE
		s_sounds->PlaySound(Sounds::HIT_PLAYER);
		return true;
#else
		return false;
#endif
	}
	else
	{
		return false;
	}
}

void Player::Init()
{
	Log(@"Making Player");
	for(int i = 0; i < 25; i++)
	{
		m_image[i] = false;
	}
	m_image[0] = true;
	m_image[1] = true;
	m_image[6] = true;
	m_image[7] = true;
	m_image[8] = true;
	m_image[11] = true;
	m_image[12] = true;
	m_image[13] = true;
	m_image[14] = true;
	
	m_image[16] = true;
	m_image[17] = true;
	m_image[18] = true;
	m_image[20] = true;
	m_image[21] = true;
	
	m_red = 96; // 200;
	m_green = 96; // 200;
	m_blue = 255;
	m_alpha = 255;
	
	m_oldControls = [[NSUserDefaults standardUserDefaults] boolForKey:@"old_controls"];
	Log(@"m_oldControls: %d", m_oldControls);

	BASECLASS::Init();
}

// Draw the player at its position.
void Player::Draw()
{
	//glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	BASECLASS::Draw();
}

void Player::update(float seconds, float controllerInX)
{
	float xMove;
	
	if (m_oldControls)
	{
		xMove = controllerInX;
		m_lastControllerInX = controllerInX;
		
		float moveAmount = 0.0f;
		if (xMove > 0.0f)
		{
			//moveAmount = pow(2.0f, xMove);
			moveAmount = pow(10.0f, xMove) / 10.0f;
		}
		else
		{
			//moveAmount = -pow(2.0f, fabs(xMove));
			moveAmount = -(pow(10.0f, fabs(xMove)) / 10.0f);
		}
		
		m_accel = (3.5f * seconds * 300.0f * moveAmount) * s_decay;
		
		m_pos.x += m_accel;
	}
	else 
	{
		xMove = controllerInX;
		m_lastControllerInX = controllerInX;
		
		float moveAmount = 0.0f;
		const float toThePow = 1.1f;
		
		if (xMove > 0.0f)
		{
			moveAmount = pow(xMove, toThePow);
		}
		else
		{
			moveAmount = -pow(fabs(xMove), toThePow);
		}
		
		m_accel = (3.5f * seconds * 600.0f * moveAmount) * s_decay;
		
		if (m_accel > 5 * IPS)
		{
			m_accel = 5 * IPS;
		}
		else if (m_accel < -5 * IPS)
		{
			m_accel = -5 * IPS;
		}

		
		m_pos.x += m_accel;
	}

	
	if (m_pos.x < 20.0f)
		m_pos.x = 20.0f;
	if (m_pos.x > 450.0f)
		m_pos.x = 450.0f;
}
