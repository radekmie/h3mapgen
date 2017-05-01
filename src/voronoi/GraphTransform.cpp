
#include "GraphTransform.h"

GraphTransform::GraphTransform(pair<int, int> _tilesDim, pair<int, int> _sectorsDim)
{
	this->tilesDim = _tilesDim;
	this->sectorsDim = sectorsDim;
	this->tiles = new Tile*[tilesDim.first];
	for (int y = 0; y < tilesDim.first; ++y)
	{
		this->tiles[y] = new Tile[tilesDim.second];
	}
	for (int y = 0; y < tilesDim.first; ++y)
	{
		for (int x = 0; x < tilesDim.second; ++x)
		{
			this->tiles[y][x].SetValues(x, y, 0.5f, 0.5f);
		}
	}
}


GraphTransform::~GraphTransform()
{
	for (int y = 0; y < tilesDim.first; ++y)
	{
		delete[] tiles[y];
	}
	delete[] tiles;
}


void GraphTransform::DivideTilesByPoints(vector<Site>& _sites)
{

}
