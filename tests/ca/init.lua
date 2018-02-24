-- Either set it here or in LUA_CPATH
package.cpath = package.cpath .. ';components/ca/?.so'

-- Yay!
local ca = require('ca')

local board1 = {
  0, 0, 0, 3, 0, 0, 0, 3,
  0, 1, 0, 0, 0, 1, 0, 0,
  0, 0, 1, 0, 0, 0, 1, 0,
  0, 0, 0, 2, 0, 0, 0, 2,
  0, 0, 0, 3, 0, 0, 0, 3,
  0, 1, 0, 0, 0, 1, 0, 0,
  0, 0, 1, 0, 0, 0, 1, 0,
  0, 0, 0, 2, 0, 0, 0, 2
}

local board2 = ca.run(board1, 'moore', 0.5, 3, 2, 0)
local result = {}

for y = 1, 8 do
  local row = {}

  for x = 1, 8 do
    table.insert(row, board2[y * 8 + x])
  end

  table.insert(result, row)
end

for y = 1, 8 do
  print(table.concat(result[y], ' '))
end
