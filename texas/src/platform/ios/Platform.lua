local Platform = class("Platform")


local luaoc = require "luaoc"
Platform.TAG = "ios-pf"
Platform.CLASSNAME = OBJC_CLASS_NAME

function Platform:ctor()
	self:getRegInfo()
end

function Platform:showExitDialog ()

end

function Platform:getAppName()
    local ok ,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_getGameName",{})
    if ok == true then return ret end
end

function Platform:getBaseVersion() 
	local ok ,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_getBaseVersion",{})
	if ok == true then return ret.version end
end

function Platform:takePhoto(paras) 
	logd( " --- takePhoto --- " , self.TAG)
	paras.uin = paras.uin..""
	local ok ,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_takePhoto",paras)
end

function Platform:selectPhoto(paras) 
	logd( " --- selectPhoto --- " , self.TAG)
    paras.uin = paras.uin..""
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_selectPhoto",paras)
end

function Platform:getIfScreenFrame(paras) 
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_getIfScreenFrame")
    if ret == 0 then 
        FULLSCREENADAPTIVE = false
    else
        FULLSCREENADAPTIVE = true
    end
    return ret 
end

function Platform:getRegInfo () 
    local ok, ret  = luaoc.callStaticMethod(self.CLASSNAME,"syyy_getRegInfo",{})
    local info = {}
    info.nick = ret.nick
    info.uuid = ret.uuid
    info.device_id = ret.device_id
    info.channel = ret.channel
    info.mac_addr = ret.mac_addr
    info.version = ret.version
    if info.nick=="" or not info.nick then
        info.nick="player"
    end
    info.nick = Util:subStringUTF8(info.nick,12)
    GAME_NAME = ret.app_name
    GAME_VERSION_CODE = info.version or "1"
    GAME_CHANNEL_NAME = info.channel or "CN_IOS"
    info.os = "ios"
    info.lang = GAME_LANG
    info.res_md5 = STRING_UPDATE_FILE_MD5 -- 更新文件列表的md5
    --logd( " local uuid ---> "..cc.UserDefault:getInstance():getStringForKey(SKEY.UUID,""), self.TAG)
    if cc.UserDefault:getInstance():getStringForKey(SKEY.UUID,"") == "" then
--        logd( " --- uuid not exist--- " , self.TAG)
        cc.UserDefault:getInstance():setStringForKey(SKEY.UUID,info.uuid)
        cc.UserDefault:getInstance():flush()
    else
--        logd( " --- uuid existed--- " , self.TAG)
        info.uuid = cc.UserDefault:getInstance():getStringForKey(SKEY.UUID,"")
    end

	if tonumber(info.version or 0) > 81 then
		local key = self:getKey()
		info.sign = QNative:shareInstance():md5(key.."|"..info.uuid.."|"..info.device_id)
	end
    info.hot_version=GAME_VERSION_CODE
    return info,ret.deviceSystemVersion
end

function Platform:getKey()
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_getKey", {})
	if ok == true then return ret end
	return ""
end

function Platform:isDebugEnv() 
    --if ENVIROMENT_TYPE == 1 then return true end 
    return false 
end

function Platform:showWebView(paras) 
	if paras == nil or paras.url == nil or
		paras.x == nil or paras.y == nil or
		paras.w == nil or paras.h == nil then 
		logd(" --- error paras in showWebView -- " ,self.TAG)
	end

	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_showWebView",paras)
	if ok == false then loge(" --- call objc error in showExitDialog ---" , self.TAG) end
end

function Platform:removeWebView(paras)
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_removeWebView")
	if ok == false then loge(" --- call objc error in removeWebView --- " , self.TAG) end
end

--[[--
震动的时长 秒
]]
function Platform:playVibrate(paras)
    if SHOCK_SETTING then
    	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_playVibrate",{})
    end
end


function Platform:umengStatistics(paras)
	if paras == nil or paras.umeng_key == nil then return end
    paras.umeng_value = paras.umeng_value or  ""
    print("友盟上报"..paras.umeng_key)
    local args = {key=paras.umeng_key,value=paras.umeng_value}
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_umengStatistics",args)
end


function Platform:requestApplyAuth(paras)
	paras.uin = paras.uin..""
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_requestApplyAuth",paras)
end

function Platform:allPay(shopInfo)
    local paymethod = shopInfo.paymethod
    local function payCallback(paras)
        if shopInfo.cb then
            shopInfo.cb(paymethod, paras)
        end
    end

    local channel = GAME_CHANNEL_NAME 
    local prefix = string.sub(channel, 1, 2)
    local source = "app_ddz"

    local jsonTable = {
        bill_type=paymethod,
        user_id = Cache.user.uin.."",
        proxy_item_id= shopInfo.proxy_item_id,
        item_id=shopInfo.item_id,
        cost = shopInfo.cost,
        item_name = shopInfo.name_desc,
        payType = shopInfo.payType,
        version=GAME_VERSION_CODE,
        cb = payCallback,
        host=HOST_PAY_NAME,
        cur=shopInfo.currency,
        source=source,
        ref=shopInfo.ref
    }
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_party",jsonTable)
end

function Platform:getLang()
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_getLang")
	if ok == true then return ret end
	return "cn"
end


function Platform:uploadError(paras) 
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_uploadError",paras)
end

function Platform:sdkAccountLogin(paras)
	
    print("paras.typeparas.typeparas.typeparas.type:"..paras.type)
	local ok,ret 
	if paras.type== 1 then
		ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_sdkAccountLogin",{ type = paras.type , cb = function(info)
			 local info = qf.json.decode(info)
			 paras.cb(info)
		end})
	elseif paras.type == 3 then--微信登陆

		ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_sdkAccountLogin",{ type = paras.type , cb = function(info)
			 local info = qf.json.decode(info)
			 self:getWXToken(info.code,function (data) 
                local data = qf.json.decode(data)
                if not data or not data.expires_in then
                    dump(data)
                    return 
                else 
    			 	data.type = paras.type
                    if not data.expires_in then
                        data.expires_in = 0 
                    end
    			 	data.date = os.time() + tonumber(data.expires_in)
    			 	data.token = data.access_token
    			 	paras.cb(data)
                end
			 end)
		end})
	end
	--local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"sendMail",{subject="subject",body="body"})
	
	--local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"sendSms",{subject="subject",body="smsbody"})
end

function Platform:getWXCode(paras)
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_sdkAccountLogin",paras)
end

function Platform:sdkShare( paras )
    local args = {
    	share=paras.share, --1只分享大图  2是图文链接
    	scene=paras.scene, --1发消息 2是朋友圈或qq空间
        localPath=paras.localPath, --本地图片绝对路径
        type=paras.type, --1是QQ,3微信
        targetUrl=paras.url  or GameTxt.share_url_ios, --打开的链接
        description=paras.description, --描述
        title=GameTxt.share_game_name_ios, --标题
        cb = function( info )
            if paras.cb then
               paras.cb(info)
            end
        end
    }
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_sdkShare",args)
end


--- paras = {subject="subject",body="body"}
function Platform:sendMail(paras) 
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_sendMail",paras)
end

-- paras = {body="body"}
function Platform:sendSms(paras) 
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_sendSms",paras)
end

function Platform:inviteFriend(paras)
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_inviteFriend",paras)
end

function Platform:sendInvite(paras)
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_sendInvite",paras)
end


function Platform:sharePic(paras)
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_sharePic",paras)
end

-- --[--反馈--]
-- function Platform:feedBack(paras)
-- 	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"feedBack",{})
-- end


--[--反馈--]
function Platform:feedBack(paras)
    local uin = Cache.user and Cache.user.uin
    local nick = Cache.user and Cache.user.nick
    --获取未读反馈信息条数
    local close_cb = function(ret)
        self:feedBackUnreadRequst()
    end
    local paras = {
        uin = uin and "ID:"..uin or "德州用户ID"
        , nick = nick or "德州用户昵称"
        , close_cb = close_cb
    }
  local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_feedBack",paras)
end

function Platform:feedBackUnreadRequst()
    --获取未读反馈信息条数
    -- local cb = function(count)
    --     -- count = 10
    --     Cache.globlInfo:saveDataByName("feedback_unread", tonumber(count))
    --     qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="feedback",number=Cache.globlInfo:takeDataByName("feedback_unread")})         
    -- end
    -- local args = {cb=cb}
    -- local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"AlibaichuanUnreadRequst",args)
end

--[[-- 传入uin 用于umegn注册--]]
--function Platform:umengPushAgent(paras)
--
--end
--[[--直接退出游戏--]]
function Platform:exitGame()
--    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"exitGame",{})
end

--[[--更新游戏--]]
function Platform:updateGame()
end

function Platform:restartGame()
end

function Platform:initWxAndQQShow()
	QQ_CAN_SHOW, WX_CAN_SHOW = false, false
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_initWxAndQQShow",{})
	if ok == true then
		QQ_CAN_SHOW = ret.QQ_CAN_SHOW == "1"
		WX_CAN_SHOW = ret.WX_CAN_SHOW == "1"
	end
end

function Platform:getWXToken(code,callback)--暂时放这里
    self._startupTime = os.time()
    --local reg = qf.platform:getRegInfo()--为了给GAME_PAKAGENAME等变量赋值
    local schdule = cc.Director:getInstance():getScheduler()

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local ok1, APPID = luaoc.callStaticMethod(self.CLASSNAME,"syyy_getWxAppId")
    -- local ok2, SECRET = luaoc.callStaticMethod(self.CLASSNAME,"getWxSecret") -- 客户端不在配置2016/04/19
    local CODE=code
    local url = HOST_PREFIX.."%s/wx/get_access_token?code=%s&appid=%s"
    url = string.format(url, HOST_NAME, CODE, APPID)
    local time = 10
    xhr:open("GET", url)

    local funcID
    local function _timeout ()  -- 失败或超时
        schdule:unscheduleScriptEntry(funcID)
    end

    funcID = schdule:scheduleScriptFunc(_timeout,time,false)   
 
    local function onReadyStateChange()  -- 成功
        if xhr.responseText == "" then 
            return
        end
        schdule:unscheduleScriptEntry(funcID)
        callback(xhr.responseText)

    end 
    xhr.timeout = time
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

--是否支持手机绑定
function Platform:isSmsVerificationEnabled()
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_isSmsVerificationEnabled",{})
    if ok then
        return ret == 1 and true or false
    else
        return false
    end
end

--[[获取短信验证码. 
        函数参数: paras.zone, 区号; paras.phone: 手机号; paras.cb:回调函数
        回调入参: success:是否成功; message,附带信息,当成功时message=短信验证码已发送至xxx,失败时返回错误信息
        示例:
            qf.platform:getSmsVerificationCode({paras.zone="86", paras.phone="158****1111", function(success, message)
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = message})
            end})
]]
function Platform:getSmsVerificationCode(paras)
    local args = { 
        zone=paras.zone,
        phone=paras.phone,
        cb = function(success, message)
            local msg = ""
            if success then
                msg = string.format(GameTxt.get_verification_code_success, paras.phone)
            else
                msg = (message ~= nil and string.len(message) > 0) and message or GameTxt.get_verification_code_failed
            end
            if paras.cb then paras.cb(success, msg) end
        end
    }
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME, "syyy_getSmsVerificationCode", args)
end

--[[获取语音验证码,参数同短信验证码]]
function Platform:getVoiceVerificationCode(paras)
    local args = {
        zone=paras.zone,
        phone=paras.phone,
        cb = function(success, message)
            local msg = ""
            if success then
                msg = GameTxt.get_voice_verification_code_success
            else
                msg = (message ~= nil and string.len(message) > 0) and message or GameTxt.get_voice_verification_code_failed
            end
            if paras.cb then paras.cb(success, msg) end
        end
    }
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME, "syyy_getVoiceVerificationCode", args)
end

--[[--调用微信分享SDK--]]
function Platform:shareToWeixinForIOS(paras)
    logd(" ---- weixinforIOS  ---- ios end")
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_shareToWeixinForIOS",{})
end

-- paras = {body="body"}
function Platform:sendSms(paras) 
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_sendSms",paras)
end

function Platform:getMusicSet()
    return true    
end

--[[--绑定jpush 的alias--]]
function Platform:bindPushAlias(paras) 
    if GAME_VERSION_CODE < 631 then
        return
    end
    paras.uin = paras.uin..""
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_bindPushAlias",paras)
end

function  Platform:pushAddTag(paras)
    if GAME_VERSION_CODE < 631 then
        return
    end
    tags = {}
    tags.tag = paras
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_pushAddTag",tags)
end

function  Platform:pushDeleteTag(paras)
    if GAME_VERSION_CODE < 631 then
        return
    end
    tags = {}
    tags.tag = paras
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_pushDeleteTag",tags)
end

function  Platform:listenKeyboardShow(paras)

    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_listenKeyboardShow",paras)
end
function  Platform:listenKeyboardHide(paras)

    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_listenKeyboardHide",paras)
end

function  Platform:closeKeyboard(paras)

    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_closeKeyboard",paras)
end

function  Platform:openKeyboard(paras)

    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_openKeyboard",paras)
end
function  Platform:getSystemVersion(paras)

    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_getSystemVersion",paras)
    if ok then
        return ret
    end
end
function Platform:isEnabledWifi(args)
    tags = {}
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_isEnabledWifi",tags)
    if ok then
        return ret == 1
    end
    return false
end
--获得WiFi信号强度
function Platform:getWifiSignal(args)
    tags = {}
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_getWifiSignal",tags)
    if ok then
        return ret 
    end
    return -200
end
-- 是否连接了gprs
function Platform:isEnabledGPRS(args)
    tags = {}
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_isEnabledGPRS",tags)
    if ok then
        return ret == 1
    end
    return false
end
--获取剩余电池电量(0-100)
function Platform:getBatteryLevel()
	tags = {}
	local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_getBatteryLevel",tags)
	if ok then
		return ret
	else
		return 0
	end 
end


function Platform:td_onRegister(uid)
    -- local paras = {}
    -- paras.uid = tostring(uid)
    -- local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_td_onRegister",paras)
end

function Platform:td_onLogin(uid)
    -- local paras = {}
    -- paras.uid = tostring(uid)
    -- local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_td_onLogin",paras)
end

function Platform:sendUinToBugly(uin)
    local paras = {}
    paras.uin = uin
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_sendUinToBugly",paras)
end

-- 开始语音识别
function Platform:startVoiceRecognition(paras)
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_startVoiceRecognition", {cb=paras.cb})
    if ok then
		return ret
	else
		return 0
	end
end
-- 结束语音识别
function Platform:finishVoiceRecognition()
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_finishVoiceRecognition", {})
end
-- 取消语音识别
function Platform:cancelVoiceRecognition()
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_cancelVoiceRecognition", {})
end
-- 获取用户输入音量
function Platform:getVoiceRecognitionVolume()
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_getVoiceRecognitionVolume", {})
    if ok then
		return ret
	else
		return 0
	end
end

function Platform:getNetworkType()
    return 2  
end
function Platform:getDeviceId( ... )
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_getIDFA")
    return ret
end

function Platform:haimaSDKLogin(paras)
    local ok,ret 
    ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_haimaLogin",{cb = function(info)
        local info = qf.json.decode(info)
        paras.cb(info)
    end})
end

function Platform:print_log( string )
    -- body
end

function Platform:createQRCode(paras)
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_createQRCode",paras)
end

--版本更新 paras 需要参数 url
function Platform:versionUpdate(paras)
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_versionUpdate",paras)
end

function Platform:getExternalPath () 
    return ""
end

function Platform:removeDir( dir )
    local args = {path=dir}
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME, "syyy_removeDir", args)
end

function Platform:openWXMiniProgram(  )
    local info = self:getRegInfo()

    if tonumber(info.version) < 621 then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = GameTxt.need_update_version})
        return
    end
    local ok,ret = luaoc.callStaticMethod(self.CLASSNAME,"syyy_openMiniProgram",{uin = Cache.user.uin})
end

--数据上报
function Platform:uploadEventStat(args)
    local regInfo = self:getRegInfo()
    local postInfo = {
        source = args.source,
        channel = regInfo.channel,
        version = regInfo.version,
        os = regInfo.os,
        res_version = RES_VERSION,
        path = "",
        session_id = regInfo.uuid,
        uin = Cache.user.uin,
        module = args.module,
        event = args.event,
        value = args.value,
        custom = args.custom,
        extend = args.extend, --以{key:value}的形式
    }

    local xhr = cc.XMLHttpRequest:new()
    xhr:setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    xhr:setRequestHeader("Accept", "application/json")
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("POST", HOST_PREFIX .. HOST_UPLOAD_EVENT_STAT_NAME)

    function onReadyStateChange()
        if xhr.readyState == 4 and xhr.status == 200 then
            dump("上传统计成功")
        else
            dump("上传统计失败")
        end
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send("data=" .. qf.json.encode(postInfo))
end

function Platform:sdkUpdatePlayerInfo(params)
end

function Platform:registerWXAPP()
end

return Platform

