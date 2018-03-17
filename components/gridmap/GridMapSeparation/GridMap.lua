
local GridMap = {}
local GridMap_mt = { __index = GridMap, __metatable = "Access restricted." }


--- Creates new GridMap object initialized with given graph data.
-- @param graph_data - Graph data
-- @return New, initialized GridMap with graph data
function GridMap.Initialize(graph_data)
  local obj = {}
  obj.gdat = graph_data
  return setmetatable(obj, GridMap_mt)
end


local getGridNeighbors = function(x, y)
  return {
    {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1},
    {x - 1, y    },             {x + 1, y    },
    {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}
  }
end


local getGridNeighbors2 = function(x, y)
  return {
    {x - 2, y - 2}, {x - 1, y - 2}, {x, y - 2}, {x + 1, y - 2}, {x + 2, y - 2},
    {x - 2, y - 1}, {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1}, {x + 2, y - 1},
    {x - 2, y    }, {x - 1, y    },             {x + 1, y    }, {x + 2, y    },
    {x - 2, y + 1}, {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}, {x + 2, y + 1},
    {x - 2, y + 2}, {x - 1, y + 2}, {x, y + 2}, {x + 1, y + 2}, {x + 2, y + 2}
  }
end


--- Generates GridMap based on initialized graph data.
-- GridMap objects have to be initialized before calling Generate.
-- @param dimensions - Set of constants containing dimensions (gW, gH, sW, sH) of the map. (gW and gH should be multiples of sW and sH respectively)
-- @param forceFill - forces filling the map even if causes uneven sizes
function GridMap:Generate(dimensions, forceFill)
  self.gW = dimensions.gW
  self.gH = dimensions.gH
  self.sW = dimensions.sW
  self.sH = dimensions.sH

  self.sectors = {}
  for hCount = self.sH, self.gH, self.sH do
    local row = {}
    for wCount = self.sW, self.gW, self.sW do
      row[#row + 1] = -1
    end
    self.sectors[#self.sectors + 1] = row
  end

  ------------------------------------------------------------------------
  -- to add later - rescale self.gdat positions to fit given dimensions --
  -- reset sector data in map [id] = (x, y, neighbors) -------------------
  ------------------------------------------------------------------------

  self.sectorMaps = {}
  for id, _ in pairs(self.gdat) do
    self.sectorMaps[id] = {}
  end

  local placeSector = function(id, sector)
      self.sectorMaps[id][{sector.x, sector.y}] = true
      self.sectors[sector.y][sector.x] = id
      if self.neighbors[id] == nil then
        self.neighbors[id] = {}
      end
      for _,nId in pairs(sector.neighbors) do
        -- now you can be a neighbor many times
        self.neighbors[id][nId] = (self.neighbors[id][nId] or 0) + 1
        --self.neighbors[id][nId] = 1
      end
  end

  local failedToPlace = {}

  self.neighbors = {}
  for id, sector in pairs(self.gdat) do
    if self.sectors[sector.y][sector.x] ~= -1 then
      print('Attempted to assign sector id ' .. id .. ' to non-empty sector. Fix attempt will be made.')
      failedToPlace[#failedToPlace + 1] = id
    else
      placeSector(id, sector)
    end
  end

  for _,id in pairs(failedToPlace) do
    local sector = self.gdat[id]
    if self.sectors[sector.y][sector.x] == -1 then
      print('Fix attempt shows that no id was set in this sector. Assigning id '..id)
      placeSector(id, sector)
    else
      local neigh = getGridNeighbors(sector.x, sector.y)
      local newPos = nil
      for _, newXY in pairs(neigh) do
        if self.sectors[newXY[2]][newXY[1]] == -1 then
          newPos = newXY
          break
        end
      end
      if newPos then
        print('Fix attempt found available sector. Assigning id '..id..' to sector '..newPos[1]..'/'..newPos[2]..'.')
        self.gdat[id].x = newPos[1]
        self.gdat[id].y = newPos[2]
        placeSector(id, self.gdat[id])
      else
        print('Fix attempt did not find available sector for id '..id..'. Errors to be expected.')
      end
    end
  end

  self.joinAt = {}

  -- we now have all data required - which sector has which starting id.
  -- which sectors are neighbors

  self.connected = {}
  for id, _ in pairs(self.gdat) do
    self.connected[id] = {}
  end
  for id, sector in pairs(self.gdat) do
    for _,nId in pairs(sector.neighbors) do
      if not self.connected[id][nId] then
        if self:TryConnectBresenham(id, nId) == true then
          print('path connected using bresenham for '..id..', '..nId)
        else
          print('failed connect bresenham for '..id..', '..nId)
          if self:TryConnectBFS(id, nId) == true then
            print('path connected using BFS for '..id..', '..nId)
          else
            print('FAILED connect bfs for '..id..', '..nId)
            -- to be fixed by sending message about teleport
          end
        end
        self.connected[id][nId] = true
        self.connected[nId][id] = true
      end
    end
  end

  local sectorSizes = {}
  for id, sectors in pairs(self.sectorMaps) do
    local sectorSize = sectorSizes[id] or 0
    for _, _ in pairs(sectors) do
      sectorSize = sectorSize + 1
    end
    sectorSizes[id] = sectorSize
  end

  local filledSectors = {}
  for y = 1, #self.sectors do
    for x = 1, #self.sectors[y] do
      if self.sectors[y][x] ~= -1 then
        filledSectors[#filledSectors + 1] = {x,y}
      end
    end
  end

  local zoneRatios = {}
  for id, _ in pairs(self.sectorMaps) do
    zoneRatios[#zoneRatios + 1] = {id, sectorSizes[id], self.gdat[id].size}
  end

  local getProportion = function(ratio)
    return ratio[2] / ratio[3]
  end

  local compareRatios = function(ratio1, ratio2)
    local proportion1 = getProportion(ratio1)
    local proportion2 = getProportion(ratio2)
    return proportion1 > proportion2
      or (proportion1 == proportion2 and ratio1[1] > ratio2[1])
  end

  table.sort(zoneRatios, compareRatios)

  local largestProportion = getProportion(zoneRatios[#zoneRatios])
  local acceptableRatioToBest = 1.5

  local getSectorNeighbors = function(x, y)
    return {
                {x, y - 1},
      {x - 1, y},           {x + 1, y},
                {x, y + 1}
    }
  end

  local addNeighborSector = function(id, xy)
    local goodNeigh = nil
    for _, neigh in pairs(getSectorNeighbors(xy[1], xy[2])) do
      if neigh[1] >= 1 and neigh[1] <= #self.sectors[1] and neigh[2] >= 1 and neigh[2] <= #self.sectors
        and self.sectors[neigh[2]][neigh[1]] == -1 then
          goodNeigh = neigh
          break
      end
    end
    if goodNeigh then
      self.sectorMaps[id][{goodNeigh[1], goodNeigh[2]}] = true
      self.sectors[goodNeigh[2]][goodNeigh[1]] = id
    end
    return goodNeigh
  end

  for _, zoneRatio in pairs(zoneRatios) do
    local proportion = getProportion(zoneRatio)
    while proportion * acceptableRatioToBest < largestProportion do
      local addedSector = nil
      for sector, _ in pairs(self.sectorMaps[id]) do
        if addNeighborSector(zoneRatio[1], sector) then
          break
        end
      end
      if addedSector then
        proportion = getProportion(zoneRatio)
      else
        print('Could not grow zone '..zoneRatio[1]..' anymore, might be smaller than expected.')
        break
      end
    end
  end

  if forceFill then
    local canBeAdded = true
    print('Force filling the map.')
    while canBeAdded do
      canBeAdded = false
      for _, xy in pairs(filledSectors) do
        local addedSector = addNeighborSector(self.sectors[xy[2]][xy[1]], xy)
        if addedSector then
          filledSectors[#filledSectors + 1] = addedSector
          canBeAdded = true
        end
      end
    end
  end
end


--- Connects two points using bresenham.
-- Can only be called from inside the Generate function.
function GridMap:TryConnectBresenham(id1, id2)
  local path = self:GetBresenhamPath(id1, id2)

  local getId = function(id)
    local xy = path[id]
    return self.sectors[xy[2]][xy[1]]
  end

  local bestStart
  local bestEnd
  local bestDist = #path
  local lastSwitch = 1

  for currentPos = 2, #path do
    local currentId = getId(currentPos)
    if currentId ~= -1 then
      local lastSwitchId = getId(lastSwitch)
      if currentId ~= id1 and currentId ~= id2 then
        lastSwitch = currentPos
      else
        if lastSwitchId == currentId or
            (lastSwitchId ~= id1 and lastSwitchId ~= id2) then
          lastSwitch = currentPos
        else
          if currentPos - lastSwitch < bestDist then
            bestStart = lastSwitch
            bestEnd = currentPos
            bestDist = currentPos - lastSwitch
          end
        end
      end
    end
  end

  return self:FillPath(path, bestStart, bestEnd)

end


--- Checks if two sectors on the grid can be connected using bresenham.
-- Can only be called from inside the Generate function.
function GridMap:GetBresenhamPath(id1, id2)
  local s1 = self.gdat[id1]
  local s2 = self.gdat[id2]
  local dX = s2.x - s1.x
  local dY = s2.y - s1.y

  local path = {}
  if dX == 0 then
    if dY == 0 then
      print('sectors were in the same spot ('..s1.x..','..s1.y..') -> ('..s2.x..','..s2.y..').')

      return path
    end

    print('sectors only had vertical change ('..s1.x..','..s1.y..') -> ('..s2.x..','..s2.y..').')

    for newY = s1.y, s2.y, (dY > 0 and 1 or -1) do
      path[#path + 1] = {s1.x, newY}
    end

    return path
  elseif dY == 0 then
    print('sectors only had horizontal change ('..s1.x..','..s1.y..') -> ('..s2.x..','..s2.y..').')

    for newX = s1.x, s2.x, (dX > 0 and 1 or -1) do
      path[#path + 1] = {newX, s1.y}
    end

    return path
  end
  -- if we hit one of the simple solutions, we will not reach this point

  local x1 = s1.x
  local y1 = s1.y
  -- modify x1,x2 for symmetry
  if dX > 0 then
    x1 = x1 + 0.5
  else
    x1 = x1 - 0.5
  end

  if dY > 0 then
    y1 = y1 + 0.5
  else
    y1 = y1 - 0.5
  end


  local maxDiff = math.max(math.abs(dX), math.abs(dY))
  local xSteps = math.abs(dX) > math.abs(dY)
  dX = dX / maxDiff
  dY = dY / maxDiff

  -- add line points to path
  path[#path + 1] = {s1.x, s1.y}
  local xRound = dX > 0 and math.floor or math.ceil
  local yRound = dY > 0 and math.floor or math.ceil
  local nX = x1
  local nY = y1

  for i = 1, maxDiff do
    print('check loop iteration')
    local nextX = nX + dX
    local nextY = nY + dY

    if xSteps then
      -- xSteps (ignoring cases when nextX != nX)
      if yRound(nextY) ~= yRound(nY) then
        local midY = (nextY + nY) / 2
        if yRound(midY) ~= yRound(nY) then
          path[#path + 1] = {xRound(nX), yRound(midY)}
        else
          path[#path + 1] = {xRound(nextX), yRound(nY)}
        end
      end
      path[#path + 1] = {xRound(nextX), yRound(nextY)}
    else
      -- ySteps (ignoring cases when nextY != nY)
      if xRound(nextX) ~= xRound(nX) then
        local midX = (nextX + nX) / 2
        if xRound(midX) ~= xRound(nX) then
          path[#path + 1] = {xRound(midX), yRound(nY)}
        else
          path[#path + 1] = {xRound(nX), yRound(nextY)}
        end
      end
      path[#path + 1] = {xRound(nextX), yRound(nextY)}
    end

    print('checked '..xRound(nX)..' '..yRound(nY))
    nX = nextX
    nY = nextY
  end

  return path
end


--- Tries to connect two points using BFS, returns true on success, false on failure.
-- Can only be called from inside the Generate function.
function GridMap:TryConnectBFS(id1, id2)
  local previous = {}
  for y = 1, #self.sectors do
    previous[#previous + 1] = {}
  end

  local toCheck = {}
  local cFront = 1
  local cBack = 1

  local popFront = function()
    if cFront >= cBack then
      return nil
    end
    local xyDist = toCheck[cFront]
    cFront = cFront + 1
    return xyDist
  end

  local pushBack = function(xyDist)
    if previous[xyDist[1][2]][xyDist[1][1]] == nil then
      toCheck[cBack] = xyDist
      cBack = cBack + 1
    end
  end

  local checkNeigh = function(previousxy, neigh)
    local neighxy = neigh[1]
    local neighX = neighxy[1]
    local neighY = neighxy[2]
    if neighX >= 1 and neighX <= #self.sectors[1] and neighY >= 1 and neighY <= #self.sectors then
      local neighId = self.sectors[neighY][neighX]
      if neighId == id2 then
        previous[neighxy[2]][neighxy[1]] = previousxy
        return neigh
      elseif neighId == -1 and previous[neighxy[2]][neighxy[1]] == nil then
        pushBack(neigh)
        previous[neighxy[2]][neighxy[1]] = previousxy
      end
    end
    return nil
  end

  for xy, _ in pairs(self.sectorMaps[id1]) do
    pushBack({xy, 1})
    previous[xy[2]][xy[1]] = xy
  end

  local foundEnd = nil
  while cFront < cBack do
    local xy = popFront()
    if xy == nil then
      break
    end
    local x = xy[1][1]
    local y = xy[1][2]
    local id = self.sectors[y][x]
    if id == -1 or id == id1 then
      local neigh1 = {{x, y - 1}, xy[2] + 1}
      local neigh2 = {{x + 1, y}, xy[2] + 1}
      local neigh3 = {{x, y + 1}, xy[2] + 1}
      local neigh4 = {{x - 1, y}, xy[2] + 1}

      foundEnd = checkNeigh(xy, neigh1)
      if foundEnd ~= nil then
        break
      end
      foundEnd = checkNeigh(xy, neigh2)
      if foundEnd ~= nil then
        break
      end
      foundEnd = checkNeigh(xy, neigh3)
      if foundEnd ~= nil then
        break
      end
      foundEnd = checkNeigh(xy, neigh4)
      if foundEnd ~= nil then
        break
      end
    end

  end

  if foundEnd == nil then
    return false
  end

  local path = {}
  local runBack = foundEnd
  local dist = foundEnd[2]
  while dist >= 1 do
    path[dist] = runBack[1]
    dist = dist - 1
    runBack = previous[runBack[1][2]][runBack[1][1]]
  end

  return self:FillPath(path, 1, #path)

end


--- Fills in the id's of sectors along the given path. It is assumed that both sides of the path have different id's, and the entire middle has only -1
-- Can only be called from inside functions which are connecting sectors.
function GridMap:FillPath(path, fragStart, fragEnd)
  if fragStart == nil or fragEnd == nil then
    return false
  end

  local startxy = path[fragStart]
  local startId = self.sectors[startxy[2]][startxy[1]]
  local endxy = path[fragEnd]
  local endId = self.sectors[endxy[2]][endxy[1]]

  local joined = false

  for pos = fragStart, fragEnd do
    local xy = path[pos]
    if self.sectors[xy[2]][xy[1]] == -1 then
      local previousId = (pos - 1 <= (fragStart + fragEnd) / 2 and startId or endId)
      local currentId  = (pos     <= (fragStart + fragEnd) / 2 and startId or endId)

      if previousId ~= currentId then
        joined = true
        table.insert(self.joinAt, {startId, endId, path[pos - 1], xy})
      end

      self.sectors[xy[2]][xy[1]] = currentId
      self.sectorMaps[currentId][xy] = true
    end
  end

  if not joined then
    table.insert(self.joinAt, {startId, endId, path[fragEnd - 1], path[fragEnd]})
  end

  return true
end


--- Divides the grid into areas depending on nearest site for each grid square.
-- GridMap objects have to have Generate function run before calling RunVoronoi.
-- @param pointsPerSector - how many points are generated in each sector
-- @param sectorLenience - how much room in the sectors is available to generate points (between 0 and 100) value of 70 should work fine
-- @param seedValue - randomseed for lua math.random (if seedValue is null, will use currently set seed)
function GridMap:RunVoronoi(pointsPerSector, sectorLenience, seedValue)
  -- first take all sectors, generate random points inside (with buffer from edges)

  if seedValue ~= nil then
    math.randomseed(seedValue)
  end

  local adjustValue = function(value)
    local multiplier = sectorLenience / 100
    local newValue = value * multiplier
    return newValue + ((1.0 - multiplier) / 2)
  end

  local sectorPoints = {}
  for y = 1, #self.sectors do
    local row = {}
    for x = 1, #self.sectors[y] do
      local xyPoints = {}
      for p = 1, pointsPerSector do
        local pointX = (x - 1 + adjustValue(math.random())) * self.sW
        local pointY = (y - 1 + adjustValue(math.random())) * self.sH

        xyPoints[#xyPoints + 1] = {pointX, pointY, self.sectors[y][x]}
      end
      row[#row + 1] = xyPoints
    end
    sectorPoints[#sectorPoints + 1] = row
  end

  self.grid = {}
  for y = 1, self.gH do
    local row = {}
    for x = 1, self.gW do
      row[#row + 1] = {id = -1, dist = self.gH * self.gW, sector = {-1, -1}}
    end
    self.grid[#self.grid + 1] = row
  end

  local areaSizes = {}

  for y = 1, self.gH do
    local thisY = y - 0.5
    local sectorY = math.floor((y - 1) / self.sH) + 1
    for x = 1, self.gW do
      local thisX = x - 0.5
      local sectorX = math.floor((x - 1) / self.sW) + 1
      local nearestSectorsPos = self:GetNearestSectors(sectorX, sectorY)
      local bestId = -1
      local bestDist = self.gH + self.gW
      local bestSector = {-1, -1}
      for _,xy in pairs(nearestSectorsPos) do
        for _,sPoint in pairs(sectorPoints[xy[2]][xy[1]]) do
          local dX = thisX - sPoint[1]
          local dY = thisY - sPoint[2]
          local thisDist = math.sqrt(dX * dX + dY * dY)
          if thisDist < bestDist then
            bestId = sPoint[3]
            bestDist = thisDist
            bestSector = xy
          end
        end
      end
      self.grid[y][x].id = bestId
      self.grid[y][x].dist = bestDist
      self.grid[y][x].sector = bestSector

      if areaSizes[bestId] == nil then
        areaSizes[bestId] = 0
      end
      areaSizes[bestId] = areaSizes[bestId] + 1
    end
  end

  local isMySquareWorse = function(myX, myY, otherX, otherY)
    if otherX < 1 or otherX > self.gW or otherY < 1 or otherY > self.gH then
      return false
    end

    local myGridSquare = self.grid[myY][myX]
    local otherGridSquare = self.grid[otherY][otherX]
    if otherGridSquare.id < 0 or myGridSquare.id == otherGridSquare.id then
      return false
    end
    if myGridSquare.dist > otherGridSquare.dist then
      return true
    end
    return myGridSquare.dist == otherGridSquare.dist and areaSizes[myGridSquare.id] < areaSizes[otherGridSquare.id]
  end

  local closestInside = function (zoneId, xy)
    local closest = {-1, -1}
    local distance = 1e10

    local x1 = xy[1]
    local y1 = xy[2]

    for y2 = 3, self.gH - 2 do
      for x2 = 3, self.gW - 2 do
        if self.grid[y2][x2].id == zoneId then
          local isInside = true

          for _, xy in pairs(getGridNeighbors2(x2, y2)) do
            if self.grid[xy[2]][xy[1]].id ~= zoneId then
              isInside = false
              break
            end
          end

          if isInside then
            local d = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
            if d < distance then
              closest = {x2, y2}
              distance = d
            end
          end
        end
      end
    end

    return closest[1], closest[2]
  end

  for _, join in ipairs(self.joinAt) do
    local idA, idB, xyA, xyB = table.unpack(join)
    local connected = {-1, -1}

    for y = 3, self.gH - 2 do
      for x = 3, self.gW - 2 do
        if self.grid[y][x].id == idA and
           self.grid[y][x].sector[1] == xyA[1] and
           self.grid[y][x].sector[2] == xyA[2]
        then
          local isAnyB
          local isEveryAorBorNeutral = true

          for i, xy in pairs(getGridNeighbors(x, y)) do
            local cell = self.grid[xy[2]][xy[1]]
            local isAxis = i == 2 or i == 4 or i == 5 or i == 7

            if isAxis and cell.sector[1] == xyB[1] and cell.sector[2] == xyB[2] then
              if cell.id ~= idA and cell.id ~= idB and cell.id ~= -1 then
                isEveryAorBorNeutral = false
                break
              end

              if cell.id == idB then
                isAnyB = xy
              end
            end
          end

          if isAnyB ~= nil and isEveryAorBorNeutral then
            -- Mark these as super white but inside of the zone.
            local ax, ay = closestInside(idA, {x, y})
            local bx, by = closestInside(idB, isAnyB)

            if ax ~= -1 and ay ~= -1 and bx ~= -1 and by ~= -1 then
              -- Point of interest.
              self.grid[ay][ax].id = -3
              self.grid[by][bx].id = -3

              table.insert(join, {ax, ay})
              table.insert(join, {bx, by})

              -- Super white.
              self.grid[y        ][x        ].id = -2
              self.grid[isAnyB[2]][isAnyB[1]].id = -2

              -- Note.
              connected = {x, y, isAnyB[1], isAnyB[2]}
              break
            end
          end
        end
      end

      if connected[1] ~= -1 and connected[2] ~= -1 then
        break
      end
    end

    if connected[1] ~= -1 and connected[2] ~= -1 then
      print(table.concat({
        'Zone', idA, 'connected with', idB, 'at',
        connected[1] .. 'x' .. connected[2], '-',
        connected[3] .. 'x' .. connected[4],
      }, ' '))
    else
      print(table.concat({'Zone', idA, 'NOT connected with', idB}, ' '))
      table.insert(join, {-1, -1})
      table.insert(join, {-1, -1})
    end
  end

  self.borders = {}

  for y = 1, self.gH do
    local border = {}
    for x = 1, self.gW do
      local present = false
      if self.grid[y][x].id > 0 then
        for _, xy in pairs(getGridNeighbors(x, y)) do
          if isMySquareWorse(x, y, xy[1], xy[2]) then
            present = true
            break
          end
        end
      end
      table.insert(border, present)
    end
    table.insert(self.borders, border)
  end

  for y = 1, self.gH do
    for x = 1, self.gW do
      self.grid[y][x] = self.grid[y][x].id
    end
  end

end


function GridMap:GetNearestSectors(sectorX, sectorY)
  local nearestSectorsPos = {}
  for newY = sectorY - 1, sectorY + 1 do
    for newX = sectorX - 1, sectorX + 1 do
      if newX >= 1 and newX <= #self.sectors[1] and newY >= 1 and newY <= #self.sectors then
        nearestSectorsPos[#nearestSectorsPos + 1] = {newX, newY}
      end
    end
  end
  return nearestSectorsPos
end


function GridMap:ShowSectors(filename)
  self:ShowMap(filename, self.sectors)
end


function GridMap:ShowGrid(filename)
  self:ShowMap(filename, self.grid)
end


function GridMap:ShowMap(filename, mapData)
  local file = io.open(filename, "w")
  file:write('gW, gH, sW, sH = '..self.gW..' '..self.gH..' '..self.sW..' '..self.sH..' \n')
  file:write('\n/')
  for j = 1, #(mapData[1]) do
    file:write(' '..(j % 10))
  end
  file:write('\n')

  for i = #mapData, 1, -1 do
    local line = ''..(i % 10)
    local row = mapData[i]
    for j = 1, #row do
      line = line..' '..(row[j] == -1 and '#' or row[j])
    end
    file:write(line, "\n")
  end

  --[=[
  for i,row in pairs(mapData) do
    local line = ''..(i % 10)
    for j = 1, #row do
      line = line..' '..(row[j] == -1 and '#' or row[j])
    end
    file:write(line, "\n")
  end
  --]=]
end


--- Creates serializable GridMap object interface table that can be used to generate the map
-- @return Table with properly formatted GridMap interface
function GridMap:Interface()
  local interface = {}
  for i,node in pairs(self) do
    if type(i) == 'number' then
--      interface[#interface + 1] = node:Interface()
    end
  end
  return interface
end


function GridMap:PrintToCA(filename)
  local file = io.open(filename, "w")
  local count = 0
  for _,_ in pairs(self) do
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
end


return GridMap

