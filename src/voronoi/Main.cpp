
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

	Tile **newTiles;
	int tH = Constants::GetTilesVerti(), tW = Constants::GetTilesHoriz();

	newTiles = new Tile*[tH];
	for (int y = 0; y < tH; ++y)
	{
		newTiles[y] = new Tile[tW];
	}
	for (int y = 0; y < tH; ++y)
	{
		for (int x = 0; x < tW; ++x)
		{
			newTiles[y][x].SetValues(x, y, 0.5f, 0.5f);
		}
	}

	vector<Site> newSites;
	int sites;
	ifstream input("sitesInput.txt");
	input >> sites;
	for (int sIndex = 0; sIndex < sites; sIndex++)
	{
		int sId;
		float sX, sY;
		input >> sId >> sX >> sY;
		newSites.push_back({ floatPoint((sX / 2.5f + 1.0f) * (float)tW / 2.0f, (sY / 2.5f + 1.0f) * (float)tH / 2.0f), sId });
	}
	input.close();

	newTiles = TileGridGenerator::AssignSectorIdByDistance(newTiles, newSites);

	newTiles = TileGridGenerator::DivideBySector(newTiles, newSites);

	ofstream output("graphMap.txt");
	output << Constants::GetTilesVerti() << " " << Constants::GetTilesHoriz() << "\n";
	for (int y = 0; y < Constants::GetTilesVerti(); ++y)
	{
		for (int x = 0; x < Constants::GetTilesHoriz(); ++x)
		{
			int sectorId = newTiles[x][y].sectorId;
			if (sectorId == -1)
			{
				output << "$";
			}
			else
			{
				if (newTiles[x][y].closestDist > 13 && newTiles[x][y].sectorId != -1)
				{
					output << "#";
				}
				else
				{
					output << " ";// sectorId;
				}
			}
		}
		output << "\n";
	}
	output.close();

	/*
	TileGridGenerator tileGridGenerator({ Constants::GetTilesVerti(), Constants::GetTilesHoriz() },
	{ Constants::GetSectorRows(), Constants::GetSectorCols() });

	tileGridGenerator.GenerateSites();

	tileGridGenerator.AssignSectorIdByDistance(tileGridGenerator.GetTiles(), tileGridGenerator.GetSites());

	tileGridGenerator.DivideBySector(tileGridGenerator.GetTiles(), tileGridGenerator.GetSites());

	tileGridGenerator.ShowTiles();
*/

	for (int y = 0; y < tH; ++y)
	{
		delete[] newTiles[y];
	}
	delete[] newTiles;

	int x;
	std::cin >> x;
	return 0;
}
