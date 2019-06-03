local Bankruptcy = class("Bankruptcy",CommonWidget.BasicWindow)

function Bankruptcy:ctor(paras)
    self.diamondInfo = {}
    self.goldInfo = {}
    self.cb       = paras.cb
    Bankruptcy.super.ctor(self, paras)
    qf.platform:umengStatistics({umeng_key = "HelpGold"})
end
function Bankruptcy:show()
    Bankruptcy.super.show(self)

    qf.event:dispatchEvent(ET.GAME_SHOW_BOUNCE_BTN,{type="bankruptcy"})
    qf.event:dispatchEvent(ET.NET_COLLAPSE_PAY_REQ)
end

function Bankruptcy:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.bankruptcyJson)
    if not paras.min then 
        if Cache.DeskAssemble:judgeGameType(JDC_MATCHE_TYPE) then   --只有经典场才有破产补助
            self.carryMin = Cache.desk:getRoomCarryMin()
        else
            qf.event:dispatchEvent(ET.GLOBAL_HANDLE_BANKRUPTCY,{method="hide"})
            return
        end
    else
        self.carryMin = paras.min
    end

    -- self.carryMin = 500000
    self.gui:setAnchorPoint(0.5,0.5)

    self.right_layout = ccui.Helper:seekWidgetByName(self.gui,"right_layout")
    --self.remind_txt = self.right_layout:getChildByName("remind_txt")
    self.get_btn = self.right_layout:getChildByName("get_btn")
    local gold_txt_layout = self.get_btn:getChildByName("gold_txt_layout")
    self.get_num_txt = gold_txt_layout:getChildByName("gold_num_txt")
    self.diamond_layout = ccui.Helper:seekWidgetByName(self.gui,"diamond_layout")
    self.gold_layout = ccui.Helper:seekWidgetByName(self.gui,"gold_layout")
    self.now_method_img = ccui.Helper:seekWidgetByName(self.gui,"method_img")

    local showType = Cache.QuickPay:isMoneyEnough(self.carryMin)

    self:showLayoutByType(showType)
end

function Bankruptcy:showLayoutByType(showType)
    
    if showType == Cache.QuickPay.JUDGE_ENOUGH.BOTH_NOT_ENOUGH then
        self.gold_layout:setVisible(false)
        self.diamond_layout:setVisible(true)


        local diamond_layout = self.diamond_layout
        local layout_1 = diamond_layout:getChildByName("layout_1")
        local layout_2 = diamond_layout:getChildByName("layout_2")

        self.pay_diamond_btn = diamond_layout:getChildByName("pay_diamond_btn")
        local num_layout = self.pay_diamond_btn:getChildByName("num_layout")
        self.pay_diamond_num_txt = num_layout:getChildByName("txt_num")
        self.method_btn = diamond_layout:getChildByName("method_btn")
        self.now_method_img = self.method_btn:getChildByName("img_method")
        self.method_layout = diamond_layout:getChildByName("method_layout")
        self._item = self.method_layout:getChildByName("_item")
        self._item:setVisible(false)

        self:setDiamondClick()
        self:initDiamondData()
        qf.event:dispatchEvent(ET.USER_ACTION_STATS_EVT, {ref=UserActionPos.GAME_POCHAN, currency=PAY_CONST.CURRENCY_DIAMOND})
    elseif showType == Cache.QuickPay.JUDGE_ENOUGH.DIAMOND_ENOUGH then

        self.gold_layout:setVisible(true)
        self.diamond_layout:setVisible(false)
        local gold_layout = self.gold_layout

        self.pay_gold_btn = gold_layout:getChildByName("pay_gold_btn")
        local num_layout = self.pay_gold_btn:getChildByName("num_layout")
        self.pay_gold_num_txt = num_layout:getChildByName("txt_num")
        self.gold_num_txt_2 = ccui.Helper:seekWidgetByName(self.gold_layout,"product_gold_num")
        self.product_img=ccui.Helper:seekWidgetByName(self.gold_layout,"gold_img_1")
        self:setGoldClick()
        self:initGoldData()
        qf.event:dispatchEvent(ET.USER_ACTION_STATS_EVT, {ref=UserActionPos.GAME_POCHAN, currency=PAY_CONST.CURRENCY_DIAMOND})
    else
        self:close()
    end
end

function Bankruptcy:initClick()
    addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"close_btn"),function ( sender )
        self:close()
    end)
    local getFunc = function ( sender )
        if self.is_all_send == 1 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=string.format(GameTxt.global_string114,Cache.Config.bankrupt_count)})
        elseif self.remain and self.remain > 1 then
            local minute = math.floor(self.remain/60)
            local seconds = self.remain-minute*60
            local time_str = minute <= 0 and seconds or minute..GameTxt.global_string116..seconds
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=GameTxt.global_string115..time_str..GameTxt.global_string117})
        elseif Cache.user.gold > Cache.Config.bankrupt_money then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=GameTxt.global_string107})
        else
            qf.event:dispatchEvent(ET.NET_GET_COLLAPSE_PAY_REQ)
            
            self.get_btn:setEnabled(false)
            self.get_btn:setColor(Theme.Color.DARK)

            self:delayRun(0.2,function()
                qf.event:dispatchEvent(ET.NET_COLLAPSE_PAY_REQ)
            end)
        end
        qf.platform:umengStatistics({umeng_key="Bankruptcy_claim"})--点击上报
    end
    addButtonEvent(self.right_layout, getFunc)
    addButtonEvent(self.get_btn, getFunc)
end

function Bankruptcy:setDiamondClick()
    addButtonEvent(self.pay_diamond_btn,function ( sender )
        if self.diamondInfo and table.getn(self.payMethodsList) > 0 then
            local cur_method = self.payMethodsList[self.channel_itemSelected]
            local payInfo = Cache.PayManager:getPayInfoByDiamondAndPaymethod(self.diamondInfo.diamond, cur_method)
            payInfo.ref = UserActionPos.GAME_POCHAN
            payInfo.return_diamond = Cache.Config:getBrokeReturn(self.diamondInfo.diamond)
            qf.event:dispatchEvent(ET.GAME_PAY_NOTICE, payInfo)
        end
        qf.platform:umengStatistics({umeng_key="Pay"})--点击上报
    end)

    self.isItemBgShow = false
    addButtonEvent(self.method_btn,function ( sender )
        self.isItemBgShow = not self.isItemBgShow
        self.method_layout:setVisible(self.isItemBgShow)
    end)
end

function Bankruptcy:setGoldClick()
    addButtonEvent(self.pay_gold_btn,function ( sender )
        local callback = function()
            qf.event:dispatchEvent(ET.NET_PRODUCT_EXCHANGE_BY_DIAMOND, {item_name=self.goldInfo.item_name, ref=UserActionPos.GAME_POCHAN})
        end
    
        local ret = {}
        ret.sureCb = callback

        local content = GameTxt.string_shop_buy_props_use_diamond
        ret.content = string.format(content, self.goldInfo.price, self.goldInfo.amount..GameTxt.global_string113)
        ret.title = GameRes.shop_title_buy_gold

        qf.event:dispatchEvent(ET.EVENT_SHOW_BUY_POPUP_TIP_VIEW, ret)
    end)
end

function Bankruptcy:initDiamondData()
    self.diamondInfo = Cache.QuickPay:getSuitableDiamondByRequire(self.carryMin)
    local brokeReturn = Cache.Config:getBrokeReturn(self.diamondInfo.diamond)
    loga("diamondInfodiamondInfodiamondInfodiamondInfodiamondInfodiamondInfodiamondInfo:"..json.encode(self.diamondInfo))

    local cost = self.diamondInfo.cost..""
    num = #cost

    self.pay_diamond_num_txt:setString("仅需"..cost.."元")


    local size = self.pay_diamond_num_txt:getContentSize()
   


    local num_layout       = self.pay_diamond_btn:getChildByName("num_layout")
    local img_font         = num_layout:getChildByName("txt_num_img")


    --升序排列
    local all_diamond_info = Cache.PayManager:getDiamondList()
    local sort_diamond_asc = clone(all_diamond_info)
    table.sort(sort_diamond_asc, function(a, b)
        return a.diamond < b.diamond
    end)
    --找到最接近等值的钻石商品，获取level
    local _return_diamond_info = nil
    for k, v in pairs(sort_diamond_asc) do
        if brokeReturn <= v.diamond then
            _return_diamond_info = clone(v)
            break
        end
    end
    img_font:setString("领"..(self.diamondInfo.diamond+brokeReturn).."钻石")
    self:initPayMethods(self.diamondInfo.diamond)
end

function Bankruptcy:initGoldData()
    self.goldInfo = Cache.QuickPay:getSuitableGoldInfoByRequire(self.carryMin)

    local isAddSuffix = (self.goldInfo.amount > 100000)
    local amount = isAddSuffix and (self.goldInfo.amount/10000)..":" or self.goldInfo.amount
    loga(amount)
    self.gold_num_txt_2:setString(amount)
     
    local price = self.goldInfo.price..""
    local num = #price
    self.pay_gold_num_txt:setString(price)

    self.product_img:loadTexture(string.format(GameRes.bankruptcyCar,self.goldInfo.level))
end

function Bankruptcy:initPayMethods(diamond)
    self.payMethodsList = Cache.QuickPay:getPayMethodsByDiamondNum(diamond)
    
    self.channel_itemSelected = 1
    if table.getn(self.payMethodsList) <= 1 then 
        self.method_btn:setVisible(false)
        return 
    end

    self.channel_tbItems = {}
    self:updateScrollViewChannel()
end

-- 更新channel ScrollView
function Bankruptcy:updateScrollViewChannel()
    ccui.Helper:seekWidgetByName(self.method_layout,"methodbg"):setContentSize(250*(#self.payMethodsList)+10,80)
    for i = 1, #self.payMethodsList do
        self:insertToScrollviewChannel(i)
    end
    self:channel_scrollToIndex(self.channel_itemSelected)
end

-- 插入Item到scrollviewChannel
function Bankruptcy:insertToScrollviewChannel( index )
    local _item = self._item:clone()
    _item:setVisible(true)
    _item:setPosition(index*(-250), 0)
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
function Bankruptcy:channel_scrollToIndex( index )
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
    self.channel_itemSelected = index
end

function Bankruptcy:EnterActionDone()
    qf.event:dispatchEvent(ET.NET_COLLAPSE_PAY_REQ)
end

function Bankruptcy:startRemoveAction()

end
--[[--
optional int32 fetch_count=1; // 已经领取的次数
optional int64 last_fetch_time=2;// timestamp
optional int64 next_fetch_time=3; // timestamp
optional int32 remain=4; // seconds
optional int32 fetch_limit =5;
optional int32 is_all_send=6; //是否已经送光
optional int64 send_gold=7; //每次送多少钱
]]
function Bankruptcy:refreshBankruptcyInfo(paras)
    self:setVisible(true)
    
    local gold = paras.send_gold..""
    self.get_num_txt:setString("领"..gold.."金币")
    local num = #gold
    
    self.is_all_send = paras.is_all_send 
    if self.is_all_send ~= 1 then
        self.remain = paras.remain 
        self:updateRemainTime()
    else
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=string.format(GameTxt.global_string114,Cache.Config.bankrupt_count)})
    end
end

function Bankruptcy:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end

function Bankruptcy:updateRemainTime()
    local function _refreshTime()
        self.remain = self.remain - 1
        if self.remain <= 0 and self.action then
            self.get_btn:setEnabled(true)
            self.get_btn:setColor(Theme.Color.LIGHT)
            self:stopAction(self.action)
        end
    end
    self.action = schedule(self, _refreshTime, 1)
end

function Bankruptcy:close()
    if self.cb then
        self.cb()
        self.cb=nil
    end
    Bankruptcy.super.close(self)
end

return Bankruptcy