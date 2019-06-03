
-------Constants.lua 
-------用来放置全局用到的常量

UserStatus = UserStatus or {}

UserStatus.USER_STATE_NORMAL = 1000 --// 不存在(进入游戏时初始化时的默认状态)
UserStatus.USER_STATE_STAND = 1010 --// 旁观中
UserStatus.USER_STATE_STAND_WAIT = 1015 --// 站着等
UserStatus.USER_STATE_READY = 1020 --// 坐下，如果已经开局，那么是不能操作的
UserStatus.USER_STATE_INGAME = 1030 --//  玩游戏中
UserStatus.USER_STATE_ALLIN = 1040 --// allin
UserStatus.USER_STATE_GIVEUP = 1050 --// 弃牌
UserStatus.USER_STATE_LOSE = 1080   --被淘汰(SNG)


-- 游戏状态
GameStatus = GameStatus or {}
GameStatus.NONE = -1 --游戏结束或者没开始或者被踢
GameStatus.READY = 0  -- 准备中
GameStatus.FAPAI = 5  -- 发牌中
GameStatus.CALL_POINT = 10 --叫分中
GameStatus.CALL_DOUBLE = 20 --加倍
GameStatus.INGAME = 30  -- 游戏中

ACCOUNT_BIND_STATUS_GUOPAN = 1
ACCOUNT_BIND_STATUS_QQ = 2
ACCOUNT_BIND_STATUS_FB = 4
ACCOUNT_BIND_STATUS_WX = 8
ACCOUNT_BIND_STATUS_MIGU = 16

--start------------模块开关--------------
TB_MODULE_BIT = {
	MODULE_BIT_STORE 	= 1,		-- 商城模块
	MODULE_BIT_EASY_BUY = 2,		-- 场内-快捷支付
	MODULE_BIT_KNAPSACK = 4,		-- 道具
	MODULE_BIT_ACTIVITY = 8,		-- 活动
	MODULE_BIT_REVIEW 	= 16,	-- 审核
	MODULE_BIT_SPECIAL_PAY = 64, -- 1000、2000元订单隐藏
	MODULE_BIT_STORE_TAB = 128, -- 其他页签关闭：金币购买、道具超市、兑换专区
	MODULE_BIT_STORE_BANNER = 256, -- 商城banner（广告条）关闭
	MODULE_BIT_EXCHANGE_FUCARD = 512, --奖券兑换中心
    MODULE_BIT_BROADCAST_SYS_MSG  = 1024, --系统消息广播
    MODULE_BIT_TUIGUANG = 8192, --推广赚钱
	BOL_MODULE_BIT_STORE = false, -- 商城模块-根据 MODULE_BIT_STORE 取值
	BOL_MODULE_BIT_EASY_BUY = false, -- 快捷支付-根据 MODULE_BIT_EASY_BUY 取值
	BOL_MODULE_BIT_KNAPSACK = false, -- 道具-根据 MODULE_BIT_KNAPSACK 取值
	BOL_MODULE_BIT_ACTIVITY = false, -- 活动-根据 MODULE_BIT_ACTIVITY 取值
	BOL_MODULE_BIT_REVIEW = false, -- 审核开关-根据 MODULE_BIT_REVIEW 取值
	BOL_MODULE_BIT_REVIEW1 = false, -- 审核开关-根据 MODULE_BIT_REVIEW 取值
	BOL_MODULE_BIT_SPECIAL_PAY = false, -- 1000、2000元订单隐藏
	BOL_MODULE_BIT_STORE_TAB = false, -- 其他页签关闭：金币购买、道具超市、兑换专区
	BOL_MODULE_BIT_STORE_BANNER = false, -- 商城banner（广告条）关闭
	BOL_MODULE_BIT_EXCHANGE_FUCARD = false, --  奖券兑换中心
	BOL_MODULE_BIT_BROADCAST_SYS_MSG = false, -- 系统消息广播
    BOL_MODULE_BIT_STORE_EXCHANGE = false, -- 商城兑换页面控制
    BOL_MODULE_BIT_TUIGUANG = false --推广赚钱
}
--end------------模块开关-----------------

--退桌原因
GameExitReason = {}
GameExitReason.NORMAL = 0      --玩家主动发起退桌
GameExitReason.OVER = 1        --牌桌正常结束
GameExitReason.KICK = 2        --被房主踢出房间
GameExitReason.TIMEOUT = 3     --长时间未准备
GameExitReason.MATCH_TIMEOUT = 4     --比赛场超时退桌
GameExitReason.EVENT_OVER = 5  --赛事牌桌解散并退桌

--时间宝箱常量定义
TimeBoxOpcode = {}	--操作码
TimeBoxOpcode.TIMER_START = 1	-- 开始计时
TimeBoxOpcode.TIMER_PAUSE = 2	-- 暂停计时
TimeBoxOpcode.TIMER_RESET = 3	-- 重置计时器
TimeBoxOpcode.TASK_DONE = 4		-- 任务完成,领取奖励
TimeBoxOpcode.TASK_LEVELUP = 5	-- 任务进阶
TIMEBOX_TASK_ID	= 22			-- 时间宝箱任务ID
TIMEBOX_TASK_ID_STR	= "22"		-- 时间宝箱任务ID


--语音识别状态通知
SpeechToTextStatus = {}
SpeechToTextStatus.STT_START_WORK = 0       --识别工作开始
SpeechToTextStatus.STT_END_WORK = 1         --识别工作结束
SpeechToTextStatus.STT_REFRESH_TEXT = 2     --中间结果更新
SpeechToTextStatus.STT_RESULT = 3           --最终结果
SpeechToTextStatus.STT_USER_CANCEL = 4      --用户取消
SpeechToTextStatus.STT_ERROR = 5            --出现错误
SpeechToTextStatus.STT_RECORD_SEC = 100     --录音计时
--语音识别错误码
SpeechToTextErrorCode = {}
SpeechToTextErrorCode.STT_REC_TIMEOUT = 0       --录音超时
SpeechToTextErrorCode.STT_START_TIMEOUT = 1     --等待开始超时
SpeechToTextErrorCode.STT_CONVERT_TIMEOUT = 2   --等待转换超时
SpeechToTextErrorCode.STT_RECORD_TOO_SHORT = 3  --录音时间太短
SpeechToTextErrorCode.STT_DEVICE_PREMISSION = 4 --没有麦克风使用权限
SpeechToTextErrorCode.STT_NETWORK_EXECEPTION = 5--网络连接异常
SpeechToTextErrorCode.STT_UNKONWN_ERROR = 6     --其他错误


NET_WORK_ERROR = {
	TIMEOUT = -200
}
RoomType = {}
RoomType.NORMAL = 1 --经典场
RoomType.BR = 3     --百人场
RoomType.SNG = 6    --SNG比赛场
RoomType.MTT = 7    --MTT比赛场
RoomType.ZJH = 10   --炸金花

GAME_SHOW_UIN_FLAG = false      --默认个人信息不显示用户ID

---------支付/兑换相关常量定义------
PAY_CONST = {}
--商品类型
PAY_CONST.ITEM_TYPE_GOLD = 0
PAY_CONST.ITEM_TYPE_PROP = 3
PAY_CONST.ITEM_TYPE_DIAMOND  = 2
PAY_CONST.ITEM_TYPE_FOCA  = 3 --斗地主里的记牌器

--兑换类型
PAY_CONST.ITEM_CURRENCY_TYPE_GOLD = 0 --用金币去兑换
PAY_CONST.ITEM_CURRENCY_TYPE_DIAMOND = 1  --用钻石去兑换

--热卖信息
PAY_CONST.ITEM_LABEL_TYPE_NONE = 0
PAY_CONST.ITEM_LABEL_TYPE_RECOMMEND = 1
PAY_CONST.ITEM_LABEL_TYPE_HOT = 2


-- 商城内页签
PAY_CONST.BOOKMARK = {}
PAY_CONST.BOOKMARK.GOLD = 0		-- 购买金币
PAY_CONST.BOOKMARK.DIAMOND = 1	-- 购买砖石
PAY_CONST.BOOKMARK.PROPS = 2	-- 购买道具

-- 游戏内商城页签
PAY_CONST.BOOKMARK_ROOM = {}
PAY_CONST.BOOKMARK_ROOM.GOLD = 0	-- 购买金币
PAY_CONST.BOOKMARK_ROOM.DIAMOND = 1	-- 购买砖石
PAY_CONST.BOOKMARK_ROOM.SUPPLY = 2	-- 补充筹码

PAY_CONST.ITEM_LABEL_TYPE_RECOMMEND = 1 --推荐
PAY_CONST.ITEM_LABEL_TYPE_HOT = 2      --热销
--展示的货币类型
PAY_CONST.CURRENCY_GOLD = 0
PAY_CONST.CURRENCY_DIAMOND = 1


--特殊牌型样式对照表           
_SPECIAL_STYLE = {"对子","三条","高牌","两对","顺子","同花",HJ="皇家",JG="金刚",HJTHS="皇家同花顺",HL="葫芦",THS="同花顺"}

-- 登录方式
VAR_LOGIN_TYPE_NO_LOGIN = "0" -- 被踢下线或没有登录过
VAR_LOGIN_TYPE_VISITOR = "-1" -- 游客登录
VAR_LOGIN_TYPE_QQ = "1" -- QQ登录
VAR_LOGIN_TYPE_OPPO = "5" -- oppo登录
VAR_LOGIN_TYPE_BEE = "6" -- 蜜蜂返利登录
VAR_LOGIN_TYPE_HUAWEI = "7" -- 华为登录

--游戏类型
JDC_MATCHE_TYPE = "JDC" --经典场
BRC_MATCHE_TYPE = "BRC" --百人场
SNG_MATCHE_TYPE = "SNG" --SNG场
MTT_MATCHE_TYPE = "MTT" --MTT场
GAME_TBZ        = "TBZ" --退豹子
GAME_NIU_ZHA    = "NIU" --牛牛扎金牛
GAME_NIU_KAN    = "NIUKAN" --牛牛看牌
GAME_ZJH        = "ZJH" --炸金花
GAME_DDZ        = "DDZ" --炸金花
LHD_MATCHE_TYPE = "LHD" --龙虎斗

GAME_DDZ_CLASSIC = 1 --斗地主经典场
GAME_DDZ_FRIEND = 2 --斗地主好友房
GAME_DDZ_MATCH = 3 --斗地主比赛场
GAME_DDZ_ENDGAME = 4 --斗地主残局
GAME_DDZ_NEWMATCH = 5 --新赛事

BATTLE_TYPE_NORMAL  = 1      --1经典场
BATTLE_TYPE_LAIZI = 2        --2.癞子玩法
BATTLE_TYPE_UNSHUFFLE = 3    --3.不洗牌玩法

GAME_START_TYPE = {
	NORMAL= 1,  --正常开始
    SHOW = 2  --明牌开始
}

LIST_ITEM_TIME = 0.08

FORCE_ADJUST_GAME = false
GAME_RADIO = 0.5625
GAME_DEAFULT_RADIO = 0.6

LOGIN_LOADING_ARMATURE_WIDTH = 202  --登录loading动画宽度值