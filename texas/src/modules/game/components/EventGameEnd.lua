local M = class("EventGameEnd", CommonWidget.BasicWindow)

local MatchAnimationNode = import(".animation.MatchAnimationNode")
local GameEndBoxView = import(".GameEndBoxView")
local InviteView = import("src.modules.share.components.Invite")

M.ALWAYS_SHOW = true

function M:ctor( paras )
    self.winSize = cc.Director:getInstance():getWinSize()
    self.isSaveStar = true

    M.super.ctor(self, paras)

    local layerColor = cc.LayerColor:create(cc.c4b(0x00, 0x00, 0x00, 0x7d), self.winSize.width, self.winSize.height)
    self:addChild(layerColor, -1)
end

function M:initUI(  )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(DDZ_Res.eventGameEndViewJson)

    self.panel = ccui.Helper:seekWidgetByName(self.gui, "panel")
    self.animation_node = ccui.Helper:seekWidgetByName(self.gui, "animation_node")
    self.img_bg = ccui.Helper:seekWidgetByName(self.gui, "img_bg")  --输赢背景
    self.img_head_bg = ccui.Helper:seekWidgetByName(self.gui, "img_head_bg")
    self.img_head = ccui.Helper:seekWidgetByName(self.gui, "img_head")

    self.my_lord_icon = ccui.Helper:seekWidgetByName(self.gui, "my_lord_icon")

    self.img_txt_result = ccui.Helper:seekWidgetByName(self.gui, "img_txt_result")  --输赢提醒语
    self.txt_ticketreward = ccui.Helper:seekWidgetByName(self.gui, "txt_ticketreward")
    self.img_ticket_icon = ccui.Helper:seekWidgetByName(self.gui, "img_ticket_icon")

    self.txt_ticketreward.orginWidth = self.txt_ticketreward:getContentSize().width

    self.panel_self_reward = ccui.Helper:seekWidgetByName(self.gui, "panel_self_reward")
    self.panel_other_reward = ccui.Helper:seekWidgetByName(self.gui, "panel_other_reward")

    self.txt_name = self.panel_other_reward:getChildByName("txt_name")
    self.txt_level = self.panel_other_reward:getChildByName("txt_level")
    self.txt_base_reward = self.panel_other_reward:getChildByName("txt_base_reward")
    self.txt_level_reward = self.panel_other_reward:getChildByName("txt_level_reward")
    self.txt_lord_reward = self.panel_other_reward:getChildByName("txt_lord_reward")

    self.btn_1 = ccui.Helper:seekWidgetByName(self.gui, "btn_1")
    self.btn_2 = ccui.Helper:seekWidgetByName(self.gui, "btn_2")
    self.btn_3 = ccui.Helper:seekWidgetByName(self.gui, "btn_3")

    self.btn_giveUp = ccui.Helper:seekWidgetByName(self.gui, "btn_giveUp")
    self.btn_savestar = ccui.Helper:seekWidgetByName(self.gui, "btn_savestar")

    self.btn_return = ccui.Helper:seekWidgetByName(self.gui, "btn_return")
    self.btn_return:setVisible(false)

    self.img_dialog = ccui.Helper:seekWidgetByName(self.btn_savestar, "img_dialog")
    self.img_dialog_txt = self.img_dialog:getChildByName("txt")
    self.img_savestar_icon = self.btn_savestar:getChildByName("img_savestar_icon")
    self.txt_savestar_count = self.btn_savestar:getChildByName("txt_count")

    local ResList = Cache.DDZDesk.mine_is_win and DDZ_Res.match_result_win or DDZ_Res.match_result_fail

    self.img_bg:loadTexture(ResList.BG)
    self.img_txt_result:loadTexture(ResList.TIP)
    self.img_head_bg:loadTexture(ResList.HEAD_BG)

    self.txt_name:setFntFile(ResList.FNT)
    self.txt_level:setFntFile(ResList.FNT)
    self.txt_base_reward:setFntFile(ResList.FNT)
    self.txt_level_reward:setFntFile(ResList.FNT)
    self.txt_lord_reward:setFntFile(ResList.FNT)

    self:initSelfRewardPanel()
    self:initOtherRewardPanel()

    self.matchIcon = MatchAnimationNode.new()
    self.gui:addChild(self.matchIcon, 100)
    self.matchIcon:setPosition(cc.p(self.winSize.width / 2, self.animation_node:getPositionY()))

    self.panel:setVisible(false)
end

function M:initSelfRewardPanel(  )
    local selfData = Cache.DDZDesk.matchSettles[Cache.user.uin] or {}

    Util:updateUserHead(self.img_head, Cache.user.portrait,  Cache.user.sex, {add = true,url = true})

    local txt_base_reward = self.panel_self_reward:getChildByName("txt_base_reward")
    local txt_level_reward = self.panel_self_reward:getChildByName("txt_level_reward")
    local txt_lord_reward = self.panel_self_reward:getChildByName("txt_lord_reward")

    txt_base_reward:setString(DDZ_TXT.match_result_txt[1] .. selfData.reward_base)
    txt_level_reward:setString(DDZ_TXT.match_result_txt[2] .. selfData.reward_lv_up)
    txt_lord_reward:setString(DDZ_TXT.match_result_txt[3] .. selfData.reward_landlord)

    self.txt_ticketreward:setString(DDZ_TXT.match_result_txt[4] .. (selfData.reward_base + selfData.reward_lv_up + selfData.reward_landlord))

    if Cache.DDZDesk.landlord_uin == Cache.user.uin then
        self.my_lord_icon:setVisible(true)
    else
        self.my_lord_icon:setVisible(false)
    end

    if Cache.DDZDesk.mine_is_win then
        self.btn_1:setVisible(true)
        self.btn_2:setVisible(true)
        self.btn_3:setVisible(false)
    else
        self.btn_1:setVisible(false)
        self.btn_2:setVisible(false)
        self.btn_3:setVisible(true)

        if selfData.star_protect_remain_count and selfData.star_protect_remain_count > 0 then
            self.isSaveStar = false
            self.img_dialog_txt:setString(string.format( DDZ_TXT.match_result_savestar_txt, selfData.star_protect_remain_count))
            self.txt_savestar_count:setString(selfData.star_protect_card_dia)
        else
            self.isSaveStar = true
        end
    end

    self.img_ticket_icon:setPositionX(self.img_ticket_icon:getPositionX() + (self.txt_ticketreward:getContentSize().width - self.txt_ticketreward.orginWidth))
end

function M:initOtherRewardPanel(  )
    local data = Cache.DDZDesk.matchSettles or {}

    local index = 1
    for k,v in pairs(data) do
        if v.uin == Cache.user.uin then
        else
            local txt_name = self.panel_other_reward:getChildByName("txt_name_" .. index)
            local txt_level = self.panel_other_reward:getChildByName("txt_level_" .. index)
            local txt_base_reward = self.panel_other_reward:getChildByName("txt_base_reward_" .. index)
            local txt_level_reward = self.panel_other_reward:getChildByName("txt_level_reward_" .. index)
            local txt_lord_reward = self.panel_other_reward:getChildByName("txt_lord_reward_" .. index)
            local lord_icon = self.panel_other_reward:getChildByName("lord_icon_" .. index)
    
            local nick = Util:filterEmoji(v.nick) or ""
            txt_name:setString(Util:getCharsByNum(Util:filter_spec_chars(nick),12))
            local levelNum = Util:getLevelNum(v.all_lv_info_now.sub_lv)
            txt_level:setString(Util:getMatchLevelTxt(v.all_lv_info_now))
            txt_base_reward:setString("+" .. v.reward_base)
            txt_level_reward:setString("+" .. v.reward_lv_up)
            txt_lord_reward:setString("+" .. v.reward_landlord)
    
            if v.uin == Cache.DDZDesk.landlord_uin then
                lord_icon:setVisible(true)
            else
                lord_icon:setVisible(false)
            end
    
            index = index + 1
        end
        
    end
end

function M:initClick(  )
    local selfData = Cache.DDZDesk.matchSettles[Cache.user.uin] or {}
    addButtonEvent(self.btn_1, function (  )
        Cache.user.shareFlag = false
        PopupManager:push({class = InviteView, init_data = {
            type = 1,
            fileName = Cache.user.uin  .. "_" .. Cache.user.all_lv_info.match_lv .. "game_result.jpg",
            shareType = 3
        }})
        PopupManager:pop()
    end)

    addButtonEvent(self.btn_2, function (  )
        self:close()
        if selfData.is_season_settle == 1 then
            Cache.DDZDesk.startAgain = nil
            qf.event:dispatchEvent(ET.RE_QUIT)
        else
            if ModuleManager:get("game") then
                ModuleManager:get("game"):getView():clearDesk()
            end
            Cache.DDZDesk.startAgain = true
            qf.event:dispatchEvent(ET.RE_QUIT,{startMatch = true})
            qf.platform:uploadEventStat({
                module = "eventgameover",
                source = "pywxddz",
                event = STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_CONTINUE_PLAY_BIN,
                custom = {
                    scene = GameConstants.ShareScene.GAME,
                }
            })
        end
    end)

    addButtonEvent(self.btn_3, function (  )
        self:close()
        if selfData.is_season_settle == 1 then
            Cache.DDZDesk.startAgain = nil
            qf.event:dispatchEvent(ET.RE_QUIT)
        else
            if ModuleManager:get("game") then
                ModuleManager:get("game"):getView():clearDesk()
            end
            Cache.DDZDesk.startAgain = true
            qf.event:dispatchEvent(ET.RE_QUIT,{startMatch = true})
            qf.platform:uploadEventStat({
                module = "eventgameover",
                source = "pywxddz",
                event = STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_CONTINUE_PLAY_BIN,
                custom = {
                    scene = GameConstants.ShareScene.GAME,
                }
            })
        end
    end)

    addButtonEvent(self.btn_giveUp, function (  )
        self.btn_giveUp:setVisible(false)
        self.btn_savestar:setVisible(false)
        self:showDetailView()
        qf.platform:uploadEventStat({
            module = "eventgameover",
            source = "pywxddz",
            event = STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_GIVEUP_BTN,
            custom = {
                scene = GameConstants.ShareScene.GAME,
            }
        })
    end)

    addButtonEvent(self.btn_savestar, function (  )
        self:saveStarReq()
    end)

    addButtonEvent(self.btn_return, function (  )
        local reward_num = selfData.next_reward_base or 0
        qf.event:dispatchEvent(ET.SHOW_GAME_EXIT_VIEW, {
            content=string.format(GameTxt.gameExit_event, reward_num),
            confirmCb=function()
                self:close()
                Cache.DDZDesk.startAgain = nil
                qf.event:dispatchEvent(ET.RE_QUIT)
                qf.platform:uploadEventStat({
                    module = "eventgameover",
                    source = "pywxddz",
                    event = STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_RETURN_BTN,
                    custom = {
                        scene = GameConstants.ShareScene.GAME,
                    }
                })
            end
        })
    end)
end

function M:initAnimation(  )
    loga("eventgameEnd   initAnimation")
    local data = Cache.DDZDesk.matchSettles[Cache.user.uin]

    local paras = {
        cb = function (  )
            if isValid(self) then
                if self.isSaveStar then
                    self:showDetailView()
                else
                    self.btn_giveUp:setVisible(true)
                    self.btn_savestar:setVisible(true)
                end
            end
        end,
        all_lv_info_now = data.all_lv_info_now,
        all_lv_info_bef = data.all_lv_info_bef
    }

    self.matchIcon:startAnimation(paras)
end

function M:saveStarReq(  )
    GameNet:send({
        cmd = CMD.NEWEVENT_SAVESTAR_REQ,
        body = {},
        callback = function ( rsp )
            if rsp.ret == 0 then
                local model = rsp.model
                self.isSaveStar = true --保星完成
                local all_lv_info_bef = {
                    match_lv = model.all_lv_info_bef.match_lv,
                    sub_lv = model.all_lv_info_bef.sub_lv,
                    star = model.all_lv_info_bef.star,
                    sub_lv_star_num = model.all_lv_info_bef.sub_lv_star_num
                }
                local all_lv_info_now = {
                    match_lv = model.all_lv_info_now.match_lv,
                    sub_lv = model.all_lv_info_now.sub_lv,
                    star = model.all_lv_info_now.star,
                    sub_lv_star_num = model.all_lv_info_now.sub_lv_star_num
                }
                Cache.DDZDesk.matchSettles[Cache.user.uin].all_lv_info_now = all_lv_info_now
                Cache.DDZDesk.matchSettles[Cache.user.uin].all_lv_info_bef = all_lv_info_bef

                self.btn_giveUp:setVisible(false)
                self.btn_savestar:setVisible(false)

                self:initAnimation()
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                if rsp.ret == 1420 then
                    --保星卡不足
                    qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.PROPS})
                end
            end
        end
    })
end

function M:showDetailView( ... )
    self.matchIcon:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.5, cc.p(self.animation_node:getPosition())),
        cc.CallFunc:create(function (  )
            if isValid(self) then
                self.panel:runAction(cc.Sequence:create(
                    cc.Show:create(),
                    cc.FadeIn:create(0.5),
                    cc.CallFunc:create(function (  )
                        self.btn_return:setVisible(true)
                        local data = Cache.DDZDesk.matchSettles[Cache.user.uin]
                        if data.reward_box.reward_box > 0 then
                            PopupManager:push({class = GameEndBoxView, init_data = {match_lv = data.all_lv_info_now.match_lv, match_box_lv = data.reward_box.match_box_lv}})
                            PopupManager:pop()
                        end
                        if Cache.user.newBankruptInfo.hasRecieveBankruptMessage == true then
                            qf.event:dispatchEvent(ET.DDZBANKRUPTPTOTECTSHOW) -- 延迟弹出破产弹窗
                        end
                    end)
                ))
            end
        end)
    ))
end

function M:registerBack(  )
    Util:registerKeyReleased({self = self,cb = function ()
        self:close()
        Cache.DDZDesk.startAgain = nil
        qf.event:dispatchEvent(ET.RE_QUIT)
	end})
end

return M