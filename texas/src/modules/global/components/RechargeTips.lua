

local RechargeTips = class("RechargeTips",CommonWidget.BasicWindow)
RechargeTips.tag = "RechargeTips"


function RechargeTips:ctor( paras )
	-- body
    self.winSize = cc.Director:getInstance():getWinSize()
    RechargeTips.super.ctor(self, paras)
end

function RechargeTips:init( paras )
	-- body
	self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.rechargeTipsJson)
	self.refuse = ccui.Helper:seekWidgetByName(self.gui,"refuse_0")
	self.accept = ccui.Helper:seekWidgetByName(self.gui,"accept_0")
	self.close_btn = ccui.Helper:seekWidgetByName(self.gui,"close_btn_0")
    self.bg_panel = ccui.Helper:seekWidgetByName(self.gui,"bg_panel")
end

function RechargeTips:initClick(  )
	-- body
    addButtonEvent(self.refuse,function (sender)
        self:closeView()
    end)
    addButtonEvent(self.accept,function (sender)
        self:closeView()
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅商城") end
        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop"})
        qf.platform:umengStatistics({umeng_key = "Shopping_Mall"})--点击上报

    end)
    addButtonEvent(self.close_btn,function (sender)
        self:closeView()
    end)
    addButtonEvent(self.bg_panel,function (sender)
    end)
end

function RechargeTips:closeView()
    self:close()
    if self.cb then
        self.cb()
    end
end

return RechargeTips