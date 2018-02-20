local Graph = require'graph/Graph'
local Productions = require'grammar/Productions'
local RNG = require'Random'

local GraphGenerator = {}

local rand = RNG.Random




--- Computes mine features for given set of zones
-- @param state H3pgm state
-- @param classes List of all zones info within the map (as Class objects)
-- @param towns List of all Towns (Feature objects) within the map
-- @return List of all Mines (Feature objects) within the map
local function ComputeMineFeatures(state, classes, towns)
  local dp = state.paramsDetailed
  local cfg = state.config
  local znum = dp.zonesnum
 
  
  print (string.format('[INFO] <lmlInitializer> Mines: Player(base,primary,gold)=%d,%d,%d/%d;  Other(base,primary,gold)=%d,%d,%d/%d; RANDOM local=%d/%d, buffer=%d/%d', 
      playerbase, playerprime, playergold, #playertowns, otherbase, otherprime, othergold, #othertowns, locrandom, loczones, bufrandom, bufzones))
  
  return mines
end
-- ComputeMineFeatures


--- Iterator providing grammar productions randomized by priorty weights
-- @param state H3pgm state
-- @param productions Table containing production functions (grammar/Productions)
-- @return Iterfunction providing name of the next chosen production
local function ProductionIterator(state, productions)
  local dp = state.paramsDetailed
  local grammar = state.config.Grammar
  
  local map = {}
  for name, weight in pairs(grammar) do
    if type(weight) == 'string' then -- parameter name as weight
      map[name] = dp[weight]
    elseif type(weight) == 'number' and weight > 0 then -- raw number as weight
      map[name] = weight
    end
  end
  return function () 
              local choice = RNG.RouletteWheel(map)
              map[choice] = nil
              return choice
            end 
end
-- ProductionIterator

--- Function generates 'lmlGraph' containing full LML graph
-- @param state H3pgm state containing 'lmlInitialNode', 'config' and optionally 'userparamsDetailed' keys, which is extended by 'lmlGraph'
function GraphGenerator.Generate(state)  

  local graph = Graph.Initialize(state.lmlInitialNode)
  local x = ProductionIterator(state, Productions)
  
  print ('lalala')
  --local classes, zonelevels = ComputeZoneLevels(state)
  
  --[[
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
  --]]
  
end
-- GraphGenerator.Generate


return GraphGenerator