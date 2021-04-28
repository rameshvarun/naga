local prev_require = require
function require(modname)
  if modname == "naga" then modname = "." end
  return prev_require(modname)
end

local function load(demo)
  package.loaded[demo] = nil
  require(demo)

  local tick = naga.tick
  function naga.tick(args)
    tick(args)

    if args.keys.pressed["1"] then
      load "demos.space"
    elseif args.keys.pressed["2"] then
      load "demos.platformer"
    end

    love.graphics.setFont(naga.font(20))
    love.graphics.printf([[
DEMOS:
1 - SPACE SHOOTER
2 - PLATFORMER
    ]], 0, 0, love.graphics.getWidth())
  end
end

load "demos.space"
