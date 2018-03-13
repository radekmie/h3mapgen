-- Instead of LUA_CPATH
package.cpath = package.cpath .. ';components/ca/?.so'
package.cpath = package.cpath .. ';libs/homm3lua/dist/?.so'

-- Instead of LUA_PATH
package.path = package.path .. ';components/gridmap/?.lua'
package.path = package.path .. ';components/mlml/?.lua'
package.path = package.path .. ';components/lml/?.lua'
package.path = package.path .. ';components/params/?.lua'
package.path = package.path .. ';libs/?.lua'

--local homm3lua = require('homm3lua') -- BO U MNIE NIE DZIAŁA

local ConfigHandler = require('ConfigHandler')
local Serialization = require('Serialization')

--local CA      = require('ca') -- BO U MNIE NIE DZIAŁA

--local Grammar = require('LogicMapLayout/Grammar/Grammar')
local GridMap = require('GridMapSeparation/GridMap')
--local LML     = require('LogicMapLayout/LogicMapLayout')
local Params = require'Params'
local Graph = require'graph/Graph'
local LML = require'LogicMapLayout'
local MLML    = require('LogicMapLayout/MultiLogicMapLayout')
local rescale = require('mdsAdapter')



--- Creates serializable LML object interface table that can be used to generate MultiLML
-- @param lml LML graph in new format
-- @return Table with properly formated LML interface
local function GenerateOldLMLInterface(graph)
  local interface = {}
  for id, node in ipairs(graph) do
    -- from old function Zone:Interface(id)
    local zone = {}
    zone.id = id
    if node.classes[1].type=='LOCAL' then zone.type = 'LOCAL' end
    if node.classes[1].type=='BUFFER' then zone.type = 'BUFFER' end
    local edges = {}
    for k, v in pairs(graph.edges[id]) do
      for i = 1, v do edges[#edges+1] = k end
    end
    zone.edges = edges
    local outer = {}
    for _, f in ipairs(node.features) do
      if f.type == 'OUTER' then
        outer[#outer+1] = f.value
      end
    end
    zone.outer = outer
    -- from old interface[i] = k:Interface(i)
    interface[id] = zone
  end
  return interface
end




-- Main.
--arg[1] = '?' -- for tests
if arg[1] == '?' then 
  arg[1] = 'tests/lml/01.h3pgm'
end
if arg[1] then
  
  -- LML PART
  
  local state = ConfigHandler.Read(arg[1])  
  state.config = ConfigHandler.Read('config.cfg')
  --os.execute('mkdir ' .. state.config.DebugOutPath:gsub('/', '\\'))

  Params.GenerateDetailedParams(state)
  Params.GenerateInitLMLNode(state)
  
  --ConfigHandler.Write('tests/lml/'..name..'.h3pgm', state)
  
  LML.GenerateGraph(state)  
  LML.GenerateMetagraph(state)
  
  ConfigHandler.Write(arg[1], state)
  --state.lmlMetagraph:Image():Draw(state.config.DebugOutPath..state.paramsDetailed.seed..'_Metagraph')
  
  
  -- MLML PART
  
  state.LML_interface_OLD = GenerateOldLMLInterface(state.lmlGraph)
  
  local mlml = MLML.Initialize(state.LML_interface_OLD)
  mlml:Generate(#state.paramsDetailed.players)

  -- TODO: Should be stored in state, not in a file.
  --mlml:PrintToMDS(state.paths.graph)

  state.MLML_graph = mlml
  state.MLML_interface = mlml:Interface()
  
  ConfigHandler.Write(arg[1], state)
  
else
    print('generate2_tmp.lua h3pgm_mfile')
    print('  Requires h3pgm file with "paramsGeneral" filled.')
    
end