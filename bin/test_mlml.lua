CONFIG = require'Auxiliary/ConfigHandler'.Read('config.cfg')

local LML = require'LogicMapLayout/LogicMapLayout'
local MLML = require'LogicMapLayout/MultiLogicMapLayout'

local Serialization = require'Auxiliary/Serialization'
local Grammar = require'LogicMapLayout/Grammar/Grammar'
local CH = require'Auxiliary/ConfigHandler'


--- Function to test generating MLML graphs and interfaces (updates the config files)
-- @param testfiles Sequence of h3pgm files within the _test folder to rewrite
-- @param regenerate_graph if true the graph (MLML_graph field) is regenerated even if it exists before
-- @param players - number of players for the graph
local function test_mlml(testfiles, regenerate_graph, players)
  for _, fname in ipairs(testfiles) do
    local cfg = CH.Read('_test/'..fname..'.h3pgm')
    math.randomseed( cfg.LML_seed>-1 and cfg.LML_seed or os.time() )
    
    local lml = LML.Initialize(cfg.LML_init)
    if regenerate_graph or not cfg.LML_graph then
      lml:Generate(Grammar, 100)
      cfg.LML_graph = lml
    end
    cfg.LML_interface = cfg.LML_graph:Interface()
    
    local mlml = MLML.Initialize(cfg.LML_interface)
    if regenerate_graph or not cfg.MLML_graph then
      mlml:Generate(players)
      cfg.MLML_graph = mlml
    end
    cfg.MLML_interface = cfg.MLML_graph:Interface()
    cfg.MLML_graph:PrintToMDS('_test/'..fname..'.txt')
    
    CH.Write('_test/'..fname..'.h3pgm', cfg) -- todo
  end
end

test_mlml({'test-1'}, true, 4)
test_mlml({'test-2'}, true, 2)

