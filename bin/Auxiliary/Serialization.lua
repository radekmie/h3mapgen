--- Handles Serialization with pretty-printing
-- Inspired by: https://github.com/hipe/lua-table-persistence/blob/master/persistence.lua
-- @class table
-- @name Serialization
local Serialization = {}

local indent = (' '):rep(CONFIG.Serialization_indent_size or 2) -- level indentation string


--- Checks if table is a sequence
--@param item Table to analyze
--@return True iff table is a sequence (#pairs==#ipairs)
local function table_issequence(item)
  local pairslen = 0
  for k, v in pairs(item) do
    pairslen = pairslen + 1
  end
  return #item==pairslen
end

--- Computes table's depth
--@param item Table to analyze
--@return Maximal depth of the tables in key/values
local function table_depth(item)
  assert(type(item)=='table', 'table_depth function expects tbale type argument not '..type(item))
  local maxdepth = 0
  for k, v in pairs(item) do
    if type(k)=='table' then
      local d = table_depth(k) + 1
      if d > maxdepth then maxdepth = d end
    end
    if type(v)=='table' then
      local d = table_depth(v) + 1
      if d > maxdepth then maxdepth = d end
    end
  end
  return maxdepth
end

--- Order keys of given table
-- @param item Table 
-- @return Sequence with alphabetically sorted keys
local function order_keys(item)
  local keys = {}
  for k, _ in pairs(item) do keys[#keys+1] = k end
  table.sort(keys)
  return keys
end


--- Function for pretty-printing Lua values 
-- @param item Lua object to write down
-- @param level Level of indentation (default 0 for the root)
-- @param iskey True (non-nil) if we try to write table key
-- @param shrink_testrun Level of testing run to check pretty-printed shrinked version (optional, technical only, depends on CONFIG settings)
-- @return String containing pretty-printed item, and true if result was shrinked
function Serialization.Value(item, level, iskey, shrink_testrun)
  if not level then level = 0 end
  if type(item) == 'nil' then
    return iskey and '[nil]' or 'nil'
  elseif type(item) == 'number' then
    return iskey and '['..tostring(item)..']' or tostring(item)
  elseif type(item) == 'string' then
    return iskey and item or string.format("%q", item) 
  elseif type(item) == 'boolean' then
    if item then return iskey and '[true]' or 'true'
    else return iskey and '[false]' or 'false' end
  elseif type(item) == 'table' then
    local str, shrnk = Serialization.Table(item, level, iskey, shrink_testrun)
    return iskey and '['..str..']' or str, shrnk
  else
    error('Serialization called for unsupported-type item: '..tostring(item), 2)
  end
end


--- Function for pretty-printing Lua tables 
-- @param item Lua object to write down
-- @param level Level of indentation (default 0 for the root, -1 removes outer braces)
-- @param iskey True (non-nil) if we try to write table key
-- @patam shrink_testrun Level of testing run to check pretty-printed shrinked version (optional, technical only, depends on CONFIG settings)
-- @return String containing pretty-printed item, and true if result was shrinked
function Serialization.Table(item, level, iskey, shrink_testrun)
  if type(item)~='table' then Serialization.Value(item, level, iskey) end
  if not level then level = 0 end
  local numkeys = table_issequence(item)
  local tabdepth = table_depth(item)
  local innertables = tabdepth > 0
  shrink_testrun = shrink_testrun or 0
  
  if shrink_testrun > 0 then
    innertables = false
  elseif level > -1 and tabdepth < 2 and CONFIG.Serialization_shrinking_limit > 0 then   -- changing works the old way tabdepth < 1
    local str = Serialization.Table(item, level, iskey, shrink_testrun+1)
    if #str <= CONFIG.Serialization_shrinking_limit  then return str, true end 
  end
  
  local str = level > -1  and indent:rep(level)..'{' or ''
  local sep = level > -1 and ',' or '\n'
  innertables = level < 0 or innertables
  if innertables then
    if numkeys then 
      str=str..'\n' 
      for _, v in ipairs(item) do 
        str=str..Serialization.Value(v, level+1)..sep..'\n'
      end
      str=str..indent:rep(level)
    else  
      str=str..'\n' 
      for _, k in ipairs(order_keys(item)) do
        local v = item[k]
        if type(v)=='table' and table_depth(v) > 0  then
          local vstr, vshrnk = Serialization.Value(v, level+1)
          str=str..indent:rep(level+1)..Serialization.Value(k, level+1, true)..' = '..(vshrnk and vstr:gsub("^%s*", "") or '\n'..vstr)..sep..'\n'
        else
          str=str..indent:rep(level+1)..Serialization.Value(k, level+1, true)..' = '..Serialization.Value(v, 0)..sep..'\n'
        end
      end
      str=str..indent:rep(level)
    end
  else -- not innertables  (or called with shrink_testrun) 
    if numkeys then -- { v1, v2, v3, }
      str=str..' ' 
      for _, v in ipairs(item) do 
        str=str..Serialization.Value(v, level, nil, shrink_testrun+1)..', '
      end
    else  -- { k1=v1, k2=v2, k3=v3, }
      str=indent:rep(level)..'{ ' 
      if shrink_testrun > 1 then str = '{ ' end
      for _, k in ipairs(order_keys(item)) do
        str=str..Serialization.Value(k, level, true, shrink_testrun+1)..'='..Serialization.Value(item[k], level, nil, shrink_testrun+1)..', '
      end
    end
  end
  str= level > -1 and str..'}' or str
  return str
end


return Serialization