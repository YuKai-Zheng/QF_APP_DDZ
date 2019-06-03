--[[
    server msg adapter to game event
    根据服务器发来的数据包，解析其唯一标识
    然后分发到本地游戏中的事件
]]



local ETAdapter = class("ETAdapter")
ETAdapter.TAG = "ETAdapter"


function ETAdapter:ctor()
	-- 这里需要绑定 服务器消息uid与其相应的res事件id
	-- 若有一对多的情况
    -- 例如 self._etable[CMD.INPUT_GAME_EVT] = {ET.A,ET.B}
    -- 
    --

	self._etable = {}
    --game proto start--
    self._etable[CMD.INPUT_GAME_EVT] =  ET.ENTER_ROOM
    self._etable[CMD.GAME_START_EVT] = ET.GAME_START
    self._etable[CMD.GENERAL_NOTICE] =  ET.GAME_GENERAL_NOTICE
    self._etable[CMD.GAME_END]          =  ET.GAME_END              --比赛结束

    self._etable[CMD.OUT_CARDS_NTF]     =  ET.OUT_CARDS_NTF         --出牌
    self._etable[CMD.MATCH_USER_CALL_NTF]   =  ET.CALL_POINTS              --叫分通知
    self._etable[CMD.CALL_DOUBLE_NTF]   =  ET.CALL_DOUBLE              --加倍
    self._etable[CMD.USER_READY]         =  ET.USER_READY                     --准备
    self._etable[CMD.QUIT]              =  ET.QUIT_ROOM             --退出
    self._etable[CMD.CHANGE_TABLE]      =  ET.CHANGE_TABLE          --换桌

    self._etable[CMD.USER_AUTO_PLAY_NTF]      =  ET.USER_AUTO_PLAY          --用户进入托管
    

    ---新协议，整理好的
    self._etable[CMD.DESK_MULTI_CHANGE_NOTIFY]   =  ET.DESK_MULTI_CHANGE_NOTIFY --b倍率更新

    self._etable[CMD.SYN_FORTUNE_INFO]   =  ET.GAME_SYN_FORTUNE_INFO --同步人员金币信息到客户端200
    
    --game proto end--
    --other proto start--
    self._etable[CMD.CHAT_NOTICE_EVT] =  ET.NET_CHAT_NOTICE_EVT
    self._etable[CMD.GET_FINISH_ACTIVITY_NUM_EVT] =  ET.NET_GET_FINISH_ACTIVITY_EVT
    
    --other proto end--
    --global proto start--
    self._etable[CMD.BROADCAST_OTHER_EVT] = ET.NET_BROADCAST_OTHER_EVT
    self._etable[CMD.BAROADCAST_DIM_EVT] = {
            ET.NET_BAROADCAST_DIM_EVT,
            ET.REFRESH_BANKRUPTCY_POPUP
    }
    self._etable[CMD.UPDATA_GOLD_EVT] = {
            ET.NET_UPDATA_GOLD_EVT,
            ET.GLOBAL_FRESH_MAIN_GOLD,
            ET.GLOBAL_FRESH_LOBBIES_GOLD,
            ET.REFRESH_SHOP_GOLD,
            ET.NET_CHANGEGOLD_EVT
    }


    self._etable[CMD.EVENT_OTHER_GOLD_CHANGE] = ET.NET_EVENT_OTHER_GOLD_CHANGE
    

    self._etable[CMD.EVENT_USER_DAOJU_CHANGE] = ET.EVENT_USER_DAOJU_CHANGE

    self._etable[CMD.EVENT_LOGIN_REWARD_GET] = ET.EVENT_LOGIN_REWARD_GET

    self._etable[CMD.EVENT_SCORE_CHANGED] = ET.EVENT_SCORE_CHANGED

    self._etable[CMD.CMD_COMMON_REDTIPS_NOTIFY] = ET.COMMON_REDTIPS_NOTIFY -- 通用小红点通知
    self._etable[CMD.SCORE_CLIENT_SHARE] = ET.NET_SCORE_CLIENT_SHARE -- 积分兑换礼物分享通知
    self._etable[CMD.INVITE_CODE_BE_EXCHANGED] = ET.INVITE_CODE_BE_EXCHANGED -- 兑换码被兑换通知

    --用户钻石变化
    self._etable[CMD.USER_DIAMOND_CHANGED] = {
        ET.NET_DIAMOND_CHANGE_GLOBAL_EVT, 
        ET.NET_DIAMOND_CHANGE_MAIN_EVT,
        ET.NET_DIAMOND_CHANGE_USERINFO_EVT,
        ET.NET_DIAMOND_CHANGE_SHOP_EVT,
        ET.NET_DIAMOND_CHANGE_HALL,
        ET.NET_DIAMOND_CHANGE_NIUNIU_HALL
    }


    --互动表情
    self._etable[CMD.CMD_INTERACT_PHIZ_NTF] = ET.INTERACT_PHIZ_NTF -- 互动表情通知

    --奖券start
    self._etable[CMD.EVT_USER_FOCARD_CHANGE] = {--奖券变化通知5
        ET.EVT_USER_FOCARD_CHANGE_MATCHING,
        ET.EVT_USER_FOCARD_CHANGE_FOCASVIEW,
        ET.EVT_USER_FOCARD_CHANGE_MAINVIEW,
        ET.EVT_USER_FOCARD_CHANGE_GAMEVIEW,
        ET.EVT_USER_FOCARD_CHANGE_HALLVIEW,
        ET.EVT_USER_FOCARD_CHANGE_EXCHANGEVIEW
    }
    --奖券end

    --邀请可领取数量通知
    self._etable[CMD.UPDATE_AWARD_NUM] = ET.UPDATE_AWARD_NUM

    -- self._etable[CMD.GET_PROMOTE_RSP] = ET.TO_BE_PROMOTER

    self._etable[CMD.FIRSTRECHARGE_INFO] = ET.FIRSTRECHARGE_INFO --首冲6元奖励详情
    
    self._etable[CMD.FIRSTRECHARGE_SUCCESS_INFO] = ET.FIRSTRECHARGE_SUCCESS_INFO --首冲6元成功奖励

    self._etable[CMD.DDZBANKRUPTPTOTECTRSP] = ET.DDZBANKRUPTPTOTECTRSP --破产保护弹窗 cmd 6527

    self._etable[CMD.GET_PROMOTE_REQ] = ET.GET_PROMOTE_NOTICE --查询推广信息 cmd 9026
    
    self._etable[CMD.SHOW_CARD_NTF]     =  ET.LIGHT_CARD    --明牌通知
    self._etable[CMD.OPUSER_NOTIFY]     =  ET.OPUSER_NOTIFY --通知玩家操作
    self._etable[CMD.CMD_INGAME_BUY]    =  ET.CMD_INGAME_BUY --牌桌内购买道具列表

    self._etable[CMD.GAME_TASK_CHANGE_NTF] = ET.GAME_TASK_CHANGE_NTF --通知玩局有礼任务更新

    self._etable[CMD.ICON_FRAME_CHANGE_EVT] = ET.ICON_FRAME_CHANGE_EVT --通知玩局有礼任务更新  

    self._etable[CMD.NEWEVENT_SHOW_CARD_NTF] = ET.LIGHT_CARD    --新比赛场明牌通知

    --cmd:30062 赛事段位更新通知
    self._etable[CMD.NEWEVENT_LEVEL_CHANGE_NTF] = ET.MATCH_LV_CHANGE_NTF;

    --cmd:180 小红点更新通知
    self._etable[CMD.DDZLITTLE_REDDOT_NTF] = ET.DDZLITTLE_REDDOT_NTF;

    --cmd:9050
    self._etable[CMD.TUIGUANG_INFO_NTF] = ET.TUIGUANG_INFO_NTF
    
end

function ETAdapter:findEventByCmd( cmd )
    if not cmd then return nil end

    if self._etable[cmd] == nil then 
        loge(" error , 未定义的cmd与事件.." ..  cmd ,self.TAG) 
        return nil
    end
    
    return self._etable[cmd]
end

return ETAdapter
