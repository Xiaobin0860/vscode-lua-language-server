local files   = require 'files'
local guide   = require 'parser.guide'
local vm      = require 'vm'
local define  = require 'proto.define'
local lang    = require 'language'
local await   = require 'await'

return function (uri, callback)
    local ast = files.getAst(uri)
    if not ast then
        return
    end
    -- 只检查局部函数与全局函数
    guide.eachSourceType(ast.ast, 'function', function (source)
        local parent = source.parent
        if not parent then
            return
        end
        if  parent.type ~= 'local'
        and parent.type ~= 'setlocal'
        and parent.type ~= 'setglobal' then
            return
        end
        local hasSet
        local hasGet = vm.eachRef(source, function (info)
            if     info.mode == 'get' then
                return true
            elseif info.mode == 'set'
            or     info.mode == 'declare' then
                hasSet = true
            end
        end)
        if not hasGet and hasSet then
            callback {
                start   = source.start,
                finish  = source.finish,
                tags    = { define.DiagnosticTag.Unnecessary },
                message = lang.script.DIAG_UNUSED_FUNCTION,
            }
        end
        await.delay(function ()
            return files.globalVersion
        end)
    end)
end
