-- Either set it here or in LUA_CPATH
package.cpath = package.cpath .. ';dist/?.so;../dist/?.so'

-- Yay!
local homm3lua = require('homm3lua')
local homm3luaInstance = homm3lua.new('H3M_FORMAT_ROE', 'H3M_SIZE_SMALL')

homm3luaInstance:fill('H3M_TERRAIN_LAVA')
homm3luaInstance:text('HELLO', 3, 2, 0, 'Pandora\'s Box')
homm3luaInstance:text('WORLD', 3, 9, 0, 'Master Gremlin')
homm3luaInstance:save('test.h3m')
