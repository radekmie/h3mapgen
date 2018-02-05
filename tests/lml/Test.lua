-- Run from the main directory ('generate.lua' level)
package.path = ";components/lml/?.lua" .. package.path
package.path = ";libs/?.lua" .. package.path


local Graph = require'graph/Graph'
local ConfigHandler = require'ConfigHandler'


local function TestOLD(name)
  local state = ConfigHandler.Read('tests/lml/'..name..'.h3pgm')  
  state.config = ConfigHandler.Read('config.cfg')
  Params.GenerateDetailedParams(state)
  ConfigHandler.Write('tests/params/'..name..'.h3pgm', state)
end


local function Test(name)
  local state = ConfigHandler.Read('tests/lml/'..name..'.h3pgm')  
  --state.config = ConfigHandler.Read('config.cfg')
  local lml = Graph.Initialize(state.LML_init)
  local gd = lml:Drawer()
  gd:Draw('tests/lml/'..name..'', true)
    
  --Params.GenerateDetailedParams(state)
  --ConfigHandler.Write('tests/params/'..name..'.h3pgm', state)
end


Test('A')
--print('00: OK')
--Test('01')
--print('01: OK')
