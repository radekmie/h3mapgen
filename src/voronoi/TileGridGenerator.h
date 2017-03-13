
#pragma once

#ifndef __MGR_TileGridGenerator_h__
#define __MGR_TileGridGenerator_h__


#include "TileGrid.h"
#include "Site.h"


class TileGridGenerator
{
private:
	TileGrid	tileGrid;

	vector<Site>	sites;

public:
	TileGridGenerator(pair<int, int> tilesDim, pair<int, int> sectorsDim);

	void GenerateSites();

	void ShowTiles();
	void AssignSectorIdByDistance();
	void DivideBySector();

private:
	void GenerateRandomSites(int pointsNum, int width, int height);
	void GenerateGridSites(int sectorsW, int sectorsH, int width, int height);

};


#endif /* __MGR_TileGridGenerator_h__ */
