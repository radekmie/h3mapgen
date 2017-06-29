#ifndef __H3MLUA_H3M_H_DEF__
#define __H3MLUA_H3M_H_DEF__

#include <h3mlib.h>
#include <internal/h3mlib_ctx.h>

void h3m_difficulty_set (h3mlib_ctx_t ctx, uint8_t difficulty);

int h3m_object_set_does_not_grow (h3mlib_ctx_t ctx, int od_index, int does_not_grow);
int h3m_object_set_never_flees   (h3mlib_ctx_t ctx, int od_index, int never_flees);

#endif
