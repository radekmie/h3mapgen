local DetailedParams = {}
local DetailedParams_mt = { __index = DetailedParams, __metatable = "Access resticted." }

local rand = math.random
local MapSizeOrder = {S=1, M=2, L=3, XL=4}

--- Rounds given number up or down with the probability dependent on its fractional part
-- @param Number to round
-- @return Rounded integer
local function RandomRound(x)
  local i, f = math.modf (x)
  if rand() > f then i = i + 1 end
  return i
end
-- RandomRound


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
-- RandomizeNotChosen


--- Sets basic information: map width and height, difficulty, zoneSide
-- @param state H3pgm state (modifying state.detailedParams)
local function SetBasicInformation(state)
  local dp = state.detailedParams
  local cfg = state.config
  
  local side = 36 * MapSizeOrder[dp.size]
  dp.width = side
  dp.height = side
  
  -- Map Difficulty: Easy, Normal, Hard, Exper, Impossible
  -- 6-welfare / monsters  (plus locations: 1-hard, 5-easy)
  --    1   2   3   4   5
  -- 5  N   H  H/E E/I  I
  -- 4  N   N   H  H/E 
  -- 3  E   N   N     
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
  
  dp.zoneSide = cfg.StandardZoneSize + (dp.zonesize-3)*cfg.ZoneSizeStep -- userchoice-dependent tuning
  dp.zoneSide = dp.zoneSide + (MapSizeOrder[dp.size]-1) * cfg.ZoneSizeStep -- mapsize-dependent tuning
  
end
-- SetBasicInformation


--- Set number of local/buffer zones for LML (MLML)
-- @param state H3pgm state (modifying state.detailedParams)
local function SetNumberOfZones(state)
  local dp = state.detailedParams
  
  -- focus (strong PvP) 1:0-20; 2:20-40; 3:40-60; 4:60-80; 5:80-100 (Strong PvE)
  local localzonesprop = 0.01 * ((dp.focus-1)*20+rand(0,20))
  
  local multiallest = (dp.width*dp.height)/(dp.zoneSide*dp.zoneSide) -- basic estimation
  local rlimit = 2 ^ (MapSizeOrder[dp.size] - 1)
  if dp.underground then -- larger values for 2-level map
    multiallest = multiallest * 1.5 
    rlimit = rlimit * 1.5
  end 
  rlimit = math.tointeger(rlimit)
  multiallest = multiallest + rand(-rlimit, rlimit)
  if multiallest < #dp.players then multiallest = #dp.players end -- low-number edgecase safeguard
  multiallest = RandomRound(multiallest) -- we need integer from now on
  
  -- Returns estimation on number of singleplayer buffers maching known global estimation and given # of single local zones
  local function EstimateSingleBuffers(slocal) 
    local gbuf = multiallest - #dp.players * slocal
    return gbuf -- I've tried some functions to compute local buffer estimation but the fancy one actually reduced to this ;-)
  end
  
  local proportions = {} -- table with proportions for each possible number of local buffers
  for sloc=1, multiallest do
    local sbuf = EstimateSingleBuffers(sloc) 
    if sbuf < 0 then
      table.insert(proportions, -math.huge)
    else
      table.insert(proportions, sloc / (sloc+sbuf))
    end
  end
  
  -- we have to find the setting with proportion closest to the desired
  local bestdiff = math.huge
  local bestsloc = 1
  for i, v in ipairs(proportions) do
    local diff = math.abs(localzonesprop - v)
    if diff < bestdiff then
      bestdiff = diff
      bestsloc = i
    end
  end
  
  dp.zonesnum = {estimAll=multiallest, singleLocal=bestsloc, singleBuffer=EstimateSingleBuffers(bestsloc)}
  print (string.format('[INFO] <DetailedParams> Zones: multi_estim=%i, sLocal=%i, sBuffer=%i  (%s, %i players);  targetProp=%.3f, foundProp=%.3f', 
      multiallest, bestsloc, EstimateSingleBuffers(bestsloc), dp.size, #dp.players, localzonesprop, proportions[bestsloc]))
  
end
-- SetNumberOfZones


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
  SetNumberOfZones(state)
  
  -- todo
  -- potem mamy zbiór podfunkcji nadpisujący rózne konkretne wartości detailedParams (liczby zamków, priorytety produkcji, itd, itp)
  
end
-- DetailedParams.Generate


return DetailedParams