#include "homm3lua.h"

/// Glue between homm3tools and Lua.
// @module homm3lua

/// Creates a new map.
// @function    new
// @tparam      integer     format    Map format. See FORMAT_*
// @tparam      integer     size      Map size. See SIZE_*
// @treturn     homm3lua              Map instance.
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

/// Map instance.
// @type homm3lua

/// Clean up map memory.
// @local
// @function    __gc
static int __gc (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  h3m_exit(h3m);

  return 0;
}

/// Place an artifact.
// @function    artifact
// @tparam      integer         artifact    Artifact name. See ARTIFACT_*
// @tparam      homm3lua_xyz    xyz         Position in {x, y, z} format.
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

/// Place a creature.
// @function    creature
// @tparam      integer         creature         Creature name. See CREATURE_*
// @tparam      homm3lua_xyz    xyz              Position in {x, y, z} format.
// @tparam      integer         quantity         Quantity. Set to 0 for random integer.
// @tparam      integer         disposition      Creatures disposition. See DISPOSITION_*
// @tparam      boolean         never_flees      Disallows creatures to flee.
// @tparam      boolean         does_not_grow    Disallows creatures to grow.
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

/// Set map description.
// @function    description
// @tparam      string         description    Map description.
static int description (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *description = luaL_checkstring(L, 2);

  h3m_desc_set(*h3m, description);

  return 0;
}

/// Set map difficulty.
// @function    difficulty
// @tparam      integer       difficulty    Map difficulty. See DIFFICULTY_*
static int difficulty (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const int difficulty = luaL_checkinteger(L, 2);

  h3m_difficulty_set(*h3m, difficulty);

  return 0;
}

/// Place a hero.
// @function    hero
// @tparam      string          hero      Hero name. See HERO_*
// @tparam      homm3lua_xyz    xyz       Position in {x, y, z} format.
// @tparam      integer         player    Player. See PLAYER_*
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

/// Place a mine.
// @function    mine
// @tparam      string          mine      Mine name. See MINE_*
// @tparam      homm3lua_xyz    xyz       Position in {x, y, z} format.
// @tparam      integer         player    Owner. See OWNER_*
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

/// Set map name.
// @function    name
// @tparam      string    name    Map name.
static int name (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *name = luaL_checkstring(L, 2);

  h3m_name_set(*h3m, name);

  return 0;
}

/// Enables player.
// @function    player
// @tparam      integer    player    Player. See PLAYER_*
static int player (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const int player = luaL_checkinteger(L, 2);

  h3m_player_enable(*h3m, player);

  return 0;
}

/// Place an obstacle.
// @function    obstacle
// @tparam      string          obstacle    Obstacle name. No constants so far.
// @tparam      homm3lua_xyz    xyz         Position in {x, y, z} format.
static int obstacle (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *obstacle = luaL_checkstring(L, 2);
  const h3mlua_xyz xyz = h3mlua_check_xyz(L, 3);

  int object = 0;

  if (h3m_object_add(*h3m, obstacle, xyz.x, xyz.y, xyz.z, &object))
    return luaL_error(L, "h3m_object_add");

  return 0;
}

/// Place a resource.
// @function    resource
// @tparam      string          resource    Obstacle name. No constants so far.
// @tparam      homm3lua_xyz    xyz         Position in {x, y, z} format.
// @tparam      integer         quantity    Quantity. Set to 0 for random integer.
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

/// Draws terrain.
// @function    terrain
// @tparam      integer|function    terrain    Either a constant or a generating function of signature (homm3lua_xyz) -> (terrain?, road?, river?). See TERRAIN_*
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

/// Write text with given object.
// @function    text
// @tparam      string          text       Text.
// @tparam      homm3lua_xyz    xyz        Position in {x, y, z} format. Left top corner.
// @tparam      string          object     Object.
static int text (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *text = luaL_checkstring(L, 2);
  const h3mlua_xyz xyz = h3mlua_check_xyz(L, 3);
  const char *object = luaL_checkstring(L, 4);

  if (h3m_object_text(*h3m, object, xyz.x, xyz.y, xyz.z, text))
    return luaL_error(L, "h3m_object_text");

  return 0;
}

/// Place a town.
// @function    town
// @tparam      string         town            Town name. See TOWN_*
// @tparam      homm3lua_xyz   xyz             Position in {x, y, z} format. Entry is at {x - 2, y, z}.
// @tparam      integer        owner           Owner. See OWNER_*
// @tparam      boolean        is_main_town    Optional. Set town as player main one.
static int town (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *town = luaL_checkstring(L, 2);
  const h3mlua_xyz xyz = h3mlua_check_xyz(L, 3);
  const int owner = luaL_checkinteger(L, 4);
  const int is_main_town = lua_toboolean(L, 5);

  int object = 0;

  if (h3m_object_add(*h3m, town, xyz.x, xyz.y, xyz.z, &object))
    return luaL_error(L, "h3m_object_add");
  if ((*h3m)->meta.od_entries[object].oa_type != META_OBJECT_TOWN)
    return luaL_argerror(L, 2, "it's not a town");
  if (owner != -1 && h3m_object_set_owner(*h3m, object, owner))
    return luaL_error(L, "h3m_object_set_owner");
  if (is_main_town) {
    if (owner == -1)
      return luaL_error(L, "Neutral town cannot be a main one.");

    if (strcmp(town, "Castle")      == 0) (*h3m)->h3m.players[owner]->roe.town_types = 0x01;
    if (strcmp(town, "Rampart")     == 0) (*h3m)->h3m.players[owner]->roe.town_types = 0x02;
    if (strcmp(town, "Tower")       == 0) (*h3m)->h3m.players[owner]->roe.town_types = 0x04;
    if (strcmp(town, "Inferno")     == 0) (*h3m)->h3m.players[owner]->roe.town_types = 0x08;
    if (strcmp(town, "Necropolis")  == 0) (*h3m)->h3m.players[owner]->roe.town_types = 0x10;
    if (strcmp(town, "Dungeon")     == 0) (*h3m)->h3m.players[owner]->roe.town_types = 0x20;
    if (strcmp(town, "Fortress")    == 0) (*h3m)->h3m.players[owner]->roe.town_types = 0x40;
    if (strcmp(town, "Stronghold")  == 0) (*h3m)->h3m.players[owner]->roe.town_types = 0x80;
    if (strcmp(town, "Random Town") == 0) (*h3m)->h3m.players[owner]->roe.town_types = 0xFF;

    (*h3m)->meta.player_sizes[owner] = 11;
    (*h3m)->h3m.players[owner]->roe.unknown1 = 0;
    (*h3m)->h3m.players[owner]->roe.has_main_town = 1;
    (*h3m)->h3m.players[owner]->roe.u.e1.starting_town_xpos = xyz.x - 2;
    (*h3m)->h3m.players[owner]->roe.u.e1.starting_town_ypos = xyz.y;
    (*h3m)->h3m.players[owner]->roe.u.e1.starting_town_zpos = xyz.z;
    (*h3m)->h3m.players[owner]->roe.u.e1.starting_hero_is_random = 1;
    (*h3m)->h3m.players[owner]->roe.u.e1.starting_hero_type = 0xFF;
  }

  return 0;
}

/// Configures underground presence.
// @function    underground
// @tparam      boolean        has_two_levels    Allows underground.
static int underground (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const uint8_t has_two_levels = lua_toboolean(L, 2);

  (*h3m)->h3m.bi.any.has_two_levels = has_two_levels;

  return 0;
}

/// Export map to a file.
// @function    write
// @tparam      string     path    File path.
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

// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------

int luaopen_homm3lua (lua_State *L) {
  luaL_newmetatable(L, "homm3lua");
  lua_pushvalue(L, -1);
  lua_setfield(L, -2, "__index");
  luaL_setfuncs(L, h3mlua_instance, 0);
  luaL_newlib(L, h3mlua);
  h3mlua_constants(L);

  return 1;
}
