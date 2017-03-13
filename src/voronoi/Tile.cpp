
#include "Tile.h"


Tile::Tile()
: x(-1)
, y(-1)
, repr(0.0f, 0.0f)
{
	this->ResetClosest();
}

void Tile::SetValues(int _x, int _y, float _reprX, float _reprY)
{
	this->x = _x;
	this->y = _y;
	this->ResetClosest();

	floatPoint point{ _reprX, _reprY };
	this->repr = point;
}


void Tile::ResetClosest()
{
	this->closestSiteIndex = -1;
	this->sectorId = -1;
	this->closestDist = 120.0f * 120.0f;
}


float Tile::DistanceTo(floatPoint point)
{
	float dX = (this->x + this->repr.x - point.x);
	float dY = (this->y + this->repr.y - point.y);

	return sqrt(dX * dX + dY * dY);
}


vector<pair<int, int> > Tile::GetNeighbors(int tilesW, int tilesH)
{
	vector<pair<int, int> > neighbors;
	bool roomLeft = this->x > 0;
	bool roomRight = this->x < tilesW - 1;
	bool roomUp = this->y > 0;
	bool roomDown = this->y < tilesH - 1;
	if (roomLeft)
	{
		neighbors.push_back({this->x - 1, this->y});
		if (roomUp)
		{
			neighbors.push_back({ this->x - 1, this->y - 1 });
		}
		if (roomDown)
		{
			neighbors.push_back({ this->x - 1, this->y + 1 });
		}
	}
	if (roomRight)
	{
		neighbors.push_back({ this->x + 1, this->y });
		if (roomUp)
		{
			neighbors.push_back({ this->x + 1, this->y - 1 });
		}
		if (roomDown)
		{
			neighbors.push_back({ this->x + 1, this->y + 1 });
		}
	}
	if (roomUp)
	{
		neighbors.push_back({ this->x, this->y - 1 });
	}
	if (roomDown)
	{
		neighbors.push_back({ this->x, this->y + 1 });
	}
	return neighbors;
}
