/*
#include "TileGrid.h"




void TileGrid::PopulateSectors()
{
	float dH = (float)tilesDim.first / (float)sectorsDim.first;
	float dW = (float)tilesDim.second / (float)sectorsDim.second;
	float y = 0.0f;
	for (int row = 0; row < sectorsDim.first; ++row)
	{
		float x = 0.0f;
		for (int col = 0; col < sectorsDim.second; ++col)
		{
			sectors[row][col].topLeft = floatPoint{ x, y };
			sectors[row][col].bottomRight = floatPoint{ x + dW, y + dH };
			x += dW;
		}
		y += dH;
	}

	ifstream sectorsInput("sectorsInput.txt");
	int sectorRows, sectorCols;
	sectorsInput >> sectorRows >> sectorCols;
//	{
//		8,	4,	4,	4,	5,	5,	5,	5,
//		8,	8,	4,	4,	0,	0,	0,	5,
//		8,	8,	4,	0,	0,	1,	1,	1,
//		2,	8,	0,	0,	0,	0,	1,	1,
//		2,	8,	0,	1,	1,	1,	1,	1,
//		2,	2,	2,	2,	2,	1,	3,	6,
//		2,	2,	3,	3,	3,	3,	3,	6,
//		7,	7,	7,	7,	7,	6,	6,	6
//	};

//	8,	4,	4,	4,	5,
//	8,	8,	4,	4,	0,
//	8,	8,	4,	0,	0,
//	2,	8,	0,	0,	0,
//	2,	8,	0,	1,	1

	bool wrongSize = false;
	if (sectorRows != sectorsDim.first)
	{
		wrongSize = true;
		cout << "Rows given in input file (" << sectorRows << ") did not match expected value (" << sectorsDim.first << ").\n";
	}
	if (sectorCols != sectorsDim.second)
	{
		wrongSize = true;
		cout << "Columns given in input file (" << sectorCols << ") did not match expected value (" << sectorsDim.second << ").\n";
	}
	for (int row = 0; row < sectorRows; ++row)
	{
		for (int col = 0; col < sectorCols; ++col)
		{
			if (wrongSize)
			{
				sectors[row][col].id = -1;
			}
			else
			{
				sectorsInput >> sectors[row][col].id;
			}
		}
	}
	sectorsInput.close();
}


*/