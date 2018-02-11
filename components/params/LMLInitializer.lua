local Class = require'graph/Class'
local Feature = require'graph/Feature'
local RNG = require'Random'

local LMLInitializer = {}

local rand = RNG.Random


--- Computes types and levels of zones for the LML.
-- @param state H3pgm state
-- @return List of all zones info within the map (as Class objects), and info containing levels of each type's levels in handy format
local function ComputeZoneLevels(state)
  local dp = state.paramsDetailed
  local cfg = state.config
  local znum = dp.zonesnum
  
  local classes = {}
  
  -- we set up minimal local zone level (which is 1 except low-probability hardcore cases ^^)
  local minLocal = 1
  local worseStartChance = 0
  if dp.difficulty.str == 'Impossible' then worseStartChance=0.3 end
  if dp.difficulty.str == 'Expert' then worseStartChance=0.1 end
  if rand() < worseStartChance then minLocal = 2 end
  --print (worseStartChance, minLocal)
  
  -- we set up max (buffer) zone level depending on the map size
  local maxBufferEstim = minLocal + (cfg.MaxZoneLevel-minLocal)/4*dp.size.ord - 1
  local maxBuffer = RNG.UniformNeighbour(maxBufferEstim)
  --print (maxBufferEstim, maxBuffer)

  -- 'borderline' between PvP and PvE, higher PvP focus lower the border
  local pvpBorder = minLocal + (maxBuffer-minLocal)/6*dp.focus
  --print (pvpBorder)
  
  local minBuffer = RNG.UniformNeighbour(pvpBorder)
  if minBuffer == maxBuffer then minBuffer = maxBuffer - 1 end
  if minBuffer == minLocal then minBuffer = minLocal + 1 end
  
  -- Always try to insert max zone (goal or buffer) and min zone
  local goalReq = dp.winning==2 or dp.winning==3 or dp.winning==4
  if znum.singleBuffer > 0 then table.insert(classes, Class.New(goalReq and 'GOAL' or 'BUFFER', maxBuffer)) end
  if znum.singleBuffer > 1 then table.insert(classes, Class.New('BUFFER', minBuffer)) end

  local remBuf = znum.singleBuffer - 2;
  local bufSlots = maxBuffer - minBuffer - 1
  if remBuf >= bufSlots then
    for lvl=minBuffer+1, maxBuffer-1 do -- insert new zone for each level slot
      table.insert(classes, Class.New('BUFFER', lvl))
    end
    remBuf = remBuf - bufSlots
    for i=1,remBuf do -- remaining zones draw uniformly
      table.insert(classes, Class.New('BUFFER', rand(minBuffer, maxBuffer)))
    end
  else
    local step = (maxBuffer-minBuffer)/(remBuf+1) -- all zones draw 'randomized-should-be-quite-uniformly' within the buckets
    for i=1,remBuf do
      table.insert(classes, Class.New('BUFFER', RNG.UniformNeighbour(minBuffer+i*step)))
    end
  end
  
  local maxLocal = RNG.UniformNeighbour(pvpBorder)
  if maxLocal == minLocal then maxLocal = minLocal + 1 end
  if znum.singleLocal > 0 then table.insert(classes, Class.New('LOCAL', minLocal)) end
  if znum.singleLocal > 1 then table.insert(classes, Class.New('LOCAL', maxLocal)) end
  
  local remLoc = znum.singleLocal - 2;
  local locSlots = maxLocal - minLocal - 1
  
  if remLoc >= locSlots then
    for lvl=minLocal+1, maxLocal-1 do -- insert new zone for each level slot
      table.insert(classes, Class.New('LOCAL', lvl))
    end
    remLoc = remLoc - locSlots
    maxLocal = rand(maxLocal, math.max(maxLocal, math.ceil(maxLocal+maxBuffer))) -- higher max local for random zones
    for i=1,remLoc do -- remaining zones draw uniformly
      table.insert(classes, Class.New('LOCAL', rand(minLocal, maxLocal)))
    end
  else
    local step = (maxLocal-minLocal)/(remLoc+1) -- all zones draw 'randomized-should-be-quite-uniformly' within the buckets
    for i=1,remLoc do
      table.insert(classes, Class.New('LOCAL', RNG.UniformNeighbour(minLocal+i*step)))
    end
  end

  -- DEPRECATED
  -- Teleports (i.e. two-way monoliths) - one roll for each ZonesBatchPerTeleport zones in single+buffer; level should be close to pvpBorder
  --for i=1, math.min(4, math.max(1, math.ceil((znum.singleBuffer+znum.singleLocal)/cfg.TeleportZonesPerBatch))) do
  --  if RNG.ThresholdPass(dp.branching, cfg.TeleportRollLimit) then
  --    table.insert(classes, Class.New('TELEPORT', RNG.UniformNeighbour(pvpBorder)))
  --  end
  --end
  
  local _locs, _bufs, _goals = {}, {}, {}
  for _, c in ipairs(classes) do
    if c.type=='LOCAL' then table.insert(_locs, c.level)
    elseif c.type=='BUFFER' then table.insert(_bufs, c.level)
    elseif c.type=='GOAL' then table.insert(_goals, c.level) end
  end
  table.sort(_locs)
  table.sort(_bufs)
  print (string.format('[INFO] <lmlInitializer> Zones: LOCAL=%s; BUFFER=%s; GOAL=%s', table.concat(_locs,','), table.concat(_bufs,','), table.concat(_goals,',')))
  
  return classes, {locals=_locs, buffers=_bufs, goals=_goals, pvpBorder=pvpBorder}
end
-- ComputeZoneLevels


--- Computes town features for given set of zones
-- @param state H3pgm state
-- @param zonelevels Information about available zones: their types and levels
-- @return List of all Towns (Feature objects) within the map
local function ComputeTownFeatures(state, zonelevels)
  local dp = state.paramsDetailed
  local cfg = state.config
  local znum = dp.zonesnum
  
  local towns = {}
  
  local startChance = cfg.StartTownChance[dp.towns]
  local locChance = cfg.LocalTownChance[dp.towns]
  local bufChance = cfg.BufferTownChance[dp.towns]
  --print (startChance, locChance, bufChance)

  local startTowns = 1
  table.insert(towns, Feature.New('TOWN', 'START', Class.New('LOCAL', zonelevels.locals[1])) )
  
  local locTowns = 0
  for i=2,math.min(3,#zonelevels.locals) do -- special treatment for the next two zones
    if #zonelevels.locals > 2*i and rand() < startChance then
      table.insert(towns, Feature.New('TOWN', 'START', Class.New('LOCAL', zonelevels.locals[i])) )
      startTowns = startTowns + 1
    elseif rand() < locChance then
      table.insert(towns, Feature.New('TOWN', RNG.RouletteWheel(cfg.LocalTownType), Class.New('LOCAL', zonelevels.locals[i])) )
      locTowns = locTowns + 1
    end
  end
  
  for i=4,#zonelevels.locals do 
    if rand() < locChance then
      table.insert(towns, Feature.New('TOWN', RNG.RouletteWheel(cfg.LocalTownType), Class.New('LOCAL', zonelevels.locals[i])) )
      locTowns = locTowns + 1
    end
  end
  
  local bufTowns = 0
  for _, lvl in ipairs(zonelevels.buffers) do
    if rand() < bufChance then
      table.insert(towns, Feature.New('TOWN', RNG.RouletteWheel(cfg.BufferTownType), Class.New('BUFFER', lvl)) )
      bufTowns = bufTowns + 1
    end
  end
  
  local goalTowns = 0
  for _, lvl in ipairs(zonelevels.goals) do
    if dp.winning==2 or rand() < bufChance then -- must be when town-capture, otherwise like normal buffer
      table.insert(towns, Feature.New('TOWN', RNG.RouletteWheel(cfg.BufferTownType), Class.New('GOAL', lvl)) )
      goalTowns = goalTowns + 1
    end
  end
  
    print (string.format('[INFO] <lmlInitializer> Towns: START=%d (%.1f%%); LOCAL=%d (%.1f%%); BUFFER=%d (%.1f%%); GOAL=%d', 
        startTowns, 100*startTowns/#zonelevels.locals, locTowns, 100*locTowns/#zonelevels.locals, bufTowns, 100*bufTowns/#zonelevels.buffers, goalTowns))
  
  return towns
end
-- ComputeTowns


--- Function generates 'lmlInitialNode' containing initial node for LML stage.
-- @param state H3pgm state after GenerateDetailedParams function applied (requires 'paramsDetailed')
function LMLInitializer.Generate(state)  
  
  

  local classes, zonelevels = ComputeZoneLevels(state)
  
  local features = {}
  local towns = ComputeTownFeatures(state, zonelevels)
  for _, town in ipairs(towns) do table.insert(features, town) end
  

  -- todo mines
  -- todo outers
  -- todo teleports
  -- todo water+whirlpool
  
  
  
  state.lmlInitialNode = {classes=classes, features=features}
end
-- LMLInitializer.Generate


return LMLInitializer