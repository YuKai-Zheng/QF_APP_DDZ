local FocasInfo = class("FocasInfo")

FocasInfo.TAG = "FocasInfo"
FocasInfo.redPoint = 0
function FocasInfo:ctor() 
    self:init()
end

function FocasInfo:init() 

end

--保存福利夺宝及兑换列表
function FocasInfo:saveConfig(model)
	self.welfareDetail = {}
	self.indianaDetail = {}
	--测试数据end

	--夺宝及兑换列表

	self.userId = model.uin		--userId
	self.fucard_num = model.fucard_num --剩余副卡数量

	for i=1,model.detail:len() do
		local  data = model.detail:get(i)
		local info = {}
		info.name = data.name
		info.pic = data.pic
		info.desc = data.desc
		info.index = data.index
		info.item_id = data.item_id
		info.effective_time = data.effective_time
		info.bet_min = data.bet_min
		info.bet_max = data.bet_max
		info.stock_all = data.stock_all
		info.stock_now = data.stock_now
		info.today_buy = data.today_buy
		info.item_type = data.item_type
		table.insert(self.welfareDetail,info)
	end
	table.sort(self.welfareDetail, function(a, b)--排序
        return a.index < b.index
    end)
	for i=1,model.indiana_detail:len() do
		local data = model.indiana_detail:get(i)
		local info = {}
		info.name = data.name
		info.pic = data.pic
		info.desc = data.desc
		info.index = data.index
		info.item_id = data.item_id
		info.effective_time = data.effective_time
		info.type = data.type
		info.bet_min = data.bet_min
		info.bet_max = data.bet_max
		info.periods_all = data.periods_all
		info.periods_now = data.periods_now
		info.bet_times_now = data.bet_times_now
		info.status = data.status
		info.flag = data.flag
		info.open_time = data.open_time
		info.open_time_with_ms = math.ceil(socket.gettime()*100)
		info.item_unique_id = data.item_unique_id
		info.winner_nick=data.winner_nick
		info.winner_bet_times=data.winner_bet_times
		info.winner_lucky_num=data.winner_lucky_num
		info.winner_uin=data.winner_uin
		info.end_time = data.end_time
		info.my_lucky_num ={}
		for j=1 ,data.my_lucky_num:len() do
	        local data = data.my_lucky_num:get(j)
	        table.insert(info.my_lucky_num,tonumber(data.lucky_num))
	    end
	    table.sort(info.my_lucky_num, function(a, b)--排序
	        return a < b
	    end)
	    info.winner_pic = data.winner_pic
	    info.winner_sex = data.winner_sex
		table.insert(self.indianaDetail,info)
	end
	table.sort(self.indianaDetail, function(a, b)--排序
        return a.index < b.index
    end)

    dump(self.welfareDetail, "FocastUnfo")
    self:divWelFareDetail()
end

function FocasInfo:getWelFareDetailById(id)
    for k, v in pairs(self.welfareDetail) do
        if id == v.item_id then
            return v
        end
    end
    return {}
end

--区分兑换物品
function FocasInfo:divWelFareDetail()
    dump(1, "区分兑换物品")
    self.welfareDetailTypes = {}
    
    for k, v in pairs(self.welfareDetail) do
        if v.item_type == 1 or v.item_type == 9 then
            self.welfareDetailTypes.gold = true
            self.welfareDetailTypes.goldItem = self.welfareDetailTypes.goldItem or {}
            table.insert( self.welfareDetailTypes.goldItem, v )
        elseif v.item_type == 7 then
            self.welfareDetailTypes.rechargeCard = true
            self.welfareDetailTypes.rechargeCardItem = self.welfareDetailTypes.rechargeCardItem or {}
            table.insert( self.welfareDetailTypes.rechargeCardItem, v )
        elseif v.item_type == 6 then
            self.welfareDetailTypes.phone = true
            self.welfareDetailTypes.phoneItem = self.welfareDetailTypes.phoneItem or {}
            table.insert( self.welfareDetailTypes.phoneItem, v )
        elseif v.item_type == 8 then
            self.welfareDetailTypes.lifeGood = true
            self.welfareDetailTypes.lifeGoodItem = self.welfareDetailTypes.lifeGoodItem or {}
            table.insert( self.welfareDetailTypes.lifeGoodItem, v )
        elseif v.item_type == 5 then
            self.welfareDetailTypes.guaguaCard = true
            self.welfareDetailTypes.guaguaCardItem = self.welfareDetailTypes.guaguaCardItem or {}
            table.insert( self.welfareDetailTypes.guaguaCardItem, v )
        end
    end

    dump(self.welfareDetailTypes)
end

function FocasInfo:SaveHisIndianaRecord(model)--往期得主列表
	self.receive_record = {}
	for i=1 ,model.receive_record:len() do
        local data = model.receive_record:get(i)
        local info = {}
        info.periods_now = data.periods_now
        info.pic = data.pic
        info.winner_nick = data.winner_nick
        info.winner_bet_times = data.winner_bet_times
        info.open_time = data.open_time
        info.open_time_with_ms = math.ceil(socket.gettime()*100)
        info.winner_lucky_num = data.winner_lucky_num
        info.sex = data.sex
        table.insert(self.receive_record,info)
	end
end

function FocasInfo:SaveWelfareIndianaRecord( model )--夺宝记录与领奖记录
 loga("最新认证美女: \n"..pb.tostring(model))
	self.indiana_record = {}
	self.my_receive_record = {}--我的领奖记录
	for i=1 ,model.indiana_record:len() do
        local data = model.indiana_record:get(i)
        local info = {}
        info.name = data.name
		info.pic = HOST_PREFIX..HOST_NAME.."/media/"..data.pic
        info.desc = data.desc
        info.index = data.index
        info.item_id = data.item_id
        info.periods_now = data.periods_now
        info.bet_times_now = data.bet_times_now
        info.indiana_status = data.indiana_status
        info.open_time = data.open_time
        info.open_time_with_ms = math.ceil(socket.gettime()*100)
        info.winner_nick = data.winner_nick
        info.winner_bet_times = data.winner_bet_times
        info.winner_lucky_num = data.winner_lucky_num
        info.winner_uin = data.winner_uin
        info.my_bet_times = data.my_bet_times
	    info.my_lucky_num ={}
		for j=1 ,data.my_lucky_num:len() do
	        local data = data.my_lucky_num:get(j)
	        table.insert(info.my_lucky_num,tonumber(data.lucky_num))
	    end
	    table.sort(info.my_lucky_num, function(a, b)--排序
	        return a < b
	    end)
        info.winner_pic = data.winner_pic
        info.winner_sex = data.winner_sex
        info.index_id = i
        info.item_unique_id = data.item_unique_id
        table.insert(self.indiana_record,info)
	end
	table.sort(self.indiana_record, function(a, b)--排序
        return a.index_id > b.index_id
    end)

	for i=1 ,model.receive_record:len() do
        local data = model.receive_record:get(i)
        local info = {}
        info.name = data.name
        info.winner = data.winner
        info.receive_time = data.receive_time
        info.status = data.status
        table.insert(self.my_receive_record,info)
	end
	dump("111111111111111111111111111111111")
	dump(self.my_receive_record)
end

return FocasInfo