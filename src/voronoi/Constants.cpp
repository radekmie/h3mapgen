
#include "Constants.h"

#define TILES_HORIZ 90
#define TILES_VERTI 90
#define SECTOR_ROWS 10
#define SECTOR_COLS 10


int Constants::tilesHoriz = TILES_HORIZ;
int Constants::tilesVerti = TILES_VERTI;
int Constants::sectorRows = SECTOR_ROWS;
int Constants::sectorCols = SECTOR_COLS;


void Constants::LoadCustomValues()
{
	// for now it does nothing, but will be used to read new constants from config file.
}
