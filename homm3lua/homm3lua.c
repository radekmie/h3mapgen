#include <h3mlib.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

static int test (lua_State *L) {
  const char *path = luaL_checkstring(L, 1);

  h3mlib_ctx_t h3m = NULL;
  uint8_t terrain[H3M_SIZE_SMALL * H3M_SIZE_SMALL] = { 0 };

  // Init a S size RoE map with standard settings
  h3m_init_min(&h3m, H3M_FORMAT_ROE, H3M_SIZE_SMALL);

  // Fill map with lava terrain and "write" HELLO WORLD using objects
  h3m_terrain_fill(h3m, H3M_TERRAIN_LAVA);
  h3m_object_text(h3m, "Pandora's Box", 3, 2, 0, "HELLO");
  h3m_object_text(h3m, "Master Gremlin", 3, 9, 0, "WORLD");

  // Set terrain background under HELLO to grass, WORLD to snow
  h3m_terrain_get_all(h3m, 0, terrain, sizeof(terrain));
  for (int x = 2; x < H3M_SIZE_SMALL - 4; ++x) {
      for (int y = 1; y < 8; ++y) {
          terrain[H3M_2D_TO_1D(H3M_SIZE_SMALL, x, y, 0)] = H3M_TERRAIN_GRASS;
      }

      for (int y = 8; y < 15; ++y) {
          terrain[H3M_2D_TO_1D(H3M_SIZE_SMALL, x, y, 0)] = H3M_TERRAIN_SNOW;
      }
  }

  h3m_terrain_set_all(h3m, 0, terrain);

  // Write map and cleanup
  h3m_write(h3m, path);
  h3m_exit(&h3m);

  return 0;
}

static const struct luaL_Reg homm3lua[] = {
  {"test", test},
  {NULL, NULL}
};

int luaopen_homm3lua (lua_State *L) {
  luaL_newlib(L, homm3lua);
  return 1;
}
