#include "homm3lua.h"

// homm3lua.new(format, size)
static int new (lua_State *L) {
  const int format = h3mlua_check_format(L, 1);
  const int size = h3mlua_check_size(L, 2);

  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) lua_newuserdata(L, sizeof(h3mlib_ctx_t));

  if (h3m_init_min(h3m, format, size))
    return luaL_error(L, "h3m_init_min");

  luaL_setmetatable(L, "homm3lua");

  return 1;
}

// homm3lua:__gc()
static int __gc (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  h3m_exit(h3m);

  return 0;
}

// homm3lua:artifact(artifact, x, y, z)
static int artifact (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *artifact = luaL_checkstring(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);

  int object = 0;

  if (h3m_object_add(*h3m, artifact, x, y, z, &object))
    return luaL_error(L, "h3m_object_add");

  return 0;
}

// homm3lua:creature(creature, x, y, z, quantity, disposition, never_flees, does_not_grow)
static int creature (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *creature = luaL_checkstring(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);
  const int quantity = luaL_checkinteger(L, 6);
  const int disposition = h3mlua_check_disposition(L, 7);
  const int never_flees = lua_toboolean(L, 8);
  const int does_not_grow = lua_toboolean(L, 9);

  int object = 0;

  if (h3m_object_add(*h3m, creature, x, y, z, &object))
    return luaL_error(L, "h3m_object_add");
  if (h3m_object_set_quantitiy(*h3m, object, quantity))
    return luaL_error(L, "h3m_object_set_quantitiy");
  if (h3m_object_set_disposition(*h3m, object, disposition))
    return luaL_error(L, "h3m_object_set_disposition");
  if (h3m_object_set_never_flees(*h3m, object, never_flees))
    return luaL_error(L, "h3m_object_set_never_flees");
  if (h3m_object_set_does_not_grow(*h3m, object, does_not_grow))
    return luaL_error(L, "h3m_object_set_does_not_grow");

  return 0;
}

// homm3lua:description(description)
static int description (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *description = luaL_checkstring(L, 2);

  h3m_desc_set(*h3m, description);

  return 0;
}

// homm3lua:difficulty(difficulty)
static int difficulty (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const int difficulty = h3mlua_check_difficulty(L, 2);

  h3m_difficulty_set(*h3m, difficulty);

  return 0;
}

// homm3lua:fill(tile)
static int fill (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const int terrain = h3mlua_check_terrain(L, 2);

  if (h3m_terrain_fill(*h3m, terrain))
    return luaL_error(L, "h3m_terrain_fill");

  return 0;
}

// homm3lua:hero(hero, x, y, z, player)
static int hero (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *hero = luaL_checkstring(L, 2);
  const int class = h3mlua_check_class(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);
  const int player = h3mlua_check_player(L, 6);

  int object = 0;

  if (h3m_object_add(*h3m, hero, x, y, z, &object))
    return luaL_error(L, "h3m_object_add");
  if (h3m_object_set_subtype(*h3m, object, class))
    return luaL_error(L, "h3m_object_set_subtype");
  if (h3m_object_set_owner(*h3m, object, player))
    return luaL_error(L, "h3m_object_set_owner");

  return 0;
}

// homm3lua:mine(mine, x, y, z, owner)
static int mine (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *mine = luaL_checkstring(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);
  const int owner = h3mlua_check_owner(L, 6);

  int object = 0;

  if (h3m_object_add(*h3m, mine, x, y, z, &object))
    return luaL_error(L, "h3m_object_add");
  if (owner != -1 && h3m_object_set_owner(*h3m, object, owner))
    return luaL_error(L, "h3m_object_set_owner");

  return 0;
}

// homm3lua:name(name)
static int name (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *name = luaL_checkstring(L, 2);

  h3m_name_set(*h3m, name);

  return 0;
}

// homm3lua:player(player)
static int player (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const int player = h3mlua_check_player(L, 2);

  h3m_player_enable(*h3m, player);

  return 0;
}

// homm3lua:obstacle(obstacle, x, y, z)
static int obstacle (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *obstacle = luaL_checkstring(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);

  int object = 0;

  if (h3m_object_add(*h3m, obstacle, x, y, z, &object))
    return luaL_error(L, "h3m_object_add");

  return 0;
}

// homm3lua:resource(resource, x, y, z, quantity)
static int resource (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *resource = luaL_checkstring(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);
  const int quantity = luaL_checkinteger(L, 6);

  int object = 0;

  if (h3m_object_add(*h3m, resource, x, y, z, &object))
    return luaL_error(L, "h3m_object_add");
  if (h3m_object_set_quantitiy(*h3m, object, quantity))
    return luaL_error(L, "h3m_object_set_quantitiy");

  return 0;
}

// homm3lua:text(text, x, y, z, item)
static int text (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *text = luaL_checkstring(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);
  const char *item = luaL_checkstring(L, 6);

  if (h3m_object_text(*h3m, item, x, y, z, text))
    return luaL_error(L, "h3m_object_text");

  return 0;
}

// homm3lua:town(town, x, y, z, owner)
static int town (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *town = luaL_checkstring(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);
  const int owner = h3mlua_check_owner(L, 6);

  int object = 0;

  if (h3m_object_add(*h3m, town, x, y, z, &object))
    return luaL_error(L, "h3m_object_add");
  if (owner != -1 && h3m_object_set_owner(*h3m, object, owner))
    return luaL_error(L, "h3m_object_set_owner");

  return 0;
}

// homm3lua:write(path)
static int write (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *path = luaL_checkstring(L, 2);

  if (h3m_write(*h3m, path))
    return luaL_error(L, "h3m_write");

  return 0;
}

static const struct luaL_Reg h3mlua_instance[] = {
  {"__gc", __gc},
  {"artifact", artifact},
  {"creature", creature},
  {"description", description},
  {"difficulty", difficulty},
  {"fill", fill},
  {"hero", hero},
  {"mine", mine},
  {"name", name},
  {"player", player},
  {"obstacle", obstacle},
  {"resource", resource},
  {"text", text},
  {"town", town},
  {"write", write},
  {NULL, NULL}
};

static const struct luaL_Reg h3mlua[] = {
  {"new", new},
  {NULL, NULL}
};

int luaopen_homm3lua (lua_State *L) {
  luaL_newmetatable(L, "homm3lua");
  lua_pushvalue(L, -1);
  lua_setfield(L, -2, "__index");
  luaL_setfuncs(L, h3mlua_instance, 0);
  luaL_newlib(L, h3mlua);

  return 1;
}
