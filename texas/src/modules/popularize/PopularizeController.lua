local PopularizeController = class("PopularizeController",qf.controller)

PopularizeController.TAG = "PopularizeController"
local popularizeView = import(".PopularizeView")

function PopularizeController:ctor(parameters)
    PopularizeController.super.ctor(self)
    
end


function PopularizeController:initModuleEvent()
    qf.event:addEvent(ET.TO_BE_PROMOTER_SUCCESS,function(paras)
        qf.event:dispatchEvent(ET.GET_PROMOTE_INFO)
    end)
end

function PopularizeController:removeModuleEvent()
    qf.event:removeEvent(ET.TO_BE_PROMOTER_SUCCESS)
end

-- 这里注册与服务器相关的的事件，不销毁
function PopularizeController:initGlobalEvent()
    qf.event:addEvent(ET.GET_PROMOTE_INFO,function(paras)
        GameNet:send({ cmd = CMD.GET_PROMOTE_REQ,callback= function(rsp)
            if rsp.ret ~= 0 then
            else 
                Cache.user:updatePromotInfo(rsp.model)
                if self.view ~= nil then
                    self.view:updateInfo()
                end
            end
        end})
    end)

    --充值推广员成功后的通知
    qf.event:addEvent(ET.GET_PROMOTE_NOTICE,function(rsp)
        if rsp.ret ~= 0 then
        else 
            Cache.user:updatePromotInfo(rsp.model)
            if self.view ~= nil then
                self.view:updateInfo()
            end
        end
    end)

    -- 成为推广员推送
    qf.event:addEvent(ET.TO_BE_PROMOTER,function(paras)
        if self.view ~= nil then
            Cache.user:updatePromotInfo(paras.model)
            self.view:updateInfo()
        end
    end)
end

function PopularizeController:wantRecharge()
    if ModuleManager:judegeIsInShop() then
        return 
    end
    if self.view == nil or self.view.webIsShowing ~= true then return end
    qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK,{name = "shop",delay = 0,cb = function() self.view:gotoShopCb() end})
    if self.view then 
        self.view:webviewExit()
    end
end

function PopularizeController:initGame()
	
end

function PopularizeController:initView(parameters)
    qf.event:dispatchEvent(ET.MODULE_SHOW,"popularize")
    self.cb = parameters.cb
    local view = popularizeView.new(parameters)
    return view
end

function PopularizeController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"popularize")
    PopularizeController.super.remove(self)
    PopupManager:removeAllPopup()
    if self.cb then self.cb() end
end

return PopularizeController