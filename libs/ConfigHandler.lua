--- Handles reading and writing config/h3pgm files to/from Lua tables
-- @class table
-- @name ConfigHandler
local ConfigHandler = {}


--- Reads existing config and returns loaded values
-- @param filepath The path to existing config file
function ConfigHandler.Read(filepath)
  local environment = {}
  local f, e = loadfile(filepath, 't', environment) -- we load file in empty environment
  if f==nil then
    error ('Reading from '..filepath..' caused error:'..e)
  end 
  local ok, e = pcall(f)
  if not ok then
    error ('Calling source from from '..filepath..' caused error:'..e)
  end 
  return environment
end


--- Writes config data to a file
-- @param filepath The path to config file
-- @param config Table to write
function ConfigHandler.Write(filepath, config)
  local Serialization = require'Serialization' -- its here because of the CONFIG reading
  local str = Serialization.Table(config, -1)
  local file, e = io.open(filepath, "w")
  if file==nil then
    error ('Writing to '..filepath..' caused error:'..e)
  end 
  file:write(str)
  file:close()
end


return ConfigHandler