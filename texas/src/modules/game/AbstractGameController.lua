
--[[
牌桌基类：Controller

打开游戏内，直接使用ModuleManager:show
--]]


local AbstractGameController = class("AbstractGameController", qf.controller)

local AbstractGameView = import(".AbstractGameView")
local Card = import(".components.card.Card")

AbstractGameController.TAG = "AbstractGameController"
function AbstractGameController:ctor( params )
    AbstractGameController.super.ctor(self, params)

    self:init(params)
end

--override
function AbstractGameController:init( params )
end

function AbstractGameController:createDeskCache()
    --子类实现
end

--override
function AbstractGameController:initView( params )
end

function AbstractGameController:remove( )
    AbstractGameController.super.remove(self)
    Cache.DDZDesk:clear()
    Cache.DeskAssemble:clearGameType()
    Card.clearPool()
end

function AbstractGameController:show( params )
    AbstractGameController.super.show(self, params)
    PopupManager:clean() --展示游戏界面后清除弹窗列表
    self:createDeskCache()
end

function AbstractGameController:initGlobalEvent( ... )
end

function AbstractGameController:initModuleEvent( ... )
    --更换背景音乐
    self:addModuleEvent(ET.UPDATE_BG_MUSIC, handler(self, self.updateBgMusic))
    --打开用户信息弹窗
    self:addModuleEvent(ET.GAME_SHOW_USER_INFO, handler(self, self.showUserInfo))
    --互动表情通知
    self:addModuleEvent(ET.INTERACT_PHIZ_NTF, handler(self, self.handleInteractPhiz))
    --聊天信息通知
    self:addModuleEvent(ET.NET_CHAT_NOTICE_EVT, handler(self, self.handlerChat))
    --金币变化通知
    self:addModuleEvent(ET.GOLD_CHANGE_RSP_Game, handler(self, self.updateGold))
    --奖券变化通知
    self:addModuleEvent(ET.EVT_USER_FOCARD_CHANGE_GAMEVIEW, handler(self, self.updateFocard))
    --发送互动表情
    self:addModuleEvent(ET.PLAY_INTERACT_ANIMATION, handler(self, self.playInteractAnimation))
    ---------------牌桌操作通知---------------
    --进桌通知
    self:addModuleEvent(ET.ENTER_ROOM, handler(self, self.enterRoomNotify))
    --玩家准备通知
    self:addModuleEvent(ET.USER_READY, handler(self, self.userReadyNotify))
    --游戏开始通知
    self:addModuleEvent(ET.GAME_START, handler(self, self.startGameNotify))
    --游戏结束通知
    self:addModuleEvent(ET.GAME_END, handler(self, self.gameEndNotify))
    --玩家叫分/抢地主通知
    self:addModuleEvent(ET.CALL_POINTS, handler(self, self.callPointsNotify))
    --玩家加倍通知
    self:addModuleEvent(ET.CALL_DOUBLE, handler(self, self.callDoubleNotify))
    --玩家明牌通知
    self:addModuleEvent(ET.LIGHT_CARD, handler(self, self.showCardNotify))
    --玩家出牌通知
    self:addModuleEvent(ET.OUT_CARDS_NTF, handler(self, self.outCardsNotify))
    --玩家退桌通知
    self:addModuleEvent(ET.QUIT_ROOM, handler(self, self.quitTableNotify))
    --玩家抢地主操作通知
    self:addModuleEvent(ET.OPUSER_NOTIFY, handler(self, self.OpUserNotify))
    --倍数更新通知
    self:addModuleEvent(ET.DESK_MULTI_CHANGE_NOTIFY, handler(self, self.deskMulitChangeNotify))
    --同步人员金币信息通知
    self:addModuleEvent(ET.GAME_SYN_FORTUNE_INFO, handler(self, self.updateUserFortuneInfoNotify))
    --托管状态更新通知
    self:addModuleEvent(ET.USER_AUTO_PLAY, handler(self, self.updateUserAutoPlayNotify))
    --------------End------------------------
    ----------------牌桌请求------------------
    
    -----------------End---------------------
    --------------牌局事件--------------------
    --自身退桌事件
    self:addModuleEvent(ET.MYSELF_QUIT_ROOM, handler(self, self.myselfQuitRoomEvent))
    --用户操作事件
    self:addModuleEvent(ET.USER_HANDLE_TURN, handler(self, self.userHandleTurnEvent))
    --明牌按钮倍数变化事件
    self:addModuleEvent(ET.CARD_SHOW_TIME_EVENT, handler(self, self.updateShowCardBtnCountEvent))
    --出牌提示事件
    self:addModuleEvent(ET.SHOW_OUTCARDS_TIPS, handler(self, self.showOutCardsTipsEvent))
    --显示托管层事件
    self:addModuleEvent(ET.SHOW_AUTO_PLAYER, handler(self, self.showAutoPlayerEvent))
    --更新玩家金币
    self:addModuleEvent(ET.UPDATE_USER_GOLD, handler(self, self.updateUsersGold))
    --弹出退出提示
    self:addModuleEvent(ET.SHOW_GAME_EXIT_VIEW, handler(self, self.showGameExit))
    --------------End------------------------
end

--查询牌桌
function AbstractGameController:queryDesk(paras)
    paras = paras or {}
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method = "show"})

    GameNet:send({
        cmd = self.queryDeskCMD,
        body = {},
        callback = function (rsp)
            if rsp.ret == 0 then
                --进桌
            elseif rsp.ret == NET_WORK_ERROR.TIMEOUT then
                Util.delayRun(0.5, function()
                    self:queryDesk(paras)
                end)
                return
            else
                self:quitTable()
            end
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT, {method = "hide"})
        end
    })
end

--前后台切换
function AbstractGameController:processApplicationMessageInGame(paras)
    if not isValid(self.view) then return end

    if paras.type == "show" then
        if GameNet:isConnected() then
            self:queryDesk()
        end
    elseif paras.type == "hide" then

    end
end

--退出牌桌
function AbstractGameController:quitTable()
    if not isValid(self.view) then return end

    self:remove()
    ModuleManager.gamehall:show({stopEffect = true})
    ModuleManager.DDZhall:show()
end

---------------------牌桌功能----start-------------------------

--更换背景音乐
function AbstractGameController:updateBgMusic()
    if not isValid(self.view) then return end

    --当前只有type：1, 3 情况
    if Cache.DDZDesk.musicType ~= nil then
        MusicPlayer:playMusic(string.format(DDZ_Res.all_music.gameMusic,Cache.DDZDesk.musicType),true)
    end
end

--打开用户信息弹窗
function AbstractGameController:showUserInfo(paras)
    if not isValid(self.view) then return end
    if not paras then return end

    self.view:showUserInfo(paras)
end

--接受到互动表情
function AbstractGameController:handleInteractPhiz(rsp)
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end
    loga("接受到互动表情")
    self.view:interactPhizAnimation(rsp.model)
end

--聊天通知
function AbstractGameController:handlerChat(rsp)
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    Cache.DDZDesk:updateCacheByChat(rsp.model)
    self.view:chat(rsp.model)
end

--金币变化通知
function AbstractGameController:updateGold(paras)
    if not isValid(self.view) then return end

    self.view:updateUserInfo(paras.rsp)

    qf.event:dispatchEvent(ET.REFRESH_MYSELF_GOLD)
end

--奖券变化通知
function AbstractGameController:updateFocard(rsp)
    if not isValid(self.view) then return end

    if rsp.model and rsp.model.remain_amount then 
        Cache.user.fucard_num = rsp.model.remain_amount
    end

    self.view:updateUserInfo(rsp.model)
end

---------------------牌桌功能----end--------------------------

function AbstractGameController:enterRoomNotify(rsp)
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end
    Cache.DDZDesk:updateCacheByEnter(rsp.model)
    self.view:enterRoom(rsp.model.uin)

    if Cache.DDZDesk.op_left_time then 
        qf.event:dispatchEvent(ET.USER_HANDLE_TURN, {timer = 1,leftTime = Cache.DDZDesk.op_left_time})
    end

    if Cache.user.come_back == true then
        MusicPlayer:backgroundSineIn()
        Cache.user.come_back = false
    end
end

function AbstractGameController:userReadyNotify(rsp)
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    if Cache.DDZDesk._player_info[rsp.model.uin] then
        Cache.DDZDesk._player_info[rsp.model.uin].status = UserStatus.USER_STATE_READY
    end

    self.view:userReady(rsp.model)
end

function AbstractGameController:startGameNotify(rsp)
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    Cache.DDZDesk:updateCacheByGamestart(rsp.model)

    self.view:gameStart(rsp.model)
    
    if Cache.DDZDesk.status ~= GameStatus.FAPAI then
        qf.event:dispatchEvent(ET.USER_HANDLE_TURN,{timer = 2, leftTime = rsp.model.op_left_time})
    end
end

function AbstractGameController:gameEndNotify(rsp)
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    --进入结算 移除其他弹窗，弹出结算弹窗
    PopupManager:removeAllPopup()
    Cache.DDZDesk:updateCacheByGameover(rsp.model)

    self.view:GameEnd(rsp.model)
end

function AbstractGameController:callPointsNotify(rsp)
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    Cache.DDZDesk:updateCacheByCallPoints(rsp.model)
    self.view:showCallPoints(rsp.model)

    if Cache.DDZDesk.status ~= GameStatus.NONE then 
        if Cache.DDZDesk.status == GameStatus.INGAME then
            qf.event:dispatchEvent(ET.USER_HANDLE_TURN,{timer = 1, leftTime = rsp.model.op_left_time})
        else
            qf.event:dispatchEvent(ET.USER_HANDLE_TURN,{leftTime = rsp.model.op_left_time})
        end
    end
end

function AbstractGameController:callDoubleNotify( rsp )
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    Cache.DDZDesk:updateCacheByCallDouble(rsp.model)
    self.view:showCallDouble(rsp.model)

    local timer = nil
    if Cache.DDZDesk.status == GameStatus.INGAME then
        timer = 3
    end

    qf.event:dispatchEvent(ET.USER_HANDLE_TURN,{timer = timer, leftTime = rsp.model.op_left_time})
end

function AbstractGameController:showCardNotify( rsp )
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    Cache.DDZDesk:updateCacheByUserShowCard(rsp.model)
    self.view:userShowCard(rsp.model)
end

function AbstractGameController:outCardsNotify( rsp )
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    Cache.DDZDesk:updateCacheByOutCards(rsp.model)
    self.view:outCards(rsp.model)
    qf.event:dispatchEvent(ET.USER_HANDLE_TURN,{leftTime = rsp.model.op_left_time})
end

function AbstractGameController:quitTableNotify( rsp )
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end
    if rsp.model.reason == GameExitReason.KICK then
        if rsp.model.prompt and rsp.model.prompt ~= "" then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = rsp.model.prompt})
        end
    end
end

function AbstractGameController:OpUserNotify( rsp )
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    Cache.DDZDesk:updateOpUserInfo(rsp.model)
    Cache.DDZDesk:updateCanCallDoubleInfo(rsp.model.next_uin2)

    qf.event:dispatchEvent(ET.USER_HANDLE_TURN,{timer = 0, leftTime = rsp.model.op_left_time})
end

function AbstractGameController:deskMulitChangeNotify( rsp )
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    Cache.DDZDesk:updateMySelfBeiInfo(rsp.model)
    self.view:updateMySelfBeiDetailInfo(rsp.model)
end

function AbstractGameController:updateUserFortuneInfoNotify( rsp )
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    Cache.DDZDesk:updateUserFortuneInfo(rsp.model)
    self.view:deskUserFortuneInfoUpdate(rsp.model)
end

function AbstractGameController:updateUserAutoPlayNotify( rsp )
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    Cache.DDZDesk:updateCacheByAuto(rsp.model)
    self.view:updateUserAutoPlay(rsp.model)

    if rsp.model.uin == Cache.DDZDesk.next_uin and Cache.DDZDesk.next_uin == Cache.user.uin and rsp.model.auto == 0 then
        Cache.DDZDesk.op_uin = Cache.DDZDesk.next_uin

        qf.event:dispatchEvent(ET.USER_HANDLE_TURN,{timer = 0, leftTime = Cache.DDZDesk.op_left_time - 0.5})
    end
end

function AbstractGameController:myselfQuitRoomEvent(  )
    if not isValid(self.view) then return end

    self.view:quitRoom(Cache.user.uin)
end

function AbstractGameController:userHandleTurnEvent( paras )
    if not isValid(self.view) then return end

    paras = paras or {}
    paras.timer = paras.timer or 0
    paras.leftTime = paras.leftTime or 0

    self.view:userHandleTurn(paras.timer, paras.leftTime)
end

function AbstractGameController:updateShowCardBtnCountEvent( paras )
    if not isValid(self.view) then return end

    if not Cache.DDZDesk.can_showCard then return end

    local user = self.view._users[Cache.user.uin]
    if isValid(user) then
        user:updateShowCardBtnCount(paras)
    end
end

function AbstractGameController:showOutCardsTipsEvent( paras )
    if not isValid(self.view) then return end

    self.view:showOutCardsTips(paras)
end

function AbstractGameController:showAutoPlayerEvent( paras )
    if not isValid(self.view) then return end

    self.view:showAutoPlayer(paras.isshow)
end

function AbstractGameController:updateUsersGold()
    if not isValid(self.view) then return end

    self.view:updateUserGold()
end

---------匹配成功----
function AbstractGameController:MathingSuccess()
    ModuleManager.gameshall:remove()
    --淡入背景音乐 播放开始音效
    MusicPlayer:setBgMusic(string.format(DDZ_Res.all_music.gameMusic,1))
    MusicPlayer:backgroundSineIn()
    DDZ_Sound:playSoundGame(DDZ_Sound.GameStart)
    local instance = Cache.globalInfo:getStatUploadTime(STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_WAIT_SUCC_TIME)
    if instance then
        qf.platform:uploadEventStat({   --各场次匹配成功时长
            module = "performance",
            source = "pywxddz",
            event = STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_WAIT_SUCC_TIME,
            value = instance,
            custom = Cache.DDZDesk.room_id
        })
    end
end

function AbstractGameController:showGameExit(paras)
    self.view:showGameExit(paras)
end

function AbstractGameController:playInteractAnimation(paras)
    self.view:playInteractAnimation(paras)
end

function AbstractGameController:removeModuleEvent()
    qf.event:removeEvent(ET.UPDATE_BG_MUSIC)
    qf.event:removeEvent(ET.GAME_SHOW_USER_INFO)
    qf.event:removeEvent(ET.INTERACT_PHIZ_NTF)
    qf.event:removeEvent(ET.NET_CHAT_NOTICE_EVT)
    qf.event:removeEvent(ET.GOLD_CHANGE_RSP_Game)
    qf.event:removeEvent(ET.EVT_USER_FOCARD_CHANGE_GAMEVIEW)
    qf.event:removeEvent(ET.ENTER_ROOM)
    qf.event:removeEvent(ET.USER_READY)
    qf.event:removeEvent(ET.GAME_START)
    qf.event:removeEvent(ET.GAME_END)
    qf.event:removeEvent(ET.CALL_POINTS)
    qf.event:removeEvent(ET.CALL_DOUBLE)
    qf.event:removeEvent(ET.LIGHT_CARD)
    qf.event:removeEvent(ET.OUT_CARDS_NTF)
    qf.event:removeEvent(ET.QUIT_ROOM)
    qf.event:removeEvent(ET.OPUSER_NOTIFY)
    qf.event:removeEvent(ET.DESK_MULTI_CHANGE_NOTIFY)
    qf.event:removeEvent(ET.GAME_SYN_FORTUNE_INFO)
    qf.event:removeEvent(ET.USER_AUTO_PLAY)
    qf.event:removeEvent(ET.MYSELF_QUIT_ROOM)
    qf.event:removeEvent(ET.USER_HANDLE_TURN)
    qf.event:removeEvent(ET.CARD_SHOW_TIME_EVENT)
    qf.event:removeEvent(ET.SHOW_OUTCARDS_TIPS)
    qf.event:removeEvent(ET.SHOW_AUTO_PLAYER)
    qf.event:removeEvent(ET.UPDATE_USER_GOLD)
    qf.event:removeEvent(ET.SHOW_GAME_EXIT_VIEW)
end

return AbstractGameController