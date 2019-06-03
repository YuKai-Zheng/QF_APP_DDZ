

local FreeGoldShortCut = class("FreeGoldShortCut", CommonWidget.BasicWindow)
local InviteView = import("src.modules.share.components.Invite")
FreeGoldShortCut.TAG = "FreeGoldShortCut"


function FreeGoldShortCut:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    FreeGoldShortCut.super.ctor(self, paras)
    self:initInfo()
    --if paras and paras.cb then self.cb=paras.cb end
end

function FreeGoldShortCut:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.FreeGoldShortCutJson)

    self.closeBtn=ccui.Helper:seekWidgetByName(self.gui,"closebtn")
    self.listView=ccui.Helper:seekWidgetByName(self.gui,"list")

    --每日充值
    self.rechargeP=ccui.Helper:seekWidgetByName(self.gui,"rechargeP")
    self.rechargeP:retain()
    self.rechargeP:removeFromParent()
    --破产补助
    self.bankruptcyP=ccui.Helper:seekWidgetByName(self.gui,"bankruptcyP")
    self.bankruptcyP:retain()
    self.bankruptcyP:removeFromParent()
    --微信分享
    self.weixinShareP=ccui.Helper:seekWidgetByName(self.gui,"weixinP")
    self.weixinShareP:retain()
    self.weixinShareP:removeFromParent()
    --每日签到
    self.dailyP=ccui.Helper:seekWidgetByName(self.gui,"dailyP")
    self.dailyP:retain()
    self.dailyP:removeFromParent()
    --欢乐转盘
    self.turntableP=ccui.Helper:seekWidgetByName(self.gui,"turntableP")
    self.turntableP:retain()
    self.turntableP:removeFromParent()
    --实名认证
    self.realNameP=ccui.Helper:seekWidgetByName(self.gui,"realNameP")
    self.realNameP:retain()
    self.realNameP:removeFromParent()


    -- self.listView:pushBackCustomItem(self.rechargeP)
    -- self.listView:pushBackCustomItem(self.bankruptcyP)
    self.listView:pushBackCustomItem(self.dailyP)
    -- self.listView:pushBackCustomItem(self.realNameP)
    if Cache.user.show_lucky_wheel_or_not == 0 and TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then--大转盘
        self.listView:pushBackCustomItem(self.turntableP)
    end
    if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.listView:pushBackCustomItem(self.weixinShareP)
    end
end

function FreeGoldShortCut:initData( args )
    paras = args.data
    --每日充值
    self.free_gold_task_list={}
    self.free_gold_task_list.status=paras.free_gold_task_list:get(1).status
    self.free_gold_task_list.gold=paras.free_gold_task_list:get(1).gold
    self:initRechargeP()

    --微信分享
    self.weixn_task={}
    self.weixn_task.status=paras.free_gold_task_list:get(1).status
    self.weixn_task.gold=paras.free_gold_task_list:get(1).gold
    self.weixn_task.title=paras.free_gold_task_list:get(1).title
    self.weixn_task.desc=paras.free_gold_task_list:get(1).desc
    self.weixn_task.task_type=paras.free_gold_task_list:get(1).task_type
    self.weixn_task.id=paras.free_gold_task_list:get(1).id
    
    self:initWeixinShareP()

    --破产补助
    self.is_all_send=paras.is_all_send
    self.remain=paras.remain
    self.fetch_count=paras.fetch_count
    self.send_gold=paras.send_gold
    -- self:initBankruptcyP()

    --每日登陆
    self.got_day_reward=paras.got_day_reward
    self:initDailyP()

    --大转盘
    if Cache.user.show_lucky_wheel_or_not == 0 then--大转盘
        self.is_right_time=paras.is_right_time
        self:initTurntableP()
    end

    -- 实名认证状态
    self:updateRealNameInfo()

    -- self:updateRemainTime()
end

function FreeGoldShortCut:updateRealNameInfo()
    for i,v in ipairs(Cache.ActivityTaskInfo.rewardList.sys_task_list) do
        if v.id == "60" then
            print(v.status,v.status_id,v.id)
            self:showRealNameState(v)
            if v.status ~= 2 then--实名认证
                if not tolua.isnull(self.listView) then
                    local index = self.listView:getIndex(self.realNameP)
                    self.listView:removeItem(index)
                    self.listView:pushBackCustomItem(self.realNameP)
                end
            else
                if not tolua.isnull(self.listView) then
                    local index = self.listView:getIndex(self.realNameP)
                    self.listView:removeItem(index)
                end
            end
        end 
    end
end

function FreeGoldShortCut:showRealNameState(task)
    -- body
    -- self.realNameP=ccui.Helper:seekWidgetByName(self.gui,"realNameP")

    local canget = ccui.Helper:seekWidgetByName(self.realNameP,"canget")
    local get = ccui.Helper:seekWidgetByName(self.realNameP,"get")
    local review = ccui.Helper:seekWidgetByName(self.realNameP,"review")
    local state = task.status
    local state_id = task.status_id
    if state == 0 and state_id == 0 then
        canget:setVisible(true)
        get:setVisible(false)
        review:setVisible(false)
        self:setRealNameBtnState(true)
    elseif state == 0 and state_id == 1  then
        print("审核中")
        canget:setVisible(false)
        get:setVisible(false)
        review:setVisible(true)
        self:setRealNameBtnState(false)
    elseif state == 1 then
        canget:setVisible(false)
        get:setVisible(true)
        review:setVisible(false)
        self:setRealNameBtnState(true)
    end
    self:RealNameButtonAction(task)
end
function FreeGoldShortCut:setRealNameBtnState(state)
    -- body
    local realNameBtn = ccui.Helper:seekWidgetByName(self.realNameP,"btn")
    realNameBtn:setEnabled(state)
    realNameBtn:setBright(state)
    realNameBtn:setTouchEnabled(state)
end

function FreeGoldShortCut:initRechargeP( paras )--每日充值
    --[[
    optional int32 status=1; // task status
    optional string desc=2; // description
    optional string id =3; // task id
    optional int64 gold =4; // gold
    optional string title =5; // title
    optional int32 condition=6; // condition
    optional string image_url=7; // image url
    optional int32 progress =8; // progress
    optional string task_type = 9; //task type
    ]]
    loga(self.free_gold_task_list.status)
    local btn=ccui.Helper:seekWidgetByName(self.rechargeP,"btn")
    local btnget=ccui.Helper:seekWidgetByName(self.rechargeP,"btnget")
    local info=ccui.Helper:seekWidgetByName(self.rechargeP,"info")
    info:setString("每天第一笔充值可领取"..self.free_gold_task_list.gold.."金币")
    if self.free_gold_task_list.status~=0 then
        btn:setVisible(false)
        btnget:setVisible(true)
        if self.free_gold_task_list.status~=2 then
            ccui.Helper:seekWidgetByName(btnget,"get"):setVisible(false)
            ccui.Helper:seekWidgetByName(btnget,"canget"):setVisible(true)
            btnget:setBright(true)
        else
            ccui.Helper:seekWidgetByName(btnget,"get"):setVisible(true)
            ccui.Helper:seekWidgetByName(btnget,"canget"):setVisible(false)
            btnget:setBright(false)
            btnget:setTouchEnabled(false)
        end
    else
        btn:setVisible(true)
        btnget:setVisible(false)
    end 
end

function FreeGoldShortCut:initWeixinShareP(paras) --微信分享
    loga("微信分享".. self.weixn_task.status)
    local btn=ccui.Helper:seekWidgetByName(self.weixinShareP,"btn")
    local title=ccui.Helper:seekWidgetByName(self.weixinShareP,"title")
    local info=ccui.Helper:seekWidgetByName(self.weixinShareP,"info")
    title:setString(self.weixn_task.title)
    info:setString(self.weixn_task.desc)
    if self.weixn_task.status == 0 then  --未完成
        ccui.Helper:seekWidgetByName(btn,"get"):setVisible(false)
        ccui.Helper:seekWidgetByName(btn,"canget"):setVisible(true)
        ccui.Helper:seekWidgetByName(btn,"review"):setVisible(false)
        btn:setBright(true)
    elseif self.weixn_task.status == 1 then -- 已完成
        ccui.Helper:seekWidgetByName(btn,"get"):setVisible(true)
        ccui.Helper:seekWidgetByName(btn,"canget"):setVisible(false)
        ccui.Helper:seekWidgetByName(btn,"review"):setVisible(false)
        btn:setBright(true)
    elseif self.weixn_task.status == 2 then --已领取奖励
        ccui.Helper:seekWidgetByName(btn,"get"):setVisible(false)
        ccui.Helper:seekWidgetByName(btn,"canget"):setVisible(false)
        ccui.Helper:seekWidgetByName(btn,"review"):setVisible(true)
        btn:setBright(false)
    end
end

function FreeGoldShortCut:initBankruptcyP( paras )--破产补助
    --[[
    optional int32 fetch_count=11;                   // 已经领取破产补助的次数
    optional int64 last_fetch_time=12;               // 上次领取破产补助的时间
    optional int64 next_fetch_time=13;               // 下次次领取破产补助的时间
    optional int32 remain=14;                       // 下一次破产补助还有多少秒
    optional int32 fetch_limit =15;                 // 总共送多少次
    optional int32 is_all_send=16;                  // 是否已经送光破产补助
    optional int64 send_gold=17;                    // 每次破产补助送多少钱
    ]]
    local btn=ccui.Helper:seekWidgetByName(self.bankruptcyP,"btn")
    local get=ccui.Helper:seekWidgetByName(self.bankruptcyP,"get")
    local canget=ccui.Helper:seekWidgetByName(self.bankruptcyP,"canget")
    local info=ccui.Helper:seekWidgetByName(self.bankruptcyP,"info")
    local title=ccui.Helper:seekWidgetByName(self.bankruptcyP,"title")
    if self.is_all_send ~= 1 and self.remain < 1 and Cache.user.gold < Cache.Config.bankrupt_money then
        get:setVisible(false)
        canget:setVisible(true)
        btn:setBright(true)
        canget:setString("（"..self.fetch_count.."/"..Cache.Config.bankrupt_count.."）")
    else
        self:updateRemainTime()
        get:setVisible(true)
        canget:setVisible(false)
        btn:setBright(false)
        get:setString("（"..self.fetch_count.."/"..Cache.Config.bankrupt_count.."）")
    end 
    title:setString("破产补助（每日"..Cache.Config.bankrupt_count.."次）")
    info:setString("金币不足"..Cache.Config.bankrupt_money.."时，可领取"..self.send_gold.."金币")
end

function FreeGoldShortCut:initDailyP()--每日登陆
    --[[
    optional int32 login_days = 1;
    optional int32 got_day_reward = 2;
    optional int32 got_beauty_day_reward = 3;
    ]]
    local btn=ccui.Helper:seekWidgetByName(self.dailyP,"btn")
    if self.got_day_reward == 0 then
        ccui.Helper:seekWidgetByName(btn,"get"):setVisible(false)
        ccui.Helper:seekWidgetByName(btn,"canget"):setVisible(true)
        btn:setBright(true)
    else
        ccui.Helper:seekWidgetByName(btn,"get"):setVisible(true)
        ccui.Helper:seekWidgetByName(btn,"canget"):setVisible(false)
        btn:setBright(false)
    end 
    local info=ccui.Helper:seekWidgetByName(self.dailyP,"info")
    info:setString(GameTxt.Daily_login_info)
    
end

function FreeGoldShortCut:initTurntableP()--大转盘
    --[[
    optional string reward_start_time = 4;          // 抽奖开始时间 字符串格式为 xx:xx
    optional string reward_end_time = 5;            // 抽奖结束时间  字符串格式为 xx:xx
    optional int32 is_right_time = 6;                // 当前可抽奖，0 为抽奖时间段 1为不在抽奖时间段 2 为明天再来 3为本时间段次数已完
    optional int32 left_time = 7;                    // 抽奖时间段内返回当前可抽奖的剩余时间，若不在抽奖时间段返回下阶段剩余秒数
    ]]
    local btn=ccui.Helper:seekWidgetByName(self.turntableP,"btn")
    -- if self.is_right_time == 0 and Cache.user.lucky_wheel_play_times > 0 then
    if Cache.user.lucky_wheel_play_times > 0 then
        ccui.Helper:seekWidgetByName(btn,"get"):setVisible(false)
        ccui.Helper:seekWidgetByName(btn,"canget"):setVisible(true)
        btn:setBright(true)
    else
        ccui.Helper:seekWidgetByName(btn,"get"):setVisible(true)
        ccui.Helper:seekWidgetByName(btn,"canget"):setVisible(false)
        btn:setBright(false)
    end
    ccui.Helper:seekWidgetByName(self.turntableP,"info"):setString(GameTxt.turn_table_count_txt)
end


--实名认证
function FreeGoldShortCut:initRealNameP()
    -- body
    local btn = ccui.Helper:seekWidgetByName(self.realNameP,"btn")
    -- ccui.Helper:seekWidgetByName(btn,"get"):setVisible(true)
    btn:setBright(true)
end

function FreeGoldShortCut:initInfo()
    GameNet:send({cmd = CMD.ALLACTIVITYTASK,
        callback = function(rsp)
            if rsp.ret == 0 then
                Cache.ActivityTaskInfo:updateInfo(rsp.model)
            end 
            GameNet:send({ cmd = CMD.GET_DAY_LOGIN_REWARD_CFG,
                callback= function(rsp)
                    if rsp.ret ~= 0 then
                    else
                        if not tolua.isnull(self) then
                            self:initData({data = rsp.model})
                            -- self:updateRemainTime()
                        end
                    end
            end}) 
    end})
end

function FreeGoldShortCut:initClick( ... )
    local show=function( ... )
        -- body
        self:initInfo()
        self:show()
    end
    addButtonEvent(self.closeBtn,function( ... )
        -- body
        self:close()
    end)
    addButtonEvent(ccui.Helper:seekWidgetByName(self.rechargeP,"btn"),function( ... )
        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK,{name="shop",cb=show, bookmark=PAY_CONST.BOOKMARK_ROOM.DIAMOND})
    end)

    addButtonEvent(ccui.Helper:seekWidgetByName(self.rechargeP,"btnget"),function( ... )
        -- body
        GameNet:send({cmd = CMD.TASKREWARD,txt=GameTxt.net002,body = {task_type = "free",task_id = 1,refer=UserActionPos.SHORTCUT_REF},callback = function(rsp)
            if rsp.ret == 0 then
                MusicPlayer:playMyEffect("TASK_FINISH")
                qf.event:dispatchEvent(ET.GLOBAL_COIN_ANIMATION_SHOW,{number=100000000})
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.task003,self.free_gold_task_list.gold),time = 2})
                self:initInfo()
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
            end
        end})
    end)

    addButtonEvent(ccui.Helper:seekWidgetByName(self.bankruptcyP,"btn"),function( ... )
        -- body
        if self.is_all_send == 1 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=string.format(GameTxt.global_string114,Cache.Config.bankrupt_count)})
        elseif self.remain and self.remain > 1 then
            local minute = math.floor(self.remain/60)
            local seconds = self.remain-minute*60
            local time_str = minute <= 0 and seconds or minute..GameTxt.global_string116..seconds
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=GameTxt.global_string115..time_str..GameTxt.global_string117})
        elseif Cache.user.gold >= Cache.Config.bankrupt_money then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=GameTxt.global_string107})
        else
            qf.event:dispatchEvent(ET.NET_GET_COLLAPSE_PAY_REQ)
            GameNet:send({cmd=CMD.COLLAPSE_PAY,txt=GameTxt.net002,
            callback=function(rsp)
                if rsp.ret == 0 and rsp.model ~= nil then
                    Cache.Config:setBankruptcyFetchCount(rsp.model.fetch_count)-- 保存领取破产补助次数   
                    self.is_all_send=rsp.model.is_all_send
                    self.remain=rsp.model.remain
                    self.fetch_count=rsp.model.fetch_count
                    self.send_gold=rsp.model.send_gold
                    self:initBankruptcyP() 
                    if rsp.model.is_all_send  ~= 1 then
                        self.remain = rsp.model.remain 
                        self:updateRemainTime()
                    else
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt=string.format(GameTxt.global_string114,Cache.Config.bankrupt_count)})
                    end
                end
            end})
        end
    end)

    addButtonEvent(ccui.Helper:seekWidgetByName(self.dailyP,"btn"),function( ... )
        -- body
        self:hide()
        GameNet:send({ cmd = CMD.GET_NEW_DAY_LOGIN_REWARD_CFG,
            callback= function(rsp)
                if rsp.ret ~= 0 then
                else  
                    if not PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.dailylogin) then 
                        qf.event:dispatchEvent(ET.DAILYREWAED,{method="show",cb=show})
                    end
                    qf.event:dispatchEvent(ET.DAILYREWAED, {method = "init", model = rsp.model})
                end
            end})
        qf.platform:umengStatistics({umeng_key="free_land"})--点击上报
    end)

    addButtonEvent(ccui.Helper:seekWidgetByName(self.turntableP,"btn"),function( ... )
        -- body
        self:hide()
        qf.event:dispatchEvent(ET.SHOW_TURNTABLE,{cb=show})
        qf.platform:umengStatistics({umeng_key="free_lottery"})--点击上报
    end)

    addButtonEvent(ccui.Helper:seekWidgetByName(self.weixinShareP,"btn"),function( ... )
        -- body
        -- self:hide()
        local toSharefunc = function (fileName, shareType)
            PopupManager:push({class = InviteView, init_data = {
                type = 1,
                cb = handler(self, self.shareRequest),
                fileName = Cache.user.uin  .. "_exchange.jpg",
                shareType = 4
            }})
            PopupManager:pop()
        end
        -- 去分享
        if self.weixn_task.status == 0 then
            toSharefunc()
        -- 领取奖励
        elseif self.weixn_task.status == 1 then
            GameNet:send({cmd = CMD.TASKREWARD,txt=GameTxt.net002,body = {task_type = self.weixn_task.task_type,task_id = self.weixn_task.id},callback = function (rsp)
                -- body
                if rsp.ret == 0 then
                    local rewardInfo = nil
                    self.weixn_task.status = 2
                    if rsp.model.gold and rsp.model.gold > 0 then
                        rewardInfo = {rsp.model.gold}
                    end
                    if rsp.model.fucard and rsp.model.fucard > 0 then
                        rewardInfo = {0,rsp.model.fucard}
                    end
                    if rsp.model.fucard and rsp.model.fucard > 0 and rsp.model.gold > 0 then
                        rewardInfo = {rsp.model.gold,rsp.model.fucard}
                    end
                    self:initInfo()
                    if rewardInfo then
                        qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {diamond_free = 0,diamond_num = 0,rewardInfo = rewardInfo})
                    end
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                end
            end})
        elseif self.weixn_task.status == 2 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "今日已分享"})
        end
        qf.platform:umengStatistics({umeng_key="freeWeiXinShare"})--点击上报
    end)
end

--分享成功后请求下，通知服务器
function FreeGoldShortCut:shareRequest()
    GameNet:send({cmd = CMD.FREE_WEIXINSHARE_REQ,callback = function (rsp)
        if rsp.ret == 0 then
            if not tolua.isnull(self) then
                --设置状态
                self.weixn_task.status = 1
                --更新下
                self:initWeixinShareP()
            end
        else
            loga("失败")
            -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        end
    end})
end

function FreeGoldShortCut:RealNameButtonAction(task)
    -- body

    loga(task.status_id,task.task_type,task.id,"实名认证")
    ccui.Helper:seekWidgetByName(self.realNameP,"info"):setString("完成实名认证可获得"..task.desc)
    addButtonEvent(ccui.Helper:seekWidgetByName(self.realNameP,"btn"),function ( ... )
        -- body
        self:hide()
        if task.status == 0 and task.status_id == 0 then
            if not PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.realname) then 
                qf.event:dispatchEvent(ET.REALNAME,{method="show",cb = function ()
                    self:initInfo()
                end})
            end
        elseif task.status == 1  then
            GameNet:send({cmd = CMD.TASKREWARD,txt=GameTxt.net002,body = {task_type = task.task_type,task_id = task.id},callback = function (rsp)
                -- body
                if rsp.ret == 0 then
                    loga("成功")
                    for i,v in ipairs(Cache.ActivityTaskInfo.rewardList.sys_task_list) do
                        print(i,v.id)
                        if v.id == "60" then
                            v.status = 2
                        end 
                    end
                    local rewardInfo = nil
                    if rsp.model.gold and rsp.model.gold > 0 then
                        rewardInfo = {rsp.model.gold}
                    end

                    if rsp.model.fucard and rsp.model.fucard > 0 then
                        rewardInfo = {0,rsp.model.fucard}
                    end

                    if rsp.model.fucard and rsp.model.fucard > 0 and rsp.model.gold > 0 then
                        rewardInfo = {rsp.model.gold,rsp.model.fucard}
                    end

                    qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {diamond_free = 0,diamond_num = 0,rewardInfo = rewardInfo})
                    self:initInfo()
                else
                    loga("失败")
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                end
            end})
        end
    end)
end

function FreeGoldShortCut:updateRemainTime()
    local function _refreshTime()
        if self.remain then 
            self.remain = self.remain - 1
            if self.remain <= 0 and self.action then
                self:initBankruptcyP()
            end
        end
    end
    if self.action then return end
    self.action = Scheduler:scheduler(1,_refreshTime)
end

function FreeGoldShortCut:close()
    if self.action then
        Scheduler:unschedule(self.action)
        self.action=nil
    end
    qf.event:dispatchEvent(ET.MAIN_UPDATE_SHORTCUT_NUMBER)
    if self.cb then
        self.cb()
    end

    FreeGoldShortCut.super.close(self)
end

return FreeGoldShortCut
