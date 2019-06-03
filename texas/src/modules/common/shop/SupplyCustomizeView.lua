--[[
-- 输入框输入筹码数
--]]
local SupplySliderView = import(".SupplySliderView")
local M = class("SupplyCustomizeView", SupplySliderView)

function M:ctor( args )
	M.super.ctor(self)
end

function M:initUI( ... )
	self.lblCurGold = self:getChildByName("lbl_cur_gold")
	self.lblMinCarry = self:getChildByName("lbl_min_carry")
	self.lblMaxCarry = self:getChildByName("lbl_max_carry")
	self.lblExchangeFee = self:getChildByName("lbl_exchange_fee")
	self.lblExchangeFeeTip = self:getChildByName("lbl_exchange_fee_tip")

	self.cboxMinCarry = self:getChildByName("cbox_min_carry")
	self.cboxMaxCarry = self:getChildByName("cbox_max_carry")
	self.lblInputTxt = self:getChildByName("lbl_input_txt")
	self.imgInputBg = self:getChildByName("img_edit_bg")

	self.btnSure = self:getChildByName("btn_sure")

	self:initEditBox()
end

function M:initClick( ... )
	self.cboxMinCarry:addEventListener(function( sender, eventType )
		if eventType == ccui.CheckBoxEventType.selected then
			self:selectedCbox(1)
		else
			self:selectedCbox()
		end
	end)
	self.cboxMaxCarry:addEventListener(function( sender, eventType )
		if eventType == ccui.CheckBoxEventType.selected then
			self:selectedCbox(2)
		else
			self:selectedCbox()
		end
	end)

	addButtonEvent(self.btnSure, function( sender )
        if not self:checkInputIsValid() then return end

		local bookmark = self:getJumpBookmark()
		if bookmark then
			qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=GameTxt.string_shop_tip_4, time=1})

            self:delayRun(1.0, function( ... )
                self:_statUserAction(bookmark)
                qf.event:dispatchEvent(ET.EVENT_GAMESHOP_JUMP_TO_BOOKMARK, {bookmark=bookmark, gold=self.percentGold})
            end)
		else
			if self.index ~= nil then
				qf.event:dispatchEvent(ET.NET_EXCAHNGE_CHIPS_REQ, {exchange_chips=self.percentGold, action=1, immediately=1, seat_id=self.index})
			else
				qf.event:dispatchEvent(ET.NET_EXCAHNGE_CHIPS_REQ, {exchange_chips=self.percentGold, action=1, immediately=1})
			end
			qf.event:dispatchEvent(ET.GAME_HIDE_SHOP)
		end
	end)
end

function M:selectedCbox( index )
	if not index then
		self.percentGold = 0
	elseif 1 == index then -- 最小带入
		self.percentGold = self.percentMin
		self.cboxMaxCarry:setSelectedState(false)
	elseif 2 == index then -- 最大带入
		self.percentGold = self.percentMax
		self.cboxMinCarry:setSelectedState(false)
	end
	self:resetInputLabel(0)
	self:updateExchangeNumber()
end

-- 得到跳转的标签
function M:getJumpBookmark( ... )
    local all = checkint(self.allChip)
    local gold = checkint(self.percentGold)
    if all >= gold then return nil end -- 可以补充

    local bookmark = Util:getGameShopBookmarkByGold(self.percentGold)

    return bookmark
end

function M:initEditBox( ... )
    local size = self.imgInputBg:getContentSize()
    local posx, posy = self.imgInputBg:getPosition()

    local box = cc.EditBox:create(size, cc.Scale9Sprite:create())
    box:setFontName(GameRes.font1)
    box:setFontSize(45)
    box:setMaxLength(12)
    box:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    box:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    box:setFontColor(cc.c3b(10, 10, 10))
    box:setPosition(cc.p(posx, posy))

    self:addChild(box, 1)

    self.editSupplement = box

    self.textPlaceHolder = ""
    self.lblInputTxt:setString("")

    box:registerScriptEditBoxHandler(function(strEventName,sender) 
        if strEventName == "began" then
            self.isOpenKeyboard = true
            self.lblInputTxt:setVisible(false)
			self.cboxMaxCarry:setSelectedState(false)
			self.cboxMinCarry:setSelectedState(false)
        elseif strEventName == "changed" then
        elseif strEventName == "ended" then
            -- 延迟0.05s进行赋值，防止点击其他区域把面板关闭
            Util:delayRun(0.05, function( ... )
                self.isOpenKeyboard = false
            end)
            self:setInputText()
            self.lblInputTxt:setVisible(true)
        elseif strEventName == "return" then
        end
    end)
end

function M:resetInputLabel( num )
    if 1 > num then
        self.lblInputTxt:setString(self.textPlaceHolder)
        self.lblInputTxt:setFontSize(50)
        self.lblInputTxt:setColor(cc.c3b(115, 115, 115))
    else
        local text = Util:matchStr(num, ",")
        self.lblInputTxt:setString(text)
        self.lblInputTxt:setFontSize(80)
        self.lblInputTxt:setColor(cc.c3b(50, 50, 50))
    end
end

-- 设置输入内容
function M:setInputText( ... )
    local input = self.editSupplement:getText()
    if "" == input then return end

    local text = string.trim(input)
    text = checkint(text)

    self.percentGold = text

    self:resetInputLabel(text)

    self:updateExchangeNumber()

    self.editSupplement:setText("")
end

-- 检查输入的数值是否合法
function M:checkInputIsValid( ... )
    if checkint(self.percentMin) > checkint(self.percentGold) then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=string.format(GameTxt.supplement_tip_1, self.percentMin), time=1})
        return false
    elseif checkint(self.percentGold) > checkint(self.percentMax) then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=string.format(GameTxt.supplement_tip_2, self.percentMax), time=1})
        return false
    end

    return true
end

function M:initWithData( args )
	M.super.initWithData(self, args)

    self.exchange_fee = args and args.exchange_fee or 0 -- 私人定制场服务费率
    local buyin_total, buyin_limit, buyin_remain = Cache.desk:getCustomizeBuyin() -- 本人总buyin, 牌桌buyin限制, 剩余可购筹码
    --当受限于Buyin，实际可补充到筹码小于最大买入时，按规则设置拉杆和数值
    --[[
        (当前筹码 +可购余额)  <  最小开局
            无法购买. 提示: 已达到牌局总buyin金额上限，无法继续补充筹码; 数字: 最小买入; 拉杆: 最左端
        最小开局 < (当前筹码 + 可购余额)  < 最小买入
            限制购买. 提示: 因为牌局总buyin金额限制，只能补充到XX筹码; 数字: 可补充到上限; 拉杆: 最左端; 最小买入: 可购买到的上限
        最小买入 < (当前筹码 + 可购余额)  < 最大买入
            限制购买. 提示: 因为牌局总buyin金额限制，只能补充到XX筹码; 数字: 可补充到上限; 拉杆: 按比例显示
        最大买入 < (当前筹码 + 可购余额)
            正常购买. 提示: 以实际补充筹码数量的XX%收取服务费; 数字: 最大买入; 拉杆: 最右端
    ]]
    self.customize_buyin_status = 0     --私人场buyin状态. 0, 正常; 1, 剩余额度小于最大携带, 限制购买; 2, 剩余额度小于最小携带, 无法购买
    self.customize_buyin_limit = buyin_remain + self.myChips --buyin限制下最多可补充到
    if buyin_limit > 0 and self.customize_buyin_limit < self.percentMax then
        local game_need_chips = Cache.desk:getCustomizeMinChips()   --开局所需最小筹码
        if self.customize_buyin_limit < game_need_chips then
            self.customize_buyin_status = 2
            self.percentLimit = 0
        elseif self.customize_buyin_limit < self.percentMin then
            self.customize_buyin_status = 1
            self.percentLimit = 0
        else 
            self.customize_buyin_status = 1
            if self.customize_buyin_limit < allChip then   --拉杆最大值, 受限于金币限制和buyin限制的最小值
                self.percentLimit = 100 * (self.customize_buyin_limit - self.percentMin) / (self.percentMax - self.percentMin)
            end
        end
    end

    self.percentGold = 0
    self:updateUI()
end

function M:updateExchangeNumber()
    local fee = Util:getIntPart(self.percentGold*self.exchange_fee)

    self.lblExchangeFee:setText(GameTxt.customize_service_fee..fee)
end

function M:_updateMyUI( ... )
    self.lblCurGold:setString(string.format(GameTxt.string675,tostring(Cache.user.gold)))
    self.lblMinCarry:setString(string.format(GameTxt.string673_1, Util:getFormatString(self.percentMin)))
    self.lblMaxCarry:setString(string.format(GameTxt.string674_1, Util:getFormatString(self.percentMax)))

    self.cboxMinCarry:setPositionX(self.lblMinCarry:getPositionX() + self.lblMinCarry:getContentSize().width)
    self.cboxMaxCarry:setPositionX(self.lblMaxCarry:getPositionX() + self.lblMaxCarry:getContentSize().width)

    self.textPlaceHolder = string.format(GameTxt.input_placeholder_supplement, self.percentMin)
    self.lblInputTxt:setString(self.textPlaceHolder)
end

function M:updateUI( ... )
    self:_updateMyUI()

	self:updateExchangeNumber()

    if self.customize_buyin_status == 1 then -- 限制购买
        self.lblExchangeFeeTip:setText(string.format(GameTxt.customize_buyin_limit_tip_1, self.customize_buyin_limit))
    elseif self.customize_buyin_status == 2 then -- 无法购买
	    self.lblExchangeFeeTip:setText(GameTxt.customize_buyin_limit_tip_2)
        self.btnSure:setTouchEnabled(false)
        self.btnSure:setBright(false)
    else
        self.lblExchangeFeeTip:setText(string.format(GameTxt.customize_exchange_chips_tip, self.exchange_fee*100))
    end
end

function M:getOpenKeyBoard( ... )
	return self.isOpenKeyboard
end

return M