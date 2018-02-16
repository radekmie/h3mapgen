local mlml = {} 

function mlml.checkFairness (connections)
  -- for the connections to be fair they must meet a few conditions:
  -- 1. from every node there must be the same amount of connections
  -- 2. the created graph must be completely travelsable
  -- 3. every node must have exactly the same amount of players to which they have connections, and amount of those connections.
  -- 4. every node must have exactly the same connections of ids.
  --checking 1.
  local len = #connections[1]
  for i = 2, #connections do
    if #connections[i] ~= len then
      return false
    end
  end
  --checking 2.
  local checked = {}
  local queue = {}
  queue[1] = true
  local cur = nil
  for i = 1, #connections do
    if cur == nil and queue[i] == true and checked[i] ~= true then
      cur = i
      checked[i] = true
    end
    if cur ~= nil then
      for j = 1, #connections[cur] do
        queue[connections[cur][j][3]] = true
      end
    end
    cur = nil
  end
  for i = 1, #connections do
    if checked[i] ~= true then
      return false
    end
  end
  --checking 3.
  local bucket = {} -- bucket[i][j] = 3 -> player i has 3 connections to player j
  for i = 1, #connections do
    bucket[i] = {}
    for j = 1, #connections do
      bucket[i][j] = 0
    end
  end
  for i = 1, #connections do
    for j = 1, #connections[i] do
      local id = connections[i][j][3]
      bucket[i][id] = bucket[i][id] + 1
    end
  end
  local bucket2 = {} -- bucket2[i][j] = 2 -> there are 2 players to which player i has j connections
  for i = 1, #connections do
    bucket2[i] = {}
    for j = 0, len do
      bucket2[i][j] = 0
    end
  end
  for i = 1, #bucket do
    for j = 1, #bucket[i] do
      bucket2[i][bucket[i][j]] = bucket2[i][bucket[i][j]] + 1
    end
  end
  for i = 2, #bucket2 do
    for j = 0, #bucket2[i] do
      if bucket2[1][j] ~= bucket2[i][j] then
        return false
      end
    end
  end
  --checking 4.
  for i = 2, #connections do
    for j = 1, len do
      local pass = false
      local from = connections[1][j][1]
      local to = connections[1][j][2]
      for q = 1, len do
        if connections[i][q][1] == from and connections[i][q][2] == to then
          pass = true
        end
      end
      if pass == false then
        return false
      end
    end
  end
  return true
end

local function Connect(connections, node, player_count, is_busy, cur_ply, cur_node)
  if cur_ply > player_count then
    if mlml.checkFairness(connections) == true then
      return connections
    else
      return nil
    end
  end
  if is_busy[cur_ply][cur_node] == true then
    cur_node = cur_node + 1
    if cur_node > #node then
      cur_ply = cur_ply+1
      cur_node = 1
    end
    return Connect(connections, node, player_count, is_busy, cur_ply, cur_node)
  else
    for i = 1, player_count do
      for j = 1, #node do
        if i ~= cur_ply and is_busy[i][j] == false and ((node[cur_node][2] == 'LOCAL' and node[j][2] == 'LOCAL') or (node[cur_node][2] == node[j][2] and node[cur_node][3] == node[j][3])) then 
          --add connection
          is_busy[cur_ply][cur_node] = true
          is_busy[i][j] = true
          local c_len = #connections[cur_ply]
          connections[cur_ply][c_len+1] = {node[cur_node][1], node[j][1], i}
          c_len = #connections[i]
          connections[i][c_len+1] = {node[j][1], node[cur_node][1], cur_ply}
          cur_node = cur_node + 1
          if cur_node > #node then
            cur_ply = cur_ply+1
            cur_node = 1
          end
          
          local result = Connect(connections, node, player_count, is_busy, cur_ply, cur_node)
          if result ~= nil then
            return result
          end
          
          --delete connection
          cur_node = cur_node - 1
          if cur_node < 1 then
            cur_ply = cur_ply-1
            cur_node = #node
          end
          c_len = #connections[i]
          connections[i][c_len] = nil
          c_len = #connections[cur_ply]
          connections[cur_ply][c_len] = nil
          is_busy[i][j] = false
          is_busy[cur_ply][cur_node] = false
        end
      end
    end
  end
  return nil
end

function mlml.MultiplyLML (node, player_count)
  local connections = {}
  local is_busy = {}
  for i = 1, player_count do
    is_busy[i] = {}
    connections[i] = {}
    for j = 1, #node do
      is_busy[i][j] = false
    end
  end
  return Connect(connections, node, player_count, is_busy, 1, 1)
end

return mlml