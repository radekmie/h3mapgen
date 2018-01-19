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


--- Sets basic information: map width and height, difficulty
-- @param state H3pgm state (modifying state.detailedParams)
local function SetBasicInformation(state)
  local dp = state.detailedParams
  
  local side = 0
  if     dp.size ==  'S' then side =  36
  elseif dp.size ==  'M' then side =  72 
  elseif dp.size ==  'X' then side = 108
  elseif dp.size == 'XL' then side = 144
  end
  dp.width = side
  dp.height = side
  
  -- Map Difficulty: Easy, Normal, Hard, Exper, Impossible
  -- 6-welfare / monsters  (plus locations: 1-hard, 5-easy)
  --    1   2   3   4   5
  -- 5  N   H  H/E E/I  I
  -- 4  N  N   H  H/E 
  -- 3  E   N  N     
  -- 2  E   E   
  -- 1  E
  local tmpdiff = (6-dp.welfare) + dp.monsters + (dp.locations <=2 and 0.5 or 0)
  local difficulty = ''
  if     tmpdiff >= 9.5 then difficulty = 'Impossible'
  elseif tmpdiff >= 8.5 then difficulty = 'Expert'
  elseif tmpdiff >= 7.0 then difficulty = 'Hard'
  elseif tmpdiff >= 5.0 then difficulty = 'Normal'
  else                       difficulty = 'Easy'
  end
  dp.difficulty = difficulty 
end


--- todo
-- @param state H3pgm state (modifying state.detailedParams)
local function XXX(state)
  local dp = state.detailedParams
  
  
  
  -- todo zones estimation
  
  local factor = (dp.width*dp.height)/(36*36)
  
  -- OnMapZones (2level=avg*1.5): 
  --    S:  3- 5 /  4- 8 ; avg  4/ 6  (+-1 / +- 2)
  --    M: 14-18 / 20-28 ; avg 16/24  (+-2 / +- 4)
  --    L: 
  
  print (factor)
  
end

--- Function generates 'detailedParams' based on user's wishes about the generated map (also overrides generated values with the ones in 'userDetailedParams' if necessary)
-- @param state H3pgm state containing 'userMapParams', 'config' and optionally 'userDetailedParams' keys, which is extended by 'detailedParams'
function DetailedParams.Generate(state)  
  local dp = {}
  for k, v in pairs(state.userMapParams) do
    if type(state.userMapParams[k]) ~= 'table' then
      dp[k] = state.userMapParams[k]
    else
      dp[k] = {table.unpack(state.userMapParams[k])}
    end
  end
  
  if dp.seed == 0 then
    dp.seed = os.time()
  end
  math.randomseed(dp.seed)
  state.detailedParams = dp
  
  RandomizeNotChosen(state)
  
  SetBasicInformation(state)
  XXX(state)
  
  -- todo
  -- potem mamy zbiór podfunkcji nadpisujący rózne konkretne wartości detailedParams (liczby zon, liczby zamków, itd, itp)
  
end

return DetailedParams

