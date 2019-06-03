
local RewardController = class("RewardController",qf.controller)

RewardController.TAG = "RewardController"
local RewardView = import(".RewardView")

function RewardController:ctor(parameters)
    RewardController.super.ctor(self)
    
end

-- 这里注册与服务器相关的的事件，不销毁
function RewardController:initGlobalEvent()
    qf.event:addEvent(ET.NET_USER_TASKLIST_REQ,handler(self,function()
        GameNet:send({cmd = CMD.ALLACTIVITYTASK,
            callback = function(rsp)
                local rewardView = PopupManager:getPopupWindowByUid(self.rewardView)

                if #Cache.ActivityTaskInfo.rewardList ~= 0 then
                    if isValid(rewardView) then
                        rewardView:refreshListview()
                    end
                    return
                end
                if rsp.ret == 0 then
                    Cache.ActivityTaskInfo:updateInfo(rsp.model)
                    if isValid(rewardView) then
                        rewardView:refreshListview()
                    end
                end
        end})
    end))
    qf.event:addEvent(ET.NET_USER_TASKREWARD_REQ,handler(self,self.processTaskReward))
    qf.event:addEvent(ET.REWARD_SORT_CHECK,handler(self,self.rewardSortCheck))
    qf.event:addEvent(ET.SHOW_REWARD_VIEW, handler(self, self.showRewardView))
end

function RewardController:processTaskReward(paras)
    if paras == nil or paras.id == nil or paras.type == nil  then return end
    GameNet:send({cmd = CMD.TASKREWARD,txt=GameTxt.net002,body = {task_type = paras.type,task_id = paras.id},callback = function(rsp)
        if rsp.ret == 0 then
            MusicPlayer:playMyEffect("TASK_FINISH")
            loga("任务:"..pb.tostring(rsp.model))
            if rsp.model.reward_info:len() > 0 then
                local info = rsp.model.reward_info:get(1) --暂时一个任务里只有一种奖励
                if info.type == 1 then
                    qf.event:dispatchEvent(ET.GLOBAL_COIN_ANIMATION_SHOW,{number=1000})
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.task003,info.num),time = 2})
                elseif info.type == 2 then
                    qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {diamond_free = 0,diamond_num = 0,rewardInfo ={0,info.num}})
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.task003_1,info.num),time = 2})
                elseif info.type == 3 then 
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.task006_1,info.num),time = 2})
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.task001,time = 2})
                end
            end  
            Cache.ActivityTaskInfo:taskFinishChangeStatus({type = paras.type, id = paras.id})
            if paras.cb then paras.cb(true) end
        else
            if paras.cb then paras.cb(false) end
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = paras.time or 2})
        end
    end})
end

function RewardController:rewardSortCheck()
    local rewardView = PopupManager:getPopupWindowByUid(self.rewardView)

    if isValid(rewardView) then
        rewardView:rewardSortCheck()
    end
end

function RewardController:initGame()
	
end

function RewardController:initView(parameters)
end

function RewardController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"prize")
    RewardController.super.remove(self)
end

function RewardController:showRewardView(  )
    self.rewardView = PopupManager:push({class = RewardView, show_cb = function (  )
        qf.event:dispatchEvent(ET.NET_USER_TASKLIST_REQ)
    end})
    PopupManager:pop()
end


return RewardController