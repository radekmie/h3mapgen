
#pragma once

#ifndef __MGR_TileGrid_h__
#define __MGR_TileGrid_h__


#include "Common.h"
#include "Tile.h"
#include "Sector.h"


class TileGrid
{
private:
	pair<int, int>	tilesDim;
	Tile	**tiles;
	pair<int, int>	sectorsDim;
	Sector	**sectors;

public:
	TileGrid(pair<int, int> _tilesDim, pair<int, int> _sectorsDim);
	~TileGrid();

	Tile& GetTileAt(int x, int y);
	Sector& GetSectorAt(int col, int row);
	int GetSectorIdAt(floatPoint point);

private:
	void PopulateTiles();
	void PopulateSectors();
	
};


inline Tile& TileGrid::GetTileAt(int x, int y)
{
	return this->tiles[y][x];
}


inline Sector& TileGrid::GetSectorAt(int col, int row)
{
	return this->sectors[row][col];
}


#endif /* __MGR_TileGrid_h__ */
