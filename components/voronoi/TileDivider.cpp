
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
	for (const auto &index : _sectorIndexes)
	{
		Sector& sector = this->sectors[index.row][index.col];
		this->CreateSites(sites, sector);
	}

	this->RunVoronoi(sites);
}


void TileDivider::CreateSites(vector<pair<int, floatPoint> > &_sites, Sector& _sector)
{
//	_sites.push_back({ _sector.id, _sector.repr });
	for (int i = 0; i < 3; ++i)
	{
		float dX = _sector.bottomRight.x - _sector.topLeft.x;
		float dY = _sector.bottomRight.y - _sector.topLeft.y;
		int randX = rand() % 71;
		int randY = rand() % 71;
		float posX = _sector.topLeft.x + dX / 2.0f + ((float)randX / 71.0f - 0.5f) * dX * 0.7f;
		float posY = _sector.topLeft.y + dY / 2.0f + ((float)randY / 71.0f - 0.5f) * dY * 0.7f;
		_sites.push_back({ _sector.id, {posX, posY} });
	}

//	_sites.push_back({ _id, _position });
//	cout << "Created sites for id " << _id << ", pos " << _position.x << ", " << _position.y << endl;
}


void TileDivider::RunVoronoi(vector<pair<int, floatPoint> > _sites)
{
	// assign tile ids base on simple voronoi with given sites.
	cout << "Running voronoi\n";
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
			if (myOwnerId == -1 || tile.isBridge || tile.isEdge)
			{
				continue;
			}
			vector<pair<int, int> > neighbors = tile.GetNeighbors(Constants::tilesHoriz, Constants::tilesVerti);
			for (pair<int, int> neighbor : neighbors)
			{
				Tile& hisTile = this->tiles[neighbor.second][neighbor.first];
				int hisOwnerId = hisTile.ownerId;
				float hisOwnerDist = hisTile.ownerDist;
				if (hisOwnerId != -1 && !hisTile.isBridge && !hisTile.isEdge && hisOwnerId != myOwnerId)
				{
					if (myOwnerDist > hisOwnerDist || (myOwnerDist == hisOwnerDist && myOwnerId < hisOwnerId))
					{
//						tile.ResetValues();
						tile.isEdge = true;
						break;
					}
				}
			}
		}
	}
}
