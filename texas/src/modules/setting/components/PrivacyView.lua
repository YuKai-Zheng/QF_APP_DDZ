local PrivacyView = class("PrivacyView", CommonWidget.BasicWindow)
PrivacyView.TAG = "PrivacyView"

local IButton = import(".IButton")

function PrivacyView:ctor(paras)
    self.cb = paras.cb
    PrivacyView.super.ctor(self, paras)
end

function PrivacyView:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.privacyViewJson)
    self.gui:getChildByName("bg"):setTouchEnabled(true)
    self.back_btn = IButton.new({node = self.gui:getChildByName("back")})
end

function PrivacyView:initClick(  )
    addButtonEvent(self.gui:getChildByName("back"), function (  )
        self:close()
    end)
end

return PrivacyView
