local Zone = require'graph/Zone'
local RNG = require'Random'

local GrammarLib = {}

local rand = RNG.Random


--- Split features by their type into several sequences 
-- @param features Sequence of features to split
-- @return Sequences of features containing respectively: towns, basemines, primarymines, randommines, goldmines, outers, teleports
function GrammarLib.FeatureSplitByType(features)
  local towns, basemines, primarymines, randommines, goldmines, outers, teleports = {}, {}, {}, {}, {}, {}, {}
  for _, f in ipairs(features) do
    if f.type=='TOWN' then table.insert(towns, f)
    elseif f.type=='MINE' and f.value=='BASE' then table.insert(basemines, f)
    elseif f.type=='MINE' and f.value=='PRIMARY' then table.insert(primarymines, f)
    elseif f.type=='MINE' and f.value=='RANDOM' then table.insert(randommines, f)
    elseif f.type=='MINE' and f.value=='GOLD' then table.insert(goldmines, f)
    elseif f.type=='OUTER' then table.insert(outers, f)
    elseif f.type=='TELEPORT' then table.insert(teleports, f)
    end
  end
  return towns, basemines, primarymines, randommines, goldmines, outers, teleports
end


--- Compute zone's interestingness looking at its features
-- @param zone Zone to evaluate
-- @param values Map from features into their values
-- @return Value of the given zone
function GrammarLib.ZoneInterestingness(zone, values)
  local value = 0
  local towns, basemines, primarymines, randommines, goldmines, outers, teleports = GrammarLib.FeatureSplitByType(zone.features)
  value = value + values.TOWN * #towns
  value = value + values.BASEMINE * #basemines
  value = value + values.PRIMARYMINE * #primarymines
  value = value + values.RANDOMMINE * #randommines
  value = value + values.GOLDMINE * #goldmines
  value = value + values.OUTER * #outers
  value = value + values.TELEPORT * #teleports
  return value
end
-- GrammarLib.ZoneInterestingness


--- Generates comparator for sorting zones
-- @param values Map from features into their values
-- @return Comparator for sorting list of zones by their interestingness
function GrammarLib.ZoneInterestComparatorFactory(values)
  return function (zone1, zone2) -- Returns true if first zone is less interesting the the second
    return GrammarLib.ZoneInterestingness(zone1, values) < GrammarLib.ZoneInterestingness(zone2, values)
  end
end
-- GrammarLib.ZoneInterestComparatorFactory


--- Distributes features within some number of equal-class local zones
-- We start with towns, then gold mines, random mines, primary mines, base mines, then outers and teleports
-- Works the same as FeatureDistributionStrategyBuffer but uses different order of priorities and weights
-- @param features Sequence of features to distribute (should belong to one class!)
-- @param n Number of zones to distribute feature
-- @param config Configuration file content
-- @return Sequence of zones with empty classes and distributed features
function GrammarLib.FeatureDistributionStrategyLocal(features, n, config)
  local zones = {}
  for i=1,n do zones[i] = Zone.New() end
  local towns, basemines, primarymines, randommines, goldmines, outers, teleports = GrammarLib.FeatureSplitByType(features)
  for _, types in ipairs {towns, goldmines, randommines, primarymines, basemines, outers, teleports} do
    for _, f in ipairs(types) do
      table.insert(zones[1].features, f)
      table.sort(zones,  GrammarLib.ZoneInterestComparatorFactory(config.FeatureInterestingnessValuesLocal))
    end
  end
  return zones
end
-- GrammarLib.FeatureDistributionStrategyLocal


--- Distributes features within some number of equal-class buffer zones
-- We start with outers, teleports then towns, gold mines, random mines, primary mines, and base mines
-- Works the same as FeatureDistributionStrategyLocal but uses different order of priorities and weights
-- @param features Sequence of features to distribute (should belong to one class!)
-- @param n Number of zones to distribute feature
-- @param config Configuration file content
-- @return Sequence of zones with empty classes and distributed features
function GrammarLib.FeatureDistributionStrategyBuffer(features, n, config)
  local zones = {}
  for i=1,n do zones[i] = Zone.New() end
  local towns, basemines, primarymines, randommines, goldmines, outers, teleports = GrammarLib.FeatureSplitByType(features)
  for _, types in ipairs {outers, teleports, towns, goldmines, randommines, primarymines, basemines} do
    for _, f in ipairs(types) do
      table.insert(zones[1].features, f)
      table.sort(zones,  GrammarLib.ZoneInterestComparatorFactory(config.FeatureInterestingnessValuesBuffer))
    end
  end
  return zones
end
-- GrammarLib.FeatureDistributionStrategyBuffer


--- Splits given sequence of classes using pivot into three subsequences: smaller, equal, greater
-- Some sequences may be empty, order within sequences is arbitrary.
-- @param classes Sequence of classes
-- @param pivot Pivot (Class type) used to splitting
-- @return Sequences of classes smaller, equal and greater then given pivot
function GrammarLib.SplitInto3ByPivot(classes, pivot)
  local smaller, equal, greater = {}, {}, {}
  for _, c in ipairs(classes) do
    if c < pivot then
      smaller[#smaller+1] = c
    elseif c == pivot then
      equal[#equal+1] = c
    else
      greater[#greater+1] = c
    end
  end
  return smaller, equal, greater
end
-- GrammarLib.SplitInto3ByPivot


--- Splits given sequence of classes using random pivot into two non-empty subsequences: smaller and grater-equal
-- @param classes Sequence of classes (should contain at least 2 classes)
-- @return Non-empty sequences of classes 'smaller' and 'greater-equal' then uniformly chosen  pivot
function GrammarLib.SplitInto2ByRandomPivotUniformly(classes)
  local pivot = RNG.Choice(classes)
  local smaller, equal, greater = GrammarLib.SplitInto3ByPivot(classes, pivot)
  for _, g in ipairs(greater) do
    table.insert(equal, g)
  end
  return smaller, equal
end
-- GrammarLib.SplitInto2ByRandomPivotUniformly


--- Splits given sequence of classes using random pivot (geometric-sequence-weight based) into two non-empty subsequences: smaller and grater-equal
-- @param classes Sequence of classes (should contain at least 2 classes)
-- @param ratio Parameter modifying weights of subsequent classes (in geometric progression)
-- @return Non-empty sequences of classes 'smaller' and 'greater-equal' then non-uniformly chosen pivot
function GrammarLib.SplitInto2ByDeltaBasedPivot(classes, ratio)
  local weightMap = {0, 1}
  for i=3,#classes do
    table.insert(weightMap, weightMap[#weightMap] * ratio)
  end
  --local x={} for _, c in ipairs(classes) do table.insert(x,tostring(c)) end print (table.concat(x, ', '))
  --local y={} for _, w in ipairs(weightMap) do table.insert(y,tostring(w)) end print (table.concat(y, ', '))  
  local index = RNG.RouletteWheelTab(weightMap) --print (index)
  local pivot = classes[index]
  
  local smaller, equal, greater = GrammarLib.SplitInto3ByPivot(classes, pivot)
  for _, g in ipairs(greater) do
    table.insert(equal, g)
  end
  return smaller, equal
end
-- GrammarLib.SplitInto2ByDeltaBasedPivot


--- Checks if given set of features is safe, i.e. it does not contain buffers or at least one buffer has an outer
-- @param classes Sequence of classes to check
-- @param features Sequence of features to check
-- @return true if there is outer feature for buffer or there are no buffers at all, false otherwise
function GrammarLib.CheckForBufferWithOuter(classes, features)
  local nobuf = true
  for _, c in ipairs(classes) do
    if c.type=='BUFFER' then
      nobuf = false
      break
    end
  end
  if nobuf then return true end
  
  local bufouter=false
  for _, f in ipairs(features) do
    if f.type=='OUTER' and f.class.type=='BUFFER' then
      bufouter = true
    end
  end
  if not bufouter then return false end
  
  local class = classes[1] -- additional check for 'DivideEqualHorizontally' safety
  for _, c in ipairs(classes) do
    if c ~= class then return true end
  end
  local outercount = 0
  for _, f in ipairs(features) do
    if f.type=='OUTER' then
      outercount = outercount + 1
    end
  end  
  if outercount < #classes then return false end

  return true
end
-- GrammarLib.CheckForBufferWithOuter


return GrammarLib