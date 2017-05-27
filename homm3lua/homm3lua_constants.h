#ifndef __H3MLUA_CONSTANTS_H_DEF__
#define __H3MLUA_CONSTANTS_H_DEF__

#include <h3mlib.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <string.h>

int h3mlua_check_disposition (lua_State *L, int arg);
int h3mlua_check_format      (lua_State *L, int arg);
int h3mlua_check_owner       (lua_State *L, int arg);
int h3mlua_check_player      (lua_State *L, int arg);
int h3mlua_check_size        (lua_State *L, int arg);
int h3mlua_check_terrain     (lua_State *L, int arg);

#endif
