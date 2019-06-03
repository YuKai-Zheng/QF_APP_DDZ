
ANDROID_CLASS_NAME="com/qufan/texas/util/Util"
OBJC_CLASS_NAME="LuaMutual"

local pf = import("."..qf.device.platform..".Platform")

qf = qf or {}
qf.platform = pf.new()
-- 经测试发现，微信在这个地方调用，一定是反回false，所以要换个地方调用
--qf.platform:initWxAndQQShow()
--logd("xxxxx QQ_CAN_SHOW: " .. tostring(QQ_CAN_SHOW) .. "WX_CAN_SHOW" .. tostring(WX_CAN_SHOW))

GAME_BASE_VERSION = qf.platform:getBaseVersion()
GAME_PAKAGENAME = "com.hyz.wyddz"
GAME_VERSION_CODE = 1
GAME_CHANNEL_NAME = "HW_MAIN"
qf.platform:getRegInfo()