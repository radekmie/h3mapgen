
#pragma once

#ifndef __MGR_Tile_h__
#define __MGR_Tile_h__


#include "Common.h"


class Tile
{
public:
	int		closestSiteIndex;
	float	closestDist;
	int		sectorId;

protected:
	int	x;
	int	y;

	floatPoint	repr;

public:
	Tile();
	
	void SetValues(int _x, int _y, float _reprX, float _reprY);
	void ResetClosest();

	float DistanceTo(floatPoint point);
	vector<pair<int, int> > GetNeighbors(int tilesW, int tilesH);

};


#endif /* __MGR_Tile_h__ */
