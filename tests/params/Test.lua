-- Run from the main directory ('generate.lua' level)
package.path = package.path .. ";components/params/?.lua"
package.path = package.path .. ";components/lml/?.lua"
package.path = package.path .. ";libs/?.lua"


local Params = require'Params'
local ConfigHandler = require'ConfigHandler'


local function Test(name)
  local state = ConfigHandler.Read('tests/params/'..name..'.h3pgm')  
  state.config = ConfigHandler.Read('config.cfg')
  Params.GenerateDetailedParams(state)
  Params.GenerateInitLMLNode(state)
  ConfigHandler.Write('tests/params/'..name..'.h3pgm', state)
end


--Test('00')
--print('00: OK')
Test('01')
print('01: OK')
