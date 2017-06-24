local lib = require'LogicMapLayout/Grammar/GrammarLib'


local function divide_pivot_1 (lml, nonuniform_ids) 
  local id = nonuniform_ids[1]
  local zone = lml[id]
  local smaller_c, greater_c = lib.Split2ByRandomPivot(zone.class)
  local smaller_f, greater_f = {}, {}
  for _, f in ipairs(zone.features) do
    if f:IsConsistentWith(greater_c) then
      greater_f[#greater_f+1] = f
    else
      smaller_f[#smaller_f+1] = f
    end
  end
  local nid, nzone = lml:AddZone()
  zone.class = smaller_c
  zone.features = smaller_f
  nzone.class = greater_c
  nzone.features = greater_f
  lib.AddEdge(lml, id, nid)
  return true
end


local function connect_uniform (lml, nonuniform_ids) 
  local uniform_ids = {}
  for id, zone in ipairs(lml) do
    if zone:IsUniform() then uniform_ids[#uniform_ids+1] = id end
  end
  if #uniform_ids < 2 then return false end
  
  local id1 = math.random(#uniform_ids)
  local id2 = id1
  while id2 == id1 do id2 = math.random(#uniform_ids) end
  
  lib.AddEdge(lml, id1, id2)
  return true
end





return  {
          { priority= 0, f=divide_pivot_1, short_desc='Test-NONPOSITIVE', desc='xyz'},
          { priority= 3, f=divide_pivot_1, short_desc='Divide pivot A => A-B', desc='Divides one nonunifor node into two connected using feature pivot'},
          { priority= 1, f=connect_uniform, short_desc='Connect uniform A B => A-B', desc='Adds edge between two random uniform nodes'},
        }