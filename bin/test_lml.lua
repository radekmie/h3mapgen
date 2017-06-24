CONFIG = require'Auxiliary/ConfigHandler'.Read('config.cfg')
local LML = require'LogicMapLayout/LogicMapLayout'
local Serialization = require'Auxiliary/Serialization'
local Grammar = require'LogicMapLayout/Grammar/Grammar'
local CH = require'Auxiliary/ConfigHandler'


--- Function to test generating LML graphs and interfaces (updates given h3pgm file!)
-- @param filename Name of h3pgm file within the _test folder
-- @param regenerate_graph if true the graph (LML_graph field) is regenerated even if it exists before
local function test_lml(filename, regenerate_graph)
  local fpath = '_test/'..filename
  local h3pgm = CH.Read(fpath..'.h3pgm')
  math.randomseed( h3pgm.LML_seed>-1 and h3pgm.LML_seed or os.time() )
  local lml = LML.Initialize(h3pgm.LML_init)
  if regenerate_graph or not h3pgm.LML_graph then
    lml:Generate(Grammar, CONFIG.LML_max_steps, CONFIG.LML_draw_steps and fpath)
    h3pgm.LML_graph = lml
  end
  h3pgm.LML_interface = h3pgm.LML_graph:Interface()
  CH.Write(fpath..'.h3pgm', h3pgm)
  local gd = lml:Drawer()
  if CONFIG.LML_draw_final then gd:Draw(fpath, true) end
end

--local h3pgm = CH.Read('_test/x.h3pgm')
--CH.Write('_test/x.h3pgm', h3pgm)

test_lml('test-1', true)
test_lml('test-2', true)
test_lml('A', true)
test_lml('B', true)
