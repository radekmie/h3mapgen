package.path = ";../../components/params/?.lua" .. package.path
package.path = ";../../libs/?.lua" .. package.path

local Params = require'Params'
local ConfigHandler = require'ConfigHandler'


local function Test(name)
  local state = ConfigHandler.Read(name..'-input.h3pgm')  
  state.config = ConfigHandler.Read('../../config.cfg')
  
  local xx = {}
  
  xx.KOT='a'
  xx['10']= 'b'
  xx['3.14']= 'b'
  xx['a\nb']='c'
  xx['ab ']='c'
  
  state.xx=xx
  
  Params.GenerateDetailedParams(state)
  ConfigHandler.Write(name..'-output.h3pgm', state)
end


Test('00')
Test('01')
