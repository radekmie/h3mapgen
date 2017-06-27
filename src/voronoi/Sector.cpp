
#include "Sector.h"


Sector::Sector(floatPoint _topLeft, floatPoint _bottomRight, int _id, int _weight)
: id(_id)
, weight(_weight)
, topLeft(_topLeft)
, bottomRight(_bottomRight)
, repr((_topLeft.x + _bottomRight.x) / 2.0f, (_topLeft.y + _bottomRight.y) / 2.0f)
{

}


bool Sector::Contains(floatPoint _point)
{
	return (this->topLeft.x <= _point.x
		&& this->topLeft.y <= _point.y
		&& this->bottomRight.x >= _point.x
		&& this->bottomRight.y >= _point.y);
}


void Sector::AddConnection(sectorIndex _sectorIndex)
{
	this->connected.push_back(_sectorIndex);
}

