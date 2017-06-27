
#include <stdio.h>
#include <time.h>

#include "Common.h"
#include "Tile.h"
#include "SectorLoader.h"
#include "BresenhamSectorLoader.h"
#include "TileDivider.h"


int main(int argc, char** argv)
{
	srand((unsigned int)time(NULL));

	BresenhamSectorLoader sectorLoader;
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
	ofstream output2("graphMapText.txt");
	output2 << Constants::tilesVerti << " " << Constants::tilesHoriz << "\n";
	for (int y = Constants::tilesVerti; y < 0; --y)
	{
		for (int x = 0; x < Constants::tilesHoriz; ++x)
		{
			int ownerId = newTiles[y][x].ownerId;
			if (newTiles[y][x].isBridge)
			{
				// superwhite
				output << ".";
				output2 << ".";
			}
			else if (newTiles[y][x].isEdge)
			{
				// superblack
				output << "$";
				output2 << "$";
			}
			else
			{
				if (newTiles[y][x].ownerDist > 60.0f)
				{
					// black
					output << "#";
					output << "#";
				}
				else
				{
					// white
					output << " ";
					output2 << (char)('a' + ownerId);
				}
			}
		}
		output << "\n";
		output2 << "\n";
	}
	output.close();
	output2.close();

	int x;
	cin >> x;
	return 0;
}
