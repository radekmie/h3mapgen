
#pragma once

#ifndef __MGR_Sector_h__
#define __MGR_Sector_h__


#include "Common.h"


class Sector
{
public:
	int			id;
	int			weight;
	floatPoint	topLeft;
	floatPoint	bottomRight;
	floatPoint	repr;

protected:
	vector<sectorIndex>	connected;

public:
	Sector(floatPoint _topLeft = { 0.0f, 0.0f }, floatPoint _bottomRight = { 0.0f, 0.0f }, int _id = -1, int _weight = 1);

	bool Contains(floatPoint _point);
	void AddConnection(sectorIndex _sectorIndex);

};


#endif /* __MGR_Sector_h__ */
