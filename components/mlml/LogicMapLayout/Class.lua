
local Class = {}
local Class_mt = { __index = Class, __metatable = "Access resticted." }


function Class_mt.__eq(a, b)
  return a.type==b.type and a.level==b.level
end

function Class_mt.__lt(a, b)
  return (a.type==b.type and a.level<b.level) or (a.type=='LOCAL' and b.type=='BUFFER')
end

function Class_mt.__le(a, b)
  return a==b or a<b
end

--- Also used as a hash
function Class_mt.__tostring(a)
  return string.format('%s-%s', a.type, a.level)
end


--- Creates new empty Class object
-- @param type Zone table with full data or class type: 'LOCAL', 'BUFFER'   (future: 'TELEPORT', ...?)
-- @param level Zone class level: int
-- @return New Class with given type and level
function Class.New(type, level)
  local obj = _G.type(type)=='table' and type or {type=type, level=level}
  return setmetatable(obj, Class_mt)
end


return Class