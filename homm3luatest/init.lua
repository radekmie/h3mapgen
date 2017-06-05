-- Either set it here or in LUA_CPATH
package.cpath = package.cpath .. ';dist/?.so;../dist/?.so'

-- Yay!
local homm3lua = require('homm3lua')
local instance = homm3lua.new(homm3lua.FORMAT_ROE, homm3lua.SIZE_MEDIUM)

instance:name('Test of homm3lua')
instance:description('Example of everything we can do with homm3lua (at the moment).')
instance:difficulty(homm3lua.DIFFICULTY_IMPOSSIBLE)
instance:player(homm3lua.PLAYER_1)
instance:player(homm3lua.PLAYER_2)
instance:terrain(homm3lua.TERRAIN_SNOW)
instance:terrain(function (x, y, z, current) if x > 50 or y > 50 then return current end return (x // 6 + y // 3 + z) % 10 end)
instance:creature(homm3lua.CREATURE_ARCHANGEL, {x=3, y=15, z=0}, 45, homm3lua.DISPOSITION_AGGRESSIVE, true, true)
instance:creature(homm3lua.CREATURE_ARCHANGEL, {x=3, y=15, z=0}, 45, homm3lua.DISPOSITION_AGGRESSIVE, true, true)
instance:creature(homm3lua.CREATURE_ARCHANGEL, {x=3, y=16, z=0}, 45, homm3lua.DISPOSITION_COMPLIANT, true, false)
instance:creature(homm3lua.CREATURE_ARCHANGEL, {x=3, y=17, z=0}, 45, homm3lua.DISPOSITION_FRIENDLY, false, true)
instance:creature(homm3lua.CREATURE_ARCHANGEL, {x=3, y=18, z=0}, 45, homm3lua.DISPOSITION_HOSTILE, false, false)
instance:creature(homm3lua.CREATURE_ARCHANGEL, {x=3, y=19, z=0}, 0, homm3lua.DISPOSITION_SAVAGE, true, false) -- Random quantity
instance:mine(homm3lua.MINE_SAWMILL, {x=7, y=17, z=0}, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_ALCHEMISTS_LAB, {x=10, y=17, z=0}, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_ORE_PIT, {x=13, y=17, z=0}, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_SULFUR_DUNE, {x=16, y=17, z=0}, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_CRYSTAL_CAVERN, {x=19, y=17, z=0}, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_GEM_POND, {x=22, y=17, z=0}, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_GOLD_MINE, {x=25, y=17, z=0}, homm3lua.OWNER_NEUTRAL)
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_DISPASSION, {x=17, y=15, z=0})
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_SECOND_SIGHT, {x=18, y=15, z=0})
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_HOLINESS, {x=19, y=15, z=0})
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_LIFE, {x=20, y=15, z=0})
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_DEATH, {x=21, y=15, z=0})
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_FREE_WILL, {x=22, y=15, z=0})
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_NEGATIVITY, {x=23, y=15, z=0})
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_TOTAL_RECALL, {x=24, y=15, z=0})
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_COURAGE, {x=25, y=15, z=0})
instance:obstacle('Rock', {x=26, y=15, z=0})
instance:obstacle('Mushrooms', {x=27, y=15, z=0})
instance:obstacle('Pine Trees', {x=28, y=15, z=0})
instance:resource(homm3lua.RESOURCE_WOOD, {x=1, y=12, z=0}, 0) -- Random quantity
instance:resource(homm3lua.RESOURCE_MERCURY, {x=1, y=13, z=0}, 10)
instance:resource(homm3lua.RESOURCE_ORE, {x=1, y=14, z=0}, 20)
instance:resource(homm3lua.RESOURCE_SULFUR, {x=1, y=15, z=0}, 30)
instance:resource(homm3lua.RESOURCE_CRYSTAL, {x=1, y=16, z=0}, 40)
instance:resource(homm3lua.RESOURCE_GEMS, {x=1, y=17, z=0}, 50)
instance:resource(homm3lua.RESOURCE_GOLD, {x=1, y=18, z=0}, 60)
instance:town(homm3lua.TOWN_CASTLE, {x=3, y=3, z=0}, homm3lua.PLAYER_1)
instance:hero(homm3lua.HERO_CHRISTIAN, {x=2, y=4, z=0}, homm3lua.PLAYER_1)
instance:town(homm3lua.TOWN_RAMPART, {x=7, y=3, z=0}, homm3lua.PLAYER_2)
instance:hero(homm3lua.HERO_JENOVA, {x=6, y=4, z=0}, homm3lua.PLAYER_2)
instance:town(homm3lua.TOWN_TOWER, {x=11, y=3, z=0}, homm3lua.PLAYER_3)
instance:hero(homm3lua.HERO_FAFNER, {x=10, y=4, z=0}, homm3lua.PLAYER_3)
instance:town(homm3lua.TOWN_INFERNO, {x=15, y=3, z=0}, homm3lua.PLAYER_4)
instance:hero(homm3lua.HERO_CALH, {x=14, y=4, z=0}, homm3lua.PLAYER_4)
instance:town(homm3lua.TOWN_NECROPOLIS, {x=19, y=3, z=0}, homm3lua.PLAYER_5)
instance:hero(homm3lua.HERO_CHARNA, {x=18, y=4, z=0}, homm3lua.PLAYER_5)
instance:town(homm3lua.TOWN_DUNGEON, {x=23, y=3, z=0}, homm3lua.PLAYER_6)
instance:hero(homm3lua.HERO_AJIT, {x=22, y=4, z=0}, homm3lua.PLAYER_6)
instance:town(homm3lua.TOWN_STRONGHOLD, {x=27, y=3, z=0}, homm3lua.PLAYER_7)
instance:hero(homm3lua.HERO_CRAG_HACK, {x=26, y=4, z=0}, homm3lua.PLAYER_7)
instance:town(homm3lua.TOWN_FORTRESS, {x=31, y=3, z=0}, homm3lua.PLAYER_8)
instance:hero(homm3lua.HERO_ALKIN, {x=30, y=4, z=0}, homm3lua.PLAYER_8)
instance:town(homm3lua.TOWN_RANDOM, {x=35, y=3, z=0}, homm3lua.OWNER_NEUTRAL)
instance:text('HELLO', {x=4, y=5, z=0}, 'Pandora\'s Box')
instance:text('WORLD', {x=3, y=10, z=0}, homm3lua.CREATURE_MASTER_GREMLIN)
instance:write('test.h3m')

if false then
    local keys = {}

    for key in pairs(homm3lua) do
        keys[#keys + 1] = key
    end

    table.sort(keys)

    for _, key in ipairs(keys) do
        print(string.format('homm3lua.%-40s %s', key, homm3lua[key]))
    end
end
