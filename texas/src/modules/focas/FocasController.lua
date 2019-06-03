
local FocasController = class("FocasController",qf.controller)

FocasController.TAG = "FocasController"
local FocasView = import(".FocasView")

local  FocasRecord = import(".components.FocasRecord")
local  FocasInfo = import(".components.FocasInfo")
local  ExchangeInfo = import(".components.ExchangeInfo")
local  FocasRule = import(".components.FocasRule")

function FocasController:ctor(parameters)
    FocasController.super.ctor(self)
end

-- 这里注册与服务器相关的的事件，不销毁
function FocasController:initGlobalEvent()

end

function FocasController:initView(parameters)
end

function FocasController:remove()
end

function FocasController:showFocasView()
    self.focasView = PopupManager:push({class = FocasView})
    PopupManager:pop()
end

function FocasController:showFocasRecordView()
    self.focasRecord = PopupManager:push({class = FocasRecord})
    PopupManager:pop()
end

function FocasController:showFocasInfoView(paras)
    self.focasInfo = PopupManager:push({class = FocasInfo, init_data = paras})
    PopupManager:pop()
end

function FocasController:updateFocasInfoView()
    local focasInfoView = PopupManager:getPopupWindowByUid(self.focasInfo)

    if isValid(focasInfoView) then
        focasInfoView:initDuobaoView()
    end
end

function FocasController:showExchangeInfoView(paras)
    self.exchangeInfo = PopupManager:push({class = ExchangeInfo, init_data = paras})
    PopupManager:pop()
end

function FocasController:updateExchangeInfoView()
    local exchangeInfoView = PopupManager:getPopupWindowByUid(self.exchangeInfo)

    if isValid(exchangeInfoView) then
        exchangeInfoView:initView()
    end
end

function FocasController:showFocasRuleView()
    self.focasRule = PopupManager:push({class = FocasRule})
    PopupManager:pop()
end

return FocasController