local Config = class("Config")

function Config:ctor ()
    self:init()
end

function Config:init()
    --[[场次信息 键值是 "id" 值为"name"]]
    self._groupList = {}
    --[[礼物列表 键值是"item_id" item_id从0开始 值为 "gold"]]
    self._giftList = {}
    --[[连续登陆奖励]]
    self._dayReward = {}
    --[[商品信息列表]]
    self._shopInfoList = {}
    --[[新手礼包]]
    self._noviceShopInfoList = {}
    self._mapingItemId = {}
    --[[活动列表]]
    self._activityList = {}
    --新每日登录奖励
    self._loginReward = {}
    --经典场房间
    self._roomList = {}
    --私人定制房间信息
    self._customize_roomlist = {}
    --破产返利配置
    self._bankruptcy_returnList = {}
    self.when_to_share = {}

    --[[错误信息]]
    self._errorMsg = {}
    -- 商城内广告条
    self._store_activities = {}
    --刮刮卡--
    self._chanceCard_siteList = {}  --刮刮卡投注站表信息

    self._ingame_buy_list = {} --游戏内可购买列表
end

function Config:saveConfig(model)
    self.timestamp = model.timestamp            --时间戳
    self.broadcastCost = model.broadcast_cost
    self.qq_prompt = model.qq_prompt or ""              --“官方Q群”字符串
    self.qq_prompt_last = model.qq_prompt_last or ""    --qq号
    
    self._hasPickBeautyDayReward = model.has_pick_beauty_day_reward --是否领取了美女日常奖励
    self._defaultDelayTime = model.default_delay --超时时间
    self.phoneNum = model.phone --绑定的手机号
    self:initStoreActivities(model.store_activities)

    self.shop_activity_id = model.store_activity.activity_id -- 商城活动id
    self.shop_banner_url = model.store_activity.banner_url -- 商城活动图片url
    self.shop_activity_url = model.store_activity.activity_url -- 商城活动url
    self.ddz_match_promoter_itemrid = model.ddz_match_promoter_itemrid --推广员商城id
    self.bankrupt_count = model.bankrupt_count

    local _contrl = model.modules -- 模块位控制
    local function _getContrlBolByBit(_bit)
        return 0 ~= Util:binaryAnd(_contrl, _bit) and true or false
    end

    TB_MODULE_BIT.BOL_MODULE_BIT_STORE = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_STORE)         -- 商城模块
    TB_MODULE_BIT.BOL_MODULE_BIT_EASY_BUY = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_EASY_BUY)   -- 快捷支付
    TB_MODULE_BIT.BOL_MODULE_BIT_KNAPSACK = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_KNAPSACK)   -- 道具
    TB_MODULE_BIT.BOL_MODULE_BIT_ACTIVITY = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_ACTIVITY)   -- 活动
    TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_REVIEW)       -- 审核开关
    TB_MODULE_BIT.BOL_MODULE_BIT_SPECIAL_PAY = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_SPECIAL_PAY) -- 1000、2000元订单隐藏
    TB_MODULE_BIT.BOL_MODULE_BIT_STORE_TAB = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_STORE_TAB) -- 其他页签关闭：金币购买、道具超市、兑换专区
    TB_MODULE_BIT.BOL_MODULE_BIT_STORE_BANNER = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_STORE_BANNER) -- 商城banner（广告条）关闭
    TB_MODULE_BIT.BOL_MODULE_BIT_EXCHANGE_FUCARD = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_EXCHANGE_FUCARD) --  奖券兑换中心
    TB_MODULE_BIT.BOL_MODULE_BIT_BROADCAST_SYS_MSG = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_BROADCAST_SYS_MSG) --  系统消息广播
    TB_MODULE_BIT.BOL_MODULE_BIT_STORE_EXCHANGE = model.exchange_support == 1 --商城兑换页面控制

    TB_MODULE_BIT.BOL_MODULE_BIT_TUIGUANG = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_TUIGUANG)

    for i = 1, model.group:len() do             --获取场次信息
        local item = model.group:get(i)
        self._groupList[item.id] = item.name
    end
    
    Cache.wordMsg:setDeafultMsg(model.ddz_hall_loop_msg)--跑马灯默认显示文字
    Cache.PayManager:initInfo(model.item_list)
    
    Cache.QuickPay:initInfo()   --快捷支付依赖于商城支付,这里要放到PayManager之后初始化

    self:copyTable({"gold","item_id"},model.desk_gift_list,self._giftList)    --获取礼物列表

    for i=1,model.room:len() do
        local roomInfo = model.room:get(i)
        local r2 = {}
        self:copyFiled({"id","carry_min","carry_limit","small_blind","big_blind","seat_limit","enter_limit","group","must_spend","carry_chips","vip_room"},roomInfo,r2)
        r2.service_rate = tonumber(roomInfo.service_fee or "0")  --不再使用float类型，使用字符串，以免精度出问题.(release.160)
        r2.bets = {}
        for i=1,roomInfo.bets:len() do
            r2.bets[i] = roomInfo.bets:get(i)
        end
        self._roomList[roomInfo.id]= r2
    end
    
    for i=1,model.activity_rewards:len() do
        local item = model.activity_rewards:get(i)
        self._activityList[i] = {}
        self._activityList[i].id = item.id
        self._activityList[i].gold = item.gold
        if item.id == 1 then self._firstFlushGold = item.gold end --首充奖励
        if item.reward_gold_list then 
            self._activityList[i].reward_gold_list = {}
            for j = 1,item.reward_gold_list:len() do
                self._activityList[i].reward_gold_list[j] = item.reward_gold_list:get(j)
            end
        end
    end

    self:copyArray(model.dayreward,self._dayReward)--日常奖励
    for i = 1, model.dayreward:len() do
        local item = model.dayreward:get(i)
        self._dayReward[i] = item
    end
    
    --商品信息start--
    local shopItemName = {"item_id","cost","cost_desc","cost_type","gold","extra","desc","dianxin_code","ydmm_code","liantong_code","extra_desc","wii_code","aws_code","google_code","hot","goodstatus"}
    for i = 1, model.cny_money2gold:len() do
        local item = model.cny_money2gold:get(i)
        self._shopInfoList[i] = {}
        for key,v in pairs(shopItemName) do
            self._shopInfoList[i][v] = item[v]
        end
        self._shopInfoList[i]["sorted_bill_types"] = {}
        self._shopInfoList[i]["sorted_bill_types"]["DX"] = {}
        self._shopInfoList[i]["sorted_bill_types"]["LT"] = {}
        self._shopInfoList[i]["sorted_bill_types"]["YD"] = {}
        for j = 1, item["sorted_bill_types"]["DX"]:len() do
            self._shopInfoList[i]["sorted_bill_types"]["DX"][j] = item["sorted_bill_types"]["DX"]:get(j)
        end
        
        for j = 1, item["sorted_bill_types"]["LT"]:len() do
            self._shopInfoList[i]["sorted_bill_types"]["LT"][j] = item["sorted_bill_types"]["LT"]:get(j)
        end
        
        for j = 1, item["sorted_bill_types"]["YD"]:len() do
            self._shopInfoList[i]["sorted_bill_types"]["YD"][j] = item["sorted_bill_types"]["YD"]:get(j)
        end

        self._shopInfoList[i]["weimi_pay_codes"] = {}
        self._shopInfoList[i]["weimi_pay_codes"]["liantong"] = item["weimi_pay_codes"]["liantong"]
        self._shopInfoList[i]["weimi_pay_codes"]["yidong"] = item["weimi_pay_codes"]["yidong"]
        self._shopInfoList[i]["weimi_pay_codes"]["dianxin"] = item["weimi_pay_codes"]["dianxin"]
    end
    --商品信息end--
    
    --新手礼包start--
    for i = 1 ,model.gift_packs_to_display:len() do
        local item = model.gift_packs_to_display:get(i)
        self._mapingItemId[i] = {}
        self._mapingItemId[i]["gift_id"] = item["gift_id"]
        self._mapingItemId[i]["item_id"] = item["item_id"]
    end

    for i = 1, model.cny_gift_packs:len() do
        local item = model.cny_gift_packs:get(i)
        self._noviceShopInfoList[i] = {}
        for key,v in pairs(shopItemName) do
            self._noviceShopInfoList[i][v] = item[v]
        end
        self._noviceShopInfoList[i]["sorted_bill_types"] = {}
        self._noviceShopInfoList[i]["sorted_bill_types"]["DX"] = {}
        self._noviceShopInfoList[i]["sorted_bill_types"]["LT"] = {}
        self._noviceShopInfoList[i]["sorted_bill_types"]["YD"] = {}
        for j = 1, item["sorted_bill_types"]["DX"]:len() do
            self._noviceShopInfoList[i]["sorted_bill_types"]["DX"][j] = item["sorted_bill_types"]["DX"]:get(j)
        end

        for j = 1, item["sorted_bill_types"]["LT"]:len() do
            self._noviceShopInfoList[i]["sorted_bill_types"]["LT"][j] = item["sorted_bill_types"]["LT"]:get(j)
        end

        for j = 1, item["sorted_bill_types"]["YD"]:len() do
            self._noviceShopInfoList[i]["sorted_bill_types"]["YD"][j] = item["sorted_bill_types"]["YD"]:get(j)
        end

        self._noviceShopInfoList[i]["weimi_pay_codes"] = {}
        self._noviceShopInfoList[i]["weimi_pay_codes"]["liantong"] = item["weimi_pay_codes"]["liantong"]
        self._noviceShopInfoList[i]["weimi_pay_codes"]["yidong"] = item["weimi_pay_codes"]["yidong"]
        self._noviceShopInfoList[i]["weimi_pay_codes"]["dianxin"] = item["weimi_pay_codes"]["dianxin"]

    end
    --新手礼包end--
    
    --获取错误信息start
    self:saveConfigErrorMessages(model)
    
    if model.daily_rewards_v2 ~= nil then
        for i=1 ,model.daily_rewards_v2:len() do
            local reward = model.daily_rewards_v2:get(i)
            self._loginReward[i] = {}
            self._loginReward[i].index = reward.index
            self._loginReward[i].Gifts = {}
            for j=1, reward.items:len() do
                local item =  reward.items:get(j)
                self._loginReward[i].Gifts[j] = {}
                self._loginReward[i].Gifts[j].type = item.type 
                self._loginReward[i].Gifts[j].amount = item.amount
                self._loginReward[i].Gifts[j].desc = item.desc
                self._loginReward[i].Gifts[j].activity_amount = item.activity_amount
            end

        end
    end
   
    self:updateTimeBox(model.time_box)
    self:updateWhenToShare(model.when_to_share)
    self:updatePeriodRoomList(model.period_rooms)
    self:updateCustomizeRoomInfo(model.private_times)
    self:updateCustomizeBuyinLimit(model.buyin_multiples)
    
    --默认头像
    self.hiding_portrait = {}
    if model.hiding_portrait ~= nil and model.hiding_portrait:len() >= 2 then
		self.hiding_portrait[1] = model.hiding_portrait:get(1)
		self.hiding_portrait[2] = model.hiding_portrait:get(2)
    end

    --破产数值
    self.bankrupt_money = model.bankrupt_money

    --破产返利配置
    self:updateBrokeReturn(model.broke_return)

    --钻石兑换金币的比例
    self.diamond2gold_ratio = model.diamond2gold_ratio

    --破产补助领取次数
    self:setBankruptcyFetchCount(model.fetch_broke_count)

    self.isShowAgreementNotice = model.agreement_switch

    --[[   刮刮卡url   ]]
    self.chance_card_url_list = {}

    for i = 1, model.chance_card_url:len() do
        local item = model.chance_card_url:get(i)
        local temp = {
            item_id = item.item_id,
            url = item.url
        }
        table.insert(self.chance_card_url_list, temp)
    end

    loga("===========chance_card_url_list============")
    dump(self.chance_card_url_list)

    --[[   banner 跳转   ]]
    self.banner_link_list = {}
    for i = 1, model.banner_link:len() do
        local item = model.banner_link:get(i)
        
        local temp = {
            name = item.name,
            url = item.url,
            dest = item.dest
        }
        table.insert(self.banner_link_list, temp)
    end

    self.games = {}
    for i=1,model.game_list:len() do
        local item = model.game_list:get(i)
        local tmp = {}
        tmp['game_index']    = item.game_index
        tmp['game_name']     = item.game_name
        tmp['game_display']  = item.game_display
        tmp['game_icon']     = item.game_icon
        tmp['game_download_images']     = item.game_download_images
        table.insert(self.games,tmp)
    end

    table.sort( self.games, function ( a,b )
        return a.game_index > b.game_index
    end )

    local recharge_return_fucard = model.recharge_return_fucard--获得奖券每日充值的数值
    self.recharge_return_fucard = string.split(recharge_return_fucard,":")
    self.fuli_words = model.fuli_words  --福利文案

    self.promoter_support = false
    if model.ddz_match_promoter_swtcher and model.ddz_match_promoter_swtcher == 1 then
        self.promoter_support = true
    end
end

--更新微信的配置
function Config:updateWxConfig(model)
    --斗地主
    -- if GAME_INSTALL_TABLE['game_ddz'] then
    Cache.DDZconfig:saveConfig(model)
    -- end
end

--更新周边config
function Config:updateConfig(model)
    self._hasPickBeautyDayReward = model.has_pick_beauty_day_reward --是否领取了美女日常奖励

    if model.daily_rewards_v2 ~= nil then
        for i=1 ,model.daily_rewards_v2:len() do
            local reward = model.daily_rewards_v2:get(i)
            self._loginReward[i] = {}
            self._loginReward[i].index = reward.index
            self._loginReward[i].Gifts = {}
            for j=1, reward.items:len() do
                local item =  reward.items:get(j)
                self._loginReward[i].Gifts[j] = {}
                self._loginReward[i].Gifts[j].type = item.type 
                self._loginReward[i].Gifts[j].amount = item.amount
                self._loginReward[i].Gifts[j].desc = item.desc
            end
        end
    end
    self:updateTimeBox(model.time_box)
end

---------时间宝箱 start------------
--保存服务器下发的时间宝箱数据
function Config:updateTimeBox(m)
    if m == nil then return end
    self.box_index = m.box_index
	self.max_index = 0
    self.boxConfig = {}
    for i = 1, m.items:len() do
        local info = m.items:get(i)
        self.boxConfig[info.index] = {}
        self:copyFiled({"index", "gold","time_begin","time_end"},info,self.boxConfig[info.index])
        --duration:完成耗时
        self.boxConfig[info.index].duration = self.boxConfig[info.index].time_end - self.boxConfig[info.index].time_begin
		if self.max_index < info.index then self.max_index = info.index end
    end
	logd("时间宝箱领取阶段: "..self.box_index.."/"..self.max_index, "TimeBox")
end

--获取时间宝箱信息
function Config:getTimeBoxInfo()
	if self:judgeTimeboxIndexCorrect(self.box_index) == false then return nil end
	return self.boxConfig[self.box_index]
end

--是否宝箱任务全部完成
function Config:judgeTimeboxIndexCorrect(index)
	if index < 0 or index > self.max_index then
		return false
	else
		return true
	end
end
---------时间宝箱 end------------

function Config:copyFiled(p,s,d)
    for k,v in pairs(p) do
        d[v] = s[v]
    end
end

function Config:copyTable(keyTable,src,desc) 
    for i = 1, src:len() do
        local item = src:get(i)
        desc[i] = {}
        for key , v in pairs(keyTable) do
            desc[i][v] = item[v]
        end
    end
end

function Config:updateWhenToShare(src)
    local keys = {"classic_win_big_blind","bairen_win_chips","bairen_win_over_i_had"}
        for i = 1, #keys do
        self.when_to_share[keys[i]] = src[keys[i]]
    end 
end

function Config:copyArray(src,desc)
    --logd(src:len(),"")
    for i = 1, src:len() do
        desc[i] = src:get(i)
    end 
end

-------------私人定制------------------
--判断是否是私人定制房间
function Config:isCustomizeRoom(roomid)
	if roomid ~= nil and roomid > 10000 then
		return true
	else
		return false
	end
end
--私人定制房间时长信息
function Config:updateCustomizeRoomInfo(room_times)
	self._customize_timelist = {}
	if room_times ~= nil then
		for i=1, room_times:len() do
			self._customize_timelist[i] = room_times:get(i)
		end
	end
	--按时长从小到大排序
	table.sort(self._customize_timelist)
	
	--从_room_list中过滤出room_info
	self._customize_roomlist = {}
	local index = 1
	for k,v in pairs(self._roomList) do
		if v.id > 10000 then
			logd("customize room config: carry_min = "..v.carry_min..", carry_limit = "..v.carry_limit)
        	local item = {}
        	self:copyFiled({"id","carry_min","carry_limit","small_blind","big_blind","seat_limit","enter_limit","group","must_spend","service_rate","carry_chips","vip_room"}, v, item)
			self._customize_roomlist[index] = item
			index = index + 1
		end
	end
	--私人定制房间按盲注从小到大排序
	table.sort(self._customize_roomlist, function(a,b) return a.carry_min < b.carry_min end) 
    for k,v in pairs(self._customize_roomlist) do  --将vip放到最后
         if  v.vip_room~=0 then 
             table.insert(self._customize_roomlist, #self._customize_roomlist+1, v)
             table.remove(self._customize_roomlist,k)
            break
         end
    end
end
--更新私人房间buyin限制
function Config:updateCustomizeBuyinLimit(buyin_multiples)
    self._customize_buyin = {}
    if buyin_multiples == nil then return end
    for i = 1, buyin_multiples:len() do
        local multiples = buyin_multiples:get(i)
        self._customize_buyin[#self._customize_buyin+1] = multiples
    end
end
function Config:getCustomizeRoomBuyinLimit()
    return self._customize_buyin
end

--获取私人定制房间列表
function Config:getCustomizeRoomList()
	return self._customize_roomlist
end
--获取私人定制房间时长配置
function Config:getCustomizeRoomTimes()
	return self._customize_timelist
end
--通过roomid获取私人定制房间信息
function Config:getCustomizeRoomInfoById(roomid)
	local item = nil
	for k,v in pairs(self._customize_roomlist) do
		if v.id == roomid then
			item = v
		end
	end
	return item
end

--更新有实时战绩显示的房间列表
function Config:updatePeriodRoomList(period_rooms)
	local dumpstr = ""
	self._period_rooms = {}
	if period_rooms ~= nil then
		for i=1, period_rooms:len() do
			self._period_rooms[i] = period_rooms:get(i)
			dumpstr = dumpstr .. self._period_rooms[i] .. ","
		end
	end
	logd("支持实时战绩的房间列表共有"..#self._period_rooms.."个: "..dumpstr)
end
--根据roomid判断该房间是否可以显示实时战绩
function Config:judgePeriodByRoomid(roomid)
	if self._period_rooms == nil then return false end
	local b = false
	for k, v in pairs(self._period_rooms) do
		if v == roomid then
			b = true
			break
		end
	end
	return b
end

------------------------------破产返利----------------------
function Config:updateBrokeReturn(config)
    if config == nil then return end
    self._bankruptcy_returnList = {}
    for i = 1, config:len() do
        local v = config:get(i)
        local item = {} 
        self:copyFiled({"min","max","percent"}, v, item)
        self._bankruptcy_returnList[i] = item
    end
end

function Config:getBrokeReturn(diamond)
    for k,v in pairs(self._bankruptcy_returnList) do
        if diamond > v.min and diamond <= v.max then
            local percent = tonumber(v.percent)
            return math.floor(diamond*percent)
        end
    end
    return 0
end

--获取房间最小携带数
function Config:getRoomCarryMin( roomid )
    return self._roomList[roomid].carry_min
end

--获取房间的携带限制
function Config:getRoomCarryLimit( roomid )
    return self._roomList[roomid].carry_limit
end

--获取房间的大小盲
function Config:getRoomBlind( roomid )
    return self._roomList[roomid].big_blind, self._roomList[roomid].small_blind
end

--保存破产可领取补助次数
function Config:setBankruptcyFetchCount( count )
    self.fetch_count = count
end

--获取破产可领取补助次数
function Config:getBankruptcyFetchCount()
    return self.fetch_count
end

function Config:saveConfigErrorMessages(model)
    if model == nil or model.error_list == nil then return end
    for i=1,model.error_list:len() do
        local errorInfo = model.error_list:get(i)
        self._errorMsg[errorInfo.id]= errorInfo.desc;
    end
    self._errorMsg[-200]= GameTxt.nettimeout
end

function Config:initStoreActivities( model )
    self._store_activities = {}
    for i = 1, model:len() do
        local t = model:get(i)

        table.insert(self._store_activities
            , {activity_id = t.activity_id
            , banner_url = t.banner_url
            , activity_url = t.activity_url
            })
    end
end
function Config:getStoreActivities( ... )
    return self._store_activities
end

function Config:saveChanceCardListData( model )
    self._chanceCard_siteList = {}
    if model == nil then
        return
    end
    for i = 1, model.address_list:len() do
        local t = model.address_list:get(i)
        table.insert(self._chanceCard_siteList
            , {phone = t.phone
            , province  = t.province 
            , city = t.city
            , area   = t.area  
            , address   = t.address  
            })
    end

    dump(self._chanceCard_siteList)
end

function Config:saveIngameBuyList(model)
    self._ingame_buy_list = {}
    if model == nil then
        return
    end
    for i = 1, model.store_item:len() do
        local t = model.store_item:get(i)
        table.insert(self._ingame_buy_list
            , {name = t.name
            , type  = t.type
            , currency = t.currency
            , price   = t.price
            , title   = t.title
            })
    end
end

function Config:getIngameBuyList()
    return self._ingame_buy_list
end

function Config:updateGameTaskInfo( model )
    self.game_task = {}
    for i = 1, model.all_task:len() do
        local roomTask = model.all_task:get(i)
        local room = {}
        room.room_id = roomTask.room_id
        room.task_list = {}

        for j = 1, roomTask.task_list:len() do
            local task = {}
            self:copyFiled({"id", "condition", "progress", "status"}, roomTask.task_list:get(j), task)
            local reward_list = {}
            self:copyTable({"reward_type", "reward_nums", "img_index", "img_url", "lottery_ticket_desc"}, roomTask.task_list:get(j).reward_list, reward_list)
            task.reward_list = reward_list
            table.insert( room.task_list,task )
        end
        table.sort( room.task_list, function ( a, b )
            return a.id < b.id
        end )
        table.insert( self.game_task,room )
    end

    table.sort( self.game_task, function ( a, b )
        return a.room_id < b.room_id
    end )

end

function Config:getGameTaskInfo(  )
    return clone(self.game_task)
end

function Config:getGameTaskStatusByRoomId(room_id)
    if not self.game_task then return false end
    local roomTaskInfo = nil
    for k,v in pairs(self.game_task) do
        if room_id == v.room_id then
            roomTaskInfo = v
            break
        end
    end
    
    if not roomTaskInfo then return false end

    local isReward = false --是否可领
    local taskInfo = nil
    for i = 1, #roomTaskInfo.task_list do
        local data = roomTaskInfo.task_list[i]

        if data.status == 1 and not taskInfo then
            taskInfo = {type = 1, data = clone(data)} --任务进行中
        elseif data.status == 2 then
            isReward = true
        end
    end

    if isReward then
        taskInfo = taskInfo or {}
        return {type = 2, data = clone(taskInfo.data)}--可领奖
    end

    if taskInfo then return taskInfo end

    return {type = 3}--无任务
end

--通知差异任务
function Config:updateGameTaskInfoByNtf( model )
    if not self.game_task then return end
    for key, roomTaskInfo in pairs(self.game_task) do
        for k, data in pairs(roomTaskInfo.task_list) do
            for i = 1, model.change_list:len() do
                local taskInfo = model.change_list:get(i)
                if taskInfo.id == data.id then
                    self:copyFiled({"id", "condition", "progress", "status"}, taskInfo, data)
                    break
                end
            end
        end
    end

end

--更新比赛大厅数据
function Config:updateMatchHallInfo( model )
	local props = {"match_level", "dan_grading", "star_number", "current_level_award", "next_level_award",
		"at_play_num", "guide_status", "star_max_number", "season_award", "season_sn", "season_date_range"
		, "session_info", "sub_level", "settle_info", "match_regulations_path", "need_exchange_coupon"
	}
    self.matchHallInfo = {}
    self:copyFiled(props, model, self.matchHallInfo)

    self.matchHallInfo.session_info = {}    -- 场次信息
    self.matchHallInfo.season_award = {}    -- 赛季奖励信息
    self.matchHallInfo.settle_info = {}     -- 赛季结算弹窗信息

    for i = 1,model.session_info:len() do
        self.matchHallInfo.session_info[i] = {}
        self:copyFiled({"session_type", "session_switch", "enter_fee_type", "enter_fee"}, model.session_info:get(i), self.matchHallInfo.session_info[i])
    end
    for i = 1,model.season_award:len() do
        self.matchHallInfo.season_award[i] = {}
        self:copyFiled({"award_type", "award_num", "icon_frame_path","icon_frame_id"}, model.season_award:get(i), self.matchHallInfo.season_award[i])
    end

    self:copyFiled({"season_sn", "season_award", "all_lv_info", "season_max_lv", "defeat_num"}, model.settle_info, self.matchHallInfo.settle_info)
    self.matchHallInfo.settle_info.season_award = {}
    self.matchHallInfo.settle_info.all_lv_info = {}
    if isValid(model.settle_info.season_award) then
        for i = 1,model.settle_info.season_award:len() do
            self.matchHallInfo.settle_info.season_award[i] = {}
            self:copyFiled({"award_type", "award_num", "icon_frame_path","icon_frame_id"}, model.settle_info.season_award:get(i), self.matchHallInfo.settle_info.season_award[i])
        end
        self:copyFiled({"match_lv", "sub_lv", "star", "sub_lv_star_num"}, model.settle_info.all_lv_info, self.matchHallInfo.settle_info.all_lv_info)    
    end

    self.matchHallInfo.app_info = {}
    self:copyFiled({"is_pop_bubble", "season_max_lv", "king_rank", "award_conf", "cur_lv_award", "next_lv_award"}, model.app_info, self.matchHallInfo.app_info)
    
    self.matchHallInfo.app_info.award_conf = {}
    for i = 1,model.app_info.award_conf:len() do
        self.matchHallInfo.app_info.award_conf[i] = {}
        self:copyFiled({"match_lv", "coupon_num"}, model.app_info.award_conf:get(i), self.matchHallInfo.app_info.award_conf[i])
    end
end

--获取比赛大厅数据
function Config:getMatchHallInfo()
    return clone(self.matchHallInfo)
end

--更新赛事排行榜数据
function Config:updateMatchRankInfo( model )
    local props = {"uin", "rank", "score", "level", "times", "rate", "nick", "icon",
                "is_new", "coupon", "season_sn", "sub_lv", "star"}

    self.matchRankInfo = {}
    for i = 1,model.leader_board_info:len() do
        self.matchRankInfo[i] = {}
        self:copyFiled(props, model.leader_board_info:get(i), self.matchRankInfo[i])
    end
end

function Config:getMatchRankInfo()
    return self.matchRankInfo
end

function Config:setTuiGaungInfo( model )
    self.tuiguangInfo = self.tuiguangInfo or {}
    self.tuiguangInfo.reward_per_user = model.reward_per_user  --邀请固定奖励
    self.tuiguangInfo.activity_date = model.act_time
    -- if not self.tuiguangInfo.activity_date or self.tuiguangInfo.activity_date == "" then
    --     self.tuiguangInfo.activity_date = "2018年9月25日-2018年10月25日"
    -- end
    self.tuiguangInfo.share_info = {}
    self:copyFiled({"title", "content", "url"}, model.share_info, self.tuiguangInfo.share_info)
    
    self:updateTuiGuangInfo(model)
end

function Config:updateTuiGuangInfo( model )
    self.tuiguangInfo = self.tuiguangInfo or {}

    self.tuiguangInfo.isFinishBonus = 1
    
    self.tuiguangInfo.invitedInfo = self.tuiguangInfo.invitedInfo or {} --邀请数据
    self.tuiguangInfo.invitedInfo.invited_count = model.invited_touch.invited_count
    self.tuiguangInfo.invitedInfo.reward_num = model.invited_touch.reward_num

    self.tuiguangInfo.task_list = self.tuiguangInfo.task_list or {}

    for i = 1, model.task_arr:len() do
        local data = model.task_arr:get(i)
        self:updateTuiGaungTask(data)
    end

    self.tuiguangInfo.is_reward = false
    for i = 1, #self.tuiguangInfo.task_list do
        if self.tuiguangInfo.task_list[i].task_status == 1 then
            self.tuiguangInfo.is_reward = true
            break
        end
    end
end

function Config:updateTuiGaungTask( data )
    for i = 1, #self.tuiguangInfo.task_list do
        local taskData = self.tuiguangInfo.task_list[i]

        if taskData.task_id == data.task_id then
            self:copyFiled({"task_id", "reward_num", "task_require", "task_process", "task_status", "task_desc"}, data, taskData)

            self.tuiguangInfo.task_list[i] = taskData

            if taskData.task_id == 2 then
                if taskData.task_status == 2 then
                    self.tuiguangInfo.isFinishBonus = 2
                else
                    self.tuiguangInfo.isFinishBonus = 1
                end
            end
            return
        end
    end

    local taskData = {}
    self:copyFiled({"task_id", "reward_num", "task_require", "task_process", "task_status", "task_desc"}, data, taskData)

    table.insert( self.tuiguangInfo.task_list, taskData )
end

function Config:getTuiGuangInfo(  )
    return clone(self.tuiguangInfo)
end

function Config:setInteractTime(time)
    self.interactTime = time
end

function Config:getInteractTime()
    return self.interactTime
end

return Config
