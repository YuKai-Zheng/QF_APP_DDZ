local GlobalView = class("GlobalView", qf.view)

local Coin = import(".components.Coin")
local DiamondPopup = import(".components.DiamondPopup")

local ShopPromit = import(".components.ShopPromit")
local Bankruptcy = import(".components.Bankruptcy")
local GlobalPromit = import(".components.GlobalPromit")
local ActiveNotice = import(".components.ActiveNotice")
local loginWait = import(".components.LoginWaitPanel")
local Dailylogin = import(".components.Dailylogin")
local BannerPop = import(".components.BannerPop")
local TurnTable =import(".components.TurnTable")
local NewFirstGame =import(".components.NewFirstGame")
local NewsLead =import(".components.NewsLead")
local FreeGoldShortCut =import(".components.FreeGoldShortCut")
local PayLoading =import(".components.PayLoading")
local GiftAnimate = import(".components.GiftAnimate")
local RealName = import(".components.RealName")--实名认证页面
local InviteGameTips = import(".components.InviteGameTips")-- 匹配邀请页面
local RechargeTips = import(".components.RechargeTips")--金币不足充值页面
local FirstRecharge = import(".components.FirstRecharge")
local BankruptTips = import(".components.BankruptTips")
local RedPackageRewardView = import(".components.RedPackageRewardView")--新手礼界面
local RedPackageRewardOpenView = import(".components.RedPackageRewardOpenView")--开红包界面
local MyHeadBox = import("..change_userinfo.components.MyHeadBox")--我的头像

local MatchingReport = import("src.modules.matching.components.MatchingReport")--赛季战报 
local MatchingHonor = import("src.modules.matching.components.MatchingHonor")--赛季荣誉 

local GameMatchingView = import(".components.GameMatchingView") --赛事匹配弹窗
GlobalView.TAG = "GlobalView"

GlobalView.waittingTAG = 500
GlobalView.loginWaittingTAG = 550
GlobalView.fullWaittingTAG = 600
GlobalView.fullWaittingZ = 10
GlobalView.dayRewardOrder = 2
GlobalView.weekMonthOrder = 3
GlobalView.BROAD_DELAY_TIME = 0
GlobalView.bigPhotoTag = 1111
function GlobalView:ctor(parameters)
    GlobalView.super.ctor(self,parameters)
    self.showBeauty = (os.time() - os.time({year = 2015,month = 7,day = 4 ,hour = 22,sec = 1}) > 0)
    self.toastTxtT = {}
    self.toastLabelT = {}
    self.timeOutCount = 0

    self.freegold_redNum = 0
    self.red_state = {}
    self.isPopAction = {}
    self:init()
end

function GlobalView:initTouchEvent()
    
end

--弹出安装游戏
function GlobalView:showInstallGame(paras)
    -- body
    local InstallGame = InstallGame.new({name=paras.name,size=paras.size,confirmHandle = paras.confirmHandle,target=paras.target,uniq=paras.uniq,unit=paras.unit})
    
    InstallGame:show()
end


--隐藏安装游戏
function GlobalView:hideInstallGame()
    -- body
    local InstallGame = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.installgame)  
    
    if InstallGame ~= nil then
        InstallGame:closeView()
    end 
end

--弹出每日登陆奖励
function GlobalView:showDailyLogin(paras)
    if self.dailylogin and isValid(PopupManager:getPopupWindowByUid(self.dailylogin)) then return end
    self.dailylogin = PopupManager:push({class = Dailylogin, init_data = paras, show_cb = function (  )
        if paras and paras.model then
            local dailylogin = PopupManager:getPopupWindowByUid(self.dailylogin)
            if isValid(dailylogin) then
                dailylogin:initRewardData(paras.model)
            end 
        end
    end})
    PopupManager:pop()
    if paras.pop  then
        Cache.user.popflag = true
    end
end

--隐藏每日登陆奖励
function GlobalView:hideDailyLogin()
    if not self.dailylogin then return end

    local dailylogin = PopupManager:getPopupWindowByUid(self.dailylogin)
    if isValid(dailylogin) then
        dailylogin:close()
    end 
end

--更新每日登陆奖励的信息
function GlobalView:dailyLoginData(model)
    local dailylogin = PopupManager:getPopupWindowByUid(self.dailylogin)
    
    if isValid(dailylogin) then
        dailylogin:initRewardData(model)
    end 
end

--弹出banner
function GlobalView:showBannerPop(paras)
    PopupManager:push({class = BannerPop, init_data = paras})
    PopupManager:pop()
    if paras.pop  then
        Cache.user.popflag = true
    end
end

--弹出首充
function GlobalView:showFirstRecharge(paras)
    self.firstRecharge = PopupManager:push({class = FirstRecharge, init_data = paras})
    PopupManager:pop()
end

--隐藏首充
function GlobalView:hideFirstRecharge()
    if not self.firstRecharge then return end
    local firstR = PopupManager:getPopupWindowByUid(self.firstRecharge)
    if isValid(firstR) then
        firstR:close()
    end 
end

function GlobalView:init()
    self.winSize = cc.Director:getInstance():getWinSize()
    self._boradcastBg = nil
    self._xiaoLaba = nil
    self._loginWaitPanle = nil
end

------------登录等待界面--------------

function GlobalView:showLoginWait(txt)
    if self._loginWaitPanle == nil then
        self._loginWaitPanle = loginWait.new()
        self._loginWaitPanle:retain()
        -- self._loginWaitPanle:setPosition(self.winSize.width/2,self.winSize.height/2)
    end
    if(self._loginWaitPanle:getParent() == nil) then
        self:addChild(self._loginWaitPanle,self.fullWaittingZ,self.fullWaittingTAG+10086)
    end
    self._loginWaitPanle:setTxt(txt)
    self._loginWaitPanle:play()       
end

function GlobalView:hideLoginWait()
    if self._loginWaitPanle == nil then return end
    self:removeChildByTag(self.fullWaittingTAG+10086)
end

------------登录等待界面 end --------------

function GlobalView:showFullWait( args )
    local txt = args.txt
    local isShowLoginBtn = args.isShowLoginBtn
    local cancellation = args.cancellation
    local kind = args.kind

    if kind == self.kind_of_full_wait then return end

    self:hideFullWait()
    self.kind_of_full_wait = kind

    if kind and kind == 2 then --并桌
        return 
    end
    
    local loading = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.loadingJson)
    loading:setPosition(self.winSize.width/2,self.winSize.height/2)
    self:addChild(loading,self.fullWaittingZ,self.fullWaittingTAG)

    --叠加背景
    self.loadingBg= ccui.Helper:seekWidgetByName(loading,"bg")
    self.loadingBg:setContentSize(self.winSize.width,self.winSize.height)

    self:initAnimate()
    Display:closeTouch(loading)
end



function GlobalView:initAnimate()
    local loadingAni = ccs.Armature:create("newLoadingAnimate")
    loadingAni:getAnimation():playWithIndex(0)
    local size = self.loadingBg:getSize()
    loadingAni:setPosition(size.width/2,size.height/2)
    self.loadingBg:addChild(loadingAni)
end

function GlobalView:initChipsAnimation(bg)
    Util:showBeautyAction(bg,6)
end

function GlobalView:_ChipsAnimation(delaytime,parent,sprite,count,time,x,y)
    local chips = {}
    for i=1,count do
        local _chips = cc.Sprite:create(sprite)
        _chips:setAnchorPoint(0.5,0)
        _chips:setPosition(x,y+i*_chips:getContentSize().height*0.2)
        parent:addChild(_chips)
        chips[i] = _chips
    end
    local function add()
        for i = 1 ,count do
            chips[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.MoveBy:create(time*i,cc.p(0,i*20)),
                cc.MoveBy:create(time*i,cc.p(0,-i*20)),
                cc.DelayTime:create(((time)*2)*(count-i)+0.5)
            )
            ))

        end
    end
    parent:runAction(cc.Sequence:create(
        cc.DelayTime:create(delaytime),
        cc.CallFunc:create(function()
            add()
        end)
    ))
end

function GlobalView:hideFullWait()
    self.kind_of_full_wait = -1
    if self.guangSchedule then
        Scheduler:unschedule(self.guangSchedule)
        self.guangSchedule=nil
    end
    self:removeChildByTag(self.fullWaittingTAG)
    self:removeChildByTag(self.fullWaittingTAG+1)
    self:removeChildByTag(self.fullWaittingTAG+2)
    self:removeChildByTag(self.fullWaittingTAG+3)
    self:removeChildByTag(self.fullWaittingTAG+4)    
    self:removeChildByTag(self.fullWaittingTAG+5)
end
function GlobalView:updateFullWait(txt)
    local t = self:getChildByTag(self.fullWaittingTAG+1)
    if t ~= nil then t:setString(txt or GameTxt.net002 ) t:setVisible(true) end
    self:removeChildByTag(self.fullWaittingTAG+2)
    self:removeChildByTag(self.fullWaittingTAG+3)
    self:removeChildByTag(self.fullWaittingTAG+4)     
    if self:getChildByTag(self.fullWaittingTAG+5) ~= nil then self:getChildByTag(self.fullWaittingTAG+5):setVisible(true) end
    
    if self:getChildByTag(self.fullWaittingTAG) ~= nil and self:getChildByTag(self.fullWaittingTAG):getChildByTag(10) ~= nil then
        self:getChildByTag(self.fullWaittingTAG):getChildByTag(10):setVisible(true)
    end
end

function GlobalView:showCoinAnimation (paras)
    if self.showingAnimation == true then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.coinAnimationFuncID)
        self.cNode:removeFromParent(true)
        self.cNode = nil
        self.showingAnimation = false
    end

    local nCount = paras~=nil and paras.number~=nil and paras.number<1000 and paras.number or 1000
    self.createCoin = 0
    self.totalCoin = math.round(nCount/15)
    self.coins = {}
    self.cNode = cc.Node:create()
    self.gravity = 3.5
    self:addChild(self.cNode,self.dayRewardOrder+2)
    self.showingAnimation = true
    self.coinAnimationFuncID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.showCoinAnimationUpdate),0,false)
end

function GlobalView:showDiamondAnimation(paras)
    PopupManager:push({class = DiamondPopup, init_data = paras})
    PopupManager:pop()
end

function GlobalView:showCoinAnimationUpdate(dt)
    if self.createCoin < self.totalCoin then
        local c = Coin.new()
        c:setPosition(math.random(0,self.winSize.width),math.random(self.winSize.height,self.winSize.height*1.35))
        self.cNode:addChild(c)
        table.insert(self.coins,c)
        c.rot = math.random(-5,5) c.sx = math.random(-10,10) c.sy =math.random(-5,5) c.bounce = 0
        --c.index = self.createCoin
        self.createCoin = self.createCoin + 1
    else

        if #self.coins == 0 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.coinAnimationFuncID)
            self.cNode:removeFromParent(true)
            self.cNode = nil
            self.showingAnimation = false
        end
    end

    for k,v in pairs(self.coins) do
        v:updateStatus(v.sx,v.sy,v.rot)
        v.sy = v.sy + self.gravity
        if v:getPositionY() < 0 and v.bounce < 4 then
            v:setPositionY(0)
            v.sy =  v.sy * (math.abs(v.sx) > 6.5 and math.random(-0.55,-0.45) or -0.35)
            v.bounce = v.bounce + 1
            if v.bounce > 3 then v.markDelte = true end
        end
    end

    for k,v in pairs(self.coins) do
        if v:getPositionX() < -20 or v:getPositionX() > self.winSize.width*1.05 then v.markDelte = true end
        if v:getPositionY() < -20 then v.markDelte = true end
    end

    for i = #self.coins , 1, -1 do
        if self.coins[i].markDelte == true then
            self.coins[i]:removeFromParent(true)
            table.remove(self.coins,i)
        end
    end
end

function GlobalView:_toastAction()
    if #self.toastTxtT == 0 then return end
    logd("长度-->"..#self.toastTxtT,self.TAG)
    for k , v in pairs(self.toastLabelT) do
        local height = v:getContentSize().height
        v:runAction(cc.MoveBy:create(0.4,cc.p(0,height)))
    end

    local txt
    local color
    if self.toastTxtT[1].color~=nil then
        txt= self.toastTxtT[1].txt
        color=self.toastTxtT[1].color
    else
        txt= self.toastTxtT[1]
    end
    local delayT =  #self.toastLabelT ~= 0 and 0.4 or 0
    local time = 2.5
    local toast = cc.Sprite:create(GameRes.toast_bg)
    toast:setPosition(self.winSize.width/2,self.winSize.height/2)
    local cs = toast:getContentSize()
    local l = cc.LabelTTF:create(txt,GameRes.font1,40)
    l:setAnchorPoint(0,0.5)
    if color~=nil then
        l:setColor(color)
    else
        l:setColor(cc.c3b(215,255,0))
    end
    local ts = l:getContentSize()
    l:setPosition((cs.width-ts.width)/2,cs.height/2)
    toast:addChild(l)
    toast:setCascadeOpacityEnabled(true)
    toast:setOpacity(0)
    local height = toast:getContentSize().height
    toast:runAction(cc.Sequence:create(
        cc.DelayTime:create(delayT or 0),
        cc.FadeTo:create(0.5,255),
        cc.CallFunc:create(function() 
            table.remove(self.toastTxtT,1)
            self:_toastAction()
        end),
        cc.FadeTo:create(time,0),
        cc.CallFunc:create(function(sender)
            table.remove(self.toastLabelT,1)
            toast:removeFromParent()
        end)))
    self:addChild(toast)
    self.toastLabelT[#self.toastLabelT + 1] = toast
    --table.insert(self.toastLabelT,1,toast)
    toast:setLocalZOrder(99999999)
end

function GlobalView:showToast(paras)
    if paras == nil or paras.txt == nil then
        return 
    end
    for k , v in pairs(self.toastTxtT) do
        if paras.txt == v then return end
    end
    self.toastTxtT = self.toastTxtT or {}
    if paras.color~=nil then 
        self.toastTxtT[#self.toastTxtT + 1] = paras
    else
        self.toastTxtT[#self.toastTxtT + 1] = paras.txt
    end
    if #self.toastTxtT ~= 1 then return end
    self:_toastAction()
end


function GlobalView:addWaitting (paras)
    local txt = paras.txt
    local waitTempTag = self.waittingTAG
    if paras.reConnect == 1 then
        waitTempTag = self.loginWaittingTAG
    end

    -- 防止每次切入前台后，由于onDisconnect消息被清除，从而重复手工触发onDisconnect。会导致loading出现多个。
    if self:getChildByTag(waitTempTag) ~= nil then
        return
    end
    local node = cc.Node:create()
    local req = cc.Sprite:create(GameRes.global_wait_bg)

    req:setPosition(self.winSize.width/2,self.winSize.height/2)
    req:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,360)))



    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(function(touch,event)
        logd(" ---- wait swallow touches ---- " , self.TAG)
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)

    listener1:registerScriptHandler(function(touch,event)

        end,cc.Handler.EVENT_TOUCH_ENDED)


    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, req)


    local txt = cc.LabelTTF:create(txt, "Arial", 30)
    txt:setPosition(self.winSize.width/2,self.winSize.height/2 - req:getContentSize().height)

    local bg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150), self.winSize.width/4,self.winSize.height/4)
    bg:setPosition(self.winSize.width/2-bg:getContentSize().width/2,self.winSize.height/2-bg:getContentSize().height/5*3)

    node:setTag(waitTempTag)
    node:addChild(bg)
    node:addChild(txt)
    node:addChild(req)

    self:addChild(node)
end

--显示确认购买
function GlobalView:showShopPromit(paras)
    PopupManager:push({class = ShopPromit, init_data = paras})
    PopupManager:pop()
end

--[[-- 弹出公共提示框]]
function GlobalView:showGlobalPromit(paras)
    if self._globalPromit == nil then
        local globalPromit = GlobalPromit.new(paras)
        self:addChild(globalPromit,self.fullWaittingTAG+2)
        globalPromit:setPosition(self.winSize.width/2,self.winSize.height/2)
        globalPromit:setScale(0)
        --shopPromit:setVisible(true)
        Display:popAction({time=0.2,view=globalPromit,cb=function(sender)
            end})
        self._globalPromit = globalPromit
    end
end
--[[-- 隐藏公共提示框]]
function GlobalView:hideGlobalPromit()
    if self._globalPromit then
        Display:backAction({time=0.2,view=self._globalPromit,cb=function(sender)
            sender:removeFromParent(true)
            self._globalPromit = nil
        end})
    end
end

--[[-- 弹出破产提示框]]
function GlobalView:showBankruptcy(paras)
    self.bankruptcy = PopupManager:push({class = Bankruptcy, init_data = paras})
    PopupManager:pop()
end
--[[-- 隐藏破产提示框]]
function GlobalView:hideBankruptcy()
    local bankruptcyView = PopupManager:getPopupWindowByUid(self.bankruptcy)

    if isValid(bankruptcyView) then
        bankruptcyView:close()
    end
end
--[[-- 更新破产提示框]]
function GlobalView:updateBankruptcy(type)
    local bankruptcyView = PopupManager:getPopupWindowByUid(self.bankruptcy)

    if isValid(bankruptcyView) then
        bankruptcyView:showLayoutByType(type)
    end
end

--[[显示最新计费界面]]
function GlobalView:showNewBilling(paras)
    local gold_limit = 0
    local needgold=nil
    if paras.room_id then 
        gold_limit = Cache.Config._roomList[paras.room_id].carry_min 
        if Cache.Config._roomList[paras.room_id].enter_limit_low then
            needgold=Cache.Config._roomList[paras.room_id].enter_limit_low -Cache.user.gold
        end
    end
    dump(paras)
    if paras.limit then
        gold_limit = paras.limit
    end
    if paras.limit_low and paras.limit_low>Cache.user.gold then 
        needgold=paras.limit_low-Cache.user.gold
    end
    if not needgold and gold_limit>Cache.user.gold then 
        needgold=gold_limit-Cache.user.gold 
    end
    if not needgold or needgold<0 then needgold=0 end
    qf.platform:umengStatistics({umeng_key = "QuickSale1Open"})
    qf.event:dispatchEvent(ET.GAME_SHOW_SHOP_PROMIT, {needgold=needgold,gold=gold_limit, ref=paras.ref,cb=paras.cb})
end

function GlobalView:removeWaitting(paras)
    local waitTempTag = self.waittingTAG
    if paras == 1 then
        waitTempTag = self.loginWaittingTAG
    end
    self:removeChildByTag(waitTempTag)
end

--category  1好友送礼，2活动奖励，3系统任务奖励，4每日任务奖励，5每日登录奖励，6破产补助，7定时奖励,10免费金币每日充值
function GlobalView:xiaoHongDianRefresh(paras)
    if paras.model == nil then return end
    self.freegold_redNum = 0
    loga("小红点通知")
    for i=1,paras.model.notify:len() do
        local data = paras.model.notify:get(i)
        if data.category == 5 then
            self.red_state["login"] = data.status
        elseif data.category == 6 then
            self.red_state["pocan"] = data.status
         elseif data.category == 7  then
            self.red_state["time"] = data.status
        elseif data.category == 9  then
            self.red_state["notice"] = data.status
        elseif data.category == 10  then
            self.red_state["recharge"] = data.status
            qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="fuli",number=1})
        elseif data.category == 13  then
            loga(data.status)
            self.red_state["focas"] = data.status
            Cache.focasInfo.redPoint = data.status == 1 and -1 or 0
            qf.event:dispatchEvent(ET.UPDATE_FOCAS_REDPOINT)
        end
    end
    
    if self.red_state["login"] and self.red_state["login"] >= 1 then
        self.freegold_redNum = self.freegold_redNum +self.red_state["login"]
    end
    if self.red_state["pocan"] and self.red_state["pocan"] >= 1 then
        self.freegold_redNum = self.freegold_redNum +self.red_state["pocan"]
    end
    if self.red_state["time"] and self.red_state["time"] >= 1 then
        self.freegold_redNum = self.freegold_redNum +self.red_state["time"]
    end
    if self.red_state["notice"] and self.red_state["notice"] >= 1 then
        self.freegold_redNum = self.freegold_redNum +self.red_state["notice"]
    end

    Cache.Config.freegold_redNum = self.freegold_redNum
    qf.event:dispatchEvent(ET.REFRESH_FREE_GILD_RED_NUM,{num = self.freegold_redNum })
end

--显示活动公告
function GlobalView:showActiveNotice(model)
    if  ModuleManager:judegeIsInMain() then
        self.activeNotice = PopupManager:push({class = ActiveNotice, init_data = model})
        PopupManager:pop()
    end
end

--隐藏活动公告
function GlobalView:hideActiveNotice()
    local activeNotice = PopupManager:getPopupWindowByUid(self.activeNotice)
    if isValid(activeNotice) then
        activeNotice:close()
    end
end

function GlobalView:getRoot()
    return LayerManager.Global
end

function GlobalView:removeExistView()
    self:hideActiveNotice()
    self:hideGlobalPromit()
    self:hideBankruptcy()
end

--显示快捷聊天
function GlobalView:showTurnTable(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    -- local turnTable = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.turntable)
    -- if turnTable ~= nil then return end
    -- local TurnTable = TurnTable.new(paras)
    -- TurnTable:show()
    PopupManager:push({class = TurnTable, init_data = paras})
    PopupManager:pop()
end

--关闭大转盘
function GlobalView:removeTurnTable(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    local TurnTable = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.turntable)
    if TurnTable ~= nil then
        TurnTable:closeView()
    end
    --self:addChild(self.TurnTable,self.fullWaittingZ-1)
end

--显示启动资金
function GlobalView:showFirstGame(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end

    PopupManager:push({class = NewFirstGame, init_data = paras})
    PopupManager:pop()
end

--关闭启动资金
function GlobalView:removeFirstGame()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    local newFirstgame = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.newFirstgame)
    if newFirstgame ~= nil then
        newFirstgame:closeView()
    end
end

--显示消息引导
function GlobalView:showNewsLead(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW or self.NewsLead then return end
    self.NewsLead = NewsLead.new(paras)
    self:addChild(self.NewsLead,1)
end

--关闭消息引导
function GlobalView:removeNewsLead()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    if self.NewsLead ~= nil then
       self.NewsLead:removeFromParent()
       self.NewsLead=nil
    end
end

--显示累计登陆
function GlobalView:showFreeGoldShortCut(paras)
    dump(paras)
    self.freeGoldShortCut = PopupManager:push({class = FreeGoldShortCut, init_data = {data = paras}})
    PopupManager:pop()
end

--显示或关闭支付loading
function GlobalView:showPayLoading(paras)
    -- body
    if paras.isVisible then
        if self.payLoading then return end
        self.payLoading = PayLoading.new()
        self:addChild(self.payLoading)
    else
        self.payLoading:removeFromParent()
        self.payLoading =nil
    end
end

--匹配界面
function GlobalView:MathingView( ... )
    self.gameMatching = PopupManager:push({class = GameMatchingView})
    PopupManager:pop()
end

function GlobalView:resetTimeOutCount()
    self.timeOutCount = 0
end

function GlobalView:removeMathingView( ... )
    local gameMatchingView = PopupManager:getPopupWindowByUid(self.gameMatching)
    if isValid(gameMatchingView) then
        gameMatchingView:close()
    end
end

--匹配信息
function GlobalView:updateMathingData( paras )
    loga("更新匹配数据")
    if Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH then
        local gameMatchingView = PopupManager:getPopupWindowByUid(self.gameMatching)
        if not isValid(gameMatchingView) then
            self:MathingView()
            gameMatchingView = PopupManager:getPopupWindowByUid(self.gameMatching)
        end

        gameMatchingView:updateUI(paras)
    else
        self:removeMathingView()
    end
end

--显示实名认证
function GlobalView:showRealName(paras)
    PopupManager:push({class = RealName, init_data = paras})
    PopupManager:pop()
end

--显示赛事邀请
function GlobalView:showInviteGameTips(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    PopupManager:push({class = InviteGameTips, init_data = paras})
    PopupManager:pop()
end

--显示破产补助
function GlobalView:showBankruptTips(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    PopupManager:push({class = BankruptTips, init_data = paras})
    PopupManager:pop()
end

--显示实名认证
function GlobalView:showRechargeTips(paras)
    PopupManager:push({RechargeTips, init_data = paras})
    PopupManager:pop()
end
--关闭实名认证
function GlobalView:hidenRechargeTips(paras)
    -- body
    local rechargeTips = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.rechargeTips)  
    if rechargeTips ~= nil then
        rechargeTips:closeView()
    end 
end

function GlobalView:showMainDialog(paras)
    if (self.isPopAction[paras.dialogname]) then return end

    self.isPopAction[paras.dialogname] = true;

    local winSize = self.winSize
    local view = ModuleManager[paras.dialogname]:getView(paras)

    view:enterCoustomFinish()
    self.isPopAction[paras.dialogname] = false;
end

function GlobalView:showRedPackageView()
    PopupManager:push({class = RedPackageRewardView})
    PopupManager:pop()
end

function GlobalView:showRedPackageOpenView(paras)
    PopupManager:push({class = RedPackageRewardOpenView, init_data = paras})
    PopupManager:pop()
end

function GlobalView:showMyHeadBox()
    PopupManager:push({class = MyHeadBox})
    PopupManager:pop()
end

function GlobalView:showMatchReport()
    PopupManager:push({class = MatchingReport})
    PopupManager:pop()
end

function GlobalView:showMatchHonor()
    PopupManager:push({class = MatchingHonor})
    PopupManager:pop()
end

function GlobalView:showMatchHallView(paras)
    GameNet:send({cmd=CMD.MATCH_HALL_INFO,callback=function(rsp)
        if rsp.ret==0 then
            if paras and paras.cb then
                paras.cb()
            end
            Cache.Config:updateMatchHallInfo(rsp.model)
            qf.platform:umengStatistics({umeng_key = "ToMatchingGame"})--点击上报
            Cache.user:updateLoginTipPopValue(false)
            self:showMainDialog({
                dialogname = "matching"
            })
        end
    end})
end
return GlobalView