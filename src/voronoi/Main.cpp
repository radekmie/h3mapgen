
#include <stdio.h>
#include <time.h>

#include "Common.h"
#include "Tile.h"
#include "SectorLoader.h"
#include "ExactSectorLoader.h"
#include "TileDivider.h"


int main(int argc, char** argv)
{
	srand((unsigned int)time(NULL));

	ExactSectorLoader sectorLoader;
	sectorLoader.LoadSectors("graphInput.txt");

	TileDivider voronoiDivider(sectorLoader.GetSectors(), sectorLoader.GetDimensions());
	voronoiDivider.DivideBySectors(sectorLoader.GetSectorIndexes());

	Tile **newTiles = voronoiDivider.GetTiles();


	//newTiles[10][11].ownerId = 2;
	//newTiles[10][11].ownerDist = 15.0f;
	//newTiles[10][10].ownerId = 1;
	//newTiles[10][10].isBridge = true;

	ofstream output("graphMap.txt");
	output << Constants::tilesVerti << " " << Constants::tilesHoriz << "\n";
	for (int y = 0; y < Constants::tilesVerti; ++y)
	{
		for (int x = 0; x < Constants::tilesHoriz; ++x)
		{
			int ownerId = newTiles[x][y].ownerId;
			if (ownerId == -1)
			{
				// superblack
				output << "$";
			}
			else
			{
				if (newTiles[x][y].isBridge)
				{
					// superwhite
					output << ".";
				}
				else if (newTiles[x][y].ownerDist > 60.0f)
				{
					// black
					output << "#";
				}
				else
				{
					// white
					output << ownerId;
				}
			}
		}
		output << "\n";
	}
	output.close();

	int x;
	cin >> x;
	return 0;
}
