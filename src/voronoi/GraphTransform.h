
#pragma once

#ifndef __MGR_GraphTransform_h__
#define __MGR_GraphTransform_h__


#include "Common.h"
#include "Tile.h"
#include "Site.h"


class GraphTransform
{
protected:
	Tile			**tiles;
	pair<int, int>	tilesDim;
	pair<int, int>	sectorsDim;

public:
	GraphTransform(pair<int, int> _tilesDim, pair<int, int> _sectorsDim);
	~GraphTransform();
	void DivideTilesByPoints(vector<Site>& _sites);

};


#endif /* __MGR_GraphTransform_h__ */
