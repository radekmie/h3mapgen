
#pragma once

#ifndef __MGR_Constants_h__
#define __MGR_Constants_h__


#include <string>
#include "Common.h"


class Constants
{
public:
	static int	tilesHoriz;
	static int	tilesVerti;
	static int	sectorRows;
	static int	sectorCols;

    static void LoadCustomValues(char** argv);
	static void LoadCustomValues(std::string configFile);

};


#endif /* __MGR_Constants_h__ */
