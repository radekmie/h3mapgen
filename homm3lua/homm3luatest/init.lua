-- Either set it here or in LUA_CPATH
package.cpath = package.cpath .. ';dist/?.so;../dist/?.so;homm3lua/dist/?.so'

local function text2map (pathInData, pathInTerrain, pathInWorld, pathOut)
    -- Data
    local env = {}
    assert(loadfile(pathInData, nil, env))()
    local MLML = env.MLML_graph

    -- Terrain
    local file = assert(io.open(pathInTerrain))
    local h2, w2, terrain = file:read('*number', '*number', '*all')
    file:close()

    if h2 ~= w2 then
        error('Map have to be a square!')
    end

    -- World
    local file = assert(io.open(pathInWorld))
    local h1, w1, world = file:read('*number', '*number', '*all')
    file:close()

    if h1 ~= w1 then
        error('Map have to be a square!')
    end

    if h1 ~= h2 then
        error('Map terrain and world differ in size!')
    end

    -- Yay!
    local homm3lua = require('homm3lua')

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
        local zone = MLML[code]
        if zone then
            if zone.type == 'BUFFER' then
                return homm3lua.TERRAIN_LAVA
            end

            local firstplayer = nil
            for p, _ in pairs(zone.players) do firstplayer = p break end
            return firstplayer % 7 -- 8 is reserved for the BUFFER zone
            -- alternative version (based on the base id):
            --return zone.baseid % 7 -- 8 is reserved for the BUFFER zone
        end

        -- NOTE: It should NOT happen, but... You know.
        return homm3lua.TERRAIN_SUBTERRANEAN
    end)

    instance:write(pathOut)
end

if arg[1] ~= nil then
    text2map(table.unpack(arg))
end

