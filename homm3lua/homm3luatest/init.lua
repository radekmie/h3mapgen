-- Either set it here or in LUA_CPATH
package.cpath = package.cpath .. ';dist/?.so;../dist/?.so'

local function text2map (pathInData, pathInText, pathOut)
    -- Data
    local env = {}
    assert(loadfile(pathInData, nil, env))()
    local MLML = env.MLML_graph

    -- Text
    local file = assert(io.open(pathInText))
    local h, w, data = file:read('*number', '*number', '*all')
    file:close()

    if h ~= w then
        error('Map have to be a square!')
    end

    -- Yay!
    local homm3lua = require('homm3lua')

    local size = nil
        if w <= homm3lua.SIZE_SMALL      then size = homm3lua.SIZE_SMALL
    elseif w <= homm3lua.SIZE_MEDIUM     then size = homm3lua.SIZE_MEDIUM
    elseif w <= homm3lua.SIZE_LARGE      then size = homm3lua.SIZE_LARGE
    elseif w <= homm3lua.SIZE_EXTRALARGE then size = homm3lua.SIZE_EXTRALARGE
    else error('Map too big!') end

    local instance = homm3lua.new(homm3lua.FORMAT_ROE, size)

    instance:terrain(function (x, y, z)
        if x >= w or y >= w then
            return homm3lua.TERRAIN_WATER
        end

        local info = y * (w + 2) + x + 3 -- +2 for line breaks, +3 for the initial offset
        local char = data:sub(info, info)

        if char == '#' then instance:obstacle('Trees',  {x=x, y=y, z=z}) end
        if char == '$' then instance:obstacle('Cactus', {x=x, y=y, z=z}) end

        local code = char:byte() - ('a'):byte()

        for _, zone in pairs(MLML) do
            if zone.baseid == code then
                if zone.type == 'BUFFER' then
                    return homm3lua.TERRAIN_LAVA
                end

                return code % 7 -- 8 is reserved for the BUFFER zone
            end
        end

        -- NOTE: It should NOT happen, but... You know.
        return homm3lua.TERRAIN_GRASS
    end)

    instance:write(pathOut)
end

text2map('test.h3pgm', 'test.txt', 'test.h3m')
