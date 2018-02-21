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
-- @param state H3pgm state containing 'lmlInitialNode', 'config' and 'userparamsDetailed' keys, which is extended by 'lmlGraph'
function GraphGenerator.Generate(state)  
  local cfg = state.config
  
  local graph = Graph.Initialize(state.lmlInitialNode)
  
  
  
  --if true or CONFIG.LML_verbose_debug then print('LML Generation started with grammar containing '..#grammar..' rules.') end -- get rid of global CONFIG usage
  --if debuging_path then self:Drawer():Draw(debuging_path..'-'..0) end
  
  local c, id, fc = graph:IsConsistent()
  if not c then error(string.format('[ERROR] <GraphGenerator> : Initial grammar node %d inconsistent (feature class: %s).', id, fc)) end 
  
  local fails = 0
  for step = 1, cfg.GrammarMaxSteps do
    if graph:IsFinal() then break end
    for choice in ProductionIterator(state, Productions) do
      local success = Productions[choice](graph, state)
      local c, id, fc = graph:IsConsistent()
      if not c then error(string.format('[ERROR] <GraphGenerator> : Production %s made node %d inconsistent (feature class: %s).', choice, id, fc)) end 
      if success then 
        print (string.format('[INFO] <GraphGenerator> Production "%s" applied (after %d fails); Graph: %d nodes (%d inconsistent), %d edges', 
            choice, fails, #graph, #graph:InconsistentIds(), #graph:EdgesList()))
        fails = 0
        break 
      end
      fails = fails + 1
    end
    --if debugimg_path then self:Drawer():Draw(debuging_path..'-'..step) end
  end
  
  if graph:IsFinal() then
    state.lmlGraph = graph
  else
    error('[ERROR] <GraphGenerator> : Generating final graph within '..cfg.GrammarMaxSteps..' steps failed.')
  end
end
-- GraphGenerator.Generate


return GraphGenerator