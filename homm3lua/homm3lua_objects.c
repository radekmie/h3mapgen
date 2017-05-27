#include "homm3lua_objects.h"

void h3m_difficulty_set(h3mlib_ctx_t ctx, uint8_t difficulty) {
  ctx->h3m.bi.any.difficulty = difficulty;
}

int h3m_object_set_does_not_grow (h3mlib_ctx_t ctx, int od_index, int does_not_grow) {
  struct  H3M_OD_ENTRY  *h3m_od_entry = &ctx-> h3m.od.entries[od_index];
  struct META_OD_ENTRY *meta_od_entry = &ctx->meta.od_entries[od_index];

  uint8_t *body = h3m_od_entry->body;

  if (META_OBJECT_MONSTER != meta_od_entry->oa_type) {
      return 1;
  }

  ((struct H3M_OD_BODY_STATIC_MONSTER *)body)->does_not_grow = does_not_grow;

  return 0;
}

int h3m_object_set_never_flees (h3mlib_ctx_t ctx, int od_index, int never_flees) {
  struct  H3M_OD_ENTRY  *h3m_od_entry = &ctx-> h3m.od.entries[od_index];
  struct META_OD_ENTRY *meta_od_entry = &ctx->meta.od_entries[od_index];

  uint8_t *body = h3m_od_entry->body;

  if (META_OBJECT_MONSTER != meta_od_entry->oa_type) {
      return 1;
  }

  ((struct H3M_OD_BODY_STATIC_MONSTER *)body)->never_flees = never_flees;

  return 0;
}
