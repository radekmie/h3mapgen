local RNG = require'Random'

local LMLInitializer = {}

local rand = RNG.Random




--- Function generates 'LML_InitNodefield containing initial node for LML stage.
-- @param state H3pgm state after GenerateDetailedParams function applied (requires 'detailedParams')
function LMLInitializer.Generate(state)  
  
  
  -- TODO HERE ALL
  
  local dp = {}
  for k, v in pairs(state.userMapParams) do
    if type(state.userMapParams[k]) ~= 'table' then
      dp[k] = state.userMapParams[k]
    else
      dp[k] = {table.unpack(state.userMapParams[k])}
    end
  end
  
  if dp.seed == 0 then
    dp.seed = os.time()
  end
  math.randomseed(dp.seed)
  state.detailedParams = dp
  
  RandomizeNotChosen(state)
  
  SetBasicInformation(state)
  SetNumberOfZones(state)
  
  -- todo
  -- potem mamy zbiór podfunkcji nadpisujący rózne konkretne wartości detailedParams (liczby zamków, priorytety produkcji, itd, itp)
  
end
-- DetailedParams.Generate


return LMLInitializer