--[[
    重要提示!!! 140版本开始:
    (1) 强制所有PopupWindow都加载在PopupLayer上, 非弹框node不允许加在该layer上
    (2) 继承自 qf.view 的类，如果是弹框类型，getRoot要返回LayerMananger.PopupLayer
    (3) 弹出框背景名为"LAYERMANAGER_POPUP_BACKGROUND", 其他控件不要重名
]]
local PM = class("PM")

--===================================
--弹框在此定义
--===================================
PM.POPUPWINDOW_START=4000
PM.POPUPVIEW_START=8000
--这里的弹框是一个普通的node或者layer，不加入模块管理
PM.POPUPWINDOW = enum(PM.POPUPWINDOW_START,
    "background",
    "userinfo",
    "shopPromit",   --快捷支付
    "bankruptcy",   --破产弹框
    "activeNotice",   --活动通知
    "createRoom",      --创建房间
    "searchRoom",       --搜索房间
    "customizeCreateRoom", --私人定制创建房间
    "phoneBinding",    --绑定手机
    "passwordView",
    "heGuanDialog",
    "brPerson",
    "brDelarList",
    "inviteView",
    "sampleInviteView",
    "gallery",
    "gameLevelUp",
    "exitDialog",
    "lockDesk",
    "scoreExchange",
    "goodDetailView",           --物品详情框
    "vipDetailView",            --VIP详情
    "buyPopupTipView",          --购买提示框
    "payMethodView",            --支付方式框
    "commonTipWindow2",           --公共提示框-- 标题、内容、取消、确认
    "commonTipWindow7", --公共提示框-- 标题、内容、告辞、充值
    "commonTipWindow6",
    "dailylogin",
    "installgame",
    "winningstreak",
    "lackgold",
    "turntable",
    "newtotallogin",
    "firstgame",
    "freegoldshortcut",
    "visitortips",
    "realname",
    "BannerPop",
    "inviteGameTips",
    "RechargeTips",
    "FirstRecharge",
    "bankruptTips",
    "GameRule",
    "GameEnd",
    "NormalGameEnd",
    "GameUserInfo",
    "MatchingResult",
    "RedPackageRewardView",
    "newFirstGame",
    "GameTaskView",
    "MyHeadBox",
    "EventGameEnd",
    "MatchingReport",
    "MatchingHonor",
    "GameEndBox",
    "MatchingRank",
    "ShopView",
    "ShopToolDetailView",
    "TuiGuangMainView",
    "TuiGuangRuleView",
    "TuiGuangOfficalView",
    "TuiGuangFriendInfoView",
    "ExchangeDetail",
    "ExchangeShortage",
    "GetGoods",
    "GameExit",
    "newUserInfo"
)
--[[
    这里的弹窗是一个moudle， 名字要与ModuleManager中定义的一致
    例如: module中定义， self.setting = settingModule.new(), setting是一个弹窗，那么要加入这里:"setting"
]]
PM.POPUPVIEW = enum(PM.POPUPVIEW_START,
    "setting", 
    "prize",
    "rank",
    "daoju",
    "change_userinfo",
    "gift",
    "shop",
    "share",
    "activity",
    "popularize",
    "matching",
    "exchange"
)
--===================================
--以下代码不要随意修改
--===================================
PM.DEBUG = false
PM.TAG = "PopupMananger"
PM.BG_STYLE = enum(0, "NONE", "BLUR", "GREY", "DARK", "HIGHLIGHT")
PM.STATUS = enum(0, "NORMAL", "UPWARD")
PM.ACTION_TAG = 8001
PM.DEFAULT_BLUR_RADIUS = 10
PM.DEFAULT_HIGHLIGHT_INCREMENT = 50

function PM:ctor()
    self.winSize = cc.Director:getInstance():getWinSize()
    self.status = PM.STATUS.NORMAL
end

--===================================
--Public Interface
--===================================
--设置弹框层大小和位置
function PM:init()
    self.root = LayerManager.PopupLayer
    self.root:setContentSize(self.winSize.width, self.winSize.height)
    self.root:setAnchorPoint(cc.p(0, 0))
    self.root:setPosition(cc.p(0, 0))
    self.root:setVisible(true)
    self.zorder = self.root:getZOrder()

    self.queue = {} --待打开的
    self.queue_num = 0
    self.stack = {} --已经创建的界面
    self.stack_num = 0
end

--获取弹框所在层
function PM:getPopupLayer()
    return self.root
end

--添加一个弹框
function PM:addPopupWindow(id, windowNode)
    if id < PM.POPUPVIEW_START and self.root:getChildByTag(id) ~= nil then
        self.root:removeChildByTag(id)  --如果存在相同弹窗，先移除
    end
    self.root:addChild(windowNode, 0, id)
end

--获取弹框对象
function PM:getPopupWindow(id)
    return self.root:getChildByTag(id)
end

--显示/添加弹框背景(在弹框弹出时调用)
function PM:checkShowBackground(id, style, cb)
    if id==PM.POPUPWINDOW["payMethodView"] then 
        if cb then cb() end
        return 
    end
    self:_removeBackground()
    style = self.BG_STYLE.DARK
    if qf.device.platform ~= "windows" and 
        (id==PM.POPUPWINDOW["turntable"] or 
        id==PM.POPUPWINDOW["newtotallogin"] or 
        id==PM.POPUPWINDOW["visitortips"])  then
        style = self.BG_STYLE.BLUR
    elseif id == PM.POPUPWINDOW["freegoldshortcut"] or 
        PM.POPUPVIEW["setting"]==id or  
        PM.POPUPVIEW["prize"]==id or  
        PM.POPUPVIEW["popularize"]==id or 
        PM.POPUPVIEW["rank"]==id or  
        PM.POPUPVIEW["daoju"]==id or 
        PM.POPUPVIEW["shop"]==id or 
        PM.POPUPVIEW["activity"]==id then
        style = self.BG_STYLE.BGIMG
    end
    self:reset(id)

    if qf.device.platform ~= "ios" and style ~= self.BG_STYLE.NONE then --目前只有ios支持高斯模糊背景，其他平台暂时使用暗背景
        self:_log("目前只有IOS平台支持弹窗背景. 非IOS平台不能添加背景.")
        style = self.BG_STYLE.DARK
    end

    local bg = self.root:getChildByTag(self.POPUPWINDOW.background)
    if bg ~= nil then
        --如果背景存在, 直接设置可见
        if not bg:isVisible() then
            self:_backgroundFadeIn()
        end
        if cb then cb() end   
    else
        if style == self.BG_STYLE.BLUR then
            QNative:shareInstance():getScreenBlurSprite(function(success, sprite)
                if success and sprite ~= nil then
                    self:_addBackgroundSprite(sprite)
                end
                if cb then cb() end
            end, false, self.DEFAULT_BLUR_RADIUS)
        elseif style == self.BG_STYLE.GREY then
            QNative:shareInstance():getScreenGraySprite(function(success, sprite)
                if success and sprite ~= nil then
                    self:_addBackgroundSprite(sprite)
                end
                if cb then cb() end
            end, true)
        elseif style == self.BG_STYLE.DARK then
            local sprite = cc.LayerColor:create(cc.c4b(0x00, 0x00, 0x00, 0x7d), self.winSize.width, self.winSize.height)
            --cc.Sprite:create(GameRes.common_widget_dark_bg)
            self:_addBackgroundSprite(sprite, true)
            if cb then cb() end
        elseif style == self.BG_STYLE.BGIMG then
            local sprite = cc.Sprite:create(GameRes.mohubg)
            self:_addBackgroundSprite(sprite)
            if cb then cb() end
        elseif style == self.BG_STYLE.HIGHLIGHT then
            QNative:shareInstance():getScreenHighlightSprite(function(success, sprite)
                if success and sprite ~= nil then
                    self:_addBackgroundSprite(sprite)
                end
                if cb then cb() end
            end, false, self.DEFAULT_HIGHLIGHT_INCREMENT)
        else
            if cb then cb() end
        end
    end
end

--隐藏/移除弹框背景(在弹框关闭时调用)
function PM:checkRemoveBackground()
    self:setTouchLayerEnabled(false)
    local visible = false
    local children = self.root:getChildren()
    for k, child in pairs(children) do
        local tag = child:getTag()
        if tag ~= self.POPUPWINDOW.background and child:isVisible() then
            self:_log("还存在弹框，保留背景. tag="..tostring(tag))
            visible = true
            break
        end
    end
    if not visible then
        self:_log("所有弹框都被关闭了，移除背景")
        self:_removeBackground() --如果所有child都不可见,就将背景移除.
    end
    return visible
end

--移除所有弹框(如果modules的view不是一个弹窗，那么在其remove的时候，要调用这个接口)
function PM:removeAllPopup()
    
    self:setTouchLayerEnabled(false)
    self:_removeAllOtherChlid()
    self.root:setPosition(0, 0)
    self.root:setZOrder(self.zorder)
    self.root:setVisible(true)

    self.stack = {}
    self.stack_num = 0
end

--收起所有弹框
function PM:upwardAllPopup()
    if self.root:getActionByTag(PM.ACTION_TAG) then --如果有其他动作正在进行，打断并直接设置位置，防止动画出错
        self.root:stopActionByTag(PM.ACTION_TAG)
        self.root:setPosition(0, self.winSize.height)
        self:_setBgVisible(false)
        self:setTouchLayerEnabled(false)
    elseif self:checkRemoveBackground() and self.status == PM.STATUS.NORMAL then
        self:_setBgVisible(false)
        local action = cc.Sequence:create(
            cc.MoveTo:create(0.3, cc.p(0, self.winSize.height)),
            cc.CallFunc:create(function()
                self.root:setZOrder(-1)
                self.root:setVisible(false)
                self:setTouchLayerEnabled(false)
            end))
        action:setTag(PM.ACTION_TAG)
        self.root:runAction(action)
        self.status = PM.STATUS.UPWARD
        self:setTouchLayerEnabled(true)
    end
end

--拉回所有弹框
function PM:downwardAllPopup()
    self:setTouchLayerEnabled(false)
    if self.root:getActionByTag(PM.ACTION_TAG) then --如果有其他动作正在进行，打断并直接设置位置，防止动画出错
        self.root:stopActionByTag(PM.ACTION_TAG)
        self.root:setPosition(0, 0)
        self:_setBgVisible(true)
    elseif self:checkRemoveBackground() and self.status == PM.STATUS.UPWARD then
        self.root:setZOrder(self.zorder)
        self.root:setVisible(true)
        local action = cc.Sequence:create(
            cc.MoveTo:create(0.3, cc.p(0, 0)),
            cc.CallFunc:create(function()
                self:_setBgVisible(true)
            end)
        )
        action:setTag(PM.ACTION_TAG)
        self.root:runAction(action)
    else
        self.root:setPosition(0, 0)
    end
    self.status = PM.STATUS.NORMAL
end

--===================================
--Private Function(外部禁止调用)
--===================================
--移除背景
function PM:_removeBackground()
    if self.root:getChildByTag(self.POPUPWINDOW.background) then
        self.root:removeChildByTag(self.POPUPWINDOW.background)
    end
end

--背景慢慢出现效果
function PM:_backgroundFadeIn()
    local bg = self.root:getChildByTag(self.POPUPWINDOW.background)
    if bg ~= nil and bg:getNumberOfRunningActions() == 0 then
        bg:setVisible(true)
        bg:setOpacity(155)
        bg:runAction(cc.FadeTo:create(0.2, 255))
    end
end

function PM:_setBgVisible(visible)
    local bg = self.root:getChildByTag(self.POPUPWINDOW.background)
    if bg then
        bg:setVisible(visible)
    end
end

--添加背景精灵
function PM:_addBackgroundSprite(node, islayer)
    if node ~= nil then
        if islayer then
            self.root:addChild(node, -1, self.POPUPWINDOW.background)
            return
        end
        local size = node:getContentSize()
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setPosition(cc.p(self.winSize.width / 2, self.winSize.height / 2))
        node:setScaleX(self.winSize.width / size.width)
        node:setScaleY(self.winSize.height / size.height)
        self.root:addChild(node, -1, self.POPUPWINDOW.background)
        self:_backgroundFadeIn()
    end
end

--移除..之外的所有子节点. id == nil 时移除所有子节点
function PM:_removeAllOtherChlid(id)
    local children = self.root:getChildren()
    for k, child in pairs(children) do
        local tag = child:getTag()
        if id == nil or id ~= tag then
            if tag >= PM.POPUPVIEW_START then
                --这是一个模块，必须调用Module.remove来移除
                local key = self:getTagKey(tag, PM.POPUPVIEW)
                if key ~= nil and ModuleManager[key] ~= nil then
                    ModuleManager[key]:remove()
                    self:_log("从弹窗层移除一个Module: "..tostring(key))
                else
                    loge("!! 弹窗管理尝试移除一个未知tag的moudle. tag="..tostring(tag))
                end
            elseif tag == PM.POPUPWINDOW_START then
                --背景直接移除
                self:_log("从弹窗层移除背景")
                self.root:removeChildByTag(tag)
            else
                --弹窗，调用析构函数 destructor
                local key = self:getTagKey(tag, PM.POPUPWINDOW)
                if key ~= nil then 
                    self:_log("从弹窗层移除一个 Node "..key) 
                    child:destructor()
                else
                    loge("!! 弹窗管理尝试移除一个未知tag的子节点. tag="..tostring(tag))
                end
                self.root:removeChildByTag(tag)
            end
        end
    end
end

function PM:getTagKey(tag, tab)
    for k,v in pairs(tab) do
        if v == tag then
            return k
        end
    end
end

--在打开一个新的弹框时调用，如果PopupLayer是向上收起状态，移除所有其他的弹窗
function PM:reset(id)
    self:_log("打开了新的弹窗. 当前状态: "..tostring(self.status))
    self:setTouchLayerEnabled(false)
    if self.root:getActionByTag(PM.ACTION_TAG) then --如果有正在向上拉/向下收的动作，先停止
        self:_log("停止动画")
        self.root:stopActionByTag(PM.ACTION_TAG)
    end
    local y = self.root:getPositionY()
    if (self.status == PM.STATUS.UPWARD) or (y ~= 0) or (not self.root:isVisible()) or (self.root:getZOrder() ~= self.zorder) then
        self:_log("目前PopupLayer被移动到了屏幕外, 移除所有屏幕外的弹框, 再打开新的弹框")
        self:_removeAllOtherChlid(id)
        self.root:setPosition(0, 0)
        self.root:setZOrder(self.zorder)
        self.root:setVisible(true)
        self.status = PM.STATUS.NORMAL
    end
end

function PM:_log(str)
    --if PM.DEBUG then loga("["..PM.TAG.."]"..str) end
    if PM.DEBUG then logd(str, PM.TAG) end
end

--当弹窗层在移动时，覆盖在上面吞噬点触
function PM:setTouchLayerEnabled(visible)
    if visible then
        if self.touch_layer == nil then
            self.touch_layer = cc.Layer:create()
            self.touch_layer:setContentSize(self.winSize.width, self.winSize.height)
            self.root:addChild(self.touch_layer, 100)

            local listener = cc.EventListenerTouchOneByOne:create()     
            listener:setSwallowTouches(true)
            listener:registerScriptHandler(function(touch, event)
                    return true
                end, cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(function(touch, event) end,
                cc.Handler.EVENT_TOUCH_MOVED)
            listener:registerScriptHandler(function(touch, event) end,
                cc.Handler.EVENT_TOUCH_ENDED)

            self.touch_layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.touch_layer)
        end
    else
        if self.touch_layer ~= nil and not tolua.isnull(self.touch_layer) then
            self.touch_layer:removeFromParent(true)
            self.touch_layer = nil
        end
    end
end

--处理弹窗数据
function PM:genData( paras )
    local class = paras.class
    local event = paras.event
    local show_cb = paras.show_cb or nil
    local pop_action = paras.pop_action or false
    local show_type = paras.show_type or 0
    local priority = paras.priority or false --是否在弹窗关闭时优先弹出新弹窗,而不是显示原先未关闭弹窗
    local init_data = paras.init_data or {}

    init_data.uid = getUID()
    init_data.pop_action = pop_action

    local data = {
        class = class,
        event = event,
        show_cb = show_cb,
        show_type = show_type,
        priority = priority,
        init_data = init_data
    }

    return data
end

--[[将弹窗加入弹窗队列中
    paras:  class 弹窗类名
            event 弹窗事件名

    index: 插入队列位置
]]--
function PM:push( paras, index )
    if not paras then return end
    if not paras.class and not paras.event then return end

    local data = self:genData(paras)

    if not index or type(index) ~= "number" or index > self.queue_num or index < 1 
        then
        table.insert(self.queue, data)
    else
        table.insert(self.queue, index, data)
    end

    self.queue_num = self.queue_num + 1

    return data.init_data.uid
end

--[[按队列弹出弹窗
    stay: 当当前有弹窗显示，则不弹出新弹窗
]]--
function PM:pop(stay)
    stay = stay or false

    if self.queue_num <= 0 then return end

    if self.stack_num > 0 then
        local window = self.stack[self.stack_num]

        if window:isVisible() then
            local t = self.queue[1]

            if stay or (window.TOP and (t.class and not t.class.TOP)) then
                return
            end
        end
    end

    local t = self.queue[1]
    table.remove( self.queue,1 )
    self.queue_num = self.queue_num - 1

    if t.show_type == 0 then --打开窗口类
        self:_hide(t)
        self:_unique(t)
        self:_show(t)
    elseif t.show_type == 1 then --派发事件
        qf.event:dispatchEvent(t.event, t.init_data)
    end
end

--显示弹窗
function PM:_show( t )
    local window = t.class.new(t.init_data)
    table.insert( self.stack,window )
    self.stack_num = self.stack_num + 1

    window:show(t.show_cb)
    self.root:addChild(window, 0, window._uid)

    self:checkBackground()
end

--隐藏弹窗 判断窗口属性是否常驻 ALWAYS_SHOW
function PM:_hide( t )
    if self.stack_num > 0 then
        local window = self.stack[self.stack_num]

        if not window.ALWAYS_SHOW then
            window.autoHide = true
            window:hideWithoutAction() --隐藏弹窗
        end
    end
end

--排除相同弹窗 判断窗口是否可同时打开多个 UNIQUE
function PM:_unique( t )
    if self.stack_num > 0 then
        for i = 1, self.stack_num do
            if t.class.__cname == self.stack[i].__cname and self.stack[i].UNIQUE then
                self.stack[i]:removeFromParent()
                table.remove( self.stack,i )
                self.stack_num = self.stack_num - 1
                break
            end
        end
    end
end

--根据uid移除弹窗
function PM:remove(uid)
    if uid then
        if type(uid) == "table" then
            for k, v in pairs(uid) do
                self:_remove(v)
            end
        else
            self:_remove(uid)
        end
    end

    self:check()

    self:checkBackground()
end

function PM:_remove(uid)
    if uid then
        for i = 1, self.stack_num do
            if self.stack[i]._uid == uid then
                if isValid(self.stack[i]) then
                    self.stack[i]:removeFromParent()
                end

                table.remove( self.stack,i )
                self.stack_num = self.stack_num - 1
                break
            end
        end
    end
end

--检测队列中是否有下个界面展示
function PM:check()
    if self.stack_num > 0 then
        --申请置顶界面存在并显示不进行下步
        if isValid(self.stack[self.stack_num]) and self.stack[self.stack_num].TOP and self.stack[self.stack_num]:isVisible() then
            return
        end
        for i = 1, self.stack_num do
            local window = self.stack[i]
            if isValid(window) and window.autoHide then
                --自动隐藏的弹窗自动打开
                window:show()
                return
            end
        end
    end

    --优先打开优先弹出
    if self.queue_num > 0 and self.queue[1].priority then
        self:_prepare()
        return
    end

    --检测是否有先前隐藏的界面
    if self.stack_num > 0 then
        for i = 1, self.stack_num do
            local window = self.stack[i]
            if isValid(window) and window.autoHide then
                --自动隐藏的弹窗自动打开
                window.autoHide = false
                window:show()
                return
            end
        end
    end

    if self.stack_num == 0 then
        qf.event:dispatchEvent(ET.REFRESH_LISTEN)
    end
    self:_prepare()
end

--延迟调用pop
function PM:_prepare( ... )
    self:pop()
    -- if self.scheduler_prepare then return end
    -- self.scheduler_prepare = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
    --     self.scheduler_prepare = nil
    --     self:pop()
    -- end, 0, false)
end

--根据UID获取弹窗
function PM:getPopupWindowByUid(uid)
    if not uid then return end

    for i = 1, self.stack_num do
        if isValid(self.stack[i]) and self.stack[i]._uid == uid then
            return self.stack[i]
        end
    end

    return nil
end

--清理弹窗 和 弹窗队列
function PM:clean(  )
    self.queue = {}
    self.queue_num = 0

    self:removeAllPopup()

    self:checkBackground()
end

function PM:checkBackground(  )
    if not isValid(self.background) then
        self.background = cc.LayerColor:create(cc.c4b(0x00, 0x00, 0x00, 0x7d), self.winSize.width, self.winSize.height)
        self.root:addChild(self.background, -1, self.POPUPWINDOW.background)
    end

    --当前有窗口显示时 设置背景为true
    for i = 1, self.stack_num do
        if self.stack[i]:isVisible() then
            self.background:setVisible(true)
            return
        end
    end

    self.background:setVisible(false)
end

PopupManager = PM.new()
