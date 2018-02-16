
package.path = ";tests/lml/?.lua" .. package.path
local function write(graph)
  print()
  if graph == nil then
    print('there is no graph')
    print()
  else
    for i = 1, #graph do
      for j = 1, #graph[i] do
        print(graph[i][j][1],graph[i][j][2],graph[i][j][3])
      end
      print()
    end
  end
end

mlml = require "mlml"

local result = mlml.MultiplyLML({{1, 'LOCAL', 2},{2, 'LOCAL', 3},{3, 'LOCAL', 5}}, 3)
print('test1:')
write(result)
result = mlml.MultiplyLML({ {1, 'LOCAL', 2}, {3,'LOCAL',4}}, 4)
print('test2:')
write(result)
result = mlml.MultiplyLML({ {1, 'LOCAL', 5}, {3,'TELEPORT',5}, {4,'TELEPORT',3},{5,'LOCAL',2}}, 6)
print('test3:')
write(result)
result = mlml.MultiplyLML({ {1, 'LOCAL', 2}, {2, 'LOCAL', 3} }, 5)
print('test4:')
write(result)