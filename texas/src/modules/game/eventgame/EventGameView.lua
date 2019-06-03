
--[[
比赛场: View
--]]

local AbstractGameView = import("..AbstractGameView")
local EventGameView = class("EventGameView", AbstractGameView)
local GameAnimationConfig = import("..components.animation.AnimationConfig")
local EventGameEnd = import("..components.EventGameEnd")

EventGameView.TAG = "EventGameView"
function EventGameView:ctor( params )
    EventGameView.super.ctor(self, params)
    self.isshowGameInfo = false
end

function EventGameView:initUI( params )
	EventGameView.super.initUI(self, params)
	self.classicDeskInfo:setVisible(false)
    self.startP:setVisible(false)	
    self.newEndP:setVisible(false)
end

function EventGameView:initClick( params )
	EventGameView.super.initClick (self, params)
    --取消托管
    addButtonEventMusic(ccui.Helper:seekWidgetByName(self.tuoGuanP,"Button_tuo_guan"),DDZ_Res.all_music["BtnClick"],function( ... ) 
        GameNet:send({cmd = CMD.NEWEVENT_AUTO_PLAY_REQ,body={auto = 0},callback = function (rsp)
            if rsp.ret == 0 then
                Cache.DDZDesk._player_info[Cache.user.uin].isauto = nil
                self.tuoGuanP:setVisible(false)
                self:updateTuoguangDeskInfo()
            else
                loga("取消托管失败！ ret=" .. rsp.ret) 
            end
        end})
    end)	
    addButtonEventMusic(self.back,DDZ_Res.all_music["BtnClick"],function( ... )--下拉列表按钮
        self:quitRoomAction()
    end)

    --托管
    addButtonEventMusic(self.tuoGuanBtn,DDZ_Res.all_music["BtnClick"],function( ... )  
        GameNet:send({cmd=CMD.NEWEVENT_AUTO_PLAY_REQ,body={auto = 1},callback = function (rsp)
            if rsp.ret == 0 then
                Cache.DDZDesk._player_info[Cache.user.uin].isauto = true
                self:bankClicked()
                self.tuoGuanP:setVisible(true)
                --self.tuoGuanBtn:setVisible(false)
                self:updateTuoguangDeskInfo()
            else
                loga("托管失败！ ret=" .. rsp.ret)
            end
        end})
    end)

    -- -- 点击查看倍数信息
    -- addButtonEventMusic(self.btn_beishu,DDZ_Res.all_music["BtnClick"],function()
    --     if not self.beiDescLayer:isVisible() then
    --         GameNet:send({cmd=CMD.NEWEVENT_GET_DESK_MUTIINFO_REQ,callback= function(rsp)
    --             if rsp.ret == 0 then
    --                 Cache.DDZDesk:updateBeiInfo(rsp.model.multiple_info)
    --                 self:updateMySelfBeiDetailInfo(rsp.model.multiple_info)
    --                 self.beiDescLayer:setVisible(true)
    --             end
    --         end})
    --     else 
    --         self.beiDescLayer:setVisible(false)
    --     end
    -- end)
    
    --任务
    addButtonEventMusic(self.taskBtn,DDZ_Res.all_music["BtnClick"],function( ... )
        qf.event:dispatchEvent(ET.SHOW_REWARD_VIEW)
    end)
end

function EventGameView:resetForNewStart( ... )
	-- body
	EventGameView.super.resetForNewStart(self)
    self.startP:setVisible(false)
    self.newEndP:setVisible(false)
end

function EventGameView:quitRoomAction()
	EventGameView.super.quitRoomAction(self)
    if Cache.DDZDesk.status == GameStatus.READY then
        Cache.DDZDesk.startAgain = nil
        qf.event:dispatchEvent(ET.RE_QUIT)
    else
        if Cache.DDZDesk.status and Cache.DDZDesk.status > 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.quit_error})
        else
            --这种只有经典场才会出现  --不明确
            ModuleManager.EventGameController:remove()
            Cache.DDZDesk.startAgain = nil
            ModuleManager.DDZhall:show()
            return
        end
    end
    self.menuP:setVisible(false)
    qf.event:dispatchEvent(ET.REFRESH_LISTEN)
    if Cache.DDZDesk.enterRef == GAME_DDZ_CLASSIC then
       Cache.DDZDesk.startAgain = true
    end
end

--初始化牌桌信息
function EventGameView:initDeskDesc()
    EventGameView.super.initDeskDesc(self)
    self:initMatchGameDeskInfo()
end

--比赛场的桌子信息
function EventGameView:initMatchGameDeskInfo()
    ccui.Helper:seekWidgetByName(self.gui,"deskname"):setVisible(true)
    ccui.Helper:seekWidgetByName(self.gui,"deskname"):loadTexture(DDZ_Res.deskNameImg1,ccui.TextureResType.plistType)
    ccui.Helper:seekWidgetByName(self.gui, "desk_title"):setVisible(false)
end

--换桌按钮逻辑
function EventGameView:updateExchangeDeskInfo()
	EventGameView.super.updateExchangeDeskInfo(self)
end

--设置桌面信息(底分、倍数)
function EventGameView:setDeskInfo()
	local difenNum = Cache.DDZDesk:getCurrentDiFen()
    self.diFen:setString(difenNum)
end

-------------------proto协议信息处理------------------------------
function EventGameView:enterRoom(opuin, isReStart)
	EventGameView.super.enterRoom(self, opuin,isReStart)
    if opuin == Cache.user.uin or isReStart then
		self:updateTuoguangDeskInfo()
		self:setDeskInfo()
		self:initDeskDesc()
		-- self:initMenu()
	else

	end

	self:updateExchangeDeskInfo()
end

-- --更新托管按钮的显示和隐藏
-- function EventGameView:updateTuoguangDeskInfo()
--     EventGameView.super.updateTuoguangDeskInfo(self)
    
--     if  Cache.DDZDesk.status == GameStatus.INGAME and not Cache.DDZDesk._player_info[Cache.user.uin].isauto then
-- 		self.tuoGuanBtn:setVisible(true)
-- 	end
-- end

function EventGameView:userReady(model)
	EventGameView.super.userReady(self, model)
end

--游戏开始
function EventGameView:gameStart(model)
	EventGameView.super.gameStart(self, model)
	self:delayTimeRun(0.15, function ()
        self:showLastGameAni()
    end)
end

--抢地主/叫分阶段
function EventGameView:showCallPoints( info )
	EventGameView.super.showCallPoints(self, info)
	self:setDeskInfo()
end

--加倍阶段
function EventGameView:showCallDouble( info )
	EventGameView.super.showCallDouble(self, info)
end

--要不起显示
function EventGameView:showNotFollowUin( model )
    EventGameView.super.showNotFollowUin(self, model )
end

--玩家出牌
function EventGameView:outCards( model )
	EventGameView.super.outCards(self, model)
end

--显示本局结束
function EventGameView:oneGameEnd( model )
    self:initCardRecord()
    -- self:setDeskInfo()
    self.betNum:setString(Cache.DDZDesk.multipleInfo.multiple)
    Cache.DDZDesk.musicType = 1
    qf.event:dispatchEvent(ET.UPDATE_BG_MUSIC)
    self.endTime = 1
    local myTeamWinFlag = Cache.DDZDesk.mine_is_win
    -- if Cache.DDZDesk.win_type ~= 0 then
    --     self:delayTimeRun(self.endTime,function( ... )
    --         self:playSpringAni()
    --         end)
    --     self.endTime = self.endTime + 2.5
    --     -- self:delayTimeRun(self.endTime,function( ... )
    --     --     self:gameEndAni()
    --     --     self:clearDesk()
    --     --     Cache.DDZDesk.landlord_uin = nil
    --     -- end)
    -- end
    if Cache.DDZDesk.win_type ~= 0 then
        self:delayTimeRun(self.endTime,function( ... )
            self:playSpringAni()
        end)
    else
        self:delayTimeRun(self.endTime,function( ... )
            self:playNormalEndAni(Cache.DDZDesk.mine_is_win == true)
        end)
    end

    self.endTime = self.endTime + 2.5

    for k ,v in pairs(self._users)do
        v:changeHeadType(2)--头像变回去
        v:clearUserTips()
        v:hideDouble()
        v:updateScore()
        v:showLightCard()
        Cache.DDZDesk._player_info[k].isauto = nil
    end
    self:delayTimeRun(self.endTime,function( ... )
        self:gameEndAni()
        self:clearDesk()
        Cache.DDZDesk.landlord_uin = nil
    end)
    
    --当局结束，隐藏记牌器
    self._card_record:currentGameOver()  
end

--显示游戏结束窗口
function EventGameView:GameEnd( model )
    self._users[Cache.user.uin]:resetActionBtn()
    self:initCardRecord()

    if Cache.DDZDesk.is_abolish == 1 then return end

    --清理托管层
    self.tuoGuanP:setVisible(false)
    for k,v in pairs(self._users)do
        v:clearInGameEnd()
    end

    self.endTime = 0

    if Cache.DDZDesk.win_type ~= 0 then
        self:delayTimeRun(self.endTime,function( ... )
            self:playSpringAni()
        end)
    else
        self:delayTimeRun(self.endTime,function( ... )
            self:playNormalEndAni(Cache.DDZDesk.mine_is_win == true)
        end)
    end

    self.endTime = self.endTime + 2.5

    self:delayTimeRun(self.endTime,function( ... )
        if isValid(self) then
            self.eventGameEnd = PopupManager:push({class = EventGameEnd, show_cb = function() 
                local eventGameEndView = PopupManager:getPopupWindowByUid(self.eventGameEnd)
                if isValid(eventGameEndView) then
                    eventGameEndView:initAnimation()
                end
            end
            })
            PopupManager:pop()
        end
    end)
end

 --收到玩家退卓的消息
 function EventGameView:quitRoom(uin)
	EventGameView.super.quitRoom(self, uin)
end

-------------------proto协议信息处理---end---------------------------


--显示决胜局动画
function EventGameView:showLastGameAni()
    EventGameView.super.initAnimation(self)
    if Cache.DDZDesk.enterRef ~= GAME_DDZ_MATCH then return end
    if Cache.DDZDesk.round_index == Cache.DDZDesk.max_round then
        self.Gameanimation:play({anim=GameAnimationConfig.Ani_endGame,order=101})
    else
        local gameNumP = ccui.Helper:seekWidgetByName(self.gui,"gameNumP")
        gameNumP:setVisible(true)
        gameNumP:getChildByName("num"):setString(Cache.DDZDesk.round_index)
        gameNumP:stopAllActions()
        gameNumP:setScale(0.1)
        gameNumP:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1),cc.DelayTime:create(1),cc.Hide:create()))
    end
end

----------------延时加载的UI资源-----------------

function EventGameView:initCompontent()
    EventGameView.super.initCompontent(self)
    self.btn_beishu:setVisible(false)
	self:setDeskInfo()
end

-- 初始化菜单栏
function EventGameView:initMenu()
	local menuTable = {}    
    self.detailBtn = self.menuItem:clone()--详情按钮
    self.detailBtn:getChildByName("quit"):setBackGroundImage(DDZ_Res.menu_Detail,ccui.TextureResType.plistType)
    table.insert(menuTable,self.detailBtn)

    local lastBtn = menuTable[#menuTable]
    if lastBtn then
        lastBtn:getChildByName("line"):setVisible(false)
    end
    addButtonEventMusic(self.detailBtn,DDZ_Res.all_music["BtnClick"],function( ... )
        self:openGameRule()
        self.menuP:setVisible(false)
    end)

    self.menuP:setContentSize(cc.size(self.menuP:getContentSize().width,30+(#menuTable)*self.menuItem:getContentSize().height))
    self.menuP:setPositionY(Display.cy-5-self.menuP:getContentSize().height)
    local y=self.menuP:getContentSize().height-15
    for k,v in pairs(menuTable)do
        self.menuP:addChild(v)
        y=y-self.menuItem:getContentSize().height
        v:setPosition(14,y)
    end
end

--结算后清理牌桌 去除弹窗
function EventGameView:clearDesk()
    EventGameView.super.clearDesk(self)

    PopupManager:removeAllPopup()
end

----------------延时加载的UI资源---end--------------

function EventGameView:showMultiAction(  )
    
end

return EventGameView