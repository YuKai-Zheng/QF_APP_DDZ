--
-- Author: Your Name
-- Date: 2018-08-15 15:12:01
--
local RememberCard = class("RememberCard",function (paras)
	return paras.node
 end)
local cardManage = import(".CardManage")

function RememberCard:ctor( paras )
	self._parent_view = paras.view
    self.winSize = cc.Director:getInstance():getWinSize()
	self:init(paras)
	self:initClick()
end

--初始化RememberCard
function RememberCard:init(paras)
	self.card_record_tip = ccui.Helper:seekWidgetByName(self,"card_record_tip")   --记牌器的提示
    self.recordBg = ccui.Helper:seekWidgetByName(self,"recordBg")              --记牌器
    self.byRcord_bg = ccui.Helper:seekWidgetByName(self,"byRcord_bg")             --记牌器详情
    self.buy_coin = ccui.Helper:seekWidgetByName(self.byRcord_bg,"buy_coin")             --金币购买记牌器
    self.buy_foca = ccui.Helper:seekWidgetByName(self.byRcord_bg,"buy_foca")             --奖券购买记牌器
    self.time_remain = ccui.Helper:seekWidgetByName(self,"time_remain")            --奖券记牌器的剩余时间
    self.red_1 = self.buy_coin:getChildByName("red_point")            --记牌器（1局）数量 
    self.red_2 = self.buy_foca:getChildByName("red_point")            --记牌器（1天）数量 

    self:updateRedNum()
end

function RememberCard:updateRedNum ()
    local daojvInfo = Cache.daojuInfo.cardRemember or {}

    for i,val in pairs(daojvInfo) do
        if val.name == "cards_remember" then
            if val.amount and val.amount > 0 then
                self.red_1:setVisible(true)
                self.red_1:getChildByName("txt_num"):setString(val.amount)
            else
                self.red_1:setVisible(false)
            end
        else
            if val.amount and val.amount > 0 then
                self.red_2:setVisible(true)
                self.red_2:getChildByName("txt_num"):setString(val.amount)
            else
                self.red_2:setVisible(false)
            end
        end
    end
end

--初始化点击事件
function RememberCard:initClick( ... )
	addButtonEvent(self.card_record_tip,function()
        self:controllCardRecordTipAction()
    end)

    addButtonEvent(self.buy_coin,function()
        if Cache.user.gold < self.buy_coin.price then 
            qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color=cc.c3b(0,0,0),fontsize=34,cb_consure=function( ... )
                qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})--点击上报
                qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
            end})
        else
            self:buyRememberCard(self.buy_coin.buyId)
        end
    end)

    addButtonEvent(self.buy_foca,function()
        if Cache.user.fucard_num < self.buy_foca.price then 
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "您的奖券不足"})
        else
            self:buyRememberCard(self.buy_foca.buyId)
        end
    end)
end


--展示记牌器
function RememberCard:showCardRemember()
	local rememberCards = DDZ_cardManage:geRememberCardsByNum(Cache.DDZDesk._player_info[Cache.user.uin].total_remain_cards) or {}
    loga("记牌器能不能用use_card_remember==" .. Cache.DDZDesk._player_info[Cache.user.uin].use_card_remember)
    if Cache.DDZDesk._player_info[Cache.user.uin].use_card_remember == 1 and (Cache.DDZDesk.status == GameStatus.INGAME  or Cache.DDZDesk.status == GameStatus.CALL_DOUBLE) and #rememberCards > 0 and #rememberCards < 54 then
        self.recordBg:setVisible(true)
        self._parent_view:setGameInfoVisible(false)
        self.byRcord_bg:setVisible(false)
        -- 显示记牌器上的信息
        self:updateCardRememberList()
        self:clearTimer()
    else
        self.recordBg:setVisible(false)
        self._parent_view:setGameInfoVisible(true)
    end
end

--当局结束，初始话数据
function RememberCard:currentGameOver()
    --当局结束，隐藏记牌器
    self.recordBg:setVisible(false)
    self._parent_view:setGameInfoVisible(true)

    --每局结束后，重置记牌器是否使用和记牌器里的牌的信息
    Cache.DDZDesk._player_info[Cache.user.uin].total_remain_cards = {}
    Cache.DDZDesk._player_info[Cache.user.uin].use_card_remember = 0
    Cache.DDZDesk.status = GameStatus.READY
end

--展示记牌器上的各牌的剩余数量
function RememberCard:updateCardRememberList()
    local rememberCards = DDZ_cardManage:geRememberCardsByNum(Cache.DDZDesk._player_info[Cache.user.uin].total_remain_cards) or {}
    for k,v in pairs(rememberCards) do
        if k > 2 and k < 18 then
            local cardNumRecord = "cardNumRecord"..string.format("%d", k)
            local num = #v
            local cardRemainLbl = ccui.Helper:seekWidgetByName(self.recordBg,cardNumRecord)
            cardRemainLbl:setString(string.format("%d", num))

            if num > 0 then
                cardRemainLbl:setColor(cc.c3b(199,68,3))
            else
                cardRemainLbl:setColor(cc.c3b(101,36,21))    
            end
        end
    end
end

--记牌器提示按钮的点击
function RememberCard:controllCardRecordTipAction()
    if not Cache.DDZDesk._player_info[Cache.user.uin] then return end
    if Cache.DDZDesk._player_info[Cache.user.uin].use_card_remember == 1 then 
        if Cache.DDZDesk.status == GameStatus.INGAME or Cache.DDZDesk.status == GameStatus.CALL_DOUBLE then
            local visible  = self.recordBg:isVisible() ~= true 
            self.recordBg:setVisible(visible)
            self._parent_view:setGameInfoVisible(visible ~= true)            
            self.byRcord_bg:setVisible(false)
            self:updateCardRememberList()
        else
            local visible  = self.byRcord_bg:isVisible() ~= true 
            self.recordBg:setVisible(false)
            self._parent_view:setGameInfoVisible(true)
            self.byRcord_bg:setVisible(visible) 
        end
    else
        local visible  = self.byRcord_bg:isVisible() ~= true 
        self.recordBg:setVisible(false)
        self._parent_view:setGameInfoVisible(true)
        self.byRcord_bg:setVisible(visible) 
    end

    local visible  = self.byRcord_bg:isVisible() == true
    if visible then 
        self:updateCardRememberPoductInfo()
        self:getDaojuList()
    else
    	self:clearTimer()
    end
end

--更新道具列表信息
function RememberCard:getDaojuList(params)
	local index_process = 0
    GameNet:send({ cmd = CMD.CMD_GET_DAOJU_LIST ,wait=true,txt=GameTxt.net002,
        callback= function(rsp)
            if rsp.ret ~= 0 then
                --不成功提示
                logd("不成功提示")
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            else   
                logd("成功提示")
                if rsp.model ~= nil then 
                    Cache.daojuInfo:saveConfig(rsp.model)
                end
            end 
            index_process = index_process + 1
            if index_process == 2 then
               self:updateCardRememberPoductInfo()
            end
    end})
    
    --查询记牌器金币数
    GameNet:send({cmd = CMD.QUERYCARDSREMEMBERINFO,callback=function(rsp)
        if rsp.ret == 0 then
            if rsp.model then
                Cache.PayManager.product_info:_updateFocaInfo(rsp.model)
                Cache.DDZDesk:getCardRememberData()
            end
        end
        index_process = index_process + 1
        if index_process == 2 then
            self:updateCardRememberPoductInfo()
        end
    end})
end





--更新记牌器购买的信息及剩余数量
function RememberCard:updateCardRememberPoductInfo()
    local cardRememberData = Cache.DDZDesk.cardRememberData or {}
    for k,v in pairs(cardRememberData) do
       if v.item_name == "cards_remember" then 
            ccui.Helper:seekWidgetByName(self.buy_coin,"coinCost"):setString(string.format("%d", v.price))
            self.buy_coin.buyId = v.item_name
            self.buy_coin.price = v.price
            self.buy_coin.title = v.title
        end

        if v.item_name == "cards_remember_daily" then 
            ccui.Helper:seekWidgetByName(self.buy_foca,"coinCost"):setString(string.format("%d", v.price))
            self.buy_foca.buyId = v.item_name
            self.buy_foca.price = v.price
            self.buy_foca.title = v.title
        end
    end

    local cardRemember = Cache.daojuInfo.cardRemember or {}

    for i,v in pairs(cardRemember) do
        if v.name == "cards_remember" then 
            ccui.Helper:seekWidgetByName(self.buy_coin,"title"):setString(self.buy_coin.title)
        end

        if v.name == "cards_remember_daily" then 
            ccui.Helper:seekWidgetByName(self.buy_foca,"title"):setString(self.buy_foca.title)
            -- 倒计时
            self.buy_foca.expire_time =Cache.daojuInfo.card_remember_daily_left_times
            self:dailyRememberCardLeftTime()
        end  
    end
end
--购买记牌器
function RememberCard:buyRememberCard(buy_id)
    if buy_id then
        qf.event:dispatchEvent(ET.NET_PRODUCT_EXCHANGE_BY_DIAMOND, {item_name = buy_id, ref = UserActionPos.SHORTCUT_REF , cb = function(paras)
                if paras then
                    self.byRcord_bg:setVisible(false) 
                    --不在抢地主
                    if Cache.DDZDesk.status ~= GameStatus.CALL_POINT then 
                        if buy_id == "cards_remember" then
                           qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = self.buy_coin.title..DDZ_TXT.buy_success.."，"..DDZ_TXT.user_next})
                        else
                           qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = self.buy_foca.title..DDZ_TXT.buy_success.."，"..DDZ_TXT.user_next})
                        end
                    else
                        if buy_id == "cards_remember" then
                           qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = self.buy_coin.title..DDZ_TXT.buy_success.."！"})
                        else
                           qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = self.buy_foca.title..DDZ_TXT.buy_success.."！"})
                        end
                    end
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = DDZ_TXT.buy_fail})
                end
        end})
    end
end

--记牌器的倒计时时间
function RememberCard:dailyRememberCardLeftTime()
    if self.rememberCardtime then
        Scheduler:unschedule(self.rememberCardtime)
        self.rememberCardtime=nil
    end
    if self.buy_foca.expire_time == nil or self.buy_foca.expire_time <= 0 then
        self.time_remain:setVisible(false)
        self.time_remain:getChildByName("time_remain_title"):setString("")
        return   
    end

    self.rememberCardtime=Scheduler:scheduler(1,function ()
    	self.buy_foca.expire_time = self.buy_foca.expire_time - 1
        local left_time = self.buy_foca.expire_time
        self.time_remain:setVisible(true)
        if left_time < 0 then
            Scheduler:unschedule(self.rememberCardtime)
            self.rememberCardtime=nil
            self.time_remain:getChildByName("time_remain_title"):setString("00时00分")
        else
            self:dailyRememberCardLeftTimeByTime(left_time)    
        end
    end)
end
--天数记牌器上的剩余时间的显示
function RememberCard:dailyRememberCardLeftTimeByTime(leftTime)
    if leftTime >= 3600 *24 then
        local day = math.floor(leftTime / (3600 *24))
        self.time_remain:getChildByName("time_remain_title"):setString(string.format("%d天", day))
    else
        local hour = math.floor(leftTime / 3600)
        local min = math.floor(leftTime / 60) % 60
        self.time_remain:getChildByName("time_remain_title"):setString(string.format("%02d时%02d分", hour,min))
    end
end

--清除定时器
function RememberCard:clearTimer()
    if self.rememberCardtime then
        Scheduler:unschedule(self.rememberCardtime)
        self.rememberCardtime=nil
    end
end

--当记牌器处于没有购买和没有使用的状态下，点击游戏界面的空白处，隐藏兑换记牌器的界面
function RememberCard:clickBank()
    local visible  = self.byRcord_bg:isVisible() == true
    if visible then 
        self.recordBg:setVisible(false)
        self._parent_view:setGameInfoVisible(true)
        self.byRcord_bg:setVisible(false)
    end
end

return RememberCard