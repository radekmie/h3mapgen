local lib = require'LogicMapLayout/Grammar/GrammarLib'


local function f (lml, nonuniform_ids)
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
  zone.edges[nid] = true
  nzone.class = greater_c
  nzone.features = greater_f
  nzone.edges[id] = true
  return true
end


return  {
          { priority=2, f=f, short_desc='Noname-1', desc='How it exactly works-1'},
          { priority=2, f=f, short_desc='Noname-2', desc='How it exactly works-2'},
        }