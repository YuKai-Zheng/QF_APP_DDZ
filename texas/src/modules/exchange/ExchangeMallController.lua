-- 兑换商城
local ExchangeMallController = class("ExchangeMallController",qf.controller)

ExchangeMallController.TAG = "ExchangeMallController"
local ExchangeMallView = import(".ExchangeMallView")
local GetGoods = import("..focas.components.GetGoods")
local FocasRecord = import("..focas.components.FocasRecord")
local ExchangeDetail = import(".components.ExchangeDetail")
local ExchangeShortage = import(".components.ExchangeShortage")

function ExchangeMallController:ctor(parameters)
    ExchangeMallController.super.ctor(self)
end

function ExchangeMallController:initGlobalEvent()
    --奖券变化通知
    qf.event:addEvent(ET.EVT_USER_FOCARD_CHANGE_EXCHANGEVIEW,function(rsp)
        if rsp.model and rsp.model.remain_amount then
            Cache.user.fucard_num = rsp.model.remain_amount
        end
        if isValid(self.exchangeView) then
            self.exchangeView:updateInfoData()
        end
    end)

    --领奖记录
    qf.event:addEvent(ET.WELFARE_INDIANNA_RECORD,function( ... )
        GameNet:send({cmd = CMD.WELFARE_INDIANNA_RECORD,body={},callback=function(rsp)
            if rsp.ret == 0 then
                if rsp.model then
                    Cache.ExchangeMallInfo:SaveWelfareIndianaRecord(rsp.model)
                end
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
            end
        end})
    end)

    --显示领奖记录弹窗
    qf.event:addEvent(ET.SHOW_EXCHANGERECORD_DIALOG,function( ... )
        GameNet:send({cmd = CMD.WELFARE_INDIANNA_RECORD,body={},callback=function(rsp)
            if rsp.ret == 0 then
                if rsp.model then
                    Cache.ExchangeMallInfo:SaveWelfareIndianaRecord(rsp.model)
                    PopupManager:push({class = FocasRecord, init_data = model})
                    PopupManager:pop()
                end
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
            end
        end})
    end)

    --显示物品获取方式弹窗
    qf.event:addEvent(ET.SHOW_GETGOODS_DIALOG, function(model)
        PopupManager:push({class = GetGoods, init_data = model})
        PopupManager:pop()
    end)

    --显示兑换详情弹窗
    qf.event:addEvent(ET.SHOW_EXCHANGEDETAIL_DIALOG, function(model)
        PopupManager:push({class = ExchangeDetail, init_data = model})
        PopupManager:pop()
    end)

    --显示兑换详情弹窗
    qf.event:addEvent(ET.SHOW_EXCHANGESHORTAGE_DIALOG, function(model)
        PopupManager:push({class = ExchangeShortage, init_data = model})
        PopupManager:pop()
    end)

    qf.event:dispatchEvent(ET.GET_EXCHANGEMALL_INFO,{cb = function (isGetSuccess)
        if isGetSuccess then
            if isValid(self.exchangeView) then
                self.exchangeView:init() 
            end
        end
    end})

    qf.event:addEvent(ET.SHOW_EXCHANGEMALL_VIEW, function(model)
        local uid = PopupManager:push({class = ExchangeMallView, init_data = model})
        PopupManager:pop()
        self.exchangeView = PopupManager:getPopupWindowByUid(uid)
    end)

    qf.event:addEvent(ET.REMOVE_EXCHANGEMALL_VIEW, function(model)
        if isValid(self.exchangeView) then
            self.exchangeView:close()
        end
    end)
end

function ExchangeMallController:removeModuleEvent()
end

function ExchangeMallController:initView(parameters)
end

function ExchangeMallController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"exchange")
    ExchangeMallController.super.remove(self)
end

return ExchangeMallController