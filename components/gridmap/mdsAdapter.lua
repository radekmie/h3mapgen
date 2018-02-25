
local function mdsRescale(value, unitsNum)
  local mdsScale = 5.0
  -- rescale first so its in (0,1)
  local newVal = (value + mdsScale / 2.0) / mdsScale

  -- multiply by number of units in given axis so its in (0,unitsNum)
  newVal = newVal * unitsNum

  -- apply floor to give integer value, add 1 to keep lua numbering so its in [1,unitsNum]
  return math.floor(newVal) + 1
end

local function test()
  -- example values which give certain values.
  -- used as tool to help rewrite test_bresenham
  print(mdsRescale(-1.9, 8)) --1
  print(mdsRescale(-1.3, 8)) --2
  print(mdsRescale(-0.8, 8)) --3
  print(mdsRescale(-0.4, 8)) --4
  print(mdsRescale(0.4, 8)) --5
  print(mdsRescale(0.8, 8)) --6
  print(mdsRescale(1.3, 8)) --7
  print(mdsRescale(1.9, 8)) --8
end

return mdsRescale
