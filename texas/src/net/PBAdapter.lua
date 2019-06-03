

local PBAdapter = class("PBAdapter")
PBAdapter.TAG = "PBAdapter"
PBAdapter.prefix = "texas.net.proto."
function PBAdapter:ctor(paras)
    -- _reqtable請求消息類名稱列表
    -- _rsptable 響應回來的消息 對象名稱列表

    self._reqtable = {}
    self._rsptable = {}

    self._rsptable[CMD.GENERAL_NOTICE] = "NtfClientCommand"

    self._rsptable[CMD.GET_USER_GAME_INFO] = "query_user_info_rsp"
    self._reqtable[CMD.GET_USER_GAME_INFO] = "query_user_info_req"

    
    self._reqtable[CMD.CMD_GET_LUCKY_WHEEL_REWARD] ="LuckyWheelRewardReq" -- 大厅大转盘每日登录奖励，转动转盘请求
    self._rsptable[CMD.CMD_GET_LUCKY_WHEEL_REWARD] ="LuckyWheelRewardRsp" --转盘请求的返回


    self._reqtable[CMD.CMD_GET_CUMULATE_LOGIN_REWARD] ="CumulateLoginRewardReq" -- 大厅累计登陆奖励，累计登陆领奖请求
    self._rsptable[CMD.CMD_GET_CUMULATE_LOGIN_REWARD] ="CumulateLoginRewardRsp" --累计登陆的返回
    --game proto end--

    --应用逻辑协议 start--
    self._reqtable[CMD.REG] = "UserRegReq"
    self._rsptable[CMD.REG] = "UserLoginRsp"

    self._reqtable[CMD.LOGIN] = "UserLoginReq"
    self._rsptable[CMD.LOGIN] = "UserLoginRsp"
    self._reqtable[CMD.CONFIG] = "GameConfReq"
    self._rsptable[CMD.CONFIG] = "GameConfRsp"
    self._reqtable[CMD.APPCONFIG] = "AppGameConfRep"
    self._rsptable[CMD.APPCONFIG] = "AppGameConfRsp"
    self._reqtable[CMD.USER_MODIFY] = "SetProfileReq"
    self._rsptable[CMD.TASKLIST] = "TaskListRsp"
    -- self._rsptable[CMD.ALLACTIVITYTASK] = "GetAllActivityTaskRsp"
    self._rsptable[CMD.ALLACTIVITYTASK] = "AppGetAllActivityTaskRsp" -- 【合服更改】
    self._reqtable[CMD.TASKREWARD] = "PickRewardReq"
    self._rsptable[CMD.TASKREWARD] = "PickRewardRsp"
    self._reqtable[CMD.APPLY_REWARD_CODE] = "ApplyRewardCodeReq"
    self._rsptable[CMD.APPLY_REWARD_CODE] = "ApplyRewardCodeRsp"
    --应用逻辑协议 end--

    --other proto start--
    self._reqtable[CMD.CHAT] = "DeskChatReq"
    self._rsptable[CMD.CHAT_NOTICE_EVT] = "EvtDeskChat"
    
    -- self._reqtable[CMD.USER_INFO] = "OtherUserInfoReq"
    -- self._rsptable[CMD.USER_INFO] = "AppOtherUserInfoRsp" --【合服更改】

    self._reqtable[CMD.USER_INFO] = "OtherUserInfoReq"
    self._rsptable[CMD.USER_INFO] = "OtherUserInfoRsp" --同步小游戏

    self._rsptable[CMD.DDZLITTLE_REDDOT_NTF] = "DDZLittleRedDotNtf" --小红点通知（同步小游戏）
    

    self._reqtable[CMD.ICON_FRAME_LIST_EVT] = "IconFrameListReq"
    self._rsptable[CMD.ICON_FRAME_LIST_EVT] = "IconFrameListRsp" --头像框列表

    self._reqtable[CMD.ICON_FRAME_USE_EVT] = "UseIconFrameReq"
    self._rsptable[CMD.ICON_FRAME_USE_EVT] = "UseIconFrameRsp" --使用头像框

    self._rsptable[CMD.ICON_FRAME_CHANGE_EVT] = "IconFrameChangeNtf" --头像框变化通知
    
    self._rsptable[CMD.GET_FINISH_ACTIVITY_NUM_EVT] = "ActivityInfoRsp"
    self._rsptable[CMD.UPDATA_GOLD_EVT] = "UserChangeNtf"
    self._rsptable[CMD.EVENT_OTHER_GOLD_CHANGE] = "EvtOtherUserGoldChange"
    
    self._rsptable[CMD.BROADCAST_OTHER_EVT] = "AppEvtBroadCast"
    self._rsptable[CMD.BAROADCAST_DIM_EVT] = "EvtBuySucc"

    self._reqtable[CMD.WX_REG] = "WXUserRegReq"
    self._rsptable[CMD.WX_REG] = "UserLoginRsp"
    
    self._reqtable[CMD.OPPO_REG] = "OPPOUserRegReq"
    self._rsptable[CMD.OPPO_REG] = "UserLoginRsp"

    self._reqtable[CMD.CMD_USER_BROADCAST] = "UserBroadcastReq"  -- 喇叭发送消息

    self._reqtable[CMD.CMD_GET_DAOJU_LIST] = "QueryKnapsackReq"  -- daoju
    self._rsptable[CMD.CMD_GET_DAOJU_LIST] = "QueryKnapsackRsp"  -- daoju
    self._rsptable[CMD.EVENT_USER_DAOJU_CHANGE] = "EvtBuyPropSucc"  -- 道具发货通知

    self._rsptable[CMD.EVENT_LOGIN_REWARD_GET] = "AppReceiveGiftRsp"  -- 每日登录奖励领取 

    self._reqtable[CMD.EVENT_QUERY_DAOJU_BY_ID] = "QueryKnapsackItemReq"--查询道具数量
    self._rsptable[CMD.EVENT_QUERY_DAOJU_BY_ID] = "KnapsackItem"--查询道具数量
    
    self._rsptable[CMD.EVENT_SCORE_CHANGED] = "EvtScoreChanged"--积分变化通知

    self._reqtable[CMD.CMD_QUERY_SCHED_REWARD] = "SchedRewardConfReq"--查询定时奖励
    self._rsptable[CMD.CMD_QUERY_SCHED_REWARD] = "SchedRewardConfRsp"--查询定时奖励
    self._reqtable[CMD.CMD_PICK_SCHED_REWARD] = "PickSchedRewardReq"--领取定时奖励
    self._rsptable[CMD.CMD_QUERY_BROKE_SUPPLY] = "BrokeSupplyStatus"--查询破产补助

    self._rsptable[CMD.CMD_COMMON_REDTIPS_NOTIFY] = "PickableRewardsNtf"--小红点通知

    self._rsptable[CMD.CMD_INGAME_BUY] = "AppStoreConf"--牌桌内购买道具列表

    self._rsptable[CMD.SCORE_CLIENT_SHARE] = "CommandClientShare"
    self._rsptable[CMD.INVITE_CODE_BE_EXCHANGED] = "InviteCodeBeExchanged" -- 兑换码被兑换通知 
    self._rsptable[CMD.GET_DAY_LOGIN_REWARD_CFG] = "DailyRewardConfRsp" -- 拉取每日登录奖励配置
    self._rsptable[CMD.GET_NEW_DAY_LOGIN_REWARD_CFG] = "DDZFreshManGiftRsp" -- 拉取每日登录奖励配置
    
    self._reqtable[CMD.STORE_BUYING_USING_GOLD] = "StoreBuyReq"--用金币购买
    self._rsptable[CMD.STORE_BUYING_USING_GOLD] = "StoreBuyRsp" -- 有金币购买

    self._reqtable[CMD.MATCH_HALL_INFO] = "DDZMatchHomepageInfoReq" -- 比赛场大厅信息
    self._rsptable[CMD.MATCH_HALL_INFO] = "DDZMatchHomepageInfoRsp" -- 比赛场大厅信息
    self._reqtable[CMD.MATCH_GUIDE_REQ] = "SetGuidanceReq" -- 设置引导状态
    self._rsptable[CMD.MATCH_GUIDE_REQ] = "SetGuidanceRsp" -- 设置引导状态
    self._reqtable[CMD.MATCH_RANK_REQ] = "DDZMatchLeaderBoardInfoReq" -- 获取赛事排行榜数据
    self._rsptable[CMD.MATCH_RANK_REQ] = "DDZMatchLeaderBoardInfoRsp" -- 获取赛事排行榜数据

------------------兑换--------------------
    self._reqtable[CMD.EXCHANGE_INFO_REQ] = "ExchangeClassifyReq" -- 获取兑换商品的信息
    self._rsptable[CMD.EXCHANGE_INFO_REQ] = "ExchangeClassifyRsp" -- 获取兑换商品的信息

------------------新美女-------------------
    self._reqtable[CMD.GET_BEAUTY_PHOTO_LIST] = "QueryAlbumUrlsReq" -- 
    self._rsptable[CMD.GET_BEAUTY_PHOTO_LIST] = "QueryAlbumUrlsRsp" -- 
    self._reqtable[CMD.REMOVE_BEAUTY_PHOTO] = "RemoveAlbumImageReq" -- 
    self._rsptable[CMD.REMOVE_BEAUTY_PHOTO] = "RemoveAlbumImageRsp" -- 


    self._reqtable[CMD.USER_REPORT] = "MakeComplaintReq"                    --举报





----------------------选场大厅---------------------

    self._rsptable[CMD.USER_DIAMOND_CHANGED] = "UserChangeNtf"
    self._reqtable[CMD.PRODUCT_EXCHANGE_BY_DIAMOND] = "StoreBuyItemUsingDiamondReq"
    self._rsptable[CMD.PRODUCT_EXCHANGE_BY_DIAMOND] = "StoreBuyItemUsingDiamondRsp"
    self._reqtable[CMD.PUSH_USER_ACTION_STATS] = "PushStatDataReq"
    self._rsptable[CMD.PUSH_USER_ACTION_STATS] = "PushStatDataRsp"

    self._reqtable[CMD.CMD_INTERACT_PHIZ] = "InteractiveExpressionReq" -- 发送互动表情
    self._rsptable[CMD.CMD_INTERACT_PHIZ] = "InteractiveExpressionRsp"
    self._rsptable[CMD.CMD_INTERACT_PHIZ_NTF] = "InteractiveExpressionNtf" -- 下发互动表情

    --副卡start
    self._reqtable[CMD.IN_INDIANA] = "InIndianaReq" -- 参与夺宝
    self._rsptable[CMD.IN_INDIANA] = "InIndianaRsp" -- 参与夺宝
    self._rsptable[CMD.EVT_USER_FOCARD_CHANGE] = "UserChangeNtf" -- 奖券变化通知  【合服更改】
    self._reqtable[CMD.EVETNT_USER_RECORD_INFO] = "EventUserRecordInfoReq" -- 兑换/夺宝记录用户信息
    self._reqtable[CMD.GET_WELFARD_INDIANA_LIST] = "GetWelfareIndianaListReq" -- 返回福利夺宝及兑换列表
    self._rsptable[CMD.GET_WELFARD_INDIANA_LIST] = "GetWelfareIndianaListRsp" -- 返回福利夺宝及兑换列表
    self._reqtable[CMD.HIS_INDIANA_RECORD] = "HisIndianaRecordReq" -- 往期得主
    self._rsptable[CMD.HIS_INDIANA_RECORD] = "HisIndianaRecordRsp" -- 往期得主
    --副卡end

    -- 邀请
    self._reqtable[CMD.BIND_INIVTE] = "input_invite_req" -- 绑定邀请人
    self._rsptable[CMD.BIND_INIVTE] = "input_invite_rsp"
    self._reqtable[CMD.GET_INVITE_REWARD] = "reward_invite_req" -- 获取邀请奖励信息
    self._rsptable[CMD.GET_INVITE_REWARD] = "reward_invite_rsp" 
    self._reqtable[CMD.GET_INVITE_RECORDS] = "get_invite_record_req"   -- 获取邀请记录
    self._rsptable[CMD.GET_INVITE_RECORDS] = "get_invite_record_rsp"

    --邀请奖励数量通知
    self._rsptable[CMD.UPDATE_AWARD_NUM] = "InviteInfoRsp"
    --排行榜
    self._rsptable[CMD.APPGOLDWORLDRANKRSP] = "AppGoldWorldRankRsp"
    self._rsptable[CMD.APPGOLDFRIDENDANKRSP] = "AppGoldFriendsRankRsp"

    --退赛奖励查询
    -- self._rsptable[CMD.DDZMatchQuitQuery] = "DDZMatchQuitQuery"
    self._reqtable[CMD.DDZMatchQuitQuery] = "DDZExitMatchInfoReq" --【合服更改】
    self._rsptable[CMD.DDZMatchQuitQuery] = "DDZExitMatchInfoRsp" --【合服更改】

    self._reqtable[CMD.DDZMatchQuitApplyReq] = "DDZExitMatchReq" --【合服更改】
    self._rsptable[CMD.DDZMatchQuitApplyReq] = "DDZExitMatchRsp" --【合服更改】

    --使用等级卡
    self._reqtable[CMD.DDZMatchLevelCardUsedReq] = "UseLevelCardReq" --【合服增加】
    self._rsptable[CMD.DDZMatchLevelCardUsedReq] = "UseLevelCardRsp" --【合服增加】

    self._reqtable[CMD.GET_PROMOTE_REQ] = "DDZMatchPromoteConfigReq"--获取推荐信息
    self._rsptable[CMD.GET_PROMOTE_REQ] = "DDZMatchPromoteConfigNtf"--获取推荐信息
    self._reqtable[CMD.RELATE_TO_PROMOTER_REQ] = "DDZMatchFillPromoterReq" --填写推荐人
    self._rsptable[CMD.RELATE_TO_PROMOTER_REQ] = "DDZMatchFillPromoterNtf" --填写推荐人


    --绑定微信命令
    self._reqtable[CMD.BAND_WEIXIN_REQ] = "DDZBandWexinReq" -- "绑定微信"

    ----------------------------刮刮卡-------------------------------------
    self._reqtable[CMD.GUAGUACARD_SITE_LIST] = "BettingShopAddressReq" -- 投注站地址列表
    self._rsptable[CMD.GUAGUACARD_SITE_LIST] = "BettingShopAddressRsp" -- 投注站地址列表
    self._reqtable[CMD.GUAGUACARD_DETAIL_INFO_REQ] = "ChanceCardDetailReq" --  刮刮卡详情
    self._rsptable[CMD.GUAGUACARD_DETAIL_INFO_RSP] = "ChanceCardDetailRsp" --  刮刮卡详情

    self._reqtable[CMD.ACTIVITY_FINISHED_REQ] = "ActivityFinish" -- 活动完成请求 7078 
    self._reqtable[CMD.CHECK_USERID_REQ] = "CheckUserIdReq" -- "实名认证"
    self._rsptable[CMD.CHECK_USERID_RSP] = "CheckUserIdRsp" -- "实名认证"

    self._reqtable[CMD.QUERYCARDSREMEMBERINFO] = "QueryCardsRememberInfoReq"  
    self._rsptable[CMD.QUERYCARDSREMEMBERINFO] = "QueryCardsRememberInfoRsq"

    self._rsptable[CMD.FIRSTRECHARGE_INFO] = "DiscountGoodsNtf" --首冲6元奖励详情 9047
    self._rsptable[CMD.FIRSTRECHARGE_SUCCESS_INFO] = "DiscountGoodsNtf" --首冲6元奖励详情 9048        
    self._reqtable[CMD.FREE_WEIXINSHARE_REQ] = "WxShareToFriendReq"  
    self._rsptable[CMD.FREE_WEIXINSHARE_RSP] = "WxShareToFriendRsp"
    
    self._rsptable[CMD.DDZBANKRUPTPTOTECTRSP] = "DDZProtectNtf"  -- 破产保护弹窗 cmd 6527
    
    self._rsptable[CMD.QUIT] = "DDZExitDeskEvt"
    self._rsptable[CMD.GAME_END] = "DDZResultEvt"  --比赛结束

    self._rsptable[CMD.DESK_MULTI_CHANGE_NOTIFY]        = "DDZDeskMultiNtf"  --牌桌倍数更新信息
    self._rsptable[CMD.SYN_FORTUNE_INFO]        = "SyncFortuneInfoNtf"  --同步人员金币信息到客户端

    self._reqtable[CMD.NEW_USER_PLAY_REWARD]    = "AppNewUserPlayTaskRewardReq"
    self._rsptable[CMD.NEW_USER_PLAY_REWARD]    = "AppNewUserPlayTaskRewardRsp"

    self._reqtable[CMD.GAME_TASK_REQ]   = "AppDeskRepeatedTaskStatusReq"
    self._rsptable[CMD.GAME_TASK_REQ]   = "AppDeskRepeatedTaskStatusRsp"

    self._rsptable[CMD.GAME_TASK_CHANGE_NTF] = "AppDeskRepeatedTaskUpdateNtf"

    self._reqtable[CMD.GAME_TASK_REWARD_REQ] = "AppDeskRepeatedTaskRewardReq"
    self._rsptable[CMD.GAME_TASK_REWARD_REQ] = "AppDeskRepeatedTaskRewardRsp"

    self._reqtable[CMD.TUIGUANG_INFO_REQ]   = "App680InvaiteEarnDetailReq"
    self._rsptable[CMD.TUIGUANG_INFO_REQ]   = "App680InvaiteEarnDetailRsp"

    self._reqtable[CMD.TUIGUANG_REWARD_REQ] =   "App680InvaiteEarnTaskRewardReq"
    self._rsptable[CMD.TUIGUANG_REWARD_REQ] =   "App680InvaiteEarnTaskRewardRsp"

    self._rsptable[CMD.TUIGUANG_INFO_NTF]   =   "App680InviteTaskUpdate"

    self._reqtable[CMD.TUIGUANG_FRIEND_REQ] =   "App680InvaiteEarnInvitedUserReq"
    self._rsptable[CMD.TUIGUANG_FRIEND_REQ] =   "App680InvaiteEarnInvitedUserRsp"

    self._reqtable[CMD.EXCHANGE_WELFARE] = "ExchangeGoodsReq" -- 申请奖券兑换
    self._rsptable[CMD.EXCHANGE_WELFARE] = "ExchangeGoodsRsp" -- 申请奖券兑换
    self._reqtable[CMD.EXCHANGE_USER_INFO] = "UserChangeAddressesReq" -- 保存用戶地址等信息
    self._rsptable[CMD.EXCHANGE_USER_INFO] = "UserChangeAddressesRsp" -- 保存用戶地址等信息
    self._reqtable[CMD.WELFARE_INDIANNA_RECORD] = "UserChangeRecordReq" --兑换记录
    self._rsptable[CMD.WELFARE_INDIANNA_RECORD] = "UserChangeRecordRsp" --兑换记录

    self:initNormalGame()
    self:initMatchGame()
    self:initNewMatchGame()
end

function PBAdapter:initNormalGame( ... )
    self._reqtable[CMD.INPUT]        = "DDZEnterDeskReq"  --用户主动进桌、换桌
    self._rsptable[CMD.INPUT]        = "DDZEnterDeskRsp"  --用户主动进桌、换桌

    self._rsptable[CMD.INPUT_GAME_EVT] = "DDZEnterDeskEvt" --进桌通知

    self._reqtable[CMD.QUICK_START] = "QuickAllocRoomIdReq"  --快速开始
    self._rsptable[CMD.QUICK_START] = "QuickAllocRoomIdRsp"  --快速开始

    self._reqtable[CMD.USER_EXIT_REQ]        = "DDZExitDeskReq" --退桌
    self._rsptable[CMD.USER_EXIT_REQ]        = "DDZExitDeskRsp" --退桌

    self._reqtable[CMD.CHANGE_TABLE] = "DDZUserChangeDeskReq" --点击换桌
    self._rsptable[CMD.CHANGE_TABLE] = "DDZEnterDeskEvt"      --点击换桌

    self._reqtable[CMD.READY_REQ] = "DDZUserReadyReq"  --准备
    self._rsptable[CMD.READY_REQ] = "DDZUserReadyRsp"  --准备

    self._rsptable[CMD.USER_READY] = "DDZUserReadyNtf"  --准备

    self._reqtable[CMD.SHOW_CARD_IN_GIVE_CARD] = "DDZShowCardReq"  --发牌过程中明牌
    self._rsptable[CMD.SHOW_CARD_IN_GIVE_CARD] = "DDZShowCardRsp"  --发牌过程中明牌

    self._rsptable[CMD.SHOW_CARD_NTF] = "DDZShowCardNtf"  --明牌通知
    

    self._reqtable[CMD.ROOM_CHECK_REQ] = "RoomCheckReq"  --检测能进的场次
    self._rsptable[CMD.ROOM_CHECK_REQ] = "RoomCheckRsp"  --检测能进的场次

    self._reqtable[CMD.CALL_POINTS_REQ] = "DDZUserCallReq"  --抢地主
    self._rsptable[CMD.CALL_POINTS_REQ] = "DDZUserCallReq"  --抢地主

    self._rsptable[CMD.OPUSER_NOTIFY] = "DDZOpUserNtf"  --暂用于发牌阶段结束通知抢地主

    self._rsptable[CMD.GAME_START_EVT] = "DDZStartGameEvt"  --游戏开始

    self._reqtable[CMD.CALL_DOUBLE_REQ]      = "DDZUserMutiReq"  --加倍请求
    self._rsptable[CMD.CALL_DOUBLE_REQ]      = "DDZUserMutiRsp"  --加倍请求

    self._reqtable[CMD.CHECK_GOLD_LIMIT_REQ] = "DDZCheckGoldLimitReq"  --检测能进的场次
    self._rsptable[CMD.CHECK_GOLD_LIMIT_REQ] = "DDZCheckGoldLimitRsp"  --检测能进的场次

    self._rsptable[CMD.CALL_DOUBLE_NTF]        = "DDZUserMutiEvt"  --牌桌倍数更新信息

    self._reqtable[CMD.OUT_CARDS_REQ]        = "DDZDiscardReq"  --出牌
    self._rsptable[CMD.OUT_CARDS_REQ]        = "DDZDiscardRsp"  --出牌
    self._rsptable[CMD.OUT_CARDS_NTF]        = "DDZDiscardEvt"  --用户出牌通知

    self._reqtable[CMD.AUTO_PLAY_REQ]        = "DDZAutoPlayReq" --托管
    self._rsptable[CMD.AUTO_PLAY_REQ]        = "DDZAutoPlayRsp" --托管
    
    self._rsptable[CMD.USER_AUTO_PLAY_NTF]        = "DDZAutoPlayEvt"  --用户进入托管通知

    self._reqtable[CMD.QUERY_DESK]                 = "DDZQueryDeskReq"  --查询桌子，用于后台切回前台使用
    self._rsptable[CMD.QUERY_DESK]                 = "DDZEnterDeskEvt"  --查询桌子，用于后台切回前台使用

    self._reqtable[CMD.BEI_INFO_UPDATE]   = "DDZGetMultipleInfoReq"
    self._rsptable[CMD.BEI_INFO_UPDATE]   = "DDZGetMultipleInfoRsp"
    self._reqtable[CMD.APP_NEW_USER_GIFT]   = "AppNerUserGiftClickReq"
    self._rsptable[CMD.APP_NEW_USER_GIFT]   = "AppNerUserGiftClickRsp"

    self._reqtable[CMD.HALL_SELECT_PLAY]   = "HallSelectPlayModeReq"  --金币场选场大厅的在线人数
    self._rsptable[CMD.HALL_SELECT_PLAY]   = "HallSelectPlayModeRsp"   
end

--比赛场初始化
function PBAdapter:initMatchGame()
    self._reqtable[CMD.IS_HIGH_MATCH_LEVEL]        = "DDZIsHighMatchLevelReq"  --判断最高等级是不是可以打
    self._rsptable[CMD.IS_HIGH_MATCH_LEVEL]        = "DDZIsHighMatchLevelRsp"  --判断最高等级是不是可以打

    self._reqtable[CMD.MATCH_CHANGE_DESK_REQ]      = "DDZUserChangeDeskReq"  --换桌
    self._rsptable[CMD.MATCH_CHANGE_DESK_REQ]      = "DDZEnterDeskEvt"  --换桌
    
    self._reqtable[CMD.MATCH_EXIT_DESK_REQ]        = "DDZExitDeskReq" --退桌
    self._rsptable[CMD.MATCH_EXIT_DESK_REQ]        = "DDZExitDeskRsp" --退桌

    self._reqtable[CMD.MATCH_USER_CALL_REQ]        = "DDZUserCallReq" --叫分
    self._rsptable[CMD.MATCH_USER_CALL_REQ]        = "DDZUserCallRsp" --叫分

    self._rsptable[CMD.MATCH_USER_CALL_NTF]        = "DDZUserCallEvt" --叫分通知

    self._reqtable[CMD.MATCH_AUTO_PLAY_REQ]        = "DDZAutoPlayReq" --托管
    self._rsptable[CMD.MATCH_AUTO_PLAY_REQ]        = "DDZAutoPlayRsp" --托管

    self._reqtable[CMD.MATCH_OUT_CARDS_REQ]        = "DDZDiscardReq"  --出牌
    self._rsptable[CMD.MATCH_OUT_CARDS_REQ]        = "DDZDiscardRsp"  --出牌

    self._reqtable[CMD.MATCH_CALL_DOUBLE_REQ]      = "DDZUserMutiReq"  --加倍请求
    self._rsptable[CMD.MATCH_CALL_DOUBLE_REQ]      = "DDZUserMutiRsp"  --加倍请求

    self._reqtable[CMD.MATCH_QUERY_DESK]                 = "DDZQueryDeskReq"  --查询桌子，用于后台切回前台使用
    self._rsptable[CMD.MATCH_QUERY_DESK]                 = "DDZEnterDeskEvt"  --查询桌子，用于后台切回前台使用

    self._reqtable[CMD.MATCH_USER_TIMER_TIME_OUT_REQ]        = "DDZOPTimeoutReq"  --用户定时器超时
    self._rsptable[CMD.MATCH_USER_TIMER_TIME_OUT_REQ]        = "DDZOPTimeoutRsp"  --用户定时器超时

    self._reqtable[CMD.MATCH_DESK_MULTI_REQ]        = "DDZDeskMultiReq"  --查询牌桌倍数信息
    self._rsptable[CMD.MATCH_DESK_MULTI_REQ]        = "DDZDeskMultiRsp"  --查询牌桌倍数信息

    self._reqtable[CMD.MATCH_CHECK_GOLD_LIMIT_REQ]        = "DDZCheckGoldLimitReq"  --场次金币检测
    self._rsptable[CMD.MATCH_CHECK_GOLD_LIMIT_REQ]        = "DDZCheckGoldLimitRsp"  --场次金币检测

    self._reqtable[CMD.MATCH_GAME_DETAIL_INFO_REQ]        = "DDZRoundDetailReq"  --查询赛事对局详情
    self._rsptable[CMD.MATCH_GAME_DETAIL_INFO_REQ]        = "DDZRoundDetailRsp"  --查询赛事对局详情  
end

function PBAdapter:initNewMatchGame(  )
    --cmd:30000 新比赛场进桌
    self._reqtable[CMD.NEWEVENT_ENTER_ROOM_REQ]             = "DDZEnterDeskReq"
    self._rsptable[CMD.NEWEVENT_ENTER_ROOM_REQ]             = "DDZEnterDeskRsp"

    --cmd:30002 新比赛场退桌
    self._reqtable[CMD.NEWEVENT_EXIT_ROOM_REQ]              = "DDZExitDeskReq"
    self._rsptable[CMD.NEWEVENT_EXIT_ROOM_REQ]              = "DDZExitDeskRsp"
    --cmd:30004 新比赛场叫地主
    self._reqtable[CMD.NEWEVENT_CALL_REQ]                   = "DDZUserCallReq"
    self._rsptable[CMD.NEWEVENT_CALL_REQ]                   = "DDZUserCallRsp"
    --cmd:30005 新比赛场托管请求
    self._reqtable[CMD.NEWEVENT_AUTO_PLAY_REQ]              = "DDZAutoPlayReq"
    self._rsptable[CMD.NEWEVENT_AUTO_PLAY_REQ]              = "DDZAutoPlayRsp"
    --cmd:30006 新比赛场出牌请求
    self._reqtable[CMD.NEWEVENT_DISCARD_REQ]                = "DDZDiscardReq"
    self._rsptable[CMD.NEWEVENT_DISCARD_REQ]                = "DDZDiscardRsp"
    --cmd:30007 新比赛场加倍请求
    self._reqtable[CMD.NEWEVENT_USER_MUTI_REQ]              = "DDZUserMutiReq"
    self._rsptable[CMD.NEWEVENT_USER_MUTI_REQ]              = "DDZUserMutiRsp"
    --cmd:30008 新比赛场查询牌桌
    self._reqtable[CMD.NEWEVENT_QUERY_DESK_REQ]             = "DDZQueryDeskReq"
    self._rsptable[CMD.NEWEVENT_QUERY_DESK_REQ]             = "DDZEnterDeskEvt"
    --cmd:30009 新比赛场玩家超时请求
    self._reqtable[CMD.NEWEVENT_OP_TIMEOUT_REQ]             = "DDZOPTimeoutReq"
    self._rsptable[CMD.NEWEVENT_OP_TIMEOUT_REQ]             = "DDZOPTimeoutRsp"
    --cmd:30011 新比赛场倍数请求
    self._reqtable[CMD.NEWEVENT_DESK_MUTI_REQ]              = "DDZDeskMultiReq"
    self._rsptable[CMD.NEWEVENT_DESK_MUTI_REQ]              = "DDZDeskMultiRsp"
    --cmd:30014 新比赛场倍数数据请求
    self._reqtable[CMD.NEWEVENT_GET_DESK_MUTIINFO_REQ]      = "DDZGetMultipleInfoReq"
    self._rsptable[CMD.NEWEVENT_GET_DESK_MUTIINFO_REQ]      = "DDZGetMultipleInfoRsp"
    --cmd:30015 新比赛场明牌请求
    self._reqtable[CMD.NEWEVENT_SHOW_CARD_REQ]              = "DDZShowCardReq"
    self._rsptable[CMD.NEWEVENT_SHOW_CARD_REQ]              = "DDZShowCardRsp"
    --cmd:30012 新比赛场继续挑战请求
    self._reqtable[CMD.NEWEVENT_CHANGE_DESK_REQ]            = "DDZUserChangeDeskReq"
    self._rsptable[CMD.NEWEVENT_CHANGE_DESK_REQ]            = "DDZEnterDeskEvt"

    --cmd:30052 新比赛场打开宝箱请求
    self._reqtable[CMD.NEWEVENT_OPEN_BOX_REQ]               = "UseMatchBoxReq"
    self._rsptable[CMD.NEWEVENT_OPEN_BOX_REQ]               = "UseMatchBoxRsp"
    --cmd:30017 新比赛场保星请求
    self._reqtable[CMD.NEWEVENT_SAVESTAR_REQ]               = "StarProtectReq"
    self._rsptable[CMD.NEWEVENT_SAVESTAR_REQ]               = "StarProtectRsp"
    --cmd 7531 新比赛场明牌通知
    self._rsptable[CMD.NEWEVENT_SHOW_CARD_NTF]              = "DDZShowCardNtf"

    --cmd 30062
    self._rsptable[CMD.NEWEVENT_LEVEL_CHANGE_NTF]           = "MatchLvChangeNtf"

end


--[[--
method=req|rsp
cmd
]]

function PBAdapter:findPBNameByCmd(paras)

    if(paras == nil or paras.method == nil or paras.cmd == nil ) then
        loge("error on find pbName",self.TAG)
    end
    if self["_"..paras.method.."table"][paras.cmd] == nil then
        loge(" -- cannot find pname by cmd ="..paras.cmd .. " on table = "..paras.method)
        return nil 
    end
        
    return self.prefix..self["_"..paras.method.."table"][paras.cmd]
end

function PBAdapter:getSignPBName()
    return self.prefix.."SignedBody"
end

function PBAdapter:getSafeShellPBName( ... )
    return self.prefix.."SafeShell"
end

return PBAdapter
