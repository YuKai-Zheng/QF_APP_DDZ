local FocasRecord = class("FocasRecord",CommonWidget.BasicWindow)
FocasRecord.TAG = "FocasRecord"
local MineRecord = import(".MineRecord")
local GetGoods = import(".GetGoods")
function FocasRecord:ctor(paras)
    FocasRecord.super.ctor(self, paras)
    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
        bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
    end
end

function FocasRecord:init(paras)
    -- if paras and paras.cb then
    --     self.cb = paras.cb
    -- end
end

function FocasRecord:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.FocasRecordJson)

    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"Image_close")
    self.checkP = ccui.Helper:seekWidgetByName(self.gui,"checkp")--选择层
    self.duobaoList = ccui.Helper:seekWidgetByName(self.gui,"ListView_duo_bao")--夺宝层
    self.duobaoIetm = ccui.Helper:seekWidgetByName(self.gui,"duo_bao_item")--夺宝模板
    self.getrecordList = ccui.Helper:seekWidgetByName(self.gui,"ListView_ling_jiang")--领奖层
    self.getrecordItemm = ccui.Helper:seekWidgetByName(self.gui,"Panel_39")--领奖模板
    self.getrecordTitle = ccui.Helper:seekWidgetByName(self.gui,"Panel_ling_jiang")--领奖标题

    self:initGetRecordList()
end

function FocasRecord:initClick( ... )
    addButtonEvent(self.closeBtn, function( ... )
        self:close()
    end) 
end

--初始化领奖记录列表
function FocasRecord:initGetRecordList()
    self.getrecordList:removeAllChildren()
    self.getrecordList:setItemModel(self.getrecordItemm)

    local index = 0
    for k,v in pairs(Cache.ExchangeMallInfo.my_receive_record) do
        self.getrecordList:pushBackDefaultItem()
        local goods = self.getrecordList:getItem(index)
        ccui.Helper:seekWidgetByName(goods,"name"):setString(v.name)--物品名
        ccui.Helper:seekWidgetByName(goods,"Label_41"):setString(Cache.user.nick)--获奖者
        ccui.Helper:seekWidgetByName(goods,"time"):setString(os.date("%c", v.receive_time))--领奖时间
        if v.status==0 then
            ccui.Helper:seekWidgetByName(goods,"status"):setString("未发放")
        elseif v.status==1 then
            ccui.Helper:seekWidgetByName(goods,"status"):setString("审核中")
        elseif v.status==3 then
            ccui.Helper:seekWidgetByName(goods,"status"):setString("审核失败")
            ccui.Helper:seekWidgetByName(goods,"status"):setFontSize(32)
        else
            ccui.Helper:seekWidgetByName(goods,"status"):setString("已发放")
            ccui.Helper:seekWidgetByName(goods,"status"):setColor(cc.c3b(132,88,67))
            ccui.Helper:seekWidgetByName(goods,"Image_43"):setVisible(false)
        end 
        index = index + 1
    end
end

-- function FocasRecord:close()
--     if self.cb then
--         self.cb()
--     end

--     FocasRecord.super.close(self)
-- end
return FocasRecord
