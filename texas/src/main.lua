require("Cocos2d")

function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(string.format(debug.traceback()))
    pcall(function()
        if Util and Util.uploadError then
            Util:uploadError(tostring(msg).."\n"..string.format(debug.traceback()))
        end
    end)
    print("----------------------------------------")
    return msg
end

local function setLuaSearchPath()
    local updated_path = QNative:shareInstance():getUpdatePath() .. "/"
    package.path = updated_path .. ";" .. package.path
    -- cc.Director:getInstance():getOpenGLView():setFrameSize(2436/2,1125/2)
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1920, 1080, cc.ResolutionPolicy.FIXED_HEIGHT)  
end

local function main()
    --avoid mem leak -- 
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
        collectgarbage("collect")
        print("  --- lua mem useage -- " .. collectgarbage("count") .. "Kbytes", "GAME")
    end, 30, false)

    setLuaSearchPath()

    require("src.update.HotUpdateMain")
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
