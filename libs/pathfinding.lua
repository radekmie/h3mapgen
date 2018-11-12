
local pq = require "loop.collection.PriorityQueue"

local pathfinding = {} 

local function heuristic(sx,sy,tx,ty)
  return math.max(math.abs(tx-sx),math.abs(ty-sy))
end

local function check(x,y,width,height)
  if x < 1 or x > width or y < 1 or y > height then
    return false
  else
    return true
  end
end

local diagonal_cost = 1 --can be modified
local normal_cost = 1

function pathfinding.search_path(world_grid,start,destination,size) --A* algorithm
  local map = {}
  for i = 1, 256 do
    map[i] = {}
  end
  for i = 1, 256 do
    for j = 1, 256 do
      map[i][j] = world_grid[i+j*256]
    end
  end
  local start_x = start[1]
  local start_y = start[2]
  local des_x = destination[1]
  local des_y = destination[2]
  local width = size[1]
  local heigth = size[2]
  
  local queue = {}
  pq.enqueue(queue,start_x + start_y*256,heuristic(start_x,start_y,des_x,des_y))
  
  local gmap = {}
  local inset = {}
  local evaluated = {}
  local camefrom = {}
  for i = 1, 256 do
    gmap[i] = {}
    inset[i] = {}
    evaluated[i] = {}
    camefrom[i] = {}
    for j = 1, 256 do
      gmap[i][j] = 999999
      inset[i][j] = false
      evaluated[i][j] = false
    end
  end
  gmap[start_x][start_y] = 0
  
  while pq.empty(queue) == false do
    local current = pq.dequeue(queue)
    local x,y = current%256, math.floor(current/256)%256
    if x == des_x and y == des_y then
      local path = {}
      local len = gmap[x][y]
      while x ~= start_x or y ~= start_y do
        table.insert(path,1,x+y*256)
        x,y = camefrom[x][y][1],camefrom[x][y][2]
      end
      return len,path
    end
    evaluated[x][y] = true
    for i = -1,1 do
      for j = -1,1 do
        if check(x+i,y+j,width,heigth) and map[x+i][y+j] ~= true and evaluated[x+i][y+j] == false then
          local new_score = gmap[x][y]
          if math.abs(i) + math.abs(j) == 2 then --diagonal move
            new_score = new_score + diagonal_cost
          end
          if math.abs(i) + math.abs(j) == 1 then
            new_score = new_score + normal_cost
          end
          if new_score < gmap[x+i][y+j] then
            gmap[x+i][y+j] = new_score
            camefrom[x+i][y+j] = {x,y}
            if inset[x+i][y+j] == true then
              pq.remove(queue, x+i + (y+j)*256)
              pq.enqueue(queue, x+i + (y+j)*256, gmap[x+i][y+j] + heuristic(x+i,y+j,des_x,des_y))
            end
          end
          if inset[x+i][y+j] == false then
            pq.enqueue(queue, x+i + (y+j)*256, gmap[x+i][y+j]+ heuristic(x+i,y+j,des_x,des_y))
            inset[x+i][y+j] = true 
          end
        end
      end
    end
  end
  return nil
end

return pathfinding
