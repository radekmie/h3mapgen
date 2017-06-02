#include "homm3lua.h"

// .new(format, size)
static int new (lua_State *L) {
  const int format = luaL_checkinteger(L, 1);
  const int size = luaL_checkinteger(L, 2);

  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) lua_newuserdata(L, sizeof(h3mlib_ctx_t));

  if (h3m_init_min(h3m, format, size))
    return luaL_error(L, "h3m_init_min");

  luaL_setmetatable(L, "homm3lua");

  return 1;
}

// :__gc()
static int __gc (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  h3m_exit(h3m);

  return 0;
}

// :artifact(artifact, x, y, z)
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

// :creature(creature, x, y, z, quantity, disposition, never_flees, does_not_grow)
static int creature (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *creature = luaL_checkstring(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);
  const int quantity = luaL_checkinteger(L, 6);
  const int disposition = luaL_checkinteger(L, 7);
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

// :fill(terrain)
static int fill (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const int terrain = luaL_checkinteger(L, 2);

  if (h3m_terrain_fill(*h3m, terrain))
    return luaL_error(L, "h3m_terrain_fill");

  return 0;
}

// :hero(hero, x, y, z, player)
static int hero (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const int hero = luaL_checkinteger(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);
  const int player = luaL_checkinteger(L, 6);

  int object = 0;

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

  if (h3m_object_add(*h3m, models[hero / 8], x, y, z, &object))
    return luaL_error(L, "h3m_object_add");
  if (h3m_object_set_subtype(*h3m, object, hero))
    return luaL_error(L, "h3m_object_set_subtype");
  if (h3m_object_set_owner(*h3m, object, player))
    return luaL_error(L, "h3m_object_set_owner");

  return 0;
}

// :mine(mine, x, y, z, owner)
static int mine (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *mine = luaL_checkstring(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);
  const int owner = luaL_checkinteger(L, 6);

  int object = 0;

  if (h3m_object_add(*h3m, mine, x, y, z, &object))
    return luaL_error(L, "h3m_object_add");
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

// :obstacle(object, x, y, z)
static int obstacle (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *object = luaL_checkstring(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);

  int object = 0;

  if (h3m_object_add(*h3m, object, x, y, z, &object))
    return luaL_error(L, "h3m_object_add");

  return 0;
}

// :resource(resource, x, y, z, quantity)
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

// :text(text, x, y, z, object)
static int text (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *text = luaL_checkstring(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);
  const char *object = luaL_checkstring(L, 6);

  if (h3m_object_text(*h3m, object, x, y, z, text))
    return luaL_error(L, "h3m_object_text");

  return 0;
}

// :town(town, x, y, z, owner)
static int town (lua_State *L) {
  h3mlib_ctx_t *h3m = (h3mlib_ctx_t *) luaL_checkudata(L, 1, "homm3lua");

  const char *town = luaL_checkstring(L, 2);
  const int x = luaL_checkinteger(L, 3);
  const int y = luaL_checkinteger(L, 4);
  const int z = luaL_checkinteger(L, 5);
  const int owner = luaL_checkinteger(L, 6);

  int object = 0;

  if (h3m_object_add(*h3m, town, x, y, z, &object))
    return luaL_error(L, "h3m_object_add");
  if (owner != -1 && h3m_object_set_owner(*h3m, object, owner))
    return luaL_error(L, "h3m_object_set_owner");

  return 0;
}

// :write(path)
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
  {"obstacle", obstacle},
  {"player", player},
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

#define constant(name, value) lua_pushinteger(L, value); lua_setfield(L, -2, name);
  constant("DIFFICULTY_EASY",        0);
  constant("DIFFICULTY_EXPERT",      3);
  constant("DIFFICULTY_HARD",        2);
  constant("DIFFICULTY_IMPOSSIBLE",  4);
  constant("DIFFICULTY_NORMAL",      1);
  constant("DISPOSITION_AGGRESSIVE", H3M_DISPOSITION_AGGRESSIVE);
  constant("DISPOSITION_COMPLIANT",  H3M_DISPOSITION_COMPLIANT);
  constant("DISPOSITION_FRIENDLY",   H3M_DISPOSITION_FRIENDLY);
  constant("DISPOSITION_HOSTILE",    H3M_DISPOSITION_HOSTILE);
  constant("DISPOSITION_SAVAGE",     H3M_DISPOSITION_SAVAGE);
  constant("FORMAT_AB",              H3M_FORMAT_AB);
  constant("FORMAT_CHR",             H3M_FORMAT_CHR);
  constant("FORMAT_ROE",             H3M_FORMAT_ROE);
  constant("FORMAT_SOD",             H3M_FORMAT_SOD);
  constant("FORMAT_WOG",             H3M_FORMAT_WOG);
  constant("HERO_ADELA",             H3M_HERO_ADELA);
  constant("HERO_ADELAIDE",          H3M_HERO_ADELAIDE);
  // constant("HERO_ADRIENNE",          H3M_HERO_ADRIENNE);
  constant("HERO_AENAIN",            H3M_HERO_AENAIN);
  constant("HERO_AERIS",             H3M_HERO_AERIS);
  constant("HERO_AINE",              H3M_HERO_AINE);
  constant("HERO_AISLINN",           H3M_HERO_AISLINN);
  constant("HERO_AJIT",              H3M_HERO_AJIT);
  constant("HERO_ALAGAR",            H3M_HERO_ALAGAR);
  constant("HERO_ALAMAR",            H3M_HERO_ALAMAR);
  constant("HERO_ALKIN",             H3M_HERO_ALKIN);
  constant("HERO_ANDRA",             H3M_HERO_ANDRA);
  constant("HERO_ARLACH",            H3M_HERO_ARLACH);
  constant("HERO_ASH",               H3M_HERO_ASH);
  constant("HERO_ASTRAL",            H3M_HERO_ASTRAL);
  constant("HERO_AXSIS",             H3M_HERO_AXSIS);
  constant("HERO_AYDEN",             H3M_HERO_AYDEN);
  // constant("HERO_BORAGUS",           H3M_HERO_BORAGUS);
  constant("HERO_BRISSA",            H3M_HERO_BRISSA);
  constant("HERO_BROGHILD",          H3M_HERO_BROGHILD);
  constant("HERO_BRON",              H3M_HERO_BRON);
  constant("HERO_CAITLIN",           H3M_HERO_CAITLIN);
  constant("HERO_CALH",              H3M_HERO_CALH);
  constant("HERO_CALID",             H3M_HERO_CALID);
  // constant("HERO_CATHERINE",         H3M_HERO_CATHERINE);
  constant("HERO_CHARNA",            H3M_HERO_CHARNA);
  constant("HERO_CHRISTIAN",         H3M_HERO_CHRISTIAN);
  constant("HERO_CIELE",             H3M_HERO_CIELE);
  constant("HERO_CLANCY",            H3M_HERO_CLANCY);
  constant("HERO_CLAVIUS",           H3M_HERO_CLAVIUS);
  constant("HERO_CONFLUX",           H3M_HERO_CONFLUX);
  constant("HERO_CORONIUS",          H3M_HERO_CORONIUS);
  constant("HERO_CRAG_HACK",         H3M_HERO_CRAG_HACK);
  constant("HERO_CUTHBERT",          H3M_HERO_CUTHBERT);
  constant("HERO_CYRA",              H3M_HERO_CYRA);
  constant("HERO_DACE",              H3M_HERO_DACE);
  constant("HERO_DAMACON",           H3M_HERO_DAMACON);
  constant("HERO_DAREMYTH",          H3M_HERO_DAREMYTH);
  constant("HERO_DARKSTORN",         H3M_HERO_DARKSTORN);
  constant("HERO_DEEMER",            H3M_HERO_DEEMER);
  constant("HERO_DESSA",             H3M_HERO_DESSA);
  // constant("HERO_DRACON",            H3M_HERO_DRACON);
  constant("HERO_DRAKON",            H3M_HERO_DRAKON);
  constant("HERO_EDRIC",             H3M_HERO_EDRIC);
  constant("HERO_ELLESHAR",          H3M_HERO_ELLESHAR);
  constant("HERO_ERDAMON",           H3M_HERO_ERDAMON);
  constant("HERO_FAFNER",            H3M_HERO_FAFNER);
  constant("HERO_FIONA",             H3M_HERO_FIONA);
  constant("HERO_FIUR",              H3M_HERO_FIUR);
  constant("HERO_GALTHRAN",          H3M_HERO_GALTHRAN);
  constant("HERO_GELARE",            H3M_HERO_GELARE);
  // constant("HERO_GELU",              H3M_HERO_GELU);
  constant("HERO_GEM",               H3M_HERO_GEM);
  constant("HERO_GEON",              H3M_HERO_GEON);
  constant("HERO_GERWULF",           H3M_HERO_GERWULF);
  constant("HERO_GIRD",              H3M_HERO_GIRD);
  constant("HERO_GRETCHIN",          H3M_HERO_GRETCHIN);
  constant("HERO_GRINDAN",           H3M_HERO_GRINDAN);
  constant("HERO_GUNDULA",           H3M_HERO_GUNDULA);
  constant("HERO_GUNNAR",            H3M_HERO_GUNNAR);
  constant("HERO_GURNISSON",         H3M_HERO_GURNISSON);
  constant("HERO_HALON",             H3M_HERO_HALON);
  constant("HERO_IGNATIUS",          H3M_HERO_IGNATIUS);
  constant("HERO_IGNISSA",           H3M_HERO_IGNISSA);
  constant("HERO_INGHAM",            H3M_HERO_INGHAM);
  constant("HERO_INTEUS",            H3M_HERO_INTEUS);
  constant("HERO_IONA",              H3M_HERO_IONA);
  constant("HERO_ISRA",              H3M_HERO_ISRA);
  constant("HERO_IVOR",              H3M_HERO_IVOR);
  constant("HERO_JABARKAS",          H3M_HERO_JABARKAS);
  constant("HERO_JAEGAR",            H3M_HERO_JAEGAR);
  constant("HERO_JEDDITE",           H3M_HERO_JEDDITE);
  constant("HERO_JENOVA",            H3M_HERO_JENOVA);
  constant("HERO_JOSEPHINE",         H3M_HERO_JOSEPHINE);
  constant("HERO_KALT",              H3M_HERO_KALT);
  // constant("HERO_KILGOR",            H3M_HERO_KILGOR);
  constant("HERO_KORBAC",            H3M_HERO_KORBAC);
  constant("HERO_KRELLION",          H3M_HERO_KRELLION);
  constant("HERO_KYRRE",             H3M_HERO_KYRRE);
  constant("HERO_LACUS",             H3M_HERO_LACUS);
  constant("HERO_LORD_HAART",        H3M_HERO_LORD_HAART);
  // constant("HERO_LORD_HAART2",       H3M_HERO_LORD_HAART2);
  constant("HERO_LORELEI",           H3M_HERO_LORELEI);
  constant("HERO_LOYNIS",            H3M_HERO_LOYNIS);
  constant("HERO_LUNA",              H3M_HERO_LUNA);
  constant("HERO_MALCOM",            H3M_HERO_MALCOM);
  constant("HERO_MALEKITH",          H3M_HERO_MALEKITH);
  constant("HERO_MARIUS",            H3M_HERO_MARIUS);
  constant("HERO_MELODIA",           H3M_HERO_MELODIA);
  constant("HERO_MEPHALA",           H3M_HERO_MEPHALA);
  constant("HERO_MERIST",            H3M_HERO_MERIST);
  constant("HERO_MIRLANDA",          H3M_HERO_MIRLANDA);
  constant("HERO_MOANDOR",           H3M_HERO_MOANDOR);
  constant("HERO_MONERE",            H3M_HERO_MONERE);
  // constant("HERO_MUTARE",            H3M_HERO_MUTARE);
  // constant("HERO_MUTARE_DRAKE",      H3M_HERO_MUTARE_DRAKE);
  constant("HERO_NAGASH",            H3M_HERO_NAGASH);
  constant("HERO_NEELA",             H3M_HERO_NEELA);
  constant("HERO_NIMBUS",            H3M_HERO_NIMBUS);
  constant("HERO_NYMUS",             H3M_HERO_NYMUS);
  constant("HERO_OCTAVIA",           H3M_HERO_OCTAVIA);
  constant("HERO_OLEMA",             H3M_HERO_OLEMA);
  constant("HERO_ORIS",              H3M_HERO_ORIS);
  constant("HERO_ORRIN",             H3M_HERO_ORRIN);
  constant("HERO_PASIS",             H3M_HERO_PASIS);
  constant("HERO_PIQUEDRAM",         H3M_HERO_PIQUEDRAM);
  constant("HERO_PYRE",              H3M_HERO_PYRE);
  constant("HERO_RASHKA",            H3M_HERO_RASHKA);
  constant("HERO_RION",              H3M_HERO_RION);
  constant("HERO_RISSA",             H3M_HERO_RISSA);
  // constant("HERO_ROLAND",            H3M_HERO_ROLAND);
  constant("HERO_ROSIC",             H3M_HERO_ROSIC);
  constant("HERO_RYLAND",            H3M_HERO_RYLAND);
  constant("HERO_SANDRO",            H3M_HERO_SANDRO);
  constant("HERO_SANYA",             H3M_HERO_SANYA);
  constant("HERO_SAURUG",            H3M_HERO_SAURUG);
  constant("HERO_SEPHINROTH",        H3M_HERO_SEPHINROTH);
  constant("HERO_SEPTIENNA",         H3M_HERO_SEPTIENNA);
  constant("HERO_SERENA",            H3M_HERO_SERENA);
  constant("HERO_SHAKTI",            H3M_HERO_SHAKTI);
  constant("HERO_SHIVA",             H3M_HERO_SHIVA);
  // constant("HERO_SIR_MULLICH",       H3M_HERO_SIR_MULLICH);
  constant("HERO_SOLMYR",            H3M_HERO_SOLMYR);
  constant("HERO_SORSHA",            H3M_HERO_SORSHA);
  constant("HERO_STRAKER",           H3M_HERO_STRAKER);
  constant("HERO_STYG",              H3M_HERO_STYG);
  constant("HERO_SYLVIA",            H3M_HERO_SYLVIA);
  constant("HERO_SYNCA",             H3M_HERO_SYNCA);
  constant("HERO_TAMIKA",            H3M_HERO_TAMIKA);
  constant("HERO_TAZAR",             H3M_HERO_TAZAR);
  constant("HERO_TEREK",             H3M_HERO_TEREK);
  constant("HERO_THANE",             H3M_HERO_THANE);
  constant("HERO_THANT",             H3M_HERO_THANT);
  constant("HERO_THEODORUS",         H3M_HERO_THEODORUS);
  constant("HERO_THORGRIM",          H3M_HERO_THORGRIM);
  constant("HERO_THUNAR",            H3M_HERO_THUNAR);
  constant("HERO_TIVA",              H3M_HERO_TIVA);
  constant("HERO_TOROSAR",           H3M_HERO_TOROSAR);
  constant("HERO_TYRAXOR",           H3M_HERO_TYRAXOR);
  constant("HERO_TYRIS",             H3M_HERO_TYRIS);
  constant("HERO_UFRETIN",           H3M_HERO_UFRETIN);
  constant("HERO_ULAND",             H3M_HERO_ULAND);
  constant("HERO_VALESKA",           H3M_HERO_VALESKA);
  constant("HERO_VERDISH",           H3M_HERO_VERDISH);
  constant("HERO_VEY",               H3M_HERO_VEY);
  constant("HERO_VIDOMINA",          H3M_HERO_VIDOMINA);
  constant("HERO_VOKIAL",            H3M_HERO_VOKIAL);
  constant("HERO_VOY",               H3M_HERO_VOY);
  constant("HERO_WYSTAN",            H3M_HERO_WYSTAN);
  constant("HERO_XARFAX",            H3M_HERO_XARFAX);
  // constant("HERO_XERON",             H3M_HERO_XERON);
  constant("HERO_XSI",               H3M_HERO_XSI);
  constant("HERO_XYRON",             H3M_HERO_XYRON);
  constant("HERO_YOG",               H3M_HERO_YOG);
  constant("HERO_ZUBIN",             H3M_HERO_ZUBIN);
  constant("HERO_ZYDAR",             H3M_HERO_ZYDAR);
  constant("OWNER_1",                0);
  constant("OWNER_2",                1);
  constant("OWNER_3",                2);
  constant("OWNER_4",                3);
  constant("OWNER_5",                4);
  constant("OWNER_6",                5);
  constant("OWNER_7",                6);
  constant("OWNER_8",                7);
  constant("OWNER_NEUTRAL",          -1);
  constant("PLAYER_1",               0);
  constant("PLAYER_2",               1);
  constant("PLAYER_3",               2);
  constant("PLAYER_4",               3);
  constant("PLAYER_5",               4);
  constant("PLAYER_6",               5);
  constant("PLAYER_7",               6);
  constant("PLAYER_8",               7);
  constant("SIZE_EXTRALARGE",        H3M_SIZE_EXTRALARGE);
  constant("SIZE_LARGE",             H3M_SIZE_LARGE);
  constant("SIZE_MEDIUM",            H3M_SIZE_MEDIUM);
  constant("SIZE_SMALL",             H3M_SIZE_SMALL);
  constant("TERRAIN_DIRT",           H3M_TERRAIN_DIRT);
  constant("TERRAIN_GRASS",          H3M_TERRAIN_GRASS);
  constant("TERRAIN_LAVA",           H3M_TERRAIN_LAVA);
  constant("TERRAIN_ROCK",           H3M_TERRAIN_ROCK);
  constant("TERRAIN_ROUGH",          H3M_TERRAIN_ROUGH);
  constant("TERRAIN_SAND",           H3M_TERRAIN_SAND);
  constant("TERRAIN_SNOW",           H3M_TERRAIN_SNOW);
  constant("TERRAIN_SUBTERRANEAN",   H3M_TERRAIN_SUBTERRANEAN);
  constant("TERRAIN_SWAMP",          H3M_TERRAIN_SWAMP);
  constant("TERRAIN_WATER",          H3M_TERRAIN_WATER);
#undef constant

#define literal(name, value) lua_pushstring(L, value); lua_setfield(L, -2, name);
  literal("ARTIFACT_ADMIRALS_HAT",                   "Admiral's Hat");
  literal("ARTIFACT_AMBASSADORS_SASH",               "Ambassador's Sash");
  literal("ARTIFACT_AMMO_CART",                      "Ammo Cart");
  literal("ARTIFACT_AMULET_OF_THE_UNDERTAKER",       "Amulet of the Undertaker");
  literal("ARTIFACT_ANGELIC_ALLIANCE",               "Angelic Alliance");
  literal("ARTIFACT_ANGEL_FEATHER_ARROWS",           "Angel Feather Arrows");
  literal("ARTIFACT_ANGEL_WINGS",                    "Angel Wings");
  literal("ARTIFACT_ARMAGEDDONS_BLADE",              "Armageddon's Blade");
  literal("ARTIFACT_ARMOR_OF_THE_DAMNED",            "Armor of the Damned");
  literal("ARTIFACT_ARMOR_OF_WONDER",                "Armor of Wonder");
  literal("ARTIFACT_ARMS_OF_LEGION",                 "Arms of Legion");
  literal("ARTIFACT_BADGE_OF_COURAGE",               "Badge of Courage");
  literal("ARTIFACT_BALLISTA",                       "Ballista");
  literal("ARTIFACT_BIRD_OF_PERCEPTION",             "Bird of Perception");
  literal("ARTIFACT_BLACKSHARD_OF_THE_DEAD_KNIGHT",  "Blackshard of the Dead Knight");
  literal("ARTIFACT_BOOTS_OF_LEVITATION",            "Boots of Levitation");
  literal("ARTIFACT_BOOTS_OF_POLARITY",              "Boots of Polarity");
  literal("ARTIFACT_BOOTS_OF_SPEED",                 "Boots of Speed");
  literal("ARTIFACT_BOWSTRING_OF_THE_UNICORNS_MANE", "Bowstring of the Unicorn's Mane");
  literal("ARTIFACT_BOW_OF_ELVEN_CHERRYWOOD",        "Bow of Elven Cherrywood");
  literal("ARTIFACT_BOW_OF_THE_SHARPSHOOTER",        "Bow of the Sharpshooter");
  literal("ARTIFACT_BREASTPLATE_OF_BRIMSTONE",       "Breastplate of Brimstone");
  literal("ARTIFACT_BREASTPLATE_OF_PETRIFIED_WOOD",  "Breastplate of Petrified Wood");
  literal("ARTIFACT_BUCKLER_OF_THE_GNOLL_KING",      "Buckler of the Gnoll King");
  literal("ARTIFACT_CAPE_OF_CONJURING",              "Cape of Conjuring");
  literal("ARTIFACT_CAPE_OF_VELOCITY",               "Cape of Velocity");
  literal("ARTIFACT_CARDS_OF_PROPHECY",              "Cards of Prophecy");
  literal("ARTIFACT_CATAPULT",                       "Catapult");
  literal("ARTIFACT_CELESTIAL_NECKLACE_OF_BLISS",    "Celestial Necklace of Bliss");
  literal("ARTIFACT_CENTAUR_AXE",                    "Centaur Axe");
  literal("ARTIFACT_CHARM_OF_MANA",                  "Charm of Mana");
  literal("ARTIFACT_CLOAK_OF_THE_UNDEAD_KING",       "Cloak of the Undead King");
  literal("ARTIFACT_CLOVER_OF_FORTUNE",              "Clover of Fortune");
  literal("ARTIFACT_COLLAR_OF_CONJURING",            "Collar of Conjuring");
  literal("ARTIFACT_CORNUCOPIA",                     "Cornucopia");
  literal("ARTIFACT_CREST_OF_VALOR",                 "Crest of Valor");
  literal("ARTIFACT_CROWN_OF_DRAGONTOOTH",           "Crown of Dragontooth");
  literal("ARTIFACT_CROWN_OF_THE_SUPREME_MAGI",      "Crown of the Supreme Magi");
  literal("ARTIFACT_DEAD_MANS_BOOTS",                "Dead Man's Boots");
  literal("ARTIFACT_DIPLOMATS_RING",                 "Diplomat's Ring");
  literal("ARTIFACT_DRAGONBONE_GREAVES",             "Dragonbone Greaves");
  literal("ARTIFACT_DRAGON_SCALE_ARMOR",             "Dragon Scale Armor");
  literal("ARTIFACT_DRAGON_SCALE_SHIELD",            "Dragon Scale Shield");
  literal("ARTIFACT_DRAGON_WING_TABARD",             "Dragon Wing Tabard");
  literal("ARTIFACT_ELIXIR_OF_LIFE",                 "Elixir of Life");
  literal("ARTIFACT_EMBLEM_OF_COGNIZANCE",           "Emblem of Cognizance");
  literal("ARTIFACT_ENDLESS_BAG_OF_GOLD",            "Endless Bag of Gold");
  literal("ARTIFACT_ENDLESS_PURSE_OF_GOLD",          "Endless Purse of Gold");
  literal("ARTIFACT_ENDLESS_SACK_OF_GOLD",           "Endless Sack of Gold");
  literal("ARTIFACT_EQUESTRIANS_GLOVES",             "Equestrian's Gloves");
  literal("ARTIFACT_EVERFLOWING_CRYSTAL_CLOAK",      "Everflowing Crystal Cloak");
  literal("ARTIFACT_EVERPOURING_VIAL_OF_MERCURY",    "Everpouring Vial of Mercury");
  literal("ARTIFACT_EVERSMOKING_RING_OF_SULFUR",     "Eversmoking Ring of Sulfur");
  literal("ARTIFACT_FIRST_AID_TENT",                 "First Aid Tent");
  literal("ARTIFACT_GARNITURE_OF_INTERFERENCE",      "Garniture of Interference");
  literal("ARTIFACT_GLYPH_OF_GALLANTRY",             "Glyph of Gallantry");
  literal("ARTIFACT_GOLDEN_BOW",                     "Golden Bow");
  literal("ARTIFACT_GRAIL",                          "Grail");
  literal("ARTIFACT_GREATER_GNOLLS_FLAIL",           "Greater Gnoll's Flail");
  literal("ARTIFACT_HEAD_OF_LEGION",                 "Head of Legion");
  literal("ARTIFACT_HELLSTORM_HELMET",               "Hellstorm Helmet");
  literal("ARTIFACT_HELM_OF_CHAOS",                  "Helm of Chaos");
  literal("ARTIFACT_HELM_OF_HEAVENLY_ENLIGHTENMENT", "Helm of Heavenly Enlightenment");
  literal("ARTIFACT_HELM_OF_THE_ALABASTER_UNICORN",  "Helm of the Alabaster Unicorn");
  literal("ARTIFACT_HOURGLASS_OF_THE_EVIL_HOUR",     "Hourglass of the Evil Hour");
  literal("ARTIFACT_INEXHAUSTIBLE_CART_OF_LUMBER",   "Inexhaustible Cart of Lumber");
  literal("ARTIFACT_INEXHAUSTIBLE_CART_OF_ORE",      "Inexhaustible Cart of Ore");
  literal("ARTIFACT_LADYBIRD_OF_LUCK",               "Ladybird of Luck");
  literal("ARTIFACT_LEGS_OF_LEGION",                 "Legs of Legion");
  literal("ARTIFACT_LIONS_SHIELD_OF_COURAGE",        "Lion's Shield of Courage");
  literal("ARTIFACT_LOINS_OF_LEGION",                "Loins of Legion");
  literal("ARTIFACT_MYSTIC_ORB_OF_MANA",             "Mystic Orb of Mana");
  literal("ARTIFACT_NECKLACE_OF_DRAGONTEETH",        "Necklace of Dragonteeth");
  literal("ARTIFACT_NECKLACE_OF_OCEAN_GUIDANCE",     "Necklace of Ocean Guidance");
  literal("ARTIFACT_NECKLACE_OF_SWIFTNESS",          "Necklace of Swiftness");
  literal("ARTIFACT_OGRES_CLUB_OF_HAVOC",            "Ogre's Club of Havoc");
  literal("ARTIFACT_ORB_OF_DRIVING_RAIN",            "Orb of Driving Rain");
  literal("ARTIFACT_ORB_OF_INHIBITION",              "Orb of Inhibition");
  literal("ARTIFACT_ORB_OF_SILT",                    "Orb of Silt");
  literal("ARTIFACT_ORB_OF_TEMPESTUOUS_FIRE",        "Orb of Tempestuous Fire");
  literal("ARTIFACT_ORB_OF_THE_FIRMAMENT",           "Orb of the Firmament");
  literal("ARTIFACT_ORB_OF_VULNERABILITY",           "Orb of Vulnerability");
  literal("ARTIFACT_PENDANT_OF_COURAGE",             "Pendant of Courage");
  literal("ARTIFACT_PENDANT_OF_DEATH",               "Pendant of Death");
  literal("ARTIFACT_PENDANT_OF_DISPASSION",          "Pendant of Dispassion");
  literal("ARTIFACT_PENDANT_OF_FREE_WILL",           "Pendant of Free Will");
  literal("ARTIFACT_PENDANT_OF_HOLINESS",            "Pendant of Holiness");
  literal("ARTIFACT_PENDANT_OF_LIFE",                "Pendant of Life");
  literal("ARTIFACT_PENDANT_OF_NEGATIVITY",          "Pendant of Negativity");
  literal("ARTIFACT_PENDANT_OF_SECOND_SIGHT",        "Pendant of Second Sight");
  literal("ARTIFACT_PENDANT_OF_TOTAL_RECALL",        "Pendant of Total Recall");
  literal("ARTIFACT_POWER_OF_THE_DRAGON_FATHER",     "Power of the Dragon Father");
  literal("ARTIFACT_QUIET_EYE_OF_THE_DRAGON",        "Quiet Eye of the Dragon");
  literal("ARTIFACT_RECANTERS_CLOAK",                "Recanter's Cloak");
  literal("ARTIFACT_RED_DRAGON_FLAME_TONGUE",        "Red Dragon Flame Tongue");
  literal("ARTIFACT_RIB_CAGE",                       "Rib Cage");
  literal("ARTIFACT_RING_OF_CONJURING",              "Ring of Conjuring");
  literal("ARTIFACT_RING_OF_INFINITE_GEMS",          "Ring of Infinite Gems");
  literal("ARTIFACT_RING_OF_LIFE",                   "Ring of Life");
  literal("ARTIFACT_RING_OF_THE_MAGI",               "Ring of the Magi");
  literal("ARTIFACT_RING_OF_THE_WAYFARER",           "Ring of the Wayfarer");
  literal("ARTIFACT_RING_OF_VITALITY",               "Ring of Vitality");
  literal("ARTIFACT_SANDALS_OF_THE_SAINT",           "Sandals of the Saint");
  literal("ARTIFACT_SCALES_OF_THE_GREATER_BASILISK", "Scales of the Greater Basilisk");
  literal("ARTIFACT_SEA_CAPTAINS_HAT",               "Sea Captain's Hat");
  literal("ARTIFACT_SENTINELS_SHIELD",               "Sentinel's Shield");
  literal("ARTIFACT_SHACKLES_OF_WAR",                "Shackles of War");
  literal("ARTIFACT_SHIELD_OF_THE_DAMNED",           "Shield of the Damned");
  literal("ARTIFACT_SHIELD_OF_THE_DWARVEN_LORDS",    "Shield of the Dwarven Lords");
  literal("ARTIFACT_SHIELD_OF_THE_YAWNING_DEAD",     "Shield of the Yawning Dead");
  literal("ARTIFACT_SKULL_HELMET",                   "Skull Helmet");
  literal("ARTIFACT_SPECULUM",                       "Speculum");
  literal("ARTIFACT_SPELLBINDERS_HAT",               "Spellbinder's Hat");
  literal("ARTIFACT_SPELL_BOOK",                     "Spell book");
  literal("ARTIFACT_SPELL_SCROLL",                   "Spell Scroll");
  literal("ARTIFACT_SPHERE_OF_PERMANENCE",           "Sphere of Permanence");
  literal("ARTIFACT_SPIRIT_OF_OPPRESSION",           "Spirit of Oppression");
  literal("ARTIFACT_SPYGLASS",                       "Spyglass");
  literal("ARTIFACT_STATESMANS_MEDAL",               "Statesman's Medal");
  literal("ARTIFACT_STATUE_OF_LEGION",               "Statue of Legion");
  literal("ARTIFACT_STILL_EYE_OF_THE_DRAGON",        "Still Eye of the Dragon");
  literal("ARTIFACT_STOIC_WATCHMAN",                 "Stoic Watchman");
  literal("ARTIFACT_SURCOAT_OF_COUNTERPOISE",        "Surcoat of Counterpoise");
  literal("ARTIFACT_SWORD_OF_HELLFIRE",              "Sword of Hellfire");
  literal("ARTIFACT_SWORD_OF_JUDGEMENT",             "Sword of Judgement");
  literal("ARTIFACT_TALISMAN_OF_MANA",               "Talisman of Mana");
  literal("ARTIFACT_TARG_OF_THE_RAMPAGING_OGRE",     "Targ of the Rampaging Ogre");
  literal("ARTIFACT_THUNDER_HELMET",                 "Thunder Helmet");
  literal("ARTIFACT_TITANS_CUIRASS",                 "Titan's Cuirass");
  literal("ARTIFACT_TITANS_GLADIUS",                 "Titan's Gladius");
  literal("ARTIFACT_TITANS_THUNDER",                 "Titan's Thunder");
  literal("ARTIFACT_TOME_OF_AIR_MAGIC",              "Tome of Air Magic");
  literal("ARTIFACT_TOME_OF_EARTH_MAGIC",            "Tome of Earth Magic");
  literal("ARTIFACT_TOME_OF_FIRE_MAGIC",             "Tome of Fire Magic");
  literal("ARTIFACT_TOME_OF_WATER_MAGIC",            "Tome of Water Magic");
  literal("ARTIFACT_TORSO_OF_LEGION",                "Torso of Legion");
  literal("ARTIFACT_TUNIC_OF_THE_CYCLOPS_KING",      "Tunic of the Cyclops King");
  literal("ARTIFACT_VAMPIRES_COWL",                  "Vampire's Cowl");
  literal("ARTIFACT_VIAL_OF_DRAGON_BLOOD",           "Vial of Dragon Blood");
  literal("ARTIFACT_VIAL_OF_LIFEBLOOD",              "Vial of Lifeblood");
  literal("ARTIFACT_WIZARDS_WELL",                   "Wizard's Well");
  literal("CREATURE_AIR_ELEMENTAL",                  "Air Elemental");
  literal("CREATURE_ANCIENT_BEHEMOTH",               "Ancient Behemoth");
  literal("CREATURE_ANGEL",                          "Angel");
  literal("CREATURE_ARCHANGEL",                      "Archangel");
  literal("CREATURE_ARCHER",                         "Archer");
  literal("CREATURE_ARCH_DEVIL",                     "Arch Devil");
  literal("CREATURE_ARCH_MAGE",                      "Arch Mage");
  literal("CREATURE_AZURE_DRAGON",                   "Azure Dragon");
  literal("CREATURE_BASILISK",                       "Basilisk");
  literal("CREATURE_BATTLE_DWARF",                   "Battle Dwarf");
  literal("CREATURE_BEHEMOTH",                       "Behemoth");
  literal("CREATURE_BEHOLDER",                       "Beholder");
  literal("CREATURE_BLACK_DRAGON",                   "Black Dragon");
  literal("CREATURE_BLACK_KNIGHT",                   "Black Knight");
  literal("CREATURE_BOAR",                           "Boar");
  literal("CREATURE_BONE_DRAGON",                    "Bone Dragon");
  literal("CREATURE_CAVALIER",                       "Cavalier");
  literal("CREATURE_CENTAUR",                        "Centaur");
  literal("CREATURE_CENTAUR_CAPTAIN",                "Centaur Captain");
  literal("CREATURE_CERBERUS",                       "Cerberus");
  literal("CREATURE_CHAMPION",                       "Champion");
  literal("CREATURE_CHAOS_HYDRA",                    "Chaos Hydra");
  literal("CREATURE_CRUSADER",                       "Crusader");
  literal("CREATURE_CRYSTAL_DRAGON",                 "Crystal Dragon");
  literal("CREATURE_CYCLOPS",                        "Cyclops");
  literal("CREATURE_CYCLOPS_KING",                   "Cyclops King");
  literal("CREATURE_DEMON",                          "Demon");
  literal("CREATURE_DENDROID_GUARD",                 "Dendroid Guard");
  literal("CREATURE_DENDROID_SOLDIER",               "Dendroid Soldier");
  literal("CREATURE_DEVIL",                          "Devil");
  literal("CREATURE_DIAMOND_GOLEM",                  "Diamond Golem");
  literal("CREATURE_DRAGON_FLY",                     "Dragon Fly");
  literal("CREATURE_DREAD_KNIGHT",                   "Dread Knight");
  literal("CREATURE_DWARF",                          "Dwarf");
  literal("CREATURE_EARTH_ELEMENTAL",                "Earth Elemental");
  literal("CREATURE_EFREETI",                        "Efreeti");
  literal("CREATURE_EFREET_SULTAN",                  "Efreet Sultan");
  literal("CREATURE_ENCHANTER",                      "Enchanter");
  literal("CREATURE_ENERGY_ELEMENTAL",               "Energy Elemental");
  literal("CREATURE_EVIL_EYE",                       "Evil Eye");
  literal("CREATURE_FAERIE_DRAGON",                  "Faerie Dragon");
  literal("CREATURE_FAMILIAR",                       "Familiar");
  literal("CREATURE_FIREBIRD",                       "Firebird");
  literal("CREATURE_FIRE_ELEMENTAL",                 "Fire Elemental");
  literal("CREATURE_GENIE",                          "Genie");
  literal("CREATURE_GHOST_DRAGON",                   "Ghost Dragon");
  literal("CREATURE_GIANT",                          "Giant");
  literal("CREATURE_GNOLL",                          "Gnoll");
  literal("CREATURE_GNOLL_MARAUDER",                 "Gnoll Marauder");
  literal("CREATURE_GOBLIN",                         "Goblin");
  literal("CREATURE_GOG",                            "Gog");
  literal("CREATURE_GOLD_DRAGON",                    "Gold Dragon");
  literal("CREATURE_GOLD_GOLEM",                     "Gold Golem");
  literal("CREATURE_GORGON",                         "Gorgon");
  literal("CREATURE_GRAND_ELF",                      "Grand Elf");
  literal("CREATURE_GREATER_BASILISK",               "Greater Basilisk");
  literal("CREATURE_GREEN_DRAGON",                   "Green Dragon");
  literal("CREATURE_GREMLIN",                        "Gremlin");
  literal("CREATURE_GRIFFIN",                        "Griffin");
  literal("CREATURE_HALBERDIER",                     "Halberdier");
  literal("CREATURE_HALFLING",                       "Halfling");
  literal("CREATURE_HARPY",                          "Harpy");
  literal("CREATURE_HARPY_HAG",                      "Harpy Hag");
  literal("CREATURE_HELL_HOUND",                     "Hell Hound");
  literal("CREATURE_HOBGOBLIN",                      "Hobgoblin");
  literal("CREATURE_HORNED_DEMON",                   "Horned Demon");
  literal("CREATURE_HYDRA",                          "Hydra");
  literal("CREATURE_ICE_ELEMENTAL",                  "Ice Elemental");
  literal("CREATURE_IMP",                            "Imp");
  literal("CREATURE_INFERNAL_TROGLODYTE",            "Infernal Troglodyte");
  literal("CREATURE_IRON_GOLEM",                     "Iron Golem");
  literal("CREATURE_LICH",                           "Lich");
  literal("CREATURE_LIZARDMAN",                      "Lizardman");
  literal("CREATURE_LIZARD_WARRIOR",                 "Lizard Warrior");
  literal("CREATURE_MAGE",                           "Mage");
  literal("CREATURE_MAGIC_ELEMENTAL",                "Magic Elemental");
  literal("CREATURE_MAGMA_ELEMENTAL",                "Magma Elemental");
  literal("CREATURE_MAGOG",                          "Magog");
  literal("CREATURE_MANTICORE",                      "Manticore");
  literal("CREATURE_MARKSMAN",                       "Marksman");
  literal("CREATURE_MASTER_GENIE",                   "Master Genie");
  literal("CREATURE_MASTER_GREMLIN",                 "Master Gremlin");
  literal("CREATURE_MEDUSA",                         "Medusa");
  literal("CREATURE_MEDUSA_QUEEN",                   "Medusa Queen");
  literal("CREATURE_MIGHTY_GORGON",                  "Mighty Gorgon");
  literal("CREATURE_MINOTAUR",                       "Minotaur");
  literal("CREATURE_MINOTAUR_KING",                  "Minotaur King");
  literal("CREATURE_MONK",                           "Monk");
  literal("CREATURE_MUMMY",                          "Mummy");
  literal("CREATURE_NAGA",                           "Naga");
  literal("CREATURE_NAGA_QUEEN",                     "Naga Queen");
  literal("CREATURE_NOMAD",                          "Nomad");
  literal("CREATURE_OBSIDIAN_GARGOYLE",              "Obsidian Gargoyle");
  literal("CREATURE_OGRE",                           "Ogre");
  literal("CREATURE_OGRE_MAGE",                      "Ogre Mage");
  literal("CREATURE_ORC",                            "Orc");
  literal("CREATURE_ORC_CHIEFTAIN",                  "Orc Chieftain");
  literal("CREATURE_PEASANT",                        "Peasant");
  literal("CREATURE_PEGASUS",                        "Pegasus");
  literal("CREATURE_PHOENIX",                        "Phoenix");
  literal("CREATURE_PIKEMAN",                        "Pikeman");
  literal("CREATURE_PIT_FIEND",                      "Pit Fiend");
  literal("CREATURE_PIT_LORD",                       "Pit Lord");
  literal("CREATURE_PIXIE",                          "Pixie");
  literal("CREATURE_POWER_LICH",                     "Power Lich");
  literal("CREATURE_PSYCHIC_ELEMENTAL",              "Psychic Elemental");
  literal("CREATURE_RED_DRAGON",                     "Red Dragon");
  literal("CREATURE_ROC",                            "Roc");
  literal("CREATURE_ROGUE",                          "Rogue");
  literal("CREATURE_ROYAL_GRIFFIN",                  "Royal Griffin");
  literal("CREATURE_RUST_DRAGON",                    "Rust Dragon");
  literal("CREATURE_SCORPICORE",                     "Scorpicore");
  literal("CREATURE_SERPENT_FLY",                    "Serpent Fly");
  literal("CREATURE_SHARPSHOOTER",                   "Sharpshooter");
  literal("CREATURE_SILVER_PEGASUS",                 "Silver Pegasus");
  literal("CREATURE_SKELETON",                       "Skeleton");
  literal("CREATURE_SKELETON_WARRIOR",               "Skeleton Warrior");
  literal("CREATURE_SPRITE",                         "Sprite");
  literal("CREATURE_STONE_GARGOYLE",                 "Stone Gargoyle");
  literal("CREATURE_STONE_GOLEM",                    "Stone Golem");
  literal("CREATURE_STORM_ELEMENTAL",                "Storm Elemental");
  literal("CREATURE_SWORDSMAN",                      "Swordsman");
  literal("CREATURE_THUNDERBIRD",                    "Thunderbird");
  literal("CREATURE_TITAN",                          "Titan");
  literal("CREATURE_TROGLODYTE",                     "Troglodyte");
  literal("CREATURE_TROLL",                          "Troll");
  literal("CREATURE_UNICORN",                        "Unicorn");
  literal("CREATURE_VAMPIRE",                        "Vampire");
  literal("CREATURE_VAMPIRE_LORD",                   "Vampire Lord");
  literal("CREATURE_WALKING_DEAD",                   "Walking Dead");
  literal("CREATURE_WAR_UNICORN",                    "War Unicorn");
  literal("CREATURE_WATER_ELEMENTAL",                "Water Elemental");
  literal("CREATURE_WIGHT",                          "Wight");
  literal("CREATURE_WOLF_RAIDER",                    "Wolf Raider");
  literal("CREATURE_WOLF_RIDER",                     "Wolf Rider");
  literal("CREATURE_WOOD_ELF",                       "Wood Elf");
  literal("CREATURE_WRAITH",                         "Wraith");
  literal("CREATURE_WYVERN",                         "Wyvern");
  literal("CREATURE_WYVERN_MONARCH",                 "Wyvern Monarch");
  literal("CREATURE_ZEALOT",                         "Zealot");
  literal("CREATURE_ZOMBIE",                         "Zombie");
  literal("MINE_ABANDONED_MINE",                     "Abandoned Mine");
  literal("MINE_ALCHEMISTS_LAB",                     "Alchemist's Lab");
  literal("MINE_CRYSTAL_CAVERN",                     "Crystal Cavern");
  literal("MINE_GEM_POND",                           "Gem Pond");
  literal("MINE_GOLD_MINE",                          "Gold Mine");
  literal("MINE_ORE_PIT",                            "Ore Pit");
  literal("MINE_SAWMILL",                            "Sawmill");
  literal("MINE_SULFUR_DUNE",                        "Sulfur Dune");
  literal("RESOURCE_CRYSTAL",                        "Crystal");
  literal("RESOURCE_GEMS",                           "Gems");
  literal("RESOURCE_GOLD",                           "Gold");
  literal("RESOURCE_MERCURY",                        "Mercury");
  literal("RESOURCE_ORE",                            "Ore");
  literal("RESOURCE_SULFUR",                         "Sulfur");
  literal("RESOURCE_WOOD",                           "Wood");
  literal("TOWN_CASTLE",                             "Castle");
  literal("TOWN_DUNGEON",                            "Dungeon");
  literal("TOWN_FORTRESS",                           "Fortress");
  literal("TOWN_INFERNO",                            "Inferno");
  literal("TOWN_NECROPOLIS",                         "Necropolis");
  literal("TOWN_RAMPART",                            "Rampart");
  literal("TOWN_RANDOM",                             "Random Town");
  literal("TOWN_STRONGHOLD",                         "Stronghold");
  literal("TOWN_TOWER",                              "Tower");
#undef literal

  return 1;
}
