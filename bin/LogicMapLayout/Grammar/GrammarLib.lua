local GrammarLib = {}


--- Splits given sequence of classes using pivot into three subsequences
-- Some sequences may be empty, order within sequences is arbitrary.
-- @param classes Sequence of classes
-- @param pivot Pivot used to splitting
-- @return Sequences of classes smaller, eqaual and greater then given pivot
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
-- Classes equal to pivot are distributed randomly.
-- @param classes Sequence of classes (should contain more than 2 classes)
-- @return Non-empty sequences of classes smaller-equal, greater-equal then given pivot
function GrammarLib.Split2ByRandomPivot(classes)
  assert(#classes >= 2, 'Split2ByRandomPivot expects sequence of at least 2 classes, '..#classes..' given.')
  local pivot = classes[math.random(#classes)]
  local smaller, equal, greater = GrammarLib.Split3ByPivot(classes, pivot)
  if #smaller==0 then
    smaller[1], equal[#equal] = equal[#equal], nil
  end
  if #greater==0 then
    greater[1], equal[#equal] = equal[#equal], nil
  end
  for _, v in ipairs(equal) do
    if math.random(2)==1 then
      smaller[#smaller+1] = v
    else
      greater[#greater+1] = v
    end
  end
  return smaller, greater
end


return GrammarLib