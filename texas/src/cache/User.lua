local User = class("User")


function User:ctor() 
	
end

--[[
    optional int32 uin = 1;  // user id
    optional string key = 2; // user password
    optional string nick = 3;  //user nick
    optional int32 sex = 4; // user sex
    optional int64 gold = 5; // user gold
    optional int32 win = 6; // user win times
    optional int32 lose = 7; // user lose times
    optional int32 day = 8; // user login days
    optional string title = 9;  // user  title
    optional int32 vip_level = 10; // user vip level
    optional bool got_day_reward = 11; // user day reward flag
    optional bool got_vip_day_reward = 12;  // user vip_day_reward flag
    optional bool recharged = 13;  // recharge?
    optional int32 view_times = 14; // 观看次数
    optional int32 play_over_times = 15; // 玩到底的次数
    optional int32 play_times = 16;   // 玩的次数
    repeated int32 max_history_cards = 17;  // 历史最大手牌
    optional int32 max_history_win_chips = 18;  // 最大赢取筹码数
    optional int32 level =19; // 等级
    optional bool beauty = 20;  // 是否是认证美女
    optional bool got_beauty_day_reward = 21;  // 是否获取了美女每日奖励
    optional bool got_beauty_rank_week_reward = 22; //  获取美女每周排行奖励
    optional int32 last_week_beauty_rank = 23; // 上周美女排行
    optional string invite_code = 24; // 邀请码
    optional int32 online = 25; //在线人数
    optional int32 old_roomid = 26; // 给断线重连用的

]]
function User:updateCacheByLogin(model)
    if model == nil then return end
    self.old_roomid = 0
	local filedname = {
		"uin",
	    "key",
	    "nick",
	    "sex",
	    "gold",
	    "win",
	    "lose",
	    "day",
	    "title",
	    "vip_level",
	    "got_day_reward",
	    "got_vip_day_reward",
	    "recharged",
	    "view_times",
	    "play_over_times",
	    "play_times",
	    "max_history_win_chips",
	    "level",
	    -- "beauty",
	    -- "got_beauty_day_reward",
	    -- "got_beauty_rank_week_reward",

	    "invite_code",
	    "online",
	    "old_roomid",
	    "room_type", --给断线重连用的, 房间类型 0无, 1:ddz
        "account_bind_status",
        "remain_times",
        "score",
        "pokerface",
        "diamond",
        "contest_credit",
        "anti_stealth",
        "event_id",
        "event_exit_reason", --用户旁观MTT，断网重连回来不能进桌的原因
        "promotion_code",
        "is_new_user",
        "code_money",
        "cnd_path",
        "remain_time",
        "show_lucky_wheel_or_not",
        "IsRightTime",
        "left_time",
        "day_reward_start_time",
        "day_reward_end_time",
        "night_reward_start_time",
        "night_reward_end_time",
        "show_cumulate_login_or_not",
        "cumulate_login_reward",
        "is_new_reg_user",
        "show_third_pay_or_not",
        "game_list_type",
        "up_game_list",
        "down_game_list",
        "login_type",
        "phone",
        "address",
        "post_code",
        "fucard_num",
        "real_name",
        "show_invite",
        "show_all_func_or_not",
        -- "ddz_match_level",
        "ddz_match_exp",
        "is_bind_wx",
        "show_chance_card_or_not",
        "lucky_wheel_play_times",
        "lucky_wheel_play_amount",
        "lucky_wheel_play_type",
        "lucky_wheel_tips",
        "lucky_wheel_open_days",
        "lucky_wheel_open_times",
        "user_identity",
		"lucky_wheel_all_times",
		"app_new_user_reg_gift_click_status"
	}
	for k,v in pairs(filedname) do
		self[v] = model[v]
	end

	if model.simple_user_info then
		self:updateCacheByUseInfo(model.simple_user_info,model.simple_user_info.uin)
	end

	if not self.ddz_match_level or self.ddz_match_level < 10 then
       self.ddz_match_level = 10 --默认是10
	end

	--超级加倍卡数量(初始化)
	self.super_multi_card_num = 0

	--赛事场信息
	self.ddz_match_config = {}
	self.ddz_match_config.entry_fee = model.ddz_match_config.entry_fee
	self.ddz_match_config.min_gold_limit = model.ddz_match_config.min_gold_limit
	self.ddz_match_config.start_cond_player_count = model.ddz_match_config.start_cond_player_count
	self.ddz_match_config.game_count_per_match = model.ddz_match_config.game_count_per_match
	self.ddz_match_config.service_charge_per_game = model.ddz_match_config.service_charge_per_game
	self.ddz_match_config.practice_roomid = model.ddz_match_config.practice_roomid
	self.ddz_match_config.grade_detail = model.ddz_match_config.grade_detail
	self.ddz_match_config.practice_gold = model.ddz_match_config.practice_gold
	self.ddz_match_config.match_rule_path = model.ddz_match_config.match_rule_path
	self.ddz_match_config.match_desc_path = model.ddz_match_config.match_desc_path or ""

	loga( "self.ddz_match_config.match_desc_path = " .. self.ddz_match_config.match_desc_path)

	self.ddz_match_config.up_max_lv_hint = model.ddz_match_config.up_max_lv_hint--达到最高等级提示语 
	
	self:updateGradeDetail(model.ddz_match_config.wx_grade_detail_nest)

	self.max_history_cards = {}

	--最大历史手牌
	for i=1,model.max_history_cards:len() do
		self.max_history_cards[i] = model.max_history_cards:get(i)
	end
	--self.got_day_reward = false
    if model.max_history_win_chips64 ~= nil then
        self.max_history_win_chips = model.max_history_win_chips64  --最大赢取在服务器端改为64位存储
    end

    self.start_time = os.time()
    self.turn_os_time = os.time()
    self.hasShowActivity = 0
    self.reConnect_status       = true
	self.upGameList={}
	self.downGameList={}		
	if self.up_game_list ~= "" and self.up_game_list ~= "0" then
		self:updateGameList(self.up_game_list,self.upGameList)
	end
	if self.down_game_list ~= "" and self.up_game_list ~= 0 then
		self:updateGameList(self.down_game_list,self.downGameList)
	end

	local setDefault = function ()
		self.game_list_type=2
		self.downGameList={
		{name="7",status="0"},
		{name="1",status="0"},
		{name="2",status="0"}}
	end
	if self.game_list_type == 0 then
		setDefault()
	end
	if self.up_game_list == "" and self.down_game_list == "" then
		setDefault()
	end

	self.isNeedShowActivityPop = 1
	self.shareFlag = true
end

--根据level获取对应level奖励配置信息
function User:getConfigByLevel(level)
	local finalLevel = level
	if level == nil then finalLevel = 1 end
	return self.ddz_match_config.detail[level]
end

-- 获取最高等级
function User:getMaxLevel()
	local levelKeyTabl = table.keys(self.ddz_match_config.detail)
	return math.max(unpack(levelKeyTabl))
end

function User:getRewardConfigByLevel(level, rank)
	local rewardTable = {}
	local rewardConfig = self.ddz_match_config.detail[level]
	if table.nums(rewardConfig["reward_top_" .. rank]) > 1 then
		for k,v in pairs(rewardConfig.reward_top_1) do
			table.insert(rewardTable, v)
		end
	end
	return rewardTable
end

--等级奖励配置
function User:updateGradeDetail( grade_detail_nest )
	self.ddz_match_config.detail = {}
	local maxLevel = 10
	for i=1,grade_detail_nest:len() do
		local detail = grade_detail_nest:get(i)
		self.ddz_match_config.detail[detail.level] = {}
		self.ddz_match_config.detail[detail.level].level = detail.level
		if maxLevel < detail.level then
            maxLevel = detail.level
		end
		self.ddz_match_config.detail[detail.level].title = detail.title
		self.ddz_match_config.detail[detail.level].game_times = detail.game_times
		self.ddz_match_config.detail[detail.level].reward_top_1 = {}
		for j=1,detail.reward_top_1:len() do
			local reward = {}
			reward.type = detail.reward_top_1:get(j).type
			reward.value = detail.reward_top_1:get(j).value_min
			reward.value_max = detail.reward_top_1:get(j).value_max
			table.insert(self.ddz_match_config.detail[detail.level].reward_top_1,reward)
		end
		self.ddz_match_config.detail[detail.level].reward_top_2 = {}
		for j=1,detail.reward_top_2:len() do
			local reward = {}
			reward.type = detail.reward_top_2:get(j).type
			reward.value = detail.reward_top_2:get(j).value_min
			reward.value_max = detail.reward_top_2:get(j).value_max
			table.insert(self.ddz_match_config.detail[detail.level].reward_top_2,reward)
		end
		self.ddz_match_config.detail[detail.level].reward_top_3 = {}
		for j=1,detail.reward_top_3:len() do
			local reward = {}
			reward.type = detail.reward_top_3:get(j).type
			reward.value = detail.reward_top_3:get(j).value_min
			reward.value_max = detail.reward_top_3:get(j).value_max
			table.insert(self.ddz_match_config.detail[detail.level].reward_top_3,reward)
		end
	end
    self.ddz_match_config.valid_lv_max = maxLevel
end

function User:updateGameInfo(model)
	local filedname = {
        "total_play_times",
    	"total_win_rate",
        "single_win_max",
	    "week_gameing_result",
	    "jh_play_times",
	    "jh_win_rate",
	    "dn_play_times",
	    "dn_win_rate",
	    "double_win",
	    "single_win",
	    "ddz_win_rate",
	    "ddz_play_times",
	    "ddz_max_multiple",
	    "ddz_max_win",
	    "ddz_match_max_history_level"
	}

	for k,v in pairs(filedname) do
		self[v] = model[v]

	end
	self.jh_max_history_cards = {}
	self.dn_max_history_cards = {}
	-- self.total_play_times = self.total_play_times  or 0
	-- self.total_win_rate = self.total_win_rate  or 0
	-- self.single_win_max = self.single_win_max  or 0
	-- self.week_gameing_result = self.week_gameing_result  or 0
	-- self.jh_play_times = self.jh_play_times  or 0

	-- self.jh_win_rate = self.jh_win_rate  or 0
	-- self.dn_play_times = self.dn_play_times  or 0
	-- self.dn_win_rate = self.dn_win_rate or 0
	-- 斗牛最大历史手牌

	for i=1,model.dn_max_history_cards:len() do
		self.dn_max_history_cards[i] = model.dn_max_history_cards:get(i)
	end

	-- 金花最大历史手牌
	for i=1,model.jh_max_history_cards:len() do
		self.jh_max_history_cards[i] = model.jh_max_history_cards:get(i)
	end 
end

function User:updateGameList(listcontent,list)
	-- body
	local content=listcontent
	local gamelist={}
	gamelist=string.split(content,"|")
	for k,v in pairs(gamelist)do
		local info={}
		info=string.split(v,":")
		local gameinfo={}
		gameinfo.name=info[1]
		gameinfo.status=info[2]
		table.insert(list,gameinfo)
	end
end


function User:updateCacheByUseInfo (model,uin)
	if uin ~= self.uin or model == nil then 
		logd(" -- don't update userCache --  "..uin , "UserCache" )
		return 
	end
	local filedname = {
	"nick",
	"gold",
	"diamond_amount",
	"win",
	"lose",
	"title",
	"sex",
	"portrait",
	"play_level",
	"is_friend",
	"play_times",
	"win_prob",
	"view_times",
	"win_times_streak",
	"win_times_spring",
	"max_history_multi_num",
	"career_win_score",
	"career_bomb_times",
	"career_win_gold",
	"match_level", --已没用
	"dan_grading",
	"star_number",
	"lottery_ticket",
	"match_max_level",
	"icon_frame",
	"season_sn",
	"icon_frame_id"
	}
	for k,v in pairs(filedname) do
		self[v] = model[v]
	end

	self.fucard_num = self.lottery_ticket

	self:updateNewUserMatchLevel(model.all_lv_info)
end

--是否是VIP用户
function User:isVip()
	if self.vip_days ~= nil and self.vip_days > 0 then
		return true
	else
		return false
	end
end

--是否已经隐身
function User:isHiding()
	if self:isVip() == true and self.hiding ~= nil and self.hiding == 1 then
		return true
	else
		return false
	end
end

--更新用户信息
function User:updateCacheByProfileChange(model)
	if model == nil or model.uin == nil or model.uin ~= self.uin then return end
	self.hiding = model.hiding
	if model.hiding == 0 then	--Cache.user 只存储用户本人自定义头像和昵称, 不存储隐身头像和昵称
		Cache.user.portrait = model.portrait
		Cache.user.nick = model.nick
	end
end

--更新美女信息
--[[
CheckBeautyStatusRsp
    optional int32 status = 1; // status
    optional int32 remain_times = 2; // 还剩下多少次申请机会，0的话代表没了
    optional string refuse_reason = 3; // 如果是被拒绝，这里是拒绝原因
    optional string pretty_image = 4;       // 艺术照
    optional string normal_image = 5;       // 实拍照
]]

--更新美女信息
function User:updateBeautyInfo(model)
	if model == nil then return end
	if model.status==3 then
		self.is_beauty=true
	else
		self.is_beauty=false
	end
	local fields = {"status", "remain_times", "refuse_reason", "pretty_image", "normal_image"}
	self.beauty_info = {}
	for k,v in pairs(fields) do
		self.beauty_info[v] = model[v]
	end
end

-- 更新推广配置
function User:updatePromotInfo(model)
	self.is_self_promoter = 0

	local fields = {"is_self_promoter", "daily_promo_reward_status", "promoter_code", "my_promoter_uin", "is_show_prom_reg_tab"}
	for i,v in ipairs(fields) do
		self[v] = model[v]
	end

	-- 推广配置
	self.promoteConfig = {}
	local promoteConfigFields = {"cost_to_promoter","reward_fir_level","reward_sec_level","reward_rate_fir_level","reward_rate_sec_level","banner_url","how_to_promoter_url"}
	if model.promoter_config then
		for i,v in ipairs(promoteConfigFields) do
			self.promoteConfig[v] = model.promoter_config[v]
		end	
	end
	-- 推广业绩 
  	local promoterPerformanceFields = {"fir_level_count","sec_level_count","reward_sum","valid_reward_sum"}
  	self.promoterPerformance = {}
  	if model.promoter_performance then
  		for i,v in ipairs(promoterPerformanceFields) do
  			self.promoterPerformance[v] = model.promoter_performance[v]
  		end
  	end
end

-- 更新新手礼包配置
function User:updateDailyRewardConfInfo(model)
	self.dailyRewardConfInfo = {}
    self.dailyRewardConfInfo.cumulate_login_reward = model.cumulate_login_reward
    self.cumulate_login_reward = model.cumulate_login_reward
	self.dailyRewardConfInfo.cumulate_login_count = model.cumulate_login_count
    self.dailyRewardConfInfo.currentObtained = false --当天是否有未领取的
    local reward_obtain_info = {}
    for i=1,7 do
        local status=string.sub(model.cumulate_login_reward,i,i)
        if status == "1" then
           self.dailyRewardConfInfo.currentObtained = true --当天是否有未领取的
        end
        table.insert(reward_obtain_info, status)
    end
    self.dailyRewardConfInfo.new_user_reward = {}
    for i=1,model.new_user_reward:len() do
    	local item = {}
        item.day_index = model.new_user_reward:get(i).day_index
        item.reward_type = model.new_user_reward:get(i).reward_type
        item.amount = model.new_user_reward:get(i).amount
        item.obtainStatus = reward_obtain_info[item.day_index]
        table.insert(self.dailyRewardConfInfo.new_user_reward,item)
	end
end

-- 更新新手礼包配置
function User:updateFirstRechargeInfo(model)
	loga("updateFirstRechargeInfo\n" .. pb.tostring(model))
	local firstChargeInfo = nil
	for i=1,model.reward_gift:len()  do
		if model.reward_gift:get(i).item_id	== "apl_discount_goods_recharge_6" then
			firstChargeInfo = model.reward_gift:get(i)
		end
	end
	if firstChargeInfo then
		self.firstChargeConfInfo = {}
		self.firstChargeConfInfo.item_id = firstChargeInfo.item_id
		self.firstChargeConfInfo.price = firstChargeInfo.price
		self.firstChargeConfInfo.hasEntryControl = true --首充礼包权限控制
		self.firstChargeConfInfo.reward_gift = {}
		for i=1,firstChargeInfo.reward_gift:len() do
			local item = {}
			item.name = firstChargeInfo.reward_gift:get(i).name
			item.desc = firstChargeInfo.reward_gift:get(i).desc
			item.num = firstChargeInfo.reward_gift:get(i).num
			item.icon_path = firstChargeInfo.reward_gift:get(i).icon_path
			item.type = firstChargeInfo.reward_gift:get(i).type
			table.insert(self.firstChargeConfInfo.reward_gift,item)
		end
	end
end

function User:getLoginTipPopValue()
	return cc.UserDefault:getInstance():getBoolForKey(SKEY.LOGIN_TIP_POP,false)
end

function User:updateLoginTipPopValue(flag)
	cc.UserDefault:getInstance():setBoolForKey(SKEY.LOGIN_TIP_POP, flag)
	cc.UserDefault:getInstance():flush()
	self.justloginSuccess = true
end

-- 保存破产补助的消息
function User:saveUserBankRuptInfo(model)
	self.newBankruptInfo = {}
	self.newBankruptInfo.uin = model.uin
	self.newBankruptInfo.count = model.count
	self.newBankruptInfo.give_gold = model.give_gold
    self.newBankruptInfo.content = model.content
    self.newBankruptInfo.total_count = model.total_count
    self.newBankruptInfo.hasRecieveBankruptMessage = true 
end

function User:updateBeautyInfoByJson(info)
	self.beauty_info = self.beauty_info or {}
	self.beauty_info.status = 1
	self.beauty_info.pretty_image = info.pretty_image
	self.beauty_info.normal_image = info.normal_image
end

function User:getBeautyInfo()
	return self.beauty_info
end

function User:updateUserDiamond(diamond)
    if diamond ~= nil then
        self.diamond = diamond
    end
end

function User:updateUserGold(gold)
    if gold ~= nil then
        self.gold = gold
    end
end

function User:getGiftCardSum()
	return self.gift_card_sum
end

function User:updateNewUserPlayTask( paras )
    self.app_new_user_play_task = self.app_new_user_play_task or {}
    if paras then
        self.app_new_user_play_task.status = paras.status
    end
end

-- 更新用户头像列表
function User:updateUserHeadBox(model)
	loga("updateUserHeadBox\n" .. pb.tostring(model))
	if model then
		self.userHeadBoxList = {}
		loga(model.icon_frame:len())
		for i=1,model.icon_frame:len() do
			local itemInfo = model.icon_frame:get(i)
			local item = {}
			item.id = itemInfo.id
			item.name = itemInfo.name
			item.path = itemInfo.path
			item.in_use = itemInfo.in_use
			item.red_dot = itemInfo.red_dot
			item.timestamp = itemInfo.timestamp
			table.insert(self.userHeadBoxList,item)
		end
	end
	dump(self.userHeadBoxList)
end

-- 更新用户红点信息
function User:updateUserRedInfo(model)
	if model then
		loga(model.red_dot_msg:len())
		for i=1,model.red_dot_msg:len() do
			local redInfo = model.red_dot_msg:get(i)
			if redInfo.red_dot_type == 11 then
                Cache.user.headBox_red_control = redInfo.is_show or 0
                Cache.user.headBox_red_show_amount = redInfo.show_amount or 0
            end
		end
	end
end

function User:updateNewUserMatchLevel( model )
    self.all_lv_info = {}

    local fields = {"match_lv", "sub_lv", "star", "sub_lv_star_num"}

    for i,v in ipairs(fields) do
		self.all_lv_info[v] = model[v]
    end

    self.ddz_match_level = self.all_lv_info.match_lv
end


return User