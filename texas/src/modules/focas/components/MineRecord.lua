local MineRecord = class("MineRecord",CommonWidget.BasicWindow)
MineRecord.TAG = "MineRecord"

function MineRecord:ctor(paras)
    MineRecord.super.ctor(self, paras)
    self:showMineRecordId(paras)
    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
        bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
    end
end

function MineRecord:init(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.MineRecordJson)
    ccui.Helper:seekWidgetByName(self.gui,"txt_title"):setString(string.format(GameTxt.mineDuobaoId,paras.index))
    self.list = ccui.Helper:seekWidgetByName(self.gui,"ListView_ma")
    self.item = ccui.Helper:seekWidgetByName(self.gui,"item_ma")

    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"Button_5")
    self.okBtn = ccui.Helper:seekWidgetByName(self.gui,"Button_ok")

    addButtonEvent(self.closeBtn, function( ... )
        -- body
        self:close()
    end) 
    addButtonEvent(self.okBtn, function( ... )
        -- body
        self:close()
    end) 
end
function MineRecord:showMineRecordId( paras )
    self.list:removeAllChildren()
    self.list:setItemModel(self.item)
    local index = 0
    local num = 0
    for k,v in pairs(paras.list) do
        local time = (index/100)*0.5
        self.list:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function( ... )    
            if num%3 == 0 then
                self.list:pushBackDefaultItem()
            end
            local item = self.list:getItem(num/3)
            local recordId = item:getChildByName("txt_ma"..(num%3+1))
            recordId:setVisible(true)
            recordId:setString(v)
            num = num + 1
        end
        )))
        index = index + 1
    end
end

return MineRecord
