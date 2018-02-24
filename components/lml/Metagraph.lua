local GD = require'GraphvizDrawer'

local Metagraph = {}
local Metagraph_mt = { __index = Metagraph, __metatable = "Access resticted." }


--- Creates new Metagraph object initialized with given data
-- @param data Table containing information about metagraph outer edges, i.e. sequence of {nodeId, classType, classLevel} triples
-- @return New Metagraph object
function Metagraph.New(data)
  local obj = data
  return setmetatable(obj, Metagraph_mt)
end
-- Metagraph.New


--- Creates new Metagraph object based on given LML graph
-- @param lmlgraph Logic Map Layout graph
-- @return New Metagraph object
function Metagraph.Initialize(lmlgraph)
  local metaedges = {}
  for id, zone in ipairs(lmlgraph) do
    for _, feature in ipairs(zone.features) do
      if feature.type == 'OUTER' then
        table.insert(metaedges, {id, feature.class.type, feature.class.level} )
      end
    end
  end
  return Metagraph.New(metaedges)
end
-- Metagraph.Initialize


--- Function generates 'lmlMetagraph' containing metagraph (high-level overview) of the LML graph
-- @param state H3pgm state containing 'lmlGraph', which is extended by 'lmlMetagraph'
function Metagraph.Generate(state)  
  local metagraph = Metagraph.Initialize(state.lmlGraph)
  state.lmlMetagraph = metagraph
end
-- Metagraph.Generate


--- Produces data for LML multigraph image
-- @return GraphvizDrawer object containing current metagraph image data
function Metagraph:Image()
  local gd = GD.New()
  gd:AddNode{id=0, shape='circle', label='P'}
  for i, edge in ipairs(self) do
    gd:AddNode{id=i, shape='none', label=''}
    gd:AddEdge(0, i, {label=string.format('%d/%s%d', edge[1], edge[2]:sub(1,1), edge[3])})
  end
  return gd
end
-- Metagraph.Image


return Metagraph