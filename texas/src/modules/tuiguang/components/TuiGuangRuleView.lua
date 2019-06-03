local M = class("TuiGuangRuleView", CommonWidget.BasicWindow)

function M:ctor( paras )
    M.super.ctor(self, paras)
end

function M:init(  )
    
end

function M:initUI(  )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.tuiguangRuleViewJson)

    self.btn_close = ccui.Helper:seekWidgetByName(self.gui, "btn_close")

    self.txt = ccui.Helper:seekWidgetByName(self.gui, "txt")

    local activityData = Cache.Config:getTuiGuangInfo()

    self.txt:setString(string.format( GameTxt.tuiguangRule, activityData.activity_date, activityData.reward_per_user / 100)) 
    --self.txt:setLineHeight(80)
end

function M:initClick(  )
    addButtonEvent(self.btn_close, function (  )
        self:close()
    end)
end

return M