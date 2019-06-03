local ShaderSprite = import("src.modules.common.widget.ShaderSprite")
local NormalGameEnd = class("NormalGameEnd", CommonWidget.BasicWindow)

function NormalGameEnd:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self._parent_view = paras.view

    NormalGameEnd.super.ctor(self, paras)
end

function NormalGameEnd:init(paras)
    Cache.DDZDesk.musicType = 1
    qf.event:dispatchEvent(ET.UPDATE_BG_MUSIC)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(DDZ_Res.gameEndNormalViewJson)
    local blurBg = ccui.Helper:seekWidgetByName(self.gui,"blurBg")
    local bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
    local blackBg = ccui.Helper:seekWidgetByName(self.gui,"blackBg")
    blurBg:setVisible(false)
    bg:setVisible(true)
    self.backBtn = ccui.Helper:seekWidgetByName(self.gui,"backBtn")
    self.exchangeBtn = ccui.Helper:seekWidgetByName(self.gui,"exchangeBtn")
    self.taskBtn = ccui.Helper:seekWidgetByName(self.gui,"taskBtn")

    self.gameTask_tip = ccui.Helper:seekWidgetByName(self.gui, "gameTask_tip")
    self.gameTask_tip:setVisible(false)
    self.gameTask_tip_txt = self.gameTask_tip:getChildByName("txt")

    -- if FULLSCREENADAPTIVE then
    --     self.gui:setPositionX(self.gui:getPositionX()-(self.winSize.width/2-1920/2))
    --     self.gui:setContentSize(self.gui:getContentSize().width+(self.winSize.width-1920),self.gui:getContentSize().height)
    --     blackBg:setContentSize(self.winSize.width,self.winSize.height)
    --     blurBg:setContentSize(self.winSize.width,self.winSize.height)
    --     bg:setPositionX(bg:getPositionX() + (self.winSize.width/2 - 1920/2))
    --     self.backBtn:setPositionX(self.backBtn:getPositionX()-(self.winSize.width/2-1920/2)*3/4)
    --     self.exchangeBtn:setPositionX(self.exchangeBtn:getPositionX() + (self.winSize.width/2-1920/2)*3/4)
    --     self.taskBtn:setPositionX(self.taskBtn:getPositionX() + (self.winSize.width/2-1920/2)*3/4)
    -- end

    self:updateGameEndInfo(paras)
end

function NormalGameEnd:updateGameEndInfo(paras)
    self.gui:setVisible(false)
    local blurBg = ccui.Helper:seekWidgetByName(self.gui,"blurBg")
    for k,v in pairsByKeys(self._parent_view._users)do
        --可能有些人已经退桌了
        if Cache.DDZDesk._player_info[v.info.uin] then
            Cache.DDZDesk._player_info[v.info.uin].isauto = nil
            v:changeHeadType(2)
            v:hideCardOverWarning()
            v:showLightCard()
        end
    end
    local needGray = true
    if Cache.DDZDesk.mine_is_win == true then
        needGray = false
    end

    self.gui:setVisible(true)
    self:updateGameEndView(paras)
end

--更新详情页
function NormalGameEnd:updateGameEndView(paras)
    local endTime = paras.endTime or 1
    local endBg = ccui.Helper:seekWidgetByName(self.gui,"bg")
    self.gui:runAction(cc.Sequence:create(cc.Hide:create(),cc.DelayTime:create(endTime),cc.Show:create(),cc.CallFunc:create(function( ... )
        endBg:setScale(0.1)
        endBg:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.3,1),
            cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                self:controlBankRupt()
                if Cache.user.app_new_user_play_task.status == 2 then
                    qf.event:dispatchEvent(ET.SHOW_RED_PACKAGE)
                end

                self:updateTaskTip()
        end)))
    end)))
    --获取比赛结果
    local meType = Cache.user.uin == Cache.DDZDesk.landlord_uin and 1 or 0
    --赢了还是输了
    if Cache.DDZDesk.mine_is_win == true then
        DDZ_Sound:playSoundGame(DDZ_Sound.GameOver,0,1)
        endBg:loadTexture(DDZ_Res.classicWinBg)
    else
        DDZ_Sound:playSoundGame(DDZ_Sound.GameOver,0,0)
        endBg:loadTexture(DDZ_Res.classicFailBg)
    end
    local item = ccui.Helper:seekWidgetByName(self.gui,"item")

    local resultList = ccui.Helper:seekWidgetByName(self.gui,"resultlist")
    resultList:setItemModel(item)
    local userIndex = 0
    
    self.rankUsers = {}
    table.insert(self.rankUsers, Cache.DDZDesk.backUpOveroInfo[Cache.user.uin])
    for k,v in pairsByKeys(Cache.DDZDesk.backUpOveroInfo)do
        if v.uin ~= Cache.user.uin then 
           table.insert(self.rankUsers, Cache.DDZDesk.backUpOveroInfo[k])
        end
    end

    local resultBeiDesc = ccui.Helper:seekWidgetByName(self.gui,"bei_desc")
    resultBeiDesc:setVisible(true)
    for k,v in pairsByKeys(self.rankUsers)do
        resultList:pushBackDefaultItem()
        local result = resultList:getItem(userIndex)
        result:setVisible(true)     
        local info = v
        local nickName = Util:filterEmoji(v.nick) or ""
        result:getChildByName("nick"):setString(Util:getCharsByNum(Util:filter_spec_chars(nickName),12))
        result:getChildByName("difen"):setString(v.base_socre)
        result:getChildByName("bei_num"):setString(v.multiple)
        if v.uin == Cache.DDZDesk.landlord_uin then
            result:getChildByName("lord_tag_img"):setVisible(true)
        else
            result:getChildByName("lord_tag_img"):setVisible(false)
        end
        result:getChildByName("win_num"):setString(Util:getFormatString(v.win_money))
        result:getChildByName("bg"):setVisible(v.uin == Cache.user.uin)
        local bei_btn = result:getChildByName("bei_btn")
        bei_btn:setVisible(v.uin == Cache.user.uin)
        local size = bei_btn:getContentSize()
        -- bei_btn:setPositionX(bei_btn:getPositionX() + 10.5 - size.width)
        if Cache.DDZDesk.mine_is_win == true then
            result:getChildByName("bg"):loadTexture(DDZ_Res.winTitleImg)
        else
            result:getChildByName("bg"):loadTexture(DDZ_Res.failTitleImg)
        end 

        if info.calc_type == 1 then
            result:getChildByName("poChan"):setVisible(true)
            result:getChildByName("fengDing"):setVisible(false)
        elseif info.calc_type == 2 then
            --todo
            result:getChildByName("poChan"):setVisible(false)
            result:getChildByName("fengDing"):setVisible(true)
        else
            result:getChildByName("poChan"):setVisible(false)
            result:getChildByName("fengDing"):setVisible(false)
        end
         
        if v.uin == Cache.user.uin then
            addButtonEventMusic(result:getChildByName("bei_btn"),DDZ_Res.all_music["BtnClick"],function( ... )--准备按钮
                resultBeiDesc:setVisible(not resultBeiDesc:isVisible())
                local beiDetailInfo = Cache.DDZDesk:getBeiDetailInfo()
                local paras = {
                    beiDetailInfo.init_multi ,
                    beiDetailInfo.show_multi ,
                    beiDetailInfo.qdz_multi ,
                    beiDetailInfo.dipai_multi ,
                    beiDetailInfo.bomb_multi ,
                    beiDetailInfo.spring_multi ,
                    beiDetailInfo.common_multi,
                    beiDetailInfo.landloard_increase or beiDetailInfo.landlord_multi,
                    beiDetailInfo.farmer_increase or beiDetailInfo.farmers_multi,
                    beiDetailInfo.multiple or beiDetailInfo.total_multi,
                }

                if beiDetailInfo then
                    for i = 1, #paras do
                        local subDescLayer = resultBeiDesc:getChildByName("desc_" .. i)
                        subDescLayer:setVisible(true)
                        subDescLayer:getChildByName("name"):setString(DDZ_TXT.gameBeiInfo[i])
                        subDescLayer:getChildByName("value"):setString(paras[i])
                    end
                end
            end)
        else
            result:getChildByName("win_num"):setColor(cc.c3b(249,249,249))
            result:getChildByName("bei_num"):setColor(cc.c3b(249,249,249))
            result:getChildByName("difen"):setColor(cc.c3b(249,249,249))
            result:getChildByName("nick"):setColor(cc.c3b(249,249,249))
        end
        userIndex = userIndex + 1
    end
    
    --明牌开始
    addButtonEventMusic(ccui.Helper:seekWidgetByName(self.gui,"showcardstartbtn"),DDZ_Res.all_music["BtnClick"],function( ... )--准备按钮
        Cache.DDZDesk.startAgain = nil
        ModuleManager:get("game"):getView():deskReset()
        ModuleManager:get("game"):getView():resetForNewStart()
        ModuleManager:get("game"):getView():matchingStartAni()
        qf.event:dispatchEvent(ET.USER_READY_REQ, {
            start_type = GAME_START_TYPE.SHOW,
            show_multi = 5
        })
        self:close()
    end)

    -- 再来一局
    addButtonEventMusic(ccui.Helper:seekWidgetByName(self.gui,"readybtn"),DDZ_Res.all_music["BtnClick"],function( ... ) -- 再来一局准备
        Cache.DDZDesk.startAgain = nil
        ModuleManager:get("game"):getView():deskReset()
        ModuleManager:get("game"):getView():resetForNewStart()
        ModuleManager:get("game"):getView():matchingStartAni()
        qf.event:dispatchEvent(ET.USER_READY_REQ, {
            start_type = GAME_START_TYPE.NORMAL,
            show_multi = 0
        })
        self:close()
    end)

    --退出结束框
    addButtonEventMusic(self.backBtn,DDZ_Res.all_music["BtnClick"],function( ... )
        loga("点击了退出")
        Cache.DDZDesk.startAgain = true
        ModuleManager:get("game"):getView():deskReset()
        ModuleManager:get("game"):getView():resetForNewStart()
        -- qf.event:dispatchEvent(ET.RE_QUIT)
        self:close()
        -- qf.event:dispatchEvent(ET.MYSELF_QUIT_ROOM)
    end)

    --换桌
    addButtonEventMusic(self.exchangeBtn,DDZ_Res.all_music["BtnClick"],function( ... )
        ModuleManager:get("game"):getView():deskReset()
        ModuleManager:get("game"):getView():matchingStartAni()
        qf.event:dispatchEvent(ET.CHANGE_TABLE)
        self:close()
    end)

    --任务
    addButtonEventMusic(self.taskBtn,DDZ_Res.all_music["BtnClick"],function( ... )
        qf.event:dispatchEvent(ET.SHOW_REWARD_VIEW)
    end)
    

    Cache.DDZDesk.landlord_uin = nil
end

--判断是否破产
function NormalGameEnd:controlBankRupt()
    --判断是否破产
     if Cache.user.IsNeedWaitInGameEndBankrupt and Cache.user.IsNeedWaitInGameEndBankrupt == true and Cache.user.newBankruptInfo and Cache.user.newBankruptInfo.hasRecieveBankruptMessage ==true  then
         Cache.user.IsNeedWaitInGameEndBankrupt = false
         qf.event:dispatchEvent(ET.DDZBANKRUPTPTOTECTSHOW)
     end
 end

function NormalGameEnd:updateTaskTip(  )
    local taskInfo = Cache.Config:getGameTaskStatusByRoomId(Cache.DDZDesk.room_id)

    if taskInfo and taskInfo.type == 1 then
        self.gameTask_tip_txt:removeAllChildren()

        local data = taskInfo.data

        local txt_1 = cc.Label:createWithSystemFont(GameTxt.gameTask_tips[1][1], GameRes.font1, 40)
        local txt_2 = cc.Label:createWithSystemFont(data.condition - data.progress, GameRes.font1, 40)
        local txt_3 = cc.Label:createWithSystemFont(GameTxt.gameTask_tips[1][2], GameRes.font1, 40)

        txt_1:setColor(cc.c3b(182, 92, 58))
        txt_2:setColor(cc.c3b(255,0,0))
        txt_3:setColor(cc.c3b(182, 92, 58))

        local allWidth = txt_1:getContentSize().width + txt_2:getContentSize().width + txt_3:getContentSize().width

        local x1 = -allWidth / 2 + txt_1:getContentSize().width / 2
        local x2 = -allWidth / 2 + txt_1:getContentSize().width + txt_2:getContentSize().width / 2
        local x3 = -allWidth / 2 + txt_1:getContentSize().width + txt_2:getContentSize().width + txt_3:getContentSize().width / 2

        txt_1:setPositionX(x1)
        txt_2:setPositionX(x2)
        txt_3:setPositionX(x3)

        self.gameTask_tip_txt:addChild(txt_1)
        self.gameTask_tip_txt:addChild(txt_2)
        self.gameTask_tip_txt:addChild(txt_3)

        self.gameTask_tip:setVisible(true)
        self.gameTask_tip:runAction(cc.FadeIn:create(0.5))
    else
        self.gameTask_tip:setVisible(false)
    end
end

function M:registerBack(  )
    Util:registerKeyReleased({self = self,cb = function ()
        self:close()
        Cache.DDZDesk.startAgain = true
        ModuleManager:get("game"):getView():deskReset()
        ModuleManager:get("game"):getView():resetForNewStart()
	end})
end

return NormalGameEnd