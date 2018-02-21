local Class = require'graph/Class'
local Feature = require'graph/Feature'

local Zone = {} 
local Zone_mt = { __index = Zone, __metatable = "Access resticted." }


--- Creates new zone object initialized with given node data
-- @param data Table containing initial zone's data (<classes, features> pair)
-- @return New zone object
function Zone.New(data)
  local obj = {}
  obj.classes = {}
  for k, v in ipairs(data and data.classes or {}) do
    obj.classes[k] = Class.New(v)
  end
  obj.features = {}
  for k, v in ipairs(data and data.features or {}) do
    obj.features[k] = Feature.New(v)
  end
  return setmetatable(obj, Zone_mt)
end


--- Checks if zone is consistent i.e. does not have features without proper classes (or has empty class)
-- @return False and a feature if feature's class is not in the zone's classes; true otherwise
function Zone:IsConsistent()
  if #self.classes < 1 then return false, {} end
  local classes = {}
  for k, v in ipairs(self.classes) do classes[tostring(v)] = true end
  for k, v in ipairs(self.features) do 
    if not classes[tostring(v.class)] then return false, v end
  end
  return true
end


--- Checks if zone does not need to be further divided
-- @return True iff zone is consistent and contains only one class
function Zone:IsFinal()
  return self:IsConsistent() and #self.classes==1
end


return Zone