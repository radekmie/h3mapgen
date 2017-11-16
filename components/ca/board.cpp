#include <iostream>
#include <vector>
#include <string>
#include "board.hpp"
using namespace std;


void print_board(const Board& board) {
        int rows = board.size();
        int cols = board[0].size();
        cout << rows << ' ' << cols << '\n';
        for(int i=0 ; i < rows ; i++) {
                for(int j=0 ; j < cols ; j++)
                        cout << cell2char(board[i][j]);
                cout << '\n';
        }
}

void load_board(Board& board) {
        int rows, cols;
        string line;
        cin >> rows >> cols;
        getline(cin,line);
        board_set_size(board,rows,cols);
        for(int i=0 ; i < rows ; i++) {
                getline(cin, line);
                for(int j=0 ; j < cols ; j++)
                        board[i][j] = char2cell(line[j]);
        }
}

// count cells of specyfic colour
unsigned int count_cells(const Board& board, Cell colour) {
	int rows = board.size();
        int cols = board[0].size();
       
	int count=0;

	for(int i=0 ; i < rows ; i++)
                for(int j=0 ; j < cols ; j++)
  			if(board[i][j] == colour)
				count++;

	return count;
}

float black_rate(const Board& board) {
	int nblack = count_cells(board, black);
	int nwhite = count_cells(board, white);
	int sum = nblack+nwhite;

	return (float)nblack/(float)sum;
}
