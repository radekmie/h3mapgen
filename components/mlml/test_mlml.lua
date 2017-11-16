CONFIG = require('Auxiliary/ConfigHandler').Read('../config.cfg')

local ConfigHandler = require('Auxiliary/ConfigHandler')
local Serialization = require('Auxiliary/Serialization')

local Grammar = require('LogicMapLayout/Grammar/Grammar')
local LML     = require('LogicMapLayout/LogicMapLayout')
local MLML    = require('LogicMapLayout/MultiLogicMapLayout')

--- Function to test generating MLML graphs and interfaces (updates the config files)
-- @param testfiles Sequence of tuples {in_h3pgm, out_h3pgm, out_graph} files
-- @param regenerate_graph if true the graph (MLML_graph field) is regenerated even if it exists before
-- @param players - number of players for the graph
local function test_mlml (testfiles, regenerate_graph, players)
  for _, paths in ipairs(testfiles) do
    local in_h3pgm, out_h3pgm, out_graph = table.unpack(paths)
    local config = ConfigHandler.Read(in_h3pgm)

    math.randomseed(config.LML_seed >- 1 and config.LML_seed or os.time())

    local lml = LML.Initialize(config.LML_init)
    if regenerate_graph or not config.LML_graph then
      lml:Generate(Grammar, 100)
      config.LML_graph = lml
    end

    config.LML_interface = config.LML_graph:Interface()

    local mlml = MLML.Initialize(config.LML_interface)
    if regenerate_graph or not config.MLML_graph then
      mlml:Generate(players)
      config.MLML_graph = mlml
    end

    config.MLML_interface = config.MLML_graph:Interface()
    config.MLML_graph:PrintToMDS(out_graph)

    ConfigHandler.Write(out_h3pgm, config) -- todo
  end
end

if arg[1] == nil then
  test_mlml({{'_test/A.h3pgm', '_test/A.h3pgm', '_test/A.txt'}}, true, 4)
  test_mlml({{'_test/B.h3pgm', '_test/B.h3pgm', '_test/B.txt'}}, true, 4)
  test_mlml({{'_test/test-1.h3pgm', '_test/test-1.h3pgm', '_test/test-1.txt'}}, true, 4)
  test_mlml({{'_test/test-2.h3pgm', '_test/test-2.h3pgm', '_test/test-2.txt'}}, true, 2)
else
  test_mlml({{arg[1], arg[2], arg[3]}}, true, arg[4])
end
