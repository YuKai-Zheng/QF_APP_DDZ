local RewardView = class("RewardView", CommonWidget.BasicWindow)

local IButton = import(".components.IButton")

RewardView.TAG = "RewardView"
RewardView.LIST_ACTION_TAG = 1101

function RewardView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    RewardView.super.ctor(self,parameters)
    qf.platform:umengStatistics({umeng_key = "Task"})
end

function RewardView:init(parameters)
    Cache.ActivityTaskInfo:clearInfo()--清除掉奖励信息
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.rewardViewJson)
    self.choose_bg = self.gui:getChildByName("choose_bg")
    self.chooiceItem = 1
    self.item = self.gui:getChildByName("item")
    self.listview = self.gui:getChildByName("listview")
    self.listview:setItemModel(self.item)
    self.gui:getChildByName("bg"):setTouchEnabled(true)
    self.noMsgTipsBg = self.gui:getChildByName("nomsgTips")
    self.dayTips = self.noMsgTipsBg:getChildByName("daytips")
    self.allTips = self.noMsgTipsBg:getChildByName("alltips")
    self:refreshBtn() 
end

function RewardView:initClick(  )
    addButtonEvent(self.choose_bg:getChildByName("btn1"), function (  )
        self.chooiceItem = 1
        self:refreshBtn()
        self:refreshListview()
    end)

    addButtonEvent(self.choose_bg:getChildByName("btn2"), function (  )
        self.chooiceItem = 2
        self:refreshBtn()
        self:refreshListview()
    end)

    addButtonEvent(self.gui:getChildByName("back_btn"), function (  )
        self:close()
    end)
end

function RewardView:rewardSortCheck()
    self.chooiceItem = 1
    self:refreshBtn()
end

--[[刷新button显示]]
function RewardView:refreshBtn()
    for i = 1 , 2 do
        if i == self.chooiceItem then
            self.choose_bg:getChildByName("btn"..i):setOpacity(255)
        else
            self.choose_bg:getChildByName("btn"..i):setOpacity(0)
        end
    end
end

--[[刷新Listview]]
function RewardView:refreshListview()
    self:stopListDelayRun()
    self.boxItem = nil
    self.listview:removeAllChildren(true)
    if Cache.ActivityTaskInfo == nil then return end
    if self.chooiceItem == 1 then
        local j = 1
        if Cache.ActivityTaskInfo.rewardList.day_task_list == nil then 
            self.noMsgTipsBg:setVisible(true)
            self.dayTips:setVisible(true)
            self.allTips:setVisible(false)
            return 
        end
        self.noMsgTipsBg:setVisible(false)
        for i = 1 , #Cache.ActivityTaskInfo.rewardList.day_task_list do
            local info = Cache.ActivityTaskInfo.rewardList.day_task_list[i]
            j =  self:updateItem(info,i,j,1)
            if i == #Cache.ActivityTaskInfo.rewardList.day_task_list and j == #Cache.ActivityTaskInfo.rewardList.day_task_list +1 then
                self.noMsgTipsBg:setVisible(true)
                self.dayTips:setVisible(true)
                self.allTips:setVisible(false)
            end
        end
    elseif self.chooiceItem == 2 then
        local j = 1
        if Cache.ActivityTaskInfo.rewardList.sys_task_list == nil then 
            self.noMsgTipsBg:setVisible(true)
            self.dayTips:setVisible(true)
            self.allTips:setVisible(false)
            return 
        end
        self.noMsgTipsBg:setVisible(false)
        for i = 1 , #Cache.ActivityTaskInfo.rewardList.sys_task_list do
            local info = Cache.ActivityTaskInfo.rewardList.sys_task_list[i]
            dump(info)
            j = self:updateItem(info,i,j,2)
            if i == #Cache.ActivityTaskInfo.rewardList.sys_task_list and j == #Cache.ActivityTaskInfo.rewardList.sys_task_list +1 then
                self.noMsgTipsBg:setVisible(true)
                self.dayTips:setVisible(true)
                self.allTips:setVisible(false)
            end
        end
    end
end

function RewardView:refreshTaskBtn(btn,status)
    if btn == nil or status == nil then return end
    if status == 1 then
        btn:setTouchEnabled(true)
        btn:loadTexture(GameRes.reward_get_btn)
    elseif status == 0 then
        btn:setTouchEnabled(false)
        btn:loadTexture(GameRes.reward_goon_btn)
    elseif status == 2 then
        btn:setTouchEnabled(false)
        btn:loadTexture(GameRes.reward_have_btn)
    end
end

function RewardView:updateItem(info,i,j,index)
    local is_show_beauty=true 
    local is_show_gift = true --显示赠送礼物
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        if tonumber(info.id)== 9 then 
            is_show_beauty=false
        end
        if tonumber(info.id) == 4 then --赠送礼物
            is_show_gift = false
        end
    end
    if info.status ~= 2 and info.id ~= TIMEBOX_TASK_ID_STR and is_show_beauty and is_show_gift then	--时间宝箱、美女、赠送礼物过审时不显示
        self.listview:pushBackDefaultItem()
        local item = self.listview:getItem(i - j)
        item:setVisible(true)
        
        local btn = item:getChildByName("btn")

        progress = Util:getFormatString(info.progress)
        condition = Util:getFormatString(info.condition)

        item:getChildByName("progress"):setString(progress.."/"..condition)
        item:getChildByName("info"):setString(info.title)
        
        local rewardstr = "奖励"   
        ccui.Helper:seekWidgetByName(item,"tool_image"):setVisible(true)
        if info.rep_reward[1].type == 1 then
            ccui.Helper:seekWidgetByName(item,"tool_image"):loadTexture(GameRes["reward_type_1"])
            rewardstr = rewardstr..info.rep_reward[1].num.."金币"
        elseif info.rep_reward[1].type == 2 then
            ccui.Helper:seekWidgetByName(item,"tool_image"):loadTexture(GameRes["reward_type_2"])
            rewardstr = rewardstr..info.rep_reward[1].num.."奖券"
        elseif info.rep_reward[1].type == 3 then
            ccui.Helper:seekWidgetByName(item,"tool_image"):loadTexture(GameRes["reward_type_3"])
            rewardstr = rewardstr..info.rep_reward[1].num.."记牌器（局）"
        end

        item:getChildByName("reward"):setString(rewardstr)
        addButtonEvent(btn,function() 
             qf.event:dispatchEvent(ET.NET_USER_TASKREWARD_REQ,{id = info.id,gold = info.rep_reward[1].num,type = info.rep_reward[1].type,cb = function()
                if item and not tolua.isnull(item) then
                    item:removeFromParent(true)
                    if self.listview:getChildrenCount()<1 then 
                        if 2 == self.chooiceItem then
                            self.noMsgTipsBg:setVisible(true)
                            self.dayTips:setVisible(true)
                            self.allTips:setVisible(false)
                            Cache.ActivityTaskInfo.rewardList.sys_task_list = nil 
                        else
                            self.noMsgTipsBg:setVisible(true)
                            self.dayTips:setVisible(true)
                            self.allTips:setVisible(false)
                            Cache.ActivityTaskInfo.rewardList.day_task_list = nil 
                        end
                    end
                    qf.event:dispatchEvent(ET.GAME_BUY_ITEM_CHANGE,{})
                end
             end})
        end)
        self:refreshTaskBtn(btn,info.status)
        item:setVisible(true)
        -- Display:showScalePop({view = item})
    else j = j +1 end

    return j
end

function RewardView:listDelayRun(time,cb)
    self.gui:getChildByName("listview"):runAction(cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    ))
end

function RewardView:stopListDelayRun()
    self.gui:getChildByName("listview"):stopAllActions()
end

function RewardView:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    action:setTag(self.LIST_ACTION_TAG)
    self:runAction(action)
end

--[[获取父控件中table中的控件并存储到son  table中]]
function RewardView:getTableChild(keyTable,father,son)
    for key, v in pairs(keyTable) do
        son[v] = father:getChildByName(v)
    end
end

--[[下载图片]]
function RewardView:setHeadByUrl(view,url,count)
    if view == nil or url == nil then return end
    if Util:judgeHasHttpSuffex(RESOURCE_HOST_NAME,"http") then
        rurl = RESOURCE_HOST_NAME.."/"..url
    else
        url = HOST_PREFIX..RESOURCE_HOST_NAME.."/"..url
    end
    loga("RESOURCE_HOST_NAME=cnd资源加载RewardView:"..Util)
    view:removeAllChildren()
    --local path = CACHE_DIR.."reward_"..count


    local taskID = qf.downloader:execute(url, 10,
        function(path)
            if not tolua.isnull( self ) then
               self:downloadHeadSuccess(view,url,count,path)
            end
        end,
        function() 
        end,
        function() 
        end
    )
end


function RewardView:downloadHeadSuccess(view,url,count,path)
    if view == nil or url == nil then return end
    --local path = CACHE_DIR.."reward_"..count
    if io.exists(path) then
        return self:setHeadByImg(view,path)
    end
end
function RewardView:setHeadByImg(view,img)
    if view == nil or img == nil then return end
    view:loadTexture(img)
end

--[[下载图片end]]

return RewardView