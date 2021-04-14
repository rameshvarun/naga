local util = {}

function util.map(tbl, f)
    local t = {}
    for k,v in pairs(tbl) do t[k] = f(v) end
    return t
end

function util.filter(tbl, f)
  local t, i = {}, 1
  for _, v in ipairs(tbl) do
    if f(v) then t[i], i = v, i + 1 end
  end
  return t
end

function util.push(tbl, ...)
  for _, v in ipairs({...}) do table.insert(tbl, v) end
end

function util.clamp(val, lower, upper)
  if val < lower then return lower
  elseif val > upper then return upper
  else return val
  end
end

return util
