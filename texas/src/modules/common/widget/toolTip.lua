local toolTips = class("DeviceStatus",function ()
    return cc.Layer:create()
end)

function toolTips:ctor(paras)	
	self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.toolTipsJson)
	self:addChild(self.gui)
	self:init(paras)
	self:initClick()
	if paras then
		self.cb = paras.cb
		self.surecb = paras.surecb
	end
	self.winSize = cc.Director:getInstance():getWinSize()
	
	if FULLSCREENADAPTIVE then 
		local fullscreenX = -(self.winSize.width/2-1920/2)
		self.gui:setPositionX(-fullscreenX)
		self.closeP:setPositionX(fullscreenX)
		self.closeP:setContentSize(self.closeP:getContentSize().width+self.winSize.width-1920,self.closeP:getContentSize().height)
	end
end

function toolTips:init(paras)
	-- body
	self.closeP = ccui.Helper:seekWidgetByName(self.gui,"closeP") 
	self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"closebtn") 
	self.sureBtn = ccui.Helper:seekWidgetByName(self.gui,"surebtn") 
	self.topText = ccui.Helper:seekWidgetByName(self.gui,"tipstop") 
	self.downText = ccui.Helper:seekWidgetByName(self.gui,"tipsdown") 
	self.tipsP = ccui.Helper:seekWidgetByName(self.gui,"tipsP")
	self.tipsdi = ccui.Helper:seekWidgetByName(self.gui,"tipsdi")
end

function toolTips:initClick( ... )
	-- body
	addButtonEvent(self.closeBtn,function( ... )
		-- body
		self:closeView()
	end)
	addButtonEvent(self.sureBtn,function( ... )
		-- body
		if self.surecb then
			self.surecb()
		end
		self:closeView()
	end)
	addButtonEvent(self.closeP,function( ... )
		-- body
	end)
end

function toolTips:setTipsText(msg)
    self.decContent = self.tipsdi:getChildByName("content")
    self.descLb = self.decContent:getChildByName("desc")
    
    local richNode = require("src.modules.common.widget.RichTextNode")
    richNode.new({
        node = self.descLb,
        text = msg,
        targetTxtValue = "<WebSite>",
        targetTxtColor = cc.c3b(255, 0, 0),
        targetFontSize = 34,
        normalColor = cc.c3b(160, 64, 00),
        normalFontSize = 34,
        cb = function ( ... )
        end
    })
end

function toolTips:hideOtherText( ... )
	self.topText:setVisible(false)
	self.downText:setVisible(false)
end

function toolTips:removeCloseTouch()
	-- body
	self.closeBtn:setVisible(false)
	self.sureBtn:setVisible(false)
	self.closeP:setTouchEnabled(false)
end

function toolTips:setTipsType(info)
	if info.removeClose then
		self.closeBtn:setVisible(false)
	end
end

function toolTips:closeView( ... )
	if self.cb then
		self.cb()
	end
	self:removeFromParent()
end

return toolTips