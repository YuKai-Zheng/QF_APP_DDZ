-- 牌桌辅助类
local GameHelper = class("GameHelper")

function GameHelper:ctor()
    self:initEvent()
end

function GameHelper:initEvent()
    -- 检测进桌
    qf.event:addEvent(ET.ROOM_CHECK, handler(self, self.onRoomCheck))
    -- 进桌金币检测
    qf.event:addEvent(ET.GOLD_CHECK, handler(self, self.onGoldCheck))
    -- 请求进桌
    qf.event:addEvent(ET.GAME_INPUT_REQ, handler(self, self.onGameInput))
    -- 断线重连
    qf.event:addEvent(ET.DDZ_NET_INPUT_REQ, handler(self, self.onProcessNetInput))
    -- 退出房间
    qf.event:addEvent(ET.RE_QUIT, handler(self, self.onReQuitRoom))
    -- 请求换桌
    qf.event:addEvent(ET.CHANGE_TABLE, handler(self, self.onChangetable))
    -- 游戏中切换前后台
    qf.event:addEvent(ET.GAME_SWITCH_FB, handler(self, self.onSwitchFB))
    --快速匹配
    qf.event:addEvent(ET.QUICK_START, handler(self, self.quickStart))
end

-- 进桌检测
function GameHelper:onRoomCheck(args)
    loga("-------------进桌检测-------------")
    if args.desk_mode == GAME_DDZ_NEWMATCH then
        -- 比赛场金币不足
        dump(Cache.user.ddz_match_config.min_gold_limit)
        if Cache.user.gold < Cache.user.ddz_match_config.min_gold_limit then 
            qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color=cc.c3b(0,0,0),fontsize=34,cb_consure=function( ... )
                Util:delayRun(0.1, function (  )
                    qf.platform:umengStatistics({umeng_key = "ToPayOnMatching"})--点击上报
					qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.MATCHING_REF})
                end)
            end})
            return
        end
    end

    GameNet:send({cmd=CMD.ROOM_CHECK_REQ, callback = function(rsp)
        local model = rsp.model

        local gameType = model.desk_mode
        if gameType == 0 then
            gameType = args.desk_mode
        end

        if gameType == GAME_DDZ_CLASSIC then
            -- 金币场进桌检测
            self:_checkClassicRoom(args.roomid, model, args.callback)
        elseif gameType == GAME_DDZ_FRIEND then
            -- 好友房进桌检测
            self:_checkFriendRoom(args.roomid, model, args.callback)
        elseif gameType == GAME_DDZ_MATCH then
            -- 比赛场进桌检测
            self:_checkMatchRoom(args.roomid, model, args.callback)
        elseif gameType == GAME_DDZ_NEWMATCH then
            --新比赛场进桌检测
            self:_checkNewMatchRoom(args.roomid, model, args.callback)
        end
    end})
end

-- 进桌金币数量检测
function GameHelper:onGoldCheck(roomId, cb)
    loga("---------------进桌金币检测----------------")
    GameNet:send({cmd=CMD.CHECK_GOLD_LIMIT_REQ,body={room_id=roomId},callback=function(rsp)
        local model = rsp.model
        if not model or model.flag ~= 0 then  -- 无法进场，消除loading
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
        end

        if model then
            local id = model.room_id
            if model.flag == 1 then -- 金币太少了
                qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                    if cb then
                        cb({flag = 1})
                        cb = nil
                    end
                    qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})--点击上报
                    qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
                end})
            elseif model.flag == 2 then -- 金币过多 去高级场
                    if cb then
                        cb({flag = 2, room_id = id})
                        cb = nil
                    else
                        qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = string.format(DDZ_TXT.should_to_advanced_room, Cache.DDZconfig:getRoomConfigByRoomId(id).room_name), type = 2,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                            self:getInRoom(id)
                        end})
                    end
            elseif model.flag == 0 then
                if cb then
                    cb({flag = 0, room_id = roomId})
                    cb = nil
                else
                    self:getInRoom(roomId)
                end
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            end
        else
            if rsp.ret ~= 0 then
                if rsp.ret == 1370 then
                    if cb then
                        cb({flag = -1, ret = 1370})
                        cb = nil
                    else
                        qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                            qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})-- 点击上报
                            qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
                        end})
                    end
                    
                else
                   qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                end
            end
        end
        if cb then 
            cb({flag = -1})
            cb = nil
        end
    end})
end

-- 请求进桌
function GameHelper:onGameInput(paras)
    loga("------------用户请求进桌----------")

    local body = {
        room_id = paras.roomid,
        desk_id = paras.deskid or 0,
        entry_type = paras.entryType or 0,
        start_type = paras.startType or GAME_START_TYPE.NORMAL,
        just_view = 0,
        desk_mode = paras.desk_mode or 1,  --现在都是标准房
        show_multi = paras.showMulti or 0,
        is_match = paras.isMatch or 0,
    }

    if isMatch == 0 then
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=Util:getRandomMotto()})
    end

    local cmd = body.desk_mode ~= GAME_DDZ_NEWMATCH and CMD.INPUT or CMD.NEWEVENT_ENTER_ROOM_REQ
    GameNet:send({cmd=cmd,body=body,timeout=5,callback=function(rsp)
        local game_conf =  Cache.DDZconfig.DDZ_room
        if rsp.ret == 36 then
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end

        if rsp.ret == 3 then
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end

        if paras.removeHall then
            ModuleManager:removeExistView()
        end
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
        ModuleManager.global:show()
        

        if rsp.model.desk_mode == 3 then
            ModuleManager:show("event", {roomid = roomid})
        elseif rsp.model.desk_mode == GAME_DDZ_NEWMATCH then
            ModuleManager:show("event", {roomid = roomid})
        else
            ModuleManager:show("normal", {roomid=roomid})
        end
    end})
end

-- 断线重连
function GameHelper:onProcessNetInput(paras)
    loga("断线重连 room_id=" .. paras.roomid)
    if paras == nil or paras.roomid == nil then return end

    local isMatch = 0
    Cache.DDZDesk.enterRef = GAME_DDZ_CLASSIC

    if math.modf(paras.roomid/10000) == 2 then
        -- 比赛场
        Cache.DDZDesk.enterRef = GAME_DDZ_MATCH
        isMatch = 1
    elseif math.modf(paras.roomid/10000) == 3 then
        -- 残局
        Cache.DDZDesk.enterRef = GAME_DDZ_ENDGAME
    elseif  paras.roomid == Cache.DDZconfig.friend_room_id then
        -- 好友房
        Cache.DDZDesk.enterRef = GAME_DDZ_FRIEND
    elseif math.modf(paras.roomid/10000) == 4 then
        --新比赛场
        Cache.DDZDesk.enterRef = GAME_DDZ_NEWMATCH
    end

    self:getInRoom(paras.roomid, true, Cache.DDZDesk.enterRef)
end

-- 请求退出房间
function GameHelper:onReQuitRoom(paras)
    -- 只要是退桌都会成功
    local cmd = Cache.DDZDesk.enterRef == GAME_DDZ_MATCH and CMD.MATCH_EXIT_DESK_REQ or CMD.USER_EXIT_REQ
    cmd = Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH and CMD.NEWEVENT_EXIT_ROOM_REQ or cmd
	GameNet:send({cmd= cmd,body={},callback = function (rsp)
        loga("-- 用户主动退桌callback\n" .. rsp.ret)
        if rsp.ret == 0 then
            if paras and paras.startMatch == true then
                Util:delayRun(0.3, function ()
                    qf.platform:umengStatistics({umeng_key = "ToGameOnMatching"}) -- 点击上报
                    if Cache.user.gold < Cache.user.ddz_match_config.min_gold_limit then
                        qf.event:dispatchEvent(ET.MYSELF_QUIT_ROOM)

                        qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color=cc.c3b(0,0,0),fontsize=34,cb_consure=function( ... )
                            Util:delayRun(0.1, function (  )
                                qf.platform:umengStatistics({umeng_key = "ToPayOnMatching"}) -- 点击上报
                                qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.MATCHING_REF})
                            end)
                        end})
                    else
                        qf.event:dispatchEvent(ET.GAME_INPUT_REQ, {
                            roomid = 0,
                            isMatch = 1,
                            desk_mode = Cache.DDZDesk.enterRef
                        })
                    end
                end)
            else
                qf.event:dispatchEvent(ET.MYSELF_QUIT_ROOM)
            end
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        end
    end})
end

-- 请求换桌
function GameHelper:onChangetable()
    loga("-----------请求换桌-----------")
    local cache_desk = Cache.DeskAssemble:getCache()
    local roomid = checkint(cache_desk.room_id)
    local cmd = Cache.DDZDesk.enterRef == GAME_DDZ_MATCH and CMD.MATCH_CHANGE_DESK_REQ or CMD.CHANGE_TABLE
    local paras = {}
    if roomid then
        paras = {
            room_id = roomid
        }
    end
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=Util:getRandomMotto()})

    local changeTableFunc
    changeTableFunc = function(paras)
        GameNet:send({cmd=cmd,body=paras,timeout=5,callback=function(rsp)
            Cache.DDZDesk:clear()
            if rsp.ret == 36 then
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                return
            end

            if rsp.ret ~= 0 then
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
                ModuleManager:removeExistView()
                ModuleManager.DDZhall:show()

                if rsp.ret == 3 then
                    qf.event:dispatchEvent(ET.NO_GOLD,{roomid=roomid})
                end
                -- 换桌的话，如果被踢了，那就重新进桌
                if rsp.ret == 2 then
                    -- 主动进新的桌子
                    if Cache.DDZDesk.enterRef == GAME_DDZ_CLASSIC then
                        qf.event:dispatchEvent(ET.QUICK_START, {inGame = true, needEnter = true})
                    end
                end
                return
            end
            ModuleManager:removeExistView()
            ModuleManager:show("normal")
            ModuleManager:get("game"):getView():matchingStartAni()
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
        end})
    end

    self:onGoldCheck(roomid, function(args)
        if args.flag == -1 then
            ModuleManager:removeExistView()
            ModuleManager:remove("game")
            ModuleManager.DDZhall:show()
            if args.ret == 1370 then
                qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                    qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})-- 点击上报
                    qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
                end})
            end
            return
        end
        if args.flag == 1 then
            ModuleManager:removeExistView()
            ModuleManager:remove("game")
            ModuleManager.DDZhall:show()
        elseif args.flag == 2 then
            paras = {room_id = args.room_id}
            changeTableFunc(paras)
        elseif args.flag == 0 then
            changeTableFunc(paras)
        end
    end)
end

-- 切换前后台
function GameHelper:onSwitchFB(type)
    local cache_desk = Cache.DeskAssemble:getCache()
    local deskid = checkint(cache_desk.desk_id)
    local roomid = checkint(cache_desk.room_id)

    if type == "show" then
        -- 如果是分享出去回来，则暂时不刷新桌子，保持原来的状态
        loga("游戏中切换前台")
        if Cache.user.shareFlag == false then
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
            Cache.user.shareFlag = true
            return
        end
        -- body
        local tipContent = GameTxt.gameLoaddingTips001[math.random(1, #GameTxt.gameLoaddingTips001)] or ""
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=tipContent})

        -- 查询桌子并重新进桌. 如果因为网络原因发送失败，会一直重试，直到服务器得到服务器的返回值.
        -- 如果服务器返回值指明桌子不存在了，就退桌。如果桌子存在就进桌。
        local function _queryDesk( ... )
            local cmd = Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH and CMD.NEWEVENT_QUERY_DESK_REQ or CMD.QUERY_DESK
            GameNet:send({cmd=cmd, body={},callback=function ( rsp )
                if rsp.ret == 0 then
                    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                    Cache.user.come_back = true --记录从后台切换回来
                    qf.event:dispatchEvent(ET.ENTER_ROOM, rsp)

                    if (rsp.model.status ~=0 or rsp.model.player_info:len()==3) and ModuleManager.global.view.gameMatchingView then
                        ModuleManager.global.view.gameMatchingView:removeFromParent()
                        ModuleManager.global.view.gameMatchingView = nil
                    elseif rsp.model.status == 0 and rsp.model.player_info:len()<3 and Cache.DDZDesk.enterRef == GAME_DDZ_MATCH then
                        ModuleManager.gameshall:initModuleEvent()
                        ModuleManager.gameshall:show()
                        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "matching",noAni=true})
                        if ModuleManager:get("game") and isValid(ModuleManager:get("game").view) then
                            ModuleManager:get("game"):getView():setVisible(false)
                        end
                        
                    elseif rsp.model.status ==0 and rsp.model.player_info:len()==3 then
                        if Cache.DDZDesk.enterRef == GAME_DDZ_MATCH and not rsp.model.is_final_round then return end
                        for i = 1 ,rsp.model.player_info:len() do
                            local v = rsp.model.player_info:get(i)
                            if v.uin == Cache.user.uin and v.status == 1018 then
                                Util:delayRun(0.5,function ()
                                    ModuleManager:removeExistView()
                                    qf.event:dispatchEvent(ET.NET_EXIT_REQ,{send=false})
                                    ModuleManager.gameshall:show({stopEffect = true})
                                    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                                end)
                                return
                            end
                        end
                    end
                elseif rsp.ret == NET_WORK_ERROR.TIMEOUT then -- 如果没有发出去，则延迟0.5s再次尝试
                    Util:delayRun(0.5, function( ... )
                        _queryDesk()
                    end)
                else -- 查询失败，退桌
                    -- 这里如果服务器通知拉取桌子信息失败,可能是因为桌子不存在或本人不在桌子内. 所以就没有必要再向服务器发送退桌请求了.
                    qf.event:dispatchEvent(ET.REMOVE_GAME_MATHING_VIEW)
                    Util:delayRun(1.0,function ()
                        ModuleManager:removeExistView()
                        ModuleManager:remove("game")
                        qf.event:dispatchEvent(ET.NET_EXIT_REQ,{send=false})
                        ModuleManager.gameshall:show({stopEffect = true})
                        qf.platform:umengStatistics({umeng_key = "ResumeToHall"})--点击上报
                        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
                    end)
                end
            end})
        end
        _queryDesk()
    elseif type == "hide" then
        loga("游戏中切换后台")
    end
end

-- 进入游戏房间
function GameHelper:getInRoom(roomid, isReconnect, desk_mode)
    dump("进入游戏房间")
    local resList =  {
        {type = "Plist", file = {plist = DDZ_Res.doudizhu_Plist, png = DDZ_Res.doudizhu_Png}},
        {type = "Png", file = DDZ_Res.ddz_game_bg},
        {type = "Animate", file = DDZ_Res.match_level_animation_json},
        {type = "Plist", file = {plist = DDZ_Res.matchLevelAnimation_PLIST, png = DDZ_Res.matchLevelAnimation_PNG}}
    }

    for k,v in pairs(DDZ_Res.preloadImg) do
        local res = {type = "Png", file = v}

        table.insert(resList, res)
    end
    ResourceManager:load({
        resList = resList,
        cb = function()
            Cache.DDZDesk.room_id = roomid

            --if isReconnect then 
                qf.event:dispatchEvent(ET.GAME_INPUT_REQ, {
                    roomid = roomid,
                    removeHall = true,
                    desk_mode = desk_mode
                })
            -- else
            --     ModuleManager:removeExistView()
            --     qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
            --     ModuleManager:show("normal")
            --     ModuleManager:get("game"):getView():initDeskDesc()
            -- end
        end,
        name = "game"
    })
end

-- 金币场进桌检测
function GameHelper:_checkClassicRoom (roomid, model, cb)
    if model and model.old_room > 0 and model.desk_id > 0 then
        loga("金币场进桌检测\n" .. pb.tostring(model))
        local roomId = model.old_room
        local deskId = model.desk_id
        local inGame = model.in_game
        local gameType = model.desk_mode

        local inputRequest = function (paras)
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=Util:getRandomMotto()})
            Util:delayRun(0.5, function ()
                qf.event:dispatchEvent(ET.GAME_INPUT_REQ, {
                    roomid = paras.roomid,
                    startType = paras.startType,
                    showMulti = paras.showMulti,
                    removeHall = true
                 })
            end)
        end

        if roomId == roomid then
            Cache.DDZDesk.room_id = roomId
            inputRequest({
                roomid = roomId,
                startType = GAME_START_TYPE.NORMAL,
                showMulti = 1
            })
        else
            Cache.DDZDesk.room_id = roomid
            qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = DDZ_TXT.ddz_hall_return_game_tips, type = 2,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                inputRequest({
                    roomid = roomid,
                    startType = GAME_START_TYPE.NORMAL,
                    showMulti = 1
                })
            end})
        end
    else
        if roomid then
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=Util:getRandomMotto()})
            self:onGoldCheck(roomid, cb)
        end
    end
end

-- 比赛场进桌检测
function GameHelper:_checkMatchRoom (roomid, model, cb)
    loga("比赛场进桌检测\n" .. pb.tostring(model))
    --进桌请求前将oldroomID消除，防止影响判断
    Cache.user.old_roomid = 0
    Cache.DDZDesk.enterRef = GAME_DDZ_MATCH
    --qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "DDZhall"})
    qf.event:dispatchEvent(ET.GAME_INPUT_REQ, {
        roomid = 0,
        isMatch = 1
    })
end

function GameHelper:_checkNewMatchRoom( roomid, model, cb )
    loga("新比赛场进桌检测\n" .. pb.tostring(model))
    Cache.user.old_roomid = 0
    Cache.DDZDesk.enterRef = GAME_DDZ_NEWMATCH

    self:getInRoom(roomid, true, GAME_DDZ_NEWMATCH)
end

-- 好友房进桌检测
function GameHelper:_checkFriendRoom (roomid, model, cb)

end

--快速匹配开局
function GameHelper:quickStart(paras)
    GameNet:send({cmd=CMD.QUICK_START,body={play_mode=1},callback = function ( rsp )
        local model = rsp.model

        if model then
            if model.room_id < 0 then
                if paras.inGame then
                    ModuleManager:removeExistView()
                    ModuleManager:remove("game")
                    ModuleManager.DDZhall:show()
                end

                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[3]})
                if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
                    qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                        qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})--点击上报
                        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
                    end})
                end
            else
                local callback = nil
                if paras.needEnter then
                    callback = function ( args )
                        if args.flag == -1 then
                            if paras.inGame then
                                ModuleManager:removeExistView()
                                ModuleManager:remove("game")
                                ModuleManager.DDZhall:show()
                            end
                            return
                        end
                        if args.flag == 0 then
                            self:getInRoom(args.room_id, true)
                        end
                    end
                end
                if paras.cb then callback = cb end
                qf.event:dispatchEvent(ET.ROOM_CHECK, {roomid = roomid, desk_mode = GAME_DDZ_CLASSIC, callback = callback})
            end
        end
    end})
end

return GameHelper