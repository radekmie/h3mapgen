
#pragma once

#ifndef __MGR_Sector_h__
#define __MGR_Sector_h__


#include "Common.h"


class Sector
{
public:
	floatPoint topLeft;
	floatPoint bottomRight;
	int id;

public:
	Sector(floatPoint _topLeft = { 0.0f, 0.0f }, floatPoint _bottomRight = { 0.0f, 0.0f }, int _id = -1);

	bool Contains(floatPoint point);
};


inline bool Sector::Contains(floatPoint point)
{
	return (this->topLeft.x <= point.x
		&& this->topLeft.y <= point.y
		&& this->bottomRight.x >= point.x
		&& this->bottomRight.y >= point.y);
}


#endif /* __MGR_Sector_h__ */
