--[[
-- 商城左侧的标签页
--]]
local M = class("BookmarkView", function( args )
	return args.node
end)

function M:ctor( args )
	self._bookmark = args and args.bookmark or PAY_CONST.BOOKMARK.GOLD
	self.itemDefault = args.item

	self:initUI(args)
end

function M:initUI( args )
	self:setItemModel(self.itemDefault)

	self.items = {}
	self.itemNum = 0

	local indexs = {}
	for _, v in pairs(PAY_CONST.BOOKMARK) do
		if v == PAY_CONST.BOOKMARK.GOLD -- 购买金币
		 	or v == PAY_CONST.BOOKMARK.PROPS -- 道具超市
			then
			table.insert(indexs, v)
		elseif v == PAY_CONST.BOOKMARK.EXCHANGE or v == PAY_CONST.BOOKMARK.PROPS then -- 兑换专区
		    if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW   -- 没过审或是港台版不显示兑换专区
		        then
				-- table.insert(indexs, v)
			end
		else
			-- table.insert(indexs, v)
		end
	end

	table.sort(indexs, function( a, b )
		return a < b
	end)

	for i = 1, #indexs do
		self:insertBookmark(indexs[i])
	end

	self:_selectBookmark(self._bookmark)
end

function M:insertBookmark( bookmark )
	self:pushBackDefaultItem()

	local item = self:getItem(self.itemNum)
	item:setVisible(true)

	local normal, selected = self:_getBookmarkRes(bookmark)

	local imgBookmark = item:getChildByName("img_bookmark")
	imgBookmark:loadTexture(normal)

	local btn = item:getChildByName("btn_bookmark")
	btn._bookmark = bookmark
	addButtonEvent(btn, function( sender )
		self:jumpToBookmark(sender._bookmark)
	end)

	self.items[bookmark] = item
	self.itemNum = self.itemNum + 1
end

function M:jumpToBookmark( bookmark )
	self:_selectBookmark(bookmark)

	if bookmark == self._bookmark then return end
	self._bookmark = bookmark

	qf.event:dispatchEvent(ET.EVENT_SHOP_JUMP_TO_BOOKMARK, {bookmark=bookmark})
end

function M:_getBookmarkRes( bookmark )
	local normal, selected
	if bookmark == PAY_CONST.BOOKMARK.GOLD then -- 购买金币
		normal, selected = GameRes.shop_bookmark_gold_sel, GameRes.shop_bookmark_gold
	elseif bookmark == PAY_CONST.BOOKMARK.DIAMOND then -- 购买钻石
		normal, selected = GameRes.shop_bookmark_diamond_sel, GameRes.shop_bookmark_diamond
	elseif bookmark == PAY_CONST.BOOKMARK.PROPS then -- 购买道具
		normal, selected = GameRes.shop_bookmark_props_sel, GameRes.shop_bookmark_props
	-- elseif bookmark == PAY_CONST.BOOKMARK.EXCHANGE then -- 兑换
	-- 	normal, selected = GameRes.shop_bookmark_exchange, GameRes.shop_bookmark_exchange_sel
	end

	return normal, selected
end

function M:_selectBookmark( bookmark )
	for b, item in pairs(self.items) do
		if b ~= bookmark then
			local btn = item:getChildByName("btn_bookmark")
			local img = item:getChildByName("img_bookmark")
			btn:setHighlighted(false)
			btn:setTouchEnabled(true)

			local normal, selected = self:_getBookmarkRes(b)
			img:loadTexture(selected)
		end
	end

    local item = self.items[bookmark]
    dump(self.items)
	local btn = item:getChildByName("btn_bookmark")
	local img = item:getChildByName("img_bookmark")
	btn:setHighlighted(true)
	btn:setTouchEnabled(false)

	local normal, selected = self:_getBookmarkRes(bookmark)
	img:loadTexture(normal)
end


return M