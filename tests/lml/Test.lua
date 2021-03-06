-- Run from the main directory ('generate.lua' level)
package.path = package.path .. ";components/params/?.lua"
package.path = package.path .. ";components/lml/?.lua"
package.path = package.path .. ';components/mlml/?.lua'
package.path = package.path .. ";libs/?.lua"


local Params = require'Params'
local Graph = require'graph/Graph'
local ConfigHandler = require'ConfigHandler'
local LML = require'LogicMapLayout'
local MLML    = require('LogicMapLayout/MultiLogicMapLayout')
local MLMLHelper = require('LogicMapLayout/MLMLHelper')


local function Test(name, seed)
  local state = ConfigHandler.Read('tests/lml/'..name..'.h3pgm')  
  state.config = ConfigHandler.Read('config.cfg')
  
  if seed ~= nil then
    state.paramsGeneral.seed = seed
  end
  
  Params.GenerateDetailedParams(state)
  Params.GenerateInitLMLNode(state)
  
    local dir = state.paramsDetailed.seed .. '_' .. #state.paramsGeneral.players
  state.paths = { 
    base = 'tests/out/',
    path = 'tests/out/'..dir..'/',
    imgs = 'tests/out/'..dir..'/imgs/',
    h3pgm = 'tests/out/'..dir..'/map.h3pgm',
  }
  os.execute('mkdir ' .. (state.paths.base):gsub('/', '\\'))
  os.execute('mkdir ' .. (state.paths.path):gsub('/', '\\'))
  os.execute('mkdir ' .. (state.paths.imgs):gsub('/', '\\'))

  ConfigHandler.Write(state.paths.h3pgm, state)
  
  LML.GenerateGraph(state)  
  LML.GenerateMetagraph(state)
  state.LML_interface_OLD = MLMLHelper.GenerateOldLMLInterface(state.lmlGraph)
  
  ConfigHandler.Write(state.paths.h3pgm, state)
  state.lmlMetagraph:Image():Draw(state.paths.path..'Metagraph')
  
  print ('<MLML>')
  
  local mlml = MLML.Initialize(state.LML_interface_OLD)
  
  mlml:Generate(#state.paramsDetailed.players)
  state.MLML_graph = mlml
  state.MLML_interface = mlml:Interface()

  ConfigHandler.Write(state.paths.h3pgm, state)

  MLMLHelper.GenerateImage(mlml, state.lmlGraph):Draw(state.paths.path..'MLML')
  print ('</MLML>')
  
end


--Test('A')
--print('A: OK')
--Test('01')
--Test('01', 17)
--Test('01', 36)
--Test('01', 41)
--Test('01', 45)
Test('01', 47)
--print('01: OK')
--for i=30,50 do
--  Test('01', i)
--end
