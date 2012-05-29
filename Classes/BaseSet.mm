/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 *
 * invaderR is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * invaderR is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "baseset.h"
#include "consts.h"

BaseSet::BaseSet(void)
{

}
BaseSet::~BaseSet(void)
{
}
BaseSet* BaseSet::getInstance()
{
	static BaseSet instance;
    return &instance;
}
// Generate and place 5 bases.
void BaseSet::makeBases()
{
	Log(@"Making Bases");
	Point2D t_p;
	for(int i = 0; i < s_baseCount; i++)
	{
		base[i].Init();
		t_p.x = i*100+30;
		t_p.y = 50;
		base[i].setPos(t_p);
	}
}

// Check hits for all the bases.
bool BaseSet::checkHits(Point2D& currentPos, Point2D& previousPosition)
{
	RELATIVE_POSITION curRelativePosition = GetRelativePosition(currentPos.y);
	RELATIVE_POSITION prevRelativePosition = GetRelativePosition(previousPosition.y);
	
	// if passed through without touching
	// if inside
	if ((curRelativePosition != INSIDE && prevRelativePosition != INSIDE && curRelativePosition != prevRelativePosition)
		|| (curRelativePosition == INSIDE))
	{
		for(int i = 0; i < s_baseCount; i++)
		{
			if(base[i].TestHit(currentPos, previousPosition))
				return true;
		}
	}
	return false;
}

// Draw all the bases.
void BaseSet::drawBases()
{
	for(int i = 0; i < s_baseCount; i++)
	{
		base[i].Draw();
	}
}

RELATIVE_POSITION BaseSet::GetRelativePosition(float y)
{
	if (y >= 50)
	{
		if (y <= 50 + (5 * IPS))
			return INSIDE;
		else
			return ABOVE;
	}
	else
	{
		return BELOW;
	}
}