local DaojuView = class("DaojuView", CommonWidget.BasicWindow)

DaojuView.TAG = "DaojuView"
DaojuView.ALWAYS_SHOW = true
local IButton = import(".components.IButton")
local GuaguaCardInfo = import("..focas.components.GuaguaCardInfo")
local DaojuInfoView = import(".components.DaojuInfoView")

function DaojuView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    DaojuView.super.ctor(self,parameters)
    
    local weekNum = 4
    local mothNum = 8

    self.giftcard_item = {name = "gift_card_10w",img = GameRes.daoju_gift_card_icon,desc = ""}
    self.laba_item = {name = "little_horn",img = GameRes.laba_icon,desc = GameTxt.laba_desc}
    self.huafei_item = {name = "fee_ticket",img = GameRes.huafei_icon,desc = GameTxt.huafei_desc}
    self.weekcard_item = {name = "week_card",img = GameRes.weekcard_icon,desc = string.format(GameTxt.card_desc_format, weekNum)}
    self.monthcard_item = {name = "month_card",img = GameRes.monthcard_icon,desc = string.format(GameTxt.card_desc_format, mothNum)}
    self.pokerface_item = {name = "poker_face",img = GameRes.chat_prop_icon,desc = GameTxt.pokerface_daoju_desc_format}
    self.vipcard_item = {name = "vip_card",img = GameRes.vipcard_daoju_icon,desc = GameTxt.vipcard_daoju_desc}
    self.breakhide_item = {name = "anti_stealth_card",img = GameRes.shop_break_hide_card,desc = GameTxt.break_hide_card_desc}

    --参赛券
    self.enter_ticket = {name = "mtt_ticket",img = GameRes.enter_ticket,desc = GameTxt.enter_ticket_desc}
    if FULLSCREENADAPTIVE then
        self.bg:setPositionX(self.bg:getPositionX()+(self.winSize.width/2-1920/2)*3/4)
    end
end

function DaojuView:init(  )
    qf.event:dispatchEvent(ET.GUAGUACARD_SITE_LIST)
end

function DaojuView:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.DaojuJson)
    self.empty_desc = ccui.Helper:seekWidgetByName(self.gui,"empty_desc")
    self.empty_desc:setVisible(false)
    self.bg = ccui.Helper:seekWidgetByName(self.gui,"dialog_bg")
    local btnNode = ccui.Helper:seekWidgetByName(self.gui,"btn_daojuclose")
    addButtonEvent(btnNode,function()
       self:close()
    end)
    addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"daoju_root"),function ( sender )
    end)
    self.daojuListView = ccui.Helper:seekWidgetByName(self.gui,"listview_daoju")
    self.daoju_item_layout = ccui.Helper:seekWidgetByName(self.gui,"daoju_item_layout")
    self.daoju_item_layout:setVisible(false)
    self.itemP = ccui.Helper:seekWidgetByName(self.gui,"itemP")
    qf.event:dispatchEvent(ET.GET_DAOJU_LIST,{})
end

function DaojuView:refreshListItem()
    self.daojuListView:removeAllChildren()
    self.daojuListView:setItemModel(self.itemP)
    
    local newToolsList = Cache.daojuInfo.newToolsList or {}
    local list = Cache.daojuInfo.levelCard or {}
    local chanceCardList = Cache.daojuInfo.chanceCard or {}
    local cardRememberList = Cache.daojuInfo.cardRemember or {}
    local super_mulCardList = Cache.daojuInfo.super_mulCard or {}

    local len = 0
    local count = 0

    for i,v in pairs(newToolsList) do
        count = count + 1
        if v.amount > 0 then
            if math.mod(len,4) == 0 then
                self.daojuListView:pushBackDefaultItem()
            end
            len = len+1
            loga(math.floor((len-1)/4))
            local layout_item = self.daojuListView:getItem(math.floor((len-1)/4))
            local item = self.daoju_item_layout:clone()
            item:setVisible(true)
            item:setPosition(math.mod(len-1,4)*item:getContentSize().width,0)
            layout_item:addChild(item)

            item:getChildByName("daoju_name_n"):setString(v.alias)
            item:getChildByName("number"):setString("x"..string.format("%d", v.amount))
            local imagePath = GameRes.baoxiang
            local daoName = v.alias
            local isNeedDeadLine = false
            if v.type == 11 then
                item:getChildByName("daoju_icon"):loadTexture(string.format(GameRes.baoxingka))
                imagePath = GameRes.baoxingka
            else
                item:getChildByName("daoju_icon"):loadTexture(string.format(GameRes.baoxiang))
                local deadTime = ccui.Helper:seekWidgetByName(item,"deadTime_bg")
                deadTime:setVisible(true)
                daoName = GameTxt.match_level_desc[v.reward_box.match_box_lv] .. "宝箱"
                item:getChildByName("daoju_name_n"):setString( GameTxt.match_level_desc[v.reward_box.match_box_lv] .. "宝箱")
                deadTime:getChildByName("deadTime"):setString(v.reward_box.expire_date)
                isNeedDeadLine = true
            end
            addButtonEvent(item:getChildByName("useBtn"),function( ... )
                if v.type == 6 then --开宝箱
                    qf.event:dispatchEvent(ET.EVENT_OPEN_BAOXIANG,{match_box_lv = v.reward_box.match_box_lv ,
                    cb = function (rsp)
                        if rsp.ret == 0 then
                            local paras = { rewardInfo = {0, rsp.model.coupon}}
                            qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, paras)
                            qf.event:dispatchEvent(ET.GET_DAOJU_LIST,{})
                        end
                    end})
                else 
                    self:close()
                    qf.event:dispatchEvent(ET.EVENT_BANNER_GAME_MATCHING,{})
                end
            end)

            addButtonEvent(item:getChildByName("image_bg"),function( ... )
                self:showDaojuDetail(v)
            end)
        else
            count = count - 1
        end    
    end
    
    for i=1,#list do
        count = count + 1
        if list[i].amount>0  then
            local level = list[i].level_card
            local nowLevel = math.ceil(level/10)
            if math.mod(len,4)==0 then
                self.daojuListView:pushBackDefaultItem()
            end
            len = len+1
            loga(math.floor((len-1)/4))
            local layout_item = self.daojuListView:getItem(math.floor((len-1)/4))
            local item = self.daoju_item_layout:clone()
            item:setVisible(true)
            item:setPosition(math.mod(len-1,4)*item:getContentSize().width,0)
            layout_item:addChild(item)
            
            item:getChildByName("daoju_icon"):loadTexture(string.format(GameRes.levelCardImg,nowLevel))
            item:getChildByName("daoju_name_n"):setString(Cache.user.ddz_match_config.detail[level].title.."卡")
            item:getChildByName("number"):setString("x"..list[i].amount)
            addButtonEvent(item:getChildByName("useBtn"),function( ... ) 
                self:close()
                qf.event:dispatchEvent(ET.EVENT_BANNER_GAME_MATCHING,{chooseType = list[i].level_card})
            end)

            addButtonEvent(item:getChildByName("image_bg"),function( ... )
                self:showDaojuDetail(list[i])
            end)
        else
            count = count - 1
        end    
    end

    for i,v in pairs(chanceCardList) do
        count = count + 1
        if v.amount > 0 then
            if math.mod(len,4) == 0 then
                self.daojuListView:pushBackDefaultItem()
            end
            len = len+1
            loga(math.floor((len-1)/4))
            local layout_item = self.daojuListView:getItem(math.floor((len-1)/4))
            local item = self.daoju_item_layout:clone()
            item:setVisible(true)
            item:setPosition(math.mod(len-1,4)*item:getContentSize().width,0)
            layout_item:addChild(item)
            local nowLevel =  v.money
            item:getChildByName("daoju_name_n"):setString(v.name)
            item:getChildByName("number"):setString("x"..v.amount)

            local  urlStr = self:getChanceCardUrl(v.item_id)

            loga("===chanceCard=url=="..urlStr)

            local taskID = qf.downloader:execute(urlStr, 10,
                function(path)
                    if not tolua.isnull( item ) then
                        ccui.Helper:seekWidgetByName(item,"daoju_icon"):loadTexture(path)
                    end
                end,
                function()
                end,
                function()
                end
            )

            addButtonEvent(item:getChildByName("useBtn"),function( ... )
                PopupManager:push({class = GuaguaCardInfo, init_data = {detail = v}})
                PopupManager:pop()
            end)

            addButtonEvent(item:getChildByName("image_bg"),function( ... )
                self:showDaojuDetail(v)
            end)
        else
            count = count - 1
        end    
    end
    
    for i,v in pairs(super_mulCardList) do
        count = count + 1
        if v.amount > 0 then
            if math.mod(len,4) == 0 then
                self.daojuListView:pushBackDefaultItem()
            end
            len = len+1
            loga(math.floor((len-1)/4))
            local layout_item = self.daojuListView:getItem(math.floor((len-1)/4))
            local item = self.daoju_item_layout:clone()
            item:setVisible(true)
            item:setPosition(math.mod(len-1,4)*item:getContentSize().width,0)
            layout_item:addChild(item)

            item:getChildByName("daoju_name_n"):setString(v.alias)
            item:getChildByName("number"):setString("x"..string.format("%d", v.amount))
            item:getChildByName("daoju_icon"):loadTexture(string.format(GameRes.super_multi_card))

            addButtonEvent(item:getChildByName("useBtn"),function( ... )
                self:close()
                if v.name == "super_multi_card" then
                   qf.event:dispatchEvent(ET.EVENT_JUMP_QUICK_COIN_GAME,{})
                end
            end)

            addButtonEvent(item:getChildByName("image_bg"),function( ... )
                self:showDaojuDetail(v)
            end)
        else
            count = count - 1
        end    
    end

    for i,v in pairs(cardRememberList) do
        count = count + 1
        if v.amount > 0 then
            if math.mod(len,4) == 0 then
                self.daojuListView:pushBackDefaultItem()
            end
            len = len+1
            loga(math.floor((len-1)/4))
            local layout_item = self.daojuListView:getItem(math.floor((len-1)/4))
            local item = self.daoju_item_layout:clone()
            item:setVisible(true)
            item:setPosition(math.mod(len-1,4)*item:getContentSize().width,0)
            layout_item:addChild(item)
            local nowLevel =  v.money 
            item:getChildByName("daoju_name_n"):setString(v.alias)
            item:getChildByName("number"):setString("x"..string.format("%d", v.amount))

            item:getChildByName("daoju_icon"):loadTexture(string.format(GameRes.rememberCardImg))

            addButtonEvent(item:getChildByName("useBtn"),function( ... )
                self:close()
                if v.name == "cards_remember_daily" or v.name == "cards_remember" then
                    qf.event:dispatchEvent(ET.EVENT_JUMP_QUICK_COIN_GAME,{})
                 end
            end)

            addButtonEvent(item:getChildByName("image_bg"),function( ... )
                self:showDaojuDetail(v)
            end)
        else
            count = count - 1
        end    
    end

    self.daojuListView:jumpToTop ()
    if len <=0  then
        self.empty_desc:setVisible(true)
    end
    
end

function DaojuView:showDaojuDetail(info)
    PopupManager:push({class = DaojuInfoView, init_data = {data = info, cb = function()
    end}})
    PopupManager:pop()
end

function DaojuView:getChanceCardUrl(item_id)
    local urlStr = ""
    for i=1,#Cache.Config.chance_card_url_list do
        if Cache.Config.chance_card_url_list[i].item_id == item_id then
            urlStr = Cache.Config.chance_card_url_list[i].url
        end
    end
    return urlStr
end

return DaojuView