
---- 存放相关配置项

SERVERIP= nil
SERVERPORT= nil

ENVIROMENT_TYPE	= 2     -- 1是生产环境 2是测试环境

if ENVIROMENT_TYPE == 1 then
	HOST_PREFIX = "https://"
	HOST_CN_NAME = "wxddz.qfun.com"
	-- HOST_PAY_RELEASE_NAME = "ddz-pay-https.quyifun.com"
	HOST_PAY_RELEASE_NAME = "pay.qfun.com"	
	HOST_PAY_NOTIFY_NAME = "wxddz.qfun.com"
	HOST_UPLOAD_EVENT_STAT_NAME = "open-tongji.qfun.com/stat/event_track"
else
	HOST_PREFIX = "http://"
	HOST_CN_NAME = "wxddz-test.qfun.com"--"192.168.100.27:31400" --
	-- HOST_PAY_RELEASE_NAME = "wxddz-test.qfun.com:25100"
	HOST_PAY_RELEASE_NAME = "pay-test.qfun.com"
	HOST_PAY_NOTIFY_NAME = "wxddz-test.qfun.com"
	HOST_UPLOAD_EVENT_STAT_NAME = "wxddz-test.qfun.com:8200/stat/event_track"
end

HOST_SHARE_NAME = HOST_PREFIX .. HOST_CN_NAME
HOST_HW_NAME = "texas-hw.qfighting.com"

FULLSCREENADAPTIVE = true
FIRST_LOGIN = true --判断游戏是不是没有连上服务器过
CHANNEL_NEED_WEIXIN_BAND_FLAG = false --渠道是否需要微信綁定
VERIFY_TXT_NEED = true  --是否显示资质信息

FORCE_ADJUST_GAME = false
GAME_RADIO = 0.5625
GAME_DEAFULT_RADIO = 0.6

PF_WINDOWS = false
UNITY_PAY_SECRET = QNative:shareInstance():getKey()

GAME_BASE_VERSION = "1.0.0"
GAME_LANG = "cn"

SHOCK_SETTING = cc.UserDefault:getInstance():getBoolForKey(SKEY.SETTINGS_SHOCK,true) --是否开启了震动
BOL_AUTO_RE_CONNECT = true -- 标记：被踢下线后返回到登录界面，是否要弹出提示框

RES_VERSION = 690001
