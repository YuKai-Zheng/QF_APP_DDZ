
local NewUserDailyReward = class("NewUserDailyReward", function(paras)
    return paras.superLayer
end)

NewUserDailyReward.TAG = "NewUserDailyReward"

function NewUserDailyReward:ctor(paras)
    self:init(paras)
end

function NewUserDailyReward:init(paras)
    local modelView = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.newUserDailyRewardJson)
    local popviewModel= modelView:getChildByName("pop")
    self.popview = popviewModel:clone()
    self:addChild(self.popview)

    self.timeRemain = ccui.Helper:seekWidgetByName(self.popview,"timeRemain")
    self.lord_hero = ccui.Helper:seekWidgetByName(self.popview,"lord_hero")

    self.focaTip = ccui.Helper:seekWidgetByName(self.popview,"focaTip")
    self.reward_btn = ccui.Helper:seekWidgetByName(self.popview,"reward_btn")
    self:setRewardData()

    addButtonEvent(self.focaTip, function( ... )
        qf.event:dispatchEvent(ET.EVENT_NEWUSER_LOGIN_REWARD_FOCATIPS) 
    end) 

    addButtonEvent(self.reward_btn,function( ... )
        if not Cache.user.dailyRewardConfInfo.currentObtained then 
           qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "今日已领取"}) 
           return
        end
        local body={}
        body.refer=UserActionPos.CUMULATELOGIN_REF
        body.reward_index = self.currentRewardDay
        GameNet:send({ cmd = CMD.CMD_GET_CUMULATE_LOGIN_REWARD,body=body,callback= function(rsp)
            if rsp.ret ~= 0 then
                --不成功提示
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            else 
                self:refreshRewardData()
                if Cache.Config.FinishActivityNum and Cache.Config.FinishActivityNum >0 then
                    Cache.Config.FinishActivityNum = Cache.Config.FinishActivityNum - 1
                    qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="activity",number = Cache.Config.FinishActivityNum or 0,
                    addNumber = 0})
                end
                self:obtainRewardSuccess(rsp.model)
            end


        end})
    end)
end

function NewUserDailyReward:obtainRewardSuccess(model)
    local rewardInfo = {}
    if model.reward_type == 1 then
        rewardInfo = {model.reward_nums,0}
    elseif model.reward_type == 2 then
        rewardInfo = {0,model.reward_nums}    
    end

    if model.reward_type < 3 then
        qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {diamond = model.reward_nums, free=0,buyGoodsType= model.reward_type,rewardInfo = rewardInfo, dismissCallBack = function ()
        end})
    elseif self.Config[paras.index].type == 3 then
        local daoju = model.reward_desc
        local daojuItemPic = GameRes.rememberCardImg
        qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {getRewardType = 2, rewardInfo = {"","","","","","","",daoju}, rewardInfoUrl = {"","","","","","","",daojuItemPic},dismissCallBack = function ()
        end})
    else
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.obtainRewardSuccess})
    end
end

function NewUserDailyReward:refreshRewardData()
    qf.event:dispatchEvent(ET.EVENT_NEWUSER_LOGIN_REWARD_GET,{cb = function ( ... )
        self:setRewardData()
    end})
end

function NewUserDailyReward:setRewardData()
    if not Cache.user.dailyRewardConfInfo or not Cache.user.dailyRewardConfInfo.new_user_reward then self:refreshRewardData() return end
    local rewardList = Cache.user.dailyRewardConfInfo.new_user_reward or {}
    self.currentRewardDay = 0 
    local retainDay = 0
    local totalLottery = 0
    local allActivityData = Cache.ActivityTaskInfo.rewardList.all_activity
    local activityData = null
    for i = 1 , #allActivityData do
        if allActivityData[i].id == 4 then
            activityData = allActivityData[i]
        end
    end

    self.timeRemain:setString(string.format("活动时间：%s - %s", activityData.begin_time, activityData.end_time))

    for i=1,#rewardList do
        local itemData = rewardList[i]
        local rewardItemStr = string.format("reward_%d", itemData.day_index)
        local itemReward = ccui.Helper:seekWidgetByName(self.popview,rewardItemStr)
        if itemReward then
            local content = itemReward:getChildByName("content")
            if itemData.reward_type == 1 then
                -- content:getChildByName("rewardType_img"):loadTexture(GameRes.newUserRewardType1)
                content:getChildByName("reward_title"):setString(string.format("金币 %d",itemData.amount))
            elseif itemData.reward_type == 2 then
                -- content:getChildByName("rewardType_img"):loadTexture(GameRes.newUserRewardType2)
                -- if itemData.day_index == 7 then
                -- content:getChildByName("rewardType_img"):loadTexture(GameRes.newUserRewardType4)
                -- end
                totalLottery = totalLottery + itemData.amount
                content:getChildByName("reward_title"):setString(string.format("奖券 %d",itemData.amount))
            elseif itemData.reward_type == 3 then
                -- content:getChildByName("rewardType_img"):loadTexture(GameRes.newUserRewardType3)
                content:getChildByName("reward_title"):setString(string.format("记牌器 %d",itemData.amount))
            end
  
            if itemData.obtainStatus == "1" then
                content:getChildByName("currentDay_tag"):setVisible(true)
                itemReward:getChildByName("mengban"):setVisible(false)
                self.currentRewardDay = itemData.day_index
            elseif itemData.obtainStatus == "2" then
                content:getChildByName("currentDay_tag"):setVisible(false)
                itemReward:getChildByName("mengban"):setVisible(true)
            elseif itemData.obtainStatus == "0"  then
                content:getChildByName("currentDay_tag"):setVisible(false)
                itemReward:getChildByName("mengban"):setVisible(false)
                retainDay = retainDay + 1
            end

            if itemData.day_index == 7 then
                self.lord_hero:getChildByName("hero_msg"):setString(string.format("登录7天共送%d奖券",totalLottery))

                local size = content:getSize()

                local armatureDataManager = ccs.ArmatureDataManager:getInstance()
                armatureDataManager:addArmatureFileInfo(GameRes.DAILY_REWARD_LIGHT_2)
                face = ccs.Armature:create("NewAnimation0102dlgx")
                face:setScale(1)

                face:setPosition(size.width/2,size.height/2)
                face:getAnimation():playWithIndex(0)

                content:addChild(face, 0)

                armatureDataManager:addArmatureFileInfo(GameRes.DAILY_REWARD_LIGHT_1)
                face1 = ccs.Armature:create("newUserAni1")
                face1:setScale(1)

                face1:setPosition(size.width/2,size.height/2)
                face1:getAnimation():playWithIndex(0)

                content:addChild(face1, 99)
            end
        end
    end

    if Cache.user.dailyRewardConfInfo.currentObtained then
        self.reward_btn:loadTextureNormal(GameRes.obtainRewardBtnImg)
    else
        self.reward_btn:loadTextureNormal(GameRes.obtainedBtnImg)
    end
end

function NewUserDailyReward:close() 
   self:removeFromParent()
end

return NewUserDailyReward
