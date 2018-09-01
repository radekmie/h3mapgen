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
      zCopy.weight = zone.weight or 5
      zCopy.players = { [playerId] = true }

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

      self.localGraphs[playerId][zCopy.id] = zCopy
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
    local rightIndex = leftIndex == #orderTable and 1 or leftIndex + 1

    local leftZoneId = idShift * (orderTable[leftIndex] - 1) + zoneId
    local rightZoneId = idShift * (orderTable[rightIndex] - 1) + zoneId

    self:AddEdge(leftZoneId, rightZoneId)
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

    self:AddEdge(leftZoneId, rightZoneId)
  end

  if #self.connected == self.playersNum // 2 then
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
      local secondConnector = math.random(2, #toBeConnected)

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

    self:AddEdge(leftZoneId, rightZoneId)
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
          self:CreateRing(zones, index)
          zoneCount = zoneCount - 2
        end
      else
        if isBuffers and zoneCount > 1 then
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

        while zoneCount > 1 do
          self:CreateRing(zones, index)
          zoneCount = zoneCount - 2
        end

        if zoneCount == 1 then
          self:CreatePairs(zoneId)
          table.remove(zones, index)
          zoneCount = 0
        end
      end
    end
  end

  for _, zones in pairs(outers) do
    while #zones > 1 do
      self:JoinIntoRing(zones[1], zones[2])

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

    self:JoinIntoRing(zone1, zone2)

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

    self:JoinIntoRing(bufferOuter, localOuter)

    table.remove(bufferOuters[bufferLevel], bufferIndex)
    table.remove(localOuters[localLevel], localIndex)

    bufferIndex, bufferLevel = findAnyOuter(bufferOuters)
    localIndex, localLevel = findAnyOuter(localOuters)
  end

end


--- Finds buffers for which all new edges are exclusively to their copies.
-- Private function to be called only inside Generate function, after joining all possible outer edges.
function MLML:FindBuffersToZip()
  
  local buffers = {}
  local processed = {}
  for _,zone in ipairs(self.lml) do
    if zone.type == "BUFFER" then
      buffers[zone.id] = true
      processed[zone.id] = false
    end
  end

  -- finds all Buffer vertices that are connected exclusively with their own copies
  for zoneId,_ in pairs(buffers) do
    if not processed[zoneId] then
      local zonesToZip = {}
      local bfsFront = {zoneId}
      local failed = false

      while #bfsFront > 0 and not failed do
        local nextZoneId = bfsFront[#bfsFront]
        if not buffers[nextZoneId] or not (zoneId % self.playersNum) == (nextZoneId % self.playersNum) then
          failed = true
          break
        end

        if not processed[nextZoneId] then
          processed[nextZoneId] = true
          table.insert(zonesToZip, nextZoneId)
          table.remove(bfsFront, #bfsFront)

          if self.newEdges[nextZoneId] then
            for _,newEdge in pairs(self.newEdges[nextZoneId]) do
              if not processed[newEdge] then
                table.insert(bfsFront, newEdge)
              end
            end
          end
        end
      end

      if not failed and #zonesToZip > 1 then
        table.insert(self.toZip, zonesToZip)
      end
    end
  end

end


--- Zips all buffer groups from toZip, altering localGraphs structure and newEdges.
-- Private function to be called only inside Generate function, should be after calling FindBuffersToZip.
function MLML:ZipBuffers()

  local findNodeInLocalGraphs = function(zoneId)
    local playerId = math.ceil(zoneId / #self.lml)
    return self.localGraphs[playerId][zoneId]
  end

  for _,zonesToZip in pairs(self.toZip) do
    local printMessage = 'merging zones:'
    for index=2,#zonesToZip do
      printMessage = printMessage..' '..zonesToZip[index]
    end
    print(printMessage..' to zone '..zonesToZip[1])

    self.newEdges[zonesToZip[1]] = {}
    local targetNode = findNodeInLocalGraphs(zonesToZip[1])
    for index=2,#zonesToZip do
      local zoneId = zonesToZip[index]
      local node = findNodeInLocalGraphs(zoneId)
      self.newEdges[zoneId] = {}

      for neighborId,_ in pairs(node.edges) do
        local neighborNode = findNodeInLocalGraphs(neighborId)

        if not targetNode.edges[neighborNode.id] then
          targetNode.edges[neighborNode.id] = 0
        end
        targetNode.edges[neighborNode.id] = targetNode.edges[neighborNode.id] + neighborNode.edges[zoneId]

        if not neighborNode.edges[targetNode.id] then
          neighborNode.edges[targetNode.id] = 0
        end
        neighborNode.edges[targetNode.id] = neighborNode.edges[targetNode.id] + neighborNode.edges[zoneId]

        neighborNode.edges[zoneId] = nil
      end

      self.localGraphs[math.ceil(zoneId / #self.lml)][zoneId] = nil

      targetNode.weight = targetNode.weight + (self.playersNum > 4 and 1 or 2)
      targetNode.players[math.ceil(zoneId / #self.lml)] = true
    end
  end

  self.toZip = {}

end


--- Generates MLML based on initialized lml interface.
-- MLML objects have to be initialized before calling Generate.
-- @param PLAYERS_NUM Constant containing number of players for the MLML graph
function MLML:Generate(PLAYERS_NUM)

  self:InitialSetup(PLAYERS_NUM)

  if self.lazyBufferEdges then
    self:AutoMergeBuffers()
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

  self:ConnectOutersWithoutMixingLevels(bufferOuters, true)
  self:ConnectOutersWithoutMixingLevels(localOuters, false)

  if unusedOutersExist(bufferOuters) then
    self:ConnectOutersWhileMixingLevels(bufferOuters)
  end
  if unusedOutersExist(localOuters) then
    self:ConnectOutersWhileMixingLevels(localOuters)
  end

  if unusedOutersExist(bufferOuters) and unusedOutersExist(localOuters) then
    self:ConnectOuters(bufferOuters, localOuters)
  end

  if unusedOutersExist(bufferOuters) or unusedOutersExist(localOuters) then
    -- if this happens - we cannot join anything and we have to fail the graph making, because it's not physically possible
    -- this means an error occurred in LML, because we do have an odd number of outers, and an odd number of players
  end

  self:FindBuffersToZip()

  self:ZipBuffers()

  for _,playerNodes in pairs(self.localGraphs) do
    for nodeId,node in pairs(playerNodes) do
      local data = {}
      data.id = node.baseId
      data.weight = node.weight
      data.type = node.type
      data.players = node.players

      local edges = node.edges
      if self.newEdges[nodeId] then
        for _,newEdge in pairs(self.newEdges[nodeId]) do
          if not node.edges[newEdge] then
            if not edges[newEdge] then
              edges[newEdge] = 0
            end
            edges[newEdge] = edges[newEdge] + 1
          end
        end
      end
      data.edges = edges

      self[nodeId] = Node.New(data, nodeId)
    end
  end

  -- clean up necessary for later algorithms to work on this mlml object
  self.lml = nil
  self.lazyBufferEdges = nil
  self.playersNum = nil
  self.connected = nil
  self.newEdges = nil
  self.toZip = nil
  self.localGraphs = nil

end


--- Creates serializable MLML object interface table that can be used to generate MultiLML
-- @return Table with properly formated MLML interface
function MLML:Interface()
  local interface = {}
  for _,node in pairs(self) do
    table.insert(interface, node:Interface())
  end
  return interface
end


function MLML:PrintToMDS(filename)
  local file = io.open(filename, "w")
  local mlmlInterface = self:Interface()
  file:write(#mlmlInterface, "\n")

  for _,nodeInterface in ipairs(mlmlInterface) do
    local line = ''..nodeInterface.id..' '..nodeInterface.weight
    for _,v in pairs(nodeInterface.edges) do
      line = line..' '..v
    end
    file:write(line, "\n")
  end
  file:close()
end


return MLML
