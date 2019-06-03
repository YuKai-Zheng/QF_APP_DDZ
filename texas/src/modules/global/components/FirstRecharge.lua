local FirstRecharge   = class("FirstRecharge",CommonWidget.BasicWindow)
FirstRecharge.TAG = "FirstRecharge"

function FirstRecharge:ctor(paras)
    FirstRecharge.super.ctor(self, paras)
	if paras and paras.cb then self.cb = paras.cb end

	if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
    end
end

function FirstRecharge:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.firstRechargeJson)
	self.bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
	self.backBtn = ccui.Helper:seekWidgetByName(self.gui,"btn_close")
    self.reward_btn = ccui.Helper:seekWidgetByName(self.gui,"btn_buy")
	local rechargeGift_list = Cache.user.firstChargeConfInfo.reward_gift or {}
	for i=1,#rechargeGift_list do
        local itemData = rechargeGift_list[i]
		local rewardItemStr = string.format("item_%d", i)
        local itemReward = ccui.Helper:seekWidgetByName(self.gui,rewardItemStr)
        if itemReward then
            local reward_title = itemReward:getChildByName("name")
            local num = itemReward:getChildByName("num")
            reward_title:setString(itemData.name)
            num:setString("x" .. itemData.num)
            self:setHeadByUrl(itemReward:getChildByName("img"),itemData.icon_path)
        end
    end
end

function FirstRecharge:initClick()
	addButtonEvent(self.backBtn,function ()
		self:close()
	end)

	addButtonEvent(self.reward_btn,function ()
		self:payAction()
	end)
end

function FirstRecharge:payAction()
    local payData = Cache.PayManager:getDisplayItemInfoByItemId(Cache.user.firstChargeConfInfo.item_id)

	if not payData then return end
	local methods = Cache.QuickPay:getPayMethodsByGoldItemName(payData.item_name)
	if 1 >= #methods then -- 只有一种支付方式
		local payInfo = Cache.PayManager:getPayInfoByItemNameAndMethod(payData.item_name, methods[1])
		payInfo.ref = self.ref or UserActionPos.SHOP_REF
		if self.ref == UserActionPos.SHOP_REF then
			qf.platform:umengStatistics({umeng_key = "PayOnShop",umeng_value=payData.item_name})--点击上报
		end
		qf.event:dispatchEvent(ET.GAME_PAY_NOTICE, payInfo)
	else
		local ret = {}
		ret.data = payData
		ret.method = methods
		ret.ref = self.ref or UserActionPos.SHOP_REF
		qf.event:dispatchEvent(ET.EVENT_SHOW_PAY_METHOD_VIEW, ret)
	end
end

--[[下载图片]]
function FirstRecharge:setHeadByUrl(view,url)
    if view == nil or url == nil then return end
    local kImgUrl = url
    local reg = qf.platform:getRegInfo()
    local taskID = qf.downloader:execute(kImgUrl, 10,
        function(path)
			if not tolua.isnull( self ) then
				view:loadTexture(path)
				view:setVisible(true)
            end
        end,
        function()
        end,
        function()
        end)
end

function FirstRecharge:close()
    FirstRecharge.super.close(self)
    if self.cb then
        self.cb()
    end
end

return FirstRecharge