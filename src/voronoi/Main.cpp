
#include <stdio.h>
#include <time.h>

#include "Common.h"
#include "Tile.h"
#include "SectorLoader.h"
#include "BresenhamSectorLoader.h"
#include "TileDivider.h"


int main(int argc, char** argv)
{
	if (argc < 3)
	{
		return -1;
	}

	srand((unsigned int)time(NULL));

	std::string configFile = "";
	if (argc > 3)
	{
		configFile = argv[3];
	}
	else
	{
		configFile = "../output/mapConfig.txt";
	}
	Constants::LoadCustomValues(configFile);

	BresenhamSectorLoader sectorLoader;
	std::string graphInput = argv[1];
	sectorLoader.LoadSectors(graphInput);

	TileDivider voronoiDivider(sectorLoader.GetSectors(), sectorLoader.GetDimensions());
	voronoiDivider.DivideBySectors(sectorLoader.GetSectorIndexes());

	Tile **newTiles = voronoiDivider.GetTiles();


	//newTiles[10][11].ownerId = 2;
	//newTiles[10][11].ownerDist = 15.0f;
	//newTiles[10][10].ownerId = 1;
	//newTiles[10][10].isBridge = true;

	std::string graphOutput = argv[2];
	ofstream output(graphOutput);
	output << Constants::tilesVerti << " " << Constants::tilesHoriz << "\n";

	std::string graphOutputText = graphOutput.substr(0, graphOutput.length() - 4).append("Text.txt");
	ofstream output2(graphOutputText);
	output2 << Constants::tilesVerti << " " << Constants::tilesHoriz << "\n";
	for (int y = Constants::tilesVerti - 1; y >= 0; --y)
	{
		for (int x = 0; x < Constants::tilesHoriz; ++x)
		{
			int ownerId = newTiles[y][x].ownerId;
			if (newTiles[y][x].isBridge) // superwhite
			{
				output << ".";
			}
			else if (newTiles[y][x].isEdge) // superblack
			{
				output << "$";
			}
			else
			{
				if (newTiles[y][x].ownerDist > 60.0f) // black
				{
					output << "#";
				}
				else // white
				{
					output << " ";
				}
			}

			output2 << (char)('a' + ownerId);
		}
		output << "\n";
		output2 << "\n";
	}
	output.close();
	output2.close();

	return 0;
}
