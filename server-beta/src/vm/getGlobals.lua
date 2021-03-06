local guide = require 'parser.guide'
local vm    = require 'vm.vm'

local function getGlobals(root)
    local env  = guide.getENV(root)
    local cache = {}
    local mark = {}
    vm.eachField(env, function (info)
        local src = info.source
        if mark[src] then
            return
        end
        mark[src] = true
        local name = info.key
        if not name then
            return
        end
        if not cache[name] then
            cache[name] = {
                key  = name,
                mode = {},
            }
        end
        cache[name][#cache[name]+1] = info
        cache[name].mode[info.mode] = true
        vm.cache.getGlobal[src] = name
    end)
    return cache
end

function vm.getGlobals(source)
    source = guide.getRoot(source)
    local cache = vm.cache.getGlobals[source]
    if cache ~= nil then
        return cache
    end
    local unlock = vm.lock('getGlobals', source)
    if not unlock then
        return nil
    end
    cache = getGlobals(source) or false
    vm.cache.getGlobals[source] = cache
    unlock()
    return cache
end
