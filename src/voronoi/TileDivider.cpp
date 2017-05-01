
#include "TileDivider.h"


TileDivider::TileDivider(Sector** _sectors, pair<int, int> _sectorsDimensions)
: sectors(_sectors)
, sectorsDimensions(_sectorsDimensions)
, tilesDimensions(Constants::tilesVerti, Constants::tilesHoriz)
{
	tiles = new Tile*[tilesDimensions.first];
	for (int y = 0; y < tilesDimensions.first; ++y)
	{
		tiles[y] = new Tile[tilesDimensions.second];
		for (int x = 0; x < tilesDimensions.second; ++x)
		{
			this->tiles[y][x].SetPosition(x, y);
		}
	}
}


TileDivider::~TileDivider()
{
	for (int i = 0; i < tilesDimensions.first; ++i)
	{
		delete[] tiles[i];
	}
	delete[] tiles;
}


void TileDivider::DivideBySectors(vector<sectorIndex> _sectorIndexes)
{
	vector<pair<int, floatPoint> > sites;
	cout << "Dividing by sectors\n";
	for (int i = 0; i < _sectorIndexes.size(); ++i)
	{
		Sector& sector = this->sectors[_sectorIndexes[i].row][_sectorIndexes[i].col];
		this->CreateSites(sites, sector.id, sector.repr);
	}

	this->RunVoronoi(sites);
}


void TileDivider::CreateSites(vector<pair<int, floatPoint> > &_sites, int _id, floatPoint _position)
{
	_sites.push_back({ _id, _position });
	cout << "Created site " << _id << ", pos " << _position.x << ", " << _position.y << endl;
}


void TileDivider::RunVoronoi(vector<pair<int, floatPoint> > _sites)
{
	// assign tile ids base on simple voronoi with given sites.
	cout << "Running voronoi\n" << this->tilesDimensions.first << ", " << this->tilesDimensions.second << endl;
	for (int y = 0; y < this->tilesDimensions.first; ++y)
	{
		for (int x = 0; x < this->tilesDimensions.second; ++x)
		{
			Tile& tile = this->tiles[y][x];
			tile.ownerDist = 200.0f * 200.0f;
			tile.ownerId = -1;
			for (int i = 0; i < (int)_sites.size(); ++i)
			{
				float dist = tile.DistanceTo(floatPoint{ _sites[i].second.x, _sites[i].second.y });
//				cout << "Comparing to " << _sites[i].first << ", dist: " << dist << endl;
				if (dist < tile.ownerDist)
				{
					tile.ownerDist = dist;
					tile.ownerId = _sites[i].first;
				}
			}
		}
	}

	for (int y = 0; y < this->tilesDimensions.first; ++y)
	{
		for (int x = 0; x < this->tilesDimensions.second; ++x)
		{
			Tile& tile = this->tiles[y][x];
			int myOwnerId = tile.ownerId;
			float myOwnerDist = tile.ownerDist;
			if (myOwnerId == -1)
			{
				continue;
			}
			vector<pair<int, int> > neighbors = tile.GetNeighbors(Constants::tilesHoriz, Constants::tilesVerti);
			for (pair<int, int> neighbor : neighbors)
			{
				int hisOwnerId = this->tiles[neighbor.second][neighbor.first].ownerId;
				float hisOwnerDist = this->tiles[neighbor.second][neighbor.first].ownerDist;
				if (hisOwnerId != -1 && hisOwnerId != myOwnerId)
				{
					if (myOwnerDist > hisOwnerDist || myOwnerDist == hisOwnerDist && myOwnerId < hisOwnerId)
					{
						tile.ResetValues();
						break;
					}
				}
			}
		}
	}
}
