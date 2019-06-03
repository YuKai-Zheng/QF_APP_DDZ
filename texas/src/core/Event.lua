--[[
    global  event
]]

-- event table
-- global obj

 

ET = {}


-- game Module

ET.NET_GAME_PAYATTENTIONTO_REQ = getUID()
ET.NET_GAME_CANCER_PAYATTENTION_REQ = getUID()
ET.NET_USER_MODIFY_REQ = getUID()
ET.NET_USER_TASKLIST_REQ = getUID()
ET.NET_USER_ACTIVITY_TASKLIST_REQ = getUID()
ET.NET_USER_TASKREWARD_REQ = getUID()
ET.NET_COLLAPSE_PAY_REQ = getUID()
ET.NET_GET_COLLAPSE_PAY_REQ = getUID()
ET.NET_APPLY_REWARD_CODE_REQ = getUID()
ET.NET_USER_INFO_REQ = getUID()

ET.NET_ALL_ACTIVITY_REQ = getUID()
ET.NET_GET_FINISH_ACTIVITY_EVT = getUID()

ET.NET_CHANGEGOLD_EVT = getUID()
ET.NET_DESK_TASK_REQ= getUID()	--拉取牌桌内任务列表
ET.NET_BROADCAST_OTHER_EVT = getUID()
ET.NET_BAROADCAST_DIM_EVT= getUID()--短信充值成功后台回返接口
ET.NET_UPDATA_GOLD_EVT = getUID()
ET.NET_EVENT_OTHER_GOLD_CHANGE = getUID()
--- 选场大厅
ET.UPDATE_CHOSEHALL_HEADIMG = getUID()   --更新选场大厅的头像
--应用逻辑协议 end--


--game proto start--
--[[进入房间]]
ET.NET_INPUT_REQ = getUID() 
--[[进入游戏后 服务端 推送过来游戏内的 详细信息]]
ET.NET_INPUT_GAME_EVT = getUID() 
--[[退出游戏的协议]]
ET.NET_EXIT_REQ = getUID() 
--[[换桌请求]]
ET.NET_CHANGE_DESK_REQ = getUID()

ET.NET_CHAT_REQ = getUID() 
ET.NET_CHAT_NOTICE_EVT = getUID() 


ET.NET_GETCONFIG_DONE = getUID()
ET.NET_AUTO_INPUT_ROOM = getUID()

--other proto end--
ET.GAME_CHANGE_BUTTON_STATUS = getUID()  -- 游戏中改变自己的按钮
ET.GAME_SHOW_USER_INFO = getUID()
ET.GAME_SHOW_CHAT = getUID()
ET.GAME_HIDE_CHAT = getUID()
ET.GAME_SHOW_SHOP = getUID()
ET.GAME_HIDE_SHOP = getUID()
ET.GAME_SHOW_SHOP_PROMIT = getUID()
ET.GAME_PAY_NOTICE = getUID()
ET.NOTIFY_REFRESH_DESK = getUID()
ET.NOTIFY_REFESH_HEADIMG = getUID()

ET.LOGIN_REQUEST_LAST_SERVER = getUID()

ET.GLOBAL_WAIT_NETREQ = getUID()

ET.MAIN_BUTTON_CLICK = getUID()
ET.MAIN_MOUDLE_VIEW_EXIT = getUID()
ET.GLOBAL_GET_USER_INFO = getUID()
ET.GLOBAL_SHOW_USER_INFO = getUID()


ET.GLOBAL_SHOW_BROADCASE_TXT = getUID()
ET.GLOBAL_COIN_ANIMATION_SHOW = getUID()
ET.GLOBAL_DIAMOND_ANIMATION_SHOW = getUID()
ET.GLOBAL_SHOW_BROADCASE_LAYOUT = getUID()
ET.GLOBAL_HIDE_BROADCASE_LAYOUT = getUID()

ET.GLOBAL_FRESH_MAIN_GOLD = getUID()--刷新主界面
ET.GLOBAL_FRESH_LOBBIES_GOLD = getUID()--刷新大厅
ET.GLOBAL_FRESH_CUSTOMIZE_GOLD = getUID() --刷新私人定制大厅
ET.GLOBAL_TOAST = getUID()--吐司

ET.GLOBAL_WAIT_EVENT = getUID() --全屏等待
ET.LOGIN_WAIT_EVENT = getUID()
ET.GLOBAL_HANDLE_BANKRUPTCY = getUID()--弹出破产提示
ET.GLOBAL_HANDLE_PROMIT = getUID() -- 公共框消息处理

ET.MAIN_UPDATE_BNT_NUMBER = getUID()

ET.MAIN_UPDATE_USER_HEAD = getUID()
ET.CHANGE_VIEW_UPDATE_USER_HEAD = getUID()
ET.APPLICATION_ACTIONS_EVENT = getUID()


ET.SHOW_LOGIN = getUID()

ET.MODULE_SHOW = getUID()
ET.MODULE_HIDE = getUID()

ET.REFRESH_SHOP_GOLD = getUID()
ET.GAME_GENERAL_NOTICE = getUID()--通用服务器通知
ET.GAME_WANT_RECHARGE = getUID()--服务器通知关闭webview然后去商城
ET.MAIN_VIEW_DISMISS_ANIMATION = getUID()--主界面模块消失
ET.MAIN_VIEW_SHOW_ANIMATION = getUID()--主界面出现
ET.PRELOAD_JSON_END = getUID()--预加载结束

ET.GLOBAL_SHOW_NEWBILLING = getUID() --显示最新计费界面
ET.GLOBAL_GOTOSHOP_BY_ROOMID = getUID()--根据房间信息选取商品支付
ET.LOBBY_LIST_MOVE = getUID()--大厅控制滑动

ET.SEND_LABA = getUID() -- 发送喇叭
ET.GET_DAOJU_LIST = getUID() -- 获取道具列表
ET.EVENT_USER_DAOJU_CHANGE = getUID() -- 道具发货通知
ET.GLOBAL_CANCELLATION = getUID()--注销功能
ET.GAME_USER_RETURN_INDEX = getUID() --点击坐下的时候返回index


ET.EVENT_LOGIN_REWARD_GET = getUID() --每日登录奖励领取

ET.EVENT_SCORE_CHANGED = getUID() --服务器通知积分变化

ET.EVENT_QUERY_DAOJU_BY_ID = getUID()                  --查询道具数量

ET.REFRESH_LABA_MSG_LIST= getUID()                  --刷新喇叭列表

ET.LOGIN_SIGN_IN = getUID() --登录
ET.LOGIN_NET_GOTO_LOGIN = getUID()

ET.BR_JIFEN_EVT = getUID() --百人场积分通知

ET.GET_TIME_REWARD_INFO = getUID() --查询定时奖励信息
ET.PICK_TIME_REWARD = getUID() --领取定时奖励
ET.GET_POCAN_REWARD_INFO = getUID() --查询破产奖励
ET.GET_NOTICE_INFO = getUID()      --获取系统公告

ET.COMMON_REDTIPS_NOTIFY = getUID() -- 通用小红点通知
ET.REFRESH_FREE_GILD_RED_NUM = getUID() -- 刷新免费金币按钮的小红点

ET.NET_OPEN_INVITE_VIEW = getUID() --打开邀请界面

ET.SHOW_SHARE = getUID() --分享
ET.SHARE_HIDE = getUID() --关闭分享
ET.CHECK_BR_WIN_SHARE = getUID() -- 百人场赢钱分享通知
ET.CHECK_WIN_SHARE = getUID() -- 普通场赢钱分享通知
ET.NET_SCORE_CLIENT_SHARE = getUID() -- 积分兑换礼物分享通知
ET.SHARE_CHECK_SHOW = getUID() -- 积分兑换礼物分享通知
ET.INVITE_CODE_BE_EXCHANGED = getUID() -- 兑换码被兑换通知

ET.GAME_INVITE_FRIEND = getUID() -- 通知客户端打开邀请界面通知
ET.GOTO_ACTIVITY = getUID() -- 跳到指定的活动

ET.SHOW_BEGINNERS_GUIDE= getUID() -- 新的新手引导

ET.SHOW_ACTIVE_NOTICE_VIEW = getUID() --活动弹窗显示
ET.SHOW_ACTIVE_NOTICE = getUID() -- 显示活动公告
ET.HIDE_ACTIVE_NOTICE = getUID() -- 隐藏活动公告

ET.GET_DAY_LOGIN_REWARD_CFG = getUID() -- 获取登录奖励配置

--[[用户更换筹码]]
ET.NET_EXCAHNGE_CHIPS_REQ = getUID() 


--付费表情
ET.NET_STORE_BUYING_USING_GOLD_REQ = getUID() 

--显示通用提示框
ET.SHOW_COMMON_TIP_WINDOW_EVENT = getUID()

-- 更新礼物界面礼物卡余额
ET.UPDATE_VIEW_GIFT_CARD = getUID()


ET.CUSTOMIZE_SETTLE_CLOSE_EVT = getUID()			--私人定制关闭结算
ET.PROFILE_CHANGE_GAME_EVT = getUID()		--游戏中玩家信息修改事件
--[[私人定制 end]]

ET.REWARD_SORT_CHECK = getUID()

----------------------------------  新美女--------------------------
ET.NET_REMOVE_BEAUTY_PHOTO_REQ= getUID() 

ET.GALLERY_UPLOAD= getUID()
ET.NET_DESK_ASK_FEIEND_EVT= getUID()

ET.NET_GET_NICK_REMARK_LIST = getUID() -- 

ET.GET_SCORE_EXCHANGE_LIST = getUID() -- 获取积分兑换列表
ET.REFRESH_SCORE_EXCHANGE_LIST = getUID() -- 刷新积分兑换列表

ET.EVT_SHOW_GAMES_RECORD = getUID() --显示牌局记录

ET.EVT_USER_REPORT            = getUID()   --举报

ET.EVT_AUTO_SUPPLY_CHIPS_REMIND = getUID()  --自动补充筹码到最大提醒

---------------------------------------

ET.GAME_SHARE_CARDS_EVENT = getUID()        --牌桌内公共牌翻开事件

ET.GAME_SHOW_BOUNCE_BTN = getUID()			--显示跳动筹码或金币  1-筹码 2-金币

----------- qufanlogin start ---------
ET.QUFAN_LOGIN_CHANGE_PASSWORD = getUID() -- 趣凡修改密码
----------- qufanlogin end ----------

ET.NET_DIAMOND_CHANGE_GLOBAL_EVT = getUID()     --用户钻石变更消息.
ET.NET_DIAMOND_CHANGE_USERINFO_EVT = getUID()   --个人信息页面钻石变更通知.
ET.NET_DIAMOND_CHANGE_SHOP_EVT = getUID()       --商城信息页面钻石变更通知.
ET.EVENT_SHOP_JUMP_TO_BOOKMARK = getUID() 		-- 商城标签叶卡跳转
ET.EVENT_SHOW_BUY_POPUP_TIP_VIEW = getUID() 	-- 购买提示框
ET.EVENT_SHOW_PAY_METHOD_VIEW = getUID() 		-- 支付方式框
ET.NET_PRODUCT_EXCHANGE_BY_DIAMOND = getUID()   --用钻石兑换金币/道具
ET.EVENT_SHOP_AD_DOWN_FINISH = getUID() 		-- 商城内广告下载完成
ET.EVENT_GAMESHOP_JUMP_TO_BOOKMARK = getUID() 	-- 游戏内商城叶卡跳转
ET.USER_ACTION_STATS_EVT = getUID()             --用户行为统计
ET.REFRESH_BANKRUPTCY_POPUP = getUID()          --钻石发货 更新破产补助弹框

ET.NET_DISCONNECT_NOTIFY = getUID()         --断线重连通知
ET.APPLICATION_RESUME_NOTIFY = getUID()     --后台返回通知

ET.SETBROADCAST = getUID()  --设置喇叭位置
ET.DAILYREWAED  = getUID()  --设置喇叭位置
ET.REALNAME = getUID() -- 完成实名认证


ET.INVITEGAMETIPS = getUID() -- 匹配邀请提示
ET.RECHARGETIPS = getUID() -- 金币不足提示
ET.CHANGEREFUSE = getUID() -- 弹窗拒绝
ET.ACCEPTINVITE = getUID() -- 同意邀请
ET.REMOVETIMEOUT = getUID() -- 移除定时器



ET.BG_CLOSE     = getUID()  --关闭模糊背景
ET.HALL_UPDATE_INFO = getUID()  --大厅更新个人信息
-- ET.INSTALL_GAME  = getUID()  --安装游戏
-- ET.INSTALL_GAME_POP = getUID()  --安装游戏弹窗
ET.NET_DIAMOND_CHANGE_HALL = getUID() --大厅钻石更改
ET.NET_DIAMOND_CHANGE_NIUNIU_HALL = getUID() --斗牛大厅钻石更改

ET.INTERACT_PHIZ_NTF = getUID() -- 互动表情


ET.SHOW_FRIENDTIPS = getUID() -- 桌内好友请求


ET.SHOW_TURNTABLE = getUID() -- 大转盘弹窗
ET.REMOVE_TURNTABLE = getUID() -- 大转盘弹窗
ET.UPDATETURNICON = getUID() --更新大转盘

ET.SHOW_FIRSTGAME = getUID() -- 启动资金弹窗
ET.REMOVE_FIRSTGAME = getUID() -- 启动资金弹窗

ET.SHOW_NEWSLEAD = getUID() -- 消息引导弹窗
ET.REMOVE_NEWSLEAD = getUID() -- 消息引导弹窗

ET.UPDATENEWTOTALLOGINICON = getUID() --更新累计登陆

ET.SHOW_FREEGOLDSHORTCUT = getUID() -- 免费金币快捷领取
ET.MAIN_UPDATE_SHORTCUT_NUMBER = getUID() -- 免费金币快捷领取

ET.EVENT_SHOP_SHOWLOADING = getUID() -- 显示商城loading
ET.SETTING_QUICK_START_CHOOSE_CHANGE = getUID()  --设置界面选择快速开始游戏设置

ET.UPDATE_LOGIN_TIMES = getUID() --重置登录次数

--奖券start
ET.EVT_USER_FOCARD_CHANGE_FOCASVIEW = getUID() --奖券变化通知
ET.EVT_USER_FOCARD_CHANGE_MAINVIEW = getUID() --奖券变化通知
ET.EVT_USER_FOCARD_CHANGE_MATCHING = getUID() --奖券变化通知
ET.EVT_USER_FOCARD_CHANGE_HALLVIEW = getUID() --奖券变化通知
ET.EVT_USER_FOCARD_CHANGE_GAMEVIEW = getUID() --奖券变化通知

ET.GET_WELFARD_INDIANA_LIST = getUID()--进入奖券界面请求数据
ET.EVETNT_USER_RECORD_INFO = getUID()--填写领奖人信息
ET.HIS_INDIANA_RECORD = getUID() -- 请求往期得主
ET.WELFARE_INDIANNA_RECORD = getUID()--夺宝记录和领奖记录
ET.UPDATE_FOCAS_REDPOINT = getUID()--小红点通知
ET.GUAGUACARD_EXCHANGE_SUCCESS = getUID()--刮刮卡兑换成功通知
ET.GUAGUACARD_SITE_LIST = getUID()--刮刮卡投注站地址
--奖券end

-- 邀请可领取奖励数量通知
ET.UPDATE_AWARD_NUM = getUID()

ET.REMOVE_GAME_MATHING_VIEW = getUID()--移除匹配界面
ET.SHOW_GAME_MATHING_VIEW = getUID()--显示游戏匹配界面
ET.UPDATE_GAME_MATHING_VIEW = getUID()--更新游戏匹配界面

ET.DAY_LEVEL_RANK = getUID()--每日排行表
ET.WORLD_LEVEL_RANK = getUID()--总排行表

ET.DDZMATCH_QUIT_APPLY = getUID()--退出奖励
ET.DDZMATCH_LEVEL_CARD_USED = getUID()--使用等级卡
ET.GOLD_CHANGE_RSP = getUID()--金币变化通知
ET.GOLD_CHANGE_RSP_Game = getUID()--金币变化通知

ET.GET_PROMOTE_INFO				= getUID() --获取推广配置信息

ET.EVENT_BAND_WEIXIN = getUID()


ET.EVENT_TIME_BEGIN = getUID()--发送验证码按钮倒计时开始
ET.EVENT_TIME_DOWN = getUID()--发送验证码按钮倒计时中
ET.EVENT_TIME_END = getUID()--发送验证码按钮倒计时结束
ET.TO_BE_PROMOTER = getUID() --成为推广员推送
ET.BEE_NOT_LOGIN = getUID() --蜜蜂登录失效

ET.EVENT_BANNER_GAME_MATCHING = getUID() --万人争霸赛的banner跳转通知

ET.SHOW_BANNER_POP = getUID() -- 显示bannerPop

ET.REFRESH_LISTEN = getUID() -- 刷新大厅的定时器
ET.ACTIVITY_HIDE_WEBVIEW = getUID() --收到服务器关掉webview事件
ET.UPDATE_USER_INFO = getUID() --更新用户信息

ET.FOCAS_TASK_VIEW_SHOW_AND_CLOSE_FACAS_VIEW = getUID()


ET.EVENT_NEWUSER_LOGIN_REWARD_GET = getUID() --新手每日累计登录
ET.EVENT_NEWUSER_LOGIN_REWARD_POP = getUID() --新手礼包弹出活动中心的控制
ET.EVENT_NEWUSER_LOGIN_REWARD_FOCATIPS = getUID() --新手礼包奖券提示
ET.CLOSE_ACTIVE_VIEW = getUID() --关闭活动中心的通知

ET.FIRSTRECHARGE_INFO = getUID() --首冲6元奖励详情
ET.FIRSTRECHARGE_SUCCESS_INFO = getUID() --首冲6元奖励详情


ET.SHOW_FIRSTRECHARGE_POP = getUID() -- 显示首充
ET.HIDE_FIRSTRECHARGE_POP = getUID() -- 隐藏首充

ET.HIDE_FIRSTRECHARGE_ENTRY = getUID() -- 首充入口隐藏
ET.HIDE_FIRSTRECHARGE_ENTRY_hallView = getUID() -- 首充入口隐藏

ET.FIRSTRECHARGE_PAYSUCCESS_REFRESH_SHOP = getUID() -- 首充成功后刷新商品列表

ET.BANKRUPTTIPS = getUID() -- 破产补助提示

ET.DDZBANKRUPTPTOTECTRSP = getUID() -- 破产补助消息提示

ET.DDZBANKRUPTPTOTECTSHOW = getUID() -- 破产补助显示

ET.GET_PROMOTE_NOTICE = getUID() -- 充值推广源通知

ET.DDZMatchLevelChangedRsp = getUID() --等级变化通知 cmd 7055

ET.EVENT_JUMP_TO_COIN_GAME = getUID() --调整到金币场的选场大厅

ET.EVENT_JUMP_QUICK_COIN_GAME = getUID() --调整到金币场的快速开始



ET.EVENT_CLOSE_FOCAS_CENTER = getUID() --关闭奖券中心的通知

ET.EVENT_CLOSE_FOCAS_CENTER_TO_MATHINGE_CENTER = getUID() --关闭奖券信息比赛大厅的通知

ET.EVENT_CLOSE_FOCAS_CENTER_TO_ACTIVE_CENTER = getUID() --关闭奖券信息活动中心的通知

ET.TO_BE_PROMOTER_SUCCESS	= getUID() --充值推广员成功后刷新推广中心

ET.GLOBAL_SHOW_MAIN_DIALOG = getUID() -- 显示主界面弹窗（扩展）

--斗地主事件

ET.ENTER_ROOM                    = getUID() --进入房间
ET.GAME_START                    = getUID() --牌局开始
ET.GAME_END                  	= getUID() --游戏结算
ET.OUT_CARDS_NTF 				= getUID() --出牌
ET.NOT_FOLLOW_RSP				= getUID() --要不起
ET.CALL_POINTS					= getUID() --叫分
ET.CALL_DOUBLE					= getUID() --加倍
ET.CALL_LANDLORDS				= getUID() --叫庄抢庄
ET.LIGHT_CARD					= getUID() --明牌
ET.USER_READY_REQ			    = getUID() --用户准备
ET.USER_READY					= getUID() --准备
ET.QUIT_ROOM                     = getUID() --退出房间
ET.GAME_KICK               		= getUID() --被踢（暂时只有经典场用）
ET.OPUSER_NOTIFY  				= getUID() --玩家操作通知
ET.MYSELF_QUIT_ROOM				= getUID() --用户自己主动退桌
ET.GAME_INPUT_REQ				= getUID() --发送进桌请求
 
ET.QUICKSTARTCLICK				= getUID() --快速开始
ET.ENTERGAMECLICK				= getUID() --进桌
ET.SHOW_OUTCARDS_TIPS    		= getUID() --显示出牌提示
ET.SHOW_AUTO_PLAYER  			= getUID() --显示托管
ET.USER_AUTO_PLAY 				= getUID() --用户进入托管状态
ET.USER_HANDLE_TURN              = getUID() --到了用户操作
ET.DDZ_NET_INPUT_REQ   		 	= getUID() --断线重连/或者是进桌
ET.RE_QUIT						= getUID() --退出
ET.GAME_QUIT_KICK				= getUID() --快速开始
ET.NO_GOLD						= getUID() --金币不足
ET.CHANGE_TABLE					= getUID() --换桌
ET.GAME_SHOW_USER_INFO			= getUID() --显示用户信息
ET.UPDATE_BG_MUSIC				= getUID() -- 改变背景声音
ET.UPDATE_MATHING_DATA			= getUID() --更新匹配数据
ET.CHATPOINT 					= getUID() --聊天小红点
ET.CARD_SHOW_TIME_EVENT			= getUID() --发牌过程中事件

ET.DESK_MULTI_CHANGE_NOTIFY     = getUID() --游戏内倍数变化通知
ET.GAME_SYN_FORTUNE_INFO        = getUID() --同步人员金币信息到客户端200

ET.ROOM_CHECK                   = getUID() -- 检测进桌
ET.GOLD_CHECK                   = getUID() -- 进桌金币检测
ET.GAME_SWITCH_FB               = getUID() -- 游戏中切换前后台

ET.UPDATE_USER_GOLD             = getUID() --更新游戏中玩家金币

ET.SHOW_RED_PACKAGE             = getUID() --打开红包弹窗

ET.CMD_INGAME_BUY               = getUID() --牌桌內获取道具列表

ET.CMD_GAME_TASK_REQ            = getUID() --牌桌内获取牌桌任务列表
ET.GAME_TASK_CHANGE_NTF         = getUID() --通知玩局有礼任务更新

ET.CHECK_ACTIVITY_SHOW          = getUID()  --检测活动弹窗是否需要弹出
ET.QUICK_START                  = getUID() --快速匹配
ET.GAME_BUY_ITEM_CHANGE         = getUID() --牌桌内更新购买道具数量

ET.ICON_FRAME_CHANGE_EVT         = getUID() --头像框变化通知(服务器)
ET.SHOW_MY_HEADBOX               = getUID() --头像框的显示

ET.ICON_FRAME_CHANGE_NOT         = getUID() --头像框变化通知ET.GAME_BUY_ITEM_CHANGE         = getUID() --牌桌内更新购买道具数量

ET.CMD_SHOW_MATCH_REPORT        = getUID() --显示赛季战报
ET.CMD_SHOW_MATCH_HONOR         = getUID() --显示赛季榮譽

ET.EVENT_OPEN_BAOXIANG         = getUID() --开宝箱

ET.MATCH_LV_CHANGE_NTF          = getUID() --新段位变化通知
ET.MATCH_VIEW_UPDATE          = getUID() --新段位变化通知
ET.SHOW_MATCHHALL_VIEW          = getUID() --显示比赛场大厅

ET.DDZLITTLE_REDDOT_NTF        = getUID()  -- 小红点

ET.USER_HEADBOX_RED_NTF        = getUID()  -- 小红点(头像框红点的提示)

ET.OPEN_SHOP_VIEW               = getUID() --显示商城

ET.NOT_MAINVIEW_LEVEL_CHANGE               = getUID() -- 通知主界面大厅等级变化

ET.SHOW_MYSELF_INFO_VIEW                = getUID()  --展示个人信息界面
ET.REFRESH_MYSELF_GOLD                  = getUID()  --刷新个人信息页面金币
ET.SHOW_DAOJU_VIEW                      = getUID()  --展示道具界面

ET.SHOW_FOCAS_VIEW                      = getUID()  --展示兑换中心
ET.SHOW_FOCASRECORD_VIEW                = getUID()  --展示兑换记录界面
ET.SHOW_FOCASINFO_VIEW                  = getUID()  --展示兑换信息界面
ET.UPDATE_FOCASINFO_VIEW                = getUID()  --更新兑换信息界面
ET.SHOW_EXCHANGEINFO_VIEW               = getUID()  --展示兑换弹窗界面
ET.UPDATE_EXCHANGEINFO_VIEW             = getUID()  --更新兑换弹窗界面
ET.SHOW_FOCASRULE_VIEW                  = getUID()  --展示兑换规则界面
--推广模块
ET.SHOW_TUIGUANG_VIEW                       = getUID()  --展示推广活动界面
ET.SHOW_TUIGUAN_RULE_VIEW                   = getUID()  --展示推广活动规则界面
ET.SHOW_TUIGUANG_OFFICIAL_VIEW              = getUID()  --展示推广活动公众号跳转界面
ET.SHOW_TUIGUANG_FRIENDINFO_VIEW            = getUID()  --展示推广活动好友数据界面
ET.TUIGUANGINFO_REQ                         = getUID()  --获取推广数据
ET.TUIGUANG_REWARD_REQ                      = getUID()  --获取推广奖励
ET.TUIGUANG_INFO_NTF                        = getUID()  --推广数据更新
ET.TUIGUANG_FRIEND_REQ                      = getUID()  --推广好友数据
ET.GET_EXCHANGEMALL_INFO               = getUID() -- 通知主界面大厅等级变化

ET.SHOW_EXCHANGEMALL_VIEW = getUID() -- 显示兑换商城弹窗
ET.EVT_USER_FOCARD_CHANGE_EXCHANGEVIEW = getUID() -- 兑换商城奖券变化
ET.SHOW_GETGOODS_DIALOG = getUID() -- 显示物品获取方式弹窗
ET.SHOW_EXCHANGERECORD_DIALOG = getUID() -- 显示兑换记录弹窗
ET.SHOW_EXCHANGEDETAIL_DIALOG = getUID() -- 显示兑换详情弹窗
ET.SHOW_EXCHANGESHORTAGE_DIALOG = getUID() -- 显示奖券不足弹窗
ET.REMOVE_EXCHANGEMALL_VIEW = getUID() -- 关闭兑换商城弹窗

ET.SHOW_SETTING_VIEW        = getUID()  --打开设置弹窗

ET.UPDATE_TUIGUANG_QIPAO = getUID() --刷新推广气泡

ET.SHOW_FOCASTASK_VIEW = getUID()   --打开奖券任务弹窗
ET.SHOW_ACTIVE_VIEW = getUID()      --打开活动弹窗

ET.SHOW_START_MATCHING = getUID()      --开始匹配

ET.SHOW_REWARD_VIEW = getUID()  --打开任务弹窗

ET.SHOW_GAME_EXIT_VIEW = getUID() --弹出牌桌退出提示

ET.PLAY_INTERACT_ANIMATION = getUID() --发送互动表情

ET.GET_QUICK_START_ROOMID = getUID() --获取快速开始的房间iD

