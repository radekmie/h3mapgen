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
  if math.type and math.type(x) == 'integer' then
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


--- Function for choosing  map key using the roulette wheel selection.
-- @param map Maps keys to (nonnegative, float) weights
-- @return Key of the chosen entry or nil if map is empty
function Random.RouletteWheel(map)
  local sum = 0
  for id, weight in pairs(map) do sum = sum + weight end
  if sum == 0 then return nil end
  local shot = math.random()*sum
  for key, weight in pairs(map) do
    if shot <= weight then
        return key
      else
        shot = shot - weight
      end
  end
  error('[ERROR] <Random.RouletteWheel> : No valid results.', 2)
end
-- Random.RouletteWheel


--- Return a random element from the non-empty sequence
-- @param seq Sequence of elements
-- @return Random element or nil if the sequence is empty
function Random.Choice(seq)
  if #seq==0 then return nil end
  return seq[math.random(#seq)]
end
-- Random.Choice


return Random
