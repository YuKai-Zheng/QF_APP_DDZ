local Config = class("Config")

Config.DDZ_room = {}           --炸金花房间配置

Config.DDZ_room_arr = {}       --炸金花房间配置

function Config:ctor ()
    
end

function Config:saveConfig(model)
	self.DDZ_room       = {}
	self.DDZ_room_arr   = {}
	self.DDZ_room.cur_totle_online = 0
	for i=1,model.room:len() do
		local item = model.room:get(i)
		self.DDZ_room[item.room_level] = {}
		self.DDZ_room[item.room_level].room_level = item.room_level    	 --房间等级 1新手 2初级 3普通 4中级 5高级 6顶级
		self.DDZ_room[item.room_level].room_group = item.room_level	   	 --房间等级 1新手 2初级 3普通 4中级 5高级 6顶级
		self.DDZ_room[item.room_level].room_name = DDZ_TXT.game_name[item.room_level]
		self.DDZ_room[item.room_level].room_id 	 = item.room_id     	 --id
		self.DDZ_room[item.room_level].base_chip = item.base_score       --底分
		self.DDZ_room[item.room_level].cap_score = item.cap_score        --封顶分数

		--为了不改，直接用level
		self.DDZ_room[item.room_level].cur_online = item.cur_online    	 --当前在线人数
		self.DDZ_room[item.room_level].disable    = 0  	 --是否可用，目前没有值，默认就是打开
		self.DDZ_room[item.room_level].room_type  = item.play_mode       --1经典场 2.癞子玩法 3.不洗牌玩法
		self.DDZ_room[item.room_level].play_mode  = item.play_mode       --1经典场 2.癞子玩法 3.不洗牌玩法
		self.DDZ_room[item.room_level].seat_limit = item.seat_limit      --几人桌
		self.DDZ_room[item.room_level].enter_limit = item.enter_limit    --进入房间最下金币携带
		self.DDZ_room[item.room_level].enter_limit_low = item.carry_min  --最小携带
		self.DDZ_room[item.room_level].enter_limit_high = item.carry_limit --最大携带
		self.DDZ_room[item.room_level].carry_desc = item.carry_desc    --带入限制描述
		self.DDZ_room[item.room_level].enter_fee = item.enter_fee      --服务费

		--这个不知道是啥
		-- self.DDZ_room[item.room_level].payment_recommend = item.payment_recommend

		self.DDZ_room.cur_totle_online = self.DDZ_room.cur_totle_online + item.cur_online
		
		local tmp             = {}
		tmp.room_name         = DDZ_TXT.game_name[item.room_level]
		tmp.room_id 	 	  = item.room_id
		tmp.base_chip         = item.base_score
		tmp.cap_score 		  = item.cap_score
		tmp.enter_limit 	  = item.enter_limit
		tmp.enter_limit_low   = item.carry_min
		tmp.enter_limit_high  = item.carry_limit
		tmp.cur_online 		  = item.cur_online
		tmp.room_level        = item.room_level
		tmp.seat_limit        = item.seat_limit
		tmp.disable           = 0
		tmp.room_group        = item.room_level
		tmp.room_type 		  = item.play_mode
		tmp.play_mode         = item.play_mode
		tmp.enter_fee 		  = item.enter_fee
		tmp.carry_desc 		  = item.carry_desc
		table.insert( self.DDZ_room_arr, tmp )
	end
  
	--好友房
	self.friend_room_id = model.friend_room_id
end

-- # 斗地主房间类型
-- GAME_DDZ_CLASSIC = 1 --斗地主经典场
-- GAME_DDZ_FRIEND = 2 --斗地主好友房
-- GAME_DDZ_MATCH = 3 --斗地主比赛场
-- GAME_DDZ_ENDGAME = 4 --斗地主残局

--根据房间类型获取roomConfig
function Config:getRoomConfigByType(roomType)
	local roomConfigInfo = {}
	for k,roomInfo in pairs(self.DDZ_room_arr) do
		if roomInfo.room_type == roomType or (roomType == 1 and roomInfo.room_type == 3)  then
			table.insert(roomConfigInfo, roomInfo)
		end
	end
	if #roomConfigInfo > 1 then
		table.sort(roomConfigInfo,function( a,b )
			return a.room_level < b.room_level
		end)
	end
	return roomConfigInfo
end

--根据房间id获取Config
function Config:getRoomConfigByRoomId(roomid)
	local roomConfigInfo = {}
	for k,roomInfo in pairs(self.DDZ_room_arr) do
		if roomInfo.room_id == roomid then
			table.insert(roomConfigInfo, roomInfo)
		end
	end
	return roomConfigInfo[1]
end

function Config:getTypeByRoomId(roomid)
	local roomType = GAME_DDZ_CLASSIC
    --比赛场
    if roomid/10000 == 2 then
        roomType = GAME_DDZ_MATCH
    elseif roomid/10000 == 3 then
        roomType = GAME_DDZ_ENDGAME
    elseif  roomid == Cache.DDZconfig.friend_room_id then
        roomType = GAME_DDZ_FRIEND
    end
    return roomType
end

return Config