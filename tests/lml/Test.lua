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
  os.execute('mkdir ' .. state.config.DebugOutPath:gsub('/', '\\'))

  Params.GenerateDetailedParams(state)
  Params.GenerateInitLMLNode(state)
  
  ConfigHandler.Write('tests/lml/'..name..'.h3pgm', state)
  
  LML.GenerateGraph(state)  
  LML.GenerateMetagraph(state)
  
  ConfigHandler.Write('tests/lml/'..name..'.h3pgm', state)
  state.lmlMetagraph:Image():Draw(state.config.DebugOutPath..state.paramsDetailed.seed..'_Metagraph')
end


--Test('A')
--print('A: OK')
Test('01')
print('01: OK')
