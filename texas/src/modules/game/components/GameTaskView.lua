local M = class("GameTaskView", CommonWidget.BasicWindow)

function M:ctor(paras)
    self.richElements = {}
    self.roomConfig = Cache.DDZconfig:getRoomConfigByType(GAME_DDZ_CLASSIC)
    M.super.ctor(self, paras)
end

function M:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.gameTaskViewJson)

    self.btn_close = ccui.Helper:seekWidgetByName(self.gui,"btn_close")
    self.img_btns_bottom = ccui.Helper:seekWidgetByName(self.gui, "img_btns_bottom")

    self.panel = ccui.Helper:seekWidgetByName(self.gui, "panel")
    self.progressBar_bg = ccui.Helper:seekWidgetByName(self.gui, "progressBar_bg")
    self.progressBar = ccui.Helper:seekWidgetByName(self.gui, "progressBar")
    self.txt_progress = ccui.Helper:seekWidgetByName(self.gui, "txt_progress")
    self.txt_reward_tip = ccui.Helper:seekWidgetByName(self.gui, "txt_reward_tip") --用于定位，具体文案使用richText
    self.txt_reward_tip:setPositionX(self.progressBar_bg:getPositionX())
end

function M:updateData(isNeedJump)
    self.data = Cache.Config:getGameTaskInfo()

    self.room_id = Cache.DDZDesk.room_id
    if not self.room_id then
        self.room_id = self.data[1].room_id
    end

    if isNeedJump then
        self.page = self.page or 1
        for i = 1, #self.data do
            if self.room_id == self.data[i].room_id then
                self.page = i
            end
        end

        self:changeBtn(self.page)
    else
        self:initPanel()
    end
end

function M:initClick()
    addButtonEvent(self.btn_close, function (  )
        self:close()
    end)

    addButtonEvent(self.gui, function (  )
    end)

    
    for i = 1, 4 do
        self["btn_" .. i] = self.img_btns_bottom:getChildByName("btn_" .. i)
        self["btn_" .. i].img = self["btn_" .. i]:getChildByName("img")
        self["btn_" .. i].index = i
        addButtonEvent(self["btn_" .. i], function (sender)
            self:changeBtn(sender.index)
        end)

        if #(self.roomConfig) < 4 then
            if i > #(self.roomConfig) then
                self["btn_" .. i]:setVisible(false)
            else
                self["btn_" .. i]:setContentSize(1523/#(self.roomConfig), 82)
                self["btn_" .. i]:setPositionX(1523/#(self.roomConfig)*(i-1) + self["btn_" .. i]:getContentSize().width/2)
                self["btn_" .. i].img:setPositionX(self["btn_" .. i]:getContentSize().width/2)
            end
        end
    end
end

function M:changeBtn( index )
    for i = 1, #(self.roomConfig) do
        if i == index then
            self["btn_" .. i]:setTouchEnabled(false)
            self["btn_" .. i]:setBright(false)
            self["btn_" .. i].img:loadTexture(string.format(GameRes.gameTask_btn_txt, i, 1))
        else
            self["btn_" .. i]:setTouchEnabled(true)
            self["btn_" .. i]:setBright(true)
            self["btn_" .. i].img:loadTexture(string.format(GameRes.gameTask_btn_txt, i, 2))
        end
    end
    self.page = index
    self:initPanel()
end

function M:initPanel()
    local data = self.data[self.page]

    local isProceed = false --是否有任务进行
    local isReward = false --是否有奖励未领取
    for i = 1, 4 do
        local item = self.panel:getChildByName("item_" .. i)
        local itemData = data.task_list[i]

        if itemData then
            item:setVisible(true)

            local img_light = item:getChildByName("img_light")  --可领取状态
            local img_item = item:getChildByName("img_item")    --奖励物品图
            local txt_reward = item:getChildByName("txt_reward")    --奖励数值
            local btn_reward = item:getChildByName("btn_reward")    --领取按钮
            local img_mask = item:getChildByName("img_mask")        --遮罩蒙层
            local img_desc_bg = item:getChildByName("img_desc_bg")
            local txt_desc = img_desc_bg:getChildByName("txt")      --领取完描述
            
            if itemData.status == 1 then
                img_light:setVisible(false)
                btn_reward:setVisible(false)
                img_mask:setVisible(false)
                img_desc_bg:setVisible(true)
                txt_desc:setString(string.format( GameTxt.gameTask_rewad_tip,itemData.condition ))
            elseif itemData.status == 2 then
                img_light:setVisible(true)
                btn_reward:setVisible(true)
                img_mask:setVisible(false)
                img_desc_bg:setVisible(false)
                isReward = true
            else
                img_light:setVisible(false)
                btn_reward:setVisible(false)
                img_mask:setVisible(true)
                img_desc_bg:setVisible(true)
                txt_desc:setString(GameTxt.gameTask_is_reward )
            end

            --暂时不支持多个奖励
            local reward = itemData.reward_list[1]
            txt_reward:setString(string.format( GameTxt.gameTask_reward_txt[reward.reward_type] or "",reward.reward_nums ))
            if reward.lottery_ticket_desc and reward.lottery_ticket_desc ~= "" then
                txt_reward:setString(reward.lottery_ticket_desc)
            end
            local image = reward.reward_type == 1 and GameRes.gameTask_img_gold or GameRes.gameTask_img_redpack
            img_item:loadTexture(string.format( image,reward.img_index ))

            if not isProceed and itemData.status == 1 then
                if i == 4 then
                    item:loadTexture(string.format(GameRes.gameTask_img_panel_choose, 2 ))
                else
                    item:loadTexture(string.format(GameRes.gameTask_img_panel_choose, 1 ))
                end
                isProceed = true

                self:initProgressBar(1, itemData)
            else
                if i == 4 then
                    item:loadTexture(string.format(GameRes.gameTask_img_panel, 2 ))
                else
                    item:loadTexture(string.format(GameRes.gameTask_img_panel, 1 ))
                end
            end

            addButtonEvent(btn_reward, function ( sender )
                GameNet:send({
                    cmd = CMD.GAME_TASK_REWARD_REQ,
                    body = {task_id = itemData.id},
                    callback = function ( rsp )
                        if rsp.ret ~= 0 then
                            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                        else
                            qf.event:dispatchEvent(ET.GAME_TASK_CHANGE_NTF,rsp)

                            if rsp.model.reward_type and rsp.model.reward_nums then
                                if rsp.model.reward_type == 2 then
                                    qf.event:dispatchEvent(ET.SHOW_RED_PACKAGE, {isOpen = true, num = rsp.model.reward_nums})
                                    return
                                end
                            end
                            local rewardInfo = {0, 0}
                            rewardInfo[reward.reward_type] = reward.reward_nums
                            qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, { rewardInfo = rewardInfo})
                        end
                    end
                })
            end)
        else
            item:setVisible(false)
        end
    end

    if not isProceed then
        if isReward then
            self:initProgressBar(2, data.task_list[#data.task_list])
        else
            self:initProgressBar(3, data.task_list[#data.task_list])
        end
    end
end

--type: 1.存在未完成任务
--      2.任务全部完成，但未领取刷新
--      3.今日任务全部完成
function M:initProgressBar(type, data)
    self.txt_progress:setString(data.progress .. "/" .. data.condition)
    self.progressBar:setPercent(data.progress / data.condition * 100)

    self.txt_reward_tip:removeAllChildren()

    local isCorrectPage = self.data[self.page].room_id == self.room_id
    
    if type == 1 then
        self.txt_reward_tip:setString("")
        local txt_1 = cc.Label:createWithSystemFont(GameTxt.gameTask_tips[ isCorrectPage and 1 or 2 ][1], GameRes.font1, 40)
        local txt_2 = cc.Label:createWithSystemFont(data.condition - data.progress, GameRes.font1, 40)
        local txt_3 = cc.Label:createWithSystemFont(GameTxt.gameTask_tips[ isCorrectPage and 1 or 2 ][2], GameRes.font1, 40)

        txt_1:setColor(cc.c3b(255, 255, 255))
        txt_2:setColor(cc.c3b(255,243,133))
        txt_3:setColor(cc.c3b(255, 255, 255))

        local allWidth = txt_1:getContentSize().width + txt_2:getContentSize().width + txt_3:getContentSize().width

        local x1 = -allWidth / 2 + txt_1:getContentSize().width / 2
        local x2 = -allWidth / 2 + txt_1:getContentSize().width + txt_2:getContentSize().width / 2
        local x3 = -allWidth / 2 + txt_1:getContentSize().width + txt_2:getContentSize().width + txt_3:getContentSize().width / 2

        txt_1:setPositionX(x1)
        txt_2:setPositionX(x2)
        txt_3:setPositionX(x3)

        self.txt_reward_tip:addChild(txt_1)
        self.txt_reward_tip:addChild(txt_2)
        self.txt_reward_tip:addChild(txt_3)
    elseif type == 2 then
        self.txt_reward_tip:setString(GameTxt.gameTask_tips[3])
    elseif type == 3 then
        self.txt_reward_tip:setString(GameTxt.gameTask_tips[4])
    end

end

return M