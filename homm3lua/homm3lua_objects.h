#ifndef __H3MLUA_OBJECTS_H_DEF__
#define __H3MLUA_OBJECTS_H_DEF__

#include <h3mlib.h>
#include <internal/h3mlib_ctx.h>

int h3m_object_set_does_not_grow (h3mlib_ctx_t ctx, int od_index, int does_not_grow);
int h3m_object_set_never_flees   (h3mlib_ctx_t ctx, int od_index, int never_flees);

#endif
