
#include "BresenhamSectorLoader.h"


BresenhamSectorLoader::BresenhamSectorLoader()
: ExactSectorLoader()
{

}


Sector& BresenhamSectorLoader::HandleNewSector(int _id, int _weight, int _col, int _row, floatPoint _position)
{
	Sector& sector = this->sectors[_row][_col];
	if (sector.id == _id)
	{
		sector.weight += _weight;
	}
	else
	{
		sector.id = _id;
		sector.weight = _weight;
		this->sectorIndexes.push_back({ _row, _col });
	}
	return sector;
}
