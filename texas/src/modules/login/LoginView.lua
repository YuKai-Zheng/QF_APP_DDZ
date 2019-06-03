local LoginView = class("LoginView", qf.view)
local  VersionUpdate = import("src.modules.global.components.VersionUpdate")
LoginView.TAG = "LoginView"

function LoginView:ctor(parameters)
    self:init(parameters)
    --self:initTouchEvent()
    LoginView.super.ctor(self,parameters)
    self.bg = ccui.Helper:seekWidgetByName(self.login,"bg")
    if FULLSCREENADAPTIVE then
        -- self.bg:setPositionX(self.bg:getPositionX() + (self.winSize.width-1920)/2)
        -- self.logoImg:setPositionX(self.logoImg:getPositionX() - (self.winSize.width-1920)/2)
    end
end

function LoginView:initTouchEvent()

end

function LoginView:init(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:showLogin(not FIRST_LOGIN)
    Cache.user.isFirstgame =  cc.UserDefault:getInstance():getBoolForKey(SKEY.FIRST_GAME_FLAG,true)
    self.firstOpen = true
    if FIRST_LOGIN ~= true then
        self.firstOpen = false
     return 
    end
    FIRST_LOGIN = false
    qf.event:dispatchEvent(ET.LOGIN_REQUEST_LAST_SERVER)
end

function LoginView:showLogin(_visible)
    PopupManager:clean()
    qf.event:dispatchEvent(ET.GLOBAL_HIDE_BROADCASE_LAYOUT)
    if self.login then 
        if qf.device.platform == "windows" then
            self:showpclogin()
        else
            self:showQQLogin(_visible)
        end
        return 
    end
    self.login = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.pcLoginJson)
    self:addChild(self.login)
    
    --提示信息
    self.copyright = ccui.Helper:seekWidgetByName(self.login,"Image_9")
    --叠加背景
    self.bgImg= ccui.Helper:seekWidgetByName(self.login,"bgimg")
    --太阳光
    self.sunShine= ccui.Helper:seekWidgetByName(self.login,"sunShine")
    --美女
    self.Beauty= ccui.Helper:seekWidgetByName(self.login,"beauty")
    --美女层
    self.pan_all= ccui.Helper:seekWidgetByName(self.login,"Panel_16")
    
    self.btn_bg = ccui.Helper:seekWidgetByName(self.login,"btn_bg")
    -- logo
    self.logoImg = ccui.Helper:seekWidgetByName(self.login,"Image_15")

    if string.find(GAME_CHANNEL_NAME,"CN_AD_OPPO1") then
        self.logoImg:loadTexture(GameRes.logo_img_oppo)
    else
        self.logoImg:loadTexture(GameRes.logo_img_1)
    end

    --香港/新加坡/菲律宾不显示健康游戏提示
    self.copyright:setVisible(GAME_LANG ~= "zh_tr")

    --光
    self.guangImg={}
    for i=1,4 do
        local guang=ccui.Helper:seekWidgetByName(self.login,"guang"..i)
        if i%2==0 then guang.rightdir=1
        else guang.rightdir=-1 end
        table.insert(self.guangImg,guang)
    end

    self:initAnimate()
    local is_review = 0 ~= Util:binaryAnd(TB_SERVER_INFO.modules, TB_MODULE_BIT.MODULE_BIT_REVIEW) and true or false
    if qf.device.platform == "windows" then
        self:showpclogin()
    else
        self:showQQLogin(_visible)
    end
    if not BOL_AUTO_RE_CONNECT then
        BOL_AUTO_RE_CONNECT = true 
        self:showToolsTips1()
    end
end
--串号提示
function LoginView:showToolsTips1( uin )
    -- body
    self.toolTips = require("src.modules.common.widget.toolTip").new()
    self.toolTips:hideOtherText()
    self.toolTips:setTipsText(GameTxt.game_reconnect_text)
    self:addChild(self.toolTips,2)
end

function LoginView:showToolsTips( uin )
    -- body
    self.toolTips = require("src.modules.common.widget.toolTip").new()
    if uin then
        self.toolTips:setTipsText(string.format(GameTxt.login007,uin))
    else
        self.toolTips:setTipsText(GameTxt.login008)
    end
    self:addChild(self.toolTips,2)
end


function LoginView:initAnimate()
    self:addLoginLoadingAni()
    self:addLoginLoadingParticleAni()
end

function LoginView:cleanup( ... )
    -- body
    if self.guangSchedule then
        Scheduler:unschedule(self.guangSchedule)
        self.guangSchedule=nil
    end
end


function LoginView:showQQLogin(_visible)
    -- 如果几个登录按钮不可见，那么一定要用loading界面进行遮挡
    -- 不可见的原因是：要判断缓存中有没有账号信息可以直接登录
    -- 在这段时间，界面上要提示用户在干啥，不然会觉得很怪
    if not _visible then
        -- qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=GameTxt.main001})
        qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.main001})
    else
        -- qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
        qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
    end
    self.btn_bg:setVisible(true)

    local function guestLogin() --游客模式登录
        -- if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击游客登录") end
        -- qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=GameTxt.login003})
        self:delayRun(0.4,function (  )
            qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.login003})
            GameNet:disconnect()
        end)
        self:delayRun(0.01,function (  )
            self:removepclogin()
        end)

        cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_VISITOR); -- -1为测试账号登录或游客
        cc.UserDefault:getInstance():flush()

        qf.event:dispatchEvent(ET.UPDATE_LOGIN_TIMES)
        self.touchToLogin = false
    end
    addButtonEvent(ccui.Helper:seekWidgetByName(self.login,"other_uers_login_btn"),function (sender)
        guestLogin()
    end)

    local function sdkAccountLoginCb (info)
        -- qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="show",txt=GameTxt.login003})
        loga("微信调用返回")
        dump(info)
        self:delayRun(0.4,function (  )
            qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.login003})
            Util:setOpenIDAndToken(info.openid,info.token,info.type)
            ___tmpsdkaccountloginDate = info.date
            GameNet:disconnect()
        end)
        self:delayRun(0.01,function (  )
            self:removepclogin()
        end)
        self.touchToLogin = false
        qf.event:dispatchEvent(ET.UPDATE_LOGIN_TIMES)
    end
    qf.platform:initWxAndQQShow()
    YOUKE_CAN_SHOW = false
    
    if qf.device.platform == "android" then
        if string.find(GAME_CHANNEL_NAME,"CN_AD_OPPO1") then -- OPPO隐藏所有按钮并自动登陆
            YOUKE_CAN_SHOW, QQ_CAN_SHOW, WX_CAN_SHOW = false, false, false

            if not self.oppoLogin then
                qf.platform:sdkAccountLogin({type = 5 ,cb = sdkAccountLoginCb})
                self.oppoLogin = true
            end
        else
            QQ_CAN_SHOW, WX_CAN_SHOW = false, true
        end
        -- ccui.Helper:seekWidgetByName(self.login,"weixin_login_btn"):setPositionY(400)
        -- ccui.Helper:seekWidgetByName(self.login,"other_uers_login_btn"):setPositionY(700)
    end
    
    ccui.Helper:seekWidgetByName(self.login,"weixin_login_btn"):setVisible(WX_CAN_SHOW)
    ccui.Helper:seekWidgetByName(self.login,"qq_login_btn"):setVisible(QQ_CAN_SHOW)

    -- 如果没过审
    local is_review = 0 ~= Util:binaryAnd(TB_SERVER_INFO.modules, TB_MODULE_BIT.MODULE_BIT_REVIEW) and true or false
    if is_review == false then
        ccui.Helper:seekWidgetByName(self.login,"other_uers_login_btn"):setVisible(YOUKE_CAN_SHOW)
        ccui.Helper:seekWidgetByName(self.login,"weixin_login_btn"):setVisible(WX_CAN_SHOW)
        ccui.Helper:seekWidgetByName(self.login,"other_uers_login_btn"):setPosition(ccui.Helper:seekWidgetByName(self.login,"weixin_login_btn"):getPositionX(), ccui.Helper:seekWidgetByName(self.login,"weixin_login_btn"):getPositionY())
    else
        ccui.Helper:seekWidgetByName(self.login,"other_uers_login_btn"):setVisible(YOUKE_CAN_SHOW)
        ccui.Helper:seekWidgetByName(self.login,"weixin_login_btn"):setVisible(WX_CAN_SHOW)
    end

    addButtonEvent(ccui.Helper:seekWidgetByName(self.login,"qq_login_btn"),function (sender)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击QQ登录") end
        qf.platform:sdkAccountLogin({type = 1,cb = sdkAccountLoginCb})
        
    end)

    addButtonEvent(ccui.Helper:seekWidgetByName(self.login,"weixin_login_btn"),function (sender)--微信登陆
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击微信登录") end
        local nType = 3
        if  string.find(GAME_CHANNEL_NAME,"CN_TUHAOYYB") then
            nType = 4
        elseif string.find(GAME_CHANNEL_NAME,"CN_AD_OPPO1") then
            nType = 5
        end
        qf.platform:sdkAccountLogin({type = nType ,cb = sdkAccountLoginCb})
    end)

    ccui.Helper:seekWidgetByName(self.login,"btn_bg"):setVisible(_visible)
end
function LoginView:showpclogin(  )
    if qf.platform:getKey()=="wrong_key" then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "找不到c:\\key.txt, 请咨询客户端开发人员"})
    end
    ccui.Helper:seekWidgetByName(self.login,"btn_bg"):setVisible(true)
    ccui.Helper:seekWidgetByName(self.login,"other_uers_login_btn"):setVisible(true)
    ccui.Helper:seekWidgetByName(self.login,"qq_login_btn"):setTouchEnabled(false)
    ccui.Helper:seekWidgetByName(self.login,"weixin_login_btn"):setTouchEnabled(false)    
    addButtonEvent(ccui.Helper:seekWidgetByName(self.login,"other_uers_login_btn"),function (sender)
        self:delayRun(0.01,function (  )
            self:removepclogin()
        end)
        cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_VISITOR); -- -1为测试账号登录
        cc.UserDefault:getInstance():flush()
        self:delayRun(1,function (  )
            qf.event:dispatchEvent(ET.LOGIN_SIGN_IN,{cmd = CMD.REG,body=qf.platform:getRegInfo()})
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove",reConnect = 1})
        end)
        qf.event:dispatchEvent(ET.UPDATE_LOGIN_TIMES)
    end)

end


function LoginView:delayRun(time,cb)
    if time == nil or cb == nil then return end
    self:runAction(
        cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function() 
            if cb then cb() end
        end)
    ))
end

function LoginView:removepclogin()
    if not tolua.isnull(self.login)  then 
        if self.guangSchedule then
            Scheduler:unschedule(self.guangSchedule)
            self.guangSchedule=nil
        end
        self:runAction(cc.Sequence:create(
            cc.CallFunc:create(function ( ... )
                if self.btn_bg then
                    self:hideElements()
                end
            end),cc.DelayTime:create(1)
            ,cc.CallFunc:create(function( ... )
            -- body
            if self.login then
                self.login:removeFromParent() 
                self.login=nil
            end
        end)))
    end
end

function LoginView:getRoot() 
    return LayerManager.LoginLayer
end

function LoginView:showElements()
    if self.btn_bg then
        self.btn_bg:setVisible(true)
    end
end

function LoginView:hideElements()
    if self.btn_bg then
        self.btn_bg:setVisible(false)
    end
end

function LoginView:versionUpdate(params)
    self.versionUpdate =  VersionUpdate.new(params)
    self.versionUpdate:setPosition(0, 0)
    self.login:addChild(self.versionUpdate,3)
end


--登录界面 动画
function LoginView:addLoginLoadingAni()
    local loginAni = ccs.Armature:create("loading")
    loginAni:getAnimation():playWithIndex(0)
    local size = self.bgImg:getSize()
    loginAni:setPosition(size.width/2,size.height/2)
    self.bgImg:addChild(loginAni)
end

--登录 粒子动画
function LoginView:addLoginLoadingParticleAni()
    
    local sunAnimateAni = ccs.Armature:create("sunShineAnimate")
    sunAnimateAni:getAnimation():playWithIndex(0)
    local size = self.sunShine:getSize()
    sunAnimateAni:setPosition(size.width/2 - 300,size.height/2 -100)
    self.sunShine:addChild(sunAnimateAni)
end

return LoginView
