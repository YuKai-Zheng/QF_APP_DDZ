local Platform = class("Platform")

----不同的模拟器需要修改--start----
WINDOWS_REG_INFO = {
    nick = "药不Д能停", --随便填一个
    device_id = "8193" --4位数，随便填，跟别人的不要重复
}
----不同的模拟器需要修改--end----

-- Platform.CURRENT_VERSION = "205"
Platform.CURRENT_VERSION = "690"

function Platform:ctor() 
    
end

function Platform:showExitDialog (paras)
    
end

function Platform:uploadError( paras )
    local fileUtil = cc.FileUtils:getInstance()
    local str = fileUtil:getDataFromFile(cc.FileUtils:getInstance():getWritablePath().."cclog.txt")
    str = str or ""
    local time = os.date("%c", os.time())
    local newStr = paras.content
    str = str .."\n" .. "=============当前时间================".. time .."\n" .. newStr
    io.writefile(cc.FileUtils:getInstance():getWritablePath() .. "cclog.txt", str, "wb")
end


function Platform:getAppName()
    return "欢乐炸金花"
end

function Platform:getBaseVersion()
    return "1.0." .. tostring(self.CURRENT_VERSION)
end


function Platform:takePhoto(paras)
    logd(" --- takePhoto --- ", self.TAG)
end

function Platform:selectPhoto(paras) 
    logd(" --- selectPhoto --- ", self.TAG)
end

function Platform:umengStatistics(paras)
    logd(" --- umengStatistics --- ", self.TAG)
end

function Platform:isDebugEnv()
    if ENVIROMENT_TYPE == 1 then return true end 
    return false 
end

function Platform:getRegInfo ()
    
    GAME_NAME = GameTxt and GameTxt.dft_app_name or ""
    GAME_VERSION_CODE = self.CURRENT_VERSION --版本升级时需要修改
    GAME_CHANNEL_NAME = "CN_AD_APPWYDDZ"
    -- GAME_CHANNEL_NAME = "CN_IOS_APPJN"
    local key = self:getKey()
    local device_id, nick
    ------------------------
    -- 此处是为了配合测试同学进行模拟器测试
    local local_file_path = lfs.currentdir()
    local local_file_split = string.split(local_file_path, "\\")
    local local_file_3th = local_file_split[#local_file_split - 2] --texas
    local lcoal_file_3th_ex = string.sub(local_file_3th, 6, -1)
    lcoal_file_3th_ex = string.match(lcoal_file_3th_ex, "%d+")
    if lcoal_file_3th_ex then
        device_id = checkint(WINDOWS_REG_INFO.device_id) + checkint(lcoal_file_3th_ex)
        device_id = string.format("%04d", device_id)
        nick = "广娇" .. tostring(device_id)
    else
        device_id = WINDOWS_REG_INFO.device_id
        nick = WINDOWS_REG_INFO.nick
    end

    device_id = "CCAEC759-" .. device_id
    local ret = {}     
    ret.version = GAME_VERSION_CODE
    ret.device_id = device_id
    ret.uuid = device_id
    ret.channel = GAME_CHANNEL_NAME
    ret.lang = "cn"
    ret.mac_addr = "d0:7a:b5:e6:9c:a6"
    ret.os = "android"
    ret.nick = nick
    ret.sign = QNative:shareInstance():md5(key .. "|" .. ret.uuid .. "|" .. ret.device_id)
    return ret
end
function Platform:getKey(...)
    local path = "c:\\qf_key.txt"
    if io.exists(path) then
        local key = io.readfile(path)
        return key
    else
        return "wrong_key"
    end
end
function Platform:getIfScreenFrame( ... )
    -- body
end
function Platform:showWebView(paras) 
end

function Platform:removeWebView(paras)
end

function Platform:playVibrate(paras)
    
end

function Platform:allPay(shopInfo)
    
end


function Platform:sdkAccountLogin(paras)
    
end

function Platform:sharePic(paras)
    
end

--[[--
震动的时长 秒
]]
function Platform:playVibrate(paras)
end
function Platform:requestApplyAuth(paras)
end

function Platform:getLang () 
    return "cn"
end

--[[-- 传入uin 用于umegn注册--]]
--function Platform:umengPushAgent(paras)
--end

--[[--直接退出游戏--]]
function Platform:exitGame()
end

--[[--绑定jpush 的alias--]]
function Platform:bindPushAlias(paras)
end

function Platform:pushAddTag(paras)
end

function Platform:pushDeleteTag(paras)
end

--[[--更新游戏--]]
function Platform:updateGame()
end

function Platform:restartGame()
    
end

function Platform:feedBack()
    
end

function Platform:feedBackUnreadRequst()
end
function Platform:initWxAndQQShow()
    
end
function Platform:getMusicSet()
    return true
end

function Platform:sdkShare(paras)
    
end

function Platform:isEnabledWifi(args)
    return false
end
--获得WiFi信号强度
function Platform:getWifiSignal(args)
    return -200
end
-- 是否连接了gprs
function Platform:isEnabledGPRS(args)
    return true
end

--获取剩余电池电量(百分比)
function Platform:getBatteryLevel()
    return 50
end

function Platform:td_onRegister(uid)
end

function Platform:td_onLogin(uid)
end
function Platform:sendUinToBugly(uin)
end

-- 开始语音识别
function Platform:startVoiceRecognition(paras)
    return 0
end
-- 结束语音识别
function Platform:finishVoiceRecognition()
    
end
-- 取消语音识别
function Platform:cancelVoiceRecognition()
    
end
-- 获取用户输入音量
function Platform:getVoiceRecognitionVolume()
    return 0
end

function Platform:getNetworkType()
    return 0 
end

function Platform:isSmsVerificationEnabled()
    return true
end

function Platform:getSmsVerificationCode(paras)
    if paras.cb then
        local message = string.format(GameTxt.get_verification_code_success, paras.phone)
        paras.cb(true, message)
    end
end
function Platform:getVoiceVerificationCode(paras)
    if paras.cb then
        paras.cb(true, GameTxt.get_voice_verification_code_success)
    end
end
function Platform:getDeviceId(...)
    -- body
end

function Platform:print_log(string)
    -- body
end

--是否支持手机绑定
function Platform:isSmsVerificationEnabled()
    return false
end

function Platform:createQRCode(paras)
    -- body
end

function Platform:versionUpdate(paras)
    
end

function Platform:getExternalPath () 
    return ""
end

function Platform:removeDir( dir )
        QNative:shareInstance():rmdir(dir)
end

function Platform:openWXMiniProgram()
end

function Platform:uploadEventStat(args)
end

function Platform:sdkUpdatePlayerInfo(params)
end

function Platform:registerWXAPP()
end

return Platform