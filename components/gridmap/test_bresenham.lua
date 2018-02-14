local GridMap = require('GridMapSeparation/GridMap')

local function test_bresenham ()
  print(os.date("%Y %m %d %H %M %S"))
  local gdat = {}
  gdat[1] = {x=2, y=4, neighbors={4}, size=8}
  gdat[2] = {x=4, y=7, neighbors={3}, size=8}
  gdat[3] = {x=1, y=1, neighbors={2,5,6}, size=8}
  gdat[4] = {x=7, y=6, neighbors={1}, size=8}
  gdat[5] = {x=7, y=3, neighbors={3}, size=8}
  gdat[6] = {x=7, y=7, neighbors={3}, size=8}
  local gridMap = GridMap.Initialize(gdat)
  local dimensions = {}
  dimensions.gW = 64
  dimensions.gH = 64
  dimensions.sW = 8
  dimensions.sH = 8
  gridMap:Generate(dimensions)
  gridMap:ShowSectors('_test/sectors'..os.date("%Y_%m_%d %H-%M-%S")..'.txt')
  gridMap:RunVoronoi(3, 70, 1)
  gridMap:ShowGrid('_test/grid'..os.date("%Y_%m_%d %H-%M-%S")..'.txt')
end

test_bresenham()
