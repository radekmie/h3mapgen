local GL = require'grammar/GrammarLib'
local Zone = require'graph/Zone'

local Productions = {}

--- Computes town features for given set of zones
-- @param graph LML graph (modifying)
-- @param state H3pgm state 
-- @return true iff productions succeed and modified the graph (utherwise we assume the graph is unchanged)
function Productions.Test (graph, state) 
  local id = graph:NonfinalIds()[1]
  local zone = graph[id]
  
  local smaller_c, greatereq_c = GL.Split2ByRandomPivot(zone.classes)
  if #smaller_c==0 or #greatereq_c==0 then
    return false
  end
  
  local smaller_f, greatereq_f = {}, {}
  for _, f in ipairs(zone.features) do
    if f:IsConsistentWith(greatereq_c) then
      table.insert(greatereq_f, f)
    else
      table.insert(smaller_f, f)
    end
  end
  
  graph[id] = Zone.New{classes=smaller_c, features=smaller_f}
  local nid, nzone = graph:AddZone{classes=greatereq_c, features=greatereq_f}

  graph:AddEdge(id, nid)
  return true
end
-- Productions.Test



function Productions.Test2 (graph, state) 

  return false
end


function Productions.XXX (graph, state) 
  --print ('inside XXX')
  return false
end


return  Productions