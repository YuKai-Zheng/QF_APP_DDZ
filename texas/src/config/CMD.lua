
CMD = {}
--游戏内逻辑 start
CMD.WX_REG = 17 -- 微信登陆
CMD.OPPO_REG = 29 -- OPPO登陆

--游戏内逻辑 end
--应用逻辑协议 start--
CMD.REG = 2  --【合服修改】
CMD.LOGIN = 3 --用户登录
CMD.HEARTBEAT = 7 -- 【合服修改】
CMD.LOGOUT = 11 --注销
CMD.CONFIG = 31 --获取config配置信息
CMD.APPCONFIG = 9015 --获取appConfig配置信息   --【合服新增修改】
CMD.ZERO_CONFIG = 32 --获取0点config配置信息
CMD.USER_MODIFY = 35

CMD.TASKLIST = 9033  -- 任务列表--【合服新增修改】
CMD.TASKREWARD = 9034 --领取任务奖励 --【合服新增修改】
CMD.COLLAPSE_PAY = 60--破产补助
CMD.GET_COLLAPSE_PAY = 61--破产补助领钱
--应用逻辑协议 end--

CMD.CHAT = 145
CMD.CHAT_NOTICE_EVT = 146

CMD.BROADCAST_OTHER_EVT = 9039 --全区广播通知 【合服修改】
CMD.BAROADCAST_DIM_EVT = 149--服务器所有下发金币的通知

CMD.USER_INFO = 160 --【合服修改】
-- CMD.USER_INFO_smallGame = 160 --【合服修改】
CMD.ICON_FRAME_LIST_EVT = 30055  --头像框列表
CMD.ICON_FRAME_USE_EVT = 30056  --使用头像框
CMD.ICON_FRAME_CHANGE_EVT = 30057  --头像框变化通知

CMD.UPDATA_GOLD_EVT = 190
CMD.EVENT_OTHER_GOLD_CHANGE = 194       -- 牌桌内其他用户金币变化  --已弃用
CMD.GET_FINISH_ACTIVITY_NUM_EVT = 203 --获取已完成活动的个数
CMD.EVENT_SCORE_CHANGED = 303  -- 通知： 积分变化
CMD.ACTIVITY_FINISHED_REQ = 7078 --   活动完成请求

CMD.APPLY_REWARD_CODE = 5010 -- 请求奖励码 奖励
CMD.GENERAL_NOTICE = 9040 --服务器通用通知 【合服更改】

CMD.CMD_GET_LUCKY_WHEEL_REWARD = 9029   -- 抽取幸运转盘奖励 --【合服更改】
CMD.CMD_GET_CUMULATE_LOGIN_REWARD = 9028   --累计登陆 --【合服更改】

--------------------- 金花场专用 ----------------------------#
CMD.EVENT_USER_DAOJU_CHANGE = 192       --# 用户道具变化

--------------------- 百人场专用end ----------------------------#

--------------------- 签到转盘cmd -----------------------------#

CMD.CMD_USER_BROADCAST = 147 --喇叭发送

CMD.CMD_GET_DAOJU_LIST = 9036  --获取道具列表 --【合服更改】

CMD.EVENT_QUERY_DAOJU_BY_ID = 9010   -- 查询道具 --【合服更改】
CMD.EVENT_LOGIN_REWARD_GET = 9023  -- 每日登录奖励领取  --【合服更改】

--------------------- 免费金币 -----------------------------#
CMD.CMD_COMMON_REDTIPS_NOTIFY = 9013  --# 通用小红点通知 【合服修改】
CMD.CMD_QUERY_SCHED_REWARD = 5501  --# 查询定时奖励
CMD.CMD_PICK_SCHED_REWARD = 5502  --# 领取定时奖励
CMD.CMD_QUERY_BROKE_SUPPLY = 5505 --# 破产补助查询

CMD.SCORE_CLIENT_SHARE = 5031 --积分兑换礼品通知
CMD.INVITE_CODE_BE_EXCHANGED = 210 --兑换代码被用户兑换了

CMD.GET_DAY_LOGIN_REWARD_CFG = 9025  -- 拉取每日登录奖励配置 --【合服更改】
CMD.GET_NEW_DAY_LOGIN_REWARD_CFG = 6546  -- 拉取每日登录奖励 --【合服新增】

--------------------- 付费表情start-----------------------------#
CMD.STORE_BUYING_USING_GOLD = 220          --打赏荷官

--------------------- 礼物end ----------------------------#

--------------新美女start-------------------------------------
CMD.GET_BEAUTY_PHOTO_LIST = 206
CMD.REMOVE_BEAUTY_PHOTO = 207
----------------------新美女end---------------------------------

-------------------举报--------------------------
CMD.USER_REPORT = 5510              				--用户举报

-----------------------商城(钻石/金币)--------------------
CMD.USER_DIAMOND_CHANGED = 193          --用户的钻石信息变更
CMD.PRODUCT_EXCHANGE_BY_DIAMOND = 9037   --用钻石兑换金币/道具 【合服修改】
CMD.PUSH_USER_ACTION_STATS = 320        --用户行为上报

CMD.CMD_INTERACT_PHIZ = 6522 -- #互动表情  【合服修改】
CMD.CMD_INTERACT_PHIZ_NTF = 311 -- #互动表情 【合服修改】

-----------------用户游戏数据-------------------
CMD.GET_USER_GAME_INFO = 232

--奖券start
CMD.GET_WELFARD_INDIANA_LIST = 9019 --返回福利夺宝及兑换列表  【合服更改】
CMD.WELFARE_INDIANNA_RECORD = 6555 --夺宝领取记录 【合服更改】
CMD.IN_INDIANA = 7004 --参与夺宝
-- CMD.EXCHANGE_WELFARE = 9020 --申请奖券兑换
CMD.EVT_USER_FOCARD_CHANGE =7551 --奖券变化通知-  【合服更改】
CMD.EVETNT_USER_RECORD_INFO = 7006 --兑换/夺宝记录用户信息
CMD.HIS_INDIANA_RECORD = 7007 --往期得主
--奖券end

--邀请
CMD.BIND_INIVTE = 77
CMD.GET_INVITE_REWARD = 79
CMD.GET_INVITE_RECORDS = 80
-- 奖励推送
CMD.UPDATE_AWARD_NUM = 7009


--排行榜
CMD.APPGOLDWORLDRANKRSP = 9017 --【合服更改】
CMD.APPGOLDFRIDENDANKRSP = 9018 --【合服更改】

--退赛奖励查询
CMD.DDZMatchQuitQuery = 7553 --【合服更改】
--退赛申请请求
CMD.DDZMatchQuitApplyReq = 9035 --【合服更改】
--使用等级卡
CMD.DDZMatchLevelCardUsedReq = 7560 --【合服更改】
--------------------- 推广员 ----------------------
CMD.GET_PROMOTE_REQ		= 9026 --查询推广信息 【合服更改】
CMD.RELATE_TO_PROMOTER_REQ	= 9027 --填写推荐人 【合服更改】

CMD.BAND_WEIXIN_REQ = 9038  -- 绑定微信 【合服更改】

-----------------------刮刮卡-----------------------------
CMD.GUAGUACARD_SITE_LIST = 9000 -- 投注站地址列表
CMD.GUAGUACARD_DETAIL_INFO_REQ = 9003 --  刮刮卡详情 【合服更改】
CMD.GUAGUACARD_DETAIL_INFO_RSP = 9004 --  刮刮卡详情 【合服更改】

CMD.CHECK_USERID_REQ = 9005 --  实名认证 请求 【合服更改】
CMD.CHECK_USERID_RSP = 9005 --  实名认证 返回 【合服更改】

CMD.QUERYCARDSREMEMBERINFO = 9021 --  查询记牌器价格 请求 【合服更改】

CMD.ALLACTIVITYTASK = 9024 -- 获得所有活动及任务信息--cmd:9024  【合服更改】

CMD.FIRSTRECHARGE_INFO  = 9047 -- 首冲6元奖励详情 9031 【合服更改】
CMD.FIRSTRECHARGE_SUCCESS_INFO  = 9048 -- 首冲6元成功奖励详情 【合服更改】

CMD.FREE_WEIXINSHARE_REQ = 9032 -- 免费——微信分享 【合服更改】
CMD.FREE_WEIXINSHARE_RSP = 9032 -- 免费——微信分享 【合服更改】

CMD.DDZBANKRUPTPTOTECTRSP  = 6527 -- 破产保护弹窗 cmd 6527

CMD.HALL_SELECT_PLAY = 601  --金币场选场大厅的在线人数
------------------------------------------
----------------普通场--------------------
------------------------------------------
CMD.INPUT 						= 6500  --用户主动进桌、换桌
CMD.INPUT_GAME_EVT    			= 6512	--进桌通知

CMD.CHANGE_TABLE 					= 6541 	--点击换桌

CMD.READY_REQ         			= 6528	--游戏准备

CMD.USER_READY 					= 6529  --游戏准备通知

CMD.USER_EXIT_REQ					= 6502  --用户主动退桌
CMD.QUIT 							= 6513  --退桌通知

CMD.GAME_START_EVT 				= 6509  --游戏开始

CMD.CALL_POINTS_REQ   			= 6504	--叫分/抢地主
CMD.MATCH_USER_CALL_NTF 			= 6508  --叫分/抢地主通知

CMD.CALL_DOUBLE_REQ 				= 6514  --加倍请求
CMD.CALL_DOUBLE_NTF 				= 6515	--加倍通知

CMD.QUERY_DESK 					= 6516  --查询牌桌
CMD.USER_TIMER_TIME_OUT_REQ 		= 6521  --客户端玩家定时器超时

-- 集成一个接口
CMD.AUTO_PLAY_REQ				= 6505	--托管/取消托管

CMD.USER_AUTO_PLAY_NTF			= 6511	--用户进入托管

CMD.OUT_CARDS_REQ					= 6506	--出牌
CMD.OUT_CARDS_NTF					= 6510	--出牌

CMD.OPUSER_NOTIFY					= 6539 	--通知该抢地主了

CMD.SHOW_CARD_IN_GIVE_CARD 		= 6530  --发牌过程中明牌
CMD.SHOW_CARD_NTF					= 6531 	--明牌通知

CMD.DESK_MULTI_REQ				= 6532 	--查询牌桌倍数信息
CMD.DESK_MULTI_CHANGE_NOTIFY 		= 6533  --牌桌内倍数变化

CMD.ROOM_CHECK_REQ 				= 6534 	--进桌前检测是否进去了其他场次
CMD.CHECK_GOLD_LIMIT_REQ			= 6548  --检测能进的场次

CMD.GAME_END    					= 6507  --游戏结算（经典场和比赛场都是走这里）

------------------------------------------
-------------万元争霸赛-------------------
------------------------------------------
CMD.IS_HIGH_MATCH_LEVEL			= 6577 	--判断最高等级是不是可以打

CMD.MATCH_CHANGE_DESK_REQ   		= 7541  --换桌
CMD.MATCH_EXIT_DESK_REQ 			= 7502  --退桌

CMD.MATCH_USER_CALL_REQ 			= 7504  --叫分
CMD.MATCH_AUTO_PLAY_REQ 			= 7505  --托管
CMD.MATCH_OUT_CARDS_REQ 			= 7506  --出牌
CMD.MATCH_CALL_DOUBLE_REQ 		= 7514  --加倍请求
CMD.MATCH_QUERY_DESK				= 7516  --查询桌子，用于后台切回前台使用
CMD.MATCH_USER_TIMER_TIME_OUT_REQ = 7521  --用户定时器超时

CMD.MATCH_DESK_MULTI_REQ			= 7532 	--查询牌桌倍数信息
CMD.MATCH_CHECK_GOLD_LIMIT_REQ    = 7548  --场次金币检测
CMD.MATCH_GAME_DETAIL_INFO_REQ	= 7549  --查询赛事对局详情


------------------------------------------
-------------公共逻辑-------------------
------------------------------------------
CMD.QUICK_START     				= 602   --快速开始（直接返回roomid）
CMD.SYN_FORTUNE_INFO				= 200   -- cmd:200同步人员的财产信息。 比如同步人员金币信息到客户端，后续可拓展其他

--cmd: 6630 获得加倍信息
CMD.BEI_INFO_UPDATE = 6630

CMD.NEW_USER_PLAY_REWARD = 9041
CMD.APP_NEW_USER_GIFT = 9042
CMD.CMD_INGAME_BUY = 9043

CMD.GAME_TASK_REQ = 9044
CMD.GAME_TASK_CHANGE_NTF = 9045
CMD.GAME_TASK_REWARD_REQ = 9046

--新赛事协议
CMD.NEWEVENT_ENTER_ROOM_REQ = 30000         --进桌请求
CMD.NEWEVENT_EXIT_ROOM_REQ = 30002          --退桌请求
CMD.NEWEVENT_CALL_REQ = 30004               --叫地主请求
CMD.NEWEVENT_AUTO_PLAY_REQ = 30005          --托管请求
CMD.NEWEVENT_DISCARD_REQ = 30006            --出牌请求
CMD.NEWEVENT_USER_MUTI_REQ = 30007          --加倍请求
CMD.NEWEVENT_QUERY_DESK_REQ = 30008         --牌桌查询请求
CMD.NEWEVENT_OP_TIMEOUT_REQ = 30009         --玩家超时请求
CMD.NEWEVENT_DESK_MUTI_REQ = 30011          --牌桌倍数请求
CMD.NEWEVENT_GET_DESK_MUTIINFO_REQ = 30014  --牌桌倍数数据请求
CMD.NEWEVENT_SHOW_CARD_REQ = 30015          --牌桌明牌请求
CMD.NEWEVENT_CHANGE_DESK_REQ = 30012        --牌桌继续挑战请求
CMD.NEWEVENT_SHOW_CARD_NTF = 7531           --新比赛场明牌通知

CMD.MATCH_HALL_INFO = 30050
CMD.MATCH_GUIDE_REQ = 30051

CMD.NEWEVENT_OPEN_BOX_REQ = 30052           --使用宝箱
CMD.NEWEVENT_SAVESTAR_REQ = 30017           --保星请求

CMD.MATCH_RANK_REQ = 30061                  --排行榜数据请求
CMD.NEWEVENT_LEVEL_CHANGE_NTF = 30062       --段位变化通知

CMD.DDZLITTLE_REDDOT_NTF = 180   --红点点通知

CMD.TUIGUANG_INFO_REQ = 9049 --推广活动信息
CMD.TUIGUANG_REWARD_REQ = 9051  --推广领奖请求
CMD.TUIGUANG_INFO_NTF   = 9050  --推广更新通知
CMD.TUIGUANG_FRIEND_REQ = 9052  --推广好友数据请求
--兑换商城
CMD.EXCHANGE_INFO_REQ = 6552    --获取兑换商品的信息

CMD.EXCHANGE_WELFARE = 6553 --申请奖券兑换
CMD.EXCHANGE_USER_INFO = 6554 --保存用戶地址等信息

