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
  if dp.winning == 0 then
    dp.winning = rand(5)
  end
  if dp.water == 0 then
    dp.water = rand(4)
  end
  if dp.towns == 0 then
    dp.towns = rand(4)
  end
  if dp.monsters == 0 then
    dp.monsters = rand(5)
  end
  if dp.welfare == 0 then
    dp.welfare = rand(5)
  end
  if dp.branching == 0 then
    dp.branching = rand(5)
  end
  if dp.focus == 0 then
    dp.focus = rand(5)
  end
  if dp.transitivity == 0 then
    dp.transitivity = rand(5)
  end
  if dp.locations == 0 then
    dp.locations = rand(5)
  end
  if dp.zonesize == 0 then
    dp.zonesize = rand(5)
  end
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

