--[[
The ISC License

Copyright (c) Varun Ramesh

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT,
OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]--

local _PACKAGE = ... -- Get the current name of the module
local config = NAGA_CONF or {} -- This global allows the user to configure Naga

local naga = {}

naga.ticksPerSecond = config.ticksPerSecond or 60 -- The game runs at a fixed tick rate.
naga.canvasSize = config.canvasSize or { width = 1280, height = 720 } -- The game has a fixed canvas size

naga.maxTicks = 4 -- Cap how many ticks can happen on a frame.

naga.debug = false -- Toggle this to move in and out of debug mode.
naga.paused = false -- Built-in pausing system

-- Load submodules.
naga.vec = require(_PACKAGE .. ".vec")
naga.color = require(_PACKAGE .. ".color")
naga.util = require(_PACKAGE .. ".util")
naga.console = require(_PACKAGE .. ".console.console")

-- Make all submodules directly available on console scope.
naga.console.ENV.naga = naga
naga.console.ENV.vec = naga.vec
naga.console.ENV.color = naga.color
naga.console.ENV.util = naga.util
naga.console.ENV.console = naga.console



local lastModifiedTime = {}
local scanPeriod = 0.5
local lastScanTime = love.timer.getTime()

local function initializeState()
  local state = {
    init = function(self, key, value)
      if self[key] == nil then self[key] = value end
      return self[key]
    end
  }

  naga.console.ENV.state = state -- Make state available from console.
  return state
end

local state = initializeState()

naga.console.COMMANDS.reset = function() state = initializeState() end
naga.console.COMMANDS.pause = function() naga.paused = true end
naga.console.COMMANDS.unpause = function() naga.paused = false end

-- The user will override this function for their game.
function naga.tick(args) end

function love.load()
  naga.scan("", function(filename)
    local info = love.filesystem.getInfo(filename)
    lastModifiedTime[filename] = info.modtime
  end)
end

local heldKeys = {}
local pressedKeys = {}
local releasedKeys = {}
function love.keypressed(key, scancode, isrepeat)
  if key == 'f1' then naga.debug = not naga.debug end
  if key == 'escape' then naga.paused = not naga.paused end
  naga.console.keypressed(key, scancode, isrepeat)

  if not naga.console.isEnabled() then
    heldKeys[key] = true
    pressedKeys[key] = true
  end
end
function love.keyreleased(key)
  if not naga.console.isEnabled() then
    heldKeys[key] = nil
    releasedKeys[key] = nil
  end
end

function love.textinput(text)
  naga.console.textinput(text)
end

function love.update(dt)
  if love.timer.getTime() >= lastScanTime + scanPeriod then
    local filesChanged = false
    naga.scan("", function(filename)
      local info = love.filesystem.getInfo(filename)

      if info.modtime > lastModifiedTime[filename] then
        filesChanged = true
        lastModifiedTime[filename] = info.modtime
      end
    end)
    naga.lastScanTime = love.timer.getTime()

    if filesChanged then
      print("Files changed... Reloading game...")
      naga.reload()
    end
  end
end

function naga.reload()
  -- TODO: Support more than just reloading main
  package.loaded["main"] = nil
  require("main")
end

local canvas = love.graphics.newCanvas()

function naga.frame()
  if love.graphics.getWidth() ~= canvas:getWidth()
    or love.graphics.getHeight() ~= canvas:getHeight() then
    canvas = love.graphics.newCanvas()
  end

  love.graphics.setCanvas(canvas)
  love.graphics.clear()

  -- Scale and letterbox the game canvas.
  local windowAspect = love.graphics.getWidth() / love.graphics.getHeight()
  local canvasAspect = naga.canvasSize.width / naga.canvasSize.height
  local heightLimited = windowAspect >= canvasAspect

  local scale = love.graphics.getWidth() / naga.canvasSize.width
  if heightLimited then
    scale = love.graphics.getHeight() / naga.canvasSize.height
  end

  local actualSize = {width = scale * naga.canvasSize.width,
    height = scale * naga.canvasSize.height}

  local offset = {
    x = love.graphics.getWidth() / 2 - actualSize.width / 2,
    y = love.graphics.getHeight() / 2 - actualSize.height / 2
  }

  love.graphics.origin()
  love.graphics.translate(offset.x, offset.y)
  love.graphics.scale(scale, scale)
  love.graphics.setScissor()
  love.graphics.clear(0,0,0)

  --
  love.graphics.setScissor(love.graphics.getWidth() / 2 - actualSize.width / 2,
    love.graphics.getHeight() / 2 - actualSize.height / 2, actualSize.width, actualSize.height)

  -- Construct the args array to pass in to the user-defined tick.
  local args = {}
  args.state = state
  args.debug = naga.debug

  args.keys = { held = heldKeys, pressed = pressedKeys, released = releasedKeys }
  args.keys.arrows = naga.vec(
    (args.keys.held.right and 1 or 0) - (args.keys.held.left and 1 or 0),
    (args.keys.held.down and 1 or 0) - (args.keys.held.up and 1 or 0))
  if args.keys.arrows:len() > 1 then
    args.keys.arrows:normalize()
  end

  args.mouse = {}
  args.mouse.pos = naga.vec(love.mouse.getX() - offset.x, love.mouse.getY() - offset.y) / scale

  -- Run the game tick.
  naga.tick(args)

  pressedKeys = {}
  releasedKeys = {}

  -- Return the scissor to the full screen.
  love.graphics.setScissor()
end

local frameTimeAccumulator = 0
function love.draw()
  frameTimeAccumulator = frameTimeAccumulator + love.timer.getDelta()
  local timestep = 1 / naga.ticksPerSecond
  local numTicks = 0

  while frameTimeAccumulator >= timestep do
    if not naga.paused then naga.frame() end
    frameTimeAccumulator = frameTimeAccumulator - timestep
    numTicks = numTicks + 1

    if numTicks >= naga.maxTicks then
      print("Max tick exceeded. Resetting accumulator.")
      frameTimeAccumulator = 0
      break
    end
  end

  love.graphics.setCanvas()
  love.graphics.origin()
  love.graphics.draw(canvas, 0, 0)

  if naga.debug then
    love.graphics.setFont(naga.font(20))
    love.graphics.print("DEBUG MODE")
  end

  if naga.paused then
    love.graphics.setFont(naga.font(40))
    love.graphics.printf("PAUSED", 0, 0, love.graphics.getWidth(), "center")
  end

  naga.console.draw()
end

local imageCache = {}
function naga.image(filename)
  if imageCache[filename] then
    return imageCache[filename]
  else
    local image = love.graphics.newImage(filename)
    imageCache[filename] = image
    return image
  end
end

local fontCache = {}
function naga.font(size)
  if fontCache[size] then
    return fontCache[size]
  else
    local font = love.graphics.newFont(size)
    fontCache[size] = font
    return font
  end
end

function naga.sound(filename)
  -- TODO: Pool sounds so a new source is only created if all the sources
  -- in the pool are currently playing.
  love.audio.newSource(filename, 'static'):play()
end

local currentMusic = nil
function naga.music(filename, volume)
  volume = volume or 1.0
  -- TODO: Switch music by automatically fading out.
  if currentMusic == nil then
    currentMusic = love.audio.newSource(filename, 'stream')
    currentMusic:setVolume(volume)
    currentMusic:setLooping(true)
    currentMusic:play()
  end
end

function naga.sprite(path, pos, options)
  local image = naga.image(path)

  local r = 0
  local sx = 1
  local sy = 1

  local ox = 0
  local oy = 0

  local color = options.color or naga.color.white

  if options.origin then
    ox = options.origin.x * image:getWidth()
    oy = options.origin.y * image:getHeight()
  end

  local kx = 0
  local ky = 0

  color:use()
  love.graphics.draw(image, pos.x, pos.y, r, sx, sy, ox, oy, kx, ky)
end

function naga.scan(path, eachFunc)
  local items = love.filesystem.getDirectoryItems(path)
  for _, filename in pairs(items) do
    local fullpath = path .. "/" .. filename
    local info = love.filesystem.getInfo(fullpath)

    if info.type == "file" then eachFunc(fullpath) end
    if info.type == "directory" then naga.scan(fullpath, eachFunc) end
  end
end

return naga
