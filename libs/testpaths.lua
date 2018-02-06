paths = require "pathfinding"

map = {}
for i = 1,256 do
  for j =1,256 do
    map[i+j*256] = false
  end
end

map[258] = true
map[514] = true
path,len = paths.search_path(map,257,259) -- start x = 1, start y = 1, des x = 3, des y = 1

for i = 1,#path do
  print(path[i]%256, math.floor(path[i]/256)%256)
end
print(len)