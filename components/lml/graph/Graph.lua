local Zone = require'graph/Zone'
local GD = require'GraphvizDrawer'

local Graph = {}
local Graph_mt = { __index = Graph, __metatable = "Access resticted." }


--- Creates new LML Graph object initialized with given initial node
-- @param data Table containing initial node's data
-- @return New, initialized LML object containing one (probably inconsistent) node
function Graph.Initialize(initnode)
  local obj = {}
  obj[1] = Zone.New(initnode)
  obj.edges = {} -- Edges are stored as an adjacency matrix
  obj.edges[1] = {}
  return setmetatable(obj, Graph_mt)
end
-- Graph.Initialize


--- Extends LML Graph with a new zone
-- @param data Table containing new node's data [optional].
-- @return new zone's id and new zone's table
function Graph:AddZone(data)
  local new = Zone.New(data)
  self[#self+1] = new
  self.edges[#self] = {}
  return #self, new
end
-- Graph.AddZone


--- Extends LML Graph with a new edge
-- @param z1id Id of one of the edges adjacent nodes
-- @param z2id Id of second of the edges adjacent nodes
function Graph:AddEdge(z1id, z2id)
  if not self.edges[z1id][z2id] then
    self.edges[z1id][z2id] = 1
    self.edges[z2id][z1id] = 1
  else
    self.edges[z1id][z2id] = self.edges[z1id][z2id] + 1
    self.edges[z2id][z1id] = self.edges[z2id][z1id] + 1
  end
end
-- Graph.AddEdge


--- Checks if all zones are consistent i.e. does not have features without proper classes
-- @return False and zone's id and feature's class if zone's feature's class is not in the zone's classes; true otherwise
function Graph:IsConsistent()
  for k, v in ipairs(self) do
    local c, f = v:IsConsistent()
    if not c then return false, k, f.class end
  end
  return true
end
-- Graph.IsConsistent


--- Computes list of edges in graph
-- @return List of {id1, id2} edges (id1 < id2)
function Graph:EdgesList()
  local edges = {}
  for id1, e in pairs(self.edges) do
    for id2, k in pairs(e) do
      if id1 < id2 then
        for i=1,k do table.insert(edges, {id1, id2}) end
      end
    end
  end
  return edges
end
-- Graph.EdgesList


--- Checks if all zones are uniform
-- @return True iff all zones are consistent and contains only one class, and the list of nonfinal zones ids
function Graph:IsFinal()
  local nonfinal = {}
  for i, v in ipairs(self) do
    if not v:IsFinal() then nonfinal[#nonfinal+1] = i end
  end
  return #nonfinal==0, nonfinal
end
-- Graph.IsFinal


--- Computes list of non-final nodes within the graph
-- @return List of id's of non-final nodes
function Graph:NonfinalIds()
  local ids = {}
  for k, v in ipairs(self) do
    if not v:IsFinal() then 
      table.insert(ids, k)
    end
  end
  return ids
end
-- Graph.NonfinalIds


--- Produces data for LML graph image
-- @return GraphvizDrawer object containing current graph image data
function Graph:Image()
  local gd = GD.New()
  
  local teleports = {}
  
  gd:AddNode{id=0, shape='none', label=''}
  for i, z in ipairs(self) do
    local labelc = {}
    for _, c in ipairs(z.classes) do
      labelc[#labelc+1] = c.type:sub(1,1)..c.level
    end
    local labelf = {}
    for j, f in ipairs(z.features) do
      
      if f.type == 'OUTER' then
        gd:AddNode{id=i..'o'..j, shape='none', label=''}
        gd:AddEdge(i, i..'o'..j, {label=f.value or '', style='bold'})
      elseif f.type == 'TELEPORT' then
        local tid = f.value.id
        if teleports[tid] == nil then
          teleports[tid]=true
          gd:AddNode{id='T'..tid, shape='plaintext', label='T'..tid}
        end
        gd:AddEdge(i, 'T'..tid, {label=f.value.level, style='dotted'})
      else
        labelf[#labelf+1] = f:labelstr(#labelc>1)
      end
    end

    local shape = 'none'
    if not z:IsFinal() then shape='doubleoctagon' 
    elseif z.classes[1].type=='LOCAL' then shape='circle'
    elseif z.classes[1].type=='BUFFER' then shape='box'
    elseif z.classes[1].type=='GOAL' then shape='diamond'
    end    
    gd:AddNode{id=i, shape=shape, label=table.concat(labelc, ', ')..'\\n'..table.concat(labelf, '\\n'), color='#000000'}
  end
  
  for id1, e in pairs(self.edges) do
    for id2, k in pairs(e) do
      if id1 < id2 then
        for i=1,k do gd:AddEdge(id1, id2) end
      end
    end
  end
  
  return gd
end
-- Graph.Image


return Graph
