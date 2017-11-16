local Class = require'LogicMapLayout/Class'
local Feature = require'LogicMapLayout/Feature'

local Zone = {} 
local Zone_mt = { __index = Zone, __metatable = "Access resticted." }


--- Creates new zone object initialized with given node data
-- @param data Table containing initial zone's data
-- @return New zone object
function Zone.New(data)
  local obj = {}
  obj.class = {}
  for k, v in ipairs(data and data.class or {}) do
    obj.class[k] = Class.New(v)
  end
  obj.features = {}
  for k, v in ipairs(data and data.features or {}) do
    obj.features[k] = Feature.New(v)
  end
  obj.edges = {}
  for k, v in pairs(data and data.edges or {}) do
    obj.edges[k] = v
  end
  return setmetatable(obj, Zone_mt)
end


--- Creates serializable zone object interface table that can be used to generate MultiLML
-- @param id Zone's id
-- @return Table with properly formated zone interface
function Zone:Interface(id)
  local zone = {}
  zone.id = id
  if self.class[1].type=='LOCAL' then zone.type = 'LOCAL' end
  if self.class[1].type=='BUFFER' then zone.type = 'BUFFER' end
  local edges = {}
  for k, v in pairs(self.edges) do
    for i = 1, v do edges[#edges+1] = k end
  end
  zone.edges = edges
  local outer = {}
  for _, f in ipairs(self.features) do
    if f.type == 'OUTER' then
      outer[#outer+1] = f.value
    end
  end
  zone.outer = outer
  return zone
end


--- Checks if zone is consistent i.e. does not have features without proper classes (or has empty class)
-- @return False and a feature if feature's class is not in the zone's classes; true otherwise
function Zone:IsConsistent()
  if #self.class < 1 then return false, {} end
  local classes = {}
  for k, v in ipairs(self.class) do classes[tostring(v)] = true end
  for k, v in ipairs(self.features) do 
    if not classes[tostring(v.class)] then return false, v end
  end
  return true
end


--- Checks if zone does not need to be further divided
-- @return True iff zone contains only one class
function Zone:IsUniform()
  return #self.class==1
end


return Zone