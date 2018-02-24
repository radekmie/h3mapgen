-- Either set it here or in LUA_CPATH
package.cpath = package.cpath .. ';components/ca/?.so'

-- Yay!
local ca = require('ca')

local board1 = {
  {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
  {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
  {3, 3, 2, 0, 0, 0, 0, 0, 0, 3, 3, 3},
  {3, 3, 0, 2, 0, 0, 0, 0, 0, 3, 3, 3},
  {3, 3, 0, 0, 2, 0, 0, 0, 0, 3, 3, 3},
  {3, 3, 0, 0, 0, 2, 0, 0, 0, 3, 3, 3},
  {3, 3, 0, 0, 0, 0, 2, 0, 0, 3, 3, 3},
  {3, 3, 0, 0, 0, 0, 0, 2, 0, 3, 3, 3},
  {3, 3, 0, 0, 0, 0, 0, 0, 2, 3, 3, 3},
  {3, 3, 0, 0, 0, 0, 0, 0, 0, 2, 3, 3},
  {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
  {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3}
}

local board2 = ca.run(board1, 'moore', 0.5, 3, 2, 0)

for _, row in ipairs(board2) do
  print(table.concat(row, ' '))
end
