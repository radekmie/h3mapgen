local Random = {}

Random.Random = math.random

Random.SetSeed = math.randomseed

--- Rounds given number up or down with the probability dependent on its fractional part
-- @param Number to round
-- @return Rounded integer
function Random.RandomRound(x)
  local i, f = math.modf (x)
  if math.random() > f then i = i + 1 end
  return i
end
-- RandomRound


-- todo - choice

-- todo WeightedChoice


return Random