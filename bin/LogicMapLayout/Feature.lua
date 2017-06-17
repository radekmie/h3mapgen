local Class = require'LogicMapLayout/Class'


local Feature = {}
local Feature_mt = { __index = Feature, __metatable = "Access resticted." }


--- Creates new empty Feature object
-- @param type Feature table with full data or class type: 'TOWN', 'MINE', 'OUTER'   (future: '??', ...?)
-- @param value Feature value (depends on type, e.g. edge level for OUTER)
-- @param class Zone class the feature should belong to
-- @return New Feature with given data
function Feature.New(type, value, class)
  local obj = _G.type(type)=='table' and type or {type=type, value=value, class=class}
  obj.class = Class.New(obj.class)
  return setmetatable(obj, Feature_mt)
end


--- Checks if the feature is consistent with given set of classes
-- @param classes Sequence of classes
-- @return True if feature's class is in given classes
function Feature:IsConsistentWith(classes)
  local c = tostring(self.class)
  for _, v in ipairs(classes) do 
    if tostring(v) == c then return true end
  end
  return false
end


return Feature