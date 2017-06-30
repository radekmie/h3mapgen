local Node = require'LogicMapLayout/MLMLNode'


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


--- Generates MLML based on initialized lml interface.
-- MLML objects have to be initialized before calling Generate.
-- @param PLAYERS_NUM Constant containing number of players for the MLML graph
function MLML:Generate(PLAYERS_NUM)
  local lmlSize = #self.lml
  print ("size "..lmlSize)
  for playerId = 1, PLAYERS_NUM do
    for _,zone in ipairs(self.lml) do
      local shift = lmlSize * (playerId - 1)
      local zCopy = {}
      for k,v in pairs(zone) do
        zCopy[k] = v
      end
      zCopy.player = playerId
      local edges = {}
      for i,k in ipairs(zone.edges) do
        edges[i] = k + shift
      end
      zCopy.edges = edges
      self[zone.id + shift] = Node.New(zCopy, zone.id + shift)
    end
  end
  
  local toRemove = {}
  for i,zone in pairs(self) do
    if type(i) == 'number' and zone.type == "BUFFER" and zone.id ~= zone.baseid then
      print('removing '..i..' with zone id '..zone.id..' and base id '..zone.baseid)
      toRemove[i] = true
      
      self[zone.baseid].weight = self[zone.baseid].weight + 2
      for k,_ in pairs(zone.edges) do
        self[zone.baseid].edges[k] = true
        for p,_ in pairs(zone.players) do
          self[zone.baseid].players[p] = true
        end
      end
      
      for k,_ in pairs(zone.edges) do
        self[k].edges[zone.id] = nil
        self[k].edges[zone.baseid] = true
      end
    end
  end
  
  for i,_ in pairs(toRemove) do
    self[i] = nil
  end
  
  self.lml = nil
end


--- Creates serializable LML object interface table that can be used to generate MultiLML
-- @return Table with properly formated LML interface
function MLML:Interface()
  local interface = {}
  for i, k in pairs(self) do
    interface[#interface + 1] = k:Interface()
  end
  return interface
end


function MLML:PrintToMDS(filename)
  local file = io.open(filename, "w")
  local count = 0
  for _,_ in pairs(self) do
    count = count + 1
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
