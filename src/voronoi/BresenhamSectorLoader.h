
#pragma once

#ifndef __MGR_BresenhamSectorLoader_h__
#define __MGR_BresenhamSectorLoader_h__


#include "ExactSectorLoader.h"


class BresenhamSectorLoader : public ExactSectorLoader
{
public:
	BresenhamSectorLoader();

protected:
	Sector& HandleNewSector(int _id, int _weight, int _col, int _row, floatPoint _position);

};


#endif /* __MGR_BresenhamSectorLoader_h__ */
