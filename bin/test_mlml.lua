CONFIG = require'Auxiliary/ConfigHandler'.Read(arg[5] or 'config.cfg')

local LML = require'LogicMapLayout/LogicMapLayout'
local MLML = require'LogicMapLayout/MultiLogicMapLayout'

local Serialization = require'Auxiliary/Serialization'
local Grammar = require'LogicMapLayout/Grammar/Grammar'
local CH = require'Auxiliary/ConfigHandler'


--- Function to test generating MLML graphs and interfaces (updates the config files)
-- @param testfiles Sequence of tuples {in_h3pgm, out_h3pgm, out_graph} files
-- @param regenerate_graph if true the graph (MLML_graph field) is regenerated even if it exists before
-- @param players - number of players for the graph
local function test_mlml(testfiles, regenerate_graph, players)
  for _, paths in ipairs(testfiles) do
    local in_h3pgm, out_h3pgm, out_graph = table.unpack(paths)
    local cfg = CH.Read(in_h3pgm)
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
    cfg.MLML_graph:PrintToMDS(out_graph)
    
    CH.Write(out_h3pgm, cfg) -- todo
  end
end

if arg[1] == nil then
  test_mlml({{'_test/test-1.h3pgm', '_test/test-1.h3pgm', '_test/test-1.txt'}}, true, 4)
  test_mlml({{'_test/test-2.h3pgm', '_test/test-2.h3pgm', '_test/test-2.txt'}}, true, 2)
else
  test_mlml({{arg[1], arg[2], arg[3]}}, true, arg[4])
end
