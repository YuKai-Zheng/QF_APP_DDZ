
--[[
    click use head 
    pop up this panel
]]


--GLOBAL_SHOW_USER_INFO 事件新增参数说明: 
--[[
hide_enabled: (true/false)是否支持隐身, 默认为false. 如果支持隐身, 用户信息将按照hiding显示
hide_nick: 隐身后的昵称. 不设置则使用默认隐身后的昵称“神秘人”
]]

local UserInfo = class("UserInfo", CommonWidget.BasicWindow)

UserInfo.TAG = "UserInfo"
UserInfo.NODE_TAG = 232323
local HeadImage = require("src.modules.global.components.big_head_image.HeadImage")
function UserInfo:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    UserInfo.super.ctor(self, paras)
end

function UserInfo:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.userInfoJson)
    self.btnAddFriend = ccui.Helper:seekWidgetByName(self.gui, "btn_add_friend")
    self.isFriendImg = ccui.Helper:seekWidgetByName(self.gui, "isFriend")
    self.btnAddFriend:setVisible(false)
    self.imgHeadBg = ccui.Helper:seekWidgetByName(self.gui, "head_bg")
    self.imgHead = ccui.Helper:seekWidgetByName(self.gui, "head")
    --self.imgHead:setVisible(false)
    
    self.itemInfoNick = ccui.Helper:seekWidgetByName(self.gui, "item_info_nick")
    self.itemInfoEdit = ccui.Helper:seekWidgetByName(self.gui, "item_info_edit")
    self.itemInfoGold = ccui.Helper:seekWidgetByName(self.gui, "item_info_gold")
    self.itemInfoTitle = ccui.Helper:seekWidgetByName(self.gui, "item_info_title")
    self.itemInfoTitle:setVisible(false)
    self.itemInfoEdit:setVisible(false)
    ccui.Helper:seekWidgetByName(self.gui, "tf_remark"):setVisible(false)
    
    self.btn_common = ccui.Helper:seekWidgetByName(self.gui, "btn_common")
    self.btn_sng = ccui.Helper:seekWidgetByName(self.gui, "btn_sng")
    self.btn_mit = ccui.Helper:seekWidgetByName(self.gui, "btn_mit")
    self.btn_title_desc = ccui.Helper:seekWidgetByName(self.gui, "btn_title_desc")
    self.btn_common.name = "common"
    self.btn_sng.name = "sng"
    self.btn_mit.name = "mit"
    self.pageSwithBtns = {}
    self.pageSwithBtns["common"] = self.btn_common
    self.pageSwithBtns["sng"] = self.btn_sng
    self.pageSwithBtns["mit"] = self.btn_mit
    self.pageLayout = ccui.Helper:seekWidgetByName(self.gui,"common_page_layout")
    --self:refreshPageBtn(self.btn_common.name)
    
    self:addClickListner()
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(function(event, touch) return true end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener1:registerScriptHandler(function(event, touch)end, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self)
    
    ccui.Helper:seekWidgetByName(self.gui, "img_rev_gift"):setVisible(true)
    ccui.Helper:seekWidgetByName(self.gui, "listview_rev_gift"):setVisible(true)
    self.btn_mit:setVisible(true)
    self:initReport()
    
    self:InteractiveExpressionUI()
    self:initLocalInfo(paras)
    self:queryGameInfo(paras)
end

function UserInfo:init()
    self.index = "common"
    self.userinfoData = nil
end

function UserInfo:initLocalInfo(paras)
    -- body
    if paras.localinfo then
        if paras.localinfo.gold then
            -- 金币
            self.itemInfoGold:getChildByName("lbl_gold"):setString(Util:getFormatString(paras.localinfo.gold))
        end
        if paras.localinfo.nick then
            -- 昵称
            self.itemInfoNick:getChildByName("nick_txt"):setString(Util:filter_spec_chars(paras.localinfo.nick))
        end
        -- 头像
        self.imgHead:setVisible(true)
        Util:updateUserHead(self.imgHead, paras.localinfo.portrait, paras.localinfo.sex, {url = true, circle = true, add = true}) --头像变成实际头像
    end
end

-- 举报
function UserInfo:initReport()
    
    self.btn_report = ccui.Helper:seekWidgetByName(self.gui, "btn_report")
    self.report_layer = ccui.Helper:seekWidgetByName(self.gui, "report_layer")
    self.report_layer:ignoreAnchorPointForPosition(false)
    self.report_layer:setAnchorPoint(0.5,0.5)
    self.report_layer:setPosition(Display.cx/2,Display.cy/2)
    self.report_layer:setVisible(false)
    self.report_type = 0
    
    if FULLSCREENADAPTIVE then
        self.report_layer:setContentSize(self.winSize.width , self.winSize.height)
    end

    self.report_edit = ccui.Helper:seekWidgetByName(self.report_layer, "report_edit")
    self.report_edit:addEventListener(function (sender, eventType)
        
        if eventType == 0 then -- attach IME
            local str = self.report_edit:getStringValue()
            if str == "" then
                self.report_edit:setText("  ")
            end
        elseif eventType == 1 then -- detach IME
            
        elseif eventType == 2 then -- insert text
            
        elseif eventType == 3 then -- delete text
        end
    end)
    
    function initCheckBtns(index)
        for i = 1, 4 do
            local btn_check = ccui.Helper:seekWidgetByName(self.report_layer, "btn_check" .. i)
            if i == index then
                btn_check:getChildByName("img_check"):setVisible(true)
            else
                btn_check:getChildByName("img_check"):setVisible(false)
            end
        end
    end
    initCheckBtns(0)
    for i = 1, 4 do
        local btn_check = ccui.Helper:seekWidgetByName(self.report_layer, "btn_check" .. i)
        addButtonEvent(btn_check, function ()
            initCheckBtns(i)
            self.report_type = i
        end)
    end
    
    local btn_reportclose = ccui.Helper:seekWidgetByName(self.report_layer, "btn_reportclose")
    addButtonEvent(btn_reportclose, function ()
        self.report_layer:setVisible(false)
    end)
    
    addButtonEvent(self.btn_report, function ()
        initCheckBtns(0)
        self.report_edit:setText("")
        self.edit_text = ""
        self.report_type = 0
        self.report_layer:setVisible(true)
    end)
    
    local btn_reportsend = ccui.Helper:seekWidgetByName(self.report_layer, "btn_reportsend")
    addButtonEvent(btn_reportsend, function ()
        if self.report_type == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = GameTxt.report_no_type})
            return 
        end
        self.report_layer:setVisible(false)
        qf.event:dispatchEvent(ET.EVT_USER_REPORT, {uin = self.uin, type = self.report_type, reason = self.report_edit:getStringValue()})
    end)
    addButtonEvent(self.report_layer, function ()
        self.report_layer:setVisible(false)
    end)
end
--[[根据服务器数据刷新界面]]
function UserInfo:initView(paras)
    self.model = paras.model
    self.isCollect = paras.model.is_collect_player
    self.isFriend = paras.model.is_friend
    self.hide = (self.hide_enabled == true) and self.model.hiding or 0--如果可隐身则按用户隐身状态显示隐身信息
    self.hide_nick = self.hide_nick or GameTxt.vip_hiding_name--隐身昵称如果没有指定则显示默认的
    self.anti_stealth_time = paras.model.anti_stealth_time
    if self.anti_stealth_time and self.anti_stealth_time > 0 then --被破隐则是不隐身状态
        self.hide = 0
    end
    self.schedule_time = self.anti_stealth_time 
    self.show_edit_remark = true
    self.gifts = {}
    for i = 1, self.model.gifts:len() do
        local g = self.model.gifts:get(i)
        self.gifts[g.id + 1] = {}
        self.gifts[g.id + 1].id = g.id
        self.gifts[g.id + 1].num = g.num
        self.gifts[g.id + 1].name = g.name
        self.gifts[g.id + 1].price = g.price
        self.gifts[g.id + 1].remain = g.remain
        self.gifts[g.id + 1].category = g.category + 1
    end
    
    self.send_gifts = {}
    if self.model.send_gifts then
        for i = 1, self.model.send_gifts:len() do
            local _info = self.model.send_gifts:get(i)
            self.send_gifts[i] = {
                price = _info.price 
                , name = _info.name 
                , id = _info.id
            }
        end
    end
    self:setInfo()
    
    ccui.Helper:seekWidgetByName(self.gui, "over_txt"):setString(self.model.ruju_prob .. "%")
    ccui.Helper:seekWidgetByName(self.gui, "max_win_bg"):setString(Util:getFormatString(self.model.max_history_win_chips))
    
    -- for i = 1, 5 do
    --     self.gui:getChildByName("gift_number_img_"..i):setVisible(true)
    --     self.gui:getChildByName("gift_number_img_"..i):getChildByName("txt"):setString("0")
    -- end
    -- for i = 1, self.model.gifts:len() do
    --     local numberItem = self.gui:getChildByName("gift_number_img_"..(self.model.gifts:get(i).id + 1))
    --     if numberItem then 
    --         numberItem:getChildByName("txt"):setString(self.model.gifts:get(i).num) 
    --     end
    -- end
    self:updateIsFriend()
    
    self.gui:getChildByName("is_beauty_img"):setVisible(false)
    if self.model.is_beauty then
        if self.hide == 0 or self.uin == Cache.user.uin then--未隐身或是玩家自己，可以显示美女皇冠
            self.gui:getChildByName("is_beauty_img"):setVisible(true)
        end
    end
    
    self.itemInfoNick:getChildByName("img_sex"):loadTexture(string.format(GameRes.img_user_info_my_sex, self.model.sex))
    local isshow = true
    if self.hide == 1 then isshow = false end
    self:showOrHideMaxCard(isshow)
    self:viewAddClick(self.btnAddFriend, "friend")--关注按钮点击事件
    --礼物
    self:viewAddClick(self.btn_gift, "gift_module")--点击礼物
    self:delayRun(0, function() 
        self:setHeadByUin(self.imgHead, self.uin) 
    end) 
    self:delayRun(0.05, function() 
        self.imgHead:setVisible(true) 
    end)
    -- 相册
    self.gui:getChildByName("btn_gallery"):setVisible(false)
    if paras.model.is_beauty and (self.hide == 0 or self.uin == Cache.user.uin) then
        -- 是本人或者不隐藏时才显示相册按钮
        if true then -- 相册开关
            self.gui:getChildByName("btn_gallery"):setVisible(true)
        end
    else
        self.gui:getChildByName("btn_gallery"):setVisible(false)
    end
    if not (ModuleManager:judegeIsIngame() and Cache.DeskAssemble:judgeGameType(JDC_MATCHE_TYPE)) and self.hide == 0 and self.anti_stealth_time and self.anti_stealth_time > 0 then --如果是在经典游戏外面  且是被破隐的 显示隐藏信息
        self:hideInfo(true)--隐藏信息
    else
        self:hideInfo()--隐藏信息
    end
    self:setUserIdDisplay() --设置用户id的显示
    self:refreshVipFlag()--更新vip标识
    self:setRemarkEditBox()
    self:adjustView() --是好友过来的 可以改备注名
    self:setSendGifts()
end

-- 更新VIP标识
function UserInfo:refreshVipFlag()
    if self.model.vip_days and self.model.vip_days > 0 then
        --隐身标识
        local _lblhide = self.itemInfoNick:getChildByName("lbl_hide")
        local _lblNick = self.itemInfoNick:getChildByName("nick_txt")
        local x = _lblNick:getPositionX()
        x = x + _lblNick:getContentSize().width + 15
        if self.hide == 1 then
            _lblhide:setVisible(true)
            _lblhide:setPositionX(x)
            x = x + _lblhide:getContentSize().width + 15
        else
            _lblhide:setVisible(false)
        end
        -- vip标识
        local _imgVip = self.itemInfoNick:getChildByName("img_vip")
        _imgVip:runAction(cc.MoveTo:create(0, cc.p(x, _imgVip:getPositionY())))
        _imgVip:setVisible(true)
    else
        self.itemInfoNick:getChildByName("img_vip"):setVisible(false)
        self.itemInfoNick:getChildByName("lbl_hide"):setVisible(false)
    end
end

function UserInfo:showOrHideMaxCard(is_show)
    --其他玩家隐身不显示最大牌型
    local info = ccui.Helper:seekWidgetByName(self.gui, "max_card_panel")
    info:removeAllChildren()
    local sx, sy = 80, 90
    if self.model.max_history_cards:len() == 0 or (not is_show) then
        for i = 1, 5 do
            local c = cc.Sprite:create(GameRes.res002)
            c:setPosition(sx + (i - 1) * 150, sy)
            c:setScale(0.8)
            info:addChild(c)
        end
    end
end

--隐藏信息
function UserInfo:hideInfo(ignore_hide, alias_nick)
    if not ignore_hide then --不忽略self.hide时
        if self.hide == 0 then return end
    end
    
    -- 隐藏昵称
    local _nick = alias_nick or self.hide_nick --优先用传进来的alias_nick
    self.itemInfoNick:getChildByName("nick_txt"):setString(Util:filter_spec_chars(_nick))
    self.itemInfoNick:getChildByName("lbl_hide"):setVisible(true)
    
    if self.type ~= BRC_MATCHE_TYPE and self.type ~= SNG_MATCHE_TYPE and self.type ~= MTT_MATCHE_TYPE then -- 百人场和sng mtt没有
        -- 隐藏金币数量
        self.itemInfoGold:getChildByName("lbl_gold"):setVisible(false)
        self.itemInfoGold:getChildByName("icon_hide"):setVisible(true)
        -- 隐藏称号
        self.itemInfoTitle:getChildByName("lbl_title"):setVisible(false)
        self.itemInfoTitle:getChildByName("icon_hide"):setVisible(true)
        -- 隐藏总局数
        ccui.Helper:seekWidgetByName(self.gui, "tatol_number"):setVisible(false)
        ccui.Helper:seekWidgetByName(self.gui, "icon_hide_total"):setVisible(true)
        -- 隐藏入局率
        ccui.Helper:seekWidgetByName(self.gui, "over_txt"):setVisible(false)
        ccui.Helper:seekWidgetByName(self.gui, "icon_hide_over"):setVisible(true)
        -- 隐藏最大赢取
        ccui.Helper:seekWidgetByName(self.gui, "max_win_bg"):setVisible(false)
        ccui.Helper:seekWidgetByName(self.gui, "icon_hide_max_win"):setVisible(true)
        -- 隐藏胜率
        ccui.Helper:seekWidgetByName(self.gui, "win_txt"):setVisible(false)
        ccui.Helper:seekWidgetByName(self.gui, "icon_hide_win"):setVisible(true)
        
        self:showOrHideMaxCard(false)
        self.gui:getChildByName("is_beauty_img"):setVisible(false)
        self.gui:getChildByName("btn_gallery"):setVisible(false)
        
        Util:updateUserHead(self.imgHead, Cache.Config.hiding_portrait[self.model.sex + 1], self.model.sex, {url = true, circle = true, add = true}) --头像变成隐身头像
    end 
    self:refreshVipFlag() 
end

--隐藏信息
function UserInfo:breakHideInfo()
    -- 隐藏昵称
    self.itemInfoNick:getChildByName("nick_txt"):setString(Util:filter_spec_chars(self.model.nick))
    self.itemInfoNick:getChildByName("lbl_hide"):setVisible(false)
    
    -- 隐藏金币数量
    self.itemInfoGold:getChildByName("lbl_gold"):setVisible(true)
    self.itemInfoGold:getChildByName("icon_hide"):setVisible(false)
    -- 隐藏称号
    self.itemInfoTitle:getChildByName("lbl_title"):setVisible(true)
    self.itemInfoTitle:getChildByName("icon_hide"):setVisible(false)
    -- 隐藏总局数
    ccui.Helper:seekWidgetByName(self.gui, "tatol_number"):setVisible(true)
    ccui.Helper:seekWidgetByName(self.gui, "icon_hide_total"):setVisible(false)
    -- 隐藏入局率
    ccui.Helper:seekWidgetByName(self.gui, "over_txt"):setVisible(true)
    ccui.Helper:seekWidgetByName(self.gui, "icon_hide_over"):setVisible(false)
    -- 隐藏最大赢取
    ccui.Helper:seekWidgetByName(self.gui, "max_win_bg"):setVisible(true)
    ccui.Helper:seekWidgetByName(self.gui, "icon_hide_max_win"):setVisible(false)
    -- 隐藏胜率
    ccui.Helper:seekWidgetByName(self.gui, "win_txt"):setVisible(true)
    ccui.Helper:seekWidgetByName(self.gui, "icon_hide_win"):setVisible(false)
    self:showOrHideMaxCard(true)
    Util:updateUserHead(self.imgHead, self.model.portrait, self.model.sex, {url = true, circle = true, add = true}) --头像变成实际头像
    
    if self.model.is_beauty then
        self.gui:getChildByName("is_beauty_img"):setVisible(true)
    end
    if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW and self.model.is_beauty then -- 相册开关
        self.gui:getChildByName("btn_gallery"):setVisible(true)
    end
    self:refreshVipFlag()
end

--设置用户id的显示
function UserInfo:setUserIdDisplay()
    --如果本人是vip，且当前在私人定制场内，显示用户ID。
    if GAME_SHOW_UIN_FLAG and ModuleManager:judegeIsIngame() 
        and Cache.DeskAssemble:judgeGameType(JDC_MATCHE_TYPE) 
        and Cache.desk:isCustomizeRoom() then
        ccui.Helper:seekWidgetByName(self.gui, "item_info_uin"):setVisible(true)
    else
        ccui.Helper:seekWidgetByName(self.gui, "item_info_uin"):setVisible(false)
        ccui.Helper:seekWidgetByName(self.gui, "item_info_title"):setPositionY(83)
        ccui.Helper:seekWidgetByName(self.gui, "item_info_gold"):setPositionY(176)
        ccui.Helper:seekWidgetByName(self.gui, "item_info_edit"):setPositionY(267)
    end
end

function UserInfo:setInfo()
    local str = self.model.nick
    local remarkname, is_remarkname = Util:getFriendRemark(self.uin, self.model.nick)
    if self.show_edit_remark then
        --ccui.Helper:seekWidgetByName(self.gui,"tf_remark"):setText(remarkname) --nick
    else
        --ccui.Helper:seekWidgetByName(self.gui,"tf_remark"):setText(str) --nick
    end
    -- 用户id
    ccui.Helper:seekWidgetByName(self.gui, "txt_uin"):setString(tostring(self.uin))
    -- 昵称
    self.itemInfoNick:getChildByName("nick_txt"):setString(Util:filter_spec_chars(self.model.nick))
    -- 金币
    self.itemInfoGold:getChildByName("lbl_gold"):setString(Util:getFormatString(self.model.gold))
    -- 称号
    local title = Cache.Config:getTitleByCreditScore(self.model.contest_credit) --获取免费赛积分对应的称号
    self.itemInfoTitle:getChildByName("lbl_title"):setString(title)
    -- -- 总局数
    -- ccui.Helper:seekWidgetByName(self.gui, "tatol_number"):setString(self.model.play_times)
    -- -- 胜率
    -- ccui.Helper:seekWidgetByName(self.gui, "win_txt"):setString(self.model.win_prob .. "%")
    self.btn_gift = ccui.Helper:seekWidgetByName(self.gui, "btn_gift")
    if self.model.decoration then--显示礼物
        qf.event:dispatchEvent(ET.CHANGE_GIFT, {button = self.btn_gift, icon = self.model.decoration, scale = 1.3})
    end
    -- 根据审核开关，控制礼物按钮显隐
    self.btn_gift:setVisible(false)
    self:delayRun(0.1, function ()
        self.btn_gift:setVisible(true)
        local head_bg = ccui.Helper:seekWidgetByName(self.gui, "btn_gift")
        local left_x = head_bg:getPositionX() - head_bg:getContentSize().width / 2 
        local right_long = self.btn_gift:getContentSize().width * 1.3 * 0.9 
        local right_x = left_x + right_long 
        self.btn_gift:setPositionX(right_x - self.btn_gift:getContentSize().width / 2)
    end)
    
end

function UserInfo:delayRun(time, cb, tag)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time), 
    cc.CallFunc:create(function () if cb then cb() end end))
    if tag then action:setTag(tag) end
    self:runAction(action)
end

function UserInfo:queryGameInfo(paras)
    local body = {
        uin = paras.uin,
        role = 1 
    }
    GameNet:send({cmd = CMD.GET_USER_GAME_INFO, body = body, callback = function (rsp)
        if rsp.ret == 0 and rsp.model then
            local userData  = require("src.cache.User").new()
            userData:updateGameInfo(rsp.model)
            self.userinfoData = userData
            self:updateGameInfo(self.index)
        end
    end})
end

function UserInfo:updateGameInfo(index)
    local userInfo = self.userinfoData
    if not userInfo then return end
    
    self.index = index
    -- lbl_tatol_number  tatol_number  lbl_win_txt win_txt  lbl_max_win_bg max_win_bg
    if userInfo then
        if index == "common" then
            self.pageLayout:getChildByName("tatol_number"):setString(userInfo.total_play_times)
            self.pageLayout:getChildByName("lbl_win_txt"):setString("总胜率：")
            self.pageLayout:getChildByName("win_txt"):setString(userInfo.total_win_rate.."%")
            self.pageLayout:getChildByName("max_win_bg"):setString(userInfo.single_win_max)
        elseif index == "sng" then
            ccui.Helper:seekWidgetByName(self.pageLayout, "lbl_dankou_win_bg"):setString("单扣次数：")
            ccui.Helper:seekWidgetByName(self.pageLayout, "lbl_shuangkou_win_bg"):setString("双扣次数：")
            self.pageLayout:getChildByName("tatol_number"):setString(userInfo.jh_play_times)
            self.pageLayout:getChildByName("lbl_win_txt"):setString("总胜率：")
            self.pageLayout:getChildByName("win_txt"):setString(userInfo.jh_win_rate.."%")
            ccui.Helper:seekWidgetByName(self.pageLayout, "shuangkou_win_bg"):setString(userInfo.double_win)
            ccui.Helper:seekWidgetByName(self.pageLayout, "dankou_win_bg"):setString(userInfo.single_win)
            --设置最大手牌 TODO
            --self:setMaxCard(userInfo.jh_max_history_cards)

        else
            ccui.Helper:seekWidgetByName(self.pageLayout, "lbl_dankou_win_bg"):setString("单局盈利：")
            ccui.Helper:seekWidgetByName(self.pageLayout, "lbl_shuangkou_win_bg"):setString("最大倍数：")
            self.pageLayout:getChildByName("tatol_number"):setString(userInfo.ddz_play_times)
            self.pageLayout:getChildByName("win_txt"):setString(userInfo.ddz_win_rate.."%")
            ccui.Helper:seekWidgetByName(self.pageLayout, "shuangkou_win_bg"):setString(userInfo.ddz_max_multiple)
            ccui.Helper:seekWidgetByName(self.pageLayout, "dankou_win_bg"):setString(userInfo.ddz_max_win)

            -- self.pageLayout:getChildByName("tatol_number"):setString(userInfo.dn_play_times)
            -- self.pageLayout:getChildByName("lbl_win_txt"):setString("总胜率：")
            -- self.pageLayout:getChildByName("win_txt"):setString(userInfo.dn_win_rate.."%")
            -- --设置最大手牌
            -- self:setMaxCard(userInfo.dn_max_history_cards)
        end
    end
    
end

function UserInfo:setMaxCard(maxCardInfos)
    local maxCards = ccui.Helper:seekWidgetByName(self.gui,"max_card_txt") 
    maxCards:setString(string.format(GameTxt.main006))
    local info = ccui.Helper:seekWidgetByName(self.gui,"max_card_panel")
    local bg = ccui.Helper:seekWidgetByName(self.gui,"img_max_card_frame")
    local sy =info:getContentSize().height*0.5
    info:removeAllChildren()
    if self.index == "sng" then
        bg:loadTexture(GameRes.userinfo_cardBg)
        info:setContentSize(368 ,info:getContentSize().height)
    else
        bg:loadTexture(GameRes.userinfo_cardBg1)
        info:setContentSize(600 ,info:getContentSize().height)
    end
    local function getCardFileName (value)
        if value == nil then return nil end
        local _ctable = {"r","h","m","f"}
        local i,t = math.modf(value/4)

        i = i + 1
        if i == 14 then i = 1 end

        local c = math.fmod(value,4)
        local ret = nil

        if i < 10 then ret = "poker_".._ctable[(c+1)].."0"..i
        else ret= "poker_".._ctable[(c+1)]..i
        end
        return GameRes[ret]
    end
    if maxCardInfos and #maxCardInfos ~= 0 then
        for i = 1,#maxCardInfos do
            local num = maxCardInfos[i]
            local file = getCardFileName(num)
            local c = cc.Sprite:create(file)
            c:setAnchorPoint(0,0.5)
            c:setScale(0.55)
            c:setPosition(cc.p(info:getContentSize().width/2 -125+ (i - 2)*(c:getContentSize().width- 60),sy+15))
            info:addChild(c)
        end
    else
        local maxNum =  5 
        for i = 1, maxNum do
            local c = cc.Sprite:create(GameRes.res002)
            c:setAnchorPoint(0,0.5)
            c:setScale(0.55)
            c:setPosition(cc.p(info:getContentSize().width/2-125 + (i- 2)*(c:getContentSize().width- 60),sy+15))
            info:addChild(c)
        end
    end
end

--[[下载图片 start]]
function UserInfo:setHeadByUin(view, uin)
    if view == nil or uin == nil then return end
    local HeadImage = HeadImage.new({node = view})
    self:viewAddClick(HeadImage, "big_head_image")
    
    local defaultImag = GameRes.default_man_large_icon
    if self.model.sex == 1 then
        defaultImag = GameRes.default_girl_large_icon
    end
    if self.hide == 1 then
        Util:updateUserHead(HeadImage, Cache.Config.hiding_portrait[self.model.sex + 1], self.model.sex, {url = true, circle = true, add = true, default= defaultImag})
    else
        Util:updateUserHead(HeadImage, self.model.portrait, self.model.sex, {url = true, circle = true, add = true, default= defaultImag})
    end
end

function UserInfo:addClickListner()
    self:viewAddClick(self.gui, "root")
    self:viewAddClick(self.gui:getChildByName("back"), "root")
    self.gui:getChildByName("bg"):setTouchEnabled(true)
    Util:registerKeyReleased({self = self, cb = function ()
        self:close()
    end})
    self.gui:getChildByName("btn_gallery"):setVisible(false)
    self:viewAddClick(self.gui:getChildByName("btn_gallery"), "btn_gallery")
    self:viewAddClick(self.btn_common, self.btn_common.name)
    self:viewAddClick(self.btn_sng, self.btn_sng.name)
    self:viewAddClick(self.btn_mit, self.btn_mit.name)
    self:viewAddClick(self.btn_title_desc, "btn_title_desc")
end

--[[加点击事件start]]
function UserInfo:viewAddClick(view, name)
    view:setTouchEnabled(true)
    view.name = name
    view:addTouchEventListener(handler(self, self.addCallBack)) 
end

function UserInfo:addCallBack(sender, eventType)
    if sender.clickable == false then return false end
    if eventType == ccui.TouchEventType.began then
        return true
    elseif eventType == ccui.TouchEventType.moved then
    elseif eventType == ccui.TouchEventType.ended then
        return self:myClick(sender, sender.name)
    elseif eventType == ccui.TouchEventType.canceled then
    end
end

function UserInfo:myClick(sender, name)
    if self.editBoxShowing == true then
        return
    end
    MusicPlayer:playMyEffect("BTN")
    if name == "friend" then--好友按钮
        if self.isFriend then
            qf.event:dispatchEvent(ET.NET_FRIEND_DELETE, {uin = self.uin, 
                cb = function ()
                    self.btnAddFriend:getChildByName("img_add_friend"):setVisible(true)
                    self.btnAddFriend:getChildByName("img_delete_friend"):setVisible(false)
                    self.isFriend = false 
                end})
            else
                qf.event:dispatchEvent(ET.NET_FRIEND_APPLY, {uin = self.uin, cb = function() end, remove_cb = function() self:close() end})
            end
        elseif name == "collect" then --关注按钮
            if self.isCollect then
                qf.event:dispatchEvent(ET.NET_GAME_CANCER_PAYATTENTION_REQ, {uin = self.uin, cb = handler(self, self.refreshCollectBtn)})
            else
                qf.event:dispatchEvent(ET.NET_GAME_PAYATTENTIONTO_REQ, {uin = self.uin, cb = handler(self, self.refreshCollectBtn)
                })
            end
        elseif name == "all" then
        elseif name == "root" then
            self:close()
        elseif name == "daoju" then
            qf.event:dispatchEvent(ET.SHOW_DAOJU_VIEW)
        elseif name == "guashi" then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = GameTxt.guashi})
        elseif name == "gift_module" then
            self:close()
            local _type 
            if ModuleManager:judegeIsIngame() then
                _type = self.uin == Cache.user.uin and 3 or 4
            else
                _type = self.uin == Cache.user.uin and 1 or 2
            end
            qf.event:dispatchEvent(ET.SHOW_GIFT, {
                name = "gift", from = self.TAG, type = _type, uin = self.uin, gifts = self.gifts
            })
        elseif name == "img_touch_bg" then
            if self.isEditRemarking then
                -- self.editName:attachWithIME()
            end
        elseif name == "common" then
            self:refreshPageBtn(name)
        elseif name == "sng" then
            self:refreshPageBtn(name)
        elseif name == "mit" then
            self:refreshPageBtn(name)
        elseif name == "btn_title_desc" then
            qf.event:dispatchEvent(ET.SHOW_SNG_LEVEL_SYSTEM, {}) --打开称号弹窗
        end
end
    --[[加点击事件end]]
function UserInfo:refreshCollectBtn(paras)
    self.isCollect = paras
end
    
function UserInfo:refreshFriendBtn(paras)
    self.isFriend = paras
    local btn2 = self.btnAddFriend
    btn2:removeAllChildren()
    if paras then
        local img = cc.Sprite:create(GameRes.text_deletfriend)
        img:setPosition(cc.p(120, 38))
        btn2:addChild(img)
    else
        local img = cc.Sprite:create(GameRes.text_addfriend)
        img:setPosition(cc.p(120, 38))
        btn2:addChild(img)
    end
    self:updateIsFriend()
end

function UserInfo:updateIsFriend()
    self.isFriendImg:setVisible(self.isFriend)
    self.btnAddFriend:setVisible(not self.isFriend)
end

--更新本人的隐身状态
function UserInfo:refreshViewByHidingStatus(hiding, nick)
    self.hide = hiding
    if self.hide == 1 then
        self.hide_nick = nick
        --self.gui:getChildByName("txt1"):setString(self.hide_nick)
    else
        local remarkname, is_remarkname = Util:getFriendRemark(self.uin, self.model.nick)
        if self.show_edit_remark == true then -- 从好友过来的
            remarkname = self.model.nicks
        end
        --self.gui:getChildByName("txt1"):setString(remarkname)
    end
    self:setHeadByUin(self.imgHead, self.uin)
    self:refreshVipFlag()
end
    
function UserInfo:setRemarkEditBox()
    self.touch_width = self.itemInfoEdit:getChildByName("img_touch_bg"):getContentSize().width
    self.editName = cc.EditBox:create(cc.size(330, 50), cc.Scale9Sprite:create())
    local text = ccui.Helper:seekWidgetByName(self.gui, "remark_text")-- cc.LabelTTF:create("I",GameRes.font1,37)
    
    local _btnRemark = self.itemInfoEdit:getChildByName("btn_remark")
    local _imgTouchBg = self.itemInfoEdit:getChildByName("img_touch_bg")
    self:viewAddClick(_btnRemark, "btn_remark")
    text:setVisible(false)
    _imgTouchBg:setVisible(false)
    
    ccui.Helper:seekWidgetByName(self.gui, "tf_remark"):setVisible(false)
    self.editBoxShowing = false
    self.editName:setTouchEnabled(false)
    self.editName:setFontName(GameRes.font1)
    self.editName:setFontSize(38)
    self.editName:setAnchorPoint(0, 0.5)
    self.editName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editName:setPosition(_imgTouchBg:getPositionX(), _imgTouchBg:getPositionY())
    _imgTouchBg:getParent():addChild(self.editName, 1)
    self.editName:registerScriptEditBoxHandler(function(strEventName, sender) 
        if strEventName == "began" then
            self.editName:setContentSize(cc.size(self.touch_width, self.editName:getContentSize().height))
            self.isEditRemarking = true
            self.itemInfoEdit:getChildByName("img_touch_bg"):setVisible(true)
            self.itemInfoEdit:getChildByName("btn_remark"):loadTextureNormal(GameRes.btn_user_info_edit_sure)
            self.editBoxShowing = true
        elseif strEventName == "changed" then
            
        elseif strEventName == "ended" then
            
        elseif strEventName == "return" then
            
            self:editRemarkEnd()
        end
        
    end)
    
    if Util:getCanUseRemark() == false then
        self.editName:setVisible(false)
    end
end
    
function UserInfo:editRemarkEnd()
    self:delayRun(0.04, function()
        self.editBoxShowing = false
    end) 
    self.itemInfoEdit:getChildByName("btn_remark"):setZOrder(3)
    if string.len(self.editName:getText()) > 0 then
        local str = Util:getMySubStr(self.editName:getText(), 1, 6)
        self.editName:setText(str)
    else
    end
end
function UserInfo:adjustView()
    if self.show_edit_remark then
        -- 显示编辑选项
        self.itemInfoEdit:setVisible(false)
        local remarkname, is_remarkname = Util:getFriendRemark(self.uin, self.model.nick)
        if is_remarkname then
            self.itemInfoNick:getChildByName("nick_txt"):setString(Util:filter_spec_chars(remarkname))
            --self.editName:setText(remarkname)
        else
            self.editName:setText("")--GameTxt.remark_no_remark_name)
        end
    else
        self.itemInfoEdit:setVisible(false)
        --self.itemInfoGold:runAction(cc.MoveBy:create(0, cc.p(0, 50)))
    end
end

-- 常用礼物
function UserInfo:setSendGifts(...)
    local _listviewGifts = ccui.Helper:seekWidgetByName(self.gui, "listview_rev_gift")
    _listviewGifts:setItemsMargin(15)
    local _item = ccui.Helper:seekWidgetByName(self.gui, "item_gift")
    local _data = self.send_gifts

    _listviewGifts:setItemModel(_item)
    
    for i = 1, #_data do
        _listviewGifts:pushBackDefaultItem()
        _item = _listviewGifts:getItem(i - 1)
        _item:setVisible(true)
        _item:getChildByName("txt_gift"):setString(string.format(GameTxt.string_shop_item_txt4, _data[i].price))
        _item:getChildByName("btn_item_gift"):loadTextureNormal(GameRes["gift_icon_" .. _data[i].id])
        _item:getChildByName("btn_item_gift")._id = _data[i].id
        _item:getChildByName("btn_item_gift"):setScale(0.8)
        _item:setPosition(20, 0)
        addButtonEvent(_item:getChildByName("btn_item_gift"), function(sender)
            
        end)
    end
end

--显示UserInfo
function UserInfo:show(paras)
    if paras == nil or paras.uin == nil then return end
    self.uin = paras.uin
    self.type = paras.type
    self.hide_enabled = paras.hide_enabled or false--是否可以显示隐身状态
    self.hide_nick = paras.hide_nick--隐身后的昵称
    self.from_friend = paras.from_friend or 0 --是否来自 好友资料卡
    UserInfo.super.show(self) 
    self:delayRun(0.01, function ()
        self:adjustSngView()
    end)
    if paras.face then
        self:setFaceGold(paras.face)
        ccui.Helper:seekWidgetByName(self.gui, "gift_page_layout"):setVisible(false)
        ccui.Helper:seekWidgetByName(self.gui, "InteractiveExpressionP"):setVisible(true)
    else
        ccui.Helper:seekWidgetByName(self.gui, "gift_page_layout"):setVisible(true)
        ccui.Helper:seekWidgetByName(self.gui, "InteractiveExpressionP"):setVisible(false)
    end
end

function UserInfo:adjustSngView()
    
    if self.type == SNG_MATCHE_TYPE or self.type == MTT_MATCHE_TYPE then
        ccui.Helper:seekWidgetByName(self.gui, "common_page_layout"):runAction(cc.MoveBy:create(0, cc.p(0, -120)))
        ccui.Helper:seekWidgetByName(self.gui, "max_page_layout"):runAction(cc.MoveBy:create(0, cc.p(0, -120)))
        ccui.Helper:seekWidgetByName(self.gui, "gift_page_layout"):setVisible(false)
    end
    if self.type == SNG_MATCHE_TYPE then 
        self:refreshPageBtn(self.btn_sng.name) 
    elseif self.type == MTT_MATCHE_TYPE then
        self:refreshPageBtn(self.btn_mit.name)
    else 
        self:refreshPageBtn(self.btn_common.name)
    end
end
function UserInfo:refreshPageBtn(index)
    for key, var in pairs(self.pageSwithBtns) do
        logd("" .. var.name)
        if index == var.name then
            var:setOpacity(255)
            self.pageLayout:setVisible(true)
            self.pageLayout:getChildByName("max_win_bg"):setVisible(false)
            self.pageLayout:getChildByName("lbl_max_win_bg"):setVisible(false)
            ccui.Helper:seekWidgetByName(self.gui, "max_page_layout"):setVisible(false)
            ccui.Helper:seekWidgetByName(self.pageLayout, "lbl_dankou_win_bg"):setVisible(false)
            ccui.Helper:seekWidgetByName(self.pageLayout, "lbl_shuangkou_win_bg"):setVisible(false)
            if var.name == "common" then 
                self.pageLayout:setVisible(true)
                self.pageLayout:getChildByName("max_win_bg"):setVisible(true)
                self.pageLayout:getChildByName("lbl_max_win_bg"):setVisible(true)
                ccui.Helper:seekWidgetByName(self.gui, "select_all_1"):setVisible(true)
                ccui.Helper:seekWidgetByName(self.gui, "select_jin_1"):setVisible(false)
                ccui.Helper:seekWidgetByName(self.gui, "select_niu_1"):setVisible(false)
                self:updateGameInfo("common")
            elseif var.name == "sng" then
                ccui.Helper:seekWidgetByName(self.gui, "select_all_1"):setVisible(false)
                ccui.Helper:seekWidgetByName(self.gui, "select_jin_1"):setVisible(true)
                ccui.Helper:seekWidgetByName(self.gui, "select_niu_1"):setVisible(false)
                ccui.Helper:seekWidgetByName(self.pageLayout, "lbl_dankou_win_bg"):setVisible(true)
                ccui.Helper:seekWidgetByName(self.pageLayout, "lbl_shuangkou_win_bg"):setVisible(true)
                self:updateGameInfo("sng")
            elseif var.name == "mit" then
                ccui.Helper:seekWidgetByName(self.gui, "select_all_1"):setVisible(false)
                ccui.Helper:seekWidgetByName(self.gui, "select_jin_1"):setVisible(true)
                ccui.Helper:seekWidgetByName(self.gui, "select_niu_1"):setVisible(false)
                ccui.Helper:seekWidgetByName(self.pageLayout, "lbl_dankou_win_bg"):setVisible(true)
                ccui.Helper:seekWidgetByName(self.pageLayout, "lbl_shuangkou_win_bg"):setVisible(true)
                -- ccui.Helper:seekWidgetByName(self.gui, "max_page_layout"):setVisible(true)
                self:updateGameInfo("mit")
                -- ccui.Helper:seekWidgetByName(self.gui, "select_all_1"):setVisible(false)
                -- ccui.Helper:seekWidgetByName(self.gui, "select_jin_1"):setVisible(false)
                -- ccui.Helper:seekWidgetByName(self.gui, "select_niu_1"):setVisible(true)
            end
        else
            var:setOpacity(0)
        end
    end
end

function UserInfo:InteractiveExpressionUI()
    -- body
    
    self.InteractiveExpressioP = ccui.Helper:seekWidgetByName(self.gui, "InteractiveExpressionP")
    -- addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"closeP"),function ()
    --            self:removeFromParent(true)
    --     end)
    
    self.faceBg = ccui.Helper:seekWidgetByName(self.gui, "bgImg")
    
    
    self.connectText = ccui.Helper:seekWidgetByName(self.gui, "connectText")--内容
    self.goldText = self.connectText:clone()
    self.goldText:setAnchorPoint(0, 0.5)
    self.goldText:setPosition(cc.p(self.goldText:getPositionX() + self.goldText:getContentSize().width, self.goldText:getPositionY()))
    self.goldText:setColor(cc.c3b(251, 189, 48))
    self.goldText:setString("")
    self.faceBg:addChild(self.goldText)
    for i = 1, 4 do 
        addButtonEvent(ccui.Helper:seekWidgetByName(self.gui, "facebtn" .. i), function ()
            self:clickInteractPhiz(i)
            --self:close()
        end)
    end
end

function UserInfo:setFaceGold(paras)
    -- body
    self.goldText:setString(paras.gold .. "金币")
end

function UserInfo:clickInteractPhiz(id)
    local body = {to_uin = self.uin
        , expression_id = id
    } 
    --qf.event:dispatchEvent(ET.INTERACT_PHIZ_NTF,{model={from_uin=Cache.user.uin,to_uin=self.uin,expression_id=id}})
    GameNet:send({cmd = CMD.CMD_INTERACT_PHIZ, body = body, callback = function (rsp)
        if rsp.ret == 0 and rsp.model then
            --self:setInfoOpacity( )
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = Cache.Config._errorMsg[rsp.ret]})
        end
    end})
    -- 以下语句可以在此动作（发送互动表情）开始时，移除对方玩家信息的弹框
    --qf.event:dispatchEvent(ET.REMOVE_VIEW_DIALOG, {name="gamer"})
end

return UserInfo
            
            
            
            
            
            
            
            
            
            
            
            
           