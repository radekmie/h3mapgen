local Class = require'graph/Class'


local Feature = {}
local Feature_mt = { __index = Feature, __metatable = "Access resticted." }


--- Creates new empty Feature object
-- @param typeorobj Feature table with full data or class type: 'TOWN', 'MINE', 'OUTER'
-- @param value Feature value (depends on type, e.g. edge level for OUTER) [optional]
-- @param class Zone class the feature should belong to [optional]
-- @return New Feature with given data
function Feature.New(typeorobj, value, class)
  local obj
  if value == nil then
    obj = {type=typeorobj.type, value=typeorobj.value, class=typeorobj.class} -- slower hardcopy constructor here (safer)
  else 
    obj = {type=typeorobj, value=value, class=class}
  end
  obj.class = Class.New(obj.class)
  return setmetatable(obj, Feature_mt)
end


--- Checks if the feature is consistent with given set of classes
-- @param classes Sequence of classes
-- @return True if feature's class is in given classes
function Feature:IsConsistentWith(classes)
  local c = self.class
  for _, v in ipairs(classes) do 
    if v == c then return true end
  end
  return false
end


--- Graphviz in-node label
-- @param verbose Do we need additional info on class?
-- @return String to be shown in graph
function Feature:labelstr(verbose)
  local val = self.value
  if     val == 'PRIMARY' then val = 'PRIM'
  elseif val == 'RANDOM'  then val = 'RND' 
  elseif val == 'PLAYER'  then val = 'PLR' 
  elseif val == 'NEUTRAL' then val = 'NEUT' 
  end
  return string.format('%s<SUB>%s</SUB> %s', self.type:sub(1,1), val, verbose and '('..self.class.type:sub(1,1)..self.class.level..')' or '')
end

return Feature