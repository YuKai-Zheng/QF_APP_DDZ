local M = class("TuiGuangOfficalView", CommonWidget.BasicWindow)

function M:ctor( paras )
    M.super.ctor(self, paras)
end

function M:init(  )
    
end

function M:initUI(  )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.tuiguangOfficalViewJson)

    self.btn = ccui.Helper:seekWidgetByName(self.gui, "btn")
end

function M:initClick(  )
    addButtonEvent(self.btn, function (  )
        self:close()
    end)
end

return M