local naga = require "naga"

function naga.tick(args)
  love.graphics.clear(0, 0, 0.1) -- Background color of game
  naga.music("assets/music.ogg", 0.5) -- Looping background music.

  if args.state.stars == nil then
    args.state.stars = {}
    -- Create 50 randomized stars.
    for i=1, 50 do
      table.insert(args.state.stars,
        {x = love.math.random() * 1280,
         y = love.math.random() * 720,
         z = love.math.random()})
    end
  end

  for _, star in ipairs(args.state.stars) do
    -- Move star position with wraparound.
    star.y = star.y + star.z * 1
    if star.y > (720 + 24) then
      star.y = star.y - (720 + 24)
    end

    -- Draw star.
    love.graphics.setColor(1, 1, 1, star.z)
    love.graphics.draw(naga.image("assets/star.png"),
     star.x, star.y, 0, 1, 1, 25 / 2, 24)
    love.graphics.setColor(1, 1, 1, 1)
  end

  -- Update and draw lasers.
  args.state.lasers = args.state.lasers or {}
  for _, bullet in ipairs(args.state.lasers) do
    bullet.y = bullet.y - 20
    love.graphics.draw(naga.image("assets/laser.png"),
     bullet.x, bullet.y, 0, 1, 1, 9 / 2, 54 / 2)
  end

  -- Initialize the state of our ship.
  args.state.ship = args.state.ship or {x = 1280 / 2, y = 720 / 2}

  -- Move ship with arrow keys.
  local dx = (args.keyboard.held.right and 10 or 0) - (args.keyboard.held.left and 10 or 0)
  local dy = (args.keyboard.held.down and 10 or 0) - (args.keyboard.held.up and 10 or 0)
  args.state.ship.x = args.state.ship.x + dx
  args.state.ship.y = args.state.ship.y + dy

  -- Draw the ship.
  love.graphics.draw(naga.image("assets/ship.png"),
    args.state.ship.x, args.state.ship.y, 0, 1, 1, 99 / 2, 75 / 2)

  -- Shoot lasers with space.
  if args.keyboard.pressed.space then
    table.insert(args.state.lasers, {x = args.state.ship.x, y = args.state.ship.y - 40})
    naga.sound("assets/laser.ogg")
  end
end
