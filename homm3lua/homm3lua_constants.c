#include "homm3lua_constants.h"

int h3mlua_check_class (lua_State *L, int arg) {
  const char *class = luaL_checkstring(L, arg);

  if (strcmp(class, "Adela")        == 0) return H3M_HERO_ADELA;
  if (strcmp(class, "Adelaide")     == 0) return H3M_HERO_ADELAIDE;
  if (strcmp(class, "Adrienne")     == 0) return H3M_HERO_ADRIENNE;
  if (strcmp(class, "Aenain")       == 0) return H3M_HERO_AENAIN;
  if (strcmp(class, "Aeris")        == 0) return H3M_HERO_AERIS;
  if (strcmp(class, "Aine")         == 0) return H3M_HERO_AINE;
  if (strcmp(class, "Aislinn")      == 0) return H3M_HERO_AISLINN;
  if (strcmp(class, "Ajit")         == 0) return H3M_HERO_AJIT;
  if (strcmp(class, "Alagar")       == 0) return H3M_HERO_ALAGAR;
  if (strcmp(class, "Alamar")       == 0) return H3M_HERO_ALAMAR;
  if (strcmp(class, "Alkin")        == 0) return H3M_HERO_ALKIN;
  if (strcmp(class, "Andra")        == 0) return H3M_HERO_ANDRA;
  if (strcmp(class, "Arlach")       == 0) return H3M_HERO_ARLACH;
  if (strcmp(class, "Ash")          == 0) return H3M_HERO_ASH;
  if (strcmp(class, "Astral")       == 0) return H3M_HERO_ASTRAL;
  if (strcmp(class, "Axsis")        == 0) return H3M_HERO_AXSIS;
  if (strcmp(class, "Ayden")        == 0) return H3M_HERO_AYDEN;
  if (strcmp(class, "Boragus")      == 0) return H3M_HERO_BORAGUS;
  if (strcmp(class, "Brissa")       == 0) return H3M_HERO_BRISSA;
  if (strcmp(class, "Broghild")     == 0) return H3M_HERO_BROGHILD;
  if (strcmp(class, "Bron")         == 0) return H3M_HERO_BRON;
  if (strcmp(class, "Caitlin")      == 0) return H3M_HERO_CAITLIN;
  if (strcmp(class, "Calh")         == 0) return H3M_HERO_CALH;
  if (strcmp(class, "Calid")        == 0) return H3M_HERO_CALID;
  if (strcmp(class, "Catherine")    == 0) return H3M_HERO_CATHERINE;
  if (strcmp(class, "Charna")       == 0) return H3M_HERO_CHARNA;
  if (strcmp(class, "Christian")    == 0) return H3M_HERO_CHRISTIAN;
  if (strcmp(class, "Ciele")        == 0) return H3M_HERO_CIELE;
  if (strcmp(class, "Clancy")       == 0) return H3M_HERO_CLANCY;
  if (strcmp(class, "Clavius")      == 0) return H3M_HERO_CLAVIUS;
  if (strcmp(class, "Conflux")      == 0) return H3M_HERO_CONFLUX;
  if (strcmp(class, "Coronius")     == 0) return H3M_HERO_CORONIUS;
  if (strcmp(class, "Crag Hack")    == 0) return H3M_HERO_CRAG_HACK;
  if (strcmp(class, "Cuthbert")     == 0) return H3M_HERO_CUTHBERT;
  if (strcmp(class, "Cyra")         == 0) return H3M_HERO_CYRA;
  if (strcmp(class, "Dace")         == 0) return H3M_HERO_DACE;
  if (strcmp(class, "Damacon")      == 0) return H3M_HERO_DAMACON;
  if (strcmp(class, "Daremyth")     == 0) return H3M_HERO_DAREMYTH;
  if (strcmp(class, "Darkstorn")    == 0) return H3M_HERO_DARKSTORN;
  if (strcmp(class, "Deemer")       == 0) return H3M_HERO_DEEMER;
  if (strcmp(class, "Dessa")        == 0) return H3M_HERO_DESSA;
  if (strcmp(class, "Dracon")       == 0) return H3M_HERO_DRACON;
  if (strcmp(class, "Drakon")       == 0) return H3M_HERO_DRAKON;
  if (strcmp(class, "Edric")        == 0) return H3M_HERO_EDRIC;
  if (strcmp(class, "Elleshar")     == 0) return H3M_HERO_ELLESHAR;
  if (strcmp(class, "Erdamon")      == 0) return H3M_HERO_ERDAMON;
  if (strcmp(class, "Fafner")       == 0) return H3M_HERO_FAFNER;
  if (strcmp(class, "Fiona")        == 0) return H3M_HERO_FIONA;
  if (strcmp(class, "Fiur")         == 0) return H3M_HERO_FIUR;
  if (strcmp(class, "Galthran")     == 0) return H3M_HERO_GALTHRAN;
  if (strcmp(class, "Gelare")       == 0) return H3M_HERO_GELARE;
  if (strcmp(class, "Gelu")         == 0) return H3M_HERO_GELU;
  if (strcmp(class, "Gem")          == 0) return H3M_HERO_GEM;
  if (strcmp(class, "Geon")         == 0) return H3M_HERO_GEON;
  if (strcmp(class, "Gerwulf")      == 0) return H3M_HERO_GERWULF;
  if (strcmp(class, "Gird")         == 0) return H3M_HERO_GIRD;
  if (strcmp(class, "Gretchin")     == 0) return H3M_HERO_GRETCHIN;
  if (strcmp(class, "Grindan")      == 0) return H3M_HERO_GRINDAN;
  if (strcmp(class, "Gundula")      == 0) return H3M_HERO_GUNDULA;
  if (strcmp(class, "Gunnar")       == 0) return H3M_HERO_GUNNAR;
  if (strcmp(class, "Gurnisson")    == 0) return H3M_HERO_GURNISSON;
  if (strcmp(class, "Halon")        == 0) return H3M_HERO_HALON;
  if (strcmp(class, "Ignatius")     == 0) return H3M_HERO_IGNATIUS;
  if (strcmp(class, "Ignissa")      == 0) return H3M_HERO_IGNISSA;
  if (strcmp(class, "Ingham")       == 0) return H3M_HERO_INGHAM;
  if (strcmp(class, "Inteus")       == 0) return H3M_HERO_INTEUS;
  if (strcmp(class, "Iona")         == 0) return H3M_HERO_IONA;
  if (strcmp(class, "Isra")         == 0) return H3M_HERO_ISRA;
  if (strcmp(class, "Ivor")         == 0) return H3M_HERO_IVOR;
  if (strcmp(class, "Jabarkas")     == 0) return H3M_HERO_JABARKAS;
  if (strcmp(class, "Jaegar")       == 0) return H3M_HERO_JAEGAR;
  if (strcmp(class, "Jeddite")      == 0) return H3M_HERO_JEDDITE;
  if (strcmp(class, "Jenova")       == 0) return H3M_HERO_JENOVA;
  if (strcmp(class, "Josephine")    == 0) return H3M_HERO_JOSEPHINE;
  if (strcmp(class, "Kalt")         == 0) return H3M_HERO_KALT;
  if (strcmp(class, "Kilgor")       == 0) return H3M_HERO_KILGOR;
  if (strcmp(class, "Korbac")       == 0) return H3M_HERO_KORBAC;
  if (strcmp(class, "Krellion")     == 0) return H3M_HERO_KRELLION;
  if (strcmp(class, "Kyrre")        == 0) return H3M_HERO_KYRRE;
  if (strcmp(class, "Lacus")        == 0) return H3M_HERO_LACUS;
  if (strcmp(class, "Lord Haart")   == 0) return H3M_HERO_LORD_HAART;
  if (strcmp(class, "Lord Haart2")  == 0) return H3M_HERO_LORD_HAART2;
  if (strcmp(class, "Lorelei")      == 0) return H3M_HERO_LORELEI;
  if (strcmp(class, "Loynis")       == 0) return H3M_HERO_LOYNIS;
  if (strcmp(class, "Luna")         == 0) return H3M_HERO_LUNA;
  if (strcmp(class, "Malcom")       == 0) return H3M_HERO_MALCOM;
  if (strcmp(class, "Malekith")     == 0) return H3M_HERO_MALEKITH;
  if (strcmp(class, "Marius")       == 0) return H3M_HERO_MARIUS;
  if (strcmp(class, "Melodia")      == 0) return H3M_HERO_MELODIA;
  if (strcmp(class, "Mephala")      == 0) return H3M_HERO_MEPHALA;
  if (strcmp(class, "Merist")       == 0) return H3M_HERO_MERIST;
  if (strcmp(class, "Mirlanda")     == 0) return H3M_HERO_MIRLANDA;
  if (strcmp(class, "Moandor")      == 0) return H3M_HERO_MOANDOR;
  if (strcmp(class, "Monere")       == 0) return H3M_HERO_MONERE;
  if (strcmp(class, "Mutare")       == 0) return H3M_HERO_MUTARE;
  if (strcmp(class, "Mutare Drake") == 0) return H3M_HERO_MUTARE_DRAKE;
  if (strcmp(class, "Nagash")       == 0) return H3M_HERO_NAGASH;
  if (strcmp(class, "Neela")        == 0) return H3M_HERO_NEELA;
  if (strcmp(class, "Nimbus")       == 0) return H3M_HERO_NIMBUS;
  if (strcmp(class, "Nymus")        == 0) return H3M_HERO_NYMUS;
  if (strcmp(class, "Octavia")      == 0) return H3M_HERO_OCTAVIA;
  if (strcmp(class, "Olema")        == 0) return H3M_HERO_OLEMA;
  if (strcmp(class, "Oris")         == 0) return H3M_HERO_ORIS;
  if (strcmp(class, "Orrin")        == 0) return H3M_HERO_ORRIN;
  if (strcmp(class, "Pasis")        == 0) return H3M_HERO_PASIS;
  if (strcmp(class, "Piquedram")    == 0) return H3M_HERO_PIQUEDRAM;
  if (strcmp(class, "Pyre")         == 0) return H3M_HERO_PYRE;
  if (strcmp(class, "Rashka")       == 0) return H3M_HERO_RASHKA;
  if (strcmp(class, "Rion")         == 0) return H3M_HERO_RION;
  if (strcmp(class, "Rissa")        == 0) return H3M_HERO_RISSA;
  if (strcmp(class, "Roland")       == 0) return H3M_HERO_ROLAND;
  if (strcmp(class, "Rosic")        == 0) return H3M_HERO_ROSIC;
  if (strcmp(class, "Ryland")       == 0) return H3M_HERO_RYLAND;
  if (strcmp(class, "Sandro")       == 0) return H3M_HERO_SANDRO;
  if (strcmp(class, "Sanya")        == 0) return H3M_HERO_SANYA;
  if (strcmp(class, "Saurug")       == 0) return H3M_HERO_SAURUG;
  if (strcmp(class, "Sephinroth")   == 0) return H3M_HERO_SEPHINROTH;
  if (strcmp(class, "Septienna")    == 0) return H3M_HERO_SEPTIENNA;
  if (strcmp(class, "Serena")       == 0) return H3M_HERO_SERENA;
  if (strcmp(class, "Shakti")       == 0) return H3M_HERO_SHAKTI;
  if (strcmp(class, "Shiva")        == 0) return H3M_HERO_SHIVA;
  if (strcmp(class, "Sir Mullich")  == 0) return H3M_HERO_SIR_MULLICH;
  if (strcmp(class, "Solmyr")       == 0) return H3M_HERO_SOLMYR;
  if (strcmp(class, "Sorsha")       == 0) return H3M_HERO_SORSHA;
  if (strcmp(class, "Straker")      == 0) return H3M_HERO_STRAKER;
  if (strcmp(class, "Styg")         == 0) return H3M_HERO_STYG;
  if (strcmp(class, "Sylvia")       == 0) return H3M_HERO_SYLVIA;
  if (strcmp(class, "Synca")        == 0) return H3M_HERO_SYNCA;
  if (strcmp(class, "Tamika")       == 0) return H3M_HERO_TAMIKA;
  if (strcmp(class, "Tazar")        == 0) return H3M_HERO_TAZAR;
  if (strcmp(class, "Terek")        == 0) return H3M_HERO_TEREK;
  if (strcmp(class, "Thane")        == 0) return H3M_HERO_THANE;
  if (strcmp(class, "Thant")        == 0) return H3M_HERO_THANT;
  if (strcmp(class, "Theodorus")    == 0) return H3M_HERO_THEODORUS;
  if (strcmp(class, "Thorgrim")     == 0) return H3M_HERO_THORGRIM;
  if (strcmp(class, "Thunar")       == 0) return H3M_HERO_THUNAR;
  if (strcmp(class, "Tiva")         == 0) return H3M_HERO_TIVA;
  if (strcmp(class, "Torosar")      == 0) return H3M_HERO_TOROSAR;
  if (strcmp(class, "Tyraxor")      == 0) return H3M_HERO_TYRAXOR;
  if (strcmp(class, "Tyris")        == 0) return H3M_HERO_TYRIS;
  if (strcmp(class, "Ufretin")      == 0) return H3M_HERO_UFRETIN;
  if (strcmp(class, "Uland")        == 0) return H3M_HERO_ULAND;
  if (strcmp(class, "Valeska")      == 0) return H3M_HERO_VALESKA;
  if (strcmp(class, "Verdish")      == 0) return H3M_HERO_VERDISH;
  if (strcmp(class, "Vey")          == 0) return H3M_HERO_VEY;
  if (strcmp(class, "Vidomina")     == 0) return H3M_HERO_VIDOMINA;
  if (strcmp(class, "Vokial")       == 0) return H3M_HERO_VOKIAL;
  if (strcmp(class, "Voy")          == 0) return H3M_HERO_VOY;
  if (strcmp(class, "Wystan")       == 0) return H3M_HERO_WYSTAN;
  if (strcmp(class, "Xarfax")       == 0) return H3M_HERO_XARFAX;
  if (strcmp(class, "Xeron")        == 0) return H3M_HERO_XERON;
  if (strcmp(class, "Xsi")          == 0) return H3M_HERO_XSI;
  if (strcmp(class, "Xyron")        == 0) return H3M_HERO_XYRON;
  if (strcmp(class, "Yog")          == 0) return H3M_HERO_YOG;
  if (strcmp(class, "Zubin")        == 0) return H3M_HERO_ZUBIN;
  if (strcmp(class, "Zydar")        == 0) return H3M_HERO_ZYDAR;

  return luaL_error(L, "Invalid class %s.", class);
}

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
