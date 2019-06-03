local ExchangeTips = class("ExchangeTips",CommonWidget.BasicWindow)
ExchangeTips.TAG = "ExchangeTips"
function ExchangeTips:ctor(paras)
    ExchangeTips.super.ctor(self, paras)
    self.item_type = paras.item_type
    self.item_id = paras.item_id
    self.cb = paras.cb
    self.itemName = paras.name
    self.itemValue = paras.value
    self.itemPic = paras.item_pic
    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.gui,"Image_1")
        bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
    end
end

function ExchangeTips:init(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.AppreciateExchangeJson)
    self.exchangeTxt = ccui.Helper:seekWidgetByName(self.gui,"txt")--兑换文本
    self.exchangeTxt:setString(string.format(GameTxt.focas_exchange_tips,paras.value,paras.name))
    self.sureBtn = ccui.Helper:seekWidgetByName(self.gui,"surebtn")--确认按钮
    self.cancelBtn = ccui.Helper:seekWidgetByName(self.gui,"cancelbtn")--取消按钮

    addButtonEvent(self.sureBtn, function( ... )
        local body = {
            uin=Cache.user.uin,
            item_id=self.item_id
        }
        local item_type = self.item_type
        local itemName = self.itemName
        local itemPic = self.itemPic
        GameNet:send({cmd = CMD.EXCHANGE_WELFARE,body=body,callback=function(rsp)
            if rsp.ret == 0 then
                local info = {}
                if item_type==1 then --金币
                    info = {getRewardType = 2, rewardInfo = {"恭喜您成功兑换" .. itemName},rewardInfoUrl = {itemPic}}
                elseif item_type==2 or item_type==7 then--话费
                    local showString = "恭喜您成功兑换" .. itemName.."，24小时内到账哦"
                    info = {getRewardType = 2, rewardInfo = {"","","","",showString}, rewardInfoUrl = {"","","","",itemPic}}
                elseif item_type==3 or item_type==6 or item_type==8 then --实物
                    local showString = "恭喜您成功兑换"..itemName..",我们将于7个工作日内发货"
                    info = {getRewardType = 2, rewardInfo = {"","","","","",showString}, rewardInfoUrl = {"","","","","",itemPic}}
                elseif item_type==5 or item_type == 9 then --刮刮卡、超级加倍卡
                    info = {getRewardType = 2, rewardInfo = {"","","",itemName},rewardItemType = item_type, rewardInfoUrl = {"","","",itemPic}}
                end
                qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, info)
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
            end
        end})
        self:close()
        if self.cb then
            self.cb()
        end
    end) 
    addButtonEvent(self.gui, function( ... )
        -- body
    end) 
    addButtonEvent(self.cancelBtn, function( ... )
        -- body
        if self.cb then
            self.cb()
        end
        self:close()
    end)    
end

return ExchangeTips
