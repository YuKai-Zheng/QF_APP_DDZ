local userInfo = class("userInfo", CommonWidget.BasicWindow)
local UserHead = import("...change_userinfo.components.userHead")--我的头像

function userInfo:ctor( paras )
    self.winSize = cc.Director:getInstance():getWinSize()
    userInfo.super.ctor(self, paras)

    self:initReport()
    self:initView(paras)
    --互动表情
    self:InteractiveExpressionUI()
    self.uin = paras.uin
    if FULLSCREENADAPTIVE then
        local bg_layer = self.gui:getChildByName("bgP")
        bg_layer:setPositionX(bg_layer:getPositionX() - (self.winSize.width - 1980)/2)
        bg_layer:setContentSize(self.winSize.width, self.winSize.height)
    end
end

function userInfo:initUI( paras )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(DDZ_Res.userInfoJson)
    self.baseInfo = ccui.Helper:seekWidgetByName(self.gui,"baseInfo")
    self.careerInfo = ccui.Helper:seekWidgetByName(self.gui,"careerInfo")
    self.headInfo = ccui.Helper:seekWidgetByName(self.baseInfo,"headInfo")
    self.pan_my_info = ccui.Helper:seekWidgetByName(self.baseInfo,"pan_my_info")
    self.wanrenInfo = ccui.Helper:seekWidgetByName(self.baseInfo,"wanrenInfo")
    self.nameInfo = ccui.Helper:seekWidgetByName(self.pan_my_info,"nameInfo")


    -- self.head = ccui.Helper:seekWidgetByName(self.baseInfo, "head")
    self.sexImage = ccui.Helper:seekWidgetByName(self.nameInfo, "sexImage")
    self.nick = ccui.Helper:seekWidgetByName(self.nameInfo, "nick_txt")
    self.level = ccui.Helper:seekWidgetByName(self.nameInfo, "num")
    self.btn_report = ccui.Helper:seekWidgetByName(self.baseInfo, "btn_report")
    self.coinNum = ccui.Helper:seekWidgetByName(self.pan_my_info, "coinNum")
    
    self.ticketNum = ccui.Helper:seekWidgetByName(self.pan_my_info, "ticketText")
    self.currentLevel = ccui.Helper:seekWidgetByName(self.pan_my_info,"currentLevel")
    
    self.game_num = self.wanrenInfo:getChildByName("gameTimes"):getChildByName("num")
    self.win_pencent = self.wanrenInfo:getChildByName("winRate"):getChildByName("num")
    self.highWinTimes = self.wanrenInfo:getChildByName("highWinTimes"):getChildByName("num")
    
    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui, "close")

    --隐藏举报
    self.icon_report = ccui.Helper:seekWidgetByName(self.gui, "icon_report")
    self.icon_report:setVisible(false)

    addButtonEvent(self.closeBtn, function ()
        self:close()
    end)
end

function userInfo:getMatchingResultInfo()
    GameNet:send({cmd=CMD.USER_INFO,body={other_uin=self.uin},
        callback=function(rsp)
            if rsp.ret == 0 then
                if rsp.model then
                    self:updateUserMatchingInfo(rsp.model)
                end
            end
        end
    })
end

function userInfo:updateUserMatchingInfo(model)
    if model.match_max_level and model.match_max_level > 0 then
        self.level:setString(Cache.user:getConfigByLevel(model.match_max_level).title)
    else
        self.level:setString(Cache.user:getConfigByLevel(10).title)
    end
    self.ticketNum:setString(model.lottery_ticket)
    self.game_num:setString(string.format("%d", model.play_times or 0))
    local winRate = model.win_prob or "0"
    self.win_pencent:setString(winRate)
    self.sexImage:loadTexture(string.format(GameRes.img_user_info_my_sex, model.sex))
    self.highWinTimes:setString(model.win_times_streak)

    local levelNum = Util:getLevelNum(model.all_lv_info.sub_lv)
    local maxLevel = Cache.user:getMaxLevel()
    if model.all_lv_info.match_lv == maxLevel then
        ccui.Helper:seekWidgetByName(self.currentLevel,"num"):setString(Cache.user:getConfigByLevel(model.all_lv_info.match_lv).title)
    else
        ccui.Helper:seekWidgetByName(self.currentLevel,"num"):setString(Cache.user:getConfigByLevel(model.all_lv_info.match_lv).title .. levelNum)
    end
    self:updateUserHeadView(model)
end 

function userInfo:updateUserHeadView(model)
	if not self.userHead then
        self.userHead = UserHead.new({})
		self.headInfoDetail = self.userHead:getUI()
		self.headInfo:addChild(self.headInfoDetail)
	end
	self.headInfoDetail:setVisible(true)
	local headInfoSize = self.headInfo:getContentSize()
    local headInfoDetailSize = self.headInfoDetail:getContentSize()
    
	self.headInfoDetail:setPosition( -(headInfoDetailSize.width - headInfoSize.width)/2,-(headInfoDetailSize.height - headInfoSize.height)/2)
    self.userHead:loadHeadImage(model.portrait,model.sex,model.icon_frame,model.icon_frame_id)   
end

function userInfo:updateUserInfo( paras )
    self.uin = paras.uin
    self:initView(paras)
end

function userInfo:updateUserGold(paras)
    if paras.uin == self.uin then
        self.coinNum:setString(Util:getFormatString(paras.remain_amount))
    end
end

-- 举报
function userInfo:initReport()
    
    self.btn_report = ccui.Helper:seekWidgetByName(self.gui, "btn_report")
    self.report_layer = ccui.Helper:seekWidgetByName(self.gui, "report_layer")
    self.report_layer:ignoreAnchorPointForPosition(false)
    self.report_layer:setAnchorPoint(0.5,0.5)
    self.report_layer:setPosition(Display.cx/2,Display.cy/2)
    self.report_layer:setVisible(false)
    self.report_type = 0
    

    self.report_edit = ccui.Helper:seekWidgetByName(self.report_layer, "report_edit")
    self.report_edit:addEventListener(function (sender, eventType)
        
        if eventType == 0 then -- attach IME
            local str = self.report_edit:getStringValue()
            if str == "" then
                self.report_edit:setText("  ")
            end
        elseif eventType == 1 then -- detach IME
            
        elseif eventType == 2 then -- insert text
            
        elseif eventType == 3 then -- delete text
        end
    end)
    
    function initCheckBtns(index)
        for i = 1, 4 do
            local btn_check = ccui.Helper:seekWidgetByName(self.report_layer, "btn_check" .. i)
            if i == index then
                btn_check:getChildByName("img_check"):setVisible(true)
            else
                btn_check:getChildByName("img_check"):setVisible(false)
            end
        end
    end
    initCheckBtns(0)
    for i = 1, 4 do
        local btn_check = ccui.Helper:seekWidgetByName(self.report_layer, "btn_check" .. i)
        addButtonEvent(btn_check, function ()
            initCheckBtns(i)
            self.report_type = i
        end)
    end
    
    local btn_reportclose = ccui.Helper:seekWidgetByName(self.report_layer, "btn_reportclose")
    addButtonEvent(btn_reportclose, function ()
        self.report_layer:setVisible(false)
    end)
    
    addButtonEvent(self.btn_report, function ()
        initCheckBtns(0)
        self.report_edit:setText("")
        self.edit_text = ""
        self.report_type = 0
        self.report_layer:setVisible(true)
    end)
    
    local btn_reportsend = ccui.Helper:seekWidgetByName(self.report_layer, "btn_reportsend")
    addButtonEvent(btn_reportsend, function ()
        if self.report_type == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = GameTxt.report_no_type})
            return 
        end
        self.report_layer:setVisible(false)
        qf.event:dispatchEvent(ET.EVT_USER_REPORT, {uin = self.uin, type = self.report_type, reason = self.report_edit:getStringValue()})
    end)
    addButtonEvent(self.report_layer, function ()
        self.report_layer:setVisible(false)
    end)
end
function userInfo:initView( paras )
    local nickName = Util:filterEmoji(paras.nick) or ""
    self.nick:setString(Util:getCharsByNum(Util:filter_spec_chars(nickName),12))
    local  size = self.nick:getContentSize()
    ccui.Helper:seekWidgetByName(self.pan_my_info,"currentLevel"):setPositionX( size.width + 153)

    self.coinNum:setString(Util:getFormatString(paras.gold))

    -- Util:updateUserHead(self.head, paras.portrait, paras.sex, {url = true, circle = true, add = true})
    self.interactClickedInterival = 0
    self.interactClickedGap = true
    self:getMatchingResultInfo()
end
--互动表情
function userInfo:InteractiveExpressionUI()
    -- body
    
    self.InteractiveExpressioP = ccui.Helper:seekWidgetByName(self.gui, "InteractiveExpressionP")
    -- addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"closeP"),function ()
    --            self:removeFromParent(true)
    --     end)
    
    self.faceBg = ccui.Helper:seekWidgetByName(self.gui, "bgImg")
    
    
    -- self.connectText = ccui.Helper:seekWidgetByName(self.gui, "connectText")--内容
    -- self.connectText:setVisible(false)
    -- self.goldText = self.connectText:clone()
    -- self.goldText:setAnchorPoint(0, 0.5)
    -- self.goldText:setPosition(cc.p(self.connectText:getContentSize().width,self.connectText:getContentSize().height/2))
    -- self.goldText:setColor(cc.c3b(251, 189, 48))
    -- self.connectText:addChild(self.goldText)
    -- self.goldText:setString(Cache.DDZDesk.magic_express_money .. "金币")
    
    for i = 1, 4 do 
        addButtonEvent(ccui.Helper:seekWidgetByName(self.gui, "facebtn" .. i), function ()
            loga("发送表情")
            if self.interactClickedInterival >= 5 then
                    self:close()
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "您发的表情太多了，休息一会再发哦~"})
                    return
            end
            self:clickInteractPhiz(i)
            self.interactClickedGap = false
            self.interactClickedInterival = self.interactClickedInterival + 1
        end)
    end
end

function userInfo:clickInteractPhiz(id)
    local body = {to_uin = self.uin
        , expression_id = id
    } 
    GameNet:send({cmd = CMD.CMD_INTERACT_PHIZ, body = body, callback = function (rsp)
        if rsp.ret == 0 and rsp.model then
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = Cache.Config._errorMsg[rsp.ret]})
        end
    end})
end
return userInfo