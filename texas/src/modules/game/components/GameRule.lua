local GameRule = class("GameRule",CommonWidget.BasicWindow)

function GameRule:ctor(paras)
    GameRule.super.ctor(self, paras)
end

function GameRule:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(DDZ_Res.gameRuleJson)

     self.ruleViewP = ccui.Helper:seekWidgetByName(self.gui,"ruleviewP")
     self.ruleViewBg = ccui.Helper:seekWidgetByName(self.ruleViewP,"Image_59")
     self.ruleScrollViewP = ccui.Helper:seekWidgetByName(self.ruleViewP,"rulescrollP")
     self.btn_close = ccui.Helper:seekWidgetByName(self.gui, "btn_close")
end

function GameRule:initClick()
    addButtonEventMusic(self.btn_close,DDZ_Res.all_music["BtnClick"],function()
        self:close()
    end)
end

return GameRule