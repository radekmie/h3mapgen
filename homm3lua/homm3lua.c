#include "homm3lua.h"

// .new(format, size)
static int new (lua_State *L) {
  const int format = luaL_checkinteger(L, 1);
  const int size = luaL_checkinteger(L, 2);

  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) lua_newuserdata(L, sizeof(h3mlib_ctx_t));

  if (h3m_init_min(h3m, format, size))
    return luaL_error(L, "h3m_init_min");

  (*h3m)->h3m.bi.any.has_hero = 1;

  luaL_setmetatable(L, "homm3lua");

  return 1;
}

// :__gc()
static int __gc (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  h3m_exit(h3m);

  return 0;
}

// :artifact(artifact, {x, y, z})
static int artifact (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *artifact = luaL_checkstring(L, 2);
  const h3mlua_xyz xyz = h3mlua_check_xyz(L, 3);

  int object = 0;

  if (h3m_object_add(*h3m, artifact, xyz.x, xyz.y, xyz.z, &object))
    return luaL_error(L, "h3m_object_add");
  if ((*h3m)->meta.od_entries[object].oa_type != META_OBJECT_ARTIFACT)
    return luaL_argerror(L, 2, "it's not an artifact");

  return 0;
}

// :creature(creature, {x, y, z}, quantity, disposition, never_flees, does_not_grow)
static int creature (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *creature = luaL_checkstring(L, 2);
  const h3mlua_xyz xyz = h3mlua_check_xyz(L, 3);
  const int quantity = luaL_checkinteger(L, 4);
  const int disposition = luaL_checkinteger(L, 5);
  const int never_flees = lua_toboolean(L, 6);
  const int does_not_grow = lua_toboolean(L, 7);

  int object = 0;

  if (h3m_object_add(*h3m, creature, xyz.x, xyz.y, xyz.z, &object))
    return luaL_error(L, "h3m_object_add");
  if ((*h3m)->meta.od_entries[object].oa_type != META_OBJECT_MONSTER)
    return luaL_argerror(L, 2, "it's not a creature");
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

// :description(description)
static int description (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *description = luaL_checkstring(L, 2);

  h3m_desc_set(*h3m, description);

  return 0;
}

// :difficulty(difficulty)
static int difficulty (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const int difficulty = luaL_checkinteger(L, 2);

  h3m_difficulty_set(*h3m, difficulty);

  return 0;
}

// :hero(hero, {x, y, z}, player)
static int hero (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const int hero = luaL_checkinteger(L, 2);
  const h3mlua_xyz xyz = h3mlua_check_xyz(L, 3);
  const int player = luaL_checkinteger(L, 4);

  static const char *models[] = {
    "Knight",
    "Cleric",
    "Ranger",
    "Druid",
    "Alchemist",
    "Wizard",
    "Demoniac",
    "Heretic",
    "Death Knight",
    "Necromancer",
    "Overlord",
    "Warlock",
    "Barbarian",
    "Battle Mage",
    "Beastmaster",
    "Witch",
    "Planeswalker",
    "Elementalist"
  };

  int object = 0;

  if (h3m_object_add(*h3m, models[hero / 8], xyz.x, xyz.y, xyz.z, &object))
    return luaL_error(L, "h3m_object_add");
  if ((*h3m)->meta.od_entries[object].oa_type != META_OBJECT_HERO)
    return luaL_argerror(L, 2, "it's not a hero");
  if (h3m_object_set_subtype(*h3m, object, hero))
    return luaL_error(L, "h3m_object_set_subtype");
  if (h3m_object_set_owner(*h3m, object, player))
    return luaL_error(L, "h3m_object_set_owner");

  return 0;
}

// :mine(mine, {x, y, z}, owner)
static int mine (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *mine = luaL_checkstring(L, 2);
  const h3mlua_xyz xyz = h3mlua_check_xyz(L, 3);
  const int owner = luaL_checkinteger(L, 4);

  int object = 0;

  if (h3m_object_add(*h3m, mine, xyz.x, xyz.y, xyz.z, &object))
    return luaL_error(L, "h3m_object_add");
  if ((*h3m)->meta.od_entries[object].oa_type != META_OBJECT_RESOURCE_GENERATOR)
    return luaL_argerror(L, 2, "it's not a mine");
  if (owner != -1 && h3m_object_set_owner(*h3m, object, owner))
    return luaL_error(L, "h3m_object_set_owner");

  return 0;
}

// :name(name)
static int name (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *name = luaL_checkstring(L, 2);

  h3m_name_set(*h3m, name);

  return 0;
}

// :player(player)
static int player (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const int player = luaL_checkinteger(L, 2);

  h3m_player_enable(*h3m, player);

  return 0;
}

// :obstacle(obstacle, {x, y, z})
static int obstacle (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *obstacle = luaL_checkstring(L, 2);
  const h3mlua_xyz xyz = h3mlua_check_xyz(L, 3);

  int object = 0;

  if (h3m_object_add(*h3m, obstacle, xyz.x, xyz.y, xyz.z, &object))
    return luaL_error(L, "h3m_object_add");

  return 0;
}

// :resource(resource, {x, y, z}, quantity)
static int resource (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *resource = luaL_checkstring(L, 2);
  const h3mlua_xyz xyz = h3mlua_check_xyz(L, 3);
  const int quantity = luaL_checkinteger(L, 4);

  int object = 0;

  if (h3m_object_add(*h3m, resource, xyz.x, xyz.y, xyz.z, &object))
    return luaL_error(L, "h3m_object_add");
  if ((*h3m)->meta.od_entries[object].oa_type != META_OBJECT_RESOURCE)
    return luaL_argerror(L, 2, "it's not a resource");
  if (h3m_object_set_quantitiy(*h3m, object, quantity))
    return luaL_error(L, "h3m_object_set_quantitiy");

  return 0;
}

// :terrain(terrain | {x, y, z} -> (terrain?, road?, river?))
static int terrain (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  switch (lua_type(L, 2)) {
    case LUA_TFUNCTION: {
      const int both = (*h3m)->h3m.bi.any.has_two_levels;
      const int size = (*h3m)->h3m.bi.any.map_size;
      const int size2 = size * size;

      uint8_t *rivers  = calloc((1 + both) * size2, sizeof(uint8_t));
      uint8_t *roads   = calloc((1 + both) * size2, sizeof(uint8_t));
      uint8_t *terrain = malloc((1 + both) * size2);

      if (h3m_terrain_get_all((*h3m), 0, terrain, size2))
        return luaL_error(L, "h3m_terrain_get_all");
      if (both && h3m_terrain_get_all((*h3m), 1, terrain, size2))
        return luaL_error(L, "h3m_terrain_get_all");

      for (int z = 0; z < 1 + both; ++z)
      for (int y = 0; y < size; ++y)
      for (int x = 0; x < size; ++x) {
        const int index = H3M_2D_TO_1D(size, x, y, z);

        lua_pushvalue(L, 2);
        lua_pushinteger(L, x);
        lua_pushinteger(L, y);
        lua_pushinteger(L, z);
        lua_call(L, 3, 3);

        if (!lua_isnil(L, -1)) rivers [index] = luaL_checkinteger(L, -1);
        if (!lua_isnil(L, -2)) roads  [index] = luaL_checkinteger(L, -2);
        if (!lua_isnil(L, -3)) terrain[index] = luaL_checkinteger(L, -3);

        lua_pop(L, 3);
      }

      if (h3m_generate_tiles((*h3m), size, 0, terrain, roads, rivers))
        return luaL_error(L, "h3m_generate_tiles");
      if (both && h3m_generate_tiles((*h3m), size, 1, terrain + size2, roads + size2, rivers + size2))
        return luaL_error(L, "h3m_generate_tiles");

      free(rivers);
      free(roads);
      free(terrain);

      break;
    }

    case LUA_TNUMBER: {
      const int terrain = luaL_checkinteger(L, 2);

      if (h3m_terrain_fill(*h3m, terrain))
        return luaL_error(L, "h3m_terrain_fill");
      break;
    }

    default:
      return luaL_argerror(L, 2, "terrain must be a function or an integer");
  }

  return 0;
}

// :text(text, {x, y, z}, object)
static int text (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *text = luaL_checkstring(L, 2);
  const h3mlua_xyz xyz = h3mlua_check_xyz(L, 3);
  const char *object = luaL_checkstring(L, 4);

  if (h3m_object_text(*h3m, object, xyz.x, xyz.y, xyz.z, text))
    return luaL_error(L, "h3m_object_text");

  return 0;
}

// :town(town, {x, y, z}, owner)
static int town (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *town = luaL_checkstring(L, 2);
  const h3mlua_xyz xyz = h3mlua_check_xyz(L, 3);
  const int owner = luaL_checkinteger(L, 4);

  int object = 0;

  if (h3m_object_add(*h3m, town, xyz.x, xyz.y, xyz.z, &object))
    return luaL_error(L, "h3m_object_add");
  if ((*h3m)->meta.od_entries[object].oa_type != META_OBJECT_TOWN)
    return luaL_argerror(L, 2, "it's not a town");
  if (owner != -1 && h3m_object_set_owner(*h3m, object, owner))
    return luaL_error(L, "h3m_object_set_owner");

  return 0;
}

// :underground(has_two_levels)
static int underground (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const uint8_t has_two_levels = lua_toboolean(L, 2);

  (*h3m)->h3m.bi.any.has_two_levels = has_two_levels;

  return 0;
}

// :write(path)
static int write (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *path = luaL_checkstring(L, 2);

  if (h3m_write(*h3m, path))
    return luaL_error(L, "h3m_write");
  // https://github.com/potmdehex/homm3tools/issues/31
  // Meanwhile, normal gzip is working:
  //   gzip path && mv path.gz path
  // if (h3m_compress(path, path))
  //   return luaL_error(L, "h3m_compress");

  return 0;
}

static const struct luaL_Reg h3mlua_instance[] = {
  {"__gc", __gc},
  {"artifact", artifact},
  {"creature", creature},
  {"description", description},
  {"difficulty", difficulty},
  {"hero", hero},
  {"mine", mine},
  {"name", name},
  {"obstacle", obstacle},
  {"player", player},
  {"resource", resource},
  {"terrain", terrain},
  {"text", text},
  {"town", town},
  {"underground", underground},
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
  h3mlua_constants(L);

  return 1;
}
