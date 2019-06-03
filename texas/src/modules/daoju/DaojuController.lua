
local DaojuController = class("DaojuController",qf.controller)

DaojuController.TAG = "DaojuController"
local daojuView = import(".DaojuView")

function DaojuController:ctor(parameters)
    DaojuController.super.ctor(self)
end


function DaojuController:initModuleEvent()
    qf.event:dispatchEvent(ET.GUAGUACARD_SITE_LIST)
end

function DaojuController:removeModuleEvent()
end
-- 这里注册与服务器相关的的事件，不销毁
function DaojuController:initGlobalEvent()
    qf.event:addEvent(ET.GET_DAOJU_LIST,function(paras)
            GameNet:send({ cmd = CMD.CMD_GET_DAOJU_LIST ,wait=true,txt=GameTxt.net002,
            callback= function(rsp)
                if rsp.ret ~= 0 then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                else   
                    if rsp.model ~= nil then 
                        Cache.daojuInfo:saveConfig(rsp.model)
                    end
                end

                local daojuView = PopupManager:getPopupWindowByUid(self.daojuView)

                if isValid(daojuView) then
                    daojuView:refreshListItem()
                end
            end})
    end)

    qf.event:addEvent(ET.SHOW_DAOJU_VIEW, handler(self, self.showDaojuView))
end

function DaojuController:initGame()
end

function DaojuController:initView(parameters)
end

function DaojuController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"daoju")
    DaojuController.super.remove(self)
end

function DaojuController:showDaojuView(  )
    self.daojuView = PopupManager:push({class = daojuView})
    PopupManager:pop()
end

return DaojuController