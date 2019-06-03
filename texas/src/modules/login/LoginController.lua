
local LoginController = class("LoginController",qf.controller)

LoginController.TAG = "LoginController"
local loginView = import(".LoginView")
LoginController.loginTime = 3

--[[
登陆控制器
1.游戏启动时显示该界面
2.使用 xhr拉取最新服务器信息
3.检查最新版本资源，进行热更新，有更新，更新完重启
4.与服务建立连接，发送登陆注册请求，发送拉取config请求
5.跳转到游戏主界面
]]
function LoginController:ctor(parameters)
    LoginController.super.ctor(self)
    self:getcdnURL()
end


function LoginController:getcdnURL()
    -- body
    self.handler_http_req = nil
    self.handler_http_req = cc.XMLHttpRequest:new()
    self.handler_http_req.timeout = 5
    self.handler_scheduler = Util:runOnce(self.handler_http_req.timeout, function( ... )
        if self.handler_http_req then
            self.handler_http_req:abort()
            self.handler_http_req = nil
        end
        RESOURCE_HOST_NAME = HOST_NAME
    end)

    self.handler_http_req:registerScriptHandler(function(event)
        Util:stopRun(self.handler_scheduler)
        self.handler_scheduler = nil
        if self.handler_http_req.status == 200 then
            
            local response = self.handler_http_req.response
            self.config_list = json.decode(response)
            if not self.config_list or self.config_list.ret ~= 0 then --配置文件更新失败
                RESOURCE_HOST_NAME = HOST_NAME
            else
                if self.config_list.pay_show_list then--支付列表
                    Cache.PayManager.payMethods = self.config_list.pay_show_list
                end
                if self.config_list.cdn~='' and self.config_list.cdn then
                    RESOURCE_HOST_NAME = self.config_list.cdn
                end
                self:checkVersion(self.config_list.update_channel)
            end
        end
    end)
    response_type = cc.XMLHTTPREQUEST_RESPONSE_JSON
    self.handler_http_req.responseType = response_type
    self.handler_http_req:open("GET", Util:getRequestConfigURL())
    self.handler_http_req:send()
end

function LoginController:checkVersion(paras)
    if paras == nil then return end
    if paras.update and paras.update == 1 then
        self.view:versionUpdate(paras)
    end
end

function LoginController:initModuleEvent()

end

function LoginController:removeModuleEvent()

end

-- 这里注册与服务器相关的的事件，不销毁
--[[
ET.LOGIN_REQUEST_LAST_SERVER = getUID()
ET.NET_GETCONFIG_DONE = getUID()
]]
function LoginController:initGlobalEvent()
	qf.event:addEvent(ET.LOGIN_REQUEST_LAST_SERVER,handler(self,self.processGetServerInfo))
	qf.event:addEvent(ET.NET_GETCONFIG_DONE,handler(self,self.processConfigDone))
    qf.event:addEvent(ET.SHOW_LOGIN,handler(self,self.showLogin))
    qf.event:addEvent(ET.LOGIN_NET_GOTO_LOGIN,handler(self,self.processNettoLogin))
    qf.event:addEvent(ET.LOGIN_SIGN_IN,handler(self,self.processSignin))
    qf.event:addEvent(ET.UPDATE_LOGIN_TIMES,handler(self,self.updateLoginTimes))
end

function LoginController:updateLoginTimes( ... )
    self.tryLoginCount = nil
end

function LoginController:processGetServerInfo(paras)
    self._startupTime = os.time()
    local info = TB_SERVER_INFO
    local server_status = info.patch_status and info.patch_status.."" or "0"
    if patch_status == "1" then --停服状态
        local billboard = info.billboard
        qf.event:dispatchEvent(ET.GLOBAL_HANDLE_PROMIT,{body = {type = 1,des = billboard},type = 1})
        return
    end
    loga(json.encode(info.server_list))
    GameNet:start(info.server_list)
    -- GameNet:start({{"192.168.199.113",29001}})
end

function LoginController:SDKSignin()
    local orginInfo = qf.platform:getRegInfo()
    local ot = Util:getOpenIDAndToken()

    if ot.openid and VAR_LOGIN_TYPE_NO_LOGIN ~= ot.type then -- openid存在并且type不为0且非oppo平台时直接登录，否则显示登录界面
        local device_id = orginInfo.device_id
        local body ={}
        body.sign = QNative:shareInstance():md5(UNITY_PAY_SECRET.."|"..ot.openid.."|"..ot.token.."|"..device_id)
        body.openid = ot.openid
        body.access_token = ot.token
        body.expire_date = ___tmpsdkaccountloginDate
        body.channel = orginInfo.channel
        body.version = orginInfo.version
        body.os = orginInfo.os
        body.lang = orginInfo.lang
        body.res_md5 = STRING_UPDATE_FILE_MD5 -- 更新文件列表的md5
        body.device_id = device_id
        body.hot_version = RES_VERSION

        local cmd = CMD.WX_REG
        if Util:isLanguageChinese() then
            if ot.type == "1" then
                cmd = CMD.QQ_REG
            elseif ot.type == "5" then
                cmd = CMD.OPPO_REG
            else
                cmd = CMD.WX_REG
            end
        end
        self:_signIn(cmd,body)
    else
        qf.event:dispatchEvent(ET.SHOW_LOGIN)
    end
end
-- 只有PC上才会走这个方法
function LoginController:processSignin(paras)

    if paras == nil or paras.cmd == nil or paras.body == nil then return end
    local _type = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN);

    if VAR_LOGIN_TYPE_NO_LOGIN == _type then
        qf.event:dispatchEvent(ET.SHOW_LOGIN)
    else
        return self:_signIn(paras.cmd,paras.body)
    end
end

function LoginController:_signIn(cmd,body)
    if not isQufan then
        qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.login003})
    end
    loga("发送消息"..cmd)
    Cache.user.loginFinish = false
    GameNet:send({cmd=cmd,body=body,callback=function(rsp)
        loga("cmd"..rsp.ret)
        loga("登录返回_signIn"..rsp.ret)
        if rsp.ret == 1096 then
            if rsp.model ~= nil and rsp.model.uin ~= nil then
                self.view:showToolsTips(rsp.model.uin)
            else
                self.view:showToolsTips()
            end  
            self.isloginFail =true
            self.tryLoginCount=nil
            sdkaccount = cc.UserDefault:getInstance():setBoolForKey(SKEY.SDKACCOUNT_LOGIN, true) -- 默认为true，在这里只是判断之前有没有使用游客账号进行登录过（老版本中游客账号登录后此值为false）
            cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
            GameNet:reReg()
            return
        end

        if rsp.ret == 1094 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            self.isloginFail =true
            self.tryLoginCount = nil
            qf.event:dispatchEvent(ET.SHOW_LOGIN) 
            return
        end
        
        if rsp.ret ~= 0 then
            self.sign_in_ret = rsp.ret
            GameNet:reReg()
            return 
        end
        
        if self.view then
            self.view.touchToLogin = false
        end
        self.tryLoginCount = nil --重置尝试登陆
        Cache.user:updateCacheByLogin(rsp.model)
        Cache.user:updateNewUserPlayTask(rsp.model.app_new_user_play_task)
        qf.platform:sendUinToBugly(tostring(Cache.user.uin))
        cc.UserDefault:getInstance():setIntegerForKey(SKEY.UIN,Cache.user.uin)
        cc.UserDefault:getInstance():flush()
        local _config = GameNet:getDataBySignedBody(rsp.model.app_config, CMD.APPCONFIG)
        local _wxConfig = GameNet:getDataBySignedBody(rsp.model.config, CMD.CONFIG)
        if not _config or not _wxConfig then
            logd("登录解析微信或者app的config失败!")
            -- 解析失败
            GameNet:reReg()
        elseif xpcall(
            function()
                --app这边的Config
                Cache.Config:saveConfig(_config.model)
                --微信小游戏config，主要由于游戏模块
                Cache.Config:updateWxConfig(_wxConfig.model)
            end,
            function()
                Util:uploadError(debug.traceback())
                Util:uploadError(" 存储wxconfig出错的model-->>"..pb.tostring(_wxConfig.model))
                Util:uploadError(" 存储appconfig出错的model-->>"..pb.tostring(_config.model))
            end) 
        then
            GameNet:send({ cmd = CMD.CMD_GET_DAOJU_LIST ,wait=true,txt=GameTxt.net002,
            callback= function(rsp)
                if rsp.ret ~= 0 then
                    --不成功提示
                    loga("不成功提示")
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                else
                    loga("成功提示")
                    if rsp.model ~= nil then 
                        Cache.daojuInfo:saveConfig(rsp.model)
                        Cache.user:updateLoginTipPopValue(true)
                        qf.event:dispatchEvent(ET.NET_GETCONFIG_DONE)
                        cc.UserDefault:getInstance():setIntegerForKey("match_accept_need_"..Cache.user.uin,1)
                        cc.UserDefault:getInstance():setIntegerForKey("ddz_login_tipShow_"..Cache.user.uin,1)
                    end
                end
            end})
            Util:flashBGSave(rsp.model.app_620_flash_screen) --更新闪屏数据
        else
            -- 保存配置失败/出错
            GameNet:reReg()
        end
    end})
end

--[[----]]
function LoginController:processNettoLogin()
    logd("login ==>>")
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove",reConnect = 1})
    local sdkaccount = cc.UserDefault:getInstance():getBoolForKey(SKEY.SDKACCOUNT_LOGIN, true) -- 默认为true，在这里只是判断之前有没有使用游客账号进行登录过（老版本中游客账号登录后此值为false）
    local _type = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    if  sdkaccount==true and _type==VAR_LOGIN_TYPE_NO_LOGIN then 
        if self.isloginFail then
            self.isloginFail =nil
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "登陆失败，请重新登陆"})
        end
        qf.event:dispatchEvent(ET.SHOW_LOGIN) 
        return 
    end
    if PF_WINDOWS == false then  -- 若平台不为windows则，直接登录
        if self.view and self.view.touchToLogin then
            return
        end

        if not self.tryLoginCount then
            self.tryLoginCount = 1
        end --尝试登陆

        if self.tryLoginCount == 3 then--尝试3次没成功就显示选择登陆方式
            local _type = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
            if self.view then
                self.view.touchToLogin = true
            end
            qf.event:dispatchEvent(ET.SHOW_LOGIN)
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.login006 ,time = 2})
            return
        end
        self.tryLoginCount = self.tryLoginCount + 1

        local roadLogin = true
        --local sdkaccount = cc.UserDefault:getInstance():getBoolForKey(SKEY.SDKACCOUNT_LOGIN, true) -- 默认为true，在这里只是判断之前有没有使用游客账号进行登录过（老版本中游客账号登录后此值为false）
        --local _type = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
        if VAR_LOGIN_TYPE_NO_LOGIN == _type then -- 一定是被踢下线或者没有任何有用的登录
            if false == sdkaccount then -- 是游客登录(老版本升级)
                cc.UserDefault:getInstance():setBoolForKey(SKEY.SDKACCOUNT_LOGIN, nil)
                cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_VISITOR)
                cc.UserDefault:getInstance():flush()
            else
                roadLogin = false
                qf.event:dispatchEvent(ET.SHOW_LOGIN)
            end        
        elseif VAR_LOGIN_TYPE_VISITOR == _type then
        else 
            roadLogin = false
            self:SDKSignin()
        end
        if roadLogin == true then
            self:_signIn(CMD.REG, qf.platform:getRegInfo())
        end
    else -- windows 平台跳转到登录界面
        qf.event:dispatchEvent(ET.SHOW_LOGIN)
    end
end

function LoginController:processConfigDone()

    loga(" --- get user config success , now go to main game ----",self.TAG)
    -- 绑定阿里云推送别名
    qf.platform:bindPushAlias({uin=Cache.user.uin})

    -- 上传玩家角色信息
    if string.find(GAME_CHANNEL_NAME,"CN_AD_OPPO1") then
        qf.platform:sdkUpdatePlayerInfo({
            roleId=Cache.user.uin .. "",
            roleName=Cache.user.nick,
            roleLevel=Cache.user.level,
            realmId="1",
            realmName="斗地主",
            chapter="1",
            gold=Cache.user.gold
        })
    end

    qf.platform:registerWXAPP()

    if self.view and self.view.firstOpen ~= false then
        qf.platform:td_onRegister(Cache.user.uin)
    end
    qf.platform:td_onLogin(Cache.user.uin)
	qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{uin=Cache.user.uin,
		callback = function ()
            -- 这里是已经登录成功了-把自己的头像删除重新拉取-防止美女认证成功后头像没改变
            local _url = Util:getHURLByUin(Cache.user.uin)
            local _path = qf.downloader:getFilePathByUrl(_url)
            cc.Director:getInstance():getTextureCache():removeTextureForKey(_path)
            qf.downloader:removeFile(_url)

            local costTime = os.time() - self._startupTime
            Cache.Config._loginRewardCheck = 0 -- 登录奖励校验字段
            Cache.Config._needJoinAni = false
            Cache.Config._activeNoticeCheak = 0 -- 活动通知校验
            
            if TB_MODULE_BIT.MODULE_BIT_REVIEW then
                if self.view == nil then  self.view = self:getView() end
                if ccui.Helper:seekWidgetByName(self.view.login,"btn_bg") then
                    ccui.Helper:seekWidgetByName(self.view.login,"btn_bg"):setVisible(false)
                end
            end
            ModuleManager.gameshall:remove()
            ModuleManager.gameshall:show({ani=1})
            qf.platform:umengStatistics({umeng_key = "LoginToHall"})--点击上报

            self:remove()
            qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
            qf.event:dispatchEvent(ET.NET_AUTO_INPUT_ROOM)
		end
    }) 
end

function LoginController:showLogin()
    if self.view == nil then  self.view = self:getView() end
    qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
    self.view:showLogin(true)
end

function LoginController:versionUpdate(paras)
    if self.view == nil then return end
    self.view:versionUpdate(paras)
end

function LoginController:initView(parameters)
    qf.event:dispatchEvent(ET.MODULE_SHOW,"login")
    local view = loginView.new(parameters)
    return view
end

function LoginController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"login")
    LoginController.super.remove(self)
end

return LoginController