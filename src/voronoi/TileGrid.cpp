
#include "TileGrid.h"


TileGrid::TileGrid(pair<int, int> _tilesDim, pair<int, int> _sectorsDim)
{
	this->tilesDim = _tilesDim;
	this->sectorsDim = _sectorsDim;

	this->tiles = new Tile*[tilesDim.first];
	for (int y = 0; y < tilesDim.first; ++y)
	{
		this->tiles[y] = new Tile[tilesDim.second];
	}
	this->PopulateTiles();

	this->sectors = new Sector*[sectorsDim.first];
	for (int y = 0; y < sectorsDim.first; ++y)
	{
		this->sectors[y] = new Sector[sectorsDim.second];
	}
	this->PopulateSectors();
}


TileGrid::~TileGrid()
{
	for (int y = 0; y < tilesDim.first; ++y)
	{
		delete[] tiles[y];
	}
	delete[] tiles;

	for (int y = 0; y < sectorsDim.first; ++y)
	{
		delete[] sectors[y];
	}
	delete[] sectors;
}


void TileGrid::PopulateTiles()
{
	for (int y = 0; y < tilesDim.first; ++y)
	{
		for (int x = 0; x < tilesDim.second; ++x)
		{
			tiles[y][x].SetValues(x, y, 0.5f, 0.5f);
		}
	}
}


void TileGrid::PopulateSectors()
{
	float dH = (float)tilesDim.first / (float)sectorsDim.first;
	float dW = (float)tilesDim.second / (float)sectorsDim.second;
	float y = dH / 2.0f;
	for (int row = 0; row < sectorsDim.first; ++row)
	{
		float x = dW / 2.0f;
		for (int col = 0; col < sectorsDim.second; ++col)
		{
			sectors[row][col].topLeft = floatPoint{ x - dW / 2.0f, y - dH / 2.0f };
			sectors[row][col].bottomRight = floatPoint{ x + dW / 2.0f, y + dH / 2.0f };
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
/*
8,	4,	4,	4,	5,
8,	8,	4,	4,	0,
8,	8,	4,	0,	0,
2,	8,	0,	0,	0,
2,	8,	0,	1,	1
*/
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
//			int id = 2;
//			if (row == 0 || col == 0 || row == SECTOR_ROWS - 1 || col == SECTOR_COLS - 1)
//			{
//				id = -1;
//			} else if (row + col < 5)
//			{
//				id = 0;
//			} else if (col - row >= 1 || row + col >= 8)
//			{
//				id = 1;
//			}
//
//			sectors[row][col].id = id;
}


int TileGrid::GetSectorIdAt(floatPoint point)
{
	float dH = (float)tilesDim.first / (float)sectorsDim.first;
	float dW = (float)tilesDim.second / (float)sectorsDim.second;
	int candidateY = (int)(point.y / dH) - 1;
	int candidateX = (int)(point.x / dW) - 1;
	for (int canDY = 0; canDY < 3; ++canDY)
	{
		for (int canDX = 0; canDX < 3; ++canDX)
		{
			int row = candidateY + canDY;
			int col = candidateX + canDX;
			if (row >= 0 && row < sectorsDim.first
				&& col >= 0 && col < sectorsDim.second
				&& sectors[row][col].Contains(point))
			{
				return sectors[row][col].id;
			}
		}
	}
	return -1;
}
