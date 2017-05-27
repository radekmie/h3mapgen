-- Either set it here or in LUA_CPATH
package.cpath = package.cpath .. ';dist/?.so;../dist/?.so'

-- Yay!
local homm3lua = require('homm3lua')
local homm3luaInstance = homm3lua.new('H3M_FORMAT_ROE', 'H3M_SIZE_SMALL')

homm3luaInstance:name('Test of homm3lua')
homm3luaInstance:description('Example of everything we can do with homm3lua (at the moment).')
homm3luaInstance:difficulty(4)
homm3luaInstance:player(0)
homm3luaInstance:player(1)
homm3luaInstance:fill('H3M_TERRAIN_LAVA')
homm3luaInstance:creature('Archangel', 3, 15, 0, 45, 'H3M_DISPOSITION_AGGRESSIVE', true, true)
homm3luaInstance:creature('Archangel', 3, 16, 0, 45, 'H3M_DISPOSITION_COMPLIANT', true, false)
homm3luaInstance:creature('Archangel', 3, 17, 0, 45, 'H3M_DISPOSITION_FRIENDLY', false, true)
homm3luaInstance:creature('Archangel', 3, 18, 0, 45, 'H3M_DISPOSITION_HOSTILE', false, false)
homm3luaInstance:creature('Archangel', 3, 19, 0, 0, 'H3M_DISPOSITION_SAVAGE', true, false) -- Random quantity
homm3luaInstance:town('Castle', 3, 3, 0, 0)
homm3luaInstance:hero('Christian', 2, 4, 0, 0)
homm3luaInstance:town('Rampart', 7, 3, 0, 1)
homm3luaInstance:hero('Jenova', 6, 4, 0, 1)
homm3luaInstance:town('Tower', 11, 3, 0, 2)
homm3luaInstance:hero('Fafner', 10, 4, 0, 2)
homm3luaInstance:town('Inferno', 15, 3, 0, 3)
homm3luaInstance:hero('Calh', 14, 4, 0, 3)
homm3luaInstance:town('Necropolis', 19, 3, 0, 4)
homm3luaInstance:hero('Charna', 18, 4, 0, 4)
homm3luaInstance:town('Dungeon', 23, 3, 0, 5)
homm3luaInstance:hero('Ajit', 22, 4, 0, 5)
-- homm3luaInstance:town('Stronghold', 27, 3, 0, 6) -- https://github.com/potmdehex/homm3tools/issues/26
homm3luaInstance:hero('Crag Hack', 26, 4, 0, 6)
-- homm3luaInstance:town('Fortress', 31, 3, 0, 7)   -- https://github.com/potmdehex/homm3tools/issues/26
homm3luaInstance:hero('Alkin', 30, 4, 0, 7)
homm3luaInstance:town('Random Town', 35, 3, 0, -1)
homm3luaInstance:text('HELLO', 4, 5, 0, 'Pandora\'s Box')
homm3luaInstance:text('WORLD', 3, 10, 0, 'Master Gremlin')
homm3luaInstance:write('test.h3m')
