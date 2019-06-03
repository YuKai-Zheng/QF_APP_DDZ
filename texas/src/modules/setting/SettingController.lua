
local SettingController = class("SettingController",qf.controller)

SettingController.TAG = "SettingController"
local SettingView = import(".SettingView")

function SettingController:ctor(parameters)
    SettingController.super.ctor(self)
end


function SettingController:initModuleEvent()
end

function SettingController:removeModuleEvent()
    
end

-- 这里注册与服务器相关的的事件，不销毁
function SettingController:initGlobalEvent()
    qf.event:addEvent(ET.QUFAN_LOGIN_CHANGE_PASSWORD,function(paras)
        GameNet:send({cmd=CMD.EVENT_QUFAN_CHANGE_PASSWORD, 
        	body = {old_password = paras.old_password, new_password = paras.new_password}, callback=function(rsp)
            if rsp.ret == 0 then
                if paras.cb then paras.cb() end
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.qufan_login_string_15})
            else
            	qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            end
        end})
    end)

    qf.event:addEvent(ET.SHOW_SETTING_VIEW, handler(self, self.showSettingView))
end

function SettingController:initView(parameters)
    
end

function SettingController:showSettingView( paras )
    self.settingView = PopupManager:push({class = SettingView})
    PopupManager:pop()
end

return SettingController