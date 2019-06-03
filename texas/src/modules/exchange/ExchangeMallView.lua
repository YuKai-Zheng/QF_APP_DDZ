-- 兑换商城
local ExchangeMallView = class("ExchangeMallView", CommonWidget.BasicWindow)

ExchangeMallView.TAG = "ExchangeMallView"

local HallMenuComponent = import("src.modules.global.components.HallMenuComponent")
local CustomScrollView = import("..common.widget.CustomScrollView")

ExchangeMallView.ALWAYS_SHOW = true

function ExchangeMallView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()


    ExchangeMallView.super.ctor(self,parameters)
end

function ExchangeMallView:init()
    self.data = Cache.ExchangeMallInfo
end

function ExchangeMallView:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.exchangeMallJson)

    self.panel_info = ccui.Helper:seekWidgetByName(self.gui, "panel_info")     -- 上方信息栏
    self.panel = ccui.Helper:seekWidgetByName(self.gui, "panel")               -- UI容器
    self.btn_record = ccui.Helper:seekWidgetByName(self.panel, "btn_record")    -- 兑换记录
    self.focaTips = ccui.Helper:seekWidgetByName(self.panel, "focaTips")    -- 福卡中心的调整按钮
    self.btn_bag = ccui.Helper:seekWidgetByName(self.panel, "btn_bag")          -- 背包按钮
    self.btn_setting = ccui.Helper:seekWidgetByName(self.panel, "btn_setting")  -- 设置按钮
    self.panel_menu = ccui.Helper:seekWidgetByName(self.panel, "panel_menu")    -- 左侧分类菜单
    self.panel_items = ccui.Helper:seekWidgetByName(self.panel, "panel_items")  -- 商品列表容器
    self.exchange_item = ccui.Helper:seekWidgetByName(self.panel, "exchange_item")  -- 商品模板
    self.itemP = ccui.Helper:seekWidgetByName(self.panel, "panel_row")

    if FULLSCREENADAPTIVE then
        self.panel_menu:setPositionX(self.panel_menu:getPositionX()-(self.winSize.width - 1920)/4)
        self.panel_items:setPositionX(self.panel_items:getPositionX()+(self.winSize.width - 1920)/4)
        self.btn_record:setPositionX(self.btn_record:getPositionX()+(self.winSize.width - 1920)/2)
        self.focaTips:setPositionX(self.focaTips:getPositionX()-(self.winSize.width - 1920)/2)
        self.btn_bag:setPositionX(self.btn_bag:getPositionX()+(self.winSize.width - 1920)/2)
        self.btn_setting:setPositionX(self.btn_setting:getPositionX()+(self.winSize.width - 1920)/2)
    end

    self:initPanelInfo() -- 初始化上方信息栏
    self:initMenu()      -- 初始化左侧分类菜单
    self:updateItems()   -- 初始化右侧兑换物品
end

function ExchangeMallView:initClick()
    addButtonEvent(self.btn_bag, function(sender)
        qf.event:dispatchEvent(ET.SHOW_DAOJU_VIEW)
        qf.platform:umengStatistics({umeng_key = "pack"})--点击上报
    end)
    addButtonEvent(self.btn_setting, function(sender)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅设置") end
        qf.event:dispatchEvent(ET.SHOW_SETTING_VIEW)
        qf.platform:umengStatistics({umeng_key = "Set_up"})--点击上报
    end)
    addButtonEvent(self.btn_record, function(sender)
        qf.event:dispatchEvent(ET.SHOW_EXCHANGERECORD_DIALOG)
     	qf.event:dispatchEvent(ET.WELFARE_INDIANNA_RECORD)
    end)

    addButtonEvent(self.focaTips, function(sender)
        qf.event:dispatchEvent(ET.SHOW_FOCASTASK_VIEW)
    end) 
end

function ExchangeMallView:initMenu()
    local classifyInfoList = self.data:getClassifyList()
    local menu_btn = self.panel_menu:getChildByName("menu_btn")
    menu_btn:setVisible(false)

    self.menuBtnList = {}
    self.pre_menu_index = 1
    self.menu_index = 1

    local getResIndex = function(i, len)
        if i==1 then
            return 1
        elseif i~=len then
            return 2
        else
            return 3
        end
    end

    local changeBtn = function(btn, isSelected)
        local length = #classifyInfoList

        if isSelected then
            btn:loadTextureNormal(string.format(GameRes.exchangeMallMenuBtnSelected, getResIndex(btn.btn_index, #classifyInfoList)))
            btn:loadTexturePressed(string.format(GameRes.exchangeMallMenuBtnSelected, getResIndex(btn.btn_index, #classifyInfoList)))
            btn:setPosition(btn:getPositionX() - 6, btn:getPositionY() + 6) -- 美术图没切好
            btn:getChildByName("menu_btn_title"):setPosition(btn:getContentSize().width*0.5, btn:getContentSize().height*0.5)
            btn:getChildByName("menu_btn_title"):setFntFile(GameRes.exchangeMallFont_btn_2)
        else
            btn:loadTextureNormal(string.format(GameRes.exchangeMallMenuBtn, getResIndex(btn.btn_index, #classifyInfoList)))
            btn:loadTexturePressed(string.format(GameRes.exchangeMallMenuBtn, getResIndex(btn.btn_index, #classifyInfoList)))
            btn:setPosition(btn:getPositionX() + 6, btn:getPositionY() - 6)
            btn:getChildByName("menu_btn_title"):setPosition(btn:getContentSize().width*0.5-6, btn:getContentSize().height*0.5+10)
            btn:getChildByName("menu_btn_title"):setFntFile(GameRes.exchangeMallFont_btn_1)
        end
    end

    if classifyInfoList then
        for i,v in pairs(classifyInfoList) do
            local btn = menu_btn:clone()
    
            btn:getChildByName("menu_btn_title"):setString(v.name)
            btn:setPositionY(800 - (btn:getContentSize().height - 18)*i)
            if i == self.menu_index then
                changeBtn(btn, true)
            else
                btn:loadTextureNormal(string.format(GameRes.exchangeMallMenuBtn, getResIndex(i, #classifyInfoList)))
                btn:loadTexturePressed(string.format(GameRes.exchangeMallMenuBtn, getResIndex(i, #classifyInfoList)))
            end
            btn.btn_index = i
            addButtonEvent(btn, function(sender)
                self.pre_menu_index = self.menu_index
                self.menu_index = sender.btn_index
    
                changeBtn(self.menuBtnList[self.pre_menu_index], false)
                changeBtn(self.menuBtnList[self.menu_index], true)
    
                self:updateItems()
            end)
            btn:setVisible(true)
            self.panel_menu:addChild(btn)
    
            self.menuBtnList[i] = btn
        end
    end
end

function ExchangeMallView:updateItems()
    local classifyInfoList = self.data:getClassifyList()

    if not classifyInfoList or not classifyInfoList[self.menu_index] then return end

    local gapX,gapY = 10,40
    local itemWidth = self.exchange_item:getContentSize().width
    local itemHeight = self.exchange_item:getContentSize().height
    local panelHeight = self.panel_items:getContentSize().height

    self.panel_items:removeAllChildren()

    self.panel_items:setItemModel(self.itemP)

    for k,v in pairs(classifyInfoList[self.menu_index].goods) do
        if math.mod(tonumber(k-1),4) == 0 then
            self.panel_items:pushBackDefaultItem()
        end
        local item = self.exchange_item:clone()
        local layout_item = self.panel_items:getItem(math.floor((tonumber(k-1))/4))
        item:setPosition(tonumber(k-1)%4*(itemWidth + gapX), 0)
        self:updateItem(v, item)
        layout_item:addChild(item)
    end
end

function ExchangeMallView:updateItem(info, item)
    local item_bg = item:getChildByName("item_bg")
    item_bg:getChildByName("item_name"):setString(info.name)
    item_bg:getChildByName("txt_price"):setString(info.info[1].num)
    if info.discount and info.discount ~= 100 then
        item:getChildByName("isOffer"):getChildByName("offer_txt"):setString(string.format(GameTxt.exchangeMall_offer, info.discount/10))
        item:getChildByName("isOffer"):setVisible(true)
    end
    if info.hot_tag == 1 then
        item:getChildByName("isHot"):setVisible(true)
    end
    addButtonEvent(item, function(sender)
        qf.event:dispatchEvent(ET.SHOW_EXCHANGEDETAIL_DIALOG, {info=info})
    end)
    item:setVisible(true)

    -- 加载商品图片
    if info.icon and info.icon ~= "" then
        qf.downloader:execute(info.icon, 10,
            function(path)
                if isValid( item ) then
                    item_bg:getChildByName("img_commodity"):loadTexture(path)
                end
            end,function() end,function() end
        )
    end
end

function ExchangeMallView:initPanelInfo()
    self.menu = HallMenuComponent.new({
        return_cb = function (  )
            self:close()
        end,
        title = {img = GameRes.exchangeMallTitle}
    })
    self.panel_info:addChild(self.menu)
    self.menu:setPositionY(-self.menu:getContentSize().height)

    self.menu:hideGold()
    self.menu:startAnimation()
end

function ExchangeMallView:updateInfoData()
    self.menu:updateData()
end

return ExchangeMallView