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


local function Test(name)
  local state = ConfigHandler.Read('tests/lml/'..name..'.h3pgm')  
  state.config = ConfigHandler.Read('config.cfg')
  
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

  Params.GenerateDetailedParams(state)
  Params.GenerateInitLMLNode(state)
  
  ConfigHandler.Write(state.paths.h3pgm, state)
  
  LML.GenerateGraph(state)  
  LML.GenerateMetagraph(state)
  state.LML_interface_OLD = MLMLHelper.GenerateOldLMLInterface(state.lmlGraph)
  
  ConfigHandler.Write(state.paths.h3pgm, state)
  state.lmlMetagraph:Image():Draw(state.paths.path..'Metagraph')
  
  print ('<xxx>')
  
  local mlml = MLML.Initialize(state.LML_interface_OLD)
  
  --[[
  
      
    mlml:Generate(#state.paramsDetailed.players)

    -- TODO: Should be stored in state, not in a file.
    mlml:PrintToMDS(state.paths.graph)

    state.MLML_graph = mlml
    state.MLML_interface = mlml:Interface()
    --]]
  
end


--Test('A')
--print('A: OK')
Test('01')
print('01: OK')
