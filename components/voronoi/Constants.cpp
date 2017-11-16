
#include "Constants.h"

#define TILES_HORIZ 90
#define TILES_VERTI 90
#define SECTOR_ROWS 10
#define SECTOR_COLS 10


int Constants::tilesHoriz = TILES_HORIZ;
int Constants::tilesVerti = TILES_VERTI;
int Constants::sectorRows = SECTOR_ROWS;
int Constants::sectorCols = SECTOR_COLS;


void Constants::LoadCustomValues(char** argv)
{
    Constants::tilesVerti = atoi(argv[3]);
    Constants::tilesHoriz = atoi(argv[4]);
    Constants::sectorRows = atoi(argv[5]);
    Constants::sectorCols = atoi(argv[6]);
}

void Constants::LoadCustomValues(std::string configFile)
{
    ifstream input(configFile);
    input >> Constants::tilesVerti >> Constants::tilesHoriz >> Constants::sectorRows >> Constants::sectorCols;
    input.close();
}
