-- Instead of LUA_CPATH
package.cpath = package.cpath .. ';components/ca/?.so'
package.cpath = package.cpath .. ';libs/homm3lua/dist/?.so'

-- Instead of LUA_PATH
package.path = package.path .. ';components/gridmap/?.lua'
package.path = package.path .. ';components/lml/?.lua'
package.path = package.path .. ';components/mlml/?.lua'
package.path = package.path .. ';components/params/?.lua'
package.path = package.path .. ';libs/?.lua'

local homm3lua = require('homm3lua')

local ConfigHandler = require('ConfigHandler')
local Serialization = require('Serialization')

local CA      = require('ca')
local GridMap = require('GridMapSeparation/GridMap')
local LML     = require('LogicMapLayout')
local MLML    = require('LogicMapLayout/MultiLogicMapLayout')
local Params  = require('Params')
local rescale = require('mdsAdapter')

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

    for player = 1, #state.paramsGeneral.players do
        instance:player(player - 1)
    end

    for _, sign in ipairs(state.world_debugZoneSigns) do
        instance:sign(table.unpack(sign))
    end

    for _, mine in ipairs(state.world_mines) do
        instance:mine(table.unpack(mine))
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

-- TODO: Get rid of GenerateOldLMLInterface.
--- Creates serializable LML object interface table that can be used to generate MultiLML
-- @param lml LML graph in new format
-- @return Table with properly formated LML interface
local function GenerateOldLMLInterface(graph)
  local interface = {}
  for id, node in ipairs(graph) do
    -- from old function Zone:Interface(id)
    local zone = {}
    zone.id = id
    if node.classes[1].type=='LOCAL' then zone.type = 'LOCAL' end
    if node.classes[1].type=='BUFFER' then zone.type = 'BUFFER' end
    if node.classes[1].type=='GOAL' then zone.type = 'GOAL' end
    local edges = {}
    for k, v in pairs(graph.edges[id]) do
      for i = 1, v do edges[#edges+1] = k end
    end
    zone.edges = edges
    local outer = {}
    for _, f in ipairs(node.features) do
      if f.type == 'OUTER' then
        outer[#outer+1] = f.value
      end
    end
    zone.outer = outer
    -- from old interface[i] = k:Interface(i)
    interface[id] = zone
  end
  return interface
end

-- Steps.
local function step_ca (state)
    state.world1 = {}

    for _, row in ipairs(state.voronoi.grid) do
        local line = {}

        for _, col in ipairs(row) do
            table.insert(line, col == -1 and 3 or 1)
        end

        table.insert(state.world1, line)
    end

    state.world2 = CA.run(state.world1, 'moore', 0.5, 3, 2, 0)
end

local function step_dump (state, index)
    save(state, state.paths.dumps .. index .. '.h3pgm')
end

local function step_dumpH3M (state, index)
    saveH3M(state, state.paths.dumps .. index .. '.h3m')
end

local function step_gameSFP (state)
    local baseIds = {}

    for zoneId, zone in pairs(state.MLML_graph) do
        baseIds[zone.baseid] = true
    end

    for baseId, _ in pairs(baseIds) do
        local features = {}
        for _, feature in ipairs(state.LML_graph[baseId].features) do
            if feature.type == 'MINE' then
                -- TODO: Mine instance?
                -- TODO: Mine template.
                table.insert(features, {
                    instance = feature,
                    template = table.concat({
                        '2 4',
                        '_###',
                        '##.#',
                        '1 2',
                        ''
                    }, '\n')
                })
            end

            if feature.type == 'TOWN' then
                -- TODO: Town template.
                table.insert(features, {
                    instance = feature,
                    template = table.concat({
                        '3 5',
                        '#####',
                        '#####',
                        '##.##',
                        '2 2',
                        ''
                    }, '\n')
                })
            end
        end

        local zones = {}
        for zoneId, zone in pairs(state.MLML_graph) do
            if zone.baseid == baseId then
                local lines = {}

                for z = 0, 0 do
                for y = 0, #state.world1 - 1 do
                local line = {}
                for x = 0, #state.world1[1] - 1 do
                    local id = xyz2position(x, y, z)
                    table.insert(line, state.world[id].zone ~= zoneId and '#' or '.')
                end
                table.insert(lines, table.concat(line, ''))
                end
                end

                table.insert(lines, '')
                table.insert(zones, table.concat(lines, '\n'))
            end
        end

        if #features > 0 then
            local nzones = #zones
            local npois1 = 0
            local npois2 = 0
            local nfsw = #features

            local file = io.open(state.paths.sfp .. '.' .. baseId, 'w')
            file:write(table.concat({nzones, npois1, npois2, nfsw}, ' ') .. '\n')

            for _, zone in ipairs(zones) do
                file:write(#state.world1 .. ' ' .. #state.world1[1] .. '\n')
                file:write(zone)

                -- TODO: Points.
                -- for _, point in ipairs(points1) do
                --     file:write(table.concat(point, ' ') .. '\n')
                -- end

                for _, feature in ipairs(features) do
                    file:write(feature.template)
                end
            end

            file:close()

            local result = shell(table.concat({
                './components/sfp/sfp',
                '<', state.paths.sfp .. '.' .. baseId,
            }, ' '))

            local read = string.gmatch(result, '[^\r\n]+')
            read()

            for _, zone in ipairs(zones) do
                read()
                for _, feature in ipairs(features) do
                    local x = read()
                    local token = string.gmatch(x, '%d+')
                    token()

                    local position = {y=tonumber(token()), x=tonumber(token()), z=0}

                    if feature.instance.type == 'MINE' then
                        table.insert(state.world_mines, {homm3lua.MINE_SAWMILL, position, homm3lua.OWNER_NEUTRAL})
                    end

                    if feature.instance.type == 'TOWN' then
                        table.insert(state.world_towns, {homm3lua.TOWN_RANDOM, position, homm3lua.OWNER_NEUTRAL})
                    end
                end
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

      -- TODO: Inconsistency...
      lmlNode.class = lmlNode.classes

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
    LML.GenerateGraph(state)
    LML.GenerateMetagraph(state)

    -- TODO: Inconsistency...
    state.LML_graph = state.lmlGraph

    state.LML_interface_OLD = GenerateOldLMLInterface(state.LML_graph)
end

local function step_initMLML (state)
    local mlml = MLML.Initialize(state.LML_interface_OLD)
    mlml:Generate(#state.paramsDetailed.players)

    -- TODO: Should be stored in state, not in a file.
    mlml:PrintToMDS(state.paths.graph)

    state.MLML_graph = mlml
    state.MLML_interface = mlml:Interface()
end

local function step_initPaths (state)
    -- NOTE: Store it somewhere?
    local isWindows = package.config:sub(1,1) == '\\'
    local delim = package.config:sub(1,1)

    -- Initialize paths.
    state.path = 'output' .. delim .. state.seed .. '_' .. #state.paramsGeneral.players
    state.paths = {
        path = state.path..delim,
        delim = delim,
        dumps = state.path .. delim .. 'dumps' .. delim,
        imgs  = state.path .. delim .. 'imgs' .. delim,
        emb   = state.path .. delim .. 'emb',
        graph = state.path .. delim .. 'graph.txt',
        map   = state.path .. delim .. 'map.h3m',
        mds   = state.path .. delim .. 'emb.txt',
        pgm   = state.path .. delim .. 'mlml.h3pgm',
        sfp   = state.path .. delim .. 'sfp.txt'
    }

    -- TODO: Inconsistency...
    --state.config.DebugOutPath = state.path

    print('Generating ' .. state.path .. '...')

    -- Create dir.
    shell('mkdir ' .. (isWindows and '' or '-p ') .. state.path)
    shell('mkdir ' .. (isWindows and '' or '-p ') .. state.paths.dumps)
    shell('mkdir ' .. (isWindows and '' or '-p ') .. state.paths.imgs)
end

local function step_initParams (state)
    Params.GenerateDetailedParams(state)
    Params.GenerateInitLMLNode(state)
end

local function step_initSeed (state)
    -- Set shared seed for determinacy.
    if state.paramsGeneral.seed == 0 then
        state.seed = os.time()
    else
        state.seed = state.paramsGeneral.seed
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
    -- Backward compatibility.
    local h1 = #state.world1
    local w1 = #state.world1[1]
    local h2 = h1
    local w2 = w1

    -- Yay!
    state.world = {}
    state.world_grid = {}
    state.world_mines = {}
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
    for y = 0, state.world_size - 1 do
    for x = 0, state.world_size - 1 do
        local cell = nil

        local x2 = x - (state.world_size - w1) // 2
        local y2 = y - (state.world_size - w1) // 2

        if x2 < 0 or x2 >= w1 or y2 < 0 or y2 >= w1 then
            cell = cell or {homm3lua.TERRAIN_WATER}
        end

        local char = (x2 < 0 or x2 >= w1 or y2 < 0 or y2 >= w1) and -1 or state.voronoi.grid[y2 + 1][x2 + 1]
        local wall = (x2 < 0 or x2 >= w1 or y2 < 0 or y2 >= w1) and -1 or state.world2[y2 + 1][x2 + 1]

        -- NOTE: See https://github.com/potmdehex/homm3tools/blob/master/h3m/h3mlib/gen/object_names_hash.in.
        if wall == 1 or wall == 3 then
            local sprite = wall == 1 and 'Oak Trees' or 'Pine Trees'
            state.world_grid[xyz2position(x, y, z)] = true
            table.insert(state.world_obstacles, {sprite, {x=x, y=y, z=z}})
        end

        local code = char
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
    local gH = state.paramsDetailed.height
    local gW = state.paramsDetailed.width

    -- TODO: Sectors...?
    local sectors = state.config.StandardZoneSize // 2

    local data = {}
    local mdsItems = {}

    for _, node in pairs(state.MLML_graph) do
        data[node.id] = {neighbors={}}
        mdsItems[node.id] = {}

        for edge, _ in pairs(node.edges) do
            table.insert(data[node.id].neighbors, edge)
        end
    end

    for line in io.lines(state.paths.mds) do
        if not line:match('^%d+$') then
            local item = {}

            for part in line:gmatch('[^%s]+') do
                table.insert(item, tonumber(part))
            end

            mdsItems[item[1]][#mdsItems[item[1]] + 1] = {item[2], item[3]}
        end
    end

    for id, items in pairs(mdsItems) do
      local avgx = 0.0
      local avgy = 0.0

      for _, item in pairs(items) do
        avgx = avgx + item[1]
        avgy = avgy + item[2]
      end

      avgx = avgx / #items
      avgy = avgy / #items

      data[id].x = rescale(avgx, sectors)
      data[id].y = rescale(avgy, sectors)
      data[id].size = #items
    end

    state.voronoi = GridMap.Initialize(data)
    state.voronoi:Generate({gH=gH, gW=gW, sH=gH//sectors, sW=gW//sectors})
    state.voronoi:RunVoronoi(3, 70, nil)
end

-- Main.
if arg[1] == '?' then
  arg[1] = 'tests/lml/01.h3pgm'
end

if arg[1] then
    local seed = ConfigHandler.Read(arg[1])
    seed.config = ConfigHandler.Read('config.cfg')

    -- TODO: There's an inconsistency...
    seed._config = seed.config

    generate(seed, {
        step_initSeed,
        step_initPaths,
        step_initParams,
        step_dump,
        step_initLML,
        step_dump,
        step_initMLML,
        step_dump,
        step_mds,
        step_dump,
        step_voronoi,
        step_dump,
        step_ca,
        step_dump,
        -- NOTE: This makes state renderable, i.e. .h3m-able.
        step_parseWorld,
        step_dump,
        step_dumpH3M,
        step_gameSFP,
        step_dump,
        step_dumpH3M,
        step_debugZoneSigns,
        step_dump,
        step_dumpH3M,
        step_saveH3M
    })
else
    print('generate.lua h3pgm-file')
    print('  Example:')
    print('           lua ?')
    print('           lua tests/lml/01.h3pgm')
end
