local GetFocas = class("GetFocas",CommonWidget.BasicWindow)
GetFocas.TAG = "GetFocas"

function GetFocas:ctor(paras)
    GetFocas.super.ctor(self, paras)
    self:initGetFocasList()
    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
        bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
    end
end

function GetFocas:init(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.GetFocasJson)
    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"Image_close")
    self.getfocasList = ccui.Helper:seekWidgetByName(self.gui,"ListView_fu_ka")--领奖层
    self.getfocasItemm = ccui.Helper:seekWidgetByName(self.gui,"item_fu_ka")--领奖模板
    self.gotoFocasHallBtn = ccui.Helper:seekWidgetByName(self.gui,"Panel_qian_wang")--前往福利中心
    self.bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
    self.bg:setScale(0.1)
    self.bg:runAction(cc.ScaleTo:create(0.2,1))
    if paras then
        self.gotoFocasHallBtn:setVisible(false)
    end
end

--初始化获取奖券列表
function GetFocas:initGetFocasList()
    self.getfocasList:removeAllChildren()
    self.getfocasList:setItemModel(self.getfocasItemm)
    local switch = {
        [1]=function(paras)--福利任务(跳转成就任务)
            qf.event:dispatchEvent(ET.SHOW_REWARD_VIEW)
            qf.event:dispatchEvent(ET.REWARD_SORT_CHECK) 
        end,
        [2]=function(paras)--每日充值(跳转商城)
            qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop", bookmark=PAY_CONST.BOOKMARK.DIAMOND})
        end,
        [3]=function(paras)--积分兑换(跳转升值积分)
            qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "appreciate"})
        end
    }
    local index = 0
    for k,v in pairs(GameTxt.focas_getfocas) do
        self.getfocasList:pushBackDefaultItem()
        local goods = self.getfocasList:getItem(index)
        goods:setVisible(true)
        ccui.Helper:seekWidgetByName(goods,"Image_item_fuka"):loadTexture(string.format(GameRes.getFocasImg,v.id))
        ccui.Helper:seekWidgetByName(goods,"txt_fu_ka"):setString(v.title)
        if v.id == 2 then
            ccui.Helper:seekWidgetByName(goods,"txt_fu_ka2"):setString(string.format(v.info,Cache.Config.recharge_return_fucard[1],Cache.Config.recharge_return_fucard[2]))
        else
            ccui.Helper:seekWidgetByName(goods,"txt_fu_ka2"):setString(v.info)
        end
        addButtonEvent(ccui.Helper:seekWidgetByName(goods,"Button_qian_wang"),function( ... )
            switch[v.id]()
        end)
        index = index + 1
    end
end

function GetFocas:initClick( ... )
    addButtonEvent(self.closeBtn, function( ... )
        self:close()
    end) 
    addButtonEvent(self.gotoFocasHallBtn,function( ... )
        qf.event:dispatchEvent(ET.SHOW_EXCHANGEMALL_VIEW)
        self:close()
    end)
end

return GetFocas
