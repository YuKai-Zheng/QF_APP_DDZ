
local ActivityController = class("ActivityController",qf.controller)

ActivityController.TAG = "ActivityController"
local ActivityView = import(".ActivityView")

function ActivityController:ctor(parameters)
    ActivityController.super.ctor(self)
    
end


function ActivityController:initModuleEvent()
    
end

function ActivityController:removeModuleEvent()
end

-- 这里注册与服务器相关的的事件，不销毁
function ActivityController:initGlobalEvent()
    qf.event:addEvent(ET.CLOSE_ACTIVE_VIEW,function(paras)
        local activityView = PopupManager:getPopupWindowByUid(self.activityView)
        if isValid(activityView) then
            activityView:close()
        end
    end)

    qf.event:addEvent(ET.SHOW_ACTIVE_VIEW, handler(self, self.showActivityView))
 
    --[[打开指定的活动]]
    qf.event:addEvent(ET.GOTO_ACTIVITY,function(paras)
        local activityView = PopupManager:getPopupWindowByUid(self.activityView)
        if isValid(activityView) then
            activityView:showWebView(paras.name,paras.ref)
            qf.platform:umengStatistics({umeng_key = paras.name})
        end
    end)

    --[[请求活动列表]]
    qf.event:addEvent(ET.NET_ALL_ACTIVITY_REQ,function(paras)
        GameNet:send({cmd = CMD.ALLACTIVITYTASK,
            callback = function(rsp)
                if rsp.ret == 0 then
                    Cache.ActivityTaskInfo:updateInfo(rsp.model)
                    local activityView = PopupManager:getPopupWindowByUid(self.activityView)
                    if isValid(activityView) then
                        activityView:insertActivity(rsp.model)
                    end

                    if paras and paras.cb then 
                        if rsp.model~=nil then 
                            paras.cb(rsp.model)
                        end
                    end
                end
                --logd("ACTIVITY_LIST rsp ="..rsp.ret..pb.tostring(rsp.model),self.TAG)
            end})
    end
    )
    qf.event:addEvent(ET.GAME_WANT_RECHARGE,handler(self,self.wantRecharge))
    qf.event:addEvent(ET.ACTIVITY_HIDE_WEBVIEW, function ( ... )
        local activityView = PopupManager:getPopupWindowByUid(self.activityView)
        if isValid(activityView) then
            activityView:webviewExit()
        end
    end)
end

function ActivityController:wantRecharge()
    local activityView = PopupManager:getPopupWindowByUid(self.activityView)
    if not isValid(activityView) or activityView.webIsShowing ~= true then return end

    qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK,{name = "shop",delay = 0,cb = function() activityView:gotoShopCb() end})

    if isValid(activityView) then 
        activityView:webviewExit()
    end
end

function ActivityController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"activity")
    ActivityController.super.remove(self)
end

function ActivityController:showActivityView( paras )
    self.activityView = PopupManager:push({class = ActivityView, init_data = paras, show_cb = function (  )
        qf.event:dispatchEvent(ET.NET_ALL_ACTIVITY_REQ) --活动列表
	    qf.event:dispatchEvent(ET.EVENT_NEWUSER_LOGIN_REWARD_GET) 
    end})
    PopupManager:pop()
end

return ActivityController