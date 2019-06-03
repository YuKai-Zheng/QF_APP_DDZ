local AgreementView = class("AgreementView",CommonWidget.BasicWindow)
AgreementView.TAG = "AgreementView"

local IButton = import(".IButton")

function AgreementView:ctor(paras)
    self.cb = paras.cb
    AgreementView.super.ctor(self, paras)
end

function AgreementView:init()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.agreementViewJson)
end

function AgreementView:initClick(  )
    addButtonEvent(self.gui:getChildByName("back"), function (  )
        self:close()
    end)
end

return AgreementView
