local function getDefaultSource()
    return {
        start = 0,
        finish = 0,
        uri = '',
    }
end

local mt = {}
mt.__index = mt
mt.type = 'local'

function mt:setValue(value)
    if self.value then
        self.value:mergeValue(value)
    else
        self.value = value
    end
end

function mt:getValue()
    return self.value
end

function mt:addInfo(tp, source)
    self[#self+1] = {
        type = tp,
        source = source,
    }
end

function mt:eachInfo(callback)
    for _, info in ipairs(self) do
        callback(info)
    end
end

function mt:setFlag(name, v)
    if not self._flag then
        self._flag = {}
    end
    self._flag[name] = v
end

function mt:getFlag(name)
    if not self._flag then
        return nil
    end
    return self._flag[name]
end

return function (name, source, value)
    if not value then
        error('Local must has a value')
    end
    local self = setmetatable({
        name = name,
        source = source or getDefaultSource(),
        value = value,
    }, mt)
    return self
end