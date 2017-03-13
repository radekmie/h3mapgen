
#include "Constants.h"

#define POINTS_NUM 30
#define TILES_HORIZ 90
#define TILES_VERTI 90
#define SECTOR_ROWS 8
#define SECTOR_COLS 8
#define USE_GRID


int Constants::GetPointsNum()
{
	return POINTS_NUM;
}


int Constants::GetTilesHoriz()
{
	return TILES_HORIZ;
}


int Constants::GetTilesVerti()
{
	return TILES_VERTI;
}


int Constants::GetSectorRows()
{
	return SECTOR_ROWS;
}


int Constants::GetSectorCols()
{
	return SECTOR_COLS;
}


bool Constants::GetUseGrid()
{
#ifdef USE_GRID
	return true;
#else
	return false;
#endif
}
