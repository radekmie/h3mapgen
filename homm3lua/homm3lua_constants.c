#include "homm3lua_constants.h"

int h3mlua_check_disposition (lua_State *L, int arg) {
  const char *disposition = luaL_checkstring(L, arg);

  if (strcmp(disposition, "H3M_DISPOSITION_AGGRESSIVE") == 0) return H3M_DISPOSITION_AGGRESSIVE;
  if (strcmp(disposition, "H3M_DISPOSITION_COMPLIANT")  == 0) return H3M_DISPOSITION_COMPLIANT;
  if (strcmp(disposition, "H3M_DISPOSITION_FRIENDLY")   == 0) return H3M_DISPOSITION_FRIENDLY;
  if (strcmp(disposition, "H3M_DISPOSITION_HOSTILE")    == 0) return H3M_DISPOSITION_HOSTILE;
  if (strcmp(disposition, "H3M_DISPOSITION_SAVAGE")     == 0) return H3M_DISPOSITION_SAVAGE;

  return luaL_error(L, "Invalid disposition: %s.", disposition);
}

int h3mlua_check_difficulty (lua_State *L, int arg) {
  const int difficulty = luaL_checkinteger(L, arg);

  if (difficulty >= 0 && difficulty <= 4)
    return difficulty;

  return luaL_error(L, "Invalid difficulty: %d.", difficulty);
}

int h3mlua_check_format (lua_State *L, int arg) {
  const char *format = luaL_checkstring(L, arg);

  if (strcmp(format, "H3M_FORMAT_AB")  == 0) return H3M_FORMAT_AB;
  if (strcmp(format, "H3M_FORMAT_CHR") == 0) return H3M_FORMAT_CHR;
  if (strcmp(format, "H3M_FORMAT_ROE") == 0) return H3M_FORMAT_ROE;
  if (strcmp(format, "H3M_FORMAT_SOD") == 0) return H3M_FORMAT_SOD;
  if (strcmp(format, "H3M_FORMAT_WOG") == 0) return H3M_FORMAT_WOG;

  return luaL_error(L, "Invalid format: %s.", format);
}

int h3mlua_check_owner (lua_State *L, int arg) {
  const int owner = luaL_checkinteger(L, arg);

  if (owner >= -1 && owner <= 7)
    return owner;

  return luaL_error(L, "Invalid owner: %d.", owner);
}

int h3mlua_check_player (lua_State *L, int arg) {
  const int player = luaL_checkinteger(L, arg);

  if (player >= 0 && player <= 7)
    return player;

  return luaL_error(L, "Invalid player: %d.", player);
}

int h3mlua_check_size (lua_State *L, int arg) {
  const char *size = luaL_checkstring(L, arg);

  if (strcmp(size, "H3M_SIZE_SMALL")      == 0) return H3M_SIZE_SMALL;
  if (strcmp(size, "H3M_SIZE_EXTRALARGE") == 0) return H3M_SIZE_EXTRALARGE;
  if (strcmp(size, "H3M_SIZE_LARGE")      == 0) return H3M_SIZE_LARGE;
  if (strcmp(size, "H3M_SIZE_MEDIUM")     == 0) return H3M_SIZE_MEDIUM;

  return luaL_error(L, "Invalid size: %s.", size);
}

int h3mlua_check_terrain (lua_State *L, int arg) {
  const char *terrain = luaL_checkstring(L, arg);

  if (strcmp(terrain, "H3M_TERRAIN_DIRT")         == 0) return H3M_TERRAIN_DIRT;
  if (strcmp(terrain, "H3M_TERRAIN_GRASS")        == 0) return H3M_TERRAIN_GRASS;
  if (strcmp(terrain, "H3M_TERRAIN_LAVA")         == 0) return H3M_TERRAIN_LAVA;
  if (strcmp(terrain, "H3M_TERRAIN_ROCK")         == 0) return H3M_TERRAIN_ROCK;
  if (strcmp(terrain, "H3M_TERRAIN_ROUGH")        == 0) return H3M_TERRAIN_ROUGH;
  if (strcmp(terrain, "H3M_TERRAIN_SAND")         == 0) return H3M_TERRAIN_SAND;
  if (strcmp(terrain, "H3M_TERRAIN_SNOW")         == 0) return H3M_TERRAIN_SNOW;
  if (strcmp(terrain, "H3M_TERRAIN_SUBTERRANEAN") == 0) return H3M_TERRAIN_SUBTERRANEAN;
  if (strcmp(terrain, "H3M_TERRAIN_SWAMP")        == 0) return H3M_TERRAIN_SWAMP;
  if (strcmp(terrain, "H3M_TERRAIN_WATER")        == 0) return H3M_TERRAIN_WATER;

  return luaL_error(L, "Invalid terrain: %s.", terrain);
}
