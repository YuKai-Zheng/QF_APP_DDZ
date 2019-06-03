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
	self.viewSize = self:getContentSize()
	self.ref = args.ref
	self:initUI(args)
end

function M:initUI( args )
	self.itemDefault = args.item

	local size = self.itemDefault:getContentSize()
	self.ITEM_WIDTH = size.width
	self.ITEM_HEIGHT = size.height
end

function M:updateWithData( args )
	-- 标签页相同则不进行更新
	-- if self.selectdBookmark == args.bookmark then return end
	self.selectdBookmark = args and args.bookmark or PAY_CONST.BOOKMARK.GOLD

    local data
    if self.selectdBookmark == PAY_CONST.BOOKMARK.GOLD then -- 购买金币:获取相应的金币信息
        data = self:fileFirstRechargeData()
    elseif self.selectdBookmark == PAY_CONST.BOOKMARK.DIAMOND then -- 购买砖石:获取相应的钻石信息
        data = Cache.PayManager:getDiamondList()
    elseif self.selectdBookmark == PAY_CONST.BOOKMARK.PROPS then -- 购买道具:获取相应的道具信息
        data = Cache.PayManager:getToolsInfo()
        local items = {}
        for i = 1, #data do
            if data[i].name == "cards_remember" or data[i].name == "super_multi_card" then
            else
                table.insert( items,data[i] )
            end
        end
        data = items
    else
    	return 
    end

    self:_updateWithData(data)
end
--过滤筛选首充礼包
function M:fileFirstRechargeData( args )
    local data = {}
	local originalData = Cache.PayManager:getGoldInfo()
	for k,v in pairs(originalData) do
		if v.is_show and v.is_show == true and v.item_name ~= "apl_discount_goods_recharge_6" and v.item_name ~= "apl_first_recharge_6" then
			table.insert(data, v)
		end
	end

	return data
end

function M:_updateWithData( args )
	local newItemNum = #args
	local minNum = newItemNum < self.itemNum and newItemNum or self.itemNum
	-- 使用已有的Item进行更新
	for i = 1, minNum do
		self.items[i]:updateWithData(self.selectdBookmark, args[i])
		self.items[i]:setIndex(i)
	end
	-- 如果已有的不够则进行增加
	for i = minNum + 1, newItemNum do
		local item = self.itemDefault:clone()
		self.items[i] = CommonItem.new({node=item,ref=self.ref})
		self.items[i]:updateWithData(self.selectdBookmark, args[i])
		self.items[i]:setVisible(true)
		self.items[i]:setIndex(i)
		self:addChild(self.items[i])
	end
	-- 如果已有的多了，则要进行移除
	for i = newItemNum + 1, self.itemNum do
		self.items[i]:removeFromParent()
		self.items[i] = nil
	end
	-- 对item数量进行更新
	self.itemNum = newItemNum

	self:adjustLayout()
end
-- 根据编号获取item位置
function M:getPositionByIndex( index )
	local x, y = 0, self.containerSize.height - self.ITEM_HEIGHT

	local row = math.floor((index - 1)/3)
	local column = (index - 1)%3
	x = x + column*self.ITEM_WIDTH
	y = y - row*self.ITEM_HEIGHT

	return cc.p(x, y)
end
-- 调整布局
function M:adjustLayout( ... )
	local row = math.ceil(self.itemNum/3)
	local height = row*self.ITEM_HEIGHT
	height = height > self.viewSize.height and height or self.viewSize.height

	self.containerSize = cc.size(self.viewSize.width, height)
	self:setInnerContainerSize(self.containerSize)

	for i = 1, self.itemNum do
		self.items[i]:setPosition(self:getPositionByIndex(i))
		-- if i%3 == 1 then
		-- 	self.items[i]:getChildByName("ban"):setVisible(true)
		-- else
		-- 	self.items[i]:getChildByName("ban"):setVisible(false)
		-- end
	end
end

return M