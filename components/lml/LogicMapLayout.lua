local GraphGenerator = require'GraphGenerator'

local LML = {}


--- Function generates 'LML_InitNode' field containing initial node for LML stage
-- @param state H3pgm state after GenerateInitLMLNode function applied
function LML.GenerateGraph(state)
  if not state.lmlInitialNode then
    error('[ERROR] <LogicMapLayout> : Given h3pgm state do not contain lmlInitialNode (required by LML.GenerateGraph).', 2)
  end
  GraphGenerator.Generate(state)
end


-- Todo Interface (metagraph)




return LML
