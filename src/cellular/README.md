# h3mapgen-cellular-terrain
Part of the Heroes 3 Map Generator. Module builds terrain shape using cellular automata.




### Data representation description:

The game map (board) is represented as a 2-d vector of cells. Namely: ` typedef vector<vector<Cell> > Board; `

A single cell can be in one of 4 states: white, black, swhite or sblack:
```
enum Cell {
        white,	black,
        swhite,	sblack
};
```








### How to use the generator?

First of all, you need to include the header: `#include "cellular_terrain.hpp"`.

Then take a look on facade function `terrain(...)` as well as specialized neighbourhood functions:
```
void terrain(const Board& board, Board& result, const TerrainParams& parameters, unsigned int iterations);
```
- `board` is an input; meant to contain some swhite and sblack cells
- `result` will hold the resulting terrain map
- `parameters` structure may be easly obtained from functions such as `moore_neighbourhood(...)` etc.
- `iterations` just specifies the number of succesive CA generations




```
TerrainParams *_neighbourhood(float probability, int self_weight=1, int threshold=0);
```
- `probability` is a probability of a black cell on the initial board before running CA
- `threshold` defines the minimum value for the weighted sum (over the nighbourhood) for a cell to survive or be born; leaving it to 0 will cause the generator function to pick the best value automatically (recommended)
- `self_weight` specifies the degree of contribution of the current cell's state to the wighted sum




Example usage:
```
terrain(my_map, terrain_map, moore_neighbourhood(0.5), 2);
terrain(my_map, terrain_map, neumann_neighbourhood(0.4, 3), 4);
terrain(my_map, terrain_map, moore_neighbourhood(0.4, 1, 5), 3);
```



### Which files exactly do you need?

Just four of them:
- `board.hpp` and `board.cpp` for general board representation related stuff
- `cellular_terrain.hpp` and `cellular_terrain.cpp` for CA mechanics

