local naga = require "naga"

function naga.tick(args)
  love.graphics.clear(0, 0, 0.1)

  -- Initialize the state of our ship. The canvas is normalized
  -- to 1280x720 and letterboxed.
  args.state.ship = args.state.ship or {x = 1280 / 2, y = 720 / 2}

  -- The tick rate is fixed to 60hz, so we don't need delta time.
  local dx = (args.keyboard.held.right and 10 or 0) - (args.keyboard.held.left and 10 or 0)
  local dy = (args.keyboard.held.down and 10 or 0) - (args.keyboard.held.up and 10 or 0)
  args.state.ship.x = args.state.ship.x + dx
  args.state.ship.y = args.state.ship.y + dy

  -- naga.image gets the image and caches it by filename
  love.graphics.draw(naga.image("assets/ship.png"),
    args.state.ship.x, args.state.ship.y, 0, 1, 1, 99 / 2, 75 / 2)
end
