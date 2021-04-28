local doc = {}

-- Store documentation metadata in a table with weak keys.
local docstrings = setmetatable({}, {__mode = "k"})

function doc.annotate(value, docstring, fieldDoc)
    docstrings[value] = docstring
end

function doc.help(value)
    return docstrings[value]
end

setmetatable(doc, {
    __call = function(_, ...)
        return doc.annotate(...)
    end
})

return doc
