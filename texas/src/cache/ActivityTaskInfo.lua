local ActivityTaskInfo = class("ActivityTaskInfo")

ActivityTaskInfo.TAG = "Reward"
ActivityTaskInfo.BONUS_ID_1 = 17  --春节红包活动ID
ActivityTaskInfo.BONUS_ID_2 = 18  --春节红包活动ID

--测试用
--ActivityTaskInfo.BONUS_ID_1 = 7  --春节红包活动ID
--ActivityTaskInfo.BONUS_ID_2 = 9  --春节红包活动ID

ActivityTaskInfo.number = 0 --未领取任务奖励的任务个数
ActivityTaskInfo.rewardList = {} --成就奖励

function ActivityTaskInfo:updateInfo(model)

   --  local wanYuanCompeticion = {
   --      activity_Type = 1,
   --      condition     = 5,
   --      desc          = "达到指定头衔，可获得奖券",
   --      fucard        = 1,
   --      gold          = 0,
   --      id            = "11",
   --      image_url     = "static/task_image/sys_task_image.png",
   --      progress      = 5,
   --      reward_type   = 0,
   --      status        = 1,
   --      status_id     = 0,
   --      task_type     = "sys",
   --      title        = "万元争霸赛"
   -- }

    local filedname = {
        "status",
        "desc",
        "id",
        "gold",
        "title",
        "condition",
        "image_url",
        "progress",
        "task_type",
        "fucard",
        "status_id",
        "reward_type",
        "rep_reward"
    }
    self.number = 0
    local day_num = 0
    local sys_num = 0
    self.rewardList.day_task_list = {}
    self.rewardList.sys_task_list = {}
    self.rewardList.foca_task_list = {}
    -- table.insert(self.rewardList.foca_task_list, wanYuanCompeticion)
    for i = 1 ,model.day_task_list:len() do
        self.rewardList.day_task_list[i] = {}
        self:copyFiled(filedname,model.day_task_list:get(i),self.rewardList.day_task_list[i])
        self.rewardList.day_task_list[i].activity_Type = 1

        self.rewardList.day_task_list[i].rep_reward = {}

        for j = 1, model.day_task_list:get(i).rep_reward:len() do
            local rep_reward = {}
            self:copyFiled({"num", "type"}, model.day_task_list:get(i).rep_reward:get(j), rep_reward)

            table.insert( self.rewardList.day_task_list[i].rep_reward, rep_reward )
        end

        if model.day_task_list:get(i).status == 1 then
            self.number = self.number + 1 
            day_num = day_num + 1
        end
        self.rewardList.day_task_list[i].activity_PBClass = "TaskInfo"
        if self.rewardList.day_task_list[i].reward_type == 1 or self.rewardList.day_task_list[i].reward_type == 2 then
            table.insert(self.rewardList.foca_task_list, self.rewardList.day_task_list[i])
        end
        logd("日常任务["..self.rewardList.day_task_list[i].id.."] "..self.rewardList.day_task_list[i].title..", status="..self.rewardList.day_task_list[i].status..", progress="..self.rewardList.day_task_list[i].progress, "TimeBox")
    end
    for i = 1 ,model.sys_task_list:len() do
        self.rewardList.sys_task_list[i] = {}
        self:copyFiled(filedname,model.sys_task_list:get(i),self.rewardList.sys_task_list[i])
        self.rewardList.sys_task_list[i].activity_Type = 1
        if model.sys_task_list:get(i).status == 1 then 
            --self.number = self.number + 1 
            sys_num = sys_num + 1 
        end
        self.rewardList.sys_task_list[i].activity_PBClass = "TaskInfo"
        if self.rewardList.sys_task_list[i].reward_type == 1 or self.rewardList.sys_task_list[i].reward_type == 2 then
            table.insert(self.rewardList.foca_task_list, self.rewardList.sys_task_list[i])
        end
    end
    qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="prize",number=self.number})
    day_num = day_num + (isover == true and 1 or 0)
    if day_num == 0 and sys_num >0 then
        qf.event:dispatchEvent(ET.REWARD_SORT_CHECK)
    end
    local items = {"id",
		          "title",
		          "content",
		          "image_url",
		          "page_url", 
		          "end_time",
		          "reward_id",
		          "can_pick",
		          "show_board",
		          "board_url", 
		          "board_type",
		          "only_pop",
		          "activity_type",
                  "reward_type",
                  "begin_time"
                }
    self.rewardList.all_activity = {}
    local index = 1
	if model ~= nil and model.activities then 
		for i = 1, model.activities:len() do
	        local item = {}
	        local data = model.activities:get(i)
	        for k,v in pairs(items) do
	            item[v] = data[v]
	        end
	        item.activity_PBClass = "ActivityInfo"
            if item.id == 4 and Cache.user.show_cumulate_login_or_not ~= 0 then --过滤新手礼包的内容
            else
	           self.rewardList.all_activity[index] = item
               index = index + 1
               if item.reward_type == 1 or item.reward_type == 2 then
                    table.insert(self.rewardList.foca_task_list, item)
                end
            end
	    end
	end
        
    if model.board_url then
	    self.rewardList.board_url = model.board_url
	end
end

function ActivityTaskInfo:taskFinishChangeStatus(paras)
    if paras == nil or paras.id == nil or paras.type == nil then return end 
    Cache.ActivityTaskInfo.number = Cache.ActivityTaskInfo.number == 0 and 0 or Cache.ActivityTaskInfo.number - 1
    qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="prize",number=Cache.ActivityTaskInfo.number})
    if paras.type == "other" then return end
    if paras.type == "day" then
        if self.rewardList.day_task_list then
            for i = 1, #self.rewardList.day_task_list do
                if self.rewardList.day_task_list[i].id == paras.id then
                    self.rewardList.day_task_list[i].status = 2
                end
            end
        end
    elseif paras.type == "sys" then
        if self.rewardList.sys_task_list then
            for i = 1, #self.rewardList.sys_task_list do
                if self.rewardList.sys_task_list[i].id == paras.id then
                    self.rewardList.sys_task_list[i].status = 2
                end
            end
        end
    end
end

function ActivityTaskInfo:clearInfo()
    self.rewardList = {}
end

function ActivityTaskInfo:copyFiled(p,s,d)
    for k,v in pairs(p) do
        d[v] = s[v]
    end
end

--获取春节红包活动的URL
function ActivityTaskInfo:getBonusUrl()
    if self.rewardList.all_activity == nil then return nil end
    local url = nil
    for k, v in pairs(self.rewardList.all_activity) do
        if v.id == self.BONUS_ID_1 or v.id == self.BONUS_ID_2 then
            url = v.page_url
        end
    end
    return url
end

return ActivityTaskInfo