package.path = ";../../components/params/?.lua" .. package.path
package.path = ";../../components/mlml/?.lua" .. package.path

local Params = require'Params'

CONFIG = require('Auxiliary/ConfigHandler').Read('../../config.cfg')
local ConfigHandler = require('Auxiliary/ConfigHandler')


local function Test(name)
  local state = ConfigHandler.Read(name..'-input.h3pgm')  
  state.config = CONFIG
  Params.GenerateDetailedParams(state)
  ConfigHandler.Write(name..'-output.h3pgm', state)
end


Test('00')
Test('01')
