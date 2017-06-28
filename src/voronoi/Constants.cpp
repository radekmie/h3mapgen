
#include "Constants.h"

#define TILES_HORIZ 90
#define TILES_VERTI 90
#define SECTOR_ROWS 10
#define SECTOR_COLS 10


int Constants::tilesHoriz = TILES_HORIZ;
int Constants::tilesVerti = TILES_VERTI;
int Constants::sectorRows = SECTOR_ROWS;
int Constants::sectorCols = SECTOR_COLS;


void Constants::LoadCustomValues(std::string configFile)
{
	ifstream input(configFile);
	input >> Constants::tilesVerti >> Constants::tilesHoriz >> Constants::sectorRows >> Constants::sectorCols;
	input.close();
}
