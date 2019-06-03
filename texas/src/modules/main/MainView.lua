local MainView = class("MainView", qf.view)
MainView.TAG = "MainView"
local UserHead = import("..change_userinfo.components.userHead")--我的头像

MainView.BNT_NUMBER_BG_TAG = 747
MainView.BNT_NUMBER_NUMBER_TAG = 748 
MainView.LIST_VIEW_INIT_NUM = 4
MainView.listenTimer = nil
MainView.goto_maching = false
MainView.total_time_count = 120

function MainView:ctor(parameters)
    MainView.super.ctor(self, parameters)
    self:init(parameters)
    self:initButtonEvents()
    self:initTouchEvent({clickOnlyTop = true})
    MusicPlayer:setBgMusic()
    MusicPlayer:backgroundSineIn()
    if FULLSCREENADAPTIVE then
        self.button_panel:setPositionX(self.button_panel:getPositionX()+(self.winSize.width/2-1920/2)/2)
        self.button_panel.pos = cc.p(self.button_panel:getPositionX(), 0)
        self:setPositionX((self.winSize.width/2-1920/2)/2)
        self.mainBgImg:setPositionX(self.mainBgImg:getPositionX()+(self.winSize.width/2-1920/2)/2)
        
        self.playerP:setPositionX(self.playerP:getPositionX()-(self.winSize.width/2-1920/2)/2)
        self.playerP.pos = cc.p(self.playerP:getPositionX(), self.playerP:getPositionY())
        self.rankBtn:setPositionX(self.rankBtn:getPositionX()-(self.winSize.width/2-1920/2)/2)
        self.rankP:setContentSize(self.rankP:getContentSize().width+(self.winSize.width/2-1920/2)/2,self.rankP:getContentSize().height)

        self.beauty:setPositionX(self.beauty:getPositionX()+(self.winSize.width/2-1920/2)/2)
        self.leftTools:setPositionX(self.leftTools:getPositionX())
        self.leftTools.pos = cc.p(self.leftTools:getPositionX(),self.leftTools:getPositionY())
        self.gameChoose_pannel:setPositionX(self.gameChoose_pannel:getPositionX()+(self.winSize.width/2-1920/2)*3/4)
        self.gameChoose_pannel.pos = cc.p(self.gameChoose_pannel:getPositionX(),self.gameChoose_pannel:getPositionY())
        self.topTools:setPositionX(self.topTools:getPositionX()+(self.winSize.width/2-1920/2))
        self.topTools.pos = cc.p(self.topTools:getPositionX(), self.topTools:getPositionY())

        
    else  --普通手机切换背景图
        local margin = 100
        self.ddzNode:setPositionX(self.ddzNode:getPositionX() - margin)
        self.matchingBtn:setPositionX(self.matchingBtn:getPositionX() - margin)
    end
    
    self:ticketChargeTips()

end

function MainView:getRoot() 
    return LayerManager.MainLayer
end 

-- 初始化根节点
function MainView:initRootView()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.mainViewJson)
    self:addChild(self.root)
end

function MainView:init(parameters)
    self.bnt = {}
    self.upAreaBtns = {}--上面的
    self.item_num = 0
    qf.event:dispatchEvent(ET.NET_USER_TASKLIST_REQ)
    self.winSize = cc.Director:getInstance():getWinSize() 
    
    self:initRootView()
    self:initUI()
    self:updateUserInfo()
    self:updateUserHead() 
    self:tuiguangAni()
    self:firstPayBtnAni()
    self:initRank()
    self:enterMainView()
    self:updateReViewShow()
    qf.event:dispatchEvent(ET.BG_CLOSE)
    Util:registerKeyReleased({self = self,cb = function ()
        self:showExitTip() 
    end})

    if Cache.user.cumulate_login_reward == 1 then 
        Cache.Config.FinishActivityNum = (Cache.Config.FinishActivityNum or 0) + 1
        qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="activity",number = Cache.Config.FinishActivityNum or 0,
        addNumber = 0})
    end
end

function MainView:showExitTip( ... )
    if string.find(GAME_CHANNEL_NAME,"CN_AD_OPPO1") then
        qf.platform:showExitDialog({
            cb = function ( ... )
                cc.Director:getInstance():endToLua()
            end
        })
    else
        qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content="你确定退出游戏吗？", type = 6,is_enabled = false,color=cc.c3b(143,80,39),fontsize=38,
            cb_consure = function ( ... )
                cc.Director:getInstance():endToLua()
            end,
            cb_cancel=function( ... )
        end})
    end
end

function MainView:updateReViewShow(...)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW or not TB_MODULE_BIT.BOL_MODULE_BIT_EXCHANGE_FUCARD then 
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
            self.rankBtn:setVisible(false)
        end
        self.fuliCenterBtn:loadTextureNormal(GameRes.fuli_black)
        self.fuliCenterBtn:setTouchEnabled(false)
    else
        self.fuliCenterBtn:setTouchEnabled(true) 
    end
    self:TurnTableIconShow()--大转盘
    -- self:initUpBtnTable()
end

function MainView:initUI(...)
    self.functionBtnTable = {}
    -- body
    self.mainBgImg = ccui.Helper:seekWidgetByName(self.root, "bgimg") --背景图
    
    self.sunShineImg =  ccui.Helper:seekWidgetByName(self.root, "guang") --阳光
    --人物信息
    self.playerP = ccui.Helper:seekWidgetByName(self.root, "user_info") --人物层

    self.gameChoose_pannel = ccui.Helper:seekWidgetByName(self.root, "gameChoose_pannel") --游戏类型选择层
    self.button_panel = ccui.Helper:seekWidgetByName(self.root, "button_panel") --按钮菜单栏
    self.topTools = ccui.Helper:seekWidgetByName(self.root, "topTools") --顶部工具栏
    self.leftTools = ccui.Helper:seekWidgetByName(self.root, "leftTools") --左边工具栏

    self.headInfo = ccui.Helper:seekWidgetByName(self.playerP, "headInfo") --人物头层
    
    self.playerNickTxt = ccui.Helper:seekWidgetByName(self.playerP, "nick") --人物昵称
    -- 金币相关
    self.playerGoldBg = ccui.Helper:seekWidgetByName(self.playerP, "gold_bg") --人物金币数背景
    self.gold_buy_mark_img = ccui.Helper:seekWidgetByName(self.playerP, "gold_buy_mark_img") -- 加号
    self.playerGoldTxt = ccui.Helper:seekWidgetByName(self.playerP, "gold_num") --人物金币数
    
    -- 奖券相关
    self.playerFocasBg = ccui.Helper:seekWidgetByName(self.playerP, "focas")
    self.playerFocasBg:setVisible(true)
    self.playerFocasTxt = ccui.Helper:seekWidgetByName(self.playerP, "focas_num")

    
    --游戏类型按钮
    self.matchingBtn = ccui.Helper:seekWidgetByName(self.gameChoose_pannel, "matchingBtn")
    self.ddzNode = ccui.Helper:seekWidgetByName(self.gameChoose_pannel, "gameBtn")
    
    self.rankP = ccui.Helper:seekWidgetByName(self.root, "rank_panel") --排行榜 
    self.rankBtn = ccui.Helper:seekWidgetByName(self.root,"btn_rank") --排行榜
    self.rankBtn:setVisible(false)
    self.rankP:setVisible(false)
       
    --按钮
    self.btnBg = ccui.Helper:seekWidgetByName(self.button_panel, "bg") --按钮层背景
    self.shopBtn = ccui.Helper:seekWidgetByName(self.button_panel, "shop_car") --商城按钮
    
    self.fuliCenterBtn = ccui.Helper:seekWidgetByName(self.button_panel, "btn_fuli") --奖券兑换按钮
    table.insert(self.functionBtnTable,self.fuliCenterBtn)

    self.ticketTips = self.fuliCenterBtn:getChildByName("tips") --奖券兑换的提示
    self.ticketTips:setVisible(false)
    self.ticketTipList = self.ticketTips:getChildByName("ticketProductList")
    self.item_tipTicket = ccui.Helper:seekWidgetByName(self.root,"item_tipTicket")

    self.freeBtn = ccui.Helper:seekWidgetByName(self.button_panel, "btn_free") --福利按钮
    table.insert(self.functionBtnTable,self.freeBtn)
    
    self.activityBtn = ccui.Helper:seekWidgetByName(self.button_panel, "btn_activity") --活动按钮
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.activityBtn:setVisible(false)
    else
        table.insert(self.functionBtnTable,self.activityBtn)
    end

    self.prizeBtn = ccui.Helper:seekWidgetByName(self.button_panel, "btn_prize") --任务按钮
    table.insert(self.functionBtnTable,self.prizeBtn)

    self.btn_friend = ccui.Helper:seekWidgetByName(self.button_panel, "btn_friend") --好友房按钮
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.btn_friend:setVisible(false)
    else
        table.insert(self.functionBtnTable,self.btn_friend)
    end

    self.quickStartBtn = ccui.Helper:seekWidgetByName(self.button_panel, "quickStart") --商城按钮
    self.quickStartBtn.tag = 1056
    table.insert(self.functionBtnTable,self.quickStartBtn)

    -- 上边按钮栏
    self.settingBtn = ccui.Helper:seekWidgetByName(self.topTools, "setting") --设置按钮
    
    self.packBtn = ccui.Helper:seekWidgetByName(self.topTools, "package") -- 背包
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.packBtn:setVisible(false)
    else
        self.packBtn:setVisible(true)
    end

    self.userLevel = ccui.Helper:seekWidgetByName(self.root,"userLevel") --用户等级
    self.level_img = ccui.Helper:seekWidgetByName(self.userLevel,"level_img") --用户等级图标
    self.levelTitle = ccui.Helper:seekWidgetByName(self.userLevel,"levelTitle") --用户等级名称

    -- print("绑定微信" ..  self.playerP)
    --绑定微信按钮
    self.bindWXBtn = ccui.Helper:seekWidgetByName(self.root, "bindWXBtn")
    self.bindWechatTips = ccui.Helper:seekWidgetByName(self.root, "bindWechattips")
    self.bindWechatTips:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.3,255),cc.DelayTime:create(3),cc.FadeTo:create(0.3,0),cc.DelayTime:create(10))))
    if Cache.user.is_bind_wx == 0 and Cache.Config.promoter_support and TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW and CHANNEL_NEED_WEIXIN_BAND_FLAG == true then
        self.bindWXBtn:setVisible(true)
        self.bindWechatTips:setVisible(true)
        self.userLevel:setVisible(false)
    else
        self.userLevel:setVisible(true)
        self.bindWXBtn:setVisible(false)
        self.bindWechatTips:setVisible(false)
    end
    
    addButtonEvent(self.bindWXBtn,function()
        qf.event:dispatchEvent(ET.EVENT_BAND_WEIXIN,{cb = function (data)
            self.bindWXBtn:setVisible(false)
            self.bindWechatTips:setVisible(false)
            self.userLevel:setVisible(true)
        end})
    end)
    
    self:initFuncitonBtn()
    self.playerP.pos = cc.p(self.playerP:getPositionX(), self.playerP:getPositionY())
    self.button_panel.pos = cc.p(self.button_panel:getPositionX(), 0)
    self.topTools.pos = cc.p(self.topTools:getPositionX(), self.topTools:getPositionY())
    self.gameChoose_pannel.pos = cc.p(self.gameChoose_pannel:getPositionX(), self.gameChoose_pannel:getPositionY())
    self.leftTools.pos = cc.p(self.leftTools:getPositionX(), self.leftTools:getPositionY())
    self.prizePos = cc.p(self.prizeBtn:getPositionX(), self.prizeBtn:getPositionY())
    self.prizeBtn.pos = cc.p(self.prizeBtn:getPositionX(), self.prizeBtn:getPositionY())
    self.freeBtn.pos = cc.p(self.freeBtn:getPositionX(), self.freeBtn:getPositionY())
    self.quickStartBtn.pos = cc.p(self.quickStartBtn:getPositionX(), self.quickStartBtn:getPositionY())
    self.btn_friend.pos = cc.p(self.btn_friend:getPositionX(), self.btn_friend:getPositionY())
    self.activityBtn.pos = cc.p(self.activityBtn:getPositionX(), self.activityBtn:getPositionY())
    -- self.packBtn.pos = cc.p(self.packBtn:getPositionX(), self.packBtn:getPositionY())
    -- self.settingBtn.pos = cc.p(self.settingBtn:getPositionX(), self.settingBtn:getPositionY())

    self.beauty = ccui.Helper:seekWidgetByName(self.root,"beauty_img")
    self:addCoinGameButtonAni()
    self:addMathingGameButtonAni()
end

--大转盘icon
function MainView:TurnTableIconShow()
    -- body
    if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW and Cache.user.show_lucky_wheel_or_not == 0 and TB_MODULE_BIT.BOL_MODULE_BIT_EXCHANGE_FUCARD then--大转盘
        local turntable = ccui.Helper:seekWidgetByName(self.leftTools, "turntable")
        turntable:setVisible(true)
        turntable:setScale(0.85)
        if turntable:getChildByName("turnArmature") then
            turntable:removeChildByName("turnArmature")
        end

        --在不在抽奖时段
        if Cache.user.IsRightTime == 0 or Cache.user.IsRightTime == 1 then
            qf.event:dispatchEvent(ET.MAIN_UPDATE_SHORTCUT_NUMBER)
            ccui.Helper:seekWidgetByName(turntable, "choujiangimg"):setVisible(true)
            ccui.Helper:seekWidgetByName(turntable, "time"):setVisible(false)
            local armatureDataManager = ccs.ArmatureDataManager:getInstance()
            armatureDataManager:addArmatureFileInfo(GameRes.TURNTABLE)
            local turnicon = ccs.Armature:create("zp_icon")
            turntable:addChild(turnicon, 0)
            turnicon:setName("turnArmature")
            turnicon:setPosition(turntable:getContentSize().width / 2 + 4, turntable:getContentSize().height / 2 + 8)
            turnicon:getAnimation():playWithIndex(0)
        end
        addButtonEvent(turntable, function ()
            if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅大转盘按钮") end
            qf.platform:umengStatistics({umeng_key = "page_lottery"})--点击上报
            qf.event:dispatchEvent(ET.SHOW_TURNTABLE)
        end)
    else
        local turntable = ccui.Helper:seekWidgetByName(self.leftTools, "turntable")
        turntable:setVisible(false)
    end
end

--金币场 动画
function MainView:addCoinGameButtonAni()
    -- body
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.coin_game_button)
    local gameButtonAni = ccs.Armature:create("NewAnimation")
    gameButtonAni:getAnimation():playWithIndex(0)
    local size = self.ddzNode:getSize()
    gameButtonAni:setPosition(size.width/2,size.height/2)
    self.ddzNode:addChild(gameButtonAni)

end

--排位赛 动画
function MainView:addMathingGameButtonAni()
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.matching_game_button)
    local gameButtonAni = ccs.Armature:create("matching_game_button")
    gameButtonAni:getAnimation():playWithIndex(0)
    local size = self.matchingBtn:getSize()
    gameButtonAni:setPosition(size.width/2,size.height/2)
    self.matchingBtn:addChild(gameButtonAni)
end


function MainView:initFuncitonBtn( ... )
    for k,v in pairsByKeys(self.functionBtnTable)do 
        if v.tag == 1056 then
            v:setPositionX(114+k*((1550 - 114)/(#self.functionBtnTable)) + 80)
        else
            v:setPositionX(114+k*((1550 - 114)/(#self.functionBtnTable)))
        end
    end
end
 
-- 初始化动画
function MainView:initSunShineAnimate()
    -- body
    if self.sunShineSchedule then
        Scheduler:unschedule(self.sunShineSchedule)
        self.sunShineSchedule = nil
    end
    
    self.sunShineSchedule = Scheduler:scheduler(0.1, function ()
        if self.sunShineImg == nil then return end
        local margin = 6
        if self.sunShineImg:getRotation() ~= 0 and self.sunShineImg:getRotation() % 360 == 0 then
            self.sunShineImg:setOpacity(250)
        end
        self.sunShineImg:setRotation(self.sunShineImg:getRotation() + 2)
        
        if self.sunShineImg:getOpacity() - margin < 0 then
            self.sunShineImg:setOpacity(0)
        else
            self.sunShineImg:setOpacity(self.sunShineImg:getOpacity() - margin)
        end
    end)
end
-- 初始化顶部栏按钮位置
function MainView:initUpBtnTable(...)--初始化上部按钮的位置
    if self.upAreaBtns and #self.upAreaBtns >= 1 then 
        for i = 1, #self.upAreaBtns do
            self.upAreaBtns[i]:setPositionX(1420 + (i - 1) * 175)
            if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
                self.upAreaBtns[i]:setVisible(false)
                self.upAreaBtns[i]:setTouchEnabled(false)
            else
                self.upAreaBtns[i]:setVisible(true)
                self.upAreaBtns[i]:setTouchEnabled(true)
            end
        end
    end
end
   

function MainView:installProgress(uniq,count,total_count) 
    local item = ccui.Helper:seekWidgetByName(self.root, uniq)
    if not item then return end
    --下载游戏回调
    local download = ccui.Helper:seekWidgetByName(item, "progress_bg_img")
    if download then
        local percent = math.floor(count*100/total_count)
        if total_count == 0 then 
            percent = 100
        end
        percent = percent > 100 and 100 or percent
        local downLoadProgressBg = ccui.Helper:seekWidgetByName(download, "download_progress_bg")
        if downLoadProgressBg then downLoadProgressBg:setVisible(true) end
        local downLoadProgress = ccui.Helper:seekWidgetByName(download, "download_progress")
        if downLoadProgress then 
            downLoadProgress:setVisible(true)
            downLoadProgress:setPercent(percent)
        end
        if percent == 100 then
            download:setVisible(false)
        end
    end
end
--初始化button事件
function MainView:initButtonEvents()
    local goldImag = ccui.Helper:seekWidgetByName(self.playerP, "gold_bg")
    -- 进入商城事件
    local enterShop = function (sender)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then 
            Util:uploadError(" 点击大厅头像旁的+进入商城") 
        end
            local bookmarkIndex = sender == goldImag and PAY_CONST.BOOKMARK.GOLD or PAY_CONST.BOOKMARK.DIAMOND
            qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = bookmarkIndex})
            qf.platform:umengStatistics({umeng_key = "Shopping_Mall"})--点击上报
    end

    self.focasBtn = ccui.Helper:seekWidgetByName(self.playerP, "focas")
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.focasBtn:setVisible(false)
    end

    
    if TB_MODULE_BIT.BOL_MODULE_BIT_EXCHANGE_FUCARD then
        addButtonEvent(self.focasBtn, function (sender)
            if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅奖券") end
            qf.event:dispatchEvent(ET.SHOW_FOCASTASK_VIEW)
        end)

        addButtonEvent(self.focasBtn:getChildByName("focastipsbtn"), function (sender)
            if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅奖券") end
            qf.event:dispatchEvent(ET.SHOW_FOCASTASK_VIEW)
        end)
    end
    self.focasBtn:getChildByName("focastipsbtn"):setVisible(TB_MODULE_BIT.BOL_MODULE_BIT_EXCHANGE_FUCARD)
    self.bnt['focaTask'] = self.focasBtn

    self.root.noEffect = true
    addButtonEventNoVoice(self.root, function (sender)
        self.focasBtn:getChildByName("focastips"):setVisible(false)
    end)

    addButtonEvent(goldImag, enterShop)

    self.bnt["shop"] = self.shopBtn
    addButtonEvent(self.shopBtn, function (sender)
        self.shopBtn:setScale(1.0)

        if Cache.user.justloginSuccess then
            if not Cache.user.firstChargeConfInfo  or not Cache.user.firstChargeConfInfo.hasEntryControl or not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then 
                if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅商城") end
                qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop"})
                qf.platform:umengStatistics({umeng_key = "Shopping_Mall"})--点击上报
            else
                -- body
                if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅新手礼包") end
                qf.event:dispatchEvent(ET.SHOW_FIRSTRECHARGE_POP,{cb = function ( ... )
                    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅商城") end
                    qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop"})
                    qf.platform:umengStatistics({umeng_key = "Shopping_Mall"})--点击上报
                end})
                qf.platform:umengStatistics({umeng_key = "firstRecharge"})--点击上报
                Cache.user.justloginSuccess = false
            end
        else
            if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅商城") end
            qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop"})
            qf.platform:umengStatistics({umeng_key = "Shopping_Mall"})--点击上报
        end
    end, function ()
        self.shopBtn:setScale(1.1)
    end, nil, function ()
        self.shopBtn:setScale(1.0)
    end)

    self.bnt["quickStart"] = self.quickStartBtn
    addButtonEvent(self.quickStartBtn, function (sender)
        self.quickStartBtn:setScale(1.0)
        qf.event:dispatchEvent(ET.EVENT_JUMP_QUICK_COIN_GAME,{})
    end, function ()
        self.quickStartBtn:setScale(1.1)
    end, nil, function ()
        self.quickStartBtn:setScale(1.0)
    end)
    
    
    --日常奖励
    self.bnt['prize'] = self.prizeBtn
    addButtonEvent(self.prizeBtn, function (sender)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅任务") end
        qf.event:dispatchEvent(ET.SHOW_REWARD_VIEW)
        qf.platform:umengStatistics({umeng_key = "Reward"})--点击上报
    end)
    
    --活动
    self.bnt['activity'] = self.activityBtn
    addButtonEvent(self.activityBtn, function (sender)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅活动") end
        qf.event:dispatchEvent(ET.SHOW_ACTIVE_VIEW)
        qf.platform:umengStatistics({umeng_key = "Activity"})--点击上报
    end)

    
    
    --福利
    self.bnt['fuli'] = self.freeBtn
    addButtonEvent(self.freeBtn, function()
        qf.event:dispatchEvent(ET.SHOW_FREEGOLDSHORTCUT)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅福利") end
        qf.platform:umengStatistics({umeng_key = "click_free"})--点击上报
    end)
    
    --设置
    self.bnt['setting'] = self.settingBtn
    addButtonEvent(self.settingBtn, function (sender)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅设置") end
        qf.event:dispatchEvent(ET.SHOW_SETTING_VIEW)
        qf.platform:umengStatistics({umeng_key = "Set_up"})--点击上报
    end)

    --推广
    self.bnt['friendRoom'] = self.btn_friend
    addButtonEvent(self.btn_friend, function (sender)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError("点击好友房") end
        qf.platform:openWXMiniProgram()
    end)
    
    -- 背包
    self.bnt['pack'] = self.packBtn
    addButtonEvent(self.packBtn, function (sender)
        qf.event:dispatchEvent(ET.SHOW_DAOJU_VIEW)
        qf.platform:umengStatistics({umeng_key = "pack"})--点击上报
    end)

    -- 福利中心
    self.bnt['focas'] = self.fuliCenterBtn
    if self.fuliCenterBtn then 
        addButtonEvent(self.fuliCenterBtn, function (sender)
            self:enterFocaRechargeView()
        end)
    end
    
    --排行榜
    addButtonEvent(self.rankBtn, function( ... )
        if FULLSCREENADAPTIVE then
            self.rankBg:runAction(cc.MoveTo:create(0.1,cc.p(256-(self.winSize.width/2-1920/2)/2,554)))
        else 
            self.rankBg:runAction(cc.MoveTo:create(0.1,cc.p(256,554)))
        end
        local friendBtn = ccui.Helper:seekWidgetByName(self.rankP,"firendRankBtn")
        friendBtn:setTouchEnabled(true)
        local allBtn = ccui.Helper:seekWidgetByName(self.rankP,"allRankBtn")
        allBtn:setTouchEnabled(false)
        
        friendBtn:setOpacity(0)
        allBtn:setOpacity(255)
        qf.event:dispatchEvent(ET.WORLD_LEVEL_RANK,{cb=handler(self,self.updateRank)})
        self.rankP:runAction(cc.Show:create())
        self:removeTimeCount()
    end) 


    -- --排行榜
    -- addButtonEvent(ccui.Helper:seekWidgetByName(self.root,"btn_rank"), function( ... )
    --     self.rankBg:runAction(cc.MoveTo:create(0.1,cc.p(256,554)))
    --     self.rankP:runAction(cc.Show:create())
    -- end) 

    --个人信息
    addButtonEvent(self.headInfo, function (sender)
        --if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅个人头像") end
        qf.platform:umengStatistics({umeng_key = "Personal_information"})--点击上报
        local updatepoint = function(...)
            -- body
            qf.event:dispatchEvent(ET.MAIN_UPDATE_SHORTCUT_NUMBER)
        end
        local localinfo = {gold = Cache.user.gold, 
            nick = Cache.user.nick, 
            portrait = Cache.user.portrait, 
        sex = Cache.user.sex}
        qf.event:dispatchEvent(ET.GLOBAL_SHOW_USER_INFO, {uin = Cache.user.uin, localinfo = localinfo, isedit = true , isInGame = false, cb = updatepoint})
    end)
    
    for k, v in pairs(self.bnt) do
        self:extendBnt(v)
    end
    

    -- 比赛场
    self.bnt['matching'] = self.matchingBtn

    if self.matchingBtn then
        addButtonEvent(self.matchingBtn, function (sender)
            qf.event:dispatchEvent(ET.SHOW_MATCHHALL_VIEW)
            qf.platform:uploadEventStat({
                module = "performance",
                source = "pywxddz",
                event = STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_MATCH_CLICK_HALL_ENTER,
                value = 1,
                custom = Cache.user.level,
            })
        end)
    end

    for k, v in pairs(self.bnt) do
        self:extendBnt(v)
    end

    -- 进入斗地主训练营和经典场
    if self.ddzNode then
        addButtonEvent(self.ddzNode,function ()            
            self:classicGameClicked()
            Cache.user:updateLoginTipPopValue(false)
            self.ddzNode:setScale(1.0)
        end,function ( )
            self.ddzNode:setScale(1.05)
        end,function ( )
        end,function ( )
            self.ddzNode:setScale(1.0)
        end)
    end
end

function MainView:classicGameClicked()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅进入斗地主") end
    if self.click then return end
    
    self.click = true

    Cache.DDZDesk.enterRef = GAME_DDZ_CLASSIC
    qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "DDZhall"})

    Util:delayRun(0.2, function (...)
        -- body
        self.click = false
    end)
end

--弹窗拒绝事件
function MainView:calulateAcceptRimes(  )
    self.total_time_count = 120
    local num = cc.UserDefault:getInstance():getIntegerForKey("refuse_num_"..Cache.user.uin,0)
    num = num + 1
    loga("拒绝次数"..num)
    local time = os.time()
    loga(time)
    cc.UserDefault:getInstance():setIntegerForKey("refuse_num_"..Cache.user.uin,num)
    if num >= 2 then
        cc.UserDefault:getInstance():setIntegerForKey("refuse_time_"..Cache.user.uin,time)
    end
    cc.UserDefault:getInstance():flush() 
end

--弹窗同意事件
function MainView:acceptInviteGame( ... )
    if Cache.user.gold<Cache.user.ddz_match_config.min_gold_limit then 
        if not PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.rechargeTips) then 
            qf.event:dispatchEvent(ET.RECHARGETIPS,{method="show",cb=show})
        end
    else 
        self:calulateAcceptRimes()
        qf.event:dispatchEvent(ET.SHOW_MATCHHALL_VIEW)
        qf.platform:uploadEventStat({
            module = "performance",
            source = "pywxddz",
            event = STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_MATCH_CLICK_HALL_ENTER,
            value = 1,
            custom = Cache.user.level,
        })

        if not Cache.user.app_new_user_mathing_accept or Cache.user.app_new_user_mathing_accept ~= 1 then
            Util:delayRun(0.3,function ( ... )
                qf.event:dispatchEvent(ET.SHOW_START_MATCHING,{})
            end) 
        end
        Cache.user.app_new_user_mathing_accept = 0
    end
end

function MainView:removeTimeCount( ... )
    if self.listenTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.listenTimer)
        self.listenTimer = nil
    end
end


--定义大厅有无操作事件监听
--对有无事件操作做监听
function MainView:listenEventAction( ... )

    self.time_count = 0

    local time = cc.UserDefault:getInstance():getIntegerForKey("refuse_time_"..Cache.user.uin,0)

    local nowTime = os.time()

    local interval = nowTime - time
    --当大于24小时，重新更新本地拒绝次数
    if interval >= 86400 and time ~= 0 then
        cc.UserDefault:getInstance():setIntegerForKey("refuse_num_"..Cache.user.uin,0)
        cc.UserDefault:getInstance():flush()
    end
    
    if self.listenTimer then
        return
    end

    local timeCountId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        if tolua.isnull(self) then
            return
        end
        local num = cc.UserDefault:getInstance():getIntegerForKey("refuse_num_"..Cache.user.uin,0)
        local match_accept_need = cc.UserDefault:getInstance():getIntegerForKey("match_accept_need_"..Cache.user.uin,0)
        local childCount = PopupManager.root:getChildrenCount()
        local inviteGame = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.inviteGameTips)
        local isInhall = ModuleManager:judegeIsInHall()

        if isInhall==false or self.goto_maching == true or num >= 2 or match_accept_need == 0 and inviteGame == nil  then
            self:removeTimeCount()
        end

        if PopupManager.queue_num > 0 or PopupManager.stack_num > 0 then
            self:removeTimeCount()
        end
        
        if Cache.user.gold < Cache.user.ddz_match_config.min_gold_limit or ModuleManager:judegeIsInLogin() then -- 金币余额足够支付门票消耗
            self:removeTimeCount()
        end

        self.time_count = self.time_count + 1
        if Cache.MainHaveEvent == true then
            self.time_count = 0
            Cache.MainHaveEvent = false
        end

        if self.time_count > 15 then
            qf.event:dispatchEvent(ET.INVITEGAMETIPS,{method="hide",cb=hide})
        end

        if self.time_count >= self.total_time_count then
            self.time_count = 0
            self.refuse = false
            cc.UserDefault:getInstance():setIntegerForKey("match_accept_need_"..Cache.user.uin,0)
            if not PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.inviteGameTips) then 
                qf.event:dispatchEvent(ET.INVITEGAMETIPS,{method="show",cb=show})
            end
            qf.platform:umengStatistics({umeng_key = "game_invite_show"})
        end    
    end,1,false)
    
    self.listenTimer = timeCountId
end

--初始化选择界面按钮
function MainView:initRank( ... )
    local friendBtn = ccui.Helper:seekWidgetByName(self.rankP,"firendRankBtn")
    friendBtn:setTouchEnabled(true)
    local allBtn = ccui.Helper:seekWidgetByName(self.rankP,"allRankBtn")
    allBtn:setTouchEnabled(false)
    
    friendBtn:setOpacity(0)
    allBtn:setOpacity(255)
    --今日排行按钮
    addButtonEvent(friendBtn, function( ... )
        qf.event:dispatchEvent(ET.DAY_LEVEL_RANK,{cb=handler(self,self.updateRank)})
        friendBtn:setTouchEnabled(false)
        allBtn:setTouchEnabled(true)
        friendBtn:setOpacity(255)
        allBtn:setOpacity(0)
    end) 
    --总排行按钮
    addButtonEvent(allBtn, function( ... )
        qf.event:dispatchEvent(ET.WORLD_LEVEL_RANK,{cb=handler(self,self.updateRank)})
        friendBtn:setTouchEnabled(true)
        allBtn:setTouchEnabled(false)
        friendBtn:setOpacity(0)
        allBtn:setOpacity(255)
    end) 
    --返回
    addButtonEvent(ccui.Helper:seekWidgetByName(self.rankP,"backBtn"), function( ... )
        self.rankBg:runAction(cc.MoveTo:create(0.1,cc.p(-702,554)))
        self.rankP:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.Hide:create()))
    end) 
    --返回
    addButtonEvent(self.rankP, function( ... )
        self.rankBg:runAction(cc.MoveTo:create(0.1,cc.p(-702,554)))
        self.rankP:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.Hide:create()))
        self:listenEventAction()
    end) 
    self.rankItem = ccui.Helper:seekWidgetByName(self.rankP,"rank_item")
    self.rank_mine = ccui.Helper:seekWidgetByName(self.rankP,"rank_mine")
    self.rankBg = ccui.Helper:seekWidgetByName(self.rankP,"rankbg")
    self.rankBg:setTouchEnabled(true)
end

--初始化排行榜列表
function MainView:updateRank(model)
    self.rankList = ccui.Helper:seekWidgetByName(self.rankP,"rank_listview")
    if not self.rankList then return end
    self.rankList:removeAllChildren()
    self.rankList:stopAllActions()
    self.rankList:setItemModel(self.rankItem)
    local updateInfo = function( item,rankinfo,isrank )
        Util:updateUserHead(ccui.Helper:seekWidgetByName(item,"head"),rankinfo.portrait, rankinfo.gender, {add = true,url=true,sq=true})--物品图片
        local nickName = Util:filterEmoji(rankinfo.nick) or ""
        ccui.Helper:seekWidgetByName(item,"nick"):setString(Util:getCharsByNum(Util:filter_spec_chars(nickName),12))
        ccui.Helper:seekWidgetByName(item,"winrate"):setString((rankinfo.play_times==0 and 0 or math.ceil((rankinfo.win_times/rankinfo.play_times*100))).."%")
        if not rankinfo.level or rankinfo.level < 10 then
            rankinfo.level = 10
        end
        ccui.Helper:seekWidgetByName(item,"level"):setString(Cache.user:getConfigByLevel(rankinfo.level).title)  
        ccui.Helper:seekWidgetByName(item,"matchingGameNum"):setString(rankinfo.play_times)  
        addButtonEvent(ccui.Helper:seekWidgetByName(item,"head"),function( ... )
        end)
        if rankinfo.rank<0 then
            ccui.Helper:seekWidgetByName(item,"rankimg"):setVisible(false)
            ccui.Helper:seekWidgetByName(item,"norank"):setVisible(true)
            ccui.Helper:seekWidgetByName(item,"ranktxt"):setVisible(false)
        elseif rankinfo.rank<4 then
            ccui.Helper:seekWidgetByName(item,"ranktxt"):setVisible(false)
            ccui.Helper:seekWidgetByName(item,"rankimg"):setVisible(true)
            ccui.Helper:seekWidgetByName(item,"rankimg"):loadTexture(GameRes["main_rank_"..(rankinfo.rank)])
        elseif rankinfo.rank>0 then 
            ccui.Helper:seekWidgetByName(item,"ranktxt"):setVisible(true)
            ccui.Helper:seekWidgetByName(item,"rankimg"):setVisible(false)
            ccui.Helper:seekWidgetByName(item,"ranktxt"):setString(rankinfo.rank)
        end
        if isrank then
            ccui.Helper:seekWidgetByName(item,"nick"):setColor(cc.c3b(136,38,20))
        end
    end
    local index = 0
    for i=1,model.rank_list:len() do
        local rankinfo = model.rank_list:get(i)
        local info = {
            rank = rankinfo.rank,
            portrait = rankinfo.portrait,
            nick = rankinfo.nick,
            level = rankinfo.level,
            win_times = rankinfo.win_times,
            gender = rankinfo.gender,
            play_times = rankinfo.play_times   
        }
        
        local time = index/5*0.2
        self.rankList:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function( ... )   
            self.rankList:pushBackDefaultItem()
            local item = self.rankList:getItem(i-1)
            --Display:showScalePop({view=item})
            updateInfo(item,info,true)
        end)))
        index = index + 1
    end
    ccui.Helper:seekWidgetByName(self.rank_mine,"norank"):setVisible(false)
    updateInfo(self.rank_mine,model.my_rank)
end

-- 进入主界面，初次进入游戏或者返回主界面调用 
function MainView:enterMainView(notNeedAnimation)
    Cache.user:updateLoginTipPopValue(true)
    if notNeedAnimation == false then
        self.goto_maching = false
        self:listenEventAction()
        return
    end
    self:playBtnEffect() 
    self:playShopAnimation()
    self:initSunShineAnimate()
    self:playQuickStrartAnimation()
    if not Cache.Config._needJoinAni then 
        self:showAnimation()  
        Cache.Config._needJoinAni = true 
    end
end
    
-- 设置个人基本信息
function MainView:updateUserInfo()
    local UserInfo = Cache.user
    self.playerNickTxt:setString(Util:filter_spec_chars(Util:filterEmoji(UserInfo.nick)))
    self.playerGoldTxt:setString(Util:getFormatString(UserInfo.gold))
    self.playerFocasTxt:setString(UserInfo.fucard_num)
    local levelNum = Util:getLevelNum(Cache.user.all_lv_info.sub_lv)
    
    local maxLevel = Cache.user:getMaxLevel()
    if Cache.user.all_lv_info.match_lv == maxLevel then
        self.levelTitle:setString(Cache.user:getConfigByLevel(Cache.user.ddz_match_level).title)
    else
        self.levelTitle:setString(Cache.user:getConfigByLevel(Cache.user.ddz_match_level).title .. levelNum)
    end
    self.level_img:loadTexture(string.format(GameRes.userLevelImg, math.ceil(Cache.user.ddz_match_level/10)))
end

-- 更新头像
function MainView:updateUserHead()
    self:updateUserHeadView()
end

function MainView:updateUserHeadView()
	if not self.userHead then
        self.userHead = UserHead.new({})
		self.headInfoDetail = self.userHead:getUI()
		self.headInfo:addChild(self.headInfoDetail)
	end
    self.headInfoDetail:setVisible(true)
    
	local headInfoSize = self.headInfo:getContentSize()
	local headInfoDetailSize = self.headInfoDetail:getContentSize()

	self.headInfoDetail:setPosition( -(headInfoDetailSize.width*0.60 - headInfoSize.width)/2,-(headInfoDetailSize.height*0.60 - headInfoSize.height)/2)
    self.headInfoDetail:setScale(0.60)
    
	self.userHead:loadHeadImage(Cache.user.portrait,Cache.user.sex,Cache.user.icon_frame,Cache.user.icon_frame_id)
end

--[[下载图片]]
function MainView:setHeadByUrl(view,url)
    if view == nil or url == nil or url == "" then return end
    local kImgUrl
    if Util:judgeHasHttpSuffex(RESOURCE_HOST_NAME,"http") then
        kImgUrl = RESOURCE_HOST_NAME.."/"..url
	else
        kImgUrl = HOST_PREFIX..RESOURCE_HOST_NAME.."/"..url
    end
    local reg = qf.platform:getRegInfo()
    local taskID = qf.downloader:execute(kImgUrl, 10,
        function(path)
            if not tolua.isnull( self ) then
                view:loadTexture(path)
            end
            view:setVisible(true)
        end,
        function()
        end,
        function()
        end
    )
end
       
-- 延迟方法
function MainView:delayRun(time, cb)
    if time == nil or cb == nil then return end
    self:runAction(
        cc.Sequence:create(cc.DelayTime:create(time), 
            cc.CallFunc:create(function() 
                cb()
            end)
        ))
end
            
            
function MainView:extendBnt(bnt)
    bnt.updateNumber = function (number)
        if number == 0 then bnt.removeNumber() return end
        if number >= 100 then number = 99 end
        local cs = bnt:getContentSize()
        
        local hi = 0 
        if bnt:getTag() == 21 then
            hi = 20
        end
        
        local bg = bnt:getChildByTag(self.BNT_NUMBER_BG_TAG)
        if bg == nil then 
            bg = cc.Sprite:create(GameRes.bnt_number_bg)
            bg:setTag(self.BNT_NUMBER_BG_TAG)
            bg:setPosition(cs.width * 0.9, cs.height * 0.9 + hi)
            bnt:addChild(bg)
        end
        
        if number < 0 then return end
        
        local nl = bnt:getChildByTag(self.BNT_NUMBER_NUMBER_TAG)
        if nl == nil then 
            nl = cc.LabelTTF:create(number .. "", GameRes.font1, 30)
            nl:setPosition(cs.width * (number >= 10 and 0.89 or 0.9), cs.height * 0.9 + hi)
            nl:setTag(self.BNT_NUMBER_NUMBER_TAG)
            bnt:addChild(nl)
        else
            nl:setString(number .. "")
        end 
    end
    
    bnt.removeNumber = function ()
        bnt:removeChildByTag(self.BNT_NUMBER_BG_TAG)
        bnt:removeChildByTag(self.BNT_NUMBER_NUMBER_TAG)
    end
end
            
-- 设置界面是否可点击
function MainView:setTouch(isCantouch)
    self.setAllTouch = function(root)
        for k, v in pairs(root:getChildren())do
            if v.setTouchEnabled then
                if v:isTouchEnabled() and not isCantouch then
                    v:setTouchEnabled(isCantouch)
                    v.cansetTouch = true
                elseif v.cansetTouch then
                    v.cansetTouch = nil
                    v:setTouchEnabled(isCantouch)
                end
            end
            self.setAllTouch(v)
        end
    end
    self.setAllTouch(self.root)
end
            
--播放入场动画
function MainView:showAnimation()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    self:setTouch(false)
    self.root:stopAllActions()

    self:playerPAnimate()
    self:topToolAnimate()
    self:buttonPannelAnimate()
    self:leftToolsAnimate()
    self:gameChooseAnimate()
end

function MainView:playerPAnimate()
    --用户信息
    local positionX = self.playerP.pos.x
    local positionY = self.playerP.pos.y
    local move_back= cc.MoveTo:create(0, cc.p(positionX, positionY + 500))
    self.playerP:runAction(move_back)

    local move_back = cc.MoveTo:create(0.6, cc.p(positionX, positionY - 500))
    local ease = cc.EaseElasticOut:create(move_back,0.98)
    self.playerP:runAction(ease)
end

function MainView:topToolAnimate()
    local positionX = self.topTools.pos.x 
    local positionY = self.topTools.pos.y 
    local move_back =  cc.MoveTo:create(0, cc.p(positionX, positionY + 500))
    self.topTools:runAction(move_back)
    local move_back = cc.MoveTo:create(0.6, cc.p(positionX, positionY - 500))
    local ease = cc.EaseElasticOut:create(move_back,0.98)
    self.topTools:runAction(ease)
end

function MainView:buttonPannelAnimate()
    --按钮栏
    local positionX = self.button_panel.pos.x 
    local positionY = self.button_panel.pos.y 
    local move_back =  cc.MoveTo:create(0, cc.p(positionX, positionY - 400))
    self.button_panel:runAction(move_back)
    local move_back = cc.MoveTo:create(0.6, cc.p(positionX, positionY + 400))
    local ease = cc.EaseElasticOut:create(move_back,0.98)
    self.button_panel:runAction(ease)
end

function MainView:leftToolsAnimate()
    local positionX1 = self.leftTools.pos.x 
    local positionY1 = self.leftTools.pos.y 
    local move_back1 =  cc.MoveTo:create(0, cc.p(positionX1 - 300, positionY1))
    self.leftTools:runAction(move_back1)
    local move_back2 = cc.MoveTo:create(0.6, cc.p(positionX1 + 300, positionY1))
    local ease1 = cc.EaseElasticOut:create(move_back2,0.9)
    self.leftTools:runAction(ease1)
end

function MainView:gameChooseAnimate()
    local positionX = self.gameChoose_pannel.pos.x 
    local positionY = self.gameChoose_pannel.pos.y
    local move_back =  cc.MoveTo:create(0, cc.p(positionX + 1000, positionY))
    self.gameChoose_pannel:runAction(move_back)
    local move_back = cc.MoveTo:create(0.6, cc.p(positionX - 1000, positionY))
    local ease = cc.EaseElasticOut:create(move_back,0.9)
    self.gameChoose_pannel:runAction(ease)
end

-- 播放主页按钮特效
function MainView:playBtnEffect()
    local broadcast_txt_func = cc.CallFunc:create(function ()
        if not self.has_broadcast_txt then
            self.has_broadcast_txt = true
            qf.event:dispatchEvent(ET.SETBROADCAST, {x = 0, y = -148})
            qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_TXT) --回到主界面接收世界广播
            
        end
    end)
    local broadcast_layout_func = cc.CallFunc:create(function ()
        if not self.has_broadcast_layout then
            self.has_broadcast_layout = true
            qf.event:dispatchEvent(ET.SETBROADCAST, {x = 0, y = -148})
            qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_LAYOUT)
        end
    end)
    
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1)
        , cc.DelayTime:create(4.0)
        , broadcast_txt_func
        , cc.DelayTime:create(1.0)
    , broadcast_layout_func))
    
    local winSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local radio = winSize.height / winSize.width
    GAME_RADIO = radio
    if radio > 0.5625 then 
        FORCE_ADJUST_GAME = true
    end
    
    GAME_SCALE = 0.5625 / GAME_RADIO
    
    --self.gameslistP:setScale(GAME_SCALE)
end
            
--播放商城按钮动画
function MainView:playShopAnimation()
    -- if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
    --     return
    -- end
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.main_new_shop)
    local turnicon = ccs.Armature:create("NewAnimation_shop")
    self.shopBtn:addChild(turnicon, 0)
    --self.shopBtn:setName("turnArmature_shop")
    turnicon:setPosition(self.shopBtn:getContentSize().width / 2, self.shopBtn:getContentSize().height / 2)
    turnicon:getAnimation():playWithIndex(0)

    local size = self.shopBtn:getContentSize()
    local particle = cc.ParticleSystemQuad:create(GameRes.img_main_shop_particle)
    particle:setTexture(cc.Director:getInstance():getTextureCache():addImage(GameRes.img_main_shop_particle_texture))
    particle:setStartSize(20)
    particle:setSpeed(50)
    particle:setTotalParticles(15)
    particle:setPosition(size.width / 2, size.height / 2)
    self.shopBtn:addChild(particle)
    particle:setVisible(false)

    local move_length = 30
    local action = cc.Sequence:create(
        cc.DelayTime:create(2),
        cc.CallFunc:create(function()
            particle:setVisible(true)   -- step2, 粒子
        end),
        cc.MoveBy:create(0.3, cc.p(-move_length, 0)),
        cc.MoveBy:create(0.2, cc.p(move_length, 0)), -- step3, 移动
        cc.DelayTime:create(2) ,
        cc.CallFunc:create(function()
            particle:setVisible(false)   -- step2, 粒子
        end),       
        cc.DelayTime:create(1)
    )
    local repeat_action=cc.RepeatForever:create(action)
    self.shopBtn:runAction(repeat_action)

end

--播放商城按钮动画
function MainView:playQuickStrartAnimation()
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.quickStart)
    local turnicon = ccs.Armature:create("quickStart")
    self.quickStartBtn:addChild(turnicon, 0)
    turnicon:setPosition(self.quickStartBtn:getContentSize().width / 2, self.quickStartBtn:getContentSize().height / 2)
    turnicon:getAnimation():playWithIndex(0)

    local quickGame = self.quickStartBtn:getChildByName("quickGame")
    quickGame:setString("")
    quickGame:setPosition(120,55)

    qf.event:dispatchEvent(ET.GET_QUICK_START_ROOMID,{cb = function (rsp)
        local model = rsp.model
        if model then
            if model.room_id > 0 then
                self.quickRoomId = model.room_id
                self:setQuickStartGameName()
            end
        end
    end})
end

function MainView:setQuickStartGameName()
    local roomConfigArr  = Cache.DDZconfig:getRoomConfigByType(GAME_DDZ_CLASSIC)
    for index = 1, #roomConfigArr do
        local info = roomConfigArr[index]
        if self.quickRoomId and info.room_id == self.quickRoomId then
            self.quickName = "经典 "
            if info.room_type == 3 then
                self.quickName = "不洗牌 "
            end
            self.quickName = self.quickName..info.room_name
        end
    end
    local quickGame = self.quickStartBtn:getChildByName("quickGame")
    quickGame:setString(self.quickName)
end

function MainView:tuiguangAni(  )
    if not TB_MODULE_BIT.BOL_MODULE_BIT_TUIGUANG or not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    qf.event:dispatchEvent(ET.GET_PROMOTE_INFO)
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.tuiguangAni)
    local tuiguangAni = ccs.Armature:create("tuiguangAnimate")
    tuiguangAni:setPosition(tuiguangAni:getContentSize().width/2,tuiguangAni:getContentSize().height/2 - 4)
    ccui.Helper:seekWidgetByName(self.root,"fire"):addChild(tuiguangAni,0)
    tuiguangAni:getAnimation():playWithIndex(0)
    addButtonEvent(ccui.Helper:seekWidgetByName(self.root,"fire"), function (sender)
        tuiguangAni:setScale(1.0)
        qf.event:dispatchEvent(ET.SHOW_TUIGUANG_VIEW)
        qf.platform:uploadEventStat({
            module = "app_share",
            source = "appwxddz",
            event = STAT_KEY.PYWXDDZ_EVENT_SHARE_POP,
            value = 1,
        })
    end, function ()
        tuiguangAni:setScale(1.1)
    end, nil, function ()
        tuiguangAni:setScale(1.0)
    end)

    self.tuiguangQipao = cc.Sprite:create(GameRes.tuiguangQipao)
    tuiguangAni:addChild(self.tuiguangQipao, 100)
    self.tuiguangQipao:setPosition(cc.p(90, 55))

    local txt = ccui.Text:create("有钱领",GameRes.font1,28)
    self.tuiguangQipao:addChild(txt)
    txt:setColor(cc.c3b(251, 237, 182))
    txt:setPosition(cc.p(self.tuiguangQipao:getContentSize().width / 2, self.tuiguangQipao:getContentSize().height / 2 + 1))

    self.tuiguangQipao:setVisible(false)

    qf.event:dispatchEvent(ET.TUIGUANGINFO_REQ)
end

function MainView:updateTuiGuangQiPao(  )
    local tuiguangInfo = Cache.Config:getTuiGuangInfo()

    if tuiguangInfo and tuiguangInfo.is_reward then
        self.tuiguangQipao:setVisible(true)
    else
        self.tuiguangQipao:setVisible(false)
    end
end

function MainView:firstPayBtnAni(  )
    if not Cache.user.firstChargeConfInfo  or not Cache.user.firstChargeConfInfo.hasEntryControl or not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
    self.shouChong = ccui.Helper:seekWidgetByName(self.topTools,"shouChong")
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.firstPayAni)
    local firstPayBtnAni = ccs.Armature:create("firstPay")
    firstPayBtnAni:setPosition(firstPayBtnAni:getContentSize().width/2,firstPayBtnAni:getContentSize().height/2 + 10)
    self.shouChong:addChild(firstPayBtnAni,0)
    firstPayBtnAni:getAnimation():playWithIndex(0)
    
    self.shouChong.tag = 12980

    addButtonEvent(self.shouChong, function (sender)
        firstPayBtnAni:setScale(1.0)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅新手礼包") end
        qf.event:dispatchEvent(ET.SHOW_FIRSTRECHARGE_POP)
        qf.platform:umengStatistics({umeng_key = "firstRecharge"})--点击上报
    end, function ()
        firstPayBtnAni:setScale(1.1)
    end, nil, function ()
        firstPayBtnAni:setScale(1.0)
    end)
end

function MainView:showCaiDaiAni( ... )
    for k=1,8 do
        local sprite = cc.Sprite:create(string.format(DDZ_Res.caiDai,math.random(1,4)))
        sprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(2,math.random(-300,300))))
        local ani = function( sprite )
            sprite:runAction(cc.Sequence:create(cc.MoveTo:create(0,cc.p(math.random(200,1720),1200)),
                cc.DelayTime:create(math.random(0,50)*0.1),
                cc.MoveBy:create(5,cc.p(0,-1300)),cc.CallFunc:create(function( ... )
                    sprite.ani(sprite)
            end)))
        end
        sprite.ani = ani
        ani(sprite)
        self:addChild(sprite,999)
    end
end

--删除首充入口
function MainView:removefirstRechargeEntry( ... )
    local upAreaBtnsTemp = {}
    self.shouChong:setVisible(false)
    self.shouChong:setTouchEnabled(false)
end

--奖券兑换的提示
function MainView:ticketChargeTips( ... )
    -- self.ticketTips:setVisible(false)
    -- self.ticketTipList = self.ticketTips:getChildByName("ticketProductList")
    -- self.item_tipTicket = ccui.Helper:seekWidgetByName(self.root,"item_tipTicket")
    local match_login_tipShow = cc.UserDefault:getInstance():getIntegerForKey("ddz_login_tipShow_"..Cache.user.uin,0)
    if match_login_tipShow ~= 1 then
       return
    end
    
    cc.UserDefault:getInstance():setIntegerForKey("ddz_login_tipShow_"..Cache.user.uin,0)

    qf.event:dispatchEvent(ET.GET_EXCHANGEMALL_INFO,{cb = function (isGetSuccess)
        if isGetSuccess then
            self:reloadTicketTipList()
        end
    end})
end

function MainView:reloadTicketTipList( )
    local listData = Cache.ExchangeMallInfo:getClassifyList()
    local tipListData = {}
    self:clearTicketTimer()
    for k,v in pairs(listData) do
        for j,v in pairs(v.goods) do
            -- if #tipListData < 7 then
            if v.is_shuffling == 1 then
                table.insert(tipListData,v)
            end
        end
    end

    if #tipListData == 0 then return end
    self.ticketTips:setVisible(true)
    self.ticketTipList:setItemModel(self.item_tipTicket)

    self.btn_cover = self.ticketTips:getChildByName("btn_cover")
    self.btn_cover:setVisible(true)

    local size = self.ticketTips:getContentSize()
    local size_list = self.ticketTipList:getContentSize()
    local size_btn = self.btn_cover:getContentSize()

    if #tipListData == 1 then
        self.ticketTips:setContentSize(size.width / 2 , size.height)
        self.ticketTipList:setContentSize(size_list.width / 2, size_list.height)
        self.btn_cover:setContentSize(size_btn.width / 2, size_btn.height)
    end

    local index = 1
    for k,v in pairs(tipListData) do
        self.ticketTipList:pushBackDefaultItem()
        local item = self.ticketTipList:getItem(index -1)
        item:setVisible(true)
        self:updateItem(v,item,index)
        index = index + 1
    end
    self:ticketListSchedule(#tipListData)
    addButtonEvent(self.btn_cover , function ()
        self:enterFocaRechargeView()
    end)
end

--记牌器的倒计时时间
function MainView:ticketListSchedule(totolCount)
    if totolCount < 3 then
        return
    end
    self.ticketScrollPersent = 0
    self.tickeTime=Scheduler:scheduler(2.0,function ()
    	self:updateTicketScroll(totolCount)
    end)
end

function MainView:updateTicketScroll(totolCount)
    self.ticketScrollPersent = self.ticketScrollPersent + 100/(totolCount - 2)
    if self.ticketScrollPersent > 100 then
        self.ticketScrollPersent = 0
    end
    self.ticketTipList:scrollToPercentHorizontal(self.ticketScrollPersent,0.5,false)
end

--清除定时器
function MainView:clearTicketTimer()
    if self.tickeTime then
        Scheduler:unschedule(self.tickeTime)
        self.tickeTime=nil
    end
end

function MainView:updateItem(info, item,index)
    local product = item:getChildByName("product")
    if index == 1 then
        item:getChildByName("itemSeperate"):setVisible(false)
    else
        item:getChildByName("itemSeperate"):setVisible(true)
    end
    -- 加载商品图片
    if info.icon and info.icon ~= "" then
        qf.downloader:execute(info.icon, 10,
            function(path)
                if isValid( item ) then
                    product:loadTexture(path)
                end
            end,function() end,function() end
        )
    end

    addButtonEvent(item , function ()
        self:enterFocaRechargeView()
    end)
end

function MainView:enterFocaRechargeView()
    self.ticketTips:setVisible(false)
    self.ticketTipList:removeAllChildren()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击兑换中心") end
    if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW and TB_MODULE_BIT.BOL_MODULE_BIT_EXCHANGE_FUCARD then 
        qf.event:dispatchEvent(ET.SHOW_EXCHANGEMALL_VIEW)
    end
end

function MainView:exit()
    if self.guangSchedule then
        Scheduler:unschedule(self.guangSchedule)
        self.guangSchedule = nil
    end
    if self.turntime then
        Scheduler:unschedule(self.turntime)
        self.turntime = nil
    end

    if self.turnicontime then
        Scheduler:unschedule(self.turnicontime)
        self.turnicontime = nil
    end

    if self.sunShineSchedule then
        Scheduler:unschedule(self.sunShineSchedule)
        self.sunShineSchedule = nil
    end

    self:clearTicketTimer()
    MusicPlayer:stopMusic()
end

return MainView