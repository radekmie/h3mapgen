
local Class = {}
local Class_mt = { __index = Class, __metatable = "Access resticted." }

local TypeOrder = {LOCAL=1, TELEPORT=2, BUFFER=3, WATER=3, WHIRLPOOL=4, GOAL=5}

function Class_mt.__eq(a, b)
  return a.type==b.type and a.level==b.level
end

function Class_mt.__lt(a, b)
  if a.type==b.type then return a.level<b.level end
  return TypeOrder[a.type] < TypeOrder[b.type]
end

function Class_mt.__le(a, b)
  return a==b or a<b
end

--- Also used as a hash
function Class_mt.__tostring(a)
  return string.format('%s-%s', a.type, a.level)
end


--- Creates new empty Class object
-- @param type Zone table with full data or class type: 'LOCAL', 'BUFFER', 'GOAL', 'TELEPORT', 'WATER'
-- @param level Zone class level: int
-- @return New Class with given type and level [optional]
function Class.New(typeorobj, level)
  local obj
  if level == nil then
    obj = {type=typeorobj.type, level=typeorobj.level} -- hardcopy constructor is slower but safer
  else 
    obj = {type=typeorobj, level=level}
  end
  return setmetatable(obj, Class_mt)
end


--- Shortened string
-- @return First letter of type + level
function Class:shortstr()
  return string.format('%s%s', self.type:sub(1,1), self.level)
end

return Class