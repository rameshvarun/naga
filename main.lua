local naga = require "." -- Load naga.
local vec, color = naga.vec, naga.color -- Shortcuts.

function naga.tick(args)
  color(0, 0, 0.1):clear() -- Background color of game
  naga.music("assets/music.ogg", 0.5) -- Looping background music.

  -- Create 50 randomly positioned stars.
  local stars = args.state:init("stars", {})
  while #stars < 50 do
    table.insert(stars, {
      pos = vec(love.math.random() * 1280, love.math.random() * 720),
      depth = love.math.random()
    })
  end

  -- Move stars with wraparound and draw.
  for _, star in ipairs(stars) do
    star.pos.y = (star.pos.y + star.depth) % (720 + 24)
    naga.sprite("assets/star.png", star.pos, {
      origin = vec(0.5, 1), color=color(1, 1, 1, star.depth)})
  end

  -- Lasers that move upwards when fired.
  local lasers = args.state:init("lasers", {})
  for _, laser in ipairs(lasers) do
    laser:translate(0, -20)
    naga.sprite("assets/laser.png", laser, {origin = vec(0.5, 0.5)})
  end

  -- Create a ship that is moved with the arrow keys.
  local ship = args.state:init("ship", vec(1280 / 2, 720 / 2))
  ship:translate(args.keys.arrows * 10) -- Move ship by arrow keys vector
  ship:clamp(vec(0, 0), vec(1280, 720)) -- Stay on screen

  -- Draw the ship.
  naga.sprite("assets/ship.png", ship, {origin = vec(0.5, 0.5)})

  -- Shoot lasers with space.
  if args.keys.pressed.space then
    table.insert(lasers, ship:translated(0, -40))
    naga.sound("assets/laser.ogg")
  end
end
