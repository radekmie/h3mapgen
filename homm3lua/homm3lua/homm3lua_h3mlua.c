#include "homm3lua_h3mlua.h"

h3mlua_xyz h3mlua_check_xyz (lua_State *L, int arg) {
  luaL_checktype(L, arg, LUA_TTABLE);

  int isnum;

  lua_getfield(L, arg, "x");
  const int x = lua_tointegerx(L, -1, &isnum);
  luaL_argcheck(L, isnum, arg, "x must be an integer");

  lua_getfield(L, arg, "y");
  const int y = lua_tointegerx(L, -1, &isnum);
  luaL_argcheck(L, isnum, arg, "y must be an integer");

  lua_getfield(L, arg, "z");
  const int z = lua_tointegerx(L, -1, &isnum);
  luaL_argcheck(L, isnum, arg, "z must be an integer");

  lua_pop(L, 3);

  h3mlua_xyz xyz = {x, y, z};
  return xyz;
}
