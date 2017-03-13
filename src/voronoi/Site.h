
#pragma once

#ifndef __MGR_Site_h__
#define __MGR_Site_h__


#include "Common.h"


class Site
{
public:
	floatPoint point;
	int size;
	int id;
	
	Site(floatPoint _point, int _id = -1);
};


#endif /* __MGR_Site_h__ */
