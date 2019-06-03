--[[
-- 金币、钻石Item
-- 格式：底图、icon、数量
--]]
local M = class("MoneyItem", function( args )
	return args.node
end)

function M:ctor( args )
	self._name = args.name
	self.number = 0

	self:initUI()
end

function M:initUI( ... )
	self.lblNum = self:getChildByName("lbl_num")
end

function M:updateWithNumber( num )
	if not num then return end

	self.number = num
	if self._name == "diamond" then
		self.lblNum:setString(self.number)
	else
		self.lblNum:setString(Util:getFormatString(self.number))
	end
end

function M:addWithNumber( num )
	if not num then return end

	self:updateWithNumber(self.number + num)
end

return M