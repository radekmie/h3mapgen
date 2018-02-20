-- Run from the main directory ('generate.lua' level)
package.path = package.path .. ";components/params/?.lua"
package.path = package.path .. ";components/lml/?.lua"
package.path = package.path .. ";libs/?.lua"


local Params = require'Params'
local Graph = require'graph/Graph'
local ConfigHandler = require'ConfigHandler'
local LML = require'LogicMapLayout'


local function Test(name)
  local state = ConfigHandler.Read('tests/lml/'..name..'.h3pgm')  
  state.config = ConfigHandler.Read('config.cfg')
  if not state.lmlInitialNode then
    print ('// <Test> Generating params and init node!')
    Params.GenerateDetailedParams(state)
    Params.GenerateInitLMLNode(state)
  end
  
  LML.GenerateGraph(state)
  
  local lml = Graph.Initialize(state.lmlInitialNode)
  ConfigHandler.Write('tests/params/'..name..'.h3pgm', state)
  local gd = lml:Drawer()
  gd:Draw('tests/lml/'..name..'', true)
end


--Test('A')
--print('A: OK')
Test('01')
print('01: OK')
