
#pragma once

#ifndef __MGR_ExactSectorLoader_h__
#define __MGR_ExactSectorLoader_h__


#include "SectorLoader.h"


class ExactSectorLoader : public SectorLoader
{
public:
	ExactSectorLoader();

	Sector& HandleNewSector(int _id, int _weight, int _col, int _row, floatPoint _position);

};


#endif /* __MGR_ExactSectorLoader_h__ */
