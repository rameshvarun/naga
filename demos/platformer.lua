local naga = require "."
local vec, tilemap = naga.vec, naga.tilemap

local map = tilemap.parse [[
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
  tilemap.draw(map, 64, {"assets/grass-top.png", "assets/dirt.png", "assets/block.png"})

  -- Draw the character.
  naga.sprite("assets/character.png", vec(100, 7 * 64 + 16), {origin = vec(0.5, 0.5)})
end
