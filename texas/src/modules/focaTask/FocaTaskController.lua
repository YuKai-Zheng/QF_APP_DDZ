
local FocaTaskController = class("FocaTaskController",qf.controller)

FocaTaskController.TAG = "FocaTaskController"
local FocaTaskView = import(".FocaTaskView")

function FocaTaskController:ctor(parameters)
    FocaTaskController.super.ctor(self)
    
end

-- 这里注册与服务器相关的的事件，不销毁
function FocaTaskController:initGlobalEvent()
    qf.event:addEvent(ET.NET_USER_ACTIVITY_TASKLIST_REQ,handler(self,function()
        GameNet:send({cmd = CMD.ALLACTIVITYTASK,
            callback = function(rsp)
                local focasTaskView = PopupManager:getPopupWindowByUid(self.focasTaskView)
                if #Cache.ActivityTaskInfo.rewardList ~= 0 then
                    if isValid(focasTaskView) then
                        focasTaskView:refreshListview()
                    end
                    return
                end
                if rsp.ret == 0 then
                    Cache.ActivityTaskInfo:updateInfo(rsp.model)
                    if isValid(focasTaskView) then
                        focasTaskView:refreshListview()
                    end
                end
        end})
    end))

    qf.event:addEvent(ET.SHOW_FOCASTASK_VIEW, handler(self, self.showFocasTaskView))
end


function FocaTaskController:initGame()
	
end

function FocaTaskController:initView(parameters)
end

function FocaTaskController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"focaTask")
    FocaTaskController.super.remove(self)
end

function FocaTaskController:showFocasTaskView(  )
    self.focasTaskView = PopupManager:push({class = FocaTaskView, show_cb = function (  )
        qf.event:dispatchEvent(ET.NET_USER_ACTIVITY_TASKLIST_REQ)
    end})
    PopupManager:pop()
end


return FocaTaskController