/*
#include "TileGridGenerator.h"


void TileGridGenerator::ShowTiles()
{
	ofstream out("mapa.txt");
	out << Constants::GetTilesVerti() << " " << Constants::GetTilesHoriz() << "\n";
	for (int y = 0; y < Constants::GetTilesVerti(); ++y)
	{
		for (int x = 0; x < Constants::GetTilesHoriz(); ++x)
		{
			int sectorId = tileGrid.GetTileAt(x, y).sectorId;
			if (sectorId == -1)
			{
				out << ".";
			}
			else
			{
				out << sectorId;
			}
		}
		out << "\n";
	}
	out.close();
}


Tile** TileGridGenerator::AssignSectorIdByDistance(Tile **_tiles, vector<Site> _sites)
{
	for (int y = 0; y < Constants::GetTilesVerti(); ++y)
	{
		for (int x = 0; x < Constants::GetTilesHoriz(); ++x)
		{
			float minDist = 120.0f * 120.0f;
			int closestSiteIndex = -1;
			Tile& tile = _tiles[y][x];
			for (int i = 0; i < (int)_sites.size(); ++i)
			{
				float dist = tile.DistanceTo(floatPoint{ _sites[i].point.x, _sites[i].point.y });
				if (dist < minDist)
				{
					minDist = dist;
					closestSiteIndex = i;
				}
			}
			_sites[closestSiteIndex].size++;
			tile.closestSiteIndex = closestSiteIndex;
			tile.sectorId = _sites[closestSiteIndex].id;
			tile.closestDist = minDist;
		}
	}
	return _tiles;
}


Tile** TileGridGenerator::DivideBySector(Tile **_tiles, vector<Site> _sites)
{
	for (int y = 0; y < Constants::GetTilesVerti(); ++y)
	{
		for (int x = 0; x < Constants::GetTilesHoriz(); ++x)
		{
			Tile& myTile = _tiles[y][x];
			int mySiteIndex = myTile.closestSiteIndex;
			int mySectorId = myTile.sectorId;
			if (mySiteIndex == -1 || mySectorId == -1)
			{
				continue;
			}
			int mySize = _sites[mySiteIndex].size;
			vector<pair<int, int> > neighbors = myTile.GetNeighbors(Constants::GetTilesHoriz(), Constants::GetTilesVerti());
			for (pair<int, int> neighbor : neighbors)
			{
				int hisSiteIndex = _tiles[neighbor.second][neighbor.first].closestSiteIndex;
				int hisSectorId = _tiles[neighbor.second][neighbor.first].sectorId;
				if (hisSectorId != -1
					&& hisSectorId != mySectorId)
				{
					if (mySize > _sites[hisSiteIndex].size || mySize == _sites[hisSiteIndex].size && mySectorId < hisSectorId)
					{
						myTile.ResetClosest();
						break;
					}
				}
			}
		}
	}
	return _tiles;
}


void TileGridGenerator::GenerateRandomSites(int pointsNum, int width, int height)
{
	for (int i = 0; i < pointsNum; ++i)
	{
		float maxDist = 0.0f;
		float nextX = 0.0f;
		float nextY = 0.0f;
		for (int j = 0; j < 5; ++j)
		{
			float x = (rand() % width + (rand() % 100) / 100.0f);
			float y = (rand() % height + (rand() % 100) / 100.0f);
			float closestDist = 120.0f * 120.0f;
			for (int k = 0; k < (int)(this->sites.size()); ++k)
			{
				float dX = this->sites[k].point.x - x;
				float dY = this->sites[k].point.y - y;
				float dist = dX * dX + dY * dY;
				if (dist < closestDist)
				{
					closestDist = dist;
				}
			}
			if (closestDist > maxDist)
			{
				maxDist = closestDist;
				nextX = x;
				nextY = y;
			}
		}
		this->sites.push_back({ floatPoint{ nextX, nextY } });
	}
}


void TileGridGenerator::GenerateGridSites(int pointsW, int pointsH, int width, int height)
{
	float dW = (float)width / (float)pointsW;
	float dH = (float)height / (float)pointsH;
	int id = 0;

	for (float x = dW / 2.0f; x < (float)width; x += dW)
	{
		for (float y = dH / 2.0f; y < (float)height; y += dH)
		{
			float rangeW = dW * 0.8f;
			float rangeH = dH * 0.8f;
			for (int i = 0; i < 3; ++i)
			{
				float dX = (rand() % 7001) / 7001.0f * rangeW - rangeW / 2;
				float dY = (rand() % 7001) / 7001.0f * rangeH - rangeH / 2;
				this->sites.push_back({ floatPoint{ x + dX, y + dY }, tileGrid.GetSectorIdAt(floatPoint{ x + dX, y + dY }) });
			}
		}
	}
}
*/
