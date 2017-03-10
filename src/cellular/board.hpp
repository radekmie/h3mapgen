#ifndef BOARD_H
#define BOARD_H

#include<vector>
#include<cassert>
using namespace std;

// Representation of single cell's state
enum Cell {
        // swhite and sblack cells are not going to change their cell
        white = ' ',
        black = '#',
        swhite = '.',
        sblack = '$'
};

// Board is a 2-d array of cells
typedef vector<vector<Cell> > Board;

// Functions for I/O
void print_board(const Board& board);
void load_board(Board& board);

// Statistical measures
float black_rate(const Board& board);

// Auxiliary conversions etc:
inline int cell2int(Cell s) {
        return (s == black || s == sblack);
}
inline char cell2char(Cell s) {
        return char(s);
}
inline Cell char2cell(char c) {
        Cell values[4] { white, black, swhite, sblack };
        for(int i = 0 ; i < 4 ; i++)
                if(c == char(values[i]))
                        return values[i];
        assert(false);
        return white;
}

inline void board_set_size(Board& board, int rows, int cols) {
        board.clear();
        board.resize(rows, vector<Cell>(cols));
}

#endif
