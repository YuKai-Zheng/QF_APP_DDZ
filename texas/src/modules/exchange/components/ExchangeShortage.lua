-- 兑换时奖券不足
local ExchangeShortage = class("ExchangeShortage", CommonWidget.BasicWindow)
ExchangeShortage.TAG = "ExchangeShortage"

function ExchangeShortage:ctor(paras)
    ExchangeShortage.super.ctor(self, paras)
end

function ExchangeShortage:init(paras)
end

function ExchangeShortage:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.exchangeShortageJson)
    self.btn_close = ccui.Helper:seekWidgetByName(self.gui, "btn_close")  -- 关闭按钮
    self.btn_match = ccui.Helper:seekWidgetByName(self.gui, "btn_match")  -- 比赛按钮
end

function ExchangeShortage:initClick(paras)
    addButtonEvent(self.btn_close, function(sender)
        self:close()
    end)
    addButtonEvent(self.btn_match, function(sender)
        qf.event:dispatchEvent(ET.MATCH_VIEW_UPDATE, {cb=function()
            self:close()
            qf.event:dispatchEvent(ET.REMOVE_EXCHANGEMALL_VIEW)
        end})
    end)
end

return ExchangeShortage