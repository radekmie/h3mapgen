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
    local w = 0
    if type(weight) == 'number' then -- raw number as weight
      w = weight
    elseif type(weight) == 'string' then -- parameter name as weight
      w = dp[weight]
    --elseif type(weight) == 'function' then -- function as weight  -- UNSUPPORTED BY SERIALIZATION
    --  w = weight(dp)
    end
    if w > 0 then map[name] = w end
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
  local drawkeepsrc = cfg.GraphGeneratorDrawKeepDotSources

  local graph = Graph.Initialize(state.lmlInitialNode)
  if cfg.GraphGeneratorDrawSteps then graph:Image():Draw(state.paths.imgs..'LML-0', drawkeepsrc) end

  local c, id, fc = graph:IsConsistent()
  if not c then error(string.format('[ERROR] <GraphGenerator> : Initial grammar node %d inconsistent (feature class: %s).', id, fc)) end

  local fails = 0
  for step = 1, cfg.GrammarMaxSteps do
    if graph:IsFinal() then break end
    --for choice in ProductionIterator(state, Productions) do
    for _, choice in ipairs{ProductionIterator(state, Productions)()} do
      local success = Productions[choice](graph, state)
      local c, id, fc = graph:IsConsistent()
      if not c then error(string.format('[ERROR] <GraphGenerator> : Production %s made node %d inconsistent (feature class: %s).', choice, id, fc)) end
      if success then
        print (string.format('[INFO] <GraphGenerator> Production "%s" applied (after %d fails); Graph: %d nodes (%d non-final), %d edges',
            choice, fails, #graph, #graph:NonfinalIds(), #graph:EdgesList()))
        fails = 0
        if cfg.GraphGeneratorDrawSteps then graph:Image():Draw(state.paths.imgs..'LML-'..step, drawkeepsrc) end
        break
      end
      fails = fails + 1
    end
  end

  if cfg. GraphGeneratorDrawFinal then graph:Image():Draw(state.paths.path..'LML', drawkeepsrc) end -- deprecated (different path now): and not cfg.GraphGeneratorDrawSteps
  if graph:IsFinal() then
    state.lmlGraph = graph
  else
    error('[ERROR] <GraphGenerator> : Generating final graph within '..cfg.GrammarMaxSteps..' steps failed.')
  end
end
-- GraphGenerator.Generate


return GraphGenerator
