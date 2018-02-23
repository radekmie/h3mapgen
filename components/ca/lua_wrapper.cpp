#include <iostream>
#include "cellular_terrain.h"

using namespace std;

static int Lua_terrain(lua_State *L)
{
    /*CA(board, neighbourhood, iterations, seed)
      board is a table of booleans. /required
      next lines include information about neighbourhood
	  {
		name is a string (moore or neumann), /required
		probability is a float, /required
 		weight is a float. /required
	  }
      iterations is an integer, /required
      seed is an integer. /optional

	If seed is not provided or left at 0, a random seed will be picked.
     The result of CA(...) should be a new board and the seed used.
    */
	Board table;
	table.resize(256);
	for(int i = 0; i != 256; i++)
		table[i].resize(256,white);
	lua_pushnil(L);              // put a nil key on stack
	while (lua_next(L,1) != 0) { // key(-1) is replaced by the next key(-1) in table(1)
        	int pos = lua_tointeger(L,-2);  // Get position (x,y,z)
		int state = lua_toboolean(L,-1);  // Get state (true/false)
		int x = pos%256;
		int y = (pos/256)%256;
		if(state == 1)
			table[x][y] = black;
		else
			table[x][y] = white;
        	lua_pop(L,1);             // remove value(-1), now key on top at(-1)
    	}
    	lua_pop(L,1);                 // remove last key
	int ind = 2;
	string name = lua_tostring(L,ind);
	ind++;
	float probability = lua_tonumber(L,ind);
	ind++;
	float weight = lua_tonumber(L,ind);
	ind++;
	int iterations = lua_tointeger(L,ind);
	ind++;
	if(lua_isinteger(L,ind) == 1)
		seed = lua_tointeger(L,ind);
	Board result;
	if(name == "moore")
		terrain(table, result, moore_neighbourhood(probability, weight), iterations);
	else
		terrain(table, result, neumann_neighbourhood(probability, weight), iterations);
	lua_settop(L,0);
	lua_newtable(L);
	for(int i = 0; i != 256; i++)
	{
		for(int j = 0; j != result[i].size(); j++)
		{
			int pos = i + j*256;
			lua_pushinteger(L,pos);
			if(result[i][j] == black || result[i][j] == sblack)
				lua_pushboolean(L,1);
			else
				lua_pushboolean(L,0);
			lua_settable(L,1);
		}
	}
	lua_pushinteger(L,seed);
	return 2;
}

static const struct luaL_Reg mylib [] =
 {
	{"CA",Lua_terrain},
	{NULL, NULL}  // sentinel
};

extern "C" int luaopen_terrain(lua_State *L)  // wystawienie na zewnatrz (z extern C)
{
	luaL_newlib(L, mylib);
	return 1;
}

