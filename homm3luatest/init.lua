-- Either set it here or in LUA_CPATH
package.cpath = package.cpath .. ';dist/?.so;../dist/?.so'

-- Yay!
local homm3lua = require('homm3lua')
local homm3luaInstance = homm3lua.new('H3M_FORMAT_ROE', 'H3M_SIZE_SMALL')

homm3luaInstance:fill('H3M_TERRAIN_LAVA')
homm3luaInstance:creature('Archangel', 3, 15, 0, 45, 'H3M_DISPOSITION_AGGRESSIVE', true, true)
homm3luaInstance:creature('Archangel', 3, 16, 0, 45, 'H3M_DISPOSITION_COMPLIANT', true, false)
homm3luaInstance:creature('Archangel', 3, 17, 0, 45, 'H3M_DISPOSITION_FRIENDLY', false, true)
homm3luaInstance:creature('Archangel', 3, 18, 0, 45, 'H3M_DISPOSITION_HOSTILE', false, false)
homm3luaInstance:creature('Archangel', 3, 19, 0, 0, 'H3M_DISPOSITION_SAVAGE', true, false) -- Random quantity
homm3luaInstance:town('Castle', 3, 3, 0, 0)
homm3luaInstance:town('Rampart', 7, 3, 0, 1)
homm3luaInstance:town('Tower', 11, 3, 0, 2)
homm3luaInstance:town('Inferno', 15, 3, 0, 3)
homm3luaInstance:town('Necropolis', 19, 3, 0, 4)
homm3luaInstance:town('Dungeon', 23, 3, 0, 5)
-- homm3luaInstance:town('Stronghold', 27, 3, 0, 6) -- https://github.com/potmdehex/homm3tools/issues/26
-- homm3luaInstance:town('Fortress', 31, 3, 0, 7)   -- https://github.com/potmdehex/homm3tools/issues/26
homm3luaInstance:town('Random Town', 35, 3, 0, -1)
homm3luaInstance:text('HELLO', 3, 2, 0, 'Pandora\'s Box')
homm3luaInstance:text('WORLD', 3, 9, 0, 'Master Gremlin')
homm3luaInstance:write('test.h3m')
