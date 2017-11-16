#include <iostream>
#include "cellular_terrain.hpp"
using namespace std;

int main(int argc, char** argv) {
        if(argc < 4) {
                cerr << "Usage: " << argv[0] << " probability self_weight iterations\n";
                return 0;
        }

	float p = atof(argv[1]);
	int s = atoi(argv[2]);
	int i = atoi(argv[3]);

	Board board, board2;
	load_board(board);

	// threshold will be picked automatically
	terrain(board, board2, moore_neighbourhood(p, s), i);
	print_board(board2);

	return 0;
}
