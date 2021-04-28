local naga = require "naga"
local vec = naga.vec

local map = naga.tilemap.parse [[
00000000000000000000
00000000000000000000
00000000000000000000
00000000000000000000
00000000000000000000
00000000000000000000
00000000330000000000
00000000000000000000
11111111111111111111
22222222222222222222
22222222222222222222
22222222222222222222
]]

function naga.tick(args)
  -- Draw the background.
  naga.sprite("assets/background.png", vec(0, -250))
  naga.sprite("assets/background.png", vec(1024, -250))

  -- Draw the level.
  naga.tilemap.draw(map, 64, {"assets/grass-top.png", "assets/dirt.png", "assets/block.png"})

  -- Draw the character.
  local player = args.state:get("player", {
    pos = vec(100, 5 * 64 + 16),
    vel = vec(0, 0)
  })
  naga.sprite("assets/character.png", player.pos, {origin = vec(0.5, 0.5)})

  naga.collision.tilemap(map, 64)
  local playerCol = naga.collision.aabb(player.pos, vec(-20, -10), vec(20, 64/2 + 16))

  -- player.vel:translate(0, 0.2)
  -- player.pos:translate(player.vel)

  -- This draws the collision boxes when debug mode is enabled.
  naga.collision.draw()
end
