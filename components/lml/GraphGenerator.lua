local Graph = require'graph/Graph'
local Productions = require'grammar/Productions'
local RNG = require'Random'

local GraphGenerator = {}

local rand = RNG.Random


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
              if choice==nil then return nil end
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
  if cfg.GraphGeneratorDraw then graph:Image():Draw(cfg.DebugOutPath..state.paramsDetailed.seed..'_LML-'..0) end
  
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
        print (string.format('[INFO] <GraphGenerator> Production "%s" applied (after %d fails); Graph: %d nodes (%d non-final), %d edges', 
            choice, fails, #graph, #graph:NonfinalIds(), #graph:EdgesList()))
        fails = 0
        if cfg.GraphGeneratorDraw then graph:Image():Draw(cfg.DebugOutPath..state.paramsDetailed.seed..'_LML-'..step) end
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