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

local color = {}

setmetatable(color, {
  __call = function(_, r, g, b, a)
    assert(type(r) == "number", "'r' must be a number.")
    assert(type(g) == "number", "'g' must be a number.")
    assert(type(b) == "number", "'b' must be a number.")

    return setmetatable({
      r = r,
      g = g,
      b = b,
      a = a or 1
    }, color)
  end
})

function color:__tostring()
  return "rgba(" ..
    tostring(self.r) .. ", " ..
    tostring(self.g) .. ", " ..
    tostring(self.b) .. ", " ..
    tostring(self.a) ..
  ")"
end

color.__index = color

-- Unpack color.
function color:rgb() return self.r, self.g, self.b end
function color:rgba() return self.r, self.g, self.b, self.a end

-- Clone the color so that it can be modified.
function color:clone() return color(self.r, self.g, self.b, self.a) end

-- Use this color globally.
function color:use()
  love.graphics.setColor(self.r, self.g, self.b, self.a)
end

function color:clear()
  love.graphics.clear(self.r, self.g, self.b, self.a)
end

color.white = color(1, 1, 1, 1)
color.black = color(0, 0, 0, 1)

color.grey = color(0.5, 0.5, 0.5, 1)
color.gray = color.grey

color.transparent = color(0, 0, 0, 0)

color.red = color(1, 0, 0, 1)
color.green = color(0, 1, 0, 1)
color.blue = color(0, 0, 1, 1)

color.yellow = color(1, 1, 0, 1)
color.purple = color(1, 0, 1, 1)
color.cyan = color(0, 1, 1, 1)

return color
