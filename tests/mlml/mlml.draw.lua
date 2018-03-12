package.path = ";tests/mlml/?.lua" .. package.path
package.path = ";components/lml/?.lua" .. package.path
package.path = ";libs/?.lua" .. package.path

local GD = require'GraphvizDrawer'
local Metagraph = require'Metagraph'
local mlml = require "mlml"


-- TODO - rewrite within proper object in components/mlml (probably mlml/Metagraph)
local function MetaMLMLImage(metaMLML, metaLML)
  local gd = GD.New()
  
  local idtoclass={}
  for _, edge in ipairs(metaLML) do
    idtoclass[edge[1]] = edge[2]:sub(1,1)..edge[3]
  end
  
  for pid, edges in ipairs(metaMLML) do
    gd:AddNode{id='p'..pid, shape='circle', label='P'..pid}
    for num, edge in ipairs(edges) do
      local eid1, eid2, pid2 = table.unpack(edge)
      --print (pid, '->', eid1, eid2, pid2)
      if pid2 > pid then 
        local e = 'e'..pid..'x'..num
        gd:AddNode{id=e, shape='point', label=''}
        gd:AddEdge('p'..pid, e, {label=string.format('%d/%s', eid1, idtoclass[eid1])})
        gd:AddEdge(e, 'p'..pid2, {label=string.format('%d/%s', eid2, idtoclass[eid2])})
      end
    end
  end
  
  return gd
end


local function Test(name, metalml, players) 
  local metagraph = Metagraph.New(metalml)
  metagraph:Image():Draw(string.format('tests/mlml/%s-%d-LML', name, players), false)
  local result = mlml.MultiplyLML(metagraph, players)
  if not result then
    print ('ERROR: No result for test "'..name..'" ('..players..' players).')
    return
  end
  MetaMLMLImage(result, metagraph):Draw(string.format('tests/mlml/%s-%d-MultiLML', name, players), false)
  print ('OK: Test "'..name..'" ('..players..' players) done.')
end
  

Test('t1', 
     {{1, 'LOCAL', 2},{2, 'LOCAL', 3},{3, 'LOCAL', 5}}, 
     3)

Test('t2', 
     { {1, 'LOCAL', 2}, {3,'LOCAL',4}}, 
     3)
   
Test('t3', 
     { {1, 'LOCAL', 5}, {3,'BUFFER',5}, {3,'BUFFER',3},{5,'LOCAL',2},{9,'BUFFER',8}},  -- same id's
     4)
   
Test('t4', 
     { {1, 'LOCAL', 2}, {2, 'LOCAL', 3} },
     5)

Test('tX', 
     { {1, 'LOCAL', 5}, {2, 'LOCAL', 6}, {6,'LOCAL',5}},-- {1, 'LOCAL', 5}, {2,'LOCAL',5}, {3,'LOCAL',3},{5,'LOCAL',2}}, 
     6)
