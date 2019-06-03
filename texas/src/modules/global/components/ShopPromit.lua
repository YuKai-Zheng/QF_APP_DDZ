local ShopPromit = class("ShopPromit",CommonWidget.BasicWindow)

ShopPromit.ITEM_WIDTH = 416

ShopPromit.SHOW_DIAMOND_LAYOUT = 1--展示钻石购买界面
ShopPromit.SHOW_GOLD_LAYOUT = 2--展示金币购买界面

function ShopPromit:ctor(paras)
    ShopPromit.super.ctor(self, paras)
    self.cb = paras.cb
end

function ShopPromit:init(paras)
    self.gold_limit = paras.gold
    self.ref = paras.ref

    --获取满足条件的最少的金币商品
    local goldInfo = Cache.QuickPay:getSuitableGoldInfoByRequire(self.gold_limit)
    --钻石充足展示钻石购买界面，其他情况展示购买钻石界面
    if goldInfo ~= nil and goldInfo.price <= Cache.user.diamond then
        self.choiceIndex = self.SHOW_GOLD_LAYOUT
    else
        self.choiceIndex = self.SHOW_DIAMOND_LAYOUT
    end
    if paras.choiceIndex and paras.choiceIndex > 0 then
        self.choiceIndex = paras.choiceIndex
    end
    self.choiceIndex = self.SHOW_DIAMOND_LAYOUT
end

--初始化共用ui
function ShopPromit:initUI()
    local tip_str = ""
    if GAME_LANG == "zh_tr" then
        tip_str = string.format(GameTxt.shop_promit_tip_8, Cache.Config.qq_prompt_last)   --港台版提示不同
    else
        tip_str = string.format(GameTxt.shop_promit_tip_8, Cache.Config.qq_prompt, Cache.Config.qq_prompt_last)
    end
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.shopPromitJson)
    self.gui:setAnchorPoint(0.5,0.5)
    self.below_img = ccui.Helper:seekWidgetByName(self.gui, "below_img")
    self.promit_close_bt = ccui.Helper:seekWidgetByName(self.gui, "promit_close_bt")
    self.promit_sure_bt = ccui.Helper:seekWidgetByName(self.gui, "promit_sure_bt")
    self.lblTip = ccui.Helper:seekWidgetByName(self.gui, "lbl_tip")
    self.lblTip:setString(tip_str)
    self.promit_layout = ccui.Helper:seekWidgetByName(self.gui, "promit_layout")
    self.tag_txt = self.promit_layout:getChildByName("tag_txt")

    self.choose_bg = self.promit_layout:getChildByName("choose_bg")
    self.title_btn_1 = self.choose_bg:getChildByName("title_btn_1")
    self.title_btn_2 = self.choose_bg:getChildByName("title_btn_2")

    self.diamond_layout = self.promit_layout:getChildByName("diamond_layout")
    self.gold_layout = self.promit_layout:getChildByName("gold_layout")



    if self.choiceIndex == self.SHOW_DIAMOND_LAYOUT then
        self.title_btn_1:setOpacity(255)
        self.title_btn_2:setOpacity(0)
        self.diamond_layout:setVisible(true)
        self:initDiamondLayout()
        self.tag_txt:setString(GameTxt.shop_promit_tip_6)
        qf.event:dispatchEvent(ET.USER_ACTION_STATS_EVT, {ref=self.ref, currency=PAY_CONST.CURRENCY_DIAMOND})
    else
        self.title_btn_1:setOpacity(0)
        self.title_btn_2:setOpacity(255)
        self.gold_layout:setVisible(true)
        self:initGoldLayout()
        self.tag_txt:setString(GameTxt.shop_promit_tip_7)
        qf.event:dispatchEvent(ET.USER_ACTION_STATS_EVT, {ref=self.ref, currency=PAY_CONST.CURRENCY_GOLD})
    end
end

--初始化钻石界面ui
function ShopPromit:initDiamondLayout()
    self.method_btn = self.diamond_layout:getChildByName("method_btn")
    self.method_btn:setVisible(true)
    self.now_method_img = self.method_btn:getChildByName("method_img")
    self.now_method_name = self.method_btn:getChildByName("method_name")
    self.diamond_item = self.diamond_layout:getChildByName("diamond_item")
    self.method_layout = self.diamond_layout:getChildByName("method_layout")
    self._item = self.method_layout:getChildByName("_item")
    self._item:setVisible(false)

    self.diamondInfo = Cache.QuickPay:getSuitableDiamondByRequire(self.gold_limit)
    self._tbDiamondData = Cache.PayManager:getOrdinalDiamondList()
    if self._tbDiamondData == nil or #self._tbDiamondData <= 0 then return end

    local _kFind
    for k, v in pairs(self._tbDiamondData) do
        if self.diamondInfo.cost == v.cost then
            _kFind = k
            break
        end
    end
    loga("_kFind",_kFind)
    _kFind = _kFind or #self._tbDiamondData
    self.tbToShopInfo = clone(self._tbDiamondData[_kFind])
    self.itemSelected = _kFind

    self:initScrollViewDiamond()
    self:updateScrollViewIcon()

    self.isItemBgShow = false
    addButtonEvent(self.method_btn,function ( sender )
        self.isItemBgShow = not self.isItemBgShow
        local y = self.isItemBgShow and -1 or 1
        self.below_img:setScaleY(y)
        self.method_layout:setVisible(self.isItemBgShow)
        self.lblTip:setVisible(not self.isItemBgShow)
    end)
end

--初始化金币界面ui
function ShopPromit:initGoldLayout()
    self.gold_item = self.gold_layout:getChildByName("gold_item")
    self.method_btn = self.diamond_layout:getChildByName("method_btn")
    self.method_btn:setVisible(false)
    self.gold_frame = cc.Sprite:create(GameRes.shoppromit_item_selected_frame)
    self.gold_frame:setAnchorPoint(0, 0)
    self.gold_frame:runAction(cc.MoveTo:create(0,cc.p(42,16)))
    self.gold_layout:addChild(self.gold_frame, 10)

    self:initGoldList()
end

--设置点击事件
function ShopPromit:initClick()
    self.promit_layout:setTouchEnabled(true)
    addButtonEvent(self.gui,function ( sender )
    end)
    addButtonEvent(self.promit_close_bt,function ( sender )
        self:close()
    end)

    --更新选项按钮UI
    local function refeshBtn()
        local bool = (self.choiceIndex == self.SHOW_DIAMOND_LAYOUT)
        if bool then   
            self.title_btn_1:setOpacity(255)
            self.title_btn_2:setOpacity(0)
        else
            self.title_btn_1:setOpacity(0)
            self.title_btn_2:setOpacity(255)
        end
        self.diamond_layout:setVisible(bool)
        self.gold_layout:setVisible(not bool)

        if bool then
            if not self.diamond_item then
                self:initDiamondLayout()
            end
            if table.getn(self.payMethodsList) <= 1 then 
                self.method_btn:setVisible(false)
            else
                self.method_btn:setVisible(true)
            end
            self.lblTip:setVisible(not self.isItemBgShow)
            self.tag_txt:setString(GameTxt.shop_promit_tip_6)
        else
            if not self.gold_item then
                self:initGoldLayout()
            end
            self.lblTip:setVisible(true)
            self.tag_txt:setString(GameTxt.shop_promit_tip_7)
        end
    end
    addButtonEvent(self.title_btn_1,function ( sender )
        self.choiceIndex = self.SHOW_DIAMOND_LAYOUT
        refeshBtn()
    end)
    addButtonEvent(self.title_btn_2,function ( sender )
        self.choiceIndex = self.SHOW_GOLD_LAYOUT
        refeshBtn()
    end)

    addButtonEvent(self.promit_sure_bt,function ( sender )
        if self.choiceIndex == self.SHOW_DIAMOND_LAYOUT then
            if self.tbToShopInfo and table.getn(self.payMethodsList) > 0 then
                local cur_method = self.payMethodsList[self.channel_itemSelected]
                local payInfo = Cache.PayManager:getPayInfoByDiamondAndPaymethod(self.tbToShopInfo.diamond, cur_method)
                payInfo.ref = self.ref
                qf.event:dispatchEvent(ET.GAME_PAY_NOTICE, payInfo)
            end
            qf.platform:umengStatistics({umeng_key="Added_diamond_next"})--点击上报
        else
            if self.tbToGoldInfo then
                local callback = function()
                    qf.event:dispatchEvent(ET.NET_PRODUCT_EXCHANGE_BY_DIAMOND, {item_name=self.tbToGoldInfo.item_name, ref=self.ref})
                end
            
                local ret = {}
                ret.sureCb = callback

                local content = GameTxt.string_shop_buy_props_use_diamond
                ret.content = string.format(content, self.tbToGoldInfo.price, self.tbToGoldInfo.amount..GameTxt.global_string113)
                ret.title = GameRes.shop_title_buy_gold

                qf.event:dispatchEvent(ET.EVENT_SHOW_BUY_POPUP_TIP_VIEW, ret)
            end
           qf.platform:umengStatistics({umeng_key="Added_gold_next"})--点击上报 
        end
    end)
end

function ShopPromit:show()
    ShopPromit.super.show(self)
end

function ShopPromit:EnterActionDone()
    
end

function ShopPromit:startRemoveAction()
	
end

------钻石列表start--------
--初始化钻石列表
function ShopPromit:initScrollViewDiamond( ... )
    self.innerContainer = cc.Layer:create()
    self.innerContainer:setAnchorPoint(ccp(0, 0))
    self.innerContainer:setTouchEnabled(true)
    self.scrollviewDiamond = cc.ScrollView:create()
    self.scrollviewDiamond:setContainer(self.innerContainer)
    self.scrollviewDiamond:setBounceable(true)
    self.scrollviewDiamond:setViewSize(cc.size(1376, 400))
    self.scrollviewDiamond:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self.scrollviewDiamond:setPosition(cc.p(55, 335))
    self.scrollviewDiamond:setClippingToBounds(true)
    self.scrollviewDiamond:setContentSize(cc.size(1376, 0))
    self.scrollviewDiamond:setDelegate()
    self.scrollviewDiamond:registerScriptHandler(function( )
        if not self.touchEnded then return end
        self.touchEnded = false
        if self.touchClicked then
            self.touchClicked = false
            return 
        end
        -- local _prex = -(self.itemSelected - 1)*self.ITEM_WIDTH
        -- local _offx = self.innerContainer:getPositionX() -- self.ITEM_WIDTH/2
        -- if _prex < _offx then
        --     _offx = _offx - self.ITEM_WIDTH/4
        -- elseif _prex > _offx then
        --     _offx = _offx - self.ITEM_WIDTH*3/4
        -- end
        -- local _index = math.floor(-_offx/self.ITEM_WIDTH) + 1
        -- self:scrollToIndex(_index)
    end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.diamond_layout:addChild(self.scrollviewDiamond)

    local _listen = cc.EventListenerTouchOneByOne:create()
    _listen:registerScriptHandler(function(touch, event)
            self.touchEnded = false
            self.touchBeganX = touch:getLocation()
            -- self.scrollviewDiamond:stopAllActions()
            return true 
        end
        , cc.Handler.EVENT_TOUCH_BEGAN)
    _listen:registerScriptHandler(function(touch, event)
            self.touchEnded = true
            self.touchEndedX = touch:getLocation()
        end
        ,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self.innerContainer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(_listen, self.innerContainer)

    self.tbItems = {}
    self.itemScrollBg = cc.Sprite:create(GameRes.shoppromit_item_selected_frame)
    self.itemScrollBg:setAnchorPoint(0, 0)
    -- self.itemScrollBg:runAction(cc.MoveTo:create(0,cc.p(42,16)))
    self.innerContainer:addChild(self.itemScrollBg, 10)
end

-- 更新ScrollView
function ShopPromit:updateScrollViewIcon( ... )
    for i = 1, #self._tbDiamondData do
        if i <= #self.tbItems then
            self:updateItemByIndex(i)
        else
            self:insertToScrollViewIcon(i)
        end
    end
    if #self._tbDiamondData < #self.tbItems then
        for i = #self._tbDiamondData + 1, #self.tbItems do
            self.tbItems[i]:removeFromParent()
            self.tbItems[i] = nil 
        end
    end
    self.innerContainer:setContentSize(cc.size(#self.tbItems*self.ITEM_WIDTH, 400))
    self.innerContainer:setPositionX(0)
    self:scrollToIndex(self.itemSelected)
end
-- 滑动到指定的位置
function ShopPromit:scrollToIndex( index )
    index = index < 1 and 1 or index > #self.tbItems and #self.tbItems or index
    local _item = self.tbItems[index]
    local pos = cc.p(_item:getPositionX(),_item:getPositionY())
    local size = _item:getContentSize()
    local pos_temp =  self.innerContainer:convertToWorldSpace(pos)
    local pos_ex = self.diamond_layout:convertToNodeSpace(pos_temp)

    local minX = pos_ex.x - size.width*0.5
    local maxX = pos_ex.x + size.width*0.5
    local bg_size = self.diamond_layout:getContentSize()
    local offset = 0
    if minX<0 then
        offset = 0-minX-90
        self.innerContainer:runAction(cc.MoveBy:create(0.1,cc.p(offset,0)))
    end
    if maxX>(bg_size.width/2-3) then
        offset = bg_size.width-maxX-753
        self.innerContainer:runAction(cc.MoveBy:create(0.1,cc.p(offset,0)))
    end

    self.itemScrollBg:setPosition(cc.p(self.tbItems[index]:getPositionX()+42,self.tbItems[index]:getPositionY()+16))
    self.tbToShopInfo = clone(self._tbDiamondData[index])
    self.itemSelected = index

    self:initPayMethods(self.tbToShopInfo.diamond)
end
-- 插入Item到ScrollViewDiamond
function ShopPromit:insertToScrollViewIcon( index )
    local _item = self.diamond_item:clone()
    self.tbItems[index] = _item
    _item:setVisible(true)
    self:updateItemByIndex(index)
    self.innerContainer:addChild(_item)

    local _listen = cc.EventListenerTouchOneByOne:create()
    _listen:setSwallowTouches(false)
    _listen:registerScriptHandler(function(touch, event)
            local _pos = _item:getParent():convertToNodeSpace(touch:getLocation())
            self.touchItemBegan = _pos
            return cc.rectContainsPoint(_item:getBoundingBox(), _pos)
        end
        , cc.Handler.EVENT_TOUCH_BEGAN)
    _listen:registerScriptHandler(function(touch, event)
            local _pos = _item:getParent():convertToNodeSpace(touch:getLocation())
            if cc.rectContainsPoint(_item:getBoundingBox(), _pos) then
                if math.abs(self.touchItemBegan.x - _pos.x) < 5
                    and math.abs(self.touchItemBegan.y - _pos.y) < 5
                    then
                    self.touchClicked = true
                    self:onItemCall(index)
                end
            end

        end
        ,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = _item:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(_listen, _item)

    local x, y = (index-1)*self.ITEM_WIDTH, 8
    _item:setPosition(cc.p(x, y))
end
-- 更新第index个Item
function ShopPromit:updateItemByIndex( index )
    local _data = self._tbDiamondData[index]
    local _item = self.tbItems[index]
    local diamond_img = string.format(GameRes.shop_diamond, _data.level)
    local diamond_num_txt = _item:getChildByName("diamond_num_txt")
    local diamond_txt = _item:getChildByName("diamond_txt")
    
    diamond_num_txt:setString(_data.diamond)
    local txt_pos_x = diamond_txt:getPositionX()
    local _num_size = diamond_num_txt:getContentSize()
    diamond_txt:setPositionX(txt_pos_x+_num_size.width*0.5-10)

    _item:getChildByName("diamond_img"):loadTexture(diamond_img)
    _item:getChildByName("money_txt"):setString(string.format(GameTxt.string_yuan, tostring(_data.cost)))
end
-- Item被点击
function ShopPromit:onItemCall( index )
    if index ~= self.itemSelected then
        self:scrollToIndex(index)
    end
end
------钻石列表end--------

------支付方式start------
function ShopPromit:initPayMethods(diamond)
    self.payMethodsList = {}
    self.payMethodsList = Cache.QuickPay:getPayMethodsByDiamondNum(diamond)
    
    self.channel_itemSelected = 1
    if table.getn(self.payMethodsList) <= 1 then 
        self.method_btn:setVisible(false)
        return 
    end

    if self.channel_tbItems then
        for k,v in pairs(self.channel_tbItems) do
            v:removeFromParent()
        end
    end
    self.channel_tbItems = {}
    self:updateScrollViewChannel()
end

-- 更新channel ScrollView
function ShopPromit:updateScrollViewChannel()
    for i = 1, #self.payMethodsList do
        self:insertToScrollviewChannel(i)
    end
    self:channel_scrollToIndex(self.channel_itemSelected)
end

-- 插入Item到scrollviewChannel
function ShopPromit:insertToScrollviewChannel( index )
    local _item = self._item:clone()
    _item:setVisible(true)
    _item:setPosition((index-1)*250, 0)
    _item:setTag(index)

    local method_type = _item:getChildByName("method_type")
    local img, img_0, pay_img, pay_name = Util:getPayMethodRes(self.payMethodsList[index])
    method_type:loadTexture(img_0)

    addButtonEvent(_item,function ( sender )
        local _index = sender:getTag()
        if _index ~= self.channel_itemSelected then
            self:channel_scrollToIndex(_index)
        end
    end)
    self.channel_tbItems[index] = _item
    self.method_layout:addChild(_item)
end

-- 支付渠道滑动到指定的位置
function ShopPromit:channel_scrollToIndex( index )
    local radio = self.channel_tbItems[self.channel_itemSelected]:getChildByName("radio")
    radio:loadTexture(GameRes.radio_btn_unselected)
    local method_type = self.channel_tbItems[self.channel_itemSelected]:getChildByName("method_type")
    local img, img_0, pay_img, pay_name = Util:getPayMethodRes(self.payMethodsList[self.channel_itemSelected])
    method_type:loadTexture(img_0)

    local radio = self.channel_tbItems[index]:getChildByName("radio")
    radio:loadTexture(GameRes.radio_btn_selected)
    local method_type = self.channel_tbItems[index]:getChildByName("method_type")
    local img, img_0, pay_img, pay_name = Util:getPayMethodRes(self.payMethodsList[index])
    method_type:loadTexture(img)

    self.now_method_img:loadTexture(pay_img)
    self.now_method_name:setText(pay_name)
    self.channel_itemSelected = index
end
------支付方式end------

------金币列表start------
function ShopPromit:initGoldList()

    local   diamond  = Cache.QuickPay:getSuitableDiamondByRequire(self.gold_limit)
    self._tbGoldData = Cache.QuickPay:getRecommendGoldByRequire(diamond.diamond)


    if (not self._tbGoldData) or #self._tbGoldData <= 0 then 
        self.gold_frame:setVisible(false)
        return 
    end

    for i=1,#self._tbGoldData do
        local gold_data = self._tbGoldData[i]
        local _goldItem = self.gold_item:clone()
        local pos_x, pos_y = self:getGoldItemPos(i)
        _goldItem:setVisible(true)
        _goldItem:setPosition(pos_x, pos_y)
        self.gold_layout:addChild(_goldItem)

        local car_img = _goldItem:getChildByName("car_img")
        local car_name_txt = _goldItem:getChildByName("car_name_txt")
        local gold_num_txt = _goldItem:getChildByName("gold_num_txt")
        local txt_1 = _goldItem:getChildByName("txt_1")
        local txt_2 = _goldItem:getChildByName("txt_2")
        local pay_num_txt = _goldItem:getChildByName("pay_num_txt")
        local diamond_img = _goldItem:getChildByName("pay_img")
        local car_name, car_path = Util:getCarRes(gold_data.level)
        car_name_txt:setString(car_name)
        car_img:loadTexture(car_path)

        local isAddSuffix = (gold_data.amount > 1000000)
        local amount = isAddSuffix and (gold_data.amount/10000) or Util:matchStr(gold_data.amount, ".")
        gold_num_txt:setString(amount)
        local txt_1_pos_x = txt_1:getPositionX()
        local txt_2_pos_x = txt_2:getPositionX()
        local _gold_num_size = gold_num_txt:getContentSize()
        
        if isAddSuffix then
            local x, y = gold_num_txt:getPosition()
            local suffix = cc.Sprite:create(GameRes.shop_gold_suffix)
            _goldItem:addChild(suffix)

            local suffix_size = suffix:getContentSize()
            txt_1:setPositionX(txt_1_pos_x-(_gold_num_size.width+suffix_size.width)*0.5+5)
            gold_num_txt:setPosition(x-suffix_size.width*0.5,y)
            x, y = gold_num_txt:getPosition()
            suffix:setPosition(x+(_gold_num_size.width+suffix_size.width)*0.5,y)
            txt_2:setPositionX(txt_2_pos_x+_gold_num_size.width*0.5+suffix_size.width*0.5-10)
        else
            txt_1:setPositionX(txt_1_pos_x-_gold_num_size.width*0.5+5)
            txt_2:setPositionX(txt_2_pos_x+_gold_num_size.width*0.5-10)
        end

        pay_num_txt:setString(gold_data.price)

        local diamond_pos_x = diamond_img:getPositionX()
        local _pay_num_size = pay_num_txt:getContentSize()
        diamond_img:setPositionX(diamond_pos_x-_pay_num_size.width*0.5+5)

        addButtonEvent(_goldItem,function ( sender )
            self.gold_frame:setPosition(pos_x+42, pos_y+16)
            self.tbToGoldInfo = gold_data
        end)
    end
    local default_index = 2
    local pos_x, pos_y = self:getGoldItemPos(default_index)
    self.gold_frame:setPosition(pos_x, pos_y)
    self.tbToGoldInfo = self._tbGoldData[default_index]
end

function ShopPromit:close()
    if self.cb then
        self.cb()
        self.cb=nil
    end
    ShopPromit.super.close(self)
end

--第一个数据居中显示，第二个数据居左显示，第三个数据居右显示
function ShopPromit:getGoldItemPos(index)
    return (index-1)*450+90, 340
end
------金币列表end------
return ShopPromit
