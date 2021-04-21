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

local _PACKAGE = (...):match("^(.+)%.[^%.]+")

local util = require(_PACKAGE .. ".util")

local vec = {}

setmetatable(vec, {
  __call = function(_, x, y)
    return setmetatable({x = x, y = y}, vec)
  end
})

vec.__index = vec

local function isnum(a)
  return type(a) == "number"
end

local function isvec(v)
  return type(v) == "table" and isnum(v.x) and isnum(v.y)
end

function vec:clone()
  return vec(self.x, self.y)
end

function vec.__mul(a, b)
  if isvec(a) and isnum(b) then
    return vec(a.x * b, a.y * b)
  elseif isnum(a) and isvec(b) then
    return vec(a * b.x, a * b.y)
  else
    error()
  end
end

function vec.__div(a, b)
  if isvec(a) and isnum(b) then
    return vec(a.x / b, a.y / b)
  else
    error()
  end
end


function vec:__tostring()
  return "<" .. tostring(self.x) .. ", " .. tostring(self.y) .. ">"
end

function vec:translate(x, y)
  if isvec(x) then
    local other = x
    self.x = self.x + other.x
    self.y = self.y + other.y
  else
    self.x = self.x + x
    self.y = self.y + y
  end
  return self
end

function vec:clamp(lower, upper)
  self.x = util.clamp(self.x, lower.x, upper.x)
  self.y = util.clamp(self.y, lower.y, upper.y)
  return self
end

function vec:translated(x, y)
  return self:clone():translate(x, y)
end

function vec:len()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

function vec:unpack()
  return self.x, self.y
end

function vec:normalize()
  local len = self:len()
  if len > 0 then
    self.x = self.x / len
    self.y = self.y / len
  end
  return self
end

function vec:permul(other)
  return vec(self.x * other.x, self.y * other.y)
end

function vec.random(...)
  local args = {...}
  if #args == 0 then
    return vec(love.math.random(), love.math.random())
  elseif #args == 1 then
    local upper = args[1]
    return vec(love.math.random() * upper.x, love.math.random() * upper.y)
  else
    error("Unexpected number of arguments to vec.random")
  end
end

return vec
