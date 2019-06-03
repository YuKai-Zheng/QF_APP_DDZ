
local MatchingController = class("MatchingController",qf.controller)

MatchingController.TAG = "MatchingController"
local MatchingView = import(".MatchingView")

function MatchingController:ctor(parameters)
    MatchingController.super.ctor(self)
end

function MatchingController:initModuleEvent()
    --更新金币
    qf.event:addEvent(ET.GOLD_CHANGE_RSP,function( ... )
        self.view:updateUserInfo()
    end)
    --奖券变化通知
    qf.event:addEvent(ET.EVT_USER_FOCARD_CHANGE_MATCHING,function(rsp)
        loga("奖券变化通知EVT_USER_FOCARD_CHANGE_MATCHING:"..pb.tostring(rsp.model))
        if rsp.model and rsp.model.remain_amount then 
            Cache.user.fucard_num = rsp.model.remain_amount
        end
        if self.view then
            self.view:updateUserInfo()
        end
    end)

    qf.event:addEvent(ET.SHOW_START_MATCHING,function(rsp)
        if isValid(self.view) then
            self.view:clickStartAction()
        end
    end)
    
end

function MatchingController:removeModuleEvent()
    qf.event:removeEvent(ET.EVT_USER_FOCARD_CHANGE_MATCHING)
    qf.event:removeEvent(ET.GOLD_CHANGE_RSP)
    qf.event:removeEvent(ET.SHOW_START_MATCHING)
end

-- 这里注册与服务器相关的的事件，不销毁
function MatchingController:initGlobalEvent()
    --更新或显示比赛场大厅界面
    qf.event:addEvent(ET.MATCH_VIEW_UPDATE,function(paras)
        GameNet:send({cmd=CMD.MATCH_HALL_INFO,callback=function(rsp)
            if rsp.ret==0 then
                Cache.Config:updateMatchHallInfo(rsp.model)
                if self.view then
                    self.view:updateView()
                else
                    self:show()
                end
                if paras.cb then
                    paras.cb()
                end
            end
        end})
    end)
end

function MatchingController:initView(parameters)
    qf.event:dispatchEvent(ET.MODULE_SHOW,"matching")
    local view = MatchingView.new()
    return view
end

function MatchingController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"matching")
    MatchingController.super.remove(self)
    PopupManager:removeAllPopup()

end
return MatchingController