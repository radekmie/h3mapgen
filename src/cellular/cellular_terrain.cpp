#include <vector>
#include <random>
#include <chrono>
#include "cellular_terrain.hpp"
using namespace std;

// computes one generation of CA according to parameters given
void gen(const Board& board, Board& result, const TerrainParams& parameters) {
	// resulting board will be surrounded by 2-thick sblack boarders in order to get away with edge cases smoothly
	unsigned int rows = board.size();
	unsigned int cols = board[0].size();
	board_set_size(result, rows, cols);
	for(unsigned int i=0 ; i < rows ; i++)
		for(unsigned int j=0 ; j < cols ; j++) {
			// near edge -> sblack boarder
			if(i < neighbourhood_radius || i >= rows - neighbourhood_radius || j < neighbourhood_radius || j >= cols - neighbourhood_radius )
				result[i][j] = sblack;
			// swhite and sblack cells don't change
			else if(board[i][j] == swhite || board[i][j] == sblack) {
				result[i][j] = board[i][j];
			} else {
				int ii = i-neighbourhood_radius;
				int jj = j-neighbourhood_radius;
				int sum = 0;
				for (unsigned int i=0 ; i < neighbourhood_size ; i++)
					for(unsigned int j = 0 ; j < neighbourhood_size ; j++)
						sum += parameters.neighbourhood[i][j] * cell2int(board[ii+i][jj+j]);
				if(sum >= parameters.threshold)
					result[i][j] = black;
				else
					result[i][j] = white;
			}
		}
}

void generation(const Board& board, Board& result, const TerrainParams& parameters, unsigned int iterations) {
	Board tmp_board = board;
	Board* b2 = &tmp_board;
	Board* b1 = &result;

	for(unsigned int i=0 ; i < iterations ; i++) {
		swap(b1,b2);
		gen(*b1, *b2, parameters);
	}

	if(b2 != &result)
		result = *b2;
}

// fills the board randomly according to the probability (with respect to swhite and sblack cells)
void random_fill(const Board& board, Board& result, const TerrainParams& parameters) {
        unsigned int rows = board.size();
        unsigned int cols = board[0].size();
        board_set_size(result, rows, cols);
        
	auto seed = chrono::system_clock::now().time_since_epoch().count();
	default_random_engine gen(seed);
        bernoulli_distribution dist(parameters.probability);

	for(unsigned int i=0 ; i < rows ; i++)
                for(unsigned int j=0 ; j < cols ; j++)
			if(board[i][j] == sblack || board[i][j] == swhite)
				result[i][j] = board[i][j];
			else if(dist(gen))
				result[i][j] = black;
			else
				result[i][j] = white;
}

TerrainParams moore_neighbourhood(float probability, int self_weight, int threshold) {
        TerrainParams res;
        res.probability = probability;
        res.threshold = threshold;

        // Moore's neighbourhood:
        // 1 1 1
        // 1 s 1
        // 1 1 1
        for(unsigned int i=0 ; i < neighbourhood_size ; i++)
                for(unsigned int j=0 ; j < neighbourhood_size ; j++)
                        if(i == neighbourhood_radius && j == neighbourhood_radius)
                                res.neighbourhood[i][j] = self_weight;
                        else if(abs((int)i-(int)neighbourhood_radius) < 2 && abs((int)j-(int)neighbourhood_radius) < 2)
                                res.neighbourhood[i][j] = 1;
                        else
                                res.neighbourhood[i][j] = 0;
	return res;
}

TerrainParams neumann_neighbourhood(float probability, int self_weight, int threshold) {
        TerrainParams res;
        res.probability = probability;
        res.threshold = threshold;

        // von Neumann's neighbourhood:
        // 0 1 0
        // 1 s 1
        // 0 1 0
        for(unsigned int i=0 ; i < neighbourhood_size ; i++)
                for(unsigned int j=0 ; j < neighbourhood_size ; j++)
                        if(i == neighbourhood_radius && j == neighbourhood_radius)
                                res.neighbourhood[i][j] = self_weight;
                        else if(abs((int)i-(int)neighbourhood_radius) + abs((int)j-(int)neighbourhood_radius) < 2)
                                res.neighbourhood[i][j] = 1;
                        else
                                res.neighbourhood[i][j] = 0;
	return res;
}

// threshold == 0 -> pick automatically
void terrain(const Board& board, Board& result, const TerrainParams& parameters, unsigned int iterations) {
	TerrainParams params = parameters;
	Board tmp_board;
	random_fill(board, tmp_board, params);
	if(params.threshold == 0)
		autoset_threshold(params, tmp_board);
	generation(tmp_board, result, params, iterations);	
}

const unsigned int auto_thresholding_limit = 1024;
const unsigned int auto_thresholding_iterations = 2;
const float auto_thresholding_rate = 0.5;

// Function test various thresholds.
// For each value, the black/white rate is computed after auto_thresholding_iterations.
// One that gives the rate closest to auto_thresholding_rate is to be picked as the best one.
void autoset_threshold(TerrainParams& params, const Board& randomfilled_board, bool more_white) {
	Board result;

	for(unsigned int i=0 ; i < auto_thresholding_limit ; i++) {
		params.threshold = i;
		generation(randomfilled_board, result, params, auto_thresholding_iterations);

		if(black_rate(result) < auto_thresholding_rate)
			break;
	}

	if(!more_white)
		params.threshold--;
}
