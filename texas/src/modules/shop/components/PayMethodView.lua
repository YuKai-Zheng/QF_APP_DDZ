
--[[
-- 支付方式框
--]]
local M = class("PayMethodView", CommonWidget.BasicWindow)

function M:ctor( args )
    self.winSize = cc.Director:getInstance():getWinSize() 
    M.super.ctor(self, args)

    if FULLSCREENADAPTIVE then
    	self.gui:getChildByName("bg"):setContentSize(self.winSize.width, self.winSize.height)
    end
end

function M:initUI( ... )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.shopPayMethodJson)
	local panRoot = self.gui:getChildByName("pan_root")
	self.btnExit = panRoot:getChildByName("btn_exit")
	self.scrollview = panRoot:getChildByName("scrollview_method")
	self.itemDefault = self.gui:getChildByName("item")
	self.itemDefault:setVisible(false)
	self.applePayBtn = panRoot:getChildByName("appleBtn")
	self.applePayBtn:setVisible(false)

	self.itemSize = self.itemDefault:getContentSize()
	self.viewSize = self.scrollview:getContentSize()
	self.ITEM_HEIGHT = self.itemSize.height
	self.ITEM_WIDTH = self.itemSize.width

	for i = 1, self.itemNum do
		self:insertItem(i)
	end
	self:adjustLayout()
end

function M:insertItem( index )
	local method = self.payMethods[index]
	local res 
	if method == PAYMETHOD_APPSTORE then
		res = GameRes.shop_channel_app
		self.applePayBtn:setVisible(true)
		return
	elseif method == PAYMETHOD_ZHIFUBAO then
		res = GameRes.shop_channel_zhifubao
	elseif method == PAYMETHOD_WINXIN then
		res = GameRes.shop_channel_weixin
	else
		return 
	end

	local item = self.itemDefault:clone()
	item._method = method
	item:setVisible(true)
	local btn = item:getChildByName("btn_pay_method")
	btn._method = method
	btn:loadTextureNormal(res)
	addButtonEvent(btn, function( sender )
		self:_pay(sender._method)
	end)
	table.insert(self.items, item)
	self.scrollview:addChild(item)
end

function M:init( args )
	self.payMethods = args.method
	self.data = args.data
	self.ref = args.ref
	self.payType = args.payType
	self.itemNum = #self.payMethods
	self.items = {}
end

function M:initClick( ... )
    addButtonEvent(self.btnExit, function( sender )
		self:close()
	end)

	addButtonEvent(self.applePayBtn, function (sender)
		self:_pay(PAYMETHOD_APPSTORE)
	end)
end

-- 根据编号获取item位置
function M:getPositionByIndex( index )
	local x, y = 0, self.containerSize.height - self.ITEM_HEIGHT

	local row = math.floor((index - 1)/2)
	local column = (index - 1)%2
	local margin = (self.containerSize.width - 2*self.ITEM_WIDTH)/3
	x = x + (column +1)*margin + column*self.ITEM_WIDTH
	y = y - row*self.ITEM_HEIGHT

	if #self.items == 1 then
		x = self.containerSize.height/2 - self.ITEM_WIDTH/2
	end

	return cc.p(x, y)
end
-- 调整布局
function M:adjustLayout( ... )
	local row = math.ceil(self.itemNum/2)
	local height = row*self.ITEM_HEIGHT
	height = height > self.viewSize.height and height or self.viewSize.height

	self.containerSize = cc.size(self.viewSize.width, height)
	self.scrollview:setInnerContainerSize(self.containerSize)

	for i = 1, self.itemNum do
		if self.items[i] then
			self.items[i]:setPosition(self:getPositionByIndex(i))
		end
	end
end

-- 支付
function M:_pay( method )
	local payInfo 
	if self.ref == UserActionPos.TIPSPAY_REF then
		payInfo= Cache.PayManager:getPayInfoByGoldAndPaymethod(self.data.diamond, method)
	else
		payInfo= Cache.PayManager:getPayInfoByItemNameAndMethod(self.data.item_name, method)
	end
	payInfo.ref = self.ref
	payInfo.payType = self.payType
	if self.ref == UserActionPos.SHOP_REF then
		qf.platform:umengStatistics({umeng_key = "PayOnShop",umeng_value=self.data.item_name})--点击上报
	end
	qf.event:dispatchEvent(ET.GAME_PAY_NOTICE, payInfo)

	self:close()
end

function M:show()
    M.super.show(self)
end

return M


