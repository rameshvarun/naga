# Naga [WIP]
A framework for [Love2D](https://love2d.org/), heavily inspired by [DragonRuby](https://dragonruby.org/).

## Features
- A single `tick` function that replaces `load`, `update`, and `draw`
- Live-reload on file save (currently only reloads `main.lua`)
- Full access to the Love2D engine and it's ecosystem

## Installation

To install simply copy `naga.lua` into your game folder. Then add the following require to the top of your `main.lua`.

```lua
local naga = require "naga"
```

## Example Usage

<p align="center">
  <img width="320" height="240" src="demo.gif">
</p>

```lua
local naga = require "naga"

function naga.tick(args)
  love.graphics.clear(0, 0, 0.1) -- Background color of game
  naga.music("assets/music.ogg", 0.5) -- Looping background music.

  -- Create 50 randomly positioned stars.
  args.state.stars = args.state.stars or {}
  while #args.state.stars < 50 do
    table.insert(args.state.stars,
      {x = love.math.random() * 1280,
       y = love.math.random() * 720,
       z = love.math.random()})
  end

  -- Move stars with wraparound. Draw the stars.
  for _, star in ipairs(args.state.stars) do
    star.y = (star.y + star.z) % (720 + 24)

    love.graphics.setColor(1, 1, 1, star.z)
    love.graphics.draw(naga.image("assets/star.png"),
      star.x, star.y, 0, 1, 1, 25 / 2, 24)
    love.graphics.setColor(1, 1, 1, 1)
  end

  -- Lasers that move upwards when fired.
  args.state.lasers = args.state.lasers or {}
  for _, laser in ipairs(args.state.lasers) do
    laser.y = laser.y - 20
    love.graphics.draw(naga.image("assets/laser.png"),
      laser.x, laser.y, 0, 1, 1, 9 / 2, 54 / 2)
  end

  -- Create a ship that is moved with the arrow keys.
  args.state.ship = args.state.ship or {x = 1280 / 2, y = 720 / 2}
  args.state.ship.x = args.state.ship.x +
    (args.keyboard.held.right and 10 or 0) - (args.keyboard.held.left and 10 or 0)
  args.state.ship.y = args.state.ship.y +
    (args.keyboard.held.down and 10 or 0) - (args.keyboard.held.up and 10 or 0)

  -- Draw the ship.
  love.graphics.draw(naga.image("assets/ship.png"),
    args.state.ship.x, args.state.ship.y, 0, 1, 1, 99 / 2, 75 / 2)

  -- Shoot lasers with space.
  if args.keyboard.pressed.space then
    table.insert(args.state.lasers, {x = args.state.ship.x, y = args.state.ship.y - 40})
    naga.sound("assets/laser.ogg")
  end
end
```
