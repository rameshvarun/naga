local tilemap = {}

function tilemap.parse (str)
  local map = {}
  for line in str:gmatch("[^\r\n]+") do
    local row = {}
    for i=1, #line do
      table.insert(row, tonumber(line:sub(i, i)))
    end
    table.insert(map, row)
  end
  return map
end

function tilemap.draw(map, tilesize, tiles)
  for i, row in ipairs(map) do
    for j, block in ipairs(row) do
      local tile = tiles[map[i][j]]
      if tile then
        naga.sprite(tile, naga.vec((j - 1) * tilesize, (i - 1) * tilesize))
      end
    end
  end
end

return tilemap
