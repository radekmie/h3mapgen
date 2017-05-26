-- Either set it here or in LUA_CPATH
package.cpath = package.cpath .. ';dist/?.so;../dist/?.so'

-- Yay!
local homm3lua = require('homm3lua')
local homm3luaInstance = homm3lua.new('H3M_FORMAT_ROE', 'H3M_SIZE_SMALL')

homm3luaInstance:fill('H3M_TERRAIN_LAVA')
homm3luaInstance:mobs('Stone Gargoyle', 3, 15, 0, 45, 'H3M_DISPOSITION_AGGRESSIVE', true, true)
homm3luaInstance:mobs('Stone Gargoyle', 3, 16, 0, 45, 'H3M_DISPOSITION_COMPLIANT', true, false)
homm3luaInstance:mobs('Stone Gargoyle', 3, 17, 0, 45, 'H3M_DISPOSITION_FRIENDLY', false, true)
homm3luaInstance:mobs('Stone Gargoyle', 3, 18, 0, 45, 'H3M_DISPOSITION_HOSTILE', false, false)
homm3luaInstance:mobs('Stone Gargoyle', 3, 19, 0, 0, 'H3M_DISPOSITION_SAVAGE', true, false) -- Random quantity
homm3luaInstance:text('HELLO', 3, 2, 0, 'Pandora\'s Box')
homm3luaInstance:text('WORLD', 3, 9, 0, 'Master Gremlin')
homm3luaInstance:save('test.h3m')
