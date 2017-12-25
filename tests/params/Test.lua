package.path = ";../../components/params/?.lua" .. package.path
package.path = ";../../libs/?.lua" .. package.path

local Params = require'Params'
local ConfigHandler = require'ConfigHandler'


local function Test(name)
  local state = ConfigHandler.Read(name..'-input.h3pgm')  
  state.config = ConfigHandler.Read('../../config.cfg')
  Params.GenerateDetailedParams(state)
  ConfigHandler.Write(name..'-output.h3pgm', state)
end


Test('00')
Test('01')
