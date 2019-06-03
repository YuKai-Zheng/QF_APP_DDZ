--
-- Author: Your Name
-- Date: 2018-07-17 11:01:32
--
local GuaGuaCardSuccessTip = class("GuaGuaCardSuccessTip",CommonWidget.BasicWindow)
GuaGuaCardSuccessTip.TAG = "GuaGuaCardSuccessTip"
function GuaGuaCardSuccessTip:ctor(paras)
    GuaGuaCardSuccessTip.super.ctor(self, paras)
    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
        bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
        self.gui:setPositionX(-(self.winSize.width - 1980)/2)
    end
end


function GuaGuaCardSuccessTip:init(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.GetGuaGuaCardSuccessJson)
    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"Image_close")
    self.exchangeP = ccui.Helper:seekWidgetByName(self.gui,"Panel_dui_huan")--规则层
    self.sureBtn = ccui.Helper:seekWidgetByName(self.exchangeP,"exchangebtn")--确认按钮

    addButtonEvent(self.sureBtn, function( ... )
        if self.cb then
            self.cb()
        end

        qf.event:dispatchEvent(ET.SHOW_DAOJU_VIEW)
        -- qf.platform:umengStatistics({umeng_ke = "pack"})--点击上报
        self:close()
    end) 
    addButtonEvent(self.closeBtn, function( ... )
        self:close()
    end)    
end

return GuaGuaCardSuccessTip