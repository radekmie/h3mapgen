
#pragma once

#ifndef __MGR_SectorLoader_h__
#define __MGR_SectorLoader_h__


#include "Common.h"
#include "Sector.h"


class SectorLoader
{
protected:
	const float		totalH;
	const float		totalW;
	const float		diffH;
	const float		diffW;

	Sector**			sectors;
	pair<int, int>		dimensions;
	vector<sectorIndex>	sectorIndexes;

public:
	SectorLoader();
	~SectorLoader();

	Sector** GetSectors();
	pair<int, int> GetDimensions();
	vector<sectorIndex> &GetSectorIndexes();

	void LoadSectors(string _inputFile);

protected:
	virtual Sector& HandleNewSector(int _id, int _weight, int _col, int _row, floatPoint _position);

private:
	SectorLoader& operator=(const SectorLoader&) = delete;
	SectorLoader(const SectorLoader&);
};


inline Sector** SectorLoader::GetSectors()
{
	return this->sectors;
}


inline pair<int, int> SectorLoader::GetDimensions()
{
	return this->dimensions;
}


inline vector<sectorIndex> &SectorLoader::GetSectorIndexes()
{
	return this->sectorIndexes;
}


#endif /* __MGR_SectorLoader_h__ */
