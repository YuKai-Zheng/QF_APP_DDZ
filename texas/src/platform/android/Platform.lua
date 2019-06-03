local Platform = class("Platform")

Platform.TAG = "android-pf"
Platform.CLASSNAME = ANDROID_CLASS_NAME
local luaj = require "luaj"

function Platform:ctor() 

end



function Platform:showExitDialog (paras)
	local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
	local args = {GameTxt.game204,GameTxt.game205,GameTxt.game206,paras.cb}
	local ok = luaj.callStaticMethod(self.CLASSNAME,"exitDialog",args,sigs)
end

function Platform:getAppName()
    local sigs = "()Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getAppName",nil,sigs)
    if ok == true then return ret end
    return ""
end

function Platform:getBaseVersion () 
	local sigs = "()Ljava/lang/String;"
	local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getBaseVersion",nil,sigs)
	if ok == true then return ret end
    return "1.0.0"
end

function Platform:takePhoto(paras) 
    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;III)V"
     local  type=1
     if paras.edit==0 then  type=3 end
    local args = {paras.path,paras.key,paras.url,paras.uin,paras.cb,type}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"uploadPhoto",args,sigs)
end

function Platform:selectPhoto(paras) 
    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;III)V"
     local  type=2
     if paras.edit==0 then  type=4 end
    local args = {paras.path,paras.key,paras.url,paras.uin,paras.cb,type}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"uploadPhoto",args,sigs)
end

function Platform:getRegInfo ()
	local sigs = "()Ljava/lang/String;"
    local info = {}
	local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getRegInfo",nil,sigs)
    print("------------------android  info------------------------1----")
	if ok == true then 
		local reqInfo =  qf.json.decode(ret)
        info.nick = reqInfo.nick
        info.uuid = reqInfo.uuid
        info.device_id = reqInfo.device_id
        info.channel = reqInfo.channel
        info.mac_addr = reqInfo.mac_addr
        info.version = reqInfo.version
        
        GAME_NAME = reqInfo.app_name or "我要斗地主"
        GAME_VERSION_CODE = reqInfo.version or "1"
        GAME_CHANNEL_NAME = reqInfo.channel or "CN_MAIN"
        GAME_PAKAGENAME = reqInfo.pkg_name or "com.qufan.texas"
        if string.find(GAME_CHANNEL_NAME,"CN_SRDZ") ~= nil then
            GAME_SHOW_UIN_FLAG = true    --特殊渠道显示用户id, 并按照NORMAL_001处理
            GAME_CHANNEL_NAME = "CN_NORMAL"
        else
            GAME_SHOW_UIN_FLAG = false
        end
        info.pkg_name = nil
        info.os = "android"
        info.lang = GAME_LANG
        info.res_md5 = STRING_UPDATE_FILE_MD5 -- 更新文件列表的md5
        
        if cc.UserDefault:getInstance():getStringForKey(SKEY.UUID,"") == "" then
            cc.UserDefault:getInstance():setStringForKey(SKEY.UUID,reqInfo.uuid)
            cc.UserDefault:getInstance():flush()
        else
            info.uuid = cc.UserDefault:getInstance():getStringForKey(SKEY.UUID,"")
        end
		if tonumber(reqInfo.version or 0) > 81 then
			local key = self:getKey()
			info.sign = QNative:shareInstance():md5(key.."|"..reqInfo.uuid.."|"..reqInfo.device_id)
		end
        print("------------------android  info-----------------------2-----")
        dump(info)
        return info , reqInfo.deviceSystemVersion
	end
	return nil
end

function Platform:getKey()
	local sigs = "()Ljava/lang/String;"
	local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getKey", nil, sigs)
	if ok == true then return ret end
	return ""
end

function Platform:isDebugEnv()
    local sigs = "()Z"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"isDebugEnv",nil,sigs)
    if ok == true then return ret end

    --默认也应该是 false
    return false
end

--[[--
{url=self.url,x=x,y=y,w=w,h=h,
cb=}]]
function Platform:showWebView(paras)
    local x =  paras.x
    local y = paras.y
    local width = paras.w
    local height = paras.h
    local glview = cc.Director:getInstance():getOpenGLView()
    local designsize = glview:getDesignResolutionSize()
    local framesize = glview:getFrameSize()
    local sx = glview:getScaleX()
    local sy = glview:getScaleY()
    local designframe = cc.size(framesize.width / sx, framesize.height / sy);
    
    --这里可能需要根据ResolutionPolicy进行修改。
    --Modify this ratio equation depend on your ResolutionPolicy.
    local ratio = designsize.height / framesize.height;
    local orig = cc.p((designframe.width - designsize.width) / 2,(designframe.height - designsize.height) / 2)
    
    x = x / ratio + orig.x / ratio
    y = y / ratio + orig.y / ratio
    width = width/ratio
    height = height/ratio
    local sigs = "(Ljava/lang/String;FFFFII)V"
    local args = {paras.url,x,y,width,height,paras.cb,paras.cb2}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"showWebView",args,sigs)
end

function Platform:removeWebView()
    local sigs ="()V"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"removeWebView",nil,sigs)
end

--[[--
    震动的时长 秒
]]
function Platform:playVibrate(paras)
    if SHOCK_SETTING then
        local sigs ="(I)V"
        local args = {paras or 150}
        local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"playVibrate",args,sigs)
    end
end


function Platform:sdkAccountLogin(paras)
    qf.platform:print_log(" ---- sdkAccountLogin ---- , type = "..paras.type,self.TAG)
    local sigs = GAME_VERSION_CODE < 680 and "(II)V" or "(III)V"
    local args
    if paras.type== 1 then
        args = {
        paras.type,
        function(info)
        local info = qf.json.decode(info)
        paras.cb(info)
        end}
    elseif paras.type == 3 then--微信登陆
        args = {
        paras.type,function(info)
            local info = qf.json.decode(info)
            self:getWXToken(info.code,function (data) 

                logd("androdi get weixin userinfo result",data)
                local data = qf.json.decode(data)
                if not data.expires_in or not data.access_token then
                    logd("get weixin userinfo failure",TAG)
                 return 
                end
                data.date = os.time() + tonumber(data.expires_in)
                data.token = data.access_token
                data.type = paras.type
                paras.cb(data)
            end)
        end}
    elseif paras.type == 4 then
        args = {
            paras.type,
            function(info)
                local info = qf.json.decode(info)
                paras.cb(info)
            end
        }
    elseif paras.type == 5 then--OPPO登录
        args = {
            paras.type,
            function(info)
                local info = qf.json.decode(info)
                paras.cb(info)
            end
        }
    end
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"sdkAccountLogin",args,sigs)
end

function Platform:sdkShare( paras )
    logd("---- sdkShare ----, type = ", paras.type, paras.scene, self.TAG)
    local sigs = "(Ljava/lang/String;II)V"
    local args = {
        qf.json.encode({
        share=paras.share, --1只分享大图  2是图文链接
        scene=paras.scene, --1发给朋友 2发朋友圈或qq空间
        localPath=paras.localPath, --本地图片绝对路径
        targetUrl=paras.url or GameTxt.share_url_android, --打开的链接
        description=paras.description, --描述
        title=paras.title or GameTxt.share_game_name_android, --标题
        }),
        paras.type,--1是QQ,3微信
        function( info )
            if paras.cb then
                paras.cb(qf.json.decode(info))
            end
            logd("---- sdkShare result ----")
        end
    }
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"sdkShare",args,sigs)
end

function Platform:sharePic(paras)

end


--[[--

Android 统一支付
{["aws_code"] = "",["cost"] = 2,["cost_desc"] = "2",["cost_type"] = "CNY",["desc"] = "8000金币",
["dianxin_code"] = "E19844113AEF1EB3E0530100007FB34D",["extra"] = 0,["extra_desc"] = 0,["gold"] = 8000,
["google_code"] = "",["item_id"] = "item_2",["liantong_code"] = "",["payType"] = 0,
["sorted_bill_types"] = table[3],["weimi_pay_codes"] = table[3],["wii_code"] = "0001",
["ydmm_code"] = "30000845288901"}
]]
function Platform:allPay(shopInfo)
    local paymethod = shopInfo.paymethod
    local function payCallback(paras)
        if shopInfo.cb then
            shopInfo.cb(shopInfo.paymethod, paras)
        end
    end

    local loginType = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN);
    local jsonTable = {
        bill_type = paymethod,
        user_id = Cache.user.uin.."",
        item_id = shopInfo.item_id,
        proxy_item_id = shopInfo.proxy_item_id,
        cost = shopInfo.cost,
        gold = shopInfo.gold,
        payType = shopInfo.payType,
        name_desc = shopInfo.name_desc,
        ref = shopInfo.ref,
        openid = Util:getQufanLoginInfo().openid,
        diamond = Cache.user.diamond,
        username = Cache.user.nick,
        login_type = loginType
    }
    local channel = GAME_CHANNEL_NAME or "CN_MAIN"
    channel = string.sub(channel,0,2) == "HW" and "_hw" or ""
    local sigs ="(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
    local args = {qf.json.encode(jsonTable),HOST_PAY_NAME,"app_ddz", payCallback}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME, "allPay", args, sigs)
end

--[[--
    android端umeng统计
]]
function Platform:umengStatistics(paras)
    paras.umeng_value = paras.umeng_value or  ""
    paras.umeng_type = paras.umeng_type or 0 --0代表onEvent事件 1代表onEventValue
    local sigs ="(Ljava/lang/String;Ljava/lang/String;I)V"
    local args = {paras.umeng_key,paras.umeng_value,paras.umeng_type}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"umengStatistics",args,sigs)
end

function Platform:requestApplyAuth(paras)
    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;II)V"
    local args = {paras.livePhoto,paras.spotPhoto,paras.url,paras.key,paras.uin,paras.cb}
    logd(" ---- requestApplyAuth ---- anroid")
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"requestApplyAuth",args,sigs)
end

function Platform:getLang () 
    local sigs = "()Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getLang",nil,sigs)
    print("language == "..ret)
    if ok == true then return ret end
    return "cn"
end

--[[-- 传入uin 用于umegn注册--]]
--function Platform:umengPushAgent(paras)
--    local sigs ="(Ljava/lang/String;)V"
--    local args = {(paras.uin or "")..""}
--    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"umengPushAgent",args,sigs)
--end

--[[--直接退出游戏--]]
function Platform:exitGame()
    local sigs ="()V"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"exitGame",nil,sigs)
end

--[[--绑定alias--]]
function Platform:bindPushAlias(paras)
    if GAME_VERSION_CODE < 631 then
        return
    end
    local sigs ="(Ljava/lang/String;)V"
    local args ={paras.uin}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"bindPushAlias",args,sigs)
end

function  Platform:pushAddTag(paras)
    if GAME_VERSION_CODE < 631 then
        return
    end
    local sigs ="(Ljava/lang/String;)V"
    local args = {paras}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"pushAddTag",args,sigs)
end

function  Platform:pushDeleteTag(paras)
    if GAME_VERSION_CODE < 631 then
        return
    end
    local sigs ="(Ljava/lang/String;)V"
    local args = {paras}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"pushDeleteTag",args,sigs)
end

--[[--更新游戏--]]
function Platform:updateGame(paras)
    if paras.url == nil then
    	return
    end
    local sigs ="(Ljava/lang/String;)V"
    local args = {paras.url}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"updateGame",args,sigs)
end

--[[--反馈--]]
function Platform:feedBack(paras)
    local sigs ="(Ljava/lang/String;Ljava/lang/String;)V"
    --友盟
    --local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"umengFeedBack",nil,sigs)
    --阿里百川
    
    local uin = (Cache.user and Cache.user.uin) or "德州用户ID"
    local nick = (Cache.user and Cache.user.nick) or "德州用户昵称"
    local args = {uin, nick}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"alibaichuanFeedBack",args,sigs)
end

function Platform:feedBackUnreadRequst()
    --获取未读反馈信息条数
    -- local cb = function(count)
    --     -- count = 10
    --     if count == "0" then
    --         Cache.globlInfo:saveDataByName("feedback_unread", 0)
    --     else
    --         Cache.globlInfo:saveDataByName("feedback_unread", tonumber(count))
    --     end  
    --     qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="feedback",number=Cache.globlInfo:takeDataByName("feedback_unread")})         
    -- end
    -- local sigs ="(I)V"
    -- local args = {cb}
    -- local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"AlibaichuanUnreadRequst",args,sigs)
end
--[[--上报错误--]]
function Platform:uploadError(paras)
    local sigs ="(Ljava/lang/String;)V"
    local args = {qf.json.encode(paras)}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"uploadError",args,sigs)

    -- 在测试环境下保存错误到本地
    if "1" == paras.debug then
        local content = "\r\n============================================\r\n"
        content = content.."CHANNEL:"..GAME_CHANNEL_NAME
        content = content.." VERSION:"..GAME_VERSION_CODE
        content = content.." TIME:"..os.date("%c", socket.gettime())
        content = content.."\r\n"
        content = content..paras.content
        local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"saveErrorToLocal", {content}, sigs)
    end
end

function Platform:restartGame()
    local sigs ="()V"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"restartGame",nil,sigs)
end

function Platform:getWXToken(code,callback)--暂时放这里
    self._startupTime = os.time()
    local schdule = cc.Director:getInstance():getScheduler()

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local ok1, APPID = luaj.callStaticMethod(self.CLASSNAME,"getWxAppId",nil, "()Ljava/lang/String;")
    -- local ok2, SECRET = luaj.callStaticMethod(self.CLASSNAME,"getWxSecret",nil,"()Ljava/lang/String;")
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

function Platform:getIfScreenFrame( ... )
    -- body
end

function Platform:initWxAndQQShow()
    QQ_CAN_SHOW, WX_CAN_SHOW = false, true
end

function Platform:getMusicSet()
    local sigs = "()I"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getMusicSet",nil,sigs)
    if ok == true then
        return ret == 1
    end
    return true    
end

--是否支持手机绑定
function Platform:isSmsVerificationEnabled()
    local sigs = "()Z"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"isSmsVerificationEnabled",nil,sigs)
    if ok == true then return ret end
    return false
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
    local sigs = "(Ljava/lang/String;Ljava/lang/String;I)V"
    local args = {paras.zone, paras.phone, function(jsonstr)
            local info = qf.json.decode(jsonstr)
            if paras.cb then
                local success = tostring(info.success) == "1"
                local message = ""
                if success then
                    message = string.format(GameTxt.get_verification_code_success, paras.phone)
                else
                    message = (info.message ~= nil and string.len(info.message) > 0) and info.message or GameTxt.get_verification_code_failed
                end
                paras.cb(success, message)
            end
        end}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getSmsVerificationCode",args,sigs)
end

--[[获取语音验证码，参数同获取短信验证码]]
function Platform:getVoiceVerificationCode(paras)
    local sigs = "(Ljava/lang/String;Ljava/lang/String;I)V"
    local args = {paras.zone, paras.phone, function(jsonstr)
            local info = qf.json.decode(jsonstr)
            if paras.cb then
                local success = tostring(info.success) == "1"
                local message = ""
                if success then
                    message = GameTxt.get_voice_verification_code_success
                else
                    message = (info.message ~= nil and string.len(info.message) > 0) and info.message or GameTxt.get_voice_verification_code_failed
                end
                paras.cb(success, message)
            end
        end}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getVoiceVerificationCode",args,sigs)
end


--[[--获取游戏基地的userid--]]
function Platform:gameSpotLogin()
    local sigs = "()Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"gameSpotLogin",nil,sigs)
    if ok == true then
        return ret
    end
    return "-1"
end
-- 获取运营商类型---- 0-无，1-移动，2-联通，3-电信

function Platform:getNetworkType()
    local sigs = "()I"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getNetworkType",nil,sigs)
    if ok == true then
        return ret
    end
    return 0  
end

function Platform:sendSms(paras)
    logd("FaceBook Send sms",self.TAG)
    local sigs = "(Ljava/lang/String;)V"
    local args = {paras.body}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"sendSms",args,sigs)
end
function Platform:isEnabledWifi(args)
    local sigs = "()I"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"isEnabledWifi",nil,sigs)
    if ok then
        return ret == 1
    end
    return false
end
--获得WiFi信号强度
function Platform:getWifiSignal(args)
    local sigs = "()I"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getWifiSignal",nil,sigs)
    if ok then
        return ret 
    end
    return -200
end
-- 是否连接了gprs
function Platform:isEnabledGPRS(args)
    local sigs = "()I"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"isEnabledGPRS",nil,sigs)
    if ok then
        return ret == 1
    end
    return false
end
--获取剩余电池电量(1-100)
function Platform:getBatteryLevel()
	local sigs = "()I"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getBatteryLevel",nil,sigs)
    if ok then
        return ret
    end
    return 100
end


function Platform:td_onRegister(uid)
end

function Platform:td_onLogin(uid)
end

function Platform:sendUinToBugly(uin)
     local paras = {}
     paras.uin = uin
     local sigs = "(Ljava/lang/String;)V"
      local args = {paras}
     --local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"sendUinToBugly",args,sigs)
end

-- 开始语音识别
function Platform:startVoiceRecognition(paras)
    local sigs = "(I)I"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"startVoiceRecognition", {function(str)
        local result = {}
        local split = "&&"
        for match in (str..split):gmatch("(.-)"..split) do
            table.insert(result, match)
        end
        if paras.cb then
            paras.cb(tonumber(result[1]), tonumber(result[2]), result[3])
        end
    end}, sigs)
    if ok then
		return ret
	else
		return 0
	end
end
-- 结束语音识别
function Platform:finishVoiceRecognition()
    local sigs = "()V"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"finishVoiceRecognition", {}, sigs)
end
-- 取消语音识别
function Platform:cancelVoiceRecognition()
    local sigs = "()V"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"cancelVoiceRecognition", {}, sigs)
end
-- 获取用户输入音量
function Platform:getVoiceRecognitionVolume()
    local sigs = "()I"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getVoiceRecognitionVolume", {}, sigs)
    if ok then
		return ret
	else
		return 0
	end
end

function Platform:getDeviceId( ... )
    local sigs = "()Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getDeviceId", {}, sigs)
    return ret
end

function Platform:print_log( string )
    local sigs = "(Ljava/lang/String;)V"
    local args = {string}
    luaj.callStaticMethod(self.CLASSNAME, "print_log", args, sigs)
end

function Platform:createQRCode(paras)
    local sigs = "(Ljava/lang/String;)V"
    local args = {qf.json.encode(paras)}
    luaj.callStaticMethod(self.CLASSNAME,"createQRCode",args,sigs)
end

--版本更新 paras 需要参数 url
function Platform:versionUpdate(paras)
    local sigs = "(Ljava/lang/String;)V"
    local args = {qf.json.encode(paras)}
    luaj.callStaticMethod(self.CLASSNAME,"versionUpdate",args,sigs)
end

function Platform:getExternalPath () 
    local sigs = "()Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"getExternalPath",nil,sigs)
    if ok == true then return ret end
    return ""
end

function Platform:removeDir( dir )
    QNative:shareInstance():rmdir(dir)
end

function Platform:openWXMiniProgram(  )
    local info = self:getRegInfo()

    if tonumber(info.version) < 621 then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = GameTxt.need_update_version})
        return
    end

    local sigs = "(I)V"
    local args = {Cache.user.uin}
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"openWXMiniProgram",args,sigs)
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
    if GAME_VERSION_CODE < 680 then return end
    local sigs = "(Ljava/lang/String;)V"
    local args = {qf.json.encode(params)}
    luaj.callStaticMethod(self.CLASSNAME,"sdkUpdatePlayerInfo",args,sigs)
end

function Platform:registerWXAPP()
    if GAME_VERSION_CODE < 680 then return end
    local sigs ="()V"
    local ok,ret = luaj.callStaticMethod(self.CLASSNAME,"registerWXAPP",nil,sigs)
end

return Platform
