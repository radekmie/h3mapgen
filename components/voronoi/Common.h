
#pragma once

#ifndef __MGR_Common_h__
#define __MGR_Common_h__


#include "Constants.h"
#include <iostream>
#include <vector>
#include <math.h>
#include <fstream>


using namespace std;


struct floatPoint
{
	float x;
	float y;
	floatPoint(float _x, float _y)
	: x(_x), y(_y) {}
};


struct sectorIndex
{
	int row;
	int col;
	sectorIndex(int _row, int _col)
	: row(_row), col(_col) {}
};


#endif /* __MGR_Common_h__ */
