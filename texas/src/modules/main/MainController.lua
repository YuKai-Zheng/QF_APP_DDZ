
local MainController = class("MainController",qf.controller)

MainController.TAG = "MainController"
local acitivityView = import(".MainView")

MainController.isfirstEnter=true

function MainController:ctor(parameters)
    MainController.super.ctor(self)
end
function MainController:show(paras)
    MainController.super.show(self)
    --进入大厅移除全部弹窗
    PopupManager:removeAllPopup()
    Cache.user.loginFinish = true
    self._popup_record = {}
    MusicPlayer:playBackGround() 
    qf.event:dispatchEvent(ET.BG_CLOSE)
    qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{uin=Cache.user.uin,wait=true,txt=GameTxt.main001,callback=handler(self,self.updateUserInfo)})
    
    qf.event:dispatchEvent(ET.MODULE_SHOW,"gameshall")
    qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="activity",number=Cache.Config.FinishActivityNum or 0,addNumber=Cache.Config.RecieveAwardNum or 0})

    qf.platform:feedBackUnreadRequst()

    self.view:updateUserInfo()
    self.view:updateUserHead()
    self:noAddNewPopup()
    self:updateFreeGoldShortCutPoint()
end 

function MainController:noAddNewPopup()
    local updateShortCutPoint=function ( ... )
        self:updateFreeGoldShortCutPoint()
    end
    self.view:setTouch(true)
    -- 大厅自动弹出
    loga("大厅自动弹出")
    if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW and Cache.user:getLoginTipPopValue() then
        Util:delayRun(1.5,function ( ... )
            if not self.view then return end
            self.view:setTouch(true)

            local popEvents = {}

            --第一次游戏
            if Cache.user.app_new_user_reg_gift_click_status == 1 then
                Cache.user.app_new_user_mathing_accept = 1
                table.insert( popEvents, { popEvent = {event = ET.SHOW_FIRSTGAME, show_type = 1} , priority = 6} )
            end

            if not Cache.user.show then
                --大转盘
                if Cache.user.show_lucky_wheel_or_not == 0 and Cache.user.IsRightTime==0 and not Cache.user.show then
                    table.insert( popEvents, { popEvent = {event = ET.SHOW_TURNTABLE, show_type = 1} , priority = 4} )
                end
                --每日登陆
                table.insert( popEvents, { popEvent = {event = ET.EVENT_LOGIN_REWARD_GET, show_type = 1}, priority = 3} )
            
                if #Cache.Config.banner_link_list > 0 then
                    table.insert( popEvents, { popEvent = {event = ET.SHOW_BANNER_POP, show_type = 1} , priority = 2} )
                end
                    
                -- 新手不弹
                if Cache.user.hasShowActivity == 0 and Cache.user.is_new_reg_user ~= 1 then
                    qf.event:dispatchEvent(ET.SHOW_ACTIVE_NOTICE)
                end

                -- 活动在新手之后弹出
                if Cache.user.is_new_reg_user == 1 then
                    Cache.user.is_new_reg_user=0
                end

                
            end

            if Cache.user.app_new_user_play_task.status == 2 then
                table.insert( popEvents, { popEvent = {event = ET.SHOW_RED_PACKAGE, show_type = 1} , priority = 5} )
            end

            if Cache.user.newBankruptInfo and Cache.user.newBankruptInfo.hasRecieveBankruptMessage ==true  then
                qf.event:dispatchEvent(ET.ADDLISTPOPUP, {id=ET.DDZBANKRUPTPTOTECTSHOW, priority = 1})
            end

            table.sort( popEvents, function ( a, b )
                return a.priority < b.priority
            end )

            dump(popEvents)

            for i = 1, #popEvents do
                local uid = PopupManager:push(popEvents[i].popEvent, 1)
            end

            --暂时取消活动自动弹出，等待修改为弹窗
            if not Cache.user.show then
                --PopupManager:push({event = ET.CHECK_ACTIVITY_SHOW, show_type = 1})
            end

            if Cache.user:getLoginTipPopValue() then
                if ModuleManager:getTopModuleName() == "gameshall" then
                    PopupManager:pop()
                    Cache.user.show = 1
                end
            end
        end)
    end
end

function MainController:showDailyReward()
    qf.event:dispatchEvent(ET.EVENT_NEWUSER_LOGIN_REWARD_GET,{cb = function ()
        if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW and Cache.user.dailyRewardConfInfo.currentObtained and Cache.user.isNeedShowActivityPop == 1 then
            qf.event:dispatchEvent(ET.SHOW_ACTIVE_VIEW)
            Cache.user.isNeedShowActivityPop = 0
        end
    end}) 
end

function MainController:initModuleEvent()
    self:addModuleEvent(ET.MAIN_UPDATE_BNT_NUMBER,handler(self,self.updateBntNumber))
    self:addModuleEvent(ET.HALL_UPDATE_INFO,handler(self,self.update))
    self:addModuleEvent(ET.NET_CHANGEGOLD_EVT,handler(self,self.processGameChangeGoldEvt))
    self:addModuleEvent(ET.MAIN_UPDATE_USER_HEAD,handler(self,self.MAIN_UPDATE_USER_HEAD))
    self:addModuleEvent(ET.UPDATETURNICON,handler(self,self.updateTURNICON))--重置大转盘
    self:addModuleEvent(ET.UPDATENEWTOTALLOGINICON,handler(self,self.updateNEWTOTALLOGINICON))--重置累计登陆
    self:addModuleEvent(ET.MAIN_UPDATE_SHORTCUT_NUMBER,handler(self,self.updateFreeGoldShortCutPoint))

    --奖券变化通知
    qf.event:addEvent(ET.EVT_USER_FOCARD_CHANGE_MAINVIEW,function(rsp)
        loga("奖券变化通知EVT_USER_FOCARD_CHANGE_MAINVIEW"..rsp.model.remain_amount)
        if rsp.model and rsp.model.remain_amount then 
            Cache.user.fucard_num = rsp.model.remain_amount
        end
        -- Cache.user.fucard_num = rsp.model.fucard
        if self.view then
            self.view:updateUserInfo()
        end
    end)

    qf.event:addEvent(ET.EVENT_CLOSE_FOCAS_CENTER_TO_MATHINGE_CENTER,function(params)
        qf.event:dispatchEvent(ET.EVENT_BANNER_GAME_MATCHING,{})
    end)

    qf.event:addEvent(ET.EVENT_CLOSE_FOCAS_CENTER_TO_ACTIVE_CENTER,function(params)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅活动") end
        qf.event:dispatchEvent(ET.SHOW_ACTIVE_VIEW)
        qf.platform:umengStatistics({umeng_key = "Activity"})--点击上报
    end)
    
    qf.event:addEvent(ET.CHANGEREFUSE,function ( ... )
        if self.view then 
            self.view:calulateAcceptRimes()
        end
    end)

    qf.event:addEvent(ET.ACCEPTINVITE,function ( ... )
        if self.view then 
            self.view:acceptInviteGame()
        end
    end)

    qf.event:addEvent(ET.REMOVETIMEOUT,function ( ... )
        if self.view then
            self.view:removeTimeCount()
        end
    end)

    
    qf.event:addEvent(ET.HIDE_FIRSTRECHARGE_ENTRY,function ( ... )
        if self.view then
            self.view:removefirstRechargeEntry()
        end
    end)  

    qf.event:addEvent(ET.CHECK_ACTIVITY_SHOW, handler(self, self.showDailyReward))
    qf.event:addEvent(ET.ICON_FRAME_CHANGE_NOT,function ( ... )
        if self.view then
            self.view:updateUserHead()
        end
    end) 

     --等级变化通知
     qf.event:addEvent(ET.NOT_MAINVIEW_LEVEL_CHANGE,function()
        if isValid(self.view)  then
            self.view:updateUserInfo()
        end      
    end)
end

function MainController:removeModuleEvent()
    qf.event:removeEvent(ET.MAIN_UPDATE_BNT_NUMBER)
    qf.event:removeEvent(ET.HALL_UPDATE_INFO)
    qf.event:removeEvent(ET.MAIN_UPDATE_USER_HEAD)
    qf.event:removeEvent(ET.UPDATETURNICON)
    qf.event:removeEvent(ET.UPDATENEWTOTALLOGINICON)
    qf.event:removeEvent(ET.MAIN_UPDATE_SHORTCUT_NUMBER)
    qf.event:removeEvent(ET.EVT_USER_FOCARD_CHANGE_MAINVIEW)
    qf.event:removeEvent(ET.CHANGEREFUSE)
    qf.event:removeEvent(ET.ACCEPTINVITE)
    qf.event:removeEvent(ET.EVENT_CLOSE_FOCAS_CENTER_TO_MATHINGE_CENTER)
    qf.event:removeEvent(ET.EVENT_CLOSE_FOCAS_CENTER_TO_ACTIVE_CENTER) 
    qf.event:removeEvent(ET.ICON_FRAME_CHANGE_NOT)
    qf.event:removeEvent(ET.NOT_MAINVIEW_LEVEL_CHANGE)
end

function MainController:showReturnHallAni( ... )
    self.view:showAnimation()
    Cache.user:updateLoginTipPopValue(true)
    self:noAddNewPopup()
end

function MainController:updateTURNICON()--重置大转盘
    -- body
    self.view:TurnTableIconShow()
end

--t头像更新
function MainController:MAIN_UPDATE_USER_HEAD( )
    -- body
    self.view:updateUserHead()
end

--金币更改
function MainController:processGameChangeGoldEvt(rsp)
    if rsp.model and rsp.model.remain_amount then
        Cache.user.gold = rsp.model.remain_amount
    end
    self:updateFreeGoldShortCutPoint()
    qf.event:dispatchEvent(ET.HALL_UPDATE_INFO )

end

function MainController:update()
    self.view:updateUserInfo()
    self.view:updateUserHead()
end

function MainController:removeModuleEvent()
    PopupManager:removeAllPopup()
end

-- 这里注册与服务器相关的的事件，不销毁
function MainController:initGlobalEvent()
    qf.event:addEvent(ET.NET_GET_NICK_REMARK_LIST,handler(self,self.saveRemarkList))

    qf.event:addEvent(ET.MAIN_BUTTON_CLICK,handler(self,self.bntPressHandler))  -- 慎用 外部弹窗不应与mainview绑定 请改用PopupWindow
    qf.event:addEvent(ET.MAIN_MOUDLE_VIEW_EXIT,handler(self,self.moduleViewExit))
    qf.event:addEvent(ET.SETTING_QUICK_START_CHOOSE_CHANGE,handler(self,self.quickStartChooseChange))
    qf.event:addEvent(ET.REFRESH_LISTEN,handler(self,self.listenEventAction))
    
    qf.event:addEvent(ET.NET_USER_INFO_REQ,function(paras)
        if paras == nil or paras.uin == nil then return end
        GameNet:send({cmd=CMD.USER_INFO,body={other_uin=paras.uin},
            wait=paras.wait,txt=paras.txt,
            callback=function(rsp)
                if rsp.ret ~= 0 then return end
                local is_change_head = false
                if rsp.model then
                    if rsp.model.portrait ~= Cache.user.portrait and paras.uin == Cache.user.uin then
                        is_change_head = true
                    end
                end
                
                Cache.user:updateCacheByUseInfo(rsp.model,paras.uin)

                if is_change_head then
                    qf.event:dispatchEvent(ET.MAIN_UPDATE_USER_HEAD)
                end
                -- qf.event:dispatchEvent(ET.UPDATE_VIEW_GIFT_CARD)--更新礼物界面礼物卡余额显示
                if(paras.callback) then paras.callback(rsp.model) end
        end})
    end)


     qf.event:addEvent(ET.BG_CLOSE,handler(self,function ()
         -- body
         if self.view then
             local bg = self.view:getChildByName("mohubg")
             if bg then
                bg:removeFromParent()
             end
        end

     end))

     qf.event:addEvent(ET.UPDATE_USER_INFO,handler(self,function ()
        -- body
        if self.view then
            self.view:updateUserInfo()
        end
     end))

     qf.event:addEvent(ET.UPDATE_TUIGUANG_QIPAO, function (  )
         if self.view then
            self.view:updateTuiGuangQiPao()
         end
     end)

     qf.event:addEvent(ET.EVENT_BANNER_GAME_MATCHING,function(params)
        Util:delayRun(0.2, function (...)
            qf.event:dispatchEvent(ET.SHOW_MATCHHALL_VIEW)
            ModuleManager:removeExistViewWithOut("matching")
        end)
    end)

    qf.event:addEvent(ET.EVENT_JUMP_TO_COIN_GAME,function(params)
        if self.view then
            Util:delayRun(0.2, function (...)
                self.view:classicGameClicked()
                ModuleManager:removeExistViewWithOut("DDZhall")
            end)
        else
            ModuleManager.DDZhall:getView():show()
        end
    end)
end

function MainController:moduleViewExit(paras) 
    if paras == nil and paras.name == nil then return end
    local m = ModuleManager[paras.name]
    local v = m:getView()
    local winSize = cc.Director:getInstance():getWinSize()
    qf.event:dispatchEvent(ET.BG_CLOSE)
    self:listenEventAction()
    
    if paras.from ~= "main" or paras.full == true  then     --满屏窗口收向右边
          v:runAction(cc.Sequence:create(
            --cc.MoveBy:create(0.3,cc.p(winSize.width,0)),
            cc.FadeTo:create(0.3,0),
            cc.CallFunc:create(function ( sender )
                --qf.event:dispatchEvent(ET.MAIN_VIEW_SHOW_ANIMATION)
                m:remove()
            end)))
        return 
    end
    if paras.name == "setting" or paras.name == "prize" then
        m:remove()
    end

    if self.view == nil then return end
    -- local p = cc.p(self.view.bnt[paras.name]:getPosition())
    local p = cc.p(0,0)
    self:moduleExitAnimation(v,p,m)
end

function MainController:updateFreeGoldShortCutPoint()--更新免费领金币快捷方式小红点
    -- body
    local function _refreshTime()
        self.remain = self.remain - 1
        if self.remain <= 0 and self.action then
            self:updateFreeGoldShortCutPoint()
            Scheduler:unschedule(self.action)
            self.action=nil
        end
    end
    GameNet:send({ cmd = CMD.GET_DAY_LOGIN_REWARD_CFG,
    callback= function(rsp)
        if rsp.ret ~= 0 then
        else
            local canget=0  
            -- local recharge_status =rsp.model.free_gold_task_list:get(1).status--首冲判定
            -- if recharge_status==1 then 
            --     canget=canget+1 
            -- end

            local is_all_send =rsp.model.is_all_send--破产判定
            self.remain =rsp.model.remain

            if is_all_send ~= 1 and self.remain < 1 and Cache.user.gold < Cache.Config.bankrupt_money then
                canget=canget+1 
            elseif self.remain >=1 then
                if self.action==nil then 
                    self.action = Scheduler:scheduler(1, _refreshTime)
                end
            end

            local got_day_reward =rsp.model.got_day_reward--每日签到判定
            if got_day_reward==0 then 
                canget=canget+1 
            end

            if Cache.user.show_lucky_wheel_or_not == 0 and Cache.user.IsRightTime==0  and Cache.user.lucky_wheel_play_times > 0 then 
                canget=canget+1 
            end--大转盘判定

            if canget~=0 then 
                self:updateBntNumber({name="fuli",number=canget})
            else
                self:updateBntNumber({name="fuli",number=0})
            end
        end

    end})
end


function MainController:bntPressHandler(paras)
    if paras == nil and paras.name == nil then return end
    local popTable = {
        setting= "window",
        rank= "window",
        friend= "window",
        activity= "window",
        popularize= "window",
        prize= "window",
        shop= "window",
        laba="window",
        focas = "window",
        exchange = "window",
        matching = "window",
        focaTask = "window"
    }
    -- 用户点击了大厅的事件
    self:removeListenEvent()

    if paras.name == "shop" then
        dump(paras)
        qf.event:dispatchEvent(ET.OPEN_SHOP_VIEW, paras)
        return
    end

    if popTable[paras.name] ~= nil then 
        self:commonEvent({name=paras.name,type=popTable[paras.name],delay = paras.delay,cb = paras.cb, bookmark=paras.bookmark,noAni = paras.noAni,ref=paras.ref})
        return
    end

    if self[paras.name.."Event"] ~= nil then
        -- 进入各个游戏方法 
        self[paras.name.."Event"](self,paras)
    end

end

function MainController:commonEvent(paras)
    local winSize = cc.Director:getInstance():getWinSize()
    local view = ModuleManager[paras.name]:getView({name="main",cb = paras.cb, bookmark=paras.bookmark,ref=paras.ref})
    view:setVisible(true)
    if paras.noAni then return end
    if paras.type == "full" or paras.from == "main" then    --满屏窗口"beauty"从右侧出现
        view:setCascadeOpacityEnabled(true)
        view:setOpacity(0)
        if paras.noanimation ~= true then qf.event:dispatchEvent(ET.MAIN_VIEW_DISMISS_ANIMATION) end
        view:runAction(cc.Sequence:create(
                cc.DelayTime:create(paras.delay or 0),
                cc.CallFunc:create(function ( sender )
                sender:enterCoustomFinish()
                end),
                --cc.MoveBy:create(0.3,cc.p(-winSize.width,0)),
                cc.FadeTo:create(0.5,255)
         ))
        return
    elseif self.view and self.view.bnt ~= nil and self.view.bnt[paras.name] ~= nil then
        self:moduleEnterAnimation(view, paras.name)
    elseif paras.name == "popularize" then
        self:moduleEnterAnimation(view, paras.name)
    elseif paras.name == "shop" or paras.name == "prize" or paras.name == "setting" then    -- 暂时只处理商城弹窗 之后弹窗不应与mainview绑定
        qf.event:dispatchEvent(ET.GLOBAL_SHOW_MAIN_DIALOG, {dialogname=paras.name, cb = paras.cb, bookmark=paras.bookmark,ref=paras.ref})        
    end
end

function MainController:remove()
    MainController.super.remove(self)
    self.gamesGather = nil
    if self.action then
        Scheduler:unschedule(self.action)
        self.action=nil
    end
    qf.event:dispatchEvent(ET.MODULE_HIDE,"gameshall")
end

function MainController:initView(parameters)
    -- if self.view and not tolua.isnull(self.view) then
    --     return self.view
    -- else
        local view = acitivityView.new(parameters)
        return view
    -- end
end


--view: 要弹出的窗口. px py, 起始位置. name, 模块名
function MainController:moduleEnterAnimation ( view, name )--点击图标弹出窗口动画
    if self._popup_record[name] then  --如果窗口还没弹出完毕，禁止再次打开
        return
    end
    self._popup_record[name] = true


    local winSize = cc.Director:getInstance():getWinSize()
    local bg = self:getView():getChildByName("mohubg")
    if not isValid(bg) then
        local bg =  cc.Sprite:create(GameRes.mohubg)
        bg:setPosition(Display.cx/2,Display.cy/2)
        
        if FULLSCREENADAPTIVE then
            bg:setPosition(-((winSize.width/2-1920/2)/2)+(winSize.width)/2,Display.cy/2)
        end
        bg:setName("mohubg")

        if not isValid(self.view)  then 
            self:getView()
        end
        if isValid(self.view)  then
            self.view:addChild(bg)  
        end
    end
    
    view:setPosition((winSize.width)/2,Display.cy/2)
    view:setAnchorPoint(cc.p(0.5,0.5))
    view:ignoreAnchorPointForPosition(false)
    view:setCascadeOpacityEnabled(true)
    --先由快到慢（同时进行动作：移到中心，完全放大，在time内渐变出现），再由快到慢（放大），由慢到快（缩小到正常大小）
    --ver.620取消上述动画效果
    self._popup_record[name] = false    --弹出动画播放完毕
    view:enterCoustomFinish()
end


function MainController:moduleExitAnimation(view,pos,module)--窗口消失
    module:remove()
end

function MainController:DDZhallEvent(parameters)--游戏大厅由右侧出现
    --ModuleManager.DDZhall:getView():stopAllActions()
    ModuleManager.DDZhall:remove()
    if Cache.DDZDesk.enterRef == GAME_DDZ_CLASSIC then
        local winSize = cc.Director:getInstance():getWinSize()
        ModuleManager.DDZhall:getView()
        -- ModuleManager.DDZhall:getView():setPosition(773,0)
        -- ModuleManager.DDZhall:getView():runAction(
        --     cc.Sequence:create(
        --         cc.MoveTo:create(0.2,cc.p(0,0))
        -- ))
    end
end

function MainController:updateBntNumber(paras)
    if paras == nil or paras.name == nil  or self.view == nil then return end
    if paras.addNumber then
        loga(self.TAG .. "____________小红点更新了" .. paras.name .. ":" .. paras.number .. "paras.addNumber:" .. paras.addNumber)
    else
        loga(self.TAG .. "____________小红点更新了" .. paras.name .. ":" .. paras.number)
    end
    
    
    local bnt = self.view.bnt[paras.name] if bnt == nil then return end
    if bnt["updateNumber"] == nil then return end
    local number = paras.number or bnt.number
    number = number or 0
    if paras.addNumber then
        number = number + paras.addNumber
    end

    if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then 
        bnt.number = number
        bnt.updateNumber(number)
    end
    if "prize"==paras.name and number>0 then
    end
end


--从后台返回要重新拉取数据
function MainController:backFromBlank()
    if not self.view or tolua.isnull(self.view) then

    else
        qf.platform:feedBackUnreadRequst()
    end
end

--添加无操作事件监听
function MainController:listenEventAction(  )
    if self.view then
        self.view:listenEventAction()
    end   
end

--移除定时器
function MainController:removeListenEvent( ... )
    if self.view then
        self.view:removeTimeCount()
    end
end

return MainController