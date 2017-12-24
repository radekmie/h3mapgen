-- Instead of LUA_CPATH
package.cpath = package.cpath .. ';libs/homm3lua/dist/?.so'

-- Instead of LUA_PATH
package.path = package.path .. ';components/mlml/?.lua'
package.path = package.path .. ';libs/?.lua'

-- TODO: Read more data from this config.
local CONFIG = require('Auxiliary/ConfigHandler').Read('config.cfg')

local homm3lua = require('homm3lua')

local ConfigHandler = require('Auxiliary/ConfigHandler')
local Serialization = require('Auxiliary/Serialization')

local Grammar = require('LogicMapLayout/Grammar/Grammar')
local LML     = require('LogicMapLayout/LogicMapLayout')
local MLML    = require('LogicMapLayout/MultiLogicMapLayout')

-- Utils.
local function generate (state, steps)
    for index, step in ipairs(steps) do
        step(state, index)
    end
end

local function position2xyz (p)
    return p % 256, p // 256 % 256, p // 256 // 256
end

local function xyz2position (x, y, z)
    return x + y * 256 + z * 256 * 256
end

local function save (state, path)
    ConfigHandler.Write(path, state)
end

local function saveH3M (state, path)
    local instance = homm3lua.new(homm3lua.FORMAT_ROE, state.world_size)

    instance:name('Random Map')
    instance:description('Seed: ' .. state.seed)

    for _, sign in ipairs(state.world_debugZoneSigns) do
        instance:sign(table.unpack(sign))
    end
    
    for _, town in ipairs(state.world_towns) do
        instance:town(table.unpack(town))
    end

    for _, obstacle in ipairs(state.world_obstacles) do
        instance:obstacle(table.unpack(obstacle))
    end

    instance:terrain(function (x, y, z)
        return table.unpack(state.world[xyz2position(x, y, z)].cell)
    end)

    instance:write(path)
end

local function shell (command)
    local handle = io.popen(command)
    local result = handle:read('*a')
    handle:close()

    return result:gsub('^%s*(.-)%s*$', '%1')
end

-- Steps.
local function step_ca (state)
    shell(table.concat({
        'components/ca/ca 0.5 3 2',
        '<', state.paths.vor1,
        '>', state.paths.cell
    }, ' '))
end

local function step_dump (state, index)
    save(state, state.paths.dumps .. index .. '.h3pgm')
end

local function step_dumpH3M (state, index)
    saveH3M(state, state.paths.dumps .. index .. '.h3m')
end

local function step_gameCastles (state)
    for zoneId, zone in pairs(state.MLML_graph) do
        local base = state.LML_graph[zone.baseid]
        local town = false

        for _, feature in ipairs(base.features) do
            if feature.type == 'TOWN' then
                town = true
                break
            end
        end

        if town then
            local play = 0
            for player in pairs(zone.players) do
                play = player
                break
            end

            local cells = {}

            for cellId, cell in pairs(state.world) do
                if cell.zone == zoneId then
                    cells[cellId] = true
                end
            end

            local valid = {}

            for cellId in pairs(cells) do
                local x, y, z = position2xyz(cellId)

                if  not state.world_grid[xyz2position(x - 2,     y,     z)]
                and not state.world_grid[xyz2position(x - 2 + 1, y + 1, z)]
                and not state.world_grid[xyz2position(x - 2 + 1, y,     z)]
                and not state.world_grid[xyz2position(x - 2 - 1, y + 1, z)]
                and not state.world_grid[xyz2position(x - 2 - 1, y,     z)]
                and not state.world_grid[xyz2position(x - 2,     y + 1, z)] then
                    -- TODO: Check if this position is valid.
                    table.insert(valid, cellId)
                end
            end

            if #valid > 0 then
                for _, cellId in ipairs(valid) do
                    local x, y, z = position2xyz(cellId)

                    local sprite = ({
                        homm3lua.TOWN_CASTLE,
                        homm3lua.TOWN_DUNGEON,
                        homm3lua.TOWN_FORTRESS,
                        homm3lua.TOWN_INFERNO,
                        homm3lua.TOWN_NECROPOLIS,
                        homm3lua.TOWN_RAMPART,
                        homm3lua.TOWN_STRONGHOLD,
                        homm3lua.TOWN_TOWER
                    })[play]

                    table.insert(state.world_towns, {sprite, {x=x, y=y, z=z}, play - 1})

                    break
                end
            else
                print('FAILED TO PLACE A TOWN IN ZONE', zoneId)
            end
        end
    end
end

local function step_debugZoneSigns (state)
  
    local zonestocheck={}
    for zoneId, _ in pairs(state.MLML_graph) do
      zonestocheck[zoneId] = true
    end
    
    local generateZoneDescription = function (zoneId)
      local descr_zone = 'Zone ID: '..zoneId
      local mlmlNode = state.MLML_graph[zoneId]
      local descr_bzone = 'Zone Base-ID: '..mlmlNode.baseid
      local lmlNode = state.LML_graph[mlmlNode.baseid]
      local descr_level = 'Level: '..lmlNode.class[1].level
      local players = {}
      for p=1,8 do
        if mlmlNode.players[p] then table.insert(players, p) end
      end
      local descr_type = mlmlNode.type..' for players: '..table.concat(players,',')
      local features = {}
      for _, feature in ipairs(lmlNode.features) do
        table.insert(features, feature.type)
      end
      local descr_features = 'Features: '..table.concat(features,',')
      return table.concat({descr_zone, descr_bzone, descr_level, descr_type, descr_features}, '\n')
    end
   
    for cellId, cell in pairs(state.world) do
      if zonestocheck[cell.zone] then
        local x, y, z = position2xyz(cellId)

        if  not state.world_grid[xyz2position(x,     y,     z)]
        and not state.world_grid[xyz2position(x + 1, y + 0, z)]
        and not state.world_grid[xyz2position(x - 1, y + 0, z)]
        and not state.world_grid[xyz2position(x + 0, y + 1, z)]
        and not state.world_grid[xyz2position(x + 0, y - 1, z)]
        and not state.world_grid[xyz2position(x - 1, y - 1, z)]
        and not state.world_grid[xyz2position(x + 1, y - 1, z)]
        and not state.world_grid[xyz2position(x - 1, y + 1, z)]
        and not state.world_grid[xyz2position(x + 1, y + 1, z)] then
          table.insert(state.world_debugZoneSigns, {generateZoneDescription(cell.zone), {x=x, y=y, z=z}})
          zonestocheck[cell.zone] = nil
        end
      end
    end
 
    for cellId, cell in pairs(state.world) do
      if zonestocheck[cell.zone] then
        local x, y, z = position2xyz(cellId)

        if  not state.world_grid[xyz2position(x,     y,     z)] then
          table.insert(state.world_debugZoneSigns, {generateZoneDescription(cell.zone), {x=x, y=y, z=z}})
          zonestocheck[cell.zone] = nil
        end
      end
    end
    -- Let's be silent about fails here
end

local function step_initLML (state)
    local init = {class={}, features={}}
    local rand = function (from, to)
        return math.floor(math.random() * (to - from)) + from
    end

    for level = 0, rand(1, 6) do
        table.insert(init.class,           {level=level, type='LOCAL'})
        table.insert(init.features, {class={level=level, type='LOCAL'}, type='TOWN', value='PLAYER'})
    end

    for buffer = 1, rand(1, 4) do
        local level = rand(3, 6)

        table.insert(init.class,           {level=level, type='BUFFER'})
        table.insert(init.features, {class={level=level, type='BUFFER'}, type='OUTER', value=0})
    end

    local lml = LML.Initialize(init)
    -- TODO: Do not use a state._config?
    lml:Generate(Grammar, state._config.LML_max_steps)

    state.LML_graph = lml
    state.LML_init = init
    state.LML_interface = lml:Interface()
end

local function step_initMLML (state)
    local mlml = MLML.Initialize(state.LML_interface)
    mlml:Generate(state._params.players)

    -- TODO: Should be stored in state, not in a file.
    mlml:PrintToMDS(state.paths.graph)

    state.MLML_graph = mlml
    state.MLML_interface = mlml:Interface()
end

local function step_initPaths (state)
    -- NOTE: Store it somewhere?
    local isWindows = package.config[1] == '/'

    -- Initialize paths.
    state.path = 'output/' .. state.seed .. '_' .. state._params.players
    state.paths = {
        cell  = state.path .. '/cell.txt',
        dumps = state.path .. '/dumps/',
        emb   = state.path .. '/emb',
        graph = state.path .. '/graph.txt',
        map   = state.path .. '/map.h3m',
        mds   = state.path .. '/emb.txt',
        pgm   = state.path .. '/mlml.h3pgm',
        vor1  = state.path .. '/map.txt',
        vor2  = state.path .. '/mapText.txt'
    }

    print('Generating ' .. state.path .. '...')

    -- Create dir.
    shell('mkdir ' .. (isWindows and '' or '-p ') .. state.path)
    shell('mkdir ' .. (isWindows and '' or '-p ') .. state.paths.dumps)
end

local function step_initSeed (state)
    -- Set shared seed for determinacy.
    if state._params.seed == -1 then
        state.seed = os.time()
    else
        state.seed = state._params.seed
    end

    math.randomseed(state.seed)
end

local function step_mds (state)
    shell(table.concat({
        'python components/mds/embed_graph.py',
        state.paths.graph,
        state.paths.emb
    }, ' '))
end

local function step_parseWorld (state)
    -- Terrain
    local file = assert(io.open(state.paths.vor2))
    local h1, w1, terrain = file:read('*number', '*number', '*all')
    file:close()

    -- World
    local file = assert(io.open(state.paths.cell))
    local h2, w2, world = file:read('*number', '*number', '*all')
    file:close()

    if h1 ~= w1 then error('Map have to be a square!') end
    if h2 ~= w2 then error('Map have to be a square!') end
    if h1 ~= h2 then error('Map terrain and world differ in size!') end

    -- Yay!
    state.world = {}
    state.world_grid = {}
    state.world_obstacles = {}
    state.world_size = nil
    state.world_towns = {}
    state.world_debugZoneSigns = {}

        if w1 <= homm3lua.SIZE_SMALL      then state.world_size = homm3lua.SIZE_SMALL
    elseif w1 <= homm3lua.SIZE_MEDIUM     then state.world_size = homm3lua.SIZE_MEDIUM
    elseif w1 <= homm3lua.SIZE_LARGE      then state.world_size = homm3lua.SIZE_LARGE
    elseif w1 <= homm3lua.SIZE_EXTRALARGE then state.world_size = homm3lua.SIZE_EXTRALARGE
    else error('Map too big!') end

    -- TODO: Store underground info somewhere.
    for z = 0, 0 do
    for y = 0, state.world_size do
    for x = 0, state.world_size do
        local cell = nil

        local x2 = x - (state.world_size - w1) // 2
        local y2 = y - (state.world_size - w1) // 2

        if x2 < 0 or x2 >= w1 or y2 < 0 or y2 >= w1 then
            cell = cell or {homm3lua.TERRAIN_WATER}
        end

        -- NOTE: +1 for line break, +2 for the initial offset.
        local info = y2 * (w1 + 1) + x2 + 2
        local char = terrain:sub(info, info)
        local wall = world:sub(info, info)

        -- NOTE: See https://github.com/potmdehex/homm3tools/blob/master/h3m/h3mlib/gen/object_names_hash.in.
        if wall == '#' or wall == '$' then
            local sprite = wall == '#' and 'Oak Trees' or 'Pine Trees'
            state.world_grid[xyz2position(x, y, z)] = true
            table.insert(state.world_obstacles, {sprite, {x=x, y=y, z=z}})
        end

        local code = (char:byte() or 0) - ('a'):byte()
        local zone = state.MLML_graph[code]

        if zone then
            if zone.type == 'BUFFER' then
                cell = cell or {homm3lua.TERRAIN_LAVA}
            end

            for player in pairs(zone.players) do
                cell = cell or {player % 7}
            end
        end

        -- NOTE: It should NOT happen, but... You know.
        cell = cell or {homm3lua.H3M_TERRAIN_ROCK}

        state.world[xyz2position(x, y, z)] = {cell = cell, zone = code}
    end
    end
    end
end

local function step_saveH3M (state)
    saveH3M(state, state.paths.map)
end

local function step_voronoi (state)
    shell(table.concat({
        'components/voronoi/voronoi',
        state.paths.mds,
        state.paths.vor1,
        state._params.size,
        state._params.size,
        state._params.sectors,
        state._params.sectors
    }, ' '))
end

-- Main.
if arg[1] then
    local seed = {
        _config = CONFIG,
        _params = {
            players = tonumber(arg[1]),
            sectors = tonumber(arg[3]),
            seed    = tonumber(arg[4] or -1),
            size    = tonumber(arg[2])
        }
    }

    generate(seed, {
        step_initSeed,
        step_initPaths,
        -- step_dump,
        step_initLML,
        -- step_dump,
        step_initMLML,
        step_dump,
        step_mds,
        -- step_dump,
        step_voronoi,
        -- step_dump,
        step_ca,
        -- step_dump,
        -- NOTE: This makes state renderable, i.e. .h3m-able.
        step_parseWorld,
        step_gameCastles,
        step_debugZoneSigns,
        step_dump,
        -- step_dumpH3M,
        step_saveH3M
    })
else
    print('generate.lua players size sectors [seed]')
    print('  Example:')
    print('           lua generate.lua 8 144 36')
    print('           lua generate.lua 4 90 15')
    print('           lua generate.lua 2 72 4')
end
