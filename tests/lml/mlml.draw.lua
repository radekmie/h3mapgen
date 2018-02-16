
package.path = ";tests/lml/?.lua" .. package.path
package.path = ";libs/?.lua" .. package.path

local GD = require'GraphvizDrawer'

local function MetaLMLImage(metaLML)
  local gd = GD.New()
  gd:AddNode{id=0, shape='circle', label='P'}
  for i, edge in ipairs(metaLML) do
    gd:AddNode{id=i, shape='none', label=''}
    gd:AddEdge(0, i, {label=string.format('(%d) %s%d', edge[1], edge[2], edge[3])})
  end
  return gd
end


local function MetaMLMLImage(metaMLML, metaLML)
  local gd = GD.New()
  
  local idtoclass={}
  for _, edge in ipairs(metaLML) do
    idtoclass[edge[1]] = edge[2]..edge[3]
  end
  
  for pid, edges in ipairs(metaMLML) do
    gd:AddNode{id='p'..pid, shape='circle', label='P'..pid}
    for num, edge in ipairs(edges) do
      local eid1, eid2, pid2 = table.unpack(edge)
      --print (pid, '->', eid1, eid2, pid2)
      if pid2 > pid then 
        local e = 'e'..pid..'x'..num
        gd:AddNode{id=e, shape='point', label=''}
        gd:AddEdge('p'..pid, e, {label=string.format('(%d) %s', eid1, idtoclass[eid1])})
        gd:AddEdge(e, 'p'..pid2, {label=string.format('(%d) %s', eid2, idtoclass[eid2])})
      end
    end
  end
  
  return gd
end

local mlml = require "mlml"

local function Test(name, metalml, players) 
  MetaLMLImage(metalml):Draw(string.format('tests/lml/%s-%d-LML', name, players), false)
  local result = mlml.MultiplyLML(metalml, players)
  if not result then
    print ('ERROR: No result for test "'..name..'" ('..players..' players).')
    return
  end
  MetaMLMLImage(result, metalml):Draw(string.format('tests/lml/%s-%d-MultiLML', name, players), false)
  print ('OK: Test "'..name..'" ('..players..' players) done.')
end
  
  
Test('t1', 
     {{1, 'LOCAL', 2},{2, 'LOCAL', 3},{3, 'LOCAL', 5}}, 
     3)

Test('t2', 
     { {1, 'LOCAL', 2}, {3,'LOCAL',4}}, 
     3)
   
Test('t3', 
     { {1, 'LOCAL', 5}, {3,'BUFFER',5}, {3,'BUFFER',3},{5,'LOCAL',2}},  -- same id's
     4)
   
Test('t4', 
     { {1, 'LOCAL', 2}, {2, 'LOCAL', 3} },
     5)
   
Test('tX', 
     { {1, 'LOCAL', 5}, {3,'BUFFER',5}, {3,'BUFFER',3},{5,'LOCAL',2}}, 
     2)
