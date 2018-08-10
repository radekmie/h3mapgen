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
  local minLocal = cfg.MinLocalZoneLevel
  local worseStartChance = 0
  if dp.difficulty.str == 'Impossible' then worseStartChance=0.3 end
  if dp.difficulty.str == 'Expert' then worseStartChance=0.1 end
  if rand() < worseStartChance then minLocal = minLocal + 1 end
  --print (worseStartChance, minLocal)

  -- we set up max (buffer) zone level depending on the map size
  local mapSizes = 4 -- S, M, L, XL
  local maxBufferEstim = minLocal + (cfg.MaxZoneLevel-minLocal)/mapSizes*dp.size.ord - 1
  local maxBuffer = RNG.UniformNeighbour(maxBufferEstim)
  --print (maxBufferEstim, maxBuffer)

  -- 'borderline' between PvP and PvE, higher PvP focus lower the border
  local pvpBuckets = 6 -- _ 1 _ 2 _ 3 _ 4 _ 5 _
  local pvpBorder = minLocal + (maxBuffer-minLocal)/pvpBuckets*dp.focus
  --print (pvpBorder)

  local minBuffer = RNG.UniformNeighbour(pvpBorder)
  if minBuffer >= maxBuffer then minBuffer = maxBuffer - 1 end
  if minBuffer <= minLocal then minBuffer = minLocal + 1 end

  -- Always try to insert max zone (goal or buffer) and min zone
  local goalReq = dp.winning==2 or dp.winning==3 or dp.winning==4
  if znum.singleBuffer > 0 then table.insert(classes, Class.New(goalReq and 'GOAL' or 'BUFFER', maxBuffer)) end
  if znum.singleBuffer > 1 then table.insert(classes, Class.New('BUFFER', minBuffer)) end

  local remBuf = znum.singleBuffer - 2
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

  local remLoc = znum.singleLocal - 2
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
      table.insert(towns, Feature.New('TOWN', 'PLAYER', Class.New('LOCAL', zonelevels.locals[i])) )
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
-- ComputeTownFeatures


--- Computes mine features for given set of zones
-- @param state H3pgm state
-- @param classes List of all zones info within the map (as Class objects)
-- @param towns List of all Towns (Feature objects) within the map
-- @return List of all Mines (Feature objects) within the map
local function ComputeMineFeatures(state, classes, towns)
  local dp = state.paramsDetailed
  local cfg = state.config
  local znum = dp.zonesnum

  local mines = {}

  local playertowns, othertowns, notowns = {}, {}, {}
  for _, c in ipairs(classes) do
    table.insert(notowns, c)
  end
  for _, town in ipairs(towns) do
    if town.value == 'START' or town.value=='PLAYER' then
      table.insert(playertowns, town.class)
    else
      table.insert(othertowns, town.class)
    end
    for i, class in ipairs(notowns) do
      if class==town.class then
        table.remove(notowns, i)
        break
      end
    end
  end

  local playerbase, playerprime, playergold = 0, 0, 0
  for _, class in ipairs(playertowns) do
    if rand() < cfg.MineBasePlayerTownChance[dp.welfare] then
      table.insert(mines, Feature.New('MINE', 'BASE', class) )
      playerbase = playerbase + 1
    end
    if rand() < cfg.MinePrimaryPlayerTownChance[dp.welfare] then
      table.insert(mines, Feature.New('MINE', 'PRIMARY', class) )
      playerprime = playerprime + 1
    end
    if rand() < cfg.MineGoldPlayerTownChance[dp.welfare] then
      table.insert(mines, Feature.New('MINE', 'GOLD', class) )
      playergold = playergold + 1
    end
  end

  local otherbase, otherprime, othergold = 0, 0, 0
  for _, class in ipairs(playertowns) do
    if rand() < cfg.MineBaseOtherTownChance[dp.welfare] then
      table.insert(mines, Feature.New('MINE', 'BASE', class) )
      otherbase = otherbase + 1
    end
    if rand() < cfg.MinePrimaryOtherTownChance[dp.welfare] then
      table.insert(mines, Feature.New('MINE', 'PRIMARY', class) )
      otherprime = otherprime + 1
    end
    if rand() < cfg.MineGoldOtherTownChance[dp.welfare] then
      table.insert(mines, Feature.New('MINE', 'GOLD', class) )
      othergold = othergold + 1
    end
  end

  local locrandom, loczones, bufrandom, bufzones = 0, 0, 0, 0
  for _, class in ipairs(notowns) do
    if class.type=='LOCAL' then
      loczones = loczones + 1
      for i=1, cfg.MineRandomLocalMax[dp.welfare] do
        if rand() < cfg.MineRandomLocalChance[dp.welfare] then
          table.insert(mines, Feature.New('MINE', 'RANDOM', class) )
          locrandom = locrandom + 1
        end
      end
    elseif class.type=='BUFFER' or class.type=='GOAL' then
      bufzones = bufzones + 1
      for i=1, cfg.MineRandomBufferMax[dp.welfare] do
        if rand() < cfg.MineRandomBufferChance[dp.welfare] then
          table.insert(mines, Feature.New('MINE', 'RANDOM', class) )
          bufrandom = bufrandom + 1
        end
      end
    end
  end

  print (string.format('[INFO] <lmlInitializer> Mines: Player(base,primary,gold)=%d,%d,%d/%d;  Other(base,primary,gold)=%d,%d,%d/%d; RANDOM local=%d/%d, buffer=%d/%d',
      playerbase, playerprime, playergold, #playertowns, otherbase, otherprime, othergold, #othertowns, locrandom, loczones, bufrandom, bufzones))

  return mines
end
-- ComputeMineFeatures


--- Computes outer features for given set of zones
-- @param state H3pgm state
-- @param zonelevels Information about available zones: their types and levels
-- @return List of all Outers (Feature objects) within the map
local function ComputeOuterFeatures(state, zonelevels)
  local dp = state.paramsDetailed
  local cfg = state.config
  local znum = dp.zonesnum

  local outers = {}

  local bufouters = {}
  local cutpoint = math.ceil(#zonelevels.buffers*cfg.OuterBufferFixed)
  for i, lvl in ipairs(zonelevels.buffers) do -- first outer
    if i <= cutpoint or lvl == zonelevels.buffers[1] then
      table.insert(bufouters, lvl)
    elseif rand() < cfg.OuterBufferRemainingChance then
      table.insert(bufouters, lvl)
    end
  end
  for i=1, math.min(cfg.OuterBufferExtraMax[dp.branching], #dp.players-1) do -- remaining outers
    for _, lvl in ipairs(zonelevels.buffers) do
      if rand() < cfg.OuterBufferExtraChance[dp.branching] then
        table.insert(bufouters, lvl)
      end
    end
  end
  for _, lvl in ipairs(bufouters) do
    local outerlvl = math.min(lvl+RNG.RouletteWheel(cfg.OuterBufferDifficulty), cfg.MaxZoneLevel)
    table.insert(outers, Feature.New('OUTER', outerlvl, Class.New('BUFFER', lvl)) )
  end

  local allowedlocals = {}
  local locouters = {}
  for _, lvl in ipairs(zonelevels.locals) do -- filtering should-be-safe safe levels
    if lvl >= cfg.OuterLocalSafetyLevel[dp.focus] then
      table.insert(allowedlocals, lvl)
    end
  end
  for i=1, math.min(cfg.OuterLocalMax[dp.branching], #dp.players-1) do -- randomizing locals
    for _, lvl in ipairs(zonelevels.locals) do
      if rand() < cfg.OuterLocalChance[dp.branching] then
        table.insert(locouters, lvl)
      end
    end
  end
  for _, lvl in ipairs(locouters) do
    local outerlvl = math.min(RNG.RandomRound(zonelevels.pvpBorder + (zonelevels.pvpBorder - lvl) + cfg.OuterLocalLevelBonus[dp.focus]), cfg.MaxZoneLevel)
    table.insert(outers, Feature.New('OUTER', outerlvl, Class.New('LOCAL', lvl)) )
  end

  -- Safeguard outer addition when there is odd number of out-connections in MLML or there are no outers at all
  while #outers==0 or (#outers*#dp.players) % 2 == 1 or #outers < 2 do -- (#outers * 2 < #dp.players) do -- Piotrek said that 2 is enough
    if #zonelevels.buffers > 0 then
      local lvl = zonelevels.buffers[rand(#zonelevels.buffers)]
      local outerlvl = math.min(lvl+RNG.RouletteWheel(cfg.OuterBufferDifficulty), cfg.MaxZoneLevel)
      table.insert(outers, Feature.New('OUTER', outerlvl, Class.New('BUFFER', lvl)) )
    else
      local lvl = zonelevels.locals[rand(#zonelevels.locals)]
      local outerlvl = math.min(RNG.RandomRound(zonelevels.pvpBorder + (zonelevels.pvpBorder - lvl) + cfg.OuterLocalLevelBonus[dp.focus]), cfg.MaxZoneLevel)
      table.insert(outers, Feature.New('OUTER', outerlvl, Class.New('LOCAL', lvl)) )
    end
  end

  print (string.format('[INFO] <lmlInitializer> Outers: LOCAL=%d (%.1f%%); BUFFER=%d (%.1f%%)',
        #locouters, 100*#locouters/#zonelevels.locals, #bufouters, 100*#bufouters/#zonelevels.locals))

  return outers
end
-- ComputeOuterFeatures


--- Computes teleport features for given set of zones
-- @param state H3pgm state
-- @param zonelevels Information about available zones: their types and levels
-- @return List of all Teleports (Feature objects) within the map
local function ComputeTeleportFeatures(state, zonelevels)
  local dp = state.paramsDetailed
  local cfg = state.config
  local znum = dp.zonesnum

  local teleports = {}

  -- range for teleport levels
  local minLvl = math.ceil(zonelevels.pvpBorder)
  local maxLvl = minLvl
  if #zonelevels.buffers > 0 then
    maxLvl = zonelevels.buffers[math.floor(#zonelevels.buffers / 2) + 1]
    if maxLvl < minLvl then minLvl = maxLvl end
  end
  --print(minLvl, maxLvl)

  local classes = {}
  local safeguard = 0 -- we limit 'closeness' of teleport to starting zones
  if     dp.focus == 3 then safeguard = 1
  elseif dp.focus == 4 then safeguard = 2
  elseif dp.focus == 5 then safeguard = cfg.MaxZoneLevel -- no teleports in local zones
  end
  for _, lvl in ipairs(zonelevels.locals) do -- locals higher than the lowest
    if lvl > zonelevels.locals[1] + safeguard then table.insert(classes, {type='LOCAL', level=lvl}) end
  end
  for _, lvl in ipairs(zonelevels.buffers) do -- buffers lower than the highest
    if lvl < zonelevels.buffers[#zonelevels.buffers] then table.insert(classes, {type='BUFFER', level=lvl}) end
  end

  local info = {{}, {}, {}, {}}
  -- Teleports (i.e. two-way monoliths) - one roll for each ZonesBatchPerTeleport zones in single+buffer; level should be close to pvpBorder
  for id=1, math.min(4, math.max(1, math.ceil((znum.singleBuffer+znum.singleLocal)/cfg.TeleportZonesPerBatch))) do
    for i=1,math.min(#classes, cfg.TeleportSingleMax) do
      if #teleports == #classes then break end -- OK, not too many, that's enough
      if RNG.ThresholdPass(6-dp.branching, cfg.TeleportRollLimit) then
        table.insert(teleports, Feature.New('TELEPORT', {id=id, level=rand(minLvl, maxLvl)}, Class.New(RNG.Choice(classes))) )
        table.insert(info[id], teleports[#teleports].class:shortstr())
      end
    end
  end

  local tnum=0
  for i=1,#info do
    if #info[i]>0 then tnum = tnum+1 end
    info[i] = table.concat(info[i], ',')
  end
  print (string.format('[INFO] <lmlInitializer> Teleports: %d=%s', tnum, table.concat(info, '; ')))

  return teleports
end
-- ComputeTeleportFeatures


--- Function generates 'lmlInitialNode' containing initial node for LML stage.
-- @param state H3pgm state after GenerateDetailedParams function applied (requires 'paramsDetailed')
function LMLInitializer.Generate(state)

  local classes, zonelevels = ComputeZoneLevels(state)

  local features = {}

  local towns = ComputeTownFeatures(state, zonelevels)
  for _, town in ipairs(towns) do table.insert(features, town) end

  local mines = ComputeMineFeatures(state, classes, towns)
  for _, mine in ipairs(mines) do table.insert(features, mine) end

  local outers = ComputeOuterFeatures(state, zonelevels)
  for _, outer in ipairs(outers) do table.insert(features, outer) end

  local teleports = ComputeTeleportFeatures(state, zonelevels)
  for _, teleport in ipairs(teleports) do table.insert(features, teleport) end

  state.lmlInitialNode = {classes=classes, features=features}
end
-- LMLInitializer.Generate


return LMLInitializer
