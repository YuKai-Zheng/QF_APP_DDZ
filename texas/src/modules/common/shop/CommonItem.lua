--[[
-- 物品Item
--]]
local M = class("CommonItem", function( args )
	return args.node
end)

function M:ctor( args )
	self._bookmark = args.bookmark or PAY_CONST.BOOKMARK_ROOM.GOLD

	self:initUI()
	self:initClick()
end

function M:initUI( ... )
	self.imgItemBg = self:getChildByName("img_item_bg")
	-- 商品icon
	self.imgItemIcon = self:getChildByName("img_icon")
	self.posImgItemIcon = cc.p(self.imgItemIcon:getPosition())

	-- 买金币特有控件
	self.panBuyGold = self:getChildByName("pan_gold")
	self:initGoldUI()

	-- 买钻石特有控件
	self.panBuyDiamond = self:getChildByName("pan_diamond")
	self:initDiamondUI()

	-- 购买按钮
	self.btnBuy = self:getChildByName("btn_buy")
	self:initBtnUI()

	self:resetUI()
end
function M:initDiamondUI( ... )
	self.diamondItems = {}
	local lblDiamond = self.panBuyDiamond:getChildByName("lbl_diamond")
	local imgDiamond = self.panBuyDiamond:getChildByName("img_diamond")

	self.diamondItems.lblDiamond = lblDiamond
	self.diamondItems.imgDiamond = imgDiamond
end
function M:initGoldUI( ... )
	self.goldItems = {}
	local lblGold = self.panBuyGold:getChildByName("lbl_gold")
	local imgGive = self.panBuyGold:getChildByName("img_give")
	local lblName = self.panBuyGold:getChildByName("lbl_good_name")

	self.goldItems.lblGold = lblGold
	self.goldItems.imgGive = imgGive
	self.goldItems.lblName = lblName
end

function M:initBtnUI( ... )
	self.btnItems = {}
	-- 使用RMB购买
	self.panBuyMethodRmb = self.btnBuy:getChildByName("pan_buy_diamond")
	local lblRmbPrice = self.panBuyMethodRmb:getChildByName("lbl_price")
	local imgUnit = self.panBuyMethodRmb:getChildByName("img_unit")

	self.btnItems.lblRmbPrice = lblRmbPrice
	self.btnItems.imgUnit = imgUnit

	-- 使用砖石购买
	self.panBuyMethodDiamond = self.btnBuy:getChildByName("pan_buy_gold")
	local lblDiamondPrice = self.panBuyMethodDiamond:getChildByName("lbl_price")
	local imgDiamondIcon = self.panBuyMethodDiamond:getChildByName("img_icon")

	self.btnItems.lblDiamondPrice = lblDiamondPrice
	self.btnItems.imgDiamondIcon = imgDiamondIcon

	self.btnItems.posLblRmbPrice = cc.p(lblRmbPrice:getPosition())
end

function M:initClick( ... )
	addButtonEvent(self.imgItemBg, function( sender )
		self:buy()
	end)
	addButtonEvent(self.btnBuy, function( sender )
		self:buy()
	end)
end
-- 购买
function M:buy( ... )
	if self._bookmark == PAY_CONST.BOOKMARK.GOLD then -- 购买金币
		self:_buyByDiamond()
	elseif self._bookmark == PAY_CONST.BOOKMARK.DIAMOND then -- 购买钻石
		self:_buyByRmb()
	end
end
-- 使用钻石买
function M:_buyByDiamond( ... )
	if not self:_isLackDiamond(self.data.price) then
		local function _callBack( ... )
    		qf.event:dispatchEvent(ET.NET_PRODUCT_EXCHANGE_BY_DIAMOND, {item_name=self.data.item_name})  
		end
		local ret = {}
		ret.sureCb = _callBack

		local content = GameTxt.string_shop_buy_gold_use_diamond
		local name = GameTxt["string_car_name_"..self.data.level]
		content = string.format(content, self.data.price, name, Util:getFormatString(self.data.amount))

		ret.content = content
		qf.event:dispatchEvent(ET.EVENT_SHOW_BUY_POPUP_TIP_VIEW, ret)
	end
end

-- 使用人民币买
function M:_buyByRmb( ... )
	local methods = Cache.QuickPay:getPayMethodsByDiamondNum(self.data.diamond)

	if 1 >= #methods then -- 只有一种支付方式
		local payInfo = Cache.PayManager:getPayInfoByDiamondAndPaymethod(self.data.diamond, methods[1])

		payInfo.ref = self.ref
		payInfo.payType = self.payType

		qf.event:dispatchEvent(ET.GAME_PAY_NOTICE, payInfo)
	else
		local ret = {}
		ret.data = self.data
		ret.method = methods
		ret.ref = self.ref
		ret.payType = self.payType

		qf.event:dispatchEvent(ET.EVENT_SHOW_PAY_METHOD_VIEW, ret)
	end
end
-- 判断钻石是否足够
function M:_isLackDiamond( num )
	if num > Cache.user.diamond then -- 砖石不足
		qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=GameTxt.string_shop_tip_6, time=2})
		self:_statUserAction()
		qf.event:dispatchEvent(ET.EVENT_GAMESHOP_JUMP_TO_BOOKMARK, {bookmark=PAY_CONST.BOOKMARK_ROOM.DIAMOND, gold=self.data.amount})
		
		-- local function _callBack( ... )
		-- 	self:_statUserAction()
		-- 	qf.event:dispatchEvent(ET.EVENT_GAMESHOP_JUMP_TO_BOOKMARK, {bookmark=PAY_CONST.BOOKMARK_ROOM.DIAMOND, gold=self.data.amount})
		-- end
		-- local data = {sureCb = _callBack
		-- 	, content = GameTxt.string_shop_tip_3
		-- 	, title = GameRes.shop_title_tip
		-- }
		-- qf.event:dispatchEvent(ET.EVENT_SHOW_BUY_POPUP_TIP_VIEW, data)
		return true
	end

	return false
end

function M:setIndex( index )
	self._index = index
end

function M:resetUI( ... )
	self.panBuyGold:setVisible(false)
	self.panBuyDiamond:setVisible(false)
	self.panBuyMethodRmb:setVisible(false)
	self.panBuyMethodDiamond:setVisible(false)
end

function M:updateWithData( bookmark, args )
	self._bookmark = bookmark
	self.data = args.data
	self.ref = args.ref
	self.payType = args.payType

	self:resetUI()

	if self._bookmark == PAY_CONST.BOOKMARK_ROOM.GOLD then
		self:_updateBuyGold()
	elseif self._bookmark == PAY_CONST.BOOKMARK_ROOM.DIAMOND then
		self:_updateBuyDiamond()
	end
end

-- 更新购买金币
function M:_updateBuyGold( ... )
	self.panBuyGold:setVisible(true)

	self.goldItems.lblName:setString(GameTxt["string_car_name_"..self.data.level])
	self.imgItemIcon:loadTexture(GameRes["gift_icon_200"..(self.data.level - 1)])
	self.imgItemIcon:setPositionY(self.posImgItemIcon.y)

	self:_updateBtnUI(1, self.data.price)

	local lblGold = self.goldItems.lblGold
	lblGold:setString(Util:matchStr(self.data.amount, "，"))
end

-- 更新购买钻石
function M:_updateBuyDiamond( ... )
	self.panBuyDiamond:setVisible(true)

	self.imgItemIcon:loadTexture(string.format(GameRes.shop_diamond, self.data.level))
	self.imgItemIcon:setPositionY(self.posImgItemIcon.y - 30)

	local lblDiamond = self.diamondItems.lblDiamond
	lblDiamond:setString(self.data.diamond..'钻石')

	local sizeDiamond = lblDiamond:getContentSize()
	local posx, posy = lblDiamond:getPosition()
	self.diamondItems.imgDiamond:setPositionX(posx + sizeDiamond.width*0.5)

	self:_updateBtnUI(3, self.data.cost)
end

function M:_updateBtnUI( kind, num )
	if 1 == kind then -- 使用砖石
		self.panBuyMethodDiamond:setVisible(true)
		local lblDiamondPrice = self.btnItems.lblDiamondPrice
		lblDiamondPrice:setString('z'..num)
		local sizeDiamond = lblDiamondPrice:getContentSize()
		local posx, posy = lblDiamondPrice:getPosition()
		self.btnItems.imgDiamondIcon:setPositionX(posx - sizeDiamond.width*0.5 - 10)
		-- self.btnItems.imgDiamondIcon:setVisible(false)
	else
		self.panBuyMethodRmb:setVisible(true)
		local lblRmbPrice = self.btnItems.lblRmbPrice
		local value, unit = Util:getFormatUnit(num)
		self.btnItems.imgUnit:setString('r'..value)
		local sizePrice = lblRmbPrice:getContentSize()

		local posx, posy = lblRmbPrice:getPosition()

		self.btnItems.imgUnit:setPositionX(posx - sizePrice.width*0.5)
		loga(GameRes.shop_white_rmb_unit)
		-- self.btnItems.imgUnit:loadTexture(GameRes.shop_white_rmb_unit)
	end
end

-- 延迟1s跳转时进行用户行为统计
-- 此时一定是跳转到购买钻石页
function M:_statUserAction( ... )
    local currency = PAY_CONST.CURRENCY_DIAMOND
    -- 数据上报
    qf.event:dispatchEvent(ET.USER_ACTION_STATS_EVT, {
        ref = self.ref,
        currency = currency
    })
end

return M