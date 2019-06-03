--[[
-- 游戏内商城上面的标签页
--]]
local M = class("BookmarkView", function( args )
	return args.node
end)

function M:ctor( args )
	self._bookmark = args and args.bookmark or PAY_CONST.BOOKMARK_ROOM.SUPPLY

	self:initUI(args)
	self:initClick()
end

function M:initUI( args )
	self.items = {}

	self.btnBuyDiamond = self:getChildByName("btn_buy_diamond")
	self.items[PAY_CONST.BOOKMARK_ROOM.DIAMOND] = self.btnBuyDiamond
	self.btnBuyGold = self:getChildByName("btn_buy_gold")
	self.items[PAY_CONST.BOOKMARK_ROOM.GOLD] = self.btnBuyGold
	self.btnSupply = self:getChildByName("btn_supply")
	self.items[PAY_CONST.BOOKMARK_ROOM.SUPPLY] = self.btnSupply
	self.btn_buy_gold_txt = self:getChildByName("btn_buy_gold_txt")

	self:_reviewControl()

	self:_selectBookmark(self._bookmark)

	if  not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self:getChildByTag(3126):setVisible(false)
    end 
end

-- 审核控制
function M:_reviewControl( ... )
	if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end

	self.btnBuyGold:setVisible(false)
	self.btn_buy_gold_txt:setVisible(false)
	-- local goldSize = self.btnBuyGold:getContentSize()

	-- local posxDiamond = self.btnBuyDiamond:getPositionX()
	-- self.btnBuyDiamond:setPositionX(posxDiamond + goldSize.width*0.5)

	-- local posxSupply = self.btnSupply:getPositionX()
	-- self.btnSupply:setPositionX(posxSupply - goldSize.width*0.5)
end

function M:initClick( ... )
	addButtonEvent(self.btnBuyGold, function( sender )
		self:jumpToBookmark(PAY_CONST.BOOKMARK_ROOM.GOLD)
		

	end)
	addButtonEvent(self.btnBuyDiamond, function( sender )
		self:jumpToBookmark(PAY_CONST.BOOKMARK_ROOM.DIAMOND)
	end)
	addButtonEvent(self.btnSupply, function( sender )
		self:jumpToBookmark(PAY_CONST.BOOKMARK_ROOM.SUPPLY)
	end)
end

function M:jumpToBookmark( bookmark )
	self:_selectBookmark(bookmark)

	if bookmark == self._bookmark then return end
	self._bookmark = bookmark

	qf.event:dispatchEvent(ET.EVENT_GAMESHOP_JUMP_TO_BOOKMARK, {bookmark=bookmark})
end

function M:_selectBookmark( bookmark )
	for b, item in pairs(self.items) do
		if b ~= bookmark then
			item:setTouchEnabled(true)
            item:setOpacity(0)
		end
		item:setTitleText("")
	end

	local item = self.items[bookmark]
	item:setTouchEnabled(false)
    item:setOpacity(255)
end

function M:updateWithData( is_supply )
	self.is_supply = is_supply

	if 1 ~= self.is_supply then -- 不支持补充筹码界面
		self.btnSupply:setVisible(false)

		self.btnBuyGold:loadTextures(GameRes.change_userinfo_right_btn, "", "")

		local x = self.btnBuyGold:getPositionX()
		self.btnBuyGold:setPositionX(x + 150)
		local sizeGold = self.btnBuyGold:getContentSize()
		local sizeDiamond = self.btnBuyDiamond:getContentSize()
		self.btnBuyDiamond:setPositionX(x + 150 - sizeGold.width*0.5 - sizeDiamond.width*0.5)
	end
end

return M