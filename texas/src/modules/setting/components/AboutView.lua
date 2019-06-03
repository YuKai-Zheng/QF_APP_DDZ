local AboutView = class("AboutView",CommonWidget.BasicWindow)
AboutView.TAG = "AboutView"

local IButton = import(".IButton")

function AboutView:ctor(paras)
    self.cb = paras.cb
    AboutView.super.ctor(self, paras)
end

function AboutView:init()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.aboutViewJson)
end

function AboutView:initClick(  )
    addButtonEvent(self.gui:getChildByName("back"), function (  )
        self:close()
    end)
end

return AboutView
