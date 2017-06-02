-- Either set it here or in LUA_CPATH
package.cpath = package.cpath .. ';dist/?.so;../dist/?.so'

-- Yay!
local homm3lua = require('homm3lua')
local instance = homm3lua.new(homm3lua.FORMAT_ROE, homm3lua.SIZE_SMALL)

instance:name('Test of homm3lua')
instance:description('Example of everything we can do with homm3lua (at the moment).')
instance:difficulty(homm3lua.DIFFICULTY_IMPOSSIBLE)
instance:player(homm3lua.PLAYER_1)
instance:player(homm3lua.PLAYER_2)
instance:fill(homm3lua.TERRAIN_LAVA)
instance:creature(homm3lua.CREATURE_ARCHANGEL, 3, 15, 0, 45, homm3lua.DISPOSITION_AGGRESSIVE, true, true)
instance:creature(homm3lua.CREATURE_ARCHANGEL, 3, 16, 0, 45, homm3lua.DISPOSITION_COMPLIANT, true, false)
instance:creature(homm3lua.CREATURE_ARCHANGEL, 3, 17, 0, 45, homm3lua.DISPOSITION_FRIENDLY, false, true)
instance:creature(homm3lua.CREATURE_ARCHANGEL, 3, 18, 0, 45, homm3lua.DISPOSITION_HOSTILE, false, false)
instance:creature(homm3lua.CREATURE_ARCHANGEL, 3, 19, 0, 0, homm3lua.DISPOSITION_SAVAGE, true, false) -- Random quantity
instance:mine(homm3lua.MINE_SAWMILL, 7, 17, 0, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_ALCHEMISTS_LAB, 10, 17, 0, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_ORE_PIT, 13, 17, 0, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_SULFUR_DUNE, 16, 17, 0, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_CRYSTAL_CAVERN, 19, 17, 0, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_GEM_POND, 22, 17, 0, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_GOLD_MINE, 25, 17, 0, homm3lua.OWNER_NEUTRAL)
instance:mine(homm3lua.MINE_ABANDONED_MINE, 28, 17, 0, homm3lua.OWNER_NEUTRAL)
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_DISPASSION, 17, 15, 0)
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_SECOND_SIGHT, 18, 15, 0)
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_HOLINESS, 19, 15, 0)
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_LIFE, 20, 15, 0)
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_DEATH, 21, 15, 0)
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_FREE_WILL, 22, 15, 0)
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_NEGATIVITY, 23, 15, 0)
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_TOTAL_RECALL, 24, 15, 0)
instance:artifact(homm3lua.ARTIFACT_PENDANT_OF_COURAGE, 25, 15, 0)
instance:obstacle('Rock', 26, 15, 0)
instance:obstacle('Mushrooms', 27, 15, 0)
instance:obstacle('Pine Trees', 28, 15, 0)
instance:resource(homm3lua.RESOURCE_WOOD, 1, 12, 0, 0) -- Random quantity
instance:resource(homm3lua.RESOURCE_MERCURY, 1, 13, 0, 10)
instance:resource(homm3lua.RESOURCE_ORE, 1, 14, 0, 20)
instance:resource(homm3lua.RESOURCE_SULFUR, 1, 15, 0, 30)
instance:resource(homm3lua.RESOURCE_CRYSTAL, 1, 16, 0, 40)
instance:resource(homm3lua.RESOURCE_GEMS, 1, 17, 0, 50)
instance:resource(homm3lua.RESOURCE_GOLD, 1, 18, 0, 60)
instance:town(homm3lua.TOWN_CASTLE, 3, 3, 0, homm3lua.PLAYER_1)
instance:hero(homm3lua.HERO_CHRISTIAN, 2, 4, 0, homm3lua.PLAYER_1)
instance:town(homm3lua.TOWN_RAMPART, 7, 3, 0, homm3lua.PLAYER_2)
instance:hero(homm3lua.HERO_JENOVA, 6, 4, 0, homm3lua.PLAYER_2)
instance:town(homm3lua.TOWN_TOWER, 11, 3, 0, homm3lua.PLAYER_3)
instance:hero(homm3lua.HERO_FAFNER, 10, 4, 0, homm3lua.PLAYER_3)
instance:town(homm3lua.TOWN_INFERNO, 15, 3, 0, homm3lua.PLAYER_4)
instance:hero(homm3lua.HERO_CALH, 14, 4, 0, homm3lua.PLAYER_4)
instance:town(homm3lua.TOWN_NECROPOLIS, 19, 3, 0, homm3lua.PLAYER_5)
instance:hero(homm3lua.HERO_CHARNA, 18, 4, 0, homm3lua.PLAYER_5)
instance:town(homm3lua.TOWN_DUNGEON, 23, 3, 0, homm3lua.PLAYER_6)
instance:hero(homm3lua.HERO_AJIT, 22, 4, 0, homm3lua.PLAYER_6)
instance:town(homm3lua.TOWN_STRONGHOLD, 27, 3, 0, homm3lua.PLAYER_7)
instance:hero(homm3lua.HERO_CRAG_HACK, 26, 4, 0, homm3lua.PLAYER_7)
instance:town(homm3lua.TOWN_FORTRESS, 31, 3, 0, homm3lua.PLAYER_8)
instance:hero(homm3lua.HERO_ALKIN, 30, 4, 0, homm3lua.PLAYER_8)
instance:town(homm3lua.TOWN_RANDOM, 35, 3, 0, homm3lua.OWNER_NEUTRAL)
instance:text('HELLO', 4, 5, 0, 'Pandora\'s Box')
instance:text('WORLD', 3, 10, 0, homm3lua.CREATURE_MASTER_GREMLIN)
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
