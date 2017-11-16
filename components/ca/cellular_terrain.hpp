#ifndef CELLULAR_TERRAIN_H
#define CELLULAR_TERRAIN_H

#include "board.hpp"

// Some consts:
const unsigned int neighbourhood_radius = 2;
const unsigned int neighbourhood_size = 2*neighbourhood_radius + 1;

// Structure encapsulating all the parameters of terrain generation process
struct TerrainParams {
        // neighbourhood contains weights for cells' neighbourhood
        // initially board is filled randomly according to the probability given
	// threshold defines the minimum value for the weighted sum (over the nighbourhood)
        // for a cell to survive or be born (can be picked automatically by autoset_threshold function)
        int neighbourhood[neighbourhood_size][neighbourhood_size];
        float probability; //of black cell
	int threshold;
};


// Facade for convinient use with typical sets of parameters.
// For the threshold to be picked automatically, just set it to 0.
TerrainParams moore_neighbourhood(float probability, int self_weight=1, int threshold=0);
TerrainParams neumann_neighbourhood(float probability, int self_weight=1, int threshold=0);
void terrain(const Board& board, Board& result, const TerrainParams& parameters, unsigned int iterations);

// Example usage:
// terrain(my_map, terrain_map, moore_neighbourhood(0.5), 2);
// terrain(my_map, terrain_map, neumann_neighbourhood(0.4, 3), 4);
// terrain(my_map, terrain_map, moore_neighbourhood(0.4, 1, 5), 3);


// Real stuff:
void generation(const Board& board, Board& result, const TerrainParams& parameters, unsigned int iterations=1);
void random_fill(const Board& board, Board& result, const TerrainParams& parameters);
// more_white flag is kind of heuristical; try both values on your own to find out what works best for your purposes
void autoset_threshold(TerrainParams& params, const Board& randomfilled_board, bool more_white=true);

#endif
