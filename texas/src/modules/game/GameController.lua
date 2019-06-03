local GameController = class("GameController",qf.controller)
GameController.TAG = "GameController"

local gameView = import(".GameView")
local InteractPhizManager = import("src.modules.global.components.InteractPhizManager")

function GameController:ctor(parameters)
    self.super.ctor(self)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.tableCard = {}
end


function GameController:remove()
    if self.tableCard and #self.tableCard > 0 then
        for k,v in pairs(self.tableCard) do
            if isValid(v.card) then
               v.card:release()
            end
        end
        self.tableCard = {}
    end

    self.super.remove(self)
    self.musicLayer = nil   
    Cache.DeskAssemble:clearGameType()  --清除游戏类型
end

function GameController:initView(parameters)
    qf.event:dispatchEvent(ET.MODULE_SHOW,"DDZgame")
    Cache.DeskAssemble:setGameType(GAME_DDZ)
    local view = gameView.new(parameters)
    return view
end

function GameController:initGlobalEvent()

end

function GameController:initModuleEvent()
    --玩家准备
    self:addModuleEvent(ET.USER_READY,handler(self,self.userReady))
    --进桌
    self:addModuleEvent(ET.ENTER_ROOM,handler(self,self.enterRoom))
    --游戏开始
    self:addModuleEvent(ET.GAME_START,handler(self,self.gameStart))
    --比赛结束
    self:addModuleEvent(ET.GAME_END,handler(self,self.GameEnd))
    --玩家叫分
    self:addModuleEvent(ET.CALL_POINTS,handler(self,self.CallPoints))
    --玩家加倍
    self:addModuleEvent(ET.CALL_DOUBLE,handler(self,self.CallDouble))
    --要不起
    self:addModuleEvent(ET.NOT_FOLLOW_RSP,handler(self,self.notFollowCards))
    --用户明牌
    self:addModuleEvent(ET.LIGHT_CARD,handler(self,self.userShowCard))
    --出牌
    self:addModuleEvent(ET.OUT_CARDS_NTF,handler(self,self.outCards))
    --玩家自己主动退桌
    self:addModuleEvent(ET.MYSELF_QUIT_ROOM,handler(self,self.myselfQuitRoom))
    --退出
    self:addModuleEvent(ET.QUIT_ROOM,handler(self,self.quitRoom))
    --下一个到谁操作
    self:addModuleEvent(ET.USER_HANDLE_TURN,handler(self,self.userHandleTurn))
    --通知玩家操作
    self:addModuleEvent(ET.OPUSER_NOTIFY,handler(self,self.opUserOperate))
    -- 用户主动准备
    self:addModuleEvent(ET.USER_READY_REQ,handler(self,self.readyRequest))
    --倍数更新
    self:addModuleEvent(ET.DESK_MULTI_CHANGE_NOTIFY,handler(self,self.deskMySelfBeiInfoUpdate))

    --倍数更新
    self:addModuleEvent(ET.GAME_SYN_FORTUNE_INFO,handler(self,self.deskUserFortuneInfoUpdate))

    --托管状态更新
    self:addModuleEvent(ET.USER_AUTO_PLAY, handler(self,self.updateUserAutoPlay))
    --金币改动
    self:addModuleEvent(ET.NET_EVENT_OTHER_GOLD_CHANGE,handler(self,self.processGameChangeOtherGoldEvt))
    --明牌倍数更新
    self:addModuleEvent(ET.CARD_SHOW_TIME_EVENT, handler(self, self.updateShowCardCount))

    --出牌提示
    self:addModuleEvent(ET.SHOW_OUTCARDS_TIPS,function( paras )
        self.view:showOutCardsTips(paras)
    end)
    --显示托管
    self:addModuleEvent(ET.SHOW_AUTO_PLAYER,function( paras )
        self.view:showAutoPlayer(paras.isshow)
    end)
    --切换背景声音的播放
    self:addModuleEvent(ET.UPDATE_BG_MUSIC,handler(self,self.updateBgMusic))
    --用户信息
    self:addModuleEvent(ET.GAME_SHOW_USER_INFO,handler(self,self.showUserInfo))
    --收到互动表情
    self:addModuleEvent(ET.INTERACT_PHIZ_NTF, handler(self, self.handleInteractPhiz)) -- 收到一条互动表情
    --收到聊天消息
    self:addModuleEvent(ET.NET_CHAT_NOTICE_EVT,handler(self,self.chat))
    --奖券变化通知
    qf.event:addEvent(ET.EVT_USER_FOCARD_CHANGE_GAMEVIEW,function(rsp)
        loga("奖券变化通知EVT_USER_FOCARD_CHANGE_GAMEVIEW"..rsp.model.remain_amount)
        if rsp.model and rsp.model.remain_amount then 
            Cache.user.fucard_num = rsp.model.remain_amount
        end
        if self.view then 
            self.view:updateUserInfo(rsp)
        end
    end)

    --金币变化通知 190 
    qf.event:addEvent(ET.GOLD_CHANGE_RSP_Game,function(rsp)
        loga("金币变化通知GOLD_CHANGE_RSP_Game"..rsp.rsp.uin)
        dump(rsp.rsp)
        if self.view then 
            self.view:updateUserInfo(rsp.rsp)
        end
        if ModuleManager.change_userinfo.view and rsp.uin == Cache.user.uin then
            ModuleManager.change_userinfo.view:refreshGold()
        end
    end)

    --玩家被踢
    self:addModuleEvent(ET.GAME_KICK, handler(self, self.gameKick))
end

function GameController:removeModuleEvent()
    qf.event:removeEvent(ET.ENTER_ROOM)
    qf.event:removeEvent(ET.GAME_START)
    qf.event:removeEvent(ET.GAME_END)
    qf.event:removeEvent(ET.NOT_FOLLOW_RSP)
    qf.event:removeEvent(ET.OUT_CARDS_NTF)
    qf.event:removeEvent(ET.NET_CHAT_NOTICE_EVT)
    qf.event:removeEvent(ET.QUIT_ROOM)
    qf.event:removeEvent(ET.USER_HANDLE_TURN)
    qf.event:removeEvent(ET.NET_EVENT_OTHER_GOLD_CHANGE)
    qf.event:removeEvent(ET.SHOW_OUTCARDS_TIPS)
    qf.event:removeEvent(ET.SHOW_AUTO_PLAYER)
    qf.event:removeEvent(ET.UPDATE_BG_MUSIC)
    qf.event:removeEvent(ET.INTERACT_PHIZ_NTF)
    qf.event:removeEvent(ET.EVT_USER_FOCARD_CHANGE_GAMEVIEW)
    qf.event:removeEvent(ET.GOLD_CHANGE_RSP_Game)
    qf.event:removeEvent(ET.GAME_KICK)
    qf.event:removeEvent(ET.LIGHT_CARD)
    qf.event:removeEvent(ET.USER_AUTO_PLAY)
    qf.event:removeEvent(ET.DESK_MULTI_CHANGE_NOTIFY)
    qf.event:removeEvent(ET.CARD_SHOW_TIME_EVENT)
end

--玩家自己被踢（经典场）
function GameController:gameKick(rsp)
    loga("玩家被踢通知GameController:gameKick")
    -- 设置游戏状态
    Cache.DDZDesk.status = GameStatus.NONE
end

-- 用户准备
function GameController:userReady(rsp)
    loga("用户准备通知\n" .. pb.tostring(rsp.model))
    if Cache.DDZDesk._player_info[rsp.model.uin] then
        Cache.DDZDesk._player_info[rsp.model.uin].status = 1020
    end
    if self.view == nil then return end
    self.view:userReady(rsp.model)
end

function GameController:MathingSuccess( ... )
    ModuleManager.DDZhall:remove()
    ModuleManager.gameshall:remove()
    ModuleManager.matching:remove()
    ModuleManager:get("game"):getView():setVisible(true)
    
    MusicPlayer:setBgMusic(string.format(DDZ_Res.all_music.gameMusic,Cache.DDZDesk.musicType))
    MusicPlayer:backgroundSineIn()
    DDZ_Sound:playSoundGame(DDZ_Sound.GameStart)
end

--用户准备请求（需要金币检测）
function GameController:readyRequest(paras)
    local readyFun = function (roomid)
        GameNet:send({cmd=CMD.READY_REQ,body = {start_type=paras.start_type,show_multi = paras.show_multi},callback=function( rsp )
            loga(">>>>>用户主动准备 rsp.ret=" .. rsp.ret)
            if rsp.ret ~= 0 then
                --准备了，但是没有效果，就重新进桌匹配，还是用之前的roomid
                if Cache.DDZDesk.enterRef == GAME_DDZ_CLASSIC then
                    if self.view then
                        self.view:checkGold({
                            roomid = roomid,
                            startType = paras.start_type,
                            showMulti = paras.show_multi
                        })
                    end
                end
            end
        end})
    end
    --先检测金币
    GameNet:send({cmd=CMD.CHECK_GOLD_LIMIT_REQ,body={room_id=Cache.DDZDesk.room_id},callback=function(rsp)
        -- loga("经典场金币检测 ret=" .. rsp.ret)
        local model = rsp.model
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
        if model then
            -- loga("经典场金币检测\n" .. pb.tostring(rsp.model))
            local id = model.room_id
            if model.flag == 1 then --金币太少了
                Cache.DDZDesk.startAgain = true
                qf.event:dispatchEvent(ET.MYSELF_QUIT_ROOM)
                qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function()
                    qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})--点击上报
                    qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
                end})

            elseif model.flag == 2 then --金币过多 去高级场
                if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
                    qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = string.format(DDZ_TXT.should_to_advanced_room, Cache.DDZconfig:getRoomConfigByRoomId(id).room_name), type = 2,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                        Cache.DDZDesk.room_id = id
                        qf.event:dispatchEvent(ET.CHANGE_TABLE)
                    end,cb_cancel = function ()
                        Cache.DDZDesk.startAgain = true
                        qf.event:dispatchEvent(ET.MYSELF_QUIT_ROOM)
                    end})
                end
            elseif model.flag == 0 then
                readyFun(Cache.DDZDesk.room_id)
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            end
        else
            if rsp.ret ~= 0 then
                Cache.DDZDesk.startAgain = true
                qf.event:dispatchEvent(ET.MYSELF_QUIT_ROOM)
                if rsp.ret == 1370 then
                    qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                        qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})--点击上报
                        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
                    end})
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]}) 
                end
            end
        end
    end})
end

--进桌
function GameController:enterRoom( rsp )
    -- 从前台进来，重新游戏音效   
    local isRestart = false
    if Cache.user.come_back == true then
        MusicPlayer:backgroundSineIn()
        Cache.user.come_back = false
        isRestart = true
    end
    
    if table.nums(Cache.DDZDesk._player_info) == 3 and Cache.user.old_roomid <= 0 then  
        Cache.DDZDesk:updateCacheByEnter(rsp.model)
        if self.view then
            for k,v in pairs(self.view._users)do
                v:updateAutoStatus()
                v:updateChipAndGold()
            end
        end
        if not self.view then return end
        self:MathingSuccess()
        self.view:enterRoom(rsp.model.uin, isRestart)
        if Cache.DDZDesk.op_left_time then 
            self:userHandleTurn({leftTime = Cache.DDZDesk.op_left_time})
        end
        return
    end
    PopupManager:removeAllPopup()
    qf.event:dispatchEvent(ET.CLEARLISTPOPUP)
    qf.event:dispatchEvent(ET.GAME_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
    qf.event:dispatchEvent(ET.RESET_TIMEOUT_COUNT)
    Cache.DDZDesk:updateCacheByEnter(rsp.model)

    if Cache.DDZDesk.enterRef == GAME_DDZ_MATCH then
        local updateMatchStatusFunc = function ()
            ModuleManager:get("game"):getView():setVisible(false)
            qf.event:dispatchEvent(ET.UPDATE_GAME_MATHING_VIEW,{
                firstEnterUser = Cache.DDZDesk.firstEnterUser,
                info=Cache.DDZDesk._player_info,
                time=Cache.DDZDesk.op_time_out, 
                cb=handler(self,self.MathingSuccess)
            })
        end

        --断线重连，这个还在匹配中
        if Cache.user.old_roomid > 0  then
            if table.nums(Cache.DDZDesk._player_info) < 3 and Cache.DDZDesk.round_index == 1 then
                Cache.globalInfo:setStatUploadTime(STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_WAIT_SUCC_TIME)
                qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "matching"})
                qf.event:dispatchEvent(ET.SHOW_GAME_MATHING_VIEW)
                updateMatchStatusFunc()
            else
                self:MathingSuccess()
            end
            Cache.user.old_roomid = 0
        else
            updateMatchStatusFunc()
        end
    end
    
    if not self.view then return end
    self.view:enterRoom(rsp.model.uin, isRestart)
    
    if Cache.DDZDesk.op_left_time then
        self:userHandleTurn({leftTime = Cache.DDZDesk.op_left_time})
    end
end

--操作信息通知
function GameController:opUserOperate( rsp )
    loga("通知玩家操作==>>>>>userId=" .. rsp.model.next_uin .. "   leftTime=" .. rsp.model.op_left_time .. " status=" .. rsp.model.status)
    Cache.DDZDesk:updateOpUserInfo(rsp.model)
    Cache.DDZDesk:updateCanCallDoubleInfo(rsp.model.next_uin2)
    if not self.view then return end
    self.view:userHandleTurn(0, rsp.model.op_left_time)
end

--用户托管状态更新
function GameController:updateUserAutoPlay( rsp )
    loga("玩家托管状态更新")
    Cache.DDZDesk:updateCacheByAuto(rsp.model)
    if not self.view then return end
    self.view:updateUserAutoPlay(rsp.model)
    --如果是自己取消了托管，而且又是该自己操作，那显示下操作按钮
    if rsp.model.uin == Cache.DDZDesk.next_uin and Cache.DDZDesk.next_uin == Cache.user.uin and rsp.model.auto == 0 then
        Cache.DDZDesk.op_uin = Cache.DDZDesk.next_uin
        self.view:userHandleTurn(0, Cache.DDZDesk.op_left_time - 0.5)
    end
end

--用户明牌通知
function GameController:userShowCard( rsp )
    loga("用户明牌通知\n" .. pb.tostring(rsp.model))
    Cache.DDZDesk:updateCacheByUserShowCard(rsp.model)
    if not self.view then return end
    self.view:userShowCard(rsp.model)--显示明牌
end

--叫分
function GameController:CallPoints( rsp )
    loga("用户叫分通知 GameController:CallPoints \n" .. pb.tostring(rsp.model))
    Cache.DDZDesk:updateCacheByCallPoints(rsp.model)
    if not self.view then return end
    self.view:showCallPoints(rsp.model) --叫分
    if Cache.DDZDesk.status ~= GameStatus.NONE then 
        if Cache.DDZDesk.status == GameStatus.INGAME then
            self:userHandleTurn({timer=1,leftTime = rsp.model.op_left_time})
        else
            self:userHandleTurn({leftTime = rsp.model.op_left_time})
        end
    end
end

--加倍
function GameController:CallDouble( rsp )
    loga("用户加倍通知 GameController:CallDouble")
    Cache.DDZDesk:updateCacheByCallDouble(rsp.model)
    if not self.view then return end
    self.view:showCallDouble(rsp.model)--显示加倍
    if Cache.DDZDesk.status == GameStatus.INGAME then
        local time = Cache.DDZDesk.enterRef == GAME_DDZ_CLASSIC and 3.0 or 3.0
        self:userHandleTurn({timer = time, leftTime = rsp.model.op_left_time - time})
    else
        self:userHandleTurn({leftTime = rsp.model.op_left_time})
    end
end

--用户自己主动退桌
function GameController:myselfQuitRoom()
    if not self.view then return end
    self.view:quitRoom(Cache.user.uin)
end

--退出房间
function GameController:quitRoom( paras )
    -- loga("----退出房间----GameController:quitRoom" .. pb.tostring(paras.model))
    --被房主踢出房间
    if paras.model.reason == GameExitReason.KICK then
        if paras.model.prompt and paras.model.prompt ~= "" then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = paras.model.prompt})
        end
        if not self.view then return end
        self.view:quitRoom(paras.model.op_uin)
    end

    --牌桌正常结束
    if paras.model.reason == GameExitReason.NORMAL then
        if not self.view then return end
        self.view:quitRoom(paras.model.op_uin)
    end

    --比赛场匹配超时退桌（虽然没啥用）
    if paras.model.reason == GameExitReason.MATCH_TIMEOUT then
        if not self.view then return end
        self.view:quitRoom(paras.model.op_uin)
    end

    --如果是超时
    if paras.model.reason == GameExitReason.TIMEOUT then
        --如果是经典场而且不是自己
        if paras.model.op_uin ~= Cache.user.uin and Cache.DDZDesk.enterRef == GAME_DDZ_CLASSIC then
            if not self.view then return end
            self.view:quitRoom(paras.model.op_uin)
        else
            for k,v in pairs(Cache.DDZDesk._player_info) do
                if k ~= Cache.user.uin then
                    if not self.view then return end
                    self.view:quitRoom(k)
                end
            end
        end
    end

    --赛事牌桌解散并退桌
    if paras.model.reason == GameExitReason.EVENT_OVER then
        return
    end

    if paras.model.op_uin == Cache.user.uin then
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide",txt=Util:getRandomMotto()})
    end

    Cache.DDZDesk:updateCacheByUserquit(paras.model)

    -- 这个是比赛场，更新匹配界面
    if Cache.DDZDesk.enterRef == GAME_DDZ_MATCH 
        and Cache.DDZDesk.status == GameStatus.READY 
        and Cache.DDZDesk.round_index ==1 
        and paras.model.op_uin ~= Cache.user.uin 
        and table.nums(Cache.DDZDesk._player_info) < 3 then
            Cache.globalInfo:setStatUploadTime(STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_WAIT_SUCC_TIME)
            qf.event:dispatchEvent(ET.UPDATE_GAME_MATHING_VIEW,{firstEnterUser = Cache.DDZDesk.firstEnterUser,info=Cache.DDZDesk._player_info,time=Cache.DDZDesk.op_time_out,cb=handler(self,self.MathingSuccess)})
    end
end 

--游戏开始
function GameController:gameStart( rsp )
    loga("游戏开始")
    Cache.DDZDesk:updateCacheByGamestart(rsp.model)
    if not self.view then return end
    self.view:gameStart(rsp.model)
    if Cache.DDZDesk.status ~= GameStatus.FAPAI then
        self:userHandleTurn({timer=2, leftTime = rsp.model.op_left_time})
    end
end

--要不起
function GameController:notFollowCards( rsp)
    loga("不要")
    Cache.DDZDesk:updateCacheByNotFollow(rsp.model)
    if not self.view then return end
    self.view:showNotFollowUin(rsp.model)
    self:userHandleTurn({leftTime = rsp.model.op_left_time})
end

--更新自己的游戏倍率
function GameController:deskMySelfBeiInfoUpdate(rsp)
    loga("桌子自己的倍率更新")
    Cache.DDZDesk:updateMySelfBeiInfo(rsp.model)
    if not self.view then return end
    self.view:updateMySelfBeiDetailInfo(rsp.model)
end

--同步人员金币信息到客户端
function GameController:deskUserFortuneInfoUpdate(rsp)
    loga("同步人员金币信息到客户端")
    Cache.DDZDesk:updateUserFortuneInfo(rsp.model)
    if not self.view then return end
    self.view:deskUserFortuneInfoUpdate(rsp.model)
end

--出牌
function GameController:outCards( rsp )
    loga("用户出牌")
    Cache.DDZDesk:updateCacheByOutCards(rsp.model)
    if not self.view then return end
    self.view:outCards(rsp.model)
    self:userHandleTurn({leftTime = rsp.model.op_left_time})
end

--聊天
function GameController:chat(paras)
    if not true then  return end
    if self.view == nil then return end
    logd("牌局内聊天信息: "..pb.tostring(paras.model))
    Cache.DDZDesk:updateCacheByChat(paras.model)
    self.view:chat(paras.model)
end

--比赛结束
function GameController:GameEnd( rsp )
    Cache.DDZDesk:updateCacheByGameover(rsp.model)
    if not self.view then return end

    PopupManager:removeAllPopup()
    if Cache.DDZDesk.enterRef == GAME_DDZ_MATCH then
        self.view:GameEnd(rsp.model)
    else
        self.view:NormalGameEnd(rsp.model)
    end
end

--到了该用户操作了
function GameController:userHandleTurn(paras)
    if self.view == nil then return end
    local timer = 0
    local leftTime = 0
    if paras and  paras.timer then
        timer = paras.timer
    end
    if paras and  paras.leftTime then
        leftTime = paras.leftTime
    end
    self.view:userHandleTurn(timer, leftTime) 
end

--金币更改
function GameController:processGameChangeGoldEvt(rsp)
    -- loga("金币更改通知\n" .. pb.tostring(rsp.model))
    -- if not Cache.DDZDesk._player_info or not Cache.DDZDesk._player_info[Cache.user.uin] then return end
    -- if rsp.model ~= nil then
    --     loga("金币更改:"..rsp.model.remain_amount)
    --     Cache.user.gold = rsp.model.remain_amount
    --     Cache.DDZDesk._player_info[Cache.user.uin].gold =  rsp.model.remain_amount
    -- end
    -- if self.view == nil then return end
    -- self.view:updateUserInfo()
end

--金币更改
function GameController:processGameChangeOtherGoldEvt(rsp)
    if not Cache.DDZDesk._player_info or not Cache.DDZDesk._player_info[rsp.model.uin] then return end
    if rsp.model == nil then
        Cache.DDZDesk._player_info[rsp.model.uin].gold =  rsp.gold
    elseif rsp.model ~= nil then
        Cache.DDZDesk._player_info[rsp.model.uin].gold =  rsp.model.gold
    end
    if self.view == nil then return end
    --self.view._users[rsp.model.uin]:updateChipAndGold()
end

--用户筹码更新
function GameController:handlerChipsChangedNtf( rsp )
    if not Cache.DDZDesk._player_info or not Cache.DDZDesk._player_info[rsp.model.uin] then return end
    if rsp.model == nil then
        Cache.DDZDesk._player_info[rsp.model.uin].chips =  rsp.chips
    elseif rsp.model ~= nil then
        Cache.DDZDesk._player_info[rsp.model.uin].chips =  rsp.model.chips
    end
    -- if self.view == nil then return end
    --self.view._users[rsp.model.uin]:updateChipAndGold()
end

--更新明牌时的倍数操作按钮
function GameController:updateShowCardCount(paras)
    if self.view == nil then return end
    self.view._users[Cache.user.uin]:updateShowCardBtnCount(paras)
end


function GameController:getUserByCache(uin)
    if self.view == nil then return nil ,nil end
    
    uin = uin or -1
    if uin == -1 then return nil,nil end
    local u = Cache.DDZDesk:getUserByUin(uin)
    if u == nil then return nil,nil end
    return self.view:getUser(uin),u

end

--切换背景声音
function GameController:updateBgMusic(  )
    if not self.view then return end
    if not self.musicLayer then 
        self.musicLayer = cc.Layer:create()
        self.view:addChild(self.musicLayer)
    end
    if Cache.DDZDesk.musicType == 1 then 
        MusicPlayer:playMusic(string.format(DDZ_Res.all_music.gameMusic,Cache.DDZDesk.musicType),true)
    elseif Cache.DDZDesk.musicType == 2 and  self.musicLayer.musicType~=3 then 
        if self.musicLayer.musicType ~= Cache.DDZDesk.musicType then
            MusicPlayer:playMusic(string.format(DDZ_Res.all_music.gameMusic,Cache.DDZDesk.musicType),true)
        end
        Cache.DDZDesk.musicType = 1 
        self.musicLayer:stopAllActions()
        self.musicLayer:runAction(cc.Sequence:create(cc.DelayTime:create(30),cc.CallFunc:create(function( ... )
            if Cache.DDZDesk.musicType == 1 then 
                MusicPlayer:playMusic(string.format(DDZ_Res.all_music.gameMusic,Cache.DDZDesk.musicType),true)
            end
        end)))
    elseif Cache.DDZDesk.musicType == 3 and self.musicLayer.musicType ~= Cache.DDZDesk.musicType then 
        MusicPlayer:playMusic(string.format(DDZ_Res.all_music.gameMusic,Cache.DDZDesk.musicType),true)
    end
    self.musicLayer.musicType = Cache.DDZDesk.musicType
end

--显示用户信息
function GameController:showUserInfo( paras )
    if self.view == nil then
        return
    end
    self.view:showUserInfo(paras)
end

-- 收到一条互动表情
function GameController:handleInteractPhiz( args )
    if not true then  return end
    loga("收到互动表情:"..pb.tostring(args.model))
    self.view:handleInteractPhiz(args.model)
end
return GameController
