 local ChangeUserView = class("ChangeUserView", CommonWidget.BasicWindow)
ChangeUserView.TAG = "ChangeUserView"
local HeadImage=require("src.modules.global.components.big_head_image.HeadImage")
local UserHead = import(".components.userHead")

function ChangeUserView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    ChangeUserView.super.ctor(self,parameters)
    
    self:initWord()
    self:setNickEditBox()
    self.sex = Cache.user.sex
    self:refreshHead()
    self:initUserInfo()
    self:queryGameInfo()
end

function ChangeUserView:initUI(parameters)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.changeUserinfoJson)
    self.baseInfo = ccui.Helper:seekWidgetByName(self.gui,"baseInfo")
    self.careerInfo = ccui.Helper:seekWidgetByName(self.gui,"careerInfo")
    self.headInfo = ccui.Helper:seekWidgetByName(self.baseInfo,"headInfo")
    self.pan_my_info = ccui.Helper:seekWidgetByName(self.baseInfo,"pan_my_info")
    self.matchingdataP = ccui.Helper:seekWidgetByName(self.baseInfo,"matchingdataP")

    self.changeHead = ccui.Helper:seekWidgetByName(self.baseInfo,"changeHead")
    ccui.Helper:seekWidgetByName(self.baseInfo, "nick_txt"):setVisible(false)
    self.btn_sex = ccui.Helper:seekWidgetByName(self.baseInfo,"btn_sex")
    --是否完成实名认证
    self.panel_real_name = ccui.Helper:seekWidgetByName(self.baseInfo,"panel_real_name")

    if Cache.user.user_identity == 2 then
        self.panel_real_name:setVisible(true)
    end

    self.btn_sex:setPressedActionEnabled(false)
    self.btn_sex:setTouchEnabled(false)

    self.isedit = parameters.isedit
    qf.event:dispatchEvent(ET.GLOBAL_GET_USER_INFO,{uin = Cache.user.uin})
    
    if parameters.localinfo then
        self:initLocalInfo(parameters)
    end
    if parameters.cb then
        self.cb=parameters.cb
    end
    
    if parameters.isInGame and parameters.isInGame == true then
        self.changeHead:setVisible(false)
    else
        self.changeHead:setVisible(true)
    end

    if FULLSCREENADAPTIVE then
        local bg_layer = self.gui:getChildByName("deep_panel")
        bg_layer:setPositionX(bg_layer:getPositionX() - (self.winSize.width - 1980)/2)
        bg_layer:setContentSize(self.winSize.width, self.winSize.height)
    end

    self:onUserHeadBoxRedChange()
end

function ChangeUserView:initLocalInfo(paras)
    -- body
    if paras.localinfo then
        self:updateUserHeadView()
    end
end

function ChangeUserView:updateUserHeadView()
    if not self.userHead then
        self.userHead = UserHead.new({})
        self.headInfoDetail = self.userHead:getUI()
        self.headInfoDetail:setVisible(true)
    end
	local headInfoSize = self.headInfo:getContentSize()
    local headInfoDetailSize = self.headInfoDetail:getContentSize()
    
	self.headInfoDetail:setPosition( -(headInfoDetailSize.width - headInfoSize.width)/2,-(headInfoDetailSize.height - headInfoSize.height)/2)
	self.headInfo:addChild(self.headInfoDetail)
    self.userHead:loadHeadImage(Cache.user.portrait,Cache.user.sex,Cache.user.icon_frame,Cache.user.icon_frame_id)  
end

function ChangeUserView:initWord()
    ccui.Helper:seekWidgetByName(self.pan_my_info,"lbl_id"):setString(GameTxt.string903)
    ccui.Helper:seekWidgetByName(self.pan_my_info,"id_txt"):setString(Cache.user.uin)
    self:refreshGold()
end

function ChangeUserView:initUserInfo()
    if not Cache.user.win_prob then
        Cache.user.win_prob = 0
    end
    local levelNum = Util:getLevelNum(Cache.user.all_lv_info.sub_lv)

    local maxLevel = Cache.user:getMaxLevel()
    if Cache.user.all_lv_info.match_lv == maxLevel then
        ccui.Helper:seekWidgetByName(self.pan_my_info,"currentLevel"):getChildByName("num"):setString(Cache.user:getConfigByLevel(Cache.user.all_lv_info.match_lv).title)
    else
        ccui.Helper:seekWidgetByName(self.pan_my_info,"currentLevel"):getChildByName("num"):setString(Cache.user:getConfigByLevel(Cache.user.all_lv_info.match_lv).title .. levelNum)
    end
end

function ChangeUserView:refreshGold()
    ccui.Helper:seekWidgetByName(self.pan_my_info,"money_txt"):setString(Cache.user.gold)
    ccui.Helper:seekWidgetByName(self.pan_my_info,"ticket_txt"):setString(Cache.user.fucard_num)
end

function ChangeUserView:queryGameInfo()
    self:updateLevelInfo() 
    qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{
        uin = Cache.user.uin,
        wait = true,
        txt = GameTxt.login001,
        callback = function(model) 
            local winRate = Cache.user.win_prob or "0"
            ccui.Helper:seekWidgetByName(self.matchingdataP,"winRate"):getChildByName("num"):setString(winRate)
            ccui.Helper:seekWidgetByName(self.matchingdataP,"gameTimes"):getChildByName("num"):setString(Cache.user.play_times)
            ccui.Helper:seekWidgetByName(self.matchingdataP,"highWinTimes"):getChildByName("num"):setString(Cache.user.win_times_streak)
            self:updateLevelInfo() 
        end
    })
end

function ChangeUserView:updateLevelInfo(  )
    if not Cache.user.match_max_level or Cache.user.match_max_level < 1 then
        Cache.user.match_max_level = 10
    end
    local nowLevelIndex = math.ceil(Cache.user.match_max_level/10)
    
    self.careerInfo:getChildByName("highLevel"):getChildByName("text"):setString(Cache.user:getConfigByLevel(Cache.user.match_max_level).title)
    self.careerInfo:getChildByName("highLevel"):getChildByName("season"):setString("S"..Cache.user.season_sn)
    self.careerInfo:getChildByName("winMoney"):getChildByName("text"):setString("x".. Cache.user.career_win_gold)
    self.careerInfo:getChildByName("mulsRecord"):getChildByName("text"):setString("x".. Cache.user.max_history_multi_num)
    self.careerInfo:getChildByName("springTimes"):getChildByName("text"):setString("x".. Cache.user.win_times_spring)
    self.careerInfo:getChildByName("bombsTimes"):getChildByName("text"):setString("x".. Cache.user.career_bomb_times)
end

function ChangeUserView:initClick(  )
    addButtonEvent(self.gui, function (  )
        self:close()
    end)

    addButtonEvent(self.changeHead, function (  )
        qf.event:dispatchEvent(ET.SHOW_MY_HEADBOX,{})
        self:close()
    end)

    addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"back"), function (  )
        self:close()
    end)
end

function ChangeUserView:getNativeParas()
    return {
            cb= function(status)
                Util:uploadUserIconCallback(status)
            end,
            path=CACHE_DIR.."head_"..Cache.user.uin..".jpg",
            uin=Cache.user.uin,
            key = QNative:shareInstance():md5(Cache.user.key),
            url=HOST_PREFIX..HOST_NAME.."/portrait/upload",
            upload=1,
        }
end

function ChangeUserView:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end

function ChangeUserView:close(  )
    if self.editBoxShowing==true then
        return
    end

    if qf.device.platform ~= "android" -- 如果是android则直接关闭
        -- android下不需要判断软键盘状态，如果弹起软键盘则不会触发此操作
        and self.isOnEditng then
        self.isOnEditng = false
        return
    end

    if self.cb then self.cb() end

    ChangeUserView.super.close(self)
end


--[[加点击事件end]]
function ChangeUserView:refreshHead()
    self.btn_sex:loadTextureNormal(string.format(GameRes.img_user_info_my_sex, self.sex))
end

function ChangeUserView:updateSexInfo()
    if self.sex ~= Cache.user.sex then
        qf.event:dispatchEvent(ET.NET_USER_MODIFY_REQ,{nick = self.nick,sex = self.sex,cb = handler(self,self.updateCallback)})
    end
end

function ChangeUserView:updateCallback(paras)
    local rsp=paras.callrsp
    if rsp.ret == 0 then
        Cache.user.sex = paras.sex
        Cache.user.nick = paras.nick or Cache.user.nick
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string906,time = 2})
        qf.event:dispatchEvent(ET.GLOBAL_FRESH_MAIN_GOLD)
        qf.event:dispatchEvent(ET.MAIN_UPDATE_USER_HEAD)    --更新主界面头像
        qf.event:dispatchEvent(ET.UPDATE_CHOSEHALL_HEADIMG) --更新选场大厅的头像
        qf.event:dispatchEvent(ET.HALL_UPDATE_INFO) --更新大厅
        self.btn_sex:loadTextureNormal(string.format(GameRes.img_user_info_my_sex, Cache.user.sex))
    else
        if self.editName then 
            local nickName = Util:filterEmoji(Cache.user.nick) or ""
            self.editName:setText(nickName) 
        end
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
    end
end

--[[输入昵称start]]
function ChangeUserView:setNickEditBox()
    local nickName = Util:filterEmoji(Cache.user.nick) or ""
    ccui.Helper:seekWidgetByName(self.baseInfo, "lbl_nick_text"):setString(Util:getCharsByNum(Util:filter_spec_chars(nickName),16))
    local  size = ccui.Helper:seekWidgetByName(self.baseInfo, "lbl_nick_text"):getContentSize()
    ccui.Helper:seekWidgetByName(self.pan_my_info,"currentLevel"):setPositionX( size.width + 392 - 240)
end

function ChangeUserView:onUserHeadBoxRedChange(paras)
    if Cache.user.headBox_red_control and Cache.user.headBox_red_control == 1 then
        ccui.Helper:seekWidgetByName(self.changeHead,"redPot"):setVisible(true)
    else
        ccui.Helper:seekWidgetByName(self.changeHead,"redPot"):setVisible(false)
    end
end

return ChangeUserView
