local function apply (board, position, pattern)
    for y = 1, pattern.y do
    for x = 1, pattern.x do
        local tx = position.x + x - pattern.b
        local ty = position.y + y - pattern.a

        if board[ty] and board[ty][tx] then
            local cell = pattern.pattern[y]:sub(x, x)

            if cell == '#' then board[ty][tx] = 3 end
            if cell == '.' then board[ty][tx] = 2 end
            if cell == '_' then board[ty][tx] = 1 end
        end
    end
    end
end

local function feature (pattern)
    local x = #pattern[1]
    local y = #pattern

    local a
    local b

    for i = 1, y do
    for j = 1, x do
        if pattern[i]:sub(j, j) == '.' then
            a = i
            b = j
        end
    end
    end

    local text = {y .. ' ' .. x}

    for _ = 1, y do
        table.insert(text, pattern[_])
    end

    table.insert(text, (a - 1) .. ' ' .. (b - 1))
    table.insert(text, '')

    return {a = a, b = b, x = x, y = y, pattern = pattern, text = table.concat(text, '\n')}
end

local patterns = {
    mine = {
        sawmill = feature{
            '_###',
            '##.#'
        }
    },

    town = feature{
        '_###_',
        '#####',
        '##.##'
    },

    zero = feature{'.'}
}

return {apply = apply, patterns = patterns}
