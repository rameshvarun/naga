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

local naga = {
  ticksPerSecond = 60,
  canvasSize = { width = 1280, height = 720 },

  lastModifiedTime = {},
  scanPeriod = 0.5,
  lastScanTime = 0,
}

local state = {}

-- The user will override this function for their game.
function naga.tick(args) end

function love.load()
  naga.scan("", function(filename)
    local info = love.filesystem.getInfo(filename)
    naga.lastModifiedTime[filename] = info.modtime
  end)
  naga.lastScanTime = love.timer.getTime()
end

local heldKeys = {}
local pressedKeys = {}
local releasedKeys = {}
function love.keypressed(key, scancode, isrepeat)
  heldKeys[key] = true
  pressedKeys[key] = true
end
function love.keyreleased(key)
  heldKeys[key] = nil
  releasedKeys[key] = nil
end

function love.update(dt)
  if love.timer.getTime() >= naga.lastScanTime + naga.scanPeriod then
    local filesChanged = false
    naga.scan("", function(filename)
      local info = love.filesystem.getInfo(filename)

      if info.modtime > naga.lastModifiedTime[filename] then
        filesChanged = true
        naga.lastModifiedTime[filename] = info.modtime
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

  love.graphics.origin()
  love.graphics.translate(love.graphics.getWidth() / 2 - actualSize.width / 2,
    love.graphics.getHeight() / 2 - actualSize.height / 2)
  love.graphics.scale(scale, scale)

  love.graphics.setScissor()
  love.graphics.clear(0,0,0)

  --
  love.graphics.setScissor(love.graphics.getWidth() / 2 - actualSize.width / 2,
    love.graphics.getHeight() / 2 - actualSize.height / 2, actualSize.width, actualSize.height)

  -- Construct the args array to pass in to the user-defined tick.
  local args = {}
  args.state = state
  args.keyboard = { held = heldKeys, pressed = pressedKeys, released = releasedKeys }

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

  while frameTimeAccumulator >= timestep do
    naga.frame()
    frameTimeAccumulator = frameTimeAccumulator - timestep
  end

  love.graphics.setCanvas()
  love.graphics.origin()
  love.graphics.draw(canvas, 0, 0)
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
