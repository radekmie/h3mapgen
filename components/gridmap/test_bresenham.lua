local GridMap = require('GridMapSeparation/GridMap')
local mdsRescale = require('mdsAdapter')

local function test_bresenham ()
  print(os.date("%Y %m %d %H %M %S"))
  local dimensions = {}
  dimensions.gW = 64
  dimensions.gH = 64
  dimensions.sW = 8
  dimensions.sH = 8

  local rescaleX = function(oldX)
    return mdsRescale(oldX, dimensions.sW)
  end
  local rescaleY = function(oldY)
    return mdsRescale(oldY, dimensions.sH)
  end

  local gdat = {}
  gdat[1] = {x=rescaleX(-1.3), y=rescaleY(-0.4), neighbors={4}, size=8}
  gdat[2] = {x=rescaleX(-0.4), y=rescaleY(1.3), neighbors={3}, size=8}
  gdat[3] = {x=rescaleX(-1.9), y=rescaleY(-1.9), neighbors={2,5,6}, size=8}
  gdat[4] = {x=rescaleX(1.3), y=rescaleY(0.8), neighbors={1}, size=8}
  gdat[5] = {x=rescaleX(1.3), y=rescaleY(-0.8), neighbors={3,6}, size=8}
  gdat[6] = {x=rescaleX(1.3), y=rescaleY(1.3), neighbors={3,5}, size=8}
  local gridMap = GridMap.Initialize(gdat)
  gridMap:Generate(dimensions)
  gridMap:ShowSectors('_test/sectors'..os.date("%Y_%m_%d %H-%M-%S")..'.txt')
  gridMap:RunVoronoi(3, 70, 1)
  gridMap:ShowGrid('_test/grid'..os.date("%Y_%m_%d %H-%M-%S")..'.txt')
end

test_bresenham()
