local GraphGenerator = require'GraphGenerator'
local Metagraph = require'Metagraph'

local LML = {}


--- Function generates 'lmlGraph' field containing full LML graph
-- @param state H3pgm state after GenerateInitLMLNode function applied
function LML.GenerateGraph(state)
  if not state.lmlInitialNode then
    error('[ERROR] <LogicMapLayout> : Given h3pgm state do not contain lmlInitialNode (required by LML.GenerateGraph).', 2)
  end
  GraphGenerator.Generate(state)
end


--- Function generates 'lmlMetagraph' field containing metagraph (high-level overview) of the LML graph
-- @param state H3pgm state after GenerateGraph function applied
function LML.GenerateMetagraph(state)
  if not state.lmlGraph then
    error('[ERROR] <LogicMapLayout> : Given h3pgm state do not contain lmlGraph (required by LML.GenerateMetagraph).', 2)
  end
  Metagraph.Generate(state)
end


return LML
