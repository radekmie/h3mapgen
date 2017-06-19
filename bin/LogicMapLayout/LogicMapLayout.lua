local Zone = require'LogicMapLayout/Zone'
local GD = require'Auxiliary/GraphvizDrawer'

local LML = {}
local LML_mt = { __index = LML, __metatable = "Access resticted." }


-- todo ordered_productions
local function ordered_productions(grammar)                                                       ------------ TODO
  local i = 0
  return function () i = i + 1; return grammar[i] end
end


--- Creates new LML object initialized with given initial node
-- @param data Table containing initial node's data
-- @return New, initialized LML object containing one (inconsistent) node
function LML.Initialize(data)
  local obj = {}
  obj[1] = Zone.New(data)
  return setmetatable(obj, LML_mt)
end


--- Extends LML with a new zone
-- @param data Table containing new node's data (optional).
-- @return new zone's id and new zone's table
function LML:AddZone(data)
  local new = Zone.New(data)
  self[#self+1] = new
  return #self, new
end


--- Generates LML accortding to given grammar
-- LML object have to be initialized before calling Generate.
-- Random seed has to be properly set.
-- @param grammar Table with grammar rules
-- @param max_steps Constant containing upper bound for the number of production application (error when exceeded)
-- @param debugimg_path If provided, produces image output every step
function LML:Generate(grammar, max_steps, debuging_path)
  if debuging_path then self:Drawer():Draw(debuging_path..'-'..0) end
  local c, id, fc = self:IsConsistent()
  if not c then error(string.format('Initial grammar node %d is inconsistent (feature class: %s).', id, fc)) end 
  local isuniform, nonuniform_ids = self:IsUniform()
  if isuniform then return end 
  for step = 1, max_steps do
    local success = false
    for prod in ordered_productions(grammar) do
      success = prod.f(self, nonuniform_ids)
      local c, id, fc = self:IsConsistent()
      if not c then error(string.format('Production %s made node %d inconsistent (feature class: %s).', prod.short_desc, id, fc)) end 
      if success then break end
    end
    if not success then print('WARNING: No succesfull production found.') end
    if debugimg_path then self:Drawer():Draw(debuging_path..'-'..step) end
    isuniform, nonuniform_ids = self:IsUniform()
    if isuniform then return end
  end
  error('Generating uniform grammar within '..MAX_STEPS..' steps limit failed.')
end


--- Creates serializable LML object interface table that can be used to generate MultiLML
-- @return Table with properly formated LML interface
function LML:Interface()
  local interface = {}
  for i, k in ipairs(self) do
    interface[i] = k:Interface(i)
  end
  return interface
end


--- Checks if all zones are consistent i.e. does not have features without proper classes
-- @return False and zone's id and feature's class if zone's feature's class is not in the zone's classes; true otherwise
function LML:IsConsistent()
  for k, v in ipairs(self) do
    local c, f = v:IsConsistent()
    if not c then return false, k, f.class end
  end
  return true
end


--- Checks if all zones are uniform
-- @return True iff all zones contains only one class, and the list of nonuniform zones ids
function LML:IsUniform()
  local nonuniform = {}
  for i, v in ipairs(self) do
    if not v:IsUniform() then nonuniform[#nonuniform+1] = i end
  end
  return #nonuniform==0, nonuniform
end


--- Produces data for LML graph image
-- @return GraphvizDrawer object containing current graph image data
function LML:Drawer()
  local gd = GD.New()
  gd:AddNode{id=0, shape='none', label=''}
  for i, z in ipairs(self) do
    local labelc = {}
    for _, c in ipairs(z.class) do
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
    if not z:IsUniform() then shape='doubleoctagon' 
    elseif z.class[1].type=='LOCAL' then shape='circle'
    elseif z.class[1].type=='BUFFER' then shape='box'
    end    
    gd:AddNode{id=i, shape=shape, label=table.concat(labelc, ',')..'\\n'..table.concat(labelf, ','), color='#000000'}
    
    for e, n in pairs(z.edges) do
      if e <= i then -- display only one-direction of edge (from lhigher id's to lower)
        for j=1, n do
          gd:AddEdge(i, e) 
        end
      end
    end
  end
  
  return gd
end


return LML