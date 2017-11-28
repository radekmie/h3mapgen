
#include "Tile.h"


Tile::Tile()
: repr(-1.0f, -1.0f)
{
	this->ResetValues();
}


void Tile::SetPosition(int _x, int _y)
{
	this->repr = floatPoint{ (float)_x + 0.5f, (float)_y + 0.5f };
	this->ResetValues();
}


void Tile::ResetValues()
{
	this->ownerId = -1;
	this->ownerDist = 200.0f * 200.0f;
	this->isEdge = false;
	this->isBridge = false;
}


float Tile::DistanceTo(floatPoint point)
{
	float dX = this->repr.x - point.x;
	float dY = this->repr.y - point.y;

	return sqrt(dX * dX + dY * dY);
}


vector<pair<int, int> > Tile::GetNeighbors(int tilesW, int tilesH)
{
	vector<pair<int, int> > neighbors;
	int x = (int)this->repr.x;
	int y = (int)this->repr.y;
	bool roomLeft = x > 0;
	bool roomRight = x < tilesW - 1;
	bool roomUp = y > 0;
	bool roomDown = y < tilesH - 1;
	if (roomLeft)
	{
		neighbors.push_back({x - 1, y});
		if (roomUp)
		{
			neighbors.push_back({ x - 1, y - 1 });
		}
		if (roomDown)
		{
			neighbors.push_back({ x - 1, y + 1 });
		}
	}
	if (roomRight)
	{
		neighbors.push_back({ x + 1, y });
		if (roomUp)
		{
			neighbors.push_back({ x + 1, y - 1 });
		}
		if (roomDown)
		{
			neighbors.push_back({ x + 1, y + 1 });
		}
	}
	if (roomUp)
	{
		neighbors.push_back({ x, y - 1 });
	}
	if (roomDown)
	{
		neighbors.push_back({ x, y + 1 });
	}
	return neighbors;
}
