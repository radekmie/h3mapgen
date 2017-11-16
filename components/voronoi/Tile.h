
#pragma once

#ifndef __MGR_Tile_h__
#define __MGR_Tile_h__


#include "Common.h"


class Tile
{
public:
	int		ownerId;
	float	ownerDist;
	bool	isEdge;
	bool	isBridge;

protected:
	floatPoint	repr;

public:
	Tile();
	
	void SetPosition(int _x, int _y);
	void ResetValues();

	float DistanceTo(floatPoint point);
	vector<pair<int, int> > GetNeighbors(int tilesW, int tilesH);

};


#endif /* __MGR_Tile_h__ */
