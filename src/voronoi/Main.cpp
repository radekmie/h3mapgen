
#include <stdio.h>
#include <time.h>

#include "Common.h"
#include "Site.h"
#include "Tile.h"
#include "TileGrid.h"
#include "TileGridGenerator.h"


int main(int argc, char** argv)
{
	srand((unsigned int)time(NULL));

	TileGridGenerator tileGridGenerator({ Constants::GetTilesVerti(), Constants::GetTilesHoriz() },
		{ Constants::GetSectorRows(), Constants::GetSectorCols() });

	tileGridGenerator.GenerateSites();
	
	tileGridGenerator.AssignSectorIdByDistance();

	tileGridGenerator.DivideBySector();

	tileGridGenerator.ShowTiles();

	int x;
	std::cin >> x;
	return 0;
}

/*
	for (int x = 0; x < tilesW; ++x)
	{
		for (int y = 0; y < tilesH; ++y)
		{
			int mySiteId = tiles[x][y].closestSiteId;
			if (mySiteId == -1)
			{
				continue;
			}
			int mySize = sites[mySiteId].second;
			if (x > 0)
			{
				int hisSiteId = tiles[x - 1][y].closestSiteId;
				if (hisSiteId != -1
					&& hisSiteId != mySiteId
					&& mySize > sites[hisSiteId].second)
				{
					tiles[x][y].closestSiteId = -1;
					continue;
				}
			}
			if (x < tilesW - 10)
			{
				int hisSiteId = tiles[x + 1][y].closestSiteId;
				if (hisSiteId != -1
					&& hisSiteId != mySiteId
					&& mySize > sites[hisSiteId].second)
				{
					tiles[x][y].closestSiteId = -1;
					continue;
				}
			}
			if (y > 0)
			{
				int hisSiteId = tiles[x][y - 1].closestSiteId;
				if (hisSiteId != -1
					&& hisSiteId != mySiteId
					&& mySize > sites[hisSiteId].second)
				{
					tiles[x][y].closestSiteId = -1;
					continue;
				}
			}
			if (y < tilesH - 1)
			{
				int hisSiteId = tiles[x][y + 1].closestSiteId;
				if (hisSiteId != -1
					&& hisSiteId != mySiteId
					&& mySize > sites[hisSiteId].second)
				{
					tiles[x][y].closestSiteId = -1;
					continue;
				}
			}
		}
	}
*/