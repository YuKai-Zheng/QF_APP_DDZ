--[[
-- 带滑竿的补充筹码
--]]
local M = class("SupplySliderView", function( args )
	return args.node
end)

function M:ctor( args )
	self.selectedPercent = 0

	self:initUI()
	self:initClick()
end

function M:initUI( ... )
	self.lblCurGold = self:getChildByName("lbl_cur_gold")
	self.lblExchangeGold = self:getChildByName("lbl_exchange_gold")
	self.lblMinCarry = self:getChildByName("lbl_min_carry")
	self.lblMaxCarry = self:getChildByName("lbl_max_carry")

	local panAuto = self:getChildByName("pan_auto_exchange")
	self.cboxAuto = panAuto:getChildByName("cbox_auto")

	self.btnSure = self:getChildByName("btn_sure")

	self.sliderExchange = self:getChildByName("slider_exchange")
end

function M:initClick( ... )
	addButtonEvent(self.btnSure, function( sender )
		local bookmark = self:getJumpBookmark()
		
		local actionTag = 1
		if self.cboxAuto:getSelectedState() then -- 选择中下次兑换 最大筹码
			self.percentGold = self.percentMax
			actionTag = 2
		end

		if bookmark then
			qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=GameTxt.string_shop_tip_4, time=1})
			self:delayRun(1.0, function( ... )
				self:_statUserAction(bookmark)
				qf.event:dispatchEvent(ET.EVENT_GAMESHOP_JUMP_TO_BOOKMARK, {bookmark=bookmark})
			end)
		else
			if self.index then
				qf.event:dispatchEvent(ET.GAME_USER_RETURN_INDEX,{index=self.index, chips=self.percentGold})
			else
				qf.event:dispatchEvent(ET.NET_EXCAHNGE_CHIPS_REQ,{exchange_chips=self.percentGold, action=actionTag})
			end

			qf.event:dispatchEvent(ET.GAME_HIDE_SHOP)
		end
	end)

    self.sliderExchange:addEventListener(function( sender, eventType )    
    	if eventType == ccui.SliderEventType.percentChanged then
	        self.selectedPercent = sender:getPercent()
	        if self.selectedPercent > self.percentLimit then
	            self.selectedPercent = self.percentLimit
	            sender:setPercent(self.percentLimit)
	        end
	        self:updateExchangeNumber()
	    end
	end)
end

function M:initWithData( args )
    self.ref = args.ref or UserActionPos.ROOM_SHOP_CAR --默认房间内购物车
    self.payType = args.payType or 0
    self.index = args.index
    self.selectdBookmark = args.type or PAY_CONST.BOOKMARK_ROOM.SUPPLY

    self:updateBaseData()

   	self:_updateMyUI()
end

function M:updateExchangeNumber( ... )
    self.percentGold = self.selectedPercent*(self.percentMax - self.percentMin)/100 + self.percentMin

    self.lblExchangeGold:setString(self.percentGold)
end

function M:_updateMyUI( ... )
	self.lblCurGold:setString(string.format(GameTxt.string675, tostring(Cache.user.gold)))
	self.lblMinCarry:setString(string.format(GameTxt.string673, Util:getFormatString(self.percentMin)))
	self.lblMaxCarry:setString(string.format(GameTxt.string674, Util:getFormatString(self.percentMax)))

    self.sliderExchange:setPercent(self.selectedPercent)

    self:updateExchangeNumber()
end

function M:setSelectedState( selected )
	self.cboxAuto:setSelectedState(selected)
end

-- 得到跳转的标签
function M:getJumpBookmark( ... )
	local all = checkint(self.allChip)
	local gold = checkint(self.percentGold)
	if all >= gold then return nil end -- 可以补充

	local bookmark = Util:getGameShopBookmarkByGold(self.percentMin)

	return bookmark
end

function M:updateBaseData( ... )
	local carryLimit = Cache.desk:getRoomCarryLimit()
    local gold = Cache.user.gold

    local userData = Cache.desk:getUserByUin(Cache.user.uin)
    self.myChips = userData and userData.chips or 0
    self.allChip = gold + self.myChips
    
    self.percentMax = carryLimit
    self.percentMin = Cache.desk:getRoomCarryMin()
    self.percentGold = self.allChip < carryLimit and self.allChip or carryLimit

    if self.allChip <= self.percentMin then
        self.percentLimit = 0
    elseif self.allChip > self.percentMin and self.allChip < self.percentMax then
        self.percentLimit = 100*(self.allChip - self.percentMin)/(self.percentMax - self.percentMin)
    else
        self.percentLimit = 100
    end

    self.selectedPercent = self.percentLimit
end

-- 更新金币数量
function M:updateGoldNumber( ... )
	self:updateBaseData()

	self:_updateMyUI()
end

-- 延迟1s跳转时进行用户行为统计
-- 根据跳转后的页面进行上报
function M:_statUserAction( bookmark )
    local currency
    if bookmark == PAY_CONST.BOOKMARK_ROOM.GOLD then
    	currency = PAY_CONST.CURRENCY_GOLD
    elseif bookmark == PAY_CONST.BOOKMARK_ROOM.DIAMOND then
    	currency = PAY_CONST.CURRENCY_DIAMOND
    else
    	return 
    end
    
    -- 数据上报
    qf.event:dispatchEvent(ET.USER_ACTION_STATS_EVT, {
        ref = self.ref,
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