local GrammarLib = {}


--- Splits given sequence of classes using pivot into three subsequences
-- Some sequences may be empty, order within sequences is arbitrary.
-- @param classes Sequence of classes
-- @param pivot Pivot (Class type) used to splitting
-- @return Sequences of classes smaller, equal and greater then given pivot
function GrammarLib.Split3ByPivot(classes, pivot)
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


--- Splits given sequence of classes using random pivot into two non-empty subsequences
-- @param classes Sequence of classes (should contain more than 2 classes)
-- @return Non-empty sequences of classes 'smaller' and 'greater-equal' then given pivot
function GrammarLib.Split2ByRandomPivot(classes)
  local pivot = classes[math.random(#classes)]
  local smaller, equal, greater = GrammarLib.Split3ByPivot(classes, pivot)
  for _, g in ipairs(greater) do
    table.insert(equal, g)
  end
  return smaller, equal
end


return GrammarLib