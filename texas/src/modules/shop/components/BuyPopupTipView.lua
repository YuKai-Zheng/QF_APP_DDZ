--[[
-- 购买弹出提示框
--]]
local M = class("BuyPopupTipView", CommonWidget.BasicWindow)

function M:ctor( args )
    M.super.ctor(self,args)
end

function M:init( args )
	self.content = args.content
	self.title = args.title
	self.sureCb = args.sureCb
	self.cancelCb = args.cancelCb
end

function M:initUI( ... )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.shopBuyPopupTipJson)
	local panRoot = self.gui:getChildByName("pan_root")
	self.imgTitle = panRoot:getChildByName("img_title")
	self.lblContent = panRoot:getChildByName("lbl_content")
	self.btnExit = panRoot:getChildByName("btn_exit")
	self.btnCancel = panRoot:getChildByName("btn_cancel")
	self.btnSure = panRoot:getChildByName("btn_sure")

	self.lblContent:setString(self.content)
	if self.title then
		self.imgTitle:loadTexture(self.title)
	end
end

function M:initClick( ... )
	addButtonEvent(self.btnExit, function( sender )
		self:close()
	end)
	addButtonEvent(self.btnSure, function( sender )
		if self.sureCb then self.sureCb() end
		self:close()
	end)
	addButtonEvent(self.btnCancel, function( sender )
		if self.cancelCb then self.cancelCb() end
		self:close()
	end)
end

return M