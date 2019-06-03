--[[
-- 购买金币、购买钻石、购买道具
--]]
local M = class("BuyCommonView", function( args )
	return args.node
end)
local CommonItem = import(".CommonItem")

M.ITEM_WIDTH = 430
M.ITEM_HEIGHT = 520
function M:ctor( args )
	self.selectdBookmark = -1
	self.items = {}
	self.itemNum = 0

	self:initUI(args)
end

function M:initUI( args )
	self.listview = self:getChildByName("listview_common")
	self.itemDefault = self:getChildByName("item_common")
	--self.leftmoveBtn = self:getChildByName("leftmoveBtn")
	--self.rightmoveBtn = self:getChildByName("rightmoveBtn")

	self.itemDefault:setVisible(false)

    self.listview:setItemModel(self.itemDefault)

	local size = self.itemDefault:getContentSize()
	self.ITEM_WIDTH = size.width
	self.ITEM_HEIGHT = size.height

	self.viewSize = self.listview:getContentSize()

	-- addButtonEvent(self.leftmoveBtn, function( sender )
	-- 	loga(self.listview:getCurSelectedIndex())
	-- 	self.listview:jumpToPercentHorizontal(0)
	-- end)

	-- addButtonEvent(self.rightmoveBtn, function( sender )
	-- 	loga(self.listview:getCurSelectedIndex())
	-- 	self.listview:jumpToPercentHorizontal(100)
	-- end)
end

function M:updateWithData( args )
	args = args or {}
	self.ref = args.ref or UserActionPos.ROOM_SHOP_CAR
	self.payType = args.payType or 0
	self.defaultGold = args.gold or 0

	-- 标签页相同则不进行更新
	-- if self.selectdBookmark == args.bookmark then return end

	self.selectdBookmark = args.bookmark or PAY_CONST.BOOKMARK_ROOM.GOLD

    local data
    if self.selectdBookmark == PAY_CONST.BOOKMARK_ROOM.GOLD then -- 购买金币:获取相应的金币信息
        data = Cache.PayManager:getGoldInfo()
    elseif self.selectdBookmark == PAY_CONST.BOOKMARK_ROOM.DIAMOND then -- 购买砖石:获取相应的钻石信息
        data = Cache.PayManager:getDiamondList()
    else
    	return 
    end

    self.data = data
    self:_updateWithData(data)

    self:jumpToDefaultItem()
end

function M:_updateWithData( args )
	local newItemNum = #args
	local minNum = newItemNum < self.itemNum and newItemNum or self.itemNum
	-- 使用已有的Item进行更新
	for i = 1, minNum do
		local info = {data = args[i]
			, ref = self.ref
			, payType = self.payType
		}
		self.items[i]:updateWithData(self.selectdBookmark, info)
		self.items[i]:setIndex(i)
	end
	-- 如果已有的不够则进行增加
	for i = minNum + 1, newItemNum do
    	self.listview:pushBackDefaultItem()
    	local item = self.listview:getItem(i - 1)
    	item:setVisible(true)

		self.items[i] = CommonItem.new({node=item})

		local info = {data = args[i]
			, ref = self.ref
			, payType = self.payType
		}
		self.items[i]:updateWithData(self.selectdBookmark, info)
		self.items[i]:setVisible(true)
		self.items[i]:setIndex(i)
	end
	-- 如果已有的多了，则要进行移除
	for i = self.itemNum, newItemNum + 1, -1 do
		self.listview:removeItem(i - 1)
		self.items[i] = nil
	end

	-- 对item数量进行更新
	self.itemNum = newItemNum

	self.innerContentWidth = self.itemNum*self.ITEM_WIDTH
	self.listview:setInnerContainerSize(cc.size(self.innerContentWidth, self.viewSize.height))
end

function M:searchByFieldAndValue( field, value )
	for i = 1, self.itemNum do
		local data = self.data[i]
		if data and data[field] == value then
			return i
		end
	end

	return nil
end

-- 调到指定的item
function M:jumpToDefaultItem( ... )
	-- 按照最小携带进行跳转
	local minCarry = self.defaultGold

	local defaultIndex
	if self.selectdBookmark == PAY_CONST.BOOKMARK_ROOM.GOLD then -- 金币页
		local goldInfo = Cache.QuickPay:getSuitableGoldInfoByRequire(minCarry)

		defaultIndex = self:searchByFieldAndValue("amount", goldInfo.amount)
	else -- 钻石页
		local diamondInfo = Cache.QuickPay:getSuitableDiamondByRequire(minCarry)
		
		defaultIndex = self:searchByFieldAndValue("cost", diamondInfo.cost)
	end

	if not defaultIndex then return end

	local percent 
	if defaultIndex <= 2 then
		percent = 0
	elseif defaultIndex + 2 > self.itemNum then
		percent = 100
	elseif self.itemNum <= 2 then
		percent = 0
	else
		local totalWidth = self.innerContentWidth - self.viewSize.width -- 总共可以滑动的距离
		local width = (defaultIndex - 0.5)*self.ITEM_WIDTH - self.viewSize.width*0.5 -- 需要滑动的距离

		percent = 100*width/totalWidth
	end

	self.listview:jumpToPercentHorizontal(percent)
end

return M