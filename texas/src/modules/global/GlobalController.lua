
local GlobalController = class("GlobalController",qf.controller)
GlobalController.TAG = "GlobalController"

local globalView = import(".GlobalView")
local UserInfo = import(".components.UserInfo")
local CommonTipWindow = import(".components.CommonTipWindow")
local BuyPopupTipView = import("src.modules.shop.components.BuyPopupTipView")
local PayMethodView = import("src.modules.shop.components.PayMethodView")

function GlobalController:ctor(parameters)
    GlobalController.super.ctor(self)
    self.waittingCount = 0
    self.waitting = false
    self.loginWaitting = false
    self._broadcast = {}
    self._newWorldMsgList = {}
end

function GlobalController:initView(parameters)
    local view = globalView.new()
    return view
end

function GlobalController:initModuleEvent()

end

function GlobalController:removeModuleEvent()

end

function GlobalController:initGlobalEvent()
    --获取个人信息
    qf.event:addEvent(ET.GLOBAL_GET_USER_INFO, handler(self, self.processGetUserInfo))
    --显示个人信息
    qf.event:addEvent(ET.GLOBAL_SHOW_USER_INFO, handler(self, self.processShowUserInfo))

    qf.event:addEvent(ET.GLOBAL_SHOW_MAIN_DIALOG, handler(self, self.showMainDialog))

    qf.event:addEvent(ET.GAME_GENERAL_NOTICE,function(paras)
        -- 第一个是类型，第二个传的具体参数
        local commands = string.split(paras.model.command,"|")
        dump("commands")
        dump(commands)
        if commands[1] == "GAME_WANT_RECHARGE" then
            self:wantRecharge(commands[2])
        elseif commands[1] == "GAME_ACT_MATCH_VIEW" then
            qf.event:dispatchEvent(ET.SHOW_MATCHHALL_VIEW)
            qf.event:dispatchEvent(ET.CLOSE_ACTIVE_VIEW)
        elseif commands[1] == "GAME_ACT_EXCHANGE" then
            qf.event:dispatchEvent(ET.SHOW_EXCHANGEMALL_VIEW)
            qf.event:dispatchEvent(ET.CLOSE_ACTIVE_VIEW)
        elseif commands[1] == "WEBVIEW_CLOSE" then
            qf.event:dispatchEvent(ET.ACTIVITY_HIDE_WEBVIEW)
        end
        qf.event:dispatchEvent(ET[paras.model.command])
    end)

    qf.event:addEvent(ET.GET_TIME_REWARD_INFO,handler(self,self.showTimeReward))
    qf.event:addEvent(ET.GET_POCAN_REWARD_INFO,handler(self,self.showPoCanReward))
    qf.event:addEvent(ET.COMMON_REDTIPS_NOTIFY,handler(self,self.xiaoHongDianRefresh))

    --刷新道具通知
    qf.event:addEvent(ET.EVENT_USER_DAOJU_CHANGE,handler(self,self.refreshDaoju))

    qf.event:addEvent(ET.SHOW_ACTIVE_NOTICE_VIEW,handler(self,self.showActiveNoticeView))
    qf.event:addEvent(ET.SHOW_ACTIVE_NOTICE,handler(self,self.showActiveNotice))
    qf.event:addEvent(ET.HIDE_ACTIVE_NOTICE,handler(self,self.hideActiveNotice))

    qf.event:addEvent(ET.DAILYREWAED,handler(self,self.dailylogin))
    qf.event:addEvent(ET.REALNAME,handler(self,self.realName))
    qf.event:addEvent(ET.INVITEGAMETIPS,handler(self,self.inviteGameTips))
    qf.event:addEvent(ET.BANKRUPTTIPS,handler(self,self.bankruptTips))
    qf.event:addEvent(ET.RECHARGETIPS,handler(self,self.rechargeTips))
    -- 支付loading界面显示
    qf.event:addEvent(ET.EVENT_SHOP_SHOWLOADING, function(paras)
        -- body
        self.view:showPayLoading(paras)
    end) 

    qf.event:addEvent(ET.EVENT_BAND_WEIXIN, function(paras)
        qf.platform:sdkAccountLogin({type = 3,cb = function( data )
            GameNet:send({cmd = CMD.BAND_WEIXIN_REQ,body={uin = Cache.user.uin,openid = data.openid,unionid = data.unionid,access_token =data.token},callback = function(rsp) 
                if rsp.ret ~= 0 then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.bind_wechat_success})
                    Cache.user.is_bind_wx = 1
                    if paras.cb then
                        paras.cb()
                    end
                end
            end})
        end
            })
    end) 
    qf.event:addEvent(ET.EVENT_SCORE_CHANGED,function(rsp)
        local model = rsp.model
        if model.credit_type == 1 then
            Cache.desk.jifen = rsp.model.gain_score
        elseif model.credit_type == 2 then --BR_JIFEN_EVT
            qf.event:dispatchEvent(ET.BR_JIFEN_EVT,{score = rsp.model.gain_score})
        elseif model.credit_type == 3 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.jifen_add_word..rsp.model.gain_score})
        end
        Cache.user.score = rsp.model.user_score
        logd(pb.tostring(rsp.model))
    end)

    qf.event:addEvent(ET.GLOBAL_WAIT_NETREQ,handler(self,self.processWaitReq))
    qf.event:addEvent(ET.GLOBAL_TOAST,handler(self,self.showToast))
    qf.event:addEvent(ET.GLOBAL_COIN_ANIMATION_SHOW,handler(self,self.processCoinAnimation))
    qf.event:addEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, handler(self, self.processDiamondAnimation))
    qf.event:addEvent(ET.GAME_SHOW_SHOP_PROMIT,handler(self,self.processShopPromitShow))

    qf.event:addEvent(ET.GLOBAL_WAIT_EVENT,handler(self,self.processWaitEvent))
    qf.event:addEvent(ET.NET_AUTO_INPUT_ROOM,handler(self,self.processAutoInputRoom))
    
    qf.event:addEvent(ET.GLOBAL_HANDLE_BANKRUPTCY,handler(self,self.processHandlebankruptcy))
    qf.event:addEvent(ET.GLOBAL_HANDLE_PROMIT,handler(self,self.processHandlePromit))
    --破产补助详细信息--
    qf.event:addEvent(ET.NET_COLLAPSE_PAY_REQ,handler(self, self.getCollapsePayConfReq))
    --领取救济金请求
    qf.event:addEvent(ET.NET_GET_COLLAPSE_PAY_REQ,handler(self, self.getCollapsePayReq))

    --收到服务端 更新 活动图标的 消息
    qf.event:addEvent(ET.NET_GET_FINISH_ACTIVITY_EVT,handler(self, self.updateActivityNum))

    -- 程序切入后台
    qf.event:addEvent(ET.APPLICATION_ACTIONS_EVENT, handler(self, self.processApplicationMessage))
    
    --新的每日登录领取
    qf.event:addEvent(ET.EVENT_LOGIN_REWARD_GET,handler(self, self.getNewUserLoginDayRewardConf))

    --新手每日累计登录
    qf.event:addEvent(ET.EVENT_NEWUSER_LOGIN_REWARD_GET,handler(self, self.getNewUserLoginRewardConf))

    qf.event:addEvent(ET.SHOW_BANNER_POP,handler(self,self.showbannerPop))--bannerPop

    qf.event:addEvent(ET.SHOW_FIRSTRECHARGE_POP,handler(self,self.showFirstRecharge))
    qf.event:addEvent(ET.HIDE_FIRSTRECHARGE_POP,handler(self,self.removeFirstRecharge))

    --显示最新计费
    qf.event:addEvent(ET.GLOBAL_SHOW_NEWBILLING,handler(self, self.showNewBilling))
    --注销功能
    qf.event:addEvent(ET.GLOBAL_CANCELLATION,handler(self, self.logOut))
    --小喇叭
    qf.event:addEvent(ET.SEND_LABA,handler(self, self.userBroadcast))

    qf.event:addEvent(ET.GET_DAY_LOGIN_REWARD_CFG,handler(self,self.getDayLoginRewardCfg))
    qf.event:addEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT, handler(self, self.handlerShowTipWindow))

    --举报
    qf.event:addEvent(ET.EVT_USER_REPORT, handler(self, self.userReport))

    --[[
        支付/购买相关
    ]]
    qf.event:addEvent(ET.NET_BAROADCAST_DIM_EVT, handler(self, self.recevieDeliveryAdviceNotify))       --充值成功，发货通知
    qf.event:addEvent(ET.REFRESH_BANKRUPTCY_POPUP, handler(self, self.updateBankruptcyPopup))           --充值成功，更新破产补助弹框
    qf.event:addEvent(ET.NET_DIAMOND_CHANGE_GLOBAL_EVT, handler(self, self.userDiamondChangedNotify))   --钻石变更
    qf.event:addEvent(ET.NET_UPDATA_GOLD_EVT, handler(self, self.userGoldChangedNotify))             
    -- 打开购买提示框
    qf.event:addEvent(ET.EVENT_SHOW_BUY_POPUP_TIP_VIEW, handler(self, self.handlerShowBuyPopupTipView))
    -- 打开支付方式框
    qf.event:addEvent(ET.EVENT_SHOW_PAY_METHOD_VIEW, handler(self, self.handlerShowPayMethodView))

    qf.event:addEvent(ET.GAME_PAY_NOTICE,handler(self,self.processPayNotice))                           --购买钻石
    qf.event:addEvent(ET.NET_PRODUCT_EXCHANGE_BY_DIAMOND, handler(self, self.exchangeProductByDiamond)) --用钻石兑换金币/道具
    qf.event:addEvent(ET.USER_ACTION_STATS_EVT, handler(self, self.userActionStatsProcess))             --用户行为统计

    --显示登录等待页面
    qf.event:addEvent(ET.LOGIN_WAIT_EVENT, handler(self, self.handlerLoginWait))

    --打开大转盘
    qf.event:addEvent(ET.SHOW_TURNTABLE, handler(self, self.showTurnTable))
    qf.event:addEvent(ET.REMOVE_TURNTABLE,handler(self,self.removeTurnTable))
    qf.event:addEvent(ET.SHOW_FIRSTGAME,handler(self,self.showFirstGame))--启动资金
    qf.event:addEvent(ET.REMOVE_FIRSTGAME,handler(self,self.removeFirstGame))--启动资金
    qf.event:addEvent(ET.SHOW_NEWSLEAD,handler(self,self.showNewsLead))--消息引导
    qf.event:addEvent(ET.REMOVE_NEWSLEAD,handler(self,self.removeNewsLead))--消息引导
    --免费金币信息显示
    qf.event:addEvent(ET.SHOW_FREEGOLDSHORTCUT,handler(self, self.showFreeGoldShortCut))

    --游戏匹配界面
    qf.event:addEvent(ET.SHOW_GAME_MATHING_VIEW,function(paras)
        self.view:MathingView(paras)
    end)
    --游戏匹配界面
    qf.event:addEvent(ET.REMOVE_GAME_MATHING_VIEW,function(paras)
        self.view:removeMathingView()
    end)
    --更新游戏匹配界面
    qf.event:addEvent(ET.UPDATE_GAME_MATHING_VIEW,function(paras)
        self.view:updateMathingData(paras)
    end)
    --每日排行
    qf.event:addEvent(ET.DAY_LEVEL_RANK, handler(self, self.getDayLevelRank))
    --总排行
    qf.event:addEvent(ET.WORLD_LEVEL_RANK, handler(self, self.getWorldLevelRank))
    qf.event:addEvent(ET.FOCAS_TASK_VIEW_SHOW_AND_CLOSE_FACAS_VIEW, handler(self, self.showFocatips))
    --新手礼包奖券提示
    qf.event:addEvent(ET.EVENT_NEWUSER_LOGIN_REWARD_FOCATIPS,handler(self, self.showFocatips)) 
    --首充礼包通知
    qf.event:addEvent(ET.FIRSTRECHARGE_INFO,handler(self, self.firstChargeConfRsp))
    --首充礼包支付成功通知
    qf.event:addEvent(ET.FIRSTRECHARGE_SUCCESS_INFO,handler(self, self.firstChargeSuccessRsp))
    -- 破产补助消息提示
    qf.event:addEvent(ET.DDZBANKRUPTPTOTECTRSP,handler(self, self.getBankruptTipsRsp))
    -- 破产补助消息提示
    qf.event:addEvent(ET.DDZBANKRUPTPTOTECTSHOW, handler(self, self.showBankruptTipsWin))

    --房间内消息通知
    qf.event:addEvent(ET.NO_GOLD,handler(self,self.NO_GOLD))

    --打开新手礼红包弹窗
    qf.event:addEvent(ET.SHOW_RED_PACKAGE, handler(self, self.showRedPackageView))

    --牌桌内购买道具列表
    qf.event:addEvent(ET.CMD_INGAME_BUY,handler(self,self.getInGameBuyList))

    --显示赛季战报
    qf.event:addEvent(ET.CMD_SHOW_MATCH_REPORT, handler(self, self.showMatchReport))

    --显示赛季榮譽
    qf.event:addEvent(ET.CMD_SHOW_MATCH_HONOR, handler(self, self.showMatchHonor))

    --头像框的显示
    qf.event:addEvent(ET.SHOW_MY_HEADBOX,handler(self,self.showMyHeadBox))

    qf.event:addEvent(ET.SHOW_MATCHHALL_VIEW,handler(self,self.showMatchHallView))
    
    --跳转到金币场的快速开始
    qf.event:addEvent(ET.EVENT_JUMP_QUICK_COIN_GAME, function ( rsp )
        qf.event:dispatchEvent(ET.EVENT_JUMP_TO_COIN_GAME,{})
        Util:delayRun(0.2,function ( ... )
            qf.event:dispatchEvent(ET.QUICKSTARTCLICK)
        end)
    end)

    qf.event:addEvent(ET.ICON_FRAME_CHANGE_EVT,function ( rsp )
        loga("============ICON_FRAME_CHANGE_EVT=============")
    end)   

    qf.event:addEvent(ET.MATCH_LV_CHANGE_NTF, function ( rsp )
        if rsp.ret == 0 then
            Cache.user:updateNewUserMatchLevel(rsp.model.all_lv_info)
            qf.event:dispatchEvent(ET.NOT_MAINVIEW_LEVEL_CHANGE ,{}) 
        end
    end)
    
    --开宝箱
    qf.event:addEvent(ET.EVENT_OPEN_BAOXIANG, function ( paras )
        if paras and paras.match_box_lv then
            GameNet:send({
                cmd = CMD.NEWEVENT_OPEN_BOX_REQ,
                body = {
                    match_box_lv = paras.match_box_lv
                },
                callback = function ( rsp )
                    if paras.cb then
                        paras.cb(rsp)
                        return
                    end
                    if rsp.ret == 0 then
                        
                    else
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                    end
                end
            })
        end
    end)
    
    --小红点推送通知
    qf.event:addEvent(ET.DDZLITTLE_REDDOT_NTF, handler(self, self.onRedChange)) 

    qf.event:addEvent(ET.GET_EXCHANGEMALL_INFO,function(parms)
        GameNet:send({cmd=CMD.EXCHANGE_INFO_REQ,body={},callback=function(rsp)
            if rsp.ret == 0 then
                Cache.ExchangeMallInfo:saveConfig(rsp.model)
                if parms.cb then
                    parms.cb(true)
                end
        	else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
                if parms.cb then
                    parms.cb(false)
                end
        	end
        end})
    end)

    qf.event:addEvent(ET.GET_QUICK_START_ROOMID,function(parms)
        GameNet:send({cmd=CMD.QUICK_START,body={play_mode=1},callback=function(rsp)
            if rsp.ret == 0 then
                if parms.cb then
                    parms.cb(rsp)
                end
        	else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
        	end
        end})
    end)
end

--小红点信息变化通知 (新同步小游戏 180)
function GlobalController:onRedChange(rsp)
    if rsp.ret == 0 then  -- 头像框红点的更新
       Cache.user:updateUserRedInfo(rsp.model)
       qf.event:dispatchEvent(ET.USER_HEADBOX_RED_NTF)
    end
end

------------------临时使用------------------
--获取破产补助详细信息
function GlobalController:getCollapsePayConfReq()
    GameNet:send({cmd=CMD.COLLAPSE_PAY,txt=GameTxt.net002,
            callback=function(rsp)
                if rsp.ret == 0 and rsp.model ~= nil then
                    Cache.Config:setBankruptcyFetchCount(rsp.model.fetch_count)-- 保存领取破产补助次数         
                    local bankruptcy = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.bankruptcy)
                    if  bankruptcy ~= nil then
                        if rsp.model.fetch_count >= Cache.Config.bankrupt_count or Cache.user.gold > 1000 then
                            if bankruptcy:isVisible() == true then
                                bankruptcy:refreshBankruptcyInfo(rsp.model)
                            else
                                qf.event:dispatchEvent(ET.GLOBAL_SHOW_NEWBILLING,
                                    {room_id = Cache.desk.roomid or 1, ref=UserActionPos.GAME_POCHAN})
                            end
                        else
                            bankruptcy:refreshBankruptcyInfo(rsp.model)
                        end
                    end
                end
            end})
end
--领取救济金请求
function GlobalController:getCollapsePayReq()
    GameNet:send({cmd=CMD.GET_COLLAPSE_PAY,txt=GameTxt.net002,body={refer=UserActionPos.SHORTCUT_REF},
    callback=function(rsp)
    loga(rsp.ret)
        if rsp.ret == 0 then
            --qf.platform:umengStatistics({umeng_key = "HelpGold"})
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=GameTxt.global_string108})
            qf.event:dispatchEvent(ET.GLOBAL_COIN_ANIMATION_SHOW,{})
            qf.event:dispatchEvent(ET.GET_POCAN_REWARD_INFO)
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=Cache.Config._errorMsg[rsp.ret]})
        end
    end})
end

--更新活动图标数据通知
function GlobalController:updateActivityNum(rsp)
    Cache.Config.FinishActivityNum = rsp.model.num or 0
    qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="activity",number=Cache.Config.FinishActivityNum,addNumber=Cache.Config.RecieveAwardNum})
end

--获取新手每日登陆奖励配置
function GlobalController:getNewUserLoginDayRewardConf(paras)
    GameNet:send({
        cmd = CMD.GET_NEW_DAY_LOGIN_REWARD_CFG,
        callback= function(rsp)
            if rsp.ret ~= 0 then
                --不成功提示
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            else 
                if ModuleManager:judegeIsInMain() == false then
                    return
                end

                if rsp.model.flag == 1 then
                    if not PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.dailylogin) then 
                        qf.event:dispatchEvent(ET.DAILYREWAED,{method="show",cb=paras.cb, model = rsp.model})
                    end

                else
                    PopupManager:pop()
                end   
            end
        end})
end

--获取新手累计登陆奖励配置
function GlobalController:getNewUserLoginRewardConf(paras)
    GameNet:send({ cmd = CMD.GET_DAY_LOGIN_REWARD_CFG,
    callback= function(rsp)
        if rsp.ret ~= 0 then
            --不成功提示
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        else  
            Cache.user:updateDailyRewardConfInfo(rsp.model)
            if paras and paras.cb then
               paras.cb()
            end
        end
end})
end

--显示最新计费
function GlobalController:showNewBilling(paras)
    if self.view == nil or paras == nil then return end
        self.view:showNewBilling(paras)
end

--登出
function GlobalController:logOut()
    GameNet:send({cmd=CMD.LOGOUT,callback = function(rsp)
        dump(rsp.ret, "注销ret")
        if rsp.ret == 0 then
            Cache.user.show = nil
            self:processLogout()
            qf.event:dispatchEvent(ET.REMOVETIMEOUT)
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        end
    end})
end

--使用小喇叭
function GlobalController:userBroadcast(paras)
    if paras ==nil or paras.content == nil then
        return
    end 
    GameNet:send({
        cmd=CMD.CMD_USER_BROADCAST,
        body={content=paras.content},txt=GameTxt.net002,
        callback = function(rsp)
            if rsp.ret ~= 0 then
                --不成功提示
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            else
                qf.event:dispatchEvent(ET.EVENT_QUERY_DAOJU_BY_ID,{ prop_id = "little_horn" })
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.send_laba_succuse })
            end
        end}
    )
end

--打开免费金币弹窗
function GlobalController:showFreeGoldShortCut()
    GameNet:send({ cmd = CMD.GET_DAY_LOGIN_REWARD_CFG,callback= function(rsp)
        if rsp.ret ~= 0 then
            --不成功提示
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        else
            self.view:showFreeGoldShortCut(rsp.model)
        end

    end})
end

--获取每日排行
function GlobalController:getDayLevelRank(paras)
    GameNet:send({cmd=CMD.APPGOLDFRIDENDANKRSP,callback=function(rsp)
        if rsp.ret==0 then
            --loga("每日排行:\n"..pb.tostring(rsp.model))
            if paras.cb then
                paras.cb(rsp.model)
            end
        else
            loga("获取每日排行失败:"..rsp.ret)
        end
    end})
end

--获取世界排行
function GlobalController:getWorldLevelRank(paras)
    GameNet:send({cmd=CMD.APPGOLDWORLDRANKRSP,callback=function(rsp)
        if rsp.ret==0 then
            --loga("总排行:\n"..pb.tostring(rsp.model))
            if paras.cb then
                paras.cb(rsp.model)
            end
        else
            loga("获取总排行失败:"..rsp.ret)
        end
    end})
end

--打开奖券获取界面
function GlobalController:showFocatips(paras)
    qf.event:dispatchEvent(ET.CLOSE_ACTIVE_VIEW)
    Util:delayRun(0.25, function ( ... )
        qf.event:dispatchEvent(ET.SHOW_FOCASTASK_VIEW)
    end)
end

--首冲礼包配置消息推送
function GlobalController:firstChargeConfRsp(rsp)
    Cache.user:updateFirstRechargeInfo(rsp.model)
    Util:delayRun(0.5, function ( ... )
        if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
            PopupManager:push({event = ET.SHOW_FIRSTRECHARGE_POP, show_type = 1})
        end
    end)
end

--首冲成功消息推送
function GlobalController:firstChargeSuccessRsp(rsp)
    Cache.user:updateFirstRechargeInfo(rsp.model)
    if Cache.user.firstChargeConfInfo then 
        Cache.user.firstChargeConfInfo.payGiftInfoBackSuccess = true
        if Cache.user.firstChargeConfInfo.payFirstRechargeSuccess ==  true then
            self:showFirstRechargeSuccess()
            Cache.user.firstChargeConfInfo.payGiftInfoBackSuccess = false
            Cache.user.firstChargeConfInfo.payFirstRechargeSuccess = false
        end
    end
end

--破产补助消息推送
function GlobalController:getBankruptTipsRsp(rsp)
    loga("破产补助消息提示DDZBANKRUPTPTOTECTRSP:"..pb.tostring(rsp.model))
    if rsp.model then
        Cache.user:saveUserBankRuptInfo(rsp.model)
        if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
            if Cache.DDZDesk.status ~= GameStatus.INGAME and Cache.user.newBankruptInfo and Cache.user.newBankruptInfo.hasRecieveBankruptMessage == true 
            and Cache.user.loginFinish and Cache.DDZDesk.enterRef ~= GAME_DDZ_NEWMATCH then
                qf.event:dispatchEvent(ET.DDZBANKRUPTPTOTECTSHOW)
            end
        end
    end   
end

--打开破产补助消息提示弹窗
function GlobalController:showBankruptTipsWin()
    Cache.user.newBankruptInfo.hasRecieveBankruptMessage = false
    Cache.user.IsNeedWaitInGameEndBankrupt = false
    qf.event:dispatchEvent(ET.BANKRUPTTIPS,{method="show",model = Cache.user.newBankruptInfo,cb=show})
end

function GlobalController:showFirstRechargeSuccess()
    local rechargeGift_list = Cache.user.firstChargeConfInfo.reward_gift or {}
    local recursive
    local rewardInfo = {}
    for i=1,#rechargeGift_list do
        local itemData = rechargeGift_list[i]
        table.insert(rewardInfo, {
            type=itemData.type,
            desc=itemData.name..string.format("x%d",itemData.num),
            imgUrl=itemData.icon_path
        })
    end

    qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {getRewardType = 2,rewardInfo = rewardInfo})

    Cache.user.firstChargeConfInfo.hasEntryControl = false
    qf.event:dispatchEvent(ET.HIDE_FIRSTRECHARGE_POP)
    qf.event:dispatchEvent(ET.HIDE_FIRSTRECHARGE_ENTRY)
    qf.event:dispatchEvent(ET.HIDE_FIRSTRECHARGE_ENTRY_hallView)

    Cache.user.recharged = true
    qf.event:dispatchEvent(ET.FIRSTRECHARGE_PAYSUCCESS_REFRESH_SHOP) 
end

--每日登陆
function GlobalController:dailylogin(paras)
    if paras.method == "show" then
        self.view:showDailyLogin(paras)
    elseif paras.method == "hide" then
        self.view:hideDailyLogin()
    elseif paras.method == "init" then
        self.view:dailyLoginData(paras.model)
    end
end

--bannerPop显示
function GlobalController:showbannerPop(paras)
    -- body
    self.view:showBannerPop(paras)
end

--首充显示
function GlobalController:showFirstRecharge(paras)
    -- body
    self.view:showFirstRecharge(paras)
end

--首充删除
function GlobalController:removeFirstRecharge(paras)
    -- body
    self.view:hideFirstRecharge()
end

--实名认证
function GlobalController:realName(paras)
    -- body
    if paras.method == "show" then -- 展示实名认证界面
        self.view:showRealName(paras)
    end
end

--匹配邀请提示
function GlobalController:inviteGameTips( paras )
    -- body
    if paras.method == "show" then -- 展示实名认证界面
        self.view:showInviteGameTips(paras)
    end
end

--破产补助提示
function GlobalController:bankruptTips( paras )
    -- body
    if paras.method == "show" then -- 展示破产补助
        self.view:showBankruptTips(paras.model)
    end
end

--匹配邀请金币不足提示
function GlobalController:rechargeTips( paras )
    -- body
    if paras.method == "show" then -- 展示实名认证界面
        self.view:showRechargeTips(paras)
    elseif paras.method == "hide" then --隐藏实名认证界面
        self.view:hidenRechargeTips()
    end
end

function GlobalController:handlerLoginWait(paras)
    if paras == nil or paras.method == nil or self.view == nil then return end

    if paras.method == "show" then
        self.view:showLoginWait(paras.txt)
    elseif paras.method == "hide" then
        self.view:hideLoginWait()
    end
end

function GlobalController:processApplicationMessage(paras)
    if not paras or not paras.type then return end
    local cache_desk = Cache.DeskAssemble:getCache()
    local deskid = checkint(cache_desk.desk_id)
    local roomid = checkint(cache_desk.room_id)
    local game_type = Cache.DeskAssemble:getGameType()

    if paras.type == "show" then
        Util:cleanSwallowTouchesLayer()
        local inGame = false
        if (0 < deskid and 0 < roomid) or (Cache.DeskAssemble:judgeGameType(BRC_MATCHE_TYPE)) then -- 在房间中
            inGame = true
            GameNet:clean()
        elseif Cache.DeskAssemble:judgeGameType(MTT_MATCHE_TYPE) then
            local event_id = checkint(cache_desk:getEventId())
            if event_id > 0 then
                inGame = true
                GameNet:clean()
            end
        end

        if Cache.TBZPlayerInfo then
            if Cache.TBZPlayerInfo.Game_Type == 1 then --在推豹子房间中
                inGame = true
                GameNet:clean()
            end 
        end

        --音效处理
        self:processAudioResumeFromBg(inGame)
        -- 由于切入后台再切入前台，lua端会删除一部分网络消息，其中包括onDisconnect事件。
        -- 比如 游戏切入后台后，完全断网，隔一段时间后切入前台，就会出现检测不到onDisconnect的情况。所以需要自己判断一下，手工出发一下onDisconnect
        -- 并弹出loading框，进行reconnect
        GameNet:resume()
        if not GameNet:isConnected() then
            Util:delayRun(0.03,function () -- 解决MI3后台断网重连崩溃bug
                GameNet:onDisconnect()
            end)
        elseif inGame then
            -- 显示等待界面
            qf.event:dispatchEvent(ET.GAME_SWITCH_FB, 'show')
        else
            qf.event:dispatchEvent(ET.APPLICATION_RESUME_NOTIFY, {})    --不在游戏内的其他模块需要处理后台返回，可以处理此消息
        end

        if inGame then
            Cache.user.come_back = true
        else
            Cache.user.come_back = false
        end

    elseif paras.type == "hide" then
        if 0 < deskid and 0 < roomid then
            qf.event:dispatchEvent(ET.GAME_SWITCH_FB, '.')
        end

        self:processAudioPauseToBg()
        GameNet:pause()
    else
    end
end

--用户信息变更广播处理(消息分发)
function GlobalController:processProfileChanged(paras)
    if paras == nil or paras.model == nil then return end
    logd("用户隐身广播(506)\n"..pb.tostring(paras.model))
    local cache_desk = Cache.DeskAssemble:getCache()
    local user=cache_desk:getUserByUin(paras.model.uin)
    local userinfo_view = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.userinfo)--中途更改数据 通知个人资料卡
    if userinfo_view ~= nil then
        if userinfo_view.uin==paras.model.uin then 
            userinfo_view.real_hiding=paras.model.hiding
            userinfo_view.real_nick=paras.model.nick
            userinfo_view.real_portrait=paras.model.portrait
            if paras.model.hiding==1 then --如果打开隐身
                userinfo_view.hide_nick=paras.model.nick 
            end
            userinfo_view:setBreakHideName(paras.model.nick)
        end
    end
    if user and user.be_antit and paras.model.hiding==1 then --如果这个在这个玩家被破隐且是改成隐身状态时则屏蔽这个玩家的修改
       return
    end
    if paras.model.uin == Cache.user.uin then
        Cache.user:updateCacheByProfileChange(paras.model)	--更新缓存
    end
    qf.event:dispatchEvent(ET.PROFILE_CHANGE_GAME_EVT, paras.model)		--游戏中处理用户信息变更
end

--头像上传成功通知(消息分发)
function GlobalController:processHeadUpdate(paras)
    if paras == nil or paras.model == nil then return end
    logd("头像上传成功通知(507)\n"..pb.tostring(paras.model))
    Cache.user.portrait = paras.model.portrait
    --用户信息编辑界面头像刷新
    qf.event:dispatchEvent(ET.CHANGE_VIEW_UPDATE_USER_HEAD)
    --主界面头像刷新
    qf.event:dispatchEvent(ET.MAIN_UPDATE_USER_HEAD)
    qf.event:dispatchEvent(ET.UPDATE_CHOSEHALL_HEADIMG)
end

function GlobalController:wantRecharge(itemId)
    if ModuleManager:judegeIsInShop() then
        local shopView = ModuleManager["shop"]:getView()
        shopView:webviewExit()
        return 
    end
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})

    if itemId then
        -- 直接去支付
        local methods = Cache.QuickPay:getPayMethodsByGoldItemName(itemId)
        if 1 >= #methods then -- 只有一种支付方式
            local payInfo = Cache.PayManager:getPayInfoByItemNameAndMethod(itemId, methods[1])
            payInfo.ref = UserActionPos.ACTIVITY_SHOP
            qf.event:dispatchEvent(ET.GAME_PAY_NOTICE, payInfo)
        else
            local ret = {}
            ret.data = Cache.PayManager:getGoldInfoByItemName(itemId)
            ret.method = methods
            ret.ref = UserActionPos.ACTIVITY_SHOP
            qf.event:dispatchEvent(ET.EVENT_SHOW_PAY_METHOD_VIEW, ret)
        end
        qf.platform:umengStatistics({umeng_key = "PayOnActivity",umeng_value = itemId}) -- 活动内支付点击上报
    else
        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK,{name = "shop",delay = 0,cb = function() end})
    end
    
    qf.platform:removeWebView()
end

function GlobalController:processHandlePromit(paras)
    if paras.type == 1 then --弹出公共提示框
        self.view:showGlobalPromit(paras.body)
    elseif paras.type == 2 then --隐藏公共提示框
        self.view:hideGlobalPromit()
    end
end

function GlobalController:processHandlebankruptcy(paras)
    if paras.method == "show" then --展示破产界面
        self.view:showBankruptcy(paras)
    elseif paras.method == "hide" then --隐藏破产界面
        self.view:hideBankruptcy()
    elseif paras.method == "update" then --更新破产界面
        self.view:updateBankruptcy(paras.type)
    end
end

function GlobalController:processAutoInputRoom()
    loge("断线重连. roomid="..Cache.user.old_roomid..", event_id="..Cache.user.event_id..", gametype="..Cache.user.room_type..", old_roomid="..Cache.user.old_roomid)
    loga("断线重连. roomid="..Cache.user.old_roomid..", event_id="..Cache.user.event_id..", gametype="..Cache.user.room_type..", old_roomid="..Cache.user.old_roomid)
    if Cache.user.old_roomid > 0 then
        --斗地主  0:无  1: 斗地主   暂时是写死的。目前就判断0吧（等服务器改）
        if Cache.user.room_type == 0 then
            GameNet:send({cmd=CMD.CONFIG,body = {timestamp = "",os = qf.device.platform},
                callback=function(rsp)
                    if rsp.ret ~= 0 then
                        return  
                    end
                    Cache.DDZconfig:saveConfig(rsp.model)
                end
            })
            qf.event:dispatchEvent(ET.DDZ_NET_INPUT_REQ,{roomid = Cache.user.old_roomid, deskid = Cache.user.desk_id })
        end
    else
        --如果之前没在牌桌内再要判断有没有在MTT大厅内
        qf.event:dispatchEvent(ET.APPLICATION_RESUME_NOTIFY)
        Cache.user.reConnect_status = false

        ModuleManager:remove("game")
    end

end

function GlobalController:processWaitEvent (paras) 
    if paras == nil or paras.method == nil or self.view == nil then return end

    if paras.method == "show" then
        self.view:showFullWait(paras)
    elseif paras.method == "update" then 
        self.view:updateFullWait(paras.txt)
    elseif paras.method == "hide" then
        self.view:hideFullWait()
    end
end

function GlobalController:processCoinAnimation ( paras )
    MusicPlayer:playMyEffect("TASK_GOLD")
    self.view:showCoinAnimation(paras)
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
end

--[[
    播放得到钻石动画.
    参数: diamond, 得到的钻石. free, 免费的钻石
]]
function GlobalController:processDiamondAnimation(paras)
    MusicPlayer:playMyEffect("DIAMOND_POPUP")
    self.view:showDiamondAnimation(paras)
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
end


function GlobalController:processShopPromitShow(paras)
    self.view:showShopPromit(paras)
end

--[[
    payType 0代表商城支付
            1代表促销方式
            2代表游戏内主动点击 快捷支付
            3代表进入房间时 金币不足弹出的支付
            4代表游戏内 金币不足被踢起 时提醒支付
        （payType仅用于umeng统计）
]]
function GlobalController:processPayNotice(paras)
    if qf.device.platform == "ios" then
        qf.event:dispatchEvent(ET.EVENT_SHOP_SHOWLOADING,{isVisible = true})
    end
    --调用 Android 或者 iso的支付接口
    paras.payType = paras.payType or 0 --如果没有传递支付类型 默认是从商城过来的支付
    paras.cb = handler(self,self.payCallBack)
    paras.ref = paras.ref or UserActionPos.SHOP_REF
    --支付信息备份
    self.pay_record = {}
    self.pay_record.paymethod = paras.paymethod --支付方式
    self.pay_record.refer = paras.ref           --ref id
    self.pay_record.buy_diamond = paras.diamond --买入钻石
    self.pay_record.return_diamond = paras.return_diamond or 0   --返还钻石
    --开始支付
    paras.return_diamond = nil
    qf.platform:allPay(paras)
end

--[[-- 
    resultCoden 0支付成功  1支付成功显示等待服务端回调进度条
    --]]
function GlobalController:payCallBack(paymethod, paras)
    if qf.device.platform == "ios" then
        qf.event:dispatchEvent(ET.EVENT_SHOP_SHOWLOADING,{isVisible = false})
    end
    local paras = qf.json.decode(paras)
    local resultCode = tonumber((paras.resultCode or 0))
    paras.payType = tonumber(paras.payType or 0)
    if resultCode == 0 then
        Util:delayRun(0.4,function ( sender )
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
            if paymethod == PAYMETHOD_APPSTORE then
                --ios支付弹窗会导致网络消息堆积,这里在游戏内则重新进桌
                qf.event:dispatchEvent(ET.APPLICATION_ACTIONS_EVENT,{type="show"})
            end
        end)
    elseif resultCode == 1 then
        Util:delayRun(0.1,function ( sender )
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=GameTxt.net006})
        end)
    else
        Util:delayRun(0.1,function ( sender )
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
            if paymethod == PAYMETHOD_APPSTORE then
                --ios支付弹窗会导致网络消息堆积,这里在游戏内则重新进桌
                qf.event:dispatchEvent(ET.APPLICATION_ACTIONS_EVENT,{type="show"})
            end
        end)
    end
end

function GlobalController:processWaitReq(paras)
    paras = paras or {}
    local method = paras.method or "none"
    local txt = paras.txt or "waitting..."
    
    if method == "add" then 
        
        if paras.reConnect == 1 then
            if self.loginWaitting == false then
                self.view:addWaitting({txt = txt,reConnect = paras.reConnect})
                self.loginWaitting = true
            end
        else
            self.waittingCount = self.waittingCount + 1
            if self.waitting == false then
                self.view:addWaitting({txt = txt})
                self.waitting = true
            end
        end
        
    elseif method == "remove" then
         if paras.reConnect == 1 then
            if self.loginWaitting == true then 
                self.view:removeWaitting(paras.reConnect)
                self.loginWaitting= false
            end
         else
            self.waittingCount = self.waittingCount <= 0 and 0 or self.waittingCount - 1
            if self.waitting == true and self.waittingCount == 0 then 
                self.view:removeWaitting()
                self.waitting= false
            end
         end
        
    else
    end
end

function GlobalController:showToast(paras)
    if self.view then self.view:showToast(paras) end 
end

function GlobalController:refreshDaoju(paras)
    if paras.model == nil then
        return
    end
    local name = paras.model.name
    local num = paras.model.amount
    if name == "little_horn" then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.buySuccess..num..GameTxt.LabaShopTxt})
    elseif name == "vip_card" then	--VIP卡发货，更新主界面的用户信息
        if paras.model.vip_days ~= nil and paras.model.vip_days > 0 then
            Cache.user.vip_days = paras.model.vip_days
            qf.event:dispatchEvent(ET.GLOBAL_FRESH_MAIN_GOLD)
        end
    elseif name == "anti_stealth_card" then  --破隐卡发货，更新主界面的用户信息
            Cache.user.anti_stealth = paras.model.remain
    end
end

function GlobalController:showTimeReward()
    GameNet:send({cmd=CMD.CMD_QUERY_SCHED_REWARD,txt=GameTxt.net002,
        callback=function(rsp)
                if rsp.ret == 0 and rsp.model ~= nil then

                    local freeGold = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.freeGold)
                    if freeGold then
                       freeGold:showTimeReward(rsp.model)
                    end
                else
                     qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                end
            end})
end

function GlobalController:showPoCanReward()
    GameNet:send({cmd=CMD.CMD_QUERY_BROKE_SUPPLY,txt=GameTxt.net002,
        callback=function(rsp)
                if rsp.ret == 0 and rsp.model ~= nil then
                    local freeGold = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.freeGold)
                    if freeGold then
                       freeGold:showPoCanReward(rsp.model)
                    end
                else
                     qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                end
            end})
end

function GlobalController:xiaoHongDianRefresh(paras)
    if self.view then self.view:xiaoHongDianRefresh(paras) end
end

function GlobalController:showActiveNotice(paras)
     qf.event:dispatchEvent(ET.NET_ALL_ACTIVITY_REQ,{cb = function(model)       
        local len = model.activities:len()
        local showNum = 0
        for i=1,len do
            local item = {}
            item.show_board = model.activities:get(i).show_board
            item.page_url = model.activities:get(i).page_url
            item.board_type = model.activities:get(i).board_type
            item.id = model.activities:get(i).id
            item.board_url = model.activities:get(i).board_url
            if  item.show_board == 1 then
                -- 先下载
                PopupManager:push({event = ET.SHOW_ACTIVE_NOTICE_VIEW, show_type = 1, init_data = {model = item}})
            end
        end

        Cache.user.hasShowActivity = 1
    end}) 
end

function GlobalController:showActiveNoticeView(paras)
    if self.view then
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
        self.view:showActiveNotice(paras.model) 
    end
end

function GlobalController:hideActiveNotice()
    if self.view then self.view:hideActiveNotice(paras) end
end

function GlobalController:getDayLoginRewardCfg()
    GameNet:send({cmd=CMD.GET_DAY_LOGIN_REWARD_CFG,wait=true,txt=GameTxt.net002,
            callback=function(rsp)
                if rsp.ret == 0 and self.view then
                    self.view:setDayLoginRewardCfg(rsp.model)
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=Cache.Config._errorMsg[rsp.ret]})
                end
            end})
end

function GlobalController:handlerShowTipWindow( args )
    PopupManager:push({class = CommonTipWindow, init_data = args})
    PopupManager:pop()
end

function GlobalController:cancellationLogin()
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    cc.UserDefault:getInstance():flush()
    ModuleManager.login:show({isCancellation = true})
end

-- 删除存在的View
function GlobalController:removeExistView()
    if self.view then
        self.view:removeExistView()
    end
end

function GlobalController:processAudioResumeFromBg(inGame)
    if qf.device.platform == "ios" then
        --为了解决cocos2dx的平台适配问题。在IOS平台下会出现后台返回音效消失问题，通过重新实例化SimpleAudioEngine来解决。
        MusicPlayer:destroyInstance()
    end
    if inGame == false then
        MusicPlayer:playBackGround()    --不在游戏中, 黑屏回来, 播放背景音
    end
end

function GlobalController:processAudioPauseToBg()
    MusicPlayer:stopBackGround()
end

function GlobalController:userReport(paras)
    if paras== nil then return end
        GameNet:send({ cmd = CMD.USER_REPORT ,body = {uin =  paras.uin  ,type = paras.type , reason = paras.reason}, callback = function(rsp)
            if rsp.ret ~= 0 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
            else   
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt =GameTxt.send_report_ok})
            end
        end
        })
end


function GlobalController:processLogout()
    ModuleManager:removeByCancellation()

    self:cancellationLogin()
end

--获取个人信息
function GlobalController:processGetUserInfo(paras)
    qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{
        uin = paras.uin,
        wait = true,
        txt = GameTxt.login001,
        callback = function(model) 
            if paras.cb then
                xpcall(paras.cb({model = model}),function()end) 
            end 
        end
    })
end

-- 生成二维码
function GlobalController:generatQRCode(paras)
    if not paras.codeStr or not paras.fileName then
        loga("--------生成二维码失败，没有设置参数！")
        return;
    end
    local callBackFunc = function (isSuccess)
        if paras.cb then
            paras.cb(isSuccess)
        end
    end

    local QRCodePic = cc.FileUtils:getInstance():getWritablePath() .. paras.fileName
    if io.exists(QRCodePic) then
        return;
    end

    -- 生成二维码
    qf.platform:createQRCode({
        cb = callBackFunc,
        qrCodeStr = paras.codeStr,
        qyCodeFileName = paras.fileName,
        size = paras.size
    })
end

--显示个人信息
function GlobalController:processShowUserInfo(parameters)
    if parameters.uin == Cache.user.uin then    
        qf.event:dispatchEvent(ET.SHOW_MYSELF_INFO_VIEW, {name="change_userinfo0",isedit=parameters.isedit,isInGame=parameters.isInGame,localinfo=parameters.localinfo,cb=parameters.cb})
    else
        local userInfo = PopupManager:push({class = UserInfo, init_data = parameters})
        PopupManager:pop()
        if userInfo ~= nil then
            qf.event:dispatchEvent(ET.GLOBAL_GET_USER_INFO, {uin = parameters.uin, cb = function(paras) 
                if paras == nil or paras.model == nil then return end
                local userInfoView = PopupManager:getPopupWindowByUid(userInfo)
                if isValid(userInfoView) then
                    userInfoView:initView(paras)
                end
            end})
        end
    end
end

function GlobalController:showMainDialog(paras) 
    if self.view then 
        self.view:showMainDialog(paras)
    end
end

--钻石购买成功，发货通知
function GlobalController:recevieDeliveryAdviceNotify(paras)
    if paras ~= nil and paras.model ~= nil then
        local item_id = paras.model.item_id
        local buyGoodsType = 1
        --弹出获取钻石弹框
        local got_diamond = paras.model.recharge_diamond or 0
        local return_diamond = paras.model.return_diamond or 0
        --安卓支付成功返回后会黑屏，似乎是播放声音时的问题，暂时通过延时解决
        loga(got_diamond.."   "..return_diamond)
        loga("==============buy_SUCCESS========22222======="..item_id)
        if item_id == "apl_rmb2gold_12_120000" then
            qf.event:dispatchEvent(ET.TO_BE_PROMOTER_SUCCESS)
        end 
        Util:delayRun(1,function()
                qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {diamond=got_diamond, free=return_diamond,rewardInfo ={got_diamond,0,0},
                    dismissCallBack = function ( ... )
                        if Cache.user.firstChargeConfInfo then 
                            Cache.user.firstChargeConfInfo.payFirstRechargeSuccess = true
                            if Cache.user.firstChargeConfInfo.payGiftInfoBackSuccess ==  true then
                                self:showFirstRechargeSuccess()
                                Cache.user.firstChargeConfInfo.payGiftInfoBackSuccess = false
                                Cache.user.firstChargeConfInfo.payFirstRechargeSuccess = false
                            end
                        end   
                    end})
            end)
        --购买成功后更新默认的支付方式
        if self.pay_record ~= nil and self.pay_record.paymethod ~=nil then
            Cache.QuickPay:setDefaultPayMethod(self.pay_record.paymethod)
        end
        --首充支付后去掉首充的弹窗
        if self.poplist and #self.poplist > 0 then
            for k,v in pairs(self.poplist) do
                if v.id == ET.SHOW_FIRSTRECHARGE_POP then
                    table.remove(self.poplist,k)
                end
            end
            qf.event:dispatchEvent(ET.HIDE_ACTIVE_NOTICE)

        end
    end
end

--钻石购买成功，更新破产补助
function GlobalController:updateBankruptcyPopup()
    qf.event:dispatchEvent(ET.GLOBAL_HANDLE_BANKRUPTCY, {method="update", type=Cache.QuickPay.JUDGE_ENOUGH.DIAMOND_ENOUGH})
end

--钻石更改通知
function GlobalController:userDiamondChangedNotify(paras)
    if paras ~= nil and paras.model ~= nil and paras.model.remain_amount ~= nil then
        --更新用户钻石数量
        local remain_diamond = paras.model.remain_amount
        Cache.user:updateUserDiamond(remain_diamond)
    end
end

--金币更改通知
function GlobalController:userGoldChangedNotify(paras)
    local gold = Cache.user.gold
    local old_gold = clone(gold)
    if paras.model == nil and paras.gold ~= nil then
        gold = paras.gold
    -- elseif paras.model ~= nil and paras.model.gold ~= nil then
    --     gold = paras.model.gold
    elseif paras.model ~= nil and paras.model.remain_amount ~= nil then
        gold = paras.model.remain_amount
    end
    if paras.model.uin == Cache.user.uin then
        Cache.user:updateUserGold(gold)
    end
    qf.event:dispatchEvent(ET.GOLD_CHANGE_RSP)
    qf.event:dispatchEvent(ET.GOLD_CHANGE_RSP_Game , {rsp = paras.model})
    --破产时用户在领取补助或在其他地方获得金币时，跳动金币变成跳动筹码
    if ModuleManager:judgeIsInNormalGame() and old_gold < 200 then
        if not Util:judgeIsBankruptcy() then
            qf.event:dispatchEvent(ET.GAME_SHOW_BOUNCE_BTN,{type="shopPromit"})
        end
    end
end

--使用钻石兑换金币/道具
function GlobalController:exchangeProductByDiamond(paras)
    if paras == nil or paras.item_name == nil then return end
    local ref = paras.ref or UserActionPos.SHOP_REF --购买场景默认为商城
    GameNet:send({cmd = CMD.PRODUCT_EXCHANGE_BY_DIAMOND,
        body = { item_id=paras.item_name, refer=ref } ,
        callback = function(rsp)
            --根据item_id获取商品名称
            local product_name = Cache.PayManager:getDisplayNameByItemId(paras.item_name)
            --成功/失败提示
            local msg = ""
            if rsp.ret == 0 then
                if paras.cb then paras.cb(true) end 

                --使用金币购买不提示金币动画
                if paras.currency  and paras.currency == PAY_CONST.CURRENCY_GOLD then
                    msg = string.format(GameTxt.exchange_product_success_tip, paras.title)
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = msg})
                    return
                end
                --记牌器的购买不提示金币动画
                if paras.item_name ~= "cards_remember" and paras.item_name ~= "cards_remember_daily" and paras.scene ~= "ingame" and paras.item_name ~= "app_star_protect_card" and paras.item_name ~= "super_multi_card" then
                    msg = string.format(GameTxt.exchange_product_success_tip, product_name)
                    qf.event:dispatchEvent(ET.GLOBAL_COIN_ANIMATION_SHOW,{number = 1000})
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = msg})
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt =DDZ_TXT.buy_success})
                end 
            else
                msg = Cache.Config._errorMsg[rsp.ret] or string.format(GameTxt.exchange_product_failed_tip, product_name)
                if paras.cb then paras.cb(false) end
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = msg})
            end
        end
    })
end

-- 购买物品提示框
function GlobalController:handlerShowBuyPopupTipView( args )
    local buyTipView = BuyPopupTipView.new(args)
    buyTipView:show()
end

-- 打开支付方式框
function GlobalController:handlerShowPayMethodView( args )
    PopupManager:push({class = PayMethodView, init_data = args})
    PopupManager:pop()
end

--[[
    用户行为上报
    qf.event:dispatchEvent(ET.USER_ACTION_STATS_EVT, {
        ref=UserActionPos.ROOM_SIT_LACK, 
        currency=PAY_CONST.CURRENCY_GOLD})
]]
function GlobalController:userActionStatsProcess(paras)
    if paras == nil or paras.ref == nil then return end
    xpcall(
        function()
            local refer_id = paras.ref
            local currency_type = paras.currency or PAY_CONST.CURRENCY_GOLD
            GameNet:send({cmd = CMD.PUSH_USER_ACTION_STATS, body = {refer = refer_id, type = currency_type}})
        end,
        function() 
            logd("数据上报出错")
        end
    )
end

--大转盘显示
function GlobalController:showTurnTable(paras)
    -- body
    GameNet:send({ cmd = CMD.GET_DAY_LOGIN_REWARD_CFG,callback= function(rsp)
        if rsp.ret ~= 0 then
            --不成功提示
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        else   -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
           --[[ optional int32 reward_start_time = 4;            // 抽奖开始时间
                optional int32 reward_end_time = 5;              // 抽奖结束时间
                optional int32 is_right_time = 6;                // 当前可抽奖，0 为抽奖时间段 1为不在抽奖时间段--]]
            local model={}
            model.reward_start_time=rsp.model.reward_start_time
            model.reward_end_time=rsp.model.reward_end_time
            model.is_right_time=rsp.model.is_right_time
            model.left_time=rsp.model.left_time
            if paras and paras.cb then model.cb=paras.cb end
            self.view:showTurnTable(model)
        end
    end})
end

--大转盘删除
function GlobalController:removeTurnTable(paras)
    -- body
    self.view:removeTurnTable(paras)
end

--启动资金显示
function GlobalController:showFirstGame(paras)
    -- body
    self.view:showFirstGame(paras)
end

--启动资金删除
function GlobalController:removeFirstGame(paras)
    -- body
    self.view:removeFirstGame(paras)
end

--消息引导显示
function GlobalController:showNewsLead(paras)
    -- body
    self.view:showNewsLead(paras)
end

--消息引导删除
function GlobalController:removeNewsLead(paras)
    -- body
    self.view:removeNewsLead(paras)
end


----------------------------------------------
function GlobalController:NO_GOLD(paras)
    -- body
    local roomid=paras.roomid
    local desk_cache
    local Config 

    desk_cache  = Cache.DDZconfig
    Config      = Cache.DDZconfig.DDZ_room

    local cb = function ()
        if Cache.user.gold < desk_cache.limitest  then return end
        if not Cache.DDZDesk.roomid then
            Cache.DDZDesk.roomid = 30401
        end
        qf.event:dispatchEvent(ET.DDZ_NET_INPUT_REQ,{roomid = 30401,deskid=0,enter_source=101})
    end

    local pick_times = Cache.Config:getBankruptcyFetchCount() or 0

    if pick_times >= Cache.Config.bankrupt_count or Cache.user.gold >= Cache.Config.bankrupt_money then
        qf.event:dispatchEvent(ET.GLOBAL_SHOW_NEWBILLING,{limit_low=Config[roomid].enter_limit_low,cb=cb,limit=Config[roomid].payment_recommend,ref=UserActionPos.PRIVATE_ROOM_SIT_LACK})
    else
         qf.event:dispatchEvent(ET.GLOBAL_HANDLE_BANKRUPTCY,{method = "show",min=Config[roomid].payment_recommend,cb=cb})
    end
end

function GlobalController:showRedPackageView( paras )
    if self.view == nil then return end
    if paras and paras.isOpen then
        self.view:showRedPackageOpenView(paras)
    else
        self.view:showRedPackageView()
    end
end

function GlobalController:getInGameBuyList(paras)
    if paras.ret == 0 then
        Cache.Config:saveIngameBuyList(paras.model)
    end
end

function GlobalController:showMyHeadBox(  )
    if self.view == nil then return end
    self.view:showMyHeadBox()
end
function GlobalController:showMatchReport()
    if self.view == nil then return end

    self.view:showMatchReport()
end

function GlobalController:showMatchHonor()
    if self.view == nil then return end

    self.view:showMatchHonor()
end

function GlobalController:showMatchHallView(paras)
    if self.view == nil then return end

    self.view:showMatchHallView(paras)
end


return GlobalController