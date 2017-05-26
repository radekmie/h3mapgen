#include <h3mlib.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <string.h>

#include "homm3tools.h"

static const char *HOMM3LUA_h3mlib_ctx_t = "homm3lua.h3mlib_ctx_t";

// homm3lua.new(format, size)
static int new (lua_State *L) {
  const char *format_s = luaL_checkstring(L, 1);
  char        format_n;

       if (strcmp(format_s, "H3M_FORMAT_AB")  == 0) format_n = H3M_FORMAT_AB;
  else if (strcmp(format_s, "H3M_FORMAT_CHR") == 0) format_n = H3M_FORMAT_CHR;
  else if (strcmp(format_s, "H3M_FORMAT_ROE") == 0) format_n = H3M_FORMAT_ROE;
  else if (strcmp(format_s, "H3M_FORMAT_SOD") == 0) format_n = H3M_FORMAT_SOD;
  else if (strcmp(format_s, "H3M_FORMAT_WOG") == 0) format_n = H3M_FORMAT_WOG;
  else return luaL_error(L, "Invalid format %s.", format_s);

  const char *size_s = luaL_checkstring(L, 2);
  char        size_n;

       if (strcmp(size_s, "H3M_SIZE_SMALL")      == 0) size_n = H3M_SIZE_SMALL;
  else if (strcmp(size_s, "H3M_SIZE_EXTRALARGE") == 0) size_n = H3M_SIZE_EXTRALARGE;
  else if (strcmp(size_s, "H3M_SIZE_LARGE")      == 0) size_n = H3M_SIZE_LARGE;
  else if (strcmp(size_s, "H3M_SIZE_MEDIUM")     == 0) size_n = H3M_SIZE_MEDIUM;
  else return luaL_error(L, "Invalid size %s.", size_s);

  h3mlib_ctx_t *h3mlib_ctx = (h3mlib_ctx_t *) lua_newuserdata(L, sizeof(h3mlib_ctx_t));
  h3m_init_min(h3mlib_ctx, format_n, size_n);

  luaL_setmetatable(L, HOMM3LUA_h3mlib_ctx_t);

  return 1;
}

// homm3lua:__gc()
static int __gc (lua_State *L) {
  h3mlib_ctx_t *h3mlib_ctx = (h3mlib_ctx_t *) luaL_checkudata(L, 1, HOMM3LUA_h3mlib_ctx_t);

  h3m_exit(h3mlib_ctx);

  return 0;
}

// homm3lua:fill(tile)
static int fill (lua_State *L) {
  h3mlib_ctx_t *h3mlib_ctx = (h3mlib_ctx_t *) luaL_checkudata(L, 1, HOMM3LUA_h3mlib_ctx_t);

  const char *terrain_s = luaL_checkstring(L, 2);
  char        terrain_n;

       if (strcmp(terrain_s, "H3M_TERRAIN_DIRT")         == 0) terrain_n = H3M_TERRAIN_DIRT;
  else if (strcmp(terrain_s, "H3M_TERRAIN_GRASS")        == 0) terrain_n = H3M_TERRAIN_GRASS;
  else if (strcmp(terrain_s, "H3M_TERRAIN_LAVA")         == 0) terrain_n = H3M_TERRAIN_LAVA;
  else if (strcmp(terrain_s, "H3M_TERRAIN_ROCK")         == 0) terrain_n = H3M_TERRAIN_ROCK;
  else if (strcmp(terrain_s, "H3M_TERRAIN_ROUGH")        == 0) terrain_n = H3M_TERRAIN_ROUGH;
  else if (strcmp(terrain_s, "H3M_TERRAIN_SAND")         == 0) terrain_n = H3M_TERRAIN_SAND;
  else if (strcmp(terrain_s, "H3M_TERRAIN_SNOW")         == 0) terrain_n = H3M_TERRAIN_SNOW;
  else if (strcmp(terrain_s, "H3M_TERRAIN_SUBTERRANEAN") == 0) terrain_n = H3M_TERRAIN_SUBTERRANEAN;
  else if (strcmp(terrain_s, "H3M_TERRAIN_SWAMP")        == 0) terrain_n = H3M_TERRAIN_SWAMP;
  else if (strcmp(terrain_s, "H3M_TERRAIN_WATER")        == 0) terrain_n = H3M_TERRAIN_WATER;
  else return luaL_error(L, "Invalid terrain %s.", terrain_s);

  h3m_terrain_fill(*h3mlib_ctx, terrain_n);

  return 0;
}

// homm3lua:mobs(name, x, y, z, quantity, disposition, never_flees, does_not_grow)
static int mobs (lua_State *L) {
  h3mlib_ctx_t *h3mlib_ctx = (h3mlib_ctx_t *) luaL_checkudata(L, 1, HOMM3LUA_h3mlib_ctx_t);

  const char *name = luaL_checkstring(L, 2);
  const int does_not_grow = lua_toboolean(L, 9);
  const int never_flees = lua_toboolean(L, 8);
  const int quantity = luaL_checkinteger(L, 6);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);

  const char *disposition_s = luaL_checkstring(L, 7);
  char        disposition_n;

       if (strcmp(disposition_s, "H3M_DISPOSITION_AGGRESSIVE") == 0) disposition_n = H3M_DISPOSITION_AGGRESSIVE;
  else if (strcmp(disposition_s, "H3M_DISPOSITION_COMPLIANT")  == 0) disposition_n = H3M_DISPOSITION_COMPLIANT;
  else if (strcmp(disposition_s, "H3M_DISPOSITION_FRIENDLY")   == 0) disposition_n = H3M_DISPOSITION_FRIENDLY;
  else if (strcmp(disposition_s, "H3M_DISPOSITION_HOSTILE")    == 0) disposition_n = H3M_DISPOSITION_HOSTILE;
  else if (strcmp(disposition_s, "H3M_DISPOSITION_SAVAGE")     == 0) disposition_n = H3M_DISPOSITION_SAVAGE;
  else return luaL_error(L, "Invalid disposition %s.", disposition_s);

  luaL_checkoption(L, 2, NULL, HOMM3LUA_monsters);

  int object = 0;

  h3m_object_add(*h3mlib_ctx, name, x, y, z, &object);
  h3m_object_set_quantitiy(*h3mlib_ctx, object, quantity);
  h3m_object_set_disposition(*h3mlib_ctx, object, disposition_n);
  h3m_object_set_never_flees(*h3mlib_ctx, object, never_flees);
  h3m_object_set_does_not_grow(*h3mlib_ctx, object, does_not_grow);

  return 0;
}

// homm3lua:save(path)
static int save (lua_State *L) {
  h3mlib_ctx_t *h3mlib_ctx = (h3mlib_ctx_t *) luaL_checkudata(L, 1, HOMM3LUA_h3mlib_ctx_t);

  const char *path = luaL_checkstring(L, 2);

  h3m_write(*h3mlib_ctx, path);

  return 0;
}

// homm3lua:text(text, x, y, z, item)
static int text (lua_State *L) {
  h3mlib_ctx_t *h3mlib_ctx = (h3mlib_ctx_t *) luaL_checkudata(L, 1, HOMM3LUA_h3mlib_ctx_t);

  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);

  const char *text = luaL_checkstring(L, 2);
  const char *item = luaL_checkstring(L, 6);

  h3m_object_text(*h3mlib_ctx, item, x, y, z, text);

  return 0;
}

static const struct luaL_Reg homm3lua_h3mlib_ctx_t[] = {
  {"__gc", __gc},
  {"fill", fill},
  {"mobs", mobs},
  {"save", save},
  {"text", text},
  {NULL, NULL}
};

static const struct luaL_Reg homm3lua[] = {
  {"new", new},
  {NULL, NULL}
};

int luaopen_homm3lua (lua_State *L) {
  luaL_newmetatable(L, HOMM3LUA_h3mlib_ctx_t);
  lua_pushvalue(L, -1);
  lua_setfield(L, -2, "__index");
  luaL_setfuncs(L, homm3lua_h3mlib_ctx_t, 0);
  luaL_newlib(L, homm3lua);

  return 1;
}
