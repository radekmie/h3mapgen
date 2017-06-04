#ifndef __H3MLUA_H3MLUA_H_DEF__
#define __H3MLUA_H3MLUA_H_DEF__

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

typedef struct {
    int x;
    int y;
    int z;
} h3mlua_xyz;

h3mlua_xyz h3mlua_check_xyz (lua_State *L, int arg);

#endif
