
#include "SectorLoader.h"

SectorLoader::SectorLoader()
: totalH((float)Constants::tilesVerti)
, totalW((float)Constants::tilesHoriz)
, diffH((float)Constants::tilesVerti / (float)Constants::sectorRows)
, diffW((float)Constants::tilesHoriz / (float)Constants::sectorCols)
, dimensions(Constants::sectorRows, Constants::sectorCols)
{
	this->sectors = new Sector*[this->dimensions.first];
	float fY = 0.0f;
	for (int y = 0; y < this->dimensions.first; ++y)
	{
		float fX = 0.0f;
		this->sectors[y] = new Sector[this->dimensions.second];
		for (int x = 0; x < this->dimensions.second; ++x)
		{
			this->sectors[y][x].topLeft = floatPoint{ fX, fY };
			this->sectors[y][x].bottomRight = floatPoint{ fX + this->diffW, fY + this->diffH };
			this->sectors[y][x].repr = floatPoint{ fX + this->diffW / 2.0f, fY + this->diffH / 2.0f };
			fX += this->diffW;
		}
		fY += this->diffH;
	}
}


SectorLoader::~SectorLoader()
{
	for (int i = 0; i < this->dimensions.first; ++i)
	{
		delete[] this->sectors[i];
	}
	delete[] this->sectors;
}


void SectorLoader::LoadSectors(string _inputFile)
{
	cout << "Loading as table\n";

	ifstream input(_inputFile);
	int sites;
	input >> sites;
	for (int sIndex = 0; sIndex < sites; sIndex++)
	{
		int sId, sWeight;
		float sX, sY;
		input >> sId >> sX >> sY >> sWeight;
		// normalize the values.
		sX = (sX / 5.0f + 0.5f) * this->totalW;
		sY = (sY / 5.0f + 0.5f) * this->totalH;

		int col = (int)(sX / this->diffW);
		int row = (int)(sY / this->diffH);
		Sector& sector = this->sectors[row][col];
		sector = this->HandleNewSector(sId, sWeight, col, row, { sX, sY });
		// TODO: handle connections as well...
	}
	input.close();
}


Sector& SectorLoader::HandleNewSector(int _id, int _weight, int _col, int _row, floatPoint _position)
{
	Sector& sector = this->sectors[_row][_col];
	sector.id = _id;
	sector.weight = _weight;
	this->sectorIndexes.push_back({ _row, _col });
	return sector;
}
