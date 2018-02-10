local Random = {}

Random.Random = math.random

Random.SetSeed = math.randomseed

--- Rounds given number up or down with the probability dependent on its fractional part
-- @param x Number to round
-- @return Rounded integer
function Random.RandomRound(x)
  local i, f = math.modf (x)
  if math.random() > f then i = i + 1 end
  return i
end
-- Random.RandomRound


--- Returns uniform integer neighbor from (floor, ceil) if float, (x-1, x, x+1) if integer
-- @param x Number to round
-- @return Random integer neighbor
function Random.UniformNeighbour(x)
  if math.type(x) == 'integer' then
    return math.random(x-1, x+1)
  else
    return math.floor(x) + math.random(0,1)
  end
end
-- Random.UniformNeighbour

--- Check if we can pass the test with given threshold and limit (both can be >0 floats)
-- @param threshold Value we need to overcome
-- @param limit Maximal number we can draw
-- @return True iff rand(0, limit) > threshold
function Random.ThresholdPass(threshold, limit)
  return math.random() > threshold / limit 
end
-- Random.ThresholdPass



-- todo - choice

-- todo WeightedChoice


return Random