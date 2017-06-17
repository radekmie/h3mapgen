local LML = require'LogicMapLayout/LogicMapLayout'
local Serialization = require'Auxiliary/Serialization'
local Grammar = require'LogicMapLayout/Grammar/Grammar'
local CH = require'Auxiliary/ConfigHandler'



--- Function to test generating LML graphs and interfaces (updates the config files)
-- @param testfiles Sequence of h3pgm files within the _test folder to rewrite
-- @param regenerate_graph if true the graph (LML_graph field) is regenerated even if it exists before
local function test_lml(testfiles, regenerate_graph)
  for _, fname in ipairs(testfiles) do
    local cfg = CH.Read('_test/'..fname..'.h3pgm')
    math.randomseed( cfg.LML_seed>-1 and cfg.LML_seed or os.time() )
    local lml = LML.Initialize(cfg.LML_init)
    if regenerate_graph or not cfg.LML_graph then
      lml:Generate(Grammar, 100)
      cfg.LML_graph = lml
    end
    cfg.LML_interface = lml:Interface()
    CH.Write('_test/'..fname..'.h3pgm', cfg) -- todo
  end
end

test_lml({'test-1'}, true)
test_lml({'test-2'}, true)



--[======[
math.randomseed( os.time() )


local init = {}
init.class = 
  { 
    {type='LOCAL' , level=0},
    {type='LOCAL' , level=1},
   --[[ {type='LOCAL' , level=2},
    {type='LOCAL' , level=2},
    {type='LOCAL' , level=3},
    {type='LOCAL' , level=5},
    {type='BUFFER', level=4},
    {type='BUFFER', level=4},--]]
    {type='BUFFER', level=5},
  }
init.features = 
  {
    {class={type='LOCAL' , level=0}, type='TOWN' , value='PLAYER'},
    {class={type='LOCAL' , level=1}, type='MINE' , value='???'},
    --[[{class={type='LOCAL' , level=2}, type='MINE' , value='???'},
    {class={type='LOCAL' , level=3}, type='OUTER', value=6},
    {class={type='LOCAL' , level=5}, type='TOWN' , value='NEUTRAL'},
    {class={type='BUFFER', level=4}, type='TOWN' , value='NEUTRAL'},
    {class={type='BUFFER', level=5}, type='MINE' , value='???'},
    {class={type='BUFFER', level=4}, type='OUTER', value=0},
    {class={type='BUFFER', level=4}, type='OUTER', value=0},
    {class={type='BUFFER', level=4}, type='OUTER', value=0},--]]
    {class={type='BUFFER', level=5}, type='OUTER', value=0},
  }

local lml = LML.Initialize(init)

--for k, v in pairs(lml) do print (k, '->', v) end

print (lml[1].class[1]==lml[1].features[1].class)

--x = {}
--x[lml[1].class[1]] = 666
--print (x[lml[1].features[1].class])
-- OK, to tłumaczy


local pp = Serialization.Table(lml)
--local pp = Serialization.Table(init)
--print (pp)

lml:Generate(Grammar, 10)

--print (Serialization.Table(lml))

--local pp = Serialization.Table({'www', true, 12, 45, 'xx'})

--local pp = Serialization.Table({[5]='www', [false]=true, 12, 'xx', ['w']='ww'})

--local pp = Serialization.Table({ [1]=12, [2]="xx", [false]=true, [5]="www", w="ww", })

--print (pp)

--print(Serialization.Serialization(lml[1]) ) -- bez [1] robi brzydko (!)


--]======]

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--[==[
local ConfigReader = require 'Configs/ConfigReader'

local Node = require('LMLGenerator/Node')
local Grammar = require('LMLGenerator/Grammar')
local Generator = require('LMLGenerator/Generator')
local DrawLib = require('LMLGenerator/DrawLib')
local GrammarLib = require('LMLGenerator/GrammarLib') -- todo remove (for testing only)

local LML = {}


function LML.New()
  local obj = {}
  setmetatable(obj, { __index = LML })
    

  return obj
end

--- Creates new LML 
-- todo - split into multiple functions if more than one LML will be generated, 
-- @param seed Random seed
-- @param initializer Data for initial graph node
function LML.Initialize(data, verbose)
  error ('Function not implemented')
end

--- Generates LML graph given initial node info
-- todo - split into multiple functions if more than one LML will be generated, 
-- @param seed Random seed
-- @param initializer Data for initial graph node
function GenerateLML(seed, initializer) -- todo gensettings argument (later)
  
  ---[[ For DEBUG ONLY
  if seed < 0 then
    seed = os.time() 
  end
  --]]
  --print ('Lua seed: '..seed)
  
  math.randomseed( seed ) -- seed set (!)
  
  local config = ConfigReader.read('Configs/LMLGenerator.cfg')

  local drawdir = 'LMLGenerator/debug_graphs/'..seed..'-'
  
  local step=0
  local initnode = Node:ParseNew(initializer)
  local generator = Generator:New(initnode)
  
  -- todo, tune grammar priorities given generator settings (later)
  
  
  --GrammarLib.ShuffleIndexesRoulette(Grammar) -- just debug test
  --print(string.match('L2', '(%a)(%d+)%((.*)%)'))
  --print(string.match('L2()', '(%a)(%d+)%((.*)%)'))
  --print(string.match('L47(B)', '(%a)(%d+)%((.*)%)'))
  --print(string.match('L7(B,8)', '(%a)(%d+)%((.*)%)'))
  
  
  while not generator:IsFinished() do
    step = step+1

    if config.draw_nonfinal then
      DrawLib.Draw(generator, drawdir..step, true)
    end
    
    if config.verbose then
      generator:Show() -- prints generator data on the screen
    end
    
    generator:Step(Grammar, config.verbose)
    
    
  end

  if config.draw_final then
    DrawLib.Draw(generator, drawdir..'end', true) 
  end
  
  -- todo return the value in the right form into c++
  -- todo after splitting into multiple functions?
end

-- todo trials (?)
-- todo Evaluator (?)


--[[
-------------------------------------------------------------------------------
local INITSTATE = 'c' -- data/ file sufix
local GRAMMAR   = '01'  -- data/ file sufix
local TRIALS    = 1
local DRAW_NONFINAL = false
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


math.randomseed( os.time() )

local initialNode = require('data/init_'..INITSTATE)
local grammar = require('data/grammar_'..GRAMMAR)







-- testzone


for trial=1,TRIALS do
  print ('      TRIAL   '..trial..'/'..TRIALS)
  
  local prefix = 'out_graphs/'..INITSTATE..'-'..trial..'-'
  local step=0
  --local generator = Generator:New(Node:New(initialNode))
  local generator = Generator:New(Node:ParseNew(initialNode))
  --break
  
  --assert(#generator.root.edges==0) -- ups

-- to uncomment soon -- todo
  while not generator:IsFinished() do
    step = step+1

    if DRAW_NONFINAL then DrawLib.Draw(generator, prefix..step, true) end
      
    generator:Show()
    generator:Step(grammar)
    
    
  end

  DrawLib.Draw(generator, prefix..'end', true)  
end

--]]

--]==]

