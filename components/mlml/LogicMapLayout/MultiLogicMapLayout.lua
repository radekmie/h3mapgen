local Node = require'components/mlml/LogicMapLayout/MLMLNode'


local MLML = {}
local MLML_mt = { __index = MLML, __metatable = "Access restricted." }


--- Creates new MLML object initialized with given lml interface data.
-- @param lml_interface - LML interface
-- @return New, initialized MLML object containing lml interface
function MLML.Initialize(lml_interface)
  local obj = {}
  obj.lml = lml_interface
  return setmetatable(obj, MLML_mt)
end


--- Sets the mode for MLML.
-- MLML objects have to be initialized before calling SetMode.
-- when set to true, will cause buffers to not merge automatically, default mode merges automatically
-- @param lazyBufferEdges Constant equal to true or nil
function MLML:SetMode(lazyBufferEdges)
  self.lazyBufferEdges = lazyBufferEdges
end


--- Resets the local graphs and utility tables, intializes them again from LML.
-- MLML objects have to be initialized before calling Generate.
-- @param PLAYERS_NUM Constant containing number of players for the MLML graph
function MLML:InitialSetup(PLAYERS_NUM)

  self.playersNum = PLAYERS_NUM

  -- will hold sets of "connected players", will be merged when player graphs connect for the first time
  self.connected = {}
  for playerId = 1, PLAYERS_NUM do
    table.insert(self.connected, {playerId})
  end

  -- will hold definitions of newly created edges
  self.newEdges = {}

  -- will hold sets of shiftedIds which should be zipped
  self.toZip = {}

  self.localGraphs = {}
  for playerId = 1, PLAYERS_NUM do
    self.localGraphs[playerId] = {}
    
    local idShift = #self.lml * (playerId - 1)

    for _,zone in ipairs(self.lml) do
      local zCopy = {}
      zCopy.id = zone.id + idShift
      zCopy.baseId = zone.id
      zCopy.type = zone.type

      local edges = {}
      for _,k in pairs(zone.edges) do
        local shiftedId = k + idShift
        if not edges[shiftedId] then
          edges[shiftedId] = 0
        end
        edges[shiftedId] = edges[shiftedId] + 1
      end
      zCopy.edges = edges

      local outer = {}
      for _,k in ipairs(zone.outer) do
        table.insert(outer, k)
      end
      zCopy.outer = outer

      table.insert(self.localGraphs[playerId], zCopy)
    end
  end

end


function MLML:AddEdge(leftZoneId, rightZoneId)
  
  if not self.newEdges[leftZoneId] then
    self.newEdges[leftZoneId] = {}
  end
  table.insert(self.newEdges[leftZoneId], rightZoneId)

  if not self.newEdges[rightZoneId] then
    self.newEdges[rightZoneId] = {}
  end
  table.insert(self.newEdges[rightZoneId], leftZoneId)

end


-- requires at least 2 occurrences of baseId (zones[index]) in zones.
function MLML:CreateRing(zones, index)

  local zoneId = zones[index]

  local orderTable = {}
  for i = 1, self.playersNum do
    table.insert(orderTable, i)
  end

  if self.playersNum > 3 then
    -- when 2-3 players, there is only one "order" which can be used anyway
    for i = #orderTable, 1, -1 do
      local j = math.random(i)
      orderTable[i], orderTable[j] = orderTable[j], orderTable[i]
    end
  end

  local idShift = #self.lml
  for leftIndex = 1, #orderTable do
    local rightIndex = (leftIndex + 1) % self.playersNum

    local leftZoneId = idShift * (orderTable[leftIndex] - 1) + zoneId
    local rightZoneId = idShift * (orderTable[rightIndex] - 1) + zoneId

    self.AddEdge(leftZoneId, rightZoneId)
  end

  if #self.connected > 1 then
    -- all players are now joined
    local connected = {}
    for playerId = 1, PLAYERS_NUM do
      table.insert(connected, playerId)
    end
    self.connected = connected
  end

  table.remove(zones, index)
  for searchIndex = index, #zones do
    if zones[searchIndex] == zone then
      table.remove(zones, index)
      break
    end
  end

end

-- choose best pairs to connect most players.
-- self.connected size is 1, n/2 or n
-- if it is n or 1, then create random pairs
-- if it is n/2 go through all self.connected pairs (should have 2 elements each), join random from 1, with random from 2, other from 2 with random from 3, other from 3... etc
-- can only be called for even number of players, does not make sense to call on odd number of players.
function MLML:CreatePairs(baseId)

  if self.playersNum % 2 == 1 then
    return
  end

  local idShift = #self.lml
  local joinPlayers = function(playerId1, playerId2)
    local leftZoneId = idShift * (playerId1 - 1) + baseId
    local rightZoneId = idShift * (playerId2 - 1) + baseId

    self.AddEdge(leftZoneId, rightZoneId)
  end

  if #self.connected == self.playersNum / 2 then
    -- players are in pairs, so now we join the pairs in some random order into a ring so everyone is connected
    local connectedShuffled = {}
    for _,pair in pairs(self.connected) do
      table.insert(connectedShuffled, pair)
    end

    for i = #connectedShuffled, 1, -1 do
      local j = math.random(i)
      connectedShuffled[i], connectedShuffled[j] = connectedShuffled[j], connectedShuffled[i]
    end

    local newOrder = {}
    for index, pair in ipairs(connectedShuffled) do
      local switchOrder = math.random(2) == 1
      if switchOrder then
        table.insert(newOrder, pair[2])
        table.insert(newOrder, pair[1])
      else
        table.insert(newOrder, pair[1])
        table.insert(newOrder, pair[2])
      end
    end

    while #newOrder > 2 do
      joinPlayers(newOrder[2], newOrder[3])
      table.remove(newOrder, 3)
      table.remove(newOrder, 2)
    end
    joinPlayers(newOrder[1], newOrder[2])

    -- all players are now joined
    local connected = {}
    for playerId = 1, self.playersNum do
      table.insert(connected, playerId)
    end
    self.connected = connected

  else
    local toBeConnected = {}
    for i = 1, self.playersNum do
      table.insert(toBeConnected, i)
    end

    local connected = {}
    while #toBeConnected > 1 do
      local secondConnector = math.random(#toBeConnected, 2)

      joinPlayers(toBeConnected[1], toBeConnected[secondConnector])

      table.insert(connected, {toBeConnected[1], toBeConnected[secondConnector]})

      table.remove(toBeConnected, secondConnector)
      table.remove(toBeConnected, 1)
    end
    if #self.connected > 1 then
      self.connected = connected
    end

  end

end


function MLML:JoinIntoRing(baseIdSource, baseIdTarget)

  local orderTable = {}
  for i = 1, self.playersNum do
    table.insert(orderTable, i)
  end

  if self.playersNum > 3 then
    -- when 2-3 players, there is only one "order" which can be used anyway
    for i = #orderTable, 1, -1 do
      local j = math.random(i)
      orderTable[i], orderTable[j] = orderTable[j], orderTable[i]
    end
  end

  local idShift = #self.lml
  for leftIndex = 1, #orderTable do
    local rightIndex = (leftIndex + 1) % self.playersNum

    local leftZoneId = idShift * (orderTable[leftIndex] - 1) + baseIdSource
    local rightZoneId = idShift * (orderTable[rightIndex] - 1) + baseIdTarget

    self.AddEdge(leftZoneId, rightZoneId)
  end

  if #self.connected > 1 then
    -- all players are now joined
    local connected = {}
    for playerId = 1, PLAYERS_NUM do
      table.insert(connected, playerId)
    end
    self.connected = connected
  end

end


--- Finds buffers which can be merged automatically, removes their outer edges, adds information about merge to be made.
-- Private function to be called only inside Generate function.
function MLML:AutoMergeBuffers()

  for _,zone in ipairs(self.lml) do
    if zone.type == 'BUFFER' then
      -- if has more than 1 outer, can be merged into one, this will lighten the load on edge finding.
      -- we usually expect buffers to be merged, so this function can automatically update the graphs so that the buffers are in fact merged
    end
  end
  
end


--- Tries to connect all outer edges fairly, without mixing between levels.
-- Private function to be called only inside Generate function.
function MLML:ConnectOutersWithoutMixingLevels(outers, isBuffers)

  for _, zones in pairs(outers) do
    local index = 1
    while index <= #zones do
      local zoneId = zones[index]
      local zoneCount = 1
      for countIndex = index + 1, #zones do
        if zones[countIndex] == zoneId then
          zoneCount = zoneCount + 1
        end
      end

      if self.playersNum % 2 == 1 then
        while zoneCount > 1 do
          self.CreateRing(zones, index)
          zoneCount = zoneCount - 2
        end
      else
        if isBuffers then
          if zoneCount > 1 then
            local zonesToZip = {}
            for playerId = 1, self.playersNum do
              local idShift = #self.lml * (playerId - 1)
              table.insert(zonesToZip, zoneId + idShift)
            end

            for zipIndex = #zones, 1, -1 do
              if zones[zipIndex] == zoneId then
                table.remove(zones, zipIndex)
              end
            end

            table.insert(self.toZip, zonesToZip)
            zoneCount = 0
          end
        end

        while zoneCount > 1 do
          self.CreateRing(zones, index)
          zoneCount = zoneCount - 2
        end

        if zoneCount == 1 then
          self.CreatePairs(zoneId)
          table.remove(zones, index)
          zoneCount = 0
        end
      end
    end
  end

  for _, zones in pairs(outers) do
    while #zones > 1 then
      self.JoinIntoRing(zones[1], zones[2])

      table.remove(zones, 2)
      table.remove(zones, 1)
    end
  end

end


--- Tries to connect all outer edges fairly, while mixing between levels.
-- Private function to be called only inside Generate function.
-- To be called only after calling ConnectOutersWithoutMixingLevels.
-- After calling ConnectOutersWithoutMixingLevels, levels should have at most 1 zoneId each.
function MLML:ConnectOutersWhileMixingLevels(outers)

  local findAnyPair = function()
    local index1 = nil
    local level1 = nil

    for level, zones in pairs(outers) do
      if #zones > 0 then
        if index1 then
          return index1, level1, 1, level
        end

        if #zones > 1 then
          return 1, level, 2, level
        end

        index1 = 1
        level1 = level
      end
    end

    return index1, level1, nil, nil
  end

  local index1, level1, index2, level2 = findAnyPair()
  while index1 and index2 do
    local zone1 = outers[level1][index1]
    local zone2 = outers[level2][index2]

    self.JoinIntoRing(zone1, zone2)

    table.remove(outers[level2], index2)
    table.remove(outers[level1], index1)

    index1, level1, index2, level2 = findAnyPair()
  end

end


--- Tries to connect all outer edges fairly, using buffers and locals together.
-- Private function to be called only inside Generate function.
-- To be called only after calling ConnectOutersWhileMixingLevels.
-- After calling ConnectOutersWhileMixingLevels, bufferOuters and localOuters should have at most 1 zoneId each.
function MLML:ConnectOuters(bufferOuters, localOuters)
  local findAnyOuter = function(outers)
    for level, zones in pairs(outers) do
      if #zones > 0 then
        return 1, level
      end
    end

    return nil, nil
  end

  local bufferIndex, bufferLevel = findAnyOuter(bufferOuters)
  local localIndex, localLevel = findAnyOuter(localOuters)

  while bufferIndex and localIndex do
    local bufferOuter = bufferOuters[bufferLevel][bufferIndex]
    local localOuter = localOuters[localLevel][localIndex]

    self.JoinIntoRing(bufferOuter, localOuter)

    table.remove(bufferOuters[bufferLevel], bufferIndex)
    table.remove(localOuters[localLevel], localIndex)

    bufferIndex, bufferLevel = findAnyOuter(bufferOuters)
    localIndex, localLevel = findAnyOuter(localOuters)
  end

end


--- Generates MLML based on initialized lml interface.
-- MLML objects have to be initialized before calling Generate.
-- @param PLAYERS_NUM Constant containing number of players for the MLML graph
function MLML:Generate(PLAYERS_NUM)

  self.InitialSetup(PLAYERS_NUM)

  if self.lazyBufferEdges then
    self.AutoMergeBuffers()
  end

  -- for the graphs to be fair, whenever we use a buffer (or local) outer edge for a player, it should be used for all players.
  -- this allows us to use only single copy of buffer outers and local outers.
  -- but whenever we use an outer (or 2), we need to use them for all players at once.
  local bufferOuters = {}
  local localOuters = {}
  for _,zone in ipairs(self.lml) do
    for _,outLevel in ipairs(zone.outer) do
      if zone.type == "LOCAL" then
        if not localOuters[outLevel] then
          localOuters[outLevel] = {}
        end
        table.insert(localOuters[outLevel], zone.id)
      else
        if not bufferOuters[outLevel] then
          bufferOuters[outLevel] = {}
        end
        table.insert(bufferOuters[outLevel], zone.id)
      end
    end
  end

  local unusedOutersExist = function(outers)
    for _,zones in pairs(outers) do
      if #zones > 0 then
        return true
      end
    end
    return false
  end

  self.ConnectOutersWithoutMixingLevels(bufferOuters, true)
  self.ConnectOutersWithoutMixingLevels(localOuters, false)

  if unusedOutersExist(bufferOuters) then
    self.ConnectOutersWhileMixingLevels(bufferOuters)
  end
  if unusedOutersExist(localOuters) then
    self.ConnectOutersWhileMixingLevels(localOuters)
  end

  if unusedOutersExist(bufferOuters) and unusedOutersExist(localOuters) then
    self.ConnectOuters(bufferOuters, localOuters)
  end

  if unusedOutersExist(bufferOuters) or unusedOutersExist(localOuters) then
    -- if this happens - we cannot join anything and we have to fail the graph making, because it's not physically possible
    -- this means an error occurred in LML, because we do have an odd number of outers, and an odd number of players
  end

  -- TODO: create the full graph as it should now look (copy current + add edges + zip nodes)

  -- to be added at the very end!!!
  -- self[zone.id + idShift] = Node.New(zCopy, zone.id + idShift)

end


--- Generates MLML based on initialized lml interface.
-- THIS FUNCTION WILL BE REMOVED AFTER IMPLEMENTING NEW VERSION
-- MLML objects have to be initialized before calling Generate.
-- @param PLAYERS_NUM Constant containing number of players for the MLML graph
function MLML:OldGenerate(PLAYERS_NUM)
  local lmlSize = #self.lml
  self.playerData = {}
  for playerId = 1, PLAYERS_NUM do
    local singleData = {}
    singleData.nodes = {}
    singleData.addedEdges = {}
    self.playerData[playerId] = singleData
  end

  for playerId = 1, PLAYERS_NUM do
    local shift = lmlSize * (playerId - 1)
    for _,zone in ipairs(self.lml) do
      local zCopy = {}
      for k,v in pairs(zone) do
        zCopy[k] = v
      end
      zCopy.player = playerId
      local edges = {}
      for _,k in pairs(zone.edges) do
        if edges[k + shift] then
          edges[k + shift] = edges[k + shift] + 1
        else
          edges[k + shift] = 1
        end
      end
      zCopy.edges = edges
      self[zone.id + shift] = Node.New(zCopy, zone.id + shift)
--      self.playerData[playerId].nodes[#self.playerData[playerid].nodes + 1] = zone.id + shift
    end
  end

  local bEdges = {}
  local lEdges = {}
  for _,zone in ipairs(self.lml) do
    for _,outLevel in ipairs(zone.outer) do
      if zone.type == "LOCAL" then
        if not lEdges[outLevel] then
          lEdges[outLevel] = {}
        end
        lEdges[outLevel][#lEdges[outLevel] + 1] = zone.id
      else
        if not bEdges[outLevel] then
          bEdges[outLevel] = {}
        end
        bEdges[outLevel][#bEdges[outLevel] + 1] = zone.id
      end
    end
  end

  local bufferEdges = {}
  local localEdges = {}
  for level,zones in pairs(bEdges) do
    bufferEdges[#bufferEdges + 1] = {level, zones}
  end
  for level,zones in pairs(lEdges) do
    localEdges[#localEdges + 1] = {level, zones}
  end

  local createEdges = function (levelZones, pConn)
    -- This is the first version, should be done differently to assure automorphism of graph.
    local zonePairs = {}
    local newEdges = {}
    local level = levelZones[1]
    local zones = levelZones[2]
    zonePairs[level] = {}
    local levelPairs = zonePairs[level]
    for _,zoneId in ipairs(zones) do
      for playerId=1,PLAYERS_NUM do
        levelPairs[#levelPairs + 1] = {playerId, lmlSize * (playerId - 1) + zoneId, false}
      end
    end
    for fIndex,fPair in ipairs(levelPairs) do
      local fPlayerId = fPair[1]
      local fZoneId = fPair[2]
      if fPair[3] == false then
        local sIndex
        for sIndex = fIndex + 1, #levelPairs do
          local sPair = levelPairs[sIndex]
          local sPlayerId = sPair[1]
          local sZoneId = sPair[2]
          if sPair[3] == false and fPlayerId ~= sPlayerId then
            if not pConn[fPlayerId][sPlayerId] then
              for nPlayerId,_ in pairs(pConn[fPlayerId]) do
                pConn[sPlayerId][nPlayerId] = true
              end
              for nPlayerId,_ in pairs(pConn[sPlayerId]) do
                pConn[fPlayerId][nPlayerId] = true
              end
              fPair[3] = true
              sPair[3] = true
              newEdges[#newEdges + 1] = {level, fZoneId, sZoneId}
              break
            else
              local laterConn = false
              for lIndex = sIndex + 1, #levelPairs do
                local lPlayerId = levelPairs[lIndex][1]
                if levelPairs[lIndex][3] == false and sPlayerId ~= lPlayerId and not pConn[lPlayerId][sPlayerId] then
                  laterConn = true
                  break
                end
              end
              if not laterConn then
                fPair[3] = true
                sPair[3] = true
                newEdges[#newEdges + 1] = {level, fZoneId, sZoneId}
                break
              end
            end
          end
        end
      end
    end
    return newEdges
  end

  local pConn = {}
  for pIndex = 1, PLAYERS_NUM do
    pConn[#pConn + 1] = {}
    pConn[pIndex][pIndex] = true
  end

  local newEdges = {}
  for i=#bufferEdges, 1, -1 do
    local edges = createEdges(bufferEdges[i], pConn)
    for _,edge in ipairs(edges) do
      newEdges[#newEdges + 1] = edge
    end
  end

  for i=#localEdges, 1, -1 do
    local edges = createEdges(localEdges[i], pConn)
    for _,edge in ipairs(edges) do
      newEdges[#newEdges + 1] = edge
    end
  end

  local addEdge = function(lId, rId)
    local lEdges = self[lId].edges
    if lEdges[rId] then
      lEdges[rId] = lEdges[rId] + 1
    else
      lEdges[rId] = 1
    end
    local rEdges = self[rId].edges
    if rEdges[lId] then
      rEdges[lId] = rEdges[lId] + 1
    else
      rEdges[lId] = 1
    end
  end

  for _,edge in ipairs(newEdges) do
    addEdge(edge[2], edge[3])
  end

  -- from this point on - should work for later version of connecting vertices.
  -- should not have to be changed.

  local newEdgeGraph = {}
  for _,edge in ipairs(newEdges) do
    if not newEdgeGraph[edge[2]] then
      newEdgeGraph[edge[2]] = {}
    end
    if not newEdgeGraph[edge[3]] then
      newEdgeGraph[edge[3]] = {}
    end
    newEdgeGraph[edge[2]][edge[3]] = true
    newEdgeGraph[edge[3]][edge[2]] = true
  end

  local zipTo = {}
  local processed = {}
  for vertex,_ in pairs(newEdgeGraph) do
    zipTo[vertex] = vertex
    processed[vertex] = false
  end

  -- finds all Buffer vertices that are connected exclusively with their own copies
  for baseVertex,_ in pairs(newEdgeGraph) do
    if not processed[baseVertex] and self[baseVertex].type == "BUFFER" then
      local reached = {}
      local path = {baseVertex}
      local stopPath = false
      while #path > 0 and stopPath == false do
        local vertex = path[#path]
        path[#path] = nil
        if self[vertex].baseid ~= self[baseVertex].baseid then
          stopPath = true
          break
        else
          if not reached[vertex] then
            reached[vertex] = true
            local edges = newEdgeGraph[vertex]
            for connection,_ in pairs(edges) do
              if not reached[connection] then
                path[#path + 1] = connection
              end
            end
          end
        end
      end
      for vertex,_ in pairs(reached) do
        processed[vertex] = true
      end
      if stopPath == false then
        for vertex,_ in pairs(reached) do
          zipTo[vertex] = baseVertex
        end
      end
    end
  end

  local toRemove = {}
  for vertex,target in pairs(zipTo) do
    local node = self[vertex]
    local targetNode = self[target]
    if node.type == "BUFFER" and vertex ~= target then
      print('merging zone '..vertex..' to zone '..target)
      toRemove[vertex] = true

      -- NOTE: It's not so obvious.
      if targetNode.weight < 3 * node.weight then
        targetNode.weight = targetNode.weight + node.weight
      end
      for k,n in pairs(node.edges) do
        if k ~= target then
          if targetNode.edges[k] then
            targetNode.edges[k] = targetNode.edges[k] + n
          else
            targetNode.edges[k] = n
          end
        end
      end
      for p,_ in pairs(node.players) do
        targetNode.players[p] = true
      end

      for k,n in pairs(node.edges) do
        local kEdges = self[k].edges
        if kEdges[node.id] then
          kEdges[node.id] = kEdges[node.id] - n
          if kEdges[node.id] <= 0 then
            kEdges[node.id] = nil
          end
        end
        if k ~= target then
          if kEdges[target] then
            kEdges[target] = kEdges[target] + n
          else
            kEdges[target] = n
          end
        end
      end
    end
  end

  for i,_ in pairs(toRemove) do
    self[i] = nil
  end

  --[=====[
  local toZip = {}
  for _,edge in ipairs(newEdges) do
    if self[edge[2]].type == "BUFFER" and self[edge[3]].type == "BUFFER" then
      toZip[self[edge[2]].baseid] = true
      toZip[self[edge[3]].baseid] = true
    end
  end

  for _,edge in ipairs(newEdges) do
    local fType = self[edge[2]].type
    local sType = self[edge[3]].type
    local fBaseId = self[edge[2]].baseid
    local sBaseId = self[edge[3]].baseid
    if fType == "BUFFER" and toZip[fBaseId] then
      if sType == "LOCAL" or fBaseId ~= sBaseId then
        toZip[fBaseId] = false
      end
    end

    if sType == "BUFFER" and toZip[sBaseId] then
      if fType == "LOCAL" or sBaseId ~= fBaseId then
        toZip[sBaseId] = false
      end
    end
  end
  --]=====]

  self.playerData = nil
  self.lml = nil
end


--- Creates serializable MLML object interface table that can be used to generate MultiLML
-- @return Table with properly formated MLML interface
function MLML:Interface()
  local interface = {}
  for _,playerNodes in pairs(self.localGraphs) do
    for _,node in pairs(playerNodes) do
      local nodeInterface = node:Interface()
      if self.newEdges[node.id] then
        for _,newEdge in pairs(self.newEdges[node.id]) do
          table.insert(nodeInterface.edges, newEdge)
        end
      end
      table.insert(interface, nodeInterface)
    end
  end
  return interface
end


function MLML:PrintToMDS(filename)
  local file = io.open(filename, "w")
  local count = 0
  for _,playerNodes in pairs(self.localGraphs) do
    for _,_ in pairs(playerNodes) do
      count = count + 1
    end
  end
  file:write(count, "\n")

  for _,playerNodes in pairs(self.localGraphs) do
    for _,node in pairs(playerNodes) do
      local line = ''..node.id..' '..node.weight
      for k,_ in pairs(node.edges) do
        line = line..' '..k
      end
      if self.newEdges[node.id] then
        for _,newEdge in pairs(self.newEdges[node.id]) do
          line = line..' '..newEdge
        end
      end
      file:write(line, "\n")
    end
  end
  file:close()
end


return MLML


--[======[
-- old version

--- Generates MLML based on initialized lml interface.
-- MLML objects have to be initialized before calling Generate.
-- @param PLAYERS_NUM Constant containing number of players for the MLML graph
function MLML:Generate(PLAYERS_NUM)
  for _,zone in ipairs(self.lml) do
    print (zone.id, zone.edges[1], zone.edges[2], zone.type)
    self[zone.id] = Node.New(zone, zone.id)
  end

  local lmlSize = #self.lml
  print ("size "..lmlSize)
  for playerId = 2, PLAYERS_NUM do
    for i,zone in ipairs(self.lml) do
      if zone.type == "LOCAL" then
        local nextId = zone.id + lmlSize * (playerId - 1)
        local zCopy = {}
        for k,v in pairs(zone) do
          zCopy[k] = v
        end
        zCopy.player = playerId
        local edges = {}
        for _,k in ipairs(zone.edges) do
          if self.lml[k].type == "BUFFER" then
            print("adding edge to buffer from "..(nextId).." to "..k)
            edges[#edges + 1] = k
            self[k].players[playerId] = true
            self[k].edges[nextId] = true
          else
            print("adding edge to local from "..(nextId).." to "..(k + lmlSize * (playerId - 1)))
            edges[#edges + 1] = k + lmlSize * (playerId - 1)
          end
        end
        zCopy.edges = edges
        self[#self + 1] = Node.New(zCopy, nextId)
      end
    end
  end
  self.lml = nil
end

--]======]
