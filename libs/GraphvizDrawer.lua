-- Based on https://github.com/Nymphium/lua-graphviz
-- Check http://www.graphviz.org/pdf/dotguide.pdf in case of incomprehension


local GraphvizDrawer = {} 
local GraphvizDrawer_mt = { __index = GraphvizDrawer, __metatable = "Access resticted." }


--- Creates new GraphvizDrawer handler
-- @return New GraphvizDrawer object
function GraphvizDrawer.New()
  local obj = {nodes={}, edges={}}
  return setmetatable(obj, GraphvizDrawer_mt)
end


--- Creates new graph node
-- @param nodetable Table with node's attributes (keys as in dot node's attributes, values string/int) plus additionally numerical id
-- @return Node's name
function GraphvizDrawer:AddNode(nodetable)
  local name = 'node'..(nodetable.id and nodetable.id or 0)
  local attrs = {}
  for k, v in pairs(nodetable) do
    if k~='id' then
      local needquote = k=='label' or (k=='color' and v:sub(1,1)=='#')
      local needhtml = k=='label' and #v > 0
      if needhtml then v = v:gsub('\\n', '<BR/>') end
      attrs[#attrs+1] = string.format('%s='..((needhtml and '<%s>') or (needquote and '"%s"') or '%s'), k, v) -- use "%s" instead of %q because of the newline problems
    end
  end
  self.nodes[#self.nodes+1] = name..' ['..table.concat(attrs, ',')..'];'
  --print (self.nodes[#self.nodes])
  return name
end


--- Creates new graph edge
-- @param id1 Name of the first edge's end
-- @param id2 Name of the second edge's end
-- @param edgetable Table with edge's attributes (keys as in dot node's attributes, values string/int)
function GraphvizDrawer:AddEdge(id1, id2, edgetable)
  local attrs = {}
  for k, v in pairs(edgetable or {}) do
    if k~='id' then
      local needquote = k=='label' or (k=='color' and v:sub(1,1)=='#')
      attrs[#attrs+1] = string.format('%s='..(needquote and '"%s"' or '%s'), k, v) -- use "%s" instead of %q because of the newline problems
    end
  end
  self.edges[#self.edges+1] = string.format('node%s -> node%s [%s];', id1, id2, table.concat(attrs, ','))
end


--- Draws graph into an image
-- @param filepath Name of the output file (without extension, will be png)
-- @param keepdotsource True if we do not want to remove graph sources in '.dot' format
function GraphvizDrawer:Draw(filepath, keepdotsource)
  local src = 'digraph G \n{\n'..'  edge [arrowhead="none"];\n\n'
  src = src..'  '..table.concat(self.nodes, '\n  ')..'\n\n'
  src = src..'  '..table.concat(self.edges, '\n  ')..'\n'
  src = src..'}' 
  --print (src)
  local file, e = io.open(filepath..'.dot', "w")
  if file==nil then
    error ('Writing to '..filepath..'.dot caused error:'..e)
  end 
  file:write(src)
  file:close()
  local cmd_str = string.format("dot -Tpng %s.dot -o %s.png", filepath, filepath)
	local cmd = io.popen(cmd_str, "r")
  cmd:read('*a')
  cmd:close()
  if not keepdotsource then
    os.remove(filepath..'.dot')
  end
end


return GraphvizDrawer