local Zone = require'LogicMapLayout/Zone'


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
-- @param MAX_STEPS Constant containing upper bound for the number of production application (error when exceeded)
function LML:Generate(grammar, MAX_STEPS)
  local c, id, fc = self:IsConsistent()
  if not c then error(string.format('Initial grammar node %d is inconsistent (feature class: %s).', id, fc)) end 
  local isuniform, nonuniform_ids = self:IsUniform()
  if isuniform then return end 
  for step = 1, MAX_STEPS do
    local success = false
    for prod in ordered_productions(grammar) do
      success = prod.f(self, nonuniform_ids)
      local c, id, fc = self:IsConsistent()
      if not c then error(string.format('Production %s made node %d inconsistent (feature class: %s).', prod.short_desc, id, fc)) end 
      if success then break end
    end
    if not success then print('WARNING: No succesfull production found.') end
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


return LML