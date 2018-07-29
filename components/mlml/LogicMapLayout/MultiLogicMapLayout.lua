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
function MLML.InitialSetup(PLAYERS_NUM)
  
  -- will hold sets of "connected players", will be merge each time player graphs connect
  self.connected = {}
  for playerId = 1, PLAYERS_NUM do
    table.insert(self.connected, {playerId})
  end

  -- will hold abstract representation of connection types
  self.newConnectionTypes = {}

  -- will hold definitions of newly created edges
  self.newEdges = {}

  -- will hold sets of vertices which should be zipped
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


--- Finds buffers which can be merged automatically, removes their outer edges, adds information about merge to be made.
-- Private function to be called only inside Generate function.
function MLML.AutoMergeBuffers()
  local playerCount = #self.localGraphs
  local idShift = #self.lml * (playerId - 1)

  for _,zone in ipairs(self.lml) do
    if zone.type == 'BUFFER' then
      -- to be implemented later, will lighten the load on edge finding.
      -- since we usually expect buffers to be merged
      -- this function can automatically update the graphs so that the buffers are in fact merged
    end
  end
  
end


--- Tries to connect all outer edges fairly, without mixing between levels.
-- Private function to be called only inside Generate function.
function MLML.ConnectOutersWithoutMixingLevels(outers)

  for level,zones in pairs(outers) do
    
  end


  --[==========[
  -- old version of single level code
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
  --]==========]


end


--- Tries to connect all outer edges fairly, while mixing between levels.
-- Private function to be called only inside Generate function.
function MLML.ConnectOutersWhileMixingLevels(outers)
  
end


--- Tries to connect all outer edges fairly, using buffers and locals together.
-- Private function to be called only inside Generate function.
function MLML.ConnectOuters(bufferOuters, localOuters)
  
end


--- Tries to connect all outer edges, failsafe which does not ensure fairness, to be called if no fair method exists.
-- Private function to be called only inside Generate function.
function MLML.BruteConnectOuters(bufferOuters, localOuters)
  
end


--- Generates MLML based on initialized lml interface.
-- MLML objects have to be initialized before calling Generate.
-- @param PLAYERS_NUM Constant containing number of players for the MLML graph
function MLML:NewGenerate(PLAYERS_NUM)

  self.InitialSetup(PLAYERS_NUM)

  if self.lazyBufferEdges then
    self.AutoMergeBuffers()
  end

  -- for the graphs to be fair, whenever we use a buffer outer edge for a player, it should be used for all players.
  -- the same situation applies for using a local outer edge for a player.
  -- this allows us to use only single copy of buffer outers and local outers, but we need to always use these edges for all players.
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

  self.ConnectOutersWithoutMixingLevels(bufferOuters)
  self.ConnectOutersWithoutMixingLevels(localOuters)

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
    self.BruteConnectOuters(bufferOuters, localOuters)
  end

  -- TODO: create the full graph as it should now look (copy current + add edges + zip nodes)

  -- to be added at the very end!!!
  -- self[zone.id + idShift] = Node.New(zCopy, zone.id + idShift)

end


--- Generates MLML based on initialized lml interface.
-- THIS FUNCTION WILL BE REMOVED AFTER IMPLEMENTING NEW VERSION
-- MLML objects have to be initialized before calling Generate.
-- @param PLAYERS_NUM Constant containing number of players for the MLML graph
function MLML:Generate(PLAYERS_NUM)
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
  for i,node in pairs(self) do
    if type(i) == 'number' then
      interface[#interface + 1] = node:Interface()
    end
  end
  return interface
end


function MLML:PrintToMDS(filename)
  local file = io.open(filename, "w")
  local count = 0
  for i,_ in pairs(self) do
    if type(i) == 'number' then
      count = count + 1
    end
  end
  file:write(count, "\n")

  for i,node in pairs(self) do
    if type(i) == 'number' then
      local line = ''..node.id..' '..node.weight
      for k,_ in pairs(node.edges) do
        line = line..' '..k
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
