--[[
    牌桌缓存数据汇总
--]]

local Assemble = class("Assemble")

--游戏类型
Assemble.game_type = ""

--[[ 设置游戏类型 ]]
function Assemble:setGameType(t)
    self.game_type = t
end

--[[ 获取游戏类型 ]]
function Assemble:getGameType()
    return self.game_type
end

--[[ 清除游戏类型 ]]
function Assemble:clearGameType()
    self.game_type = ""
end

--[[ 判断游戏类型 ]]
function Assemble:judgeGameType(t)
    return t == self.game_type
end


--[[ 获取数据缓存 ]]
function Assemble:getCache(game_type)
    game_type = game_type or self.game_type

    if game_type == GAME_DDZ then
        return Cache.DDZDesk
    end
    return {}
end


return Assemble