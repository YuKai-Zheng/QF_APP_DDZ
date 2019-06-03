--[[
-- 物品Item
--]]
local M = class("CommonItem", function( args )
	return args.node
end)

local ShopToolDetailView = import(".ShopToolDetailView.lua")

function M:ctor( args )
	self._bookmark = args.bookmark or PAY_CONST.BOOKMARK.GOLD
	self:initUI()
	self:initClick()
	self.ref = args.ref
end

function M:initUI( ... )
	self.imgItemBg = self:getChildByName("img_item_bg")
	-- 商品icon
	self.imgItemIcon = self.imgItemBg:getChildByName("img_item_icon")
    self.posImgItemIcon = cc.p(self.imgItemIcon:getPosition())
    
    self.item_name = self:getChildByName("item_name")   --道具商品名

	-- 标签
	self.imgLabel = self:getChildByName("img_label")

	self:initGoldUI()
	-- 购买按钮
	self.btnBuy = self:getChildByName("buy")
    self:initBtnUI()

	self:resetUI()
end
function M:initGoldUI( ... )
	self.goldItems = {}
	local lblGold = self:getChildByName("item_num")
	self.goldItems.lblGold = lblGold
end

function M:initBtnUI( ... )
	self.btnItems = {}
	
	local lblDiamondPrice = self:getChildByName("price_lb")

	self.btnItems.lblDiamondPrice = lblDiamondPrice
	self.btnItems.lblDiamondPrice.x=lblDiamondPrice:getPositionX()
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
		self:_buyGoldByRmb()
	elseif self._bookmark == PAY_CONST.BOOKMARK.DIAMOND then -- 购买钻石
		self:_buyByRmb()
	elseif self._bookmark == PAY_CONST.BOOKMARK.PROPS then -- 购买道具
		if self.data.currency == PAY_CONST.ITEM_CURRENCY_TYPE_GOLD then -- 使用金币
			self:_buyByGold()
		end
	end
end
-- 使用钻石买
function M:_buyByDiamond( ... )
	if not self:_isLackDiamond(self.data.price) then
		local function _callBack( ... )
			local cb = function ( success )--主要为礼物卡购买后刷新数据
				if success then
					qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{uin=Cache.user.uin})
				end
			end
    		qf.event:dispatchEvent(ET.NET_PRODUCT_EXCHANGE_BY_DIAMOND, {item_name=self.data.item_name, cb=cb})  
		end
		local ret = {}
		ret.sureCb = _callBack

		local content
		if self._bookmark == PAY_CONST.BOOKMARK.GOLD then
			content = GameTxt.string_shop_buy_gold_use_diamond
			local name = GameTxt["string_car_name_"..self.data.level]
			content = string.format(content, self.data.price, name, Util:getFormatString(self.data.amount))
		elseif self._bookmark == PAY_CONST.BOOKMARK.PROPS then
			content = GameTxt.string_shop_buy_props_use_diamond
			local name = self.data.display_name
			local num=""
			if self.data.other_props.buy_num then 
				num=string.format(GameTxt.string_shop_item_txt7,""..self.data.other_props.buy_num)
			end
			content = string.format(content, self.data.price, name..num)

			ret.title = GameRes.shop_title_buy_props
		end
		ret.content = content
		qf.event:dispatchEvent(ET.EVENT_SHOW_BUY_POPUP_TIP_VIEW, ret)
	end
end
-- 使用金币买
function M:_buyByGold( ... )
    if not self:_isLackGold(self.data.price) then
		qf.event:dispatchEvent(ET.NET_PRODUCT_EXCHANGE_BY_DIAMOND, {item_name=self.data.name, currency = self.data.currency, title = self.data.title})
	end
end

function M:_buyGoldByRmb( ... )
	local methods = Cache.QuickPay:getPayMethodsByGoldItemName(self.data.item_name)
	
	loge("#item_name  "..self.data.item_name)
	loge("#methods  "..#methods)
	if 1 >= #methods then -- 只有一种支付方式
		local payInfo = Cache.PayManager:getPayInfoByItemNameAndMethod(self.data.item_name, methods[1])

		payInfo.ref = self.ref or UserActionPos.SHOP_REF
		if self.ref == UserActionPos.SHOP_REF then
			qf.platform:umengStatistics({umeng_key = "PayOnShop",umeng_value=self.data.item_name})--点击上报
		end
		qf.event:dispatchEvent(ET.GAME_PAY_NOTICE, payInfo)
	else
		local ret = {}
		ret.data = self.data
		ret.method = methods
		ret.ref = self.ref or UserActionPos.SHOP_REF
		
		qf.event:dispatchEvent(ET.EVENT_SHOW_PAY_METHOD_VIEW, ret)
	end
end

-- 使用人民币买
function M:_buyByRmb( ... )
	local methods = Cache.QuickPay:getPayMethodsByDiamondNum(self.data.diamond)

	if 1 >= #methods then -- 只有一种支付方式
		local payInfo = Cache.PayManager:getPayInfoByDiamondAndPaymethod(self.data.diamond, methods[1])

		payInfo.ref = self.ref or UserActionPos.SHOP_REF
		if self.ref == UserActionPos.SHOP_REF then
			qf.platform:umengStatistics({umeng_key = "PayOnShop",umeng_value=self.data.item_name})--点击上报
		end
		qf.event:dispatchEvent(ET.GAME_PAY_NOTICE, payInfo)
	else
		local ret = {}
		ret.data = self.data
		ret.method = methods
		ret.ref = self.ref or UserActionPos.SHOP_REF

		qf.event:dispatchEvent(ET.EVENT_SHOW_PAY_METHOD_VIEW, ret)
	end
end
-- 判断钻石是否足够
function M:_isLackDiamond( num )
	if num > Cache.user.diamond then -- 砖石不足
		qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=GameTxt.string_shop_tip_6, time=2})
		self:delayRun(0.5, function( ... )
			self:_statUserAction(PAY_CONST.BOOKMARK.DIAMOND)
			qf.event:dispatchEvent(ET.EVENT_SHOP_JUMP_TO_BOOKMARK, {bookmark=PAY_CONST.BOOKMARK.DIAMOND})
		end)
		return true
	end

	return false
end
-- 判断金币是否足够
function M:_isLackGold( num )
	if num > Cache.user.gold then -- 金币不足
		qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=GameTxt.string_shop_tip_7, time=2})
		self:delayRun(0.5, function( ... )
			local bookmark = PAY_CONST.BOOKMARK.GOLD
			self:_statUserAction(bookmark)
			qf.event:dispatchEvent(ET.EVENT_SHOP_JUMP_TO_BOOKMARK, {bookmark=bookmark})
		end)
		return true
	end

	return false
end
-- 获取金卡或银卡详情描述
function M:_getWeekOrMonthDetail( props )
	local desc1 = GameTxt.right_now_get..props.gold_immediate..GameTxt.gold_unit
	local desc2 = GameTxt.every_day_get..props.gold_everyday..GameTxt.gold_unit
	desc2 = desc2.."("..props.day_num..GameTxt.day_desc..")"

	return desc1, desc2
end

function M:setIndex( index )
	self._index = index
end

function M:resetUI( ... )
	self.imgLabel:setVisible(false)
end

function M:updateWithData( bookmark, args )
	self._bookmark = bookmark
	self.data = args
	self:resetUI()

	if self._bookmark == PAY_CONST.BOOKMARK.GOLD then
		addButtonEvent(self.imgItemBg, function( sender )
			self:buy()
	    end)
		self:_updateBuyGold()
	elseif self._bookmark == PAY_CONST.BOOKMARK.DIAMOND then
		addButtonEvent(self.imgItemBg, function( sender )
			self:buy()
	    end)
		self:_updateBuyDiamond()
	elseif self._bookmark == PAY_CONST.BOOKMARK.PROPS then
		addButtonEvent(self.imgItemBg, function( sender )--道具点击背景是显示详情 小喇叭除外
            PopupManager:push({class = ShopToolDetailView, init_data = {data = self.data, cb = function()
                self:buy()
            end}})
            PopupManager:pop()
	    end)
		self:_updateBuyProps()
	end
end

-- 更新购买道具
function M:_updateBuyProps(  )
    --self.imgItemBg:setTouchEnabled(false)
    self.imgItemIcon:ignoreContentAdaptWithSize(false)
    self.imgItemIcon:setScale(0.85)
    self.imgItemIcon:setContentSize(cc.size(200, 200))
    self.imgItemIcon:loadTexture(GameRes.tool_icon_loadding)
    
    self:_updateBtnUI(2, self.data.price)

    self.goldItems.lblGold:setVisible(false)
    self.item_name:setVisible(true)
    self.item_name:setString(self.data.title)

    local extraImg = self:getChildByName("extra")
    extraImg:setVisible(false)
    self:getChildByName("img_tuiguang"):setVisible(false)

    if self.data.pic_path and self.data.pic_path ~= "" then
        local taskID = qf.downloader:execute(self.data.pic_path, 10,
	        	function(path)
		            if isValid( self.imgItemIcon ) then
		                self.imgItemIcon:loadTexture(path)
		            end
		        end,
		        function()
		        end,
		        function()
		        end
            )
    else
        local imgPath = GameRes.rememberCardImg

        if self.data.name == "super_multi_card" then
            imgPath = GameRes.super_multi_card
        end

        self.imgItemIcon:loadTexture(imgPath)
    end
end

-- 更新购买金币
function M:_updateBuyGold( ... )
    self.imgItemBg:setTouchEnabled(true)
    self.imgItemIcon:ignoreContentAdaptWithSize(true)
	self.imgItemIcon:loadTexture(string.format(GameRes.shop_gold, self.data.level -1))
	self.imgItemIcon:setScale(0.85)
	self.imgItemIcon:setPositionY(self.posImgItemIcon.y)

	self:_updateBtnUI(1, self.data.price)

	local lblGold = self.goldItems.lblGold
    local lblCount = self.data.amount

    --self.goldItems.lblGold:setFntFile(GameRes.gold_title_fnt)
    lblGold:setVisible(true)
    self.item_name:setVisible(false)
	lblGold:setString(Util:getFormatString(lblCount, 2))

	local extraImg = self:getChildByName("extra")
	if self.data.add_count == 0 then
		extraImg:setVisible(false)
	else
		extraImg:setVisible(true)
		local num = string.format(GameTxt.shopExtraTxt, Util:getFormatString(self.data.add_count, 2))
		extraImg:getChildByName("num"):setString(num)
	end

	self:_updateLabel(self.data.label)
	if Cache.Config.ddz_match_promoter_itemrid == self.data.item_name then
		self:getChildByName("img_tuiguang"):setVisible(true)
	end

	if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW or not Cache.Config.promoter_support then
	 	self:getChildByName("img_tuiguang"):setVisible(false)
	end 
end

-- 更新购买钻石
function M:_updateBuyDiamond( ... )
	self.panBuyDiamond:setVisible(false)

	local unitPrice =string.format("%0.1f", (self.data.diamond/self.data.cost))
	local unitPrice2 = string.gsub(unitPrice, "%.0", "") 
		self.diamondItems.bgDiamond:setString(string.format(GameTxt.string_addmore_to_diamond, unitPrice2))
	self.imgItemIcon:loadTexture(string.format(GameRes.shop_diamond, self.data.level))
	self.imgItemIcon:setPositionY(self.posImgItemIcon.y -10)
	local lblDiamond = self.diamondItems.lblDiamond
	lblDiamond:setString(self.data.diamond)

	local sizeDiamond = lblDiamond:getContentSize()
	local posx, posy = lblDiamond:getPosition()
	self.diamondItems.imgDiamond:setPositionX(posx + sizeDiamond.width*0.5)

	if self.data.diamond>1000 then
		self.diamondItems.lblDiamond:setPositionX(lblDiamond.x + sizeDiamond.width*0.05)
		self.diamondItems.imgDiamond:setPositionX(lblDiamond.x + sizeDiamond.width*0.55)
	end
	self:_updateBtnUI(3, self.data.cost)
	
	self:_updateLabel(self.data.hot)
end

-- 更新标签：热销、推荐
function M:_updateLabel( label )
	if not true then return end
	if label == PAY_CONST.ITEM_LABEL_TYPE_RECOMMEND then -- 推荐
		self.imgLabel:loadTexture(GameRes.shop_sell_img1)
		self.imgLabel:setVisible(true)
	elseif label == PAY_CONST.ITEM_LABEL_TYPE_HOT then -- 热销
		self.imgLabel:loadTexture(GameRes.shop_sell_img2)
		self.imgLabel:setVisible(true)
	else
		self.imgLabel:setVisible(false)
	end
end
function M:_updateBtnUI( kind, num )
	if 1 == kind then -- rmb
		local lblDiamondPrice = self.btnItems.lblDiamondPrice
		lblDiamondPrice:setString("￥"..num)
		local sizeDiamond = lblDiamondPrice:getContentSize()
		-- local posx, posy = lblDiamondPrice:getPosition()
		if num>=10000 then
			self.btnItems.imgDiamondIcon:setPositionX(lblDiamondPrice.x - sizeDiamond.width*0.2)
			self.btnItems.lblDiamondPrice:setPositionX(lblDiamondPrice.x - sizeDiamond.width*0.2)
		end
    else
        local lblDiamondPrice = self.btnItems.lblDiamondPrice
        local value, unit = Util:getFormatUnit(num)
        local txt = unit == 1 and "万金币" or "金币"
        lblDiamondPrice:setString(value .. txt)
        
		local sizeDiamond = lblDiamondPrice:getContentSize()
		if num>=10000 then
			--self.btnItems.imgDiamondIcon:setPositionX(lblDiamondPrice.x - sizeDiamond.width*0.2)
			--self.btnItems.lblDiamondPrice:setPositionX(lblDiamondPrice.x - sizeDiamond.width*0.2)
		end
	end
end

-- 延迟1s跳转时进行用户行为统计
function M:_statUserAction( bookmark )
	local currency
	if bookmark == PAY_CONST.BOOKMARK.GOLD then
		currency = PAY_CONST.CURRENCY_GOLD
	elseif bookmark == PAY_CONST.BOOKMARK.DIAMOND then
		currency = PAY_CONST.CURRENCY_DIAMOND
	else
		return 
	end
	-- 数据上报
    qf.event:dispatchEvent(ET.USER_ACTION_STATS_EVT, {
        ref = UserActionPos.SHOP_REF,
        currency = currency
    })
end

function M:delayRun( dt, cb )
	self:runAction(cc.Sequence:create(cc.DelayTime:create(dt)
		, cc.CallFunc:create(function( ... )
			cb()
		end)))
end

return M