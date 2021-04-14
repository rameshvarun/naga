# Naga [WIP]
A framework for [Love2D](https://love2d.org/), heavily inspired by [DragonRuby](https://dragonruby.org/).

## Features
- A single `tick` function that replaces `load`, `update`, and `draw`
- Live-reload on file save (currently only reloads `main.lua`)
- Full access to the Love2D engine and it's ecosystem

## Installation

To install, run `git submodule add https://github.com/rameshvarun/naga.git naga` in the same directory as your main.lua.

```lua
local naga = require "naga"
```

## Example Usage

<p align="center">
  <img width="320" height="240" src="demo.gif">
</p>

```lua
local naga = require "."
local vec = naga.vec

function naga.tick(args)
  love.graphics.clear(0, 0, 0.1) -- Background color of game
  naga.music("assets/music.ogg", 0.5) -- Looping background music.

  -- Create 50 randomly positioned stars.
  local stars = args.state:init("stars", {})
  while #stars < 50 do
    table.insert(stars, {pos = vec(love.math.random() * 1280, love.math.random() * 720),
                         depth = love.math.random()})
  end

  -- Move stars with wraparound and draw.
  for _, star in ipairs(stars) do
    star.pos.y = (star.pos.y + star.depth) % (720 + 24)

    love.graphics.setColor(1, 1, 1, star.depth)
    love.graphics.draw(naga.image("assets/star.png"),
      star.pos.x, star.pos.y, 0, 1, 1, 25 / 2, 24)
    love.graphics.setColor(1, 1, 1, 1)
  end

  -- Lasers that move upwards when fired.
  local lasers = args.state:init("lasers", {})
  for _, laser in ipairs(lasers) do
    laser.y = laser.y - 20
    love.graphics.draw(naga.image("assets/laser.png"),
      laser.x, laser.y, 0, 1, 1, 9 / 2, 54 / 2)
  end

  -- Create a ship that is moved with the arrow keys.
  local ship = args.state:init("ship", vec(1280 / 2, 720 / 2))
  ship:translate((args.keys.held.right and 10 or 0) - (args.keys.held.left and 10 or 0),
    (args.keys.held.down and 10 or 0) - (args.keys.held.up and 10 or 0))
  ship:clamp(vec(0, 0), vec(1280, 720)) -- Stay on screen

  -- Draw the ship.
  love.graphics.draw(naga.image("assets/ship.png"), ship.x, ship.y, 0, 1, 1, 99 / 2, 75 / 2)

  -- Shoot lasers with space.
  if args.keys.pressed.space then
    table.insert(lasers, ship:translated(0, -40))
    naga.sound("assets/laser.ogg")
  end
end
```
