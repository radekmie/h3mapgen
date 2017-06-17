--- Handles Serialization with pretty-printing
-- Inspired by: https://github.com/hipe/lua-table-persistence/blob/master/persistence.lua
-- @class table
-- @name Serialization
local Serialization = {}

local indent = '  ' -- level 1 indentation string


--- Analyzes table structure to help with pretty-printing
--@param item Table to analyze
--@return First value is true if table contains tables, second value is true iff table contains only numeric keys
local function analyze_table(item)
  local pairslen = 0
  local innertables = false
  for k, v in pairs(item) do
    pairslen = pairslen + 1
    if type(k)=='table' or type(v)=='table' then innertables=true end
  end
  return innertables, #item==pairslen
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
-- @iskey True (non-nil) if we try to write table key
-- @return String containing pretty-printed item
function Serialization.Value(item, level, iskey)
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
    local str = Serialization.Table(item, level, iskey)
    return iskey and '['..str..']' or str
  else
    error('Serialization called for unsupported-type item: '..tostring(item), 2)
  end
end


--- Function for pretty-printing Lua tables 
-- @param item Lua object to write down
-- @param level Level of indentation (default 0 for the root, -1 removes outer braces)
-- @iskey True (non-nil) if we try to write table key
-- @return String containing pretty-printed item
function Serialization.Table(item, level, iskey)
  if type(item)~='table' then Serialization.Value(item, level, iskey) end
  if not level then level = 0 end
  local innertables, numkeys = analyze_table(item) 
  local str = level > -1 and indent:rep(level)..'{' or ''
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
        if type(v)=='table' and analyze_table(v) then
          str=str..indent:rep(level+1)..Serialization.Value(k, level+1, true)..' = \n'..Serialization.Value(v, level+1)..sep..'\n'
        else
          str=str..indent:rep(level+1)..Serialization.Value(k, level+1, true)..' = '..Serialization.Value(v, 0)..sep..'\n'
        end
      end
      str=str..indent:rep(level)
    end
  else
    if numkeys then -- { v1, v2, v3, }
      str=str..' ' 
      for _, v in ipairs(item) do 
        str=str..Serialization.Value(v, level)..', '
      end
    else  -- { k1=v1, k2=v2, k3=v3, }
      str=indent:rep(level)..'{ '  
      for _, k in ipairs(order_keys(item)) do
        str=str..Serialization.Value(k, level, true)..'='..Serialization.Value(item[k], level)..', '
      end
    end
  end
  str= level > -1 and str..'}' or str
  return str
end


return Serialization