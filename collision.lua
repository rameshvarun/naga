local collision = {}

local entities = {}

function collision.reset()
  entities = {}
end

function collision.aabb(center, lower, upper)
  local entity = {
    shape = "aabb",
    center = center,
    lower = lower,
    upper = upper
  }
  table.insert(entities, entity)
  return entity
end

function collision.draw()
  if not naga.debug then return end
  for _, entity in ipairs(entities) do
    naga.color.green:use()

    local pos = entity.center + entity.lower
    local size = entity.upper - entity.lower
    love.graphics.rectangle('line', pos.x, pos.y, size.x, size.y)
  end
end

function collision.tilemap(map, tilesize)
  for i, row in ipairs(map) do
    for j, block in ipairs(row) do
      if map[i][j] > 0 then
        collision.aabb(naga.vec((j - 1) * tilesize, (i - 1) * tilesize),
          naga.vec(0, 0),
          naga.vec(tilesize, tilesize))
      end
    end
  end
end

return collision
