
local MLMLNode = {} 
local MLMLNode_mt = { __index = MLMLNode, __metatable = "Access resticted." }


--- Creates new node object initialized with given node data
-- @param data Table containing initial node's data
-- @param id - generated id for the node
-- @return New node object
function MLMLNode.New(data, id)
  local obj = {}
  obj.id = id
  obj.baseid = data and data.id or -1
  obj.weight = data and data.weight or 5
  obj.type = data and data.type or "LOCAL"
  obj.players = {}
  local playerId = data and data.player or 1
  obj.players[playerId] = true
  obj.edges = data and data.edges or {}
  return setmetatable(obj, MLMLNode_mt)
end


--- Creates serializable node object interface table that can be used in MDS
-- @return Table with properly formatted node interface
function MLMLNode:Interface()
  local node = {}
  node.id = self.id
  node.weight = self.weight
  local edges = {}
  for k, _ in pairs(self.edges) do
    edges[#edges+1] = k
  end
  node.edges = edges
  return node
end


return MLMLNode