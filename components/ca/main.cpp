#include "cellular_terrain.hpp"

int main(int argc, char** argv) {
  if (argc < 4) {
    std::cerr << "Usage: " << argv[0] << " probability self_weight iterations\n";
    return 0;
  }

  float p = atof(argv[1]);
  int s = atoi(argv[2]);
  int i = atoi(argv[3]);

  Board board, board2;
  load_board(board);

  // threshold will be picked automatically
  terrain(board, board2, moore_neighbourhood(p, s), i, 0);
  print_board(board2);

  return 0;
}

/// Glue between CA and Lua.
// @module ca

/// Runs cellular automata on a board.
// @function    run
// @tparam      table       board           Board. A 2D table of 0 (white, ' '), 1 (black, '#'), 2 (super white, '.') and 3 (super black, '$'). See board.hpp.
// @tparam      integer     neighbourhood   Neighbourhood: either 'moore' or 'neumann'.
// @tparam      float       probability     Probability.
// @tparam      float       weight          Weight.
// @tparam      integer     iterations      Iterations.
// @tparam      integer     seed            Seed.
// @treturn     table                       Board (copied!) after CA.
static int run(lua_State* L) {
  Board board;

  // Resize.
  lua_geti(L, 1, 1);
  lua_len(L, -1);
  lua_len(L, 1);
  int size_x = lua_tointeger(L, -2);
  int size_y = lua_tointeger(L, -1);
  lua_pop(L, 3);

  board.resize(size_y);
  for (int y = 0; y < size_y; ++y)
    board[y].resize(size_x, white);

  // Load board.
  for (int y = 0; y < size_y; ++y) {
    lua_geti(L, 1, y + 1);

    for (int x = 0; x < size_x; ++x) {
      lua_geti(L, -1, x + 1);

      switch (lua_tointeger(L, -1)) {
        case 0: board[x][y] = white; break;
        case 1: board[x][y] = black; break;
        case 2: board[x][y] = swhite; break;
        case 3: board[x][y] = sblack; break;
      }

      lua_pop(L, 1);
    }

    lua_pop(L, 1);
  }

  // Load rest arguments.
  std::string name = lua_tostring(L, 2);
  float probability = lua_tonumber(L, 3);
  float weight = lua_tonumber(L, 4);
  int iterations = lua_tointeger(L, 5);
  int seed = lua_tointeger(L, 6);

  // Run CA.
  Board result;
  if (name == "moore")   terrain(board, result,   moore_neighbourhood(probability, weight), iterations, seed);
  if (name == "neumann") terrain(board, result, neumann_neighbourhood(probability, weight), iterations, seed);

  // Return.
  lua_settop(L, 0);
  lua_newtable(L);

  for (int y = 0; y < size_x; ++y) {
    lua_pushinteger(L, y + 1);
    lua_newtable(L);

    for (int x = 0; x < size_x; ++x) {
      lua_pushinteger(L, x + 1);

      switch (result[x][y]) {
        case white:  lua_pushinteger(L, 0); break;
        case black:  lua_pushinteger(L, 1); break;
        case swhite: lua_pushinteger(L, 2); break;
        case sblack: lua_pushinteger(L, 3); break;
      }

      lua_settable(L, 3);
    }

    lua_settable(L, 1);
  }

  return 1;
}

static const struct luaL_Reg ca[] = {
  {"run", run},
  {NULL, NULL}
};

extern "C" int luaopen_ca(lua_State* L) {
  luaL_newlib(L, ca);
  return 1;
}
