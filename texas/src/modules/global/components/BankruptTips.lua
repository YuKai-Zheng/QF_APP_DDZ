

local BankruptTips = class("BankruptTips",CommonWidget.BasicWindow)
BankruptTips.tag = "BankruptTips"

function BankruptTips:ctor( paras )
	-- body
    self.winSize = cc.Director:getInstance():getWinSize()
    BankruptTips.super.ctor(self, paras)
end

function BankruptTips:init( paras )
    -- body
    dump(paras, "破产弹窗数据")
	self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.bankrupt_tipsJson)
	self.refuse = ccui.Helper:seekWidgetByName(self.gui,"refuse")
	self.accept = ccui.Helper:seekWidgetByName(self.gui,"accept")
    self.bg_panel = ccui.Helper:seekWidgetByName(self.gui,"bg_panel")

    self.txt_tip = ccui.Helper:seekWidgetByName(self.gui, "txt_tip")
    
    self.bankrupt_num = ccui.Helper:seekWidgetByName(self.gui,"txt_num")
    if paras.give_gold then
        self.bankrupt_num:setString(paras.give_gold)
    end

    self.txt_tip:setString(string.format( GameTxt.bankrupt_count_tip,paras.count, paras.total_count - paras.count ))
end

function BankruptTips:initClick(  )
    addButtonEvent(self.refuse,function (sender)
        self:close()
    end)
    addButtonEvent(self.accept,function (sender)
        self:close()
    end)
end

function BankruptTips:close()
    if self.cb then
        self.cb()
    end

    BankruptTips.super.close(self)
end

return BankruptTips
