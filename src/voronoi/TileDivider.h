
#pragma once

#ifndef __MGR_TileDivider_h__
#define __MGR_TileDivider_h__


#include "Common.h"
#include "Sector.h"
#include "Tile.h"


class TileDivider
{
protected:
	Sector**		sectors;
	pair<int, int>	sectorsDimensions;
	Tile**			tiles;
	pair<int, int>	tilesDimensions;

public:
	TileDivider(Sector** _sectors, pair<int, int> _sectorsDimensions);
	~TileDivider();

	Tile** GetTiles();
	pair<int, int> GetTilesDimensions();

	void DivideBySectors(vector<sectorIndex> _sectorIndexes);

protected:
	virtual void CreateSites(vector<pair<int, floatPoint> > &_sites, Sector& _sector);

private:
	void RunVoronoi(vector<pair<int, floatPoint> > _sites);

	TileDivider& operator=(const TileDivider&) = delete;
	TileDivider(const TileDivider&);
};


inline Tile** TileDivider::GetTiles()
{
	return this->tiles;
}


inline pair<int, int> TileDivider::GetTilesDimensions()
{
	return this->tilesDimensions;
}


#endif /* __MGR_TileDivider_h__ */
