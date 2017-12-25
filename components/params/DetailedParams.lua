local DetailedParams = {}
local DetailedParams_mt = { __index = DetailedParams, __metatable = "Access resticted." }

local rand = math.random


--- Function randomizes values for which user choose 0 and player castles.
-- @param state H3pgm state (modifying state.detailedParams)
local function RandomizeNotChosen(state)
  local dp = state.detailedParams
  for i, p in ipairs(dp.players) do
    local np = {id=p.id, team=p.team, computerOnly=p.computerOnly}
    if #p.castle>0 then
      np.castle = p.castle[rand(#p.castle)]
    else
      np.castle = nil
    end
    dp.players[i] = np
  end
  local function randIfZero(n, range)
    if n == 0 then return rand(range) end
    return n
  end
  dp.winning = randIfZero(dp.winning, 5)
  dp.water = randIfZero(dp.water, 4)
  dp.towns = randIfZero(dp.towns, 4)
  dp.monsters = randIfZero(dp.monsters, 5)
  dp.welfare = randIfZero(dp.welfare, 5)
  dp.branching = randIfZero(dp.branching, 5)
  dp.focus = randIfZero(dp.focus, 5)
  dp.transitivity = randIfZero(dp.transitivity, 5)
  dp.locations = randIfZero(dp.locations, 5)
  dp.zonesize = randIfZero(dp.zonesize, 5)
end


--- Function generates 'detailedParams' based on user's wishes about the generated map (also overrides generated values with the ones in 'userDetailedParams' if necessary)
-- @param state H3pgm state containing 'userMapParams', 'config' and optionally 'userDetailedParams' keys, which is extended by 'detailedParams'
function DetailedParams.Generate(state)
  if not state.userMapParams then
    error('Given h3pgm state do not contain userMapParams.')
  end
  
  local dp = {}
  for k, v in pairs(state.userMapParams) do
    dp[k] = state.userMapParams[k]
  end
  
  if dp.seed == 0 then
    dp.seed = os.time()
  end
  math.randomseed(dp.seed)
  state.detailedParams = dp
  
  RandomizeNotChosen(state)
  
  
  -- todo
  -- potem mamy zbiór podfunkcji nadpisujący rózne konkretne wartości detailedParams (liczby zon, liczby zamków, itd, itp)
  
end

return DetailedParams

