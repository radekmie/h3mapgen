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

local CA         = require('ca')
local GridMap    = require('GridMapSeparation/GridMap')
local LML        = require('LogicMapLayout')
local MLML       = require('LogicMapLayout/MultiLogicMapLayout')
local MLMLHelper = require('LogicMapLayout/MLMLHelper')
local Params     = require('Params')
local SFPTools   = require('SFPTools')
local rescale    = require('mdsAdapter')

-- Utils.
local function generate (state, steps)
    for index, step in ipairs(steps) do
        step(state, index)
    end
end

local function position2xyz (p)
    return p % 256, math.floor(p / 256) % 256, math.floor(math.floor(p / 256) / 256)
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
    instance:description('Seed: ' .. state.paramsDetailed.seed)

    for player = 1, #state.paramsGeneral.players do
        instance:player(player - 1)
    end

    for _, creature in ipairs(state.world_creatures) do
        instance:creature(table.unpack(creature))
    end

    for _, hero in ipairs(state.world_heroes) do
        hero[2].y = hero[2].y - 1
        instance:hero(table.unpack(hero))
        hero[2].y = hero[2].y + 1
    end

    for _, sign in ipairs(state.world_debugZoneSigns) do
        instance:sign(table.unpack(sign))
    end

    for _, mine in ipairs(state.world_mines) do
        instance:mine(table.unpack(mine))
    end

    for _, town in ipairs(state.world_towns) do
        town[2].x = town[2].x + 2
        instance:town(table.unpack(town))
        town[2].x = town[2].x - 2
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
    if type(command) == 'table' then
        command = table.concat(command, ' ')
    end

    local handle = io.popen(command)
    local result = handle:read('*a')
    handle:close()

    return result:gsub('^%s*(.-)%s*$', '%1')
end


-- Steps.
local function step_ca (state)
    print('[CA] Start.')
    local board = CA.run(state.board, 'moore', 0.5, 3, 2, state.paramsDetailed.seed)

    print('[CA]   Load.')
    for y, line in ipairs(board) do
        if y - 2 > 0 and y + 2 < #state.board then
            for x, char in ipairs(line) do
                if x - 2 > 0 and x + 2 < #line then
                    if (char == 1 or char == 3) and state.board[y][x] == 0 then
                        local sprite = char == 1 and 'Oak Trees' or 'Pine Trees'
                        state.world_grid[xyz2position(x, y, 0)] = true
                        table.insert(state.world_obstacles, {sprite, {x=x - 1, y=y - 1, z=0}})
                    end
                end
            end
        end
    end

    state.board = board
    print('[CA]   Done.')
end

local function step_dump (state, index)
    save(state, state.paths.dumps .. index .. '.h3pgm')
end

local function step_dumpH3M (state, index)
    saveH3M(state, state.paths.dumps .. index .. '.h3m')
end

local function step_SFP (state)
    local baseIds = {}

    for zoneId, zone in pairs(state.MLML_graph) do
        baseIds[zone.baseid] = true
    end

    for baseId, _ in pairs(baseIds) do
        print('[SFP] BaseId: ' .. baseId)

        local features = {}
        for _, feature in ipairs(state.LML_graph[baseId].features) do
            if feature.type == 'MINE' then
                -- TODO: Mine instance?
                table.insert(features, {
                    instance = feature,
                    template = SFPTools.patterns.mine.sawmill.text
                })
            end

            if feature.type == 'TOWN' then
                table.insert(features, {
                    instance = feature,
                    template = SFPTools.patterns.town.text
                })
            end
        end

        local border = {}
        for x = 1, #state.board[1] + 2 do
            table.insert(border, '#')
        end

        border = table.concat(border, '')

        local zonesCount = 0
        local zones = {}
        local pois1 = {}

        for zoneId, zone in pairs(state.MLML_graph) do
            if zone.baseid == baseId then
                local lines = {border, border}
                local poisA = {}

                for z = 0, 0 do
                for y = 1, #state.board - 2 do
                local line = {'#', '#'}
                for x = 1, #state.board[1] - 2 do
                    local id = state.world[xyz2position(x, y, z)].zone

                    local hasPoi1 = false
                    local hasWall = state.board[y + 1][x + 1] == 3
                    local hasZone = id == zoneId

                    if hasWall then
                        table.insert(line, '#')
                    else
                        for _, join in ipairs(state.voronoi.joinAt) do
                            if (join[1] == zoneId and join[5][1] == (x + 1) and join[5][2] == (y + 1)) or
                               (join[2] == zoneId and join[6][1] == (x + 1) and join[6][2] == (y + 1))
                            then
                                hasPoi1 = true
                                table.insert(poisA, y .. ' ' .. x)
                                break
                            end
                        end

                        if hasPoi1 then
                            -- NOTE: Change to P for debugging.
                            table.insert(line, '.')
                        elseif hasZone then
                            table.insert(line, '.')
                        else
                            table.insert(line, '#')
                        end
                    end
                end
                table.insert(line, '##')
                table.insert(lines, table.concat(line, ''))
                end
                end

                table.insert(lines, border)
                table.insert(lines, border)
                table.insert(lines, '')
                table.insert(poisA, '')

                zones[zoneId] = table.concat(lines, '\n')
                pois1[zoneId] = poisA
                zonesCount = zonesCount + 1
            end
        end

        if #features == 0 then
            print('[SFP]   Added artificial PoI.')
            table.insert(features, {
                instance = {type='PLACEHOLDER'},
                template = SFPTools.patterns.zero.text
            })
        end

        local nzones = zonesCount
        local npois1 = 0
        local npois2 = 0
        local nfsw = #features

        -- All pois1 have to be the same length.
        while true do
            local changed = false

            for a, poisa in pairs(pois1) do
                for b, poisb in pairs(pois1) do
                    while #poisa > #poisb do
                        changed = true
                        table.remove(poisa, 1)
                    end

                    while #poisa < #poisb do
                        changed = true
                        table.remove(poisb, 1)
                    end

                    npois1 = #poisa - 1
                end
            end

            if not changed then
                break
            end
        end

        local file = io.open(state.paths.sfp .. '.' .. baseId, 'w')
        file:write('-1 -1 -1 ' .. state.paramsDetailed.seed .. '\n')
        file:write(table.concat({nzones, npois1, npois2, nfsw}, ' ') .. '\n')

        for zoneId, zone in pairs(zones) do
            file:write((#state.board + 2) .. ' ' .. (#state.board[1] + 2) .. '\n')
            file:write(zone)
            file:write(table.concat(pois1[zoneId], '\n'))

            for _, feature in ipairs(features) do
                file:write(feature.template)
            end
        end

        file:close()

        local result = shell{
            './components/sfp/sfp',
            '< ' .. state.paths.sfp .. '.' .. baseId,
            '2> ' .. state.paths.dumps .. 'sfp.' .. baseId .. '.log'
        }

        local read = result:gmatch('[^\r\n]+')
        local status = read()
        print('[SFP]   Status:', status)

        if status == 'check_data returned 0.' then
            for zoneId, _ in pairs(zones) do
                read()
                for _, feature in ipairs(features) do
                    local token = string.gmatch(read(), '%d+')
                    token()

                    local position = {y=tonumber(token()) - 1, x=tonumber(token()) - 1, z=0}

                    if position.x ~= 0 and position.y ~= 0 then
                        local owner = homm3lua.OWNER_NEUTRAL
                        for player = 1, 8 do
                            if state.MLML_graph[zoneId].players[player] then
                                owner = player - 1
                                break
                            end
                        end

                        if feature.instance.type == 'PLACEHOLDER' then
                            SFPTools.apply(state.board, position, SFPTools.patterns.zero)
                            print('[SFP]     PoI', 'at', position.x, position.y)
                            -- FIXME: Offset!?
                            position.x = position.x + 1
                            position.y = position.y + 1
                            table.insert(state.world_heroes, {homm3lua.HERO_CRAG_HACK, position, homm3lua.PLAYER_7})
                        end

                        if feature.instance.type == 'MINE' then
                            SFPTools.apply(state.board, position, SFPTools.patterns.mine.sawmill)
                            print('[SFP]     Mine', 'at', position.x, position.y)
                            -- NOTE: Right bottom, not doors.
                            position.x = position.x + 1
                            table.insert(state.world_mines, {homm3lua.MINE_SAWMILL, position, owner})
                        end

                        if feature.instance.type == 'TOWN' then
                            SFPTools.apply(state.board, position, SFPTools.patterns.town)
                            print('[SFP]     Town', 'at', position.x, position.y)
                            table.insert(state.world_towns, {homm3lua.TOWN_RANDOM, position, owner})
                        end
                    else
                        print('[SFP]     Failed', feature.instance.type)
                    end
                end
            end

            print('[SFP]   Fitness: ' .. read():sub(8))
            print('[SFP]   Scanning roads.')

            for zoneId, _ in pairs(zones) do
                for y = -1, #state.board do
                    local char = (read() or ''):gmatch('.')
                    for x = -1, #state.board[1] do
                        if char() == 'x' then
                            state.board[y + 1][x + 1] = 2
                            state.world[xyz2position(x, y, 0)].cell[2] = 2
                        end
                    end
                end
            end

            print('[SFP]     Done.')
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

    state.LML_interface_OLD = MLMLHelper.GenerateOldLMLInterface(state.LML_graph)
end

local function step_initMLML (state)
    local mlml = MLML.Initialize(state.LML_interface_OLD)
    mlml:Generate(#state.paramsDetailed.players)

    -- TODO: Should be stored in state, not in a file.
    mlml:PrintToMDS(state.paths.graph)

    state.MLML_graph = mlml
    state.MLML_interface = mlml:Interface()

    MLMLHelper.GenerateImage(mlml, state.lmlGraph):Draw(state.paths.path..'MLML', state.config.GraphGeneratorDrawKeepDotSources)
end

local function step_initPaths (state)
    -- NOTE: Store it somewhere?
    local isWindows = package.config:sub(1,1) == '\\'
    local delim = package.config:sub(1,1)

    -- Initialize paths.
    state.path = 'output' .. delim .. state.paramsDetailed.seed .. '_' .. #state.paramsGeneral.players
    state.paths = {
        path = state.path..delim,
        delim = delim,
        dumps = state.path .. delim .. 'dumps' .. delim,
        imgs  = state.path .. delim .. 'imgs' .. delim,
        emb   = state.path .. delim .. 'emb',
        graph = state.path .. delim .. 'graph.txt',
        logs  = state.path .. delim .. 'logs.txt',
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
    math.randomseed(state.paramsDetailed.seed)
end

local function step_mds (state)
    shell{
        'components/mds/mds',
        state.paths.graph,
        state.paths.emb,
        state.paramsDetailed.seed
    }
end

local function step_parseWorld (state)
    state.board = {}

    for y, row in ipairs(state.voronoi.grid) do
        local line = {}

        for x, col in ipairs(row) do
            table.insert(line, (col == -1 or state.voronoi.borders[y][x]) and 3 or ((col == -2 or col == -3) and 2 or 0))
        end

        table.insert(state.board, line)
    end

    -- Backward compatibility.
    local h1 = #state.board
    local w1 = #state.board[1]
    local h2 = h1
    local w2 = w1

    -- Yay!
    state.world = {}
    state.world_creatures = {}
    state.world_grid = {}
    state.world_heroes = {}
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

        local x2 = x - math.floor((state.world_size - w1) / 2)
        local y2 = y - math.floor((state.world_size - w1) / 2)

        if x2 < 0 or x2 >= w1 or y2 < 0 or y2 >= w1 then
            cell = cell or {homm3lua.TERRAIN_WATER}
        end

        local char = (x2 < 0 or x2 >= w1 or y2 < 0 or y2 >= w1) and -1 or state.voronoi.grid[y2 + 1][x2 + 1]
        local wall = (x2 < 0 or x2 >= w1 or y2 < 0 or y2 >= w1) and -1 or state.board[y2 + 1][x2 + 1]

        -- NOTE: See https://github.com/potmdehex/homm3tools/blob/master/h3m/h3mlib/gen/object_names_hash.in.
        if wall == 2 then
            local sprite = char == -2 and 'Archangel' or 'Pikeman'
            state.world_grid[xyz2position(x, y, z)] = true
            table.insert(state.world_creatures, {sprite, {x=x, y=y, z=z}, 0, homm3lua.DISPOSITION_AGGRESSIVE, true, true})
        end
        if wall == 3 then
            local sprite = 'Pine Trees'
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

        -- No zone.
        cell = cell or {homm3lua.TERRAIN_LAVA}

        state.world[xyz2position(x, y, z)] = {cell = cell, zone = code}
    end
    end
    end
end

local function step_initLogging (state)
    local handle = io.open(state.paths.logs, 'w')
    local _print = print
    print = function (...)
        handle:write(table.concat({...}, '\t'), '\n')
        _print(...)
    end
end

local function step_saveH3M (state)
    saveH3M(state, state.paths.map)
end

local function step_voronoi (state)
    local gH = state.paramsDetailed.height
    local gW = state.paramsDetailed.width

    -- TODO: Sectors...?
    local sectors = math.floor(state.config.StandardZoneSize / 2)

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

    -- TODO: set this parameter to value from input parameters
    local forceFill = true

    state.voronoi = GridMap.Initialize(data)
    state.voronoi:Generate({gH=gH, gW=gW, sH=math.floor(gH / sectors), sW=math.floor(gW / sectors)}, forceFill)
    state.voronoi:RunVoronoi(3, 70, nil)
end

-- Main.
local skipInit = arg[1] == '!'

if arg[1] == '?' then arg[1] = 'tests/lml/01.h3pgm' end
if arg[1] == '!' then arg[1] = 'tests/paperMap.h3pgm' end

if arg[1] then
    local seed  = ConfigHandler.Read(arg[1])
    seed.config = ConfigHandler.Read('config.cfg')

    -- TODO: There's an inconsistency...
    seed._config = seed.config

    local steps = {}

    if skipInit then
        table.insert(steps, step_initSeed)
    else
        table.insert(steps, step_initParams)
    end

    table.insert(steps, step_initPaths)
    table.insert(steps, step_initLogging)

    if not skipInit then
        table.insert(steps, step_dump)

        table.insert(steps, step_initLML)
        table.insert(steps, step_dump)
    end

    table.insert(steps, step_initMLML)
    table.insert(steps, step_dump)

    table.insert(steps, step_mds)
    table.insert(steps, step_dump)

    table.insert(steps, step_voronoi)
    table.insert(steps, step_dump)

    -- NOTE: This makes state renderable, i.e. .h3m-able
    table.insert(steps, step_parseWorld)
    table.insert(steps, step_dump)
    table.insert(steps, step_dumpH3M)

    table.insert(steps, step_SFP)
    table.insert(steps, step_dump)
    table.insert(steps, step_dumpH3M)

    table.insert(steps, step_ca)
    table.insert(steps, step_dump)
    table.insert(steps, step_dumpH3M)

    table.insert(steps, step_debugZoneSigns)
    table.insert(steps, step_dump)
    table.insert(steps, step_dumpH3M)

    table.insert(steps, step_saveH3M)

    generate(seed, steps)
else
    print('generate.lua h3pgm-file')
    print('  Example:')
    print('           lua ?')
    print('           lua tests/lml/01.h3pgm')
end
