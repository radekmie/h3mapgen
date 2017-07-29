package.cpath = package.cpath .. ';homm3lua/dist/?.so'
package.path  = package.path  .. ';bin/?.lua'

-- TODO: Read more data from this config.
CONFIG = require('Auxiliary/ConfigHandler').Read('config.cfg')

local homm3lua = require('homm3lua')

local ConfigHandler = require('Auxiliary/ConfigHandler')
local Serialization = require('Auxiliary/Serialization')

local Grammar = require('LogicMapLayout/Grammar/Grammar')
local LML     = require('LogicMapLayout/LogicMapLayout')
local MLML    = require('LogicMapLayout/MultiLogicMapLayout')

local function shell (command)
    local handle = io.popen(command)
    local result = handle:read('*a')
    handle:close()

    return result:gsub('^%s*(.-)%s*$', '%1')
end

local function generateH3M (mlml, terrain, world, out)
    -- Terrain
    local file = assert(io.open(terrain))
    local h1, w1, terrain = file:read('*number', '*number', '*all')
    file:close()

    -- World
    local file = assert(io.open(world))
    local h2, w2, world = file:read('*number', '*number', '*all')
    file:close()

    if h1 ~= w1 then error('Map have to be a square!') end
    if h2 ~= w2 then error('Map have to be a square!') end
    if h1 ~= h2 then error('Map terrain and world differ in size!') end

    -- Yay!
    local size = nil
        if w1 <= homm3lua.SIZE_SMALL      then size = homm3lua.SIZE_SMALL
    elseif w1 <= homm3lua.SIZE_MEDIUM     then size = homm3lua.SIZE_MEDIUM
    elseif w1 <= homm3lua.SIZE_LARGE      then size = homm3lua.SIZE_LARGE
    elseif w1 <= homm3lua.SIZE_EXTRALARGE then size = homm3lua.SIZE_EXTRALARGE
    else error('Map too big!') end

    local instance = homm3lua.new(homm3lua.FORMAT_ROE, size)

    instance:terrain(function (x, y, z)
        local x2 = x - (size - w1) // 2
        local y2 = y - (size - w1) // 2

        if x2 < 0 or x2 >= w1 or y2 < 0 or y2 >= w1 then
            return homm3lua.TERRAIN_WATER
        end

        local info = y2 * (w1 + 1) + x2 + 2 -- +1 for line break, +2 for the initial offset
        local char = terrain:sub(info, info)
        local wall = world:sub(info, info)

        -- see  https://github.com/potmdehex/homm3tools/blob/master/h3m/h3mlib/gen/object_names_hash.in
        if wall == '#' then instance:obstacle('Oak Trees',  {x=x, y=y, z=z}) end
        if wall == '$' then instance:obstacle('Pine Trees', {x=x, y=y, z=z}) end

        local code = (char:byte() or 0) - ('a'):byte()
        local zone = mlml[code]

        if zone then
            if zone.type == 'BUFFER' then
                return homm3lua.TERRAIN_LAVA
            end

            for player in pairs(zone.players) do
                return player % 7
            end
        end

        -- NOTE: It should NOT happen, but... You know.
        return homm3lua.H3M_TERRAIN_ROCK
    end)

    instance:write(out)
end

local function generateMLML (init, iterations, seed, players, graph, pgm)
    local lml = LML.Initialize(init)
    lml:Generate(Grammar, iterations)

    local mlml = MLML.Initialize(lml:Interface())
    mlml:Generate(players)
    mlml:PrintToMDS(graph)

    if pgm then
        ConfigHandler.Write(pgm, {
            LML_init = init,
            LML_seed = seed,

            LML_graph  = lml,
            MLML_graph = mlml,

            LML_interface  = mlml.lml,
            MLML_interface = mlml:Interface(),
        })
    end

    return mlml
end

local function generateMLMLSeed ()
    local init = {class={}, features={}}

    for level = 0, math.floor(math.random() * 5) + 1 do
        init.class[#init.class + 1] = {level=level, type='LOCAL'}
        init.features[#init.features + 1] = {class={level=level, type='LOCAL'}, type='TOWN', value='PLAYER'}
    end

    for buffer = 1, math.floor(math.random() * 3) + 1 do
        local level = math.floor(math.random() * 3) + 3
        init.class[#init.class + 1] = {level=level, type='BUFFER'}
        init.features[#init.features + 1] = {class={level=level, type='BUFFER'}, type='OUTER', value=0}
    end

    return init
end

local function generate (players, size, sectors, seed)
    local isWindows = package.config[1] == '/'

    local _seed = seed or os.time()
    local _path = 'output/' .. _seed .. '_' .. players

    math.randomseed(_seed)

    local cell  = _path .. '/cell.txt'
    local emb   = _path .. '/emb'
    local graph = _path .. '/graph.txt'
    local map   = _path .. '/map.h3m'
    local mds   = _path .. '/emb.txt'
    local pgm   = _path .. '/mlml.h3pgm'
    local vor1  = _path .. '/map.txt'
    local vor2  = _path .. '/mapText.txt'

    -- Preparation
    shell('mkdir ' .. (isWindows and '' or '-p ') .. _path)

    -- LML & LMLM
    local init = generateMLMLSeed()
    local mlml = generateMLML(init, CONFIG.LML_max_steps, _seed, players, graph, pgm)

    -- Terrain
    shell('python MDS/embed_graph.py ' .. graph .. ' ' .. emb)
    shell('bin/voronoi ' .. mds .. ' ' .. vor1 .. ' ' .. size .. ' ' .. size .. ' ' .. sectors .. ' ' .. sectors)
    shell('cellular/cellular 0.5 1 2 < ' .. vor1 .. ' > ' .. cell)

    -- Debug
    -- shell('sed \'s/./& /g\' ' .. cell .. ' | grep --color \'\\$\'')

    -- H3M
    generateH3M(mlml, vor2, cell, map)
end

if arg[1] then
    generate(table.unpack(arg))
else
    print('generate.lua players size sectors players size sectors [seed]')
    print('  Example:')
    print('           lua generate.lua 8 144 36')
    print('           lua generate.lua 4 90 15')
    print('           lua generate.lua 2 72 4')
end
