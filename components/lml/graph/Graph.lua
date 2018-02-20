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
  self.edges[z1id][z2id]=true
  self.edges[z2id][z1id]=true
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


--- Computes list of inconsistent nodes within the graph
-- @return List of id's of inconsistent nodes
function Graph:InconsistentIds()
  local ids = {}
  for k, v in ipairs(self) do
    if not v:IsConsistent() then 
      table.insert(ids, k)
    end
  end
  return ids
end
-- Graph.IsConsistent


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


-- TODO - update the function

--- Produces data for LML graph image
-- @return GraphvizDrawer object containing current graph image data
function Graph:Drawer()
  local gd = GD.New()
  gd:AddNode{id=0, shape='none', label=''}
  for i, z in ipairs(self) do
    local labelc = {}
    for _, c in ipairs(z.classes) do
      labelc[#labelc+1] = c.type:sub(1,1)..c.level
    end
    local labelf = {}
    for _, f in ipairs(z.features) do
      if f.type == 'OUTER' then
        gd:AddNode{id=i..'o', shape='point', style='invisible', label=''}
        -- two options: one that all outer edges goes to their corresponding outer nodes, second that all goes to the common 0 node i.e.\ sink state
        gd:AddEdge(i, i..'o', {label=f.value or '', style='dotted'}) -- or gd:AddEdge(i, 0, ...
      else
        labelf[#labelf+1] = f.type:sub(1,1)..'-'..f.value:sub(1,1)
      end
    end

    local shape = 'none'
    if not z:IsFinal() then shape='doubleoctagon' 
    elseif z.class[1].type=='LOCAL' then shape='circle'
    elseif z.class[1].type=='BUFFER' then shape='box'
    end    
    gd:AddNode{id=i, shape=shape, label=table.concat(labelc, ',')..'\\n'..table.concat(labelf, ','), color='#000000'}
    
    for e, n in pairs(z.edges or {}) do
      if e <= i then -- display only one-direction of edge (from lhigher id's to lower)
        for j=1, n do
          gd:AddEdge(i, e) 
        end
      end
    end
  end
  
  return gd
end


return Graph
