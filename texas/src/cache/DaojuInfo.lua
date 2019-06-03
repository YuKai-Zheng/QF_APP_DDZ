local DaojuInfo = class("DaojuInfo")

DaojuInfo.TAG = "DaojuInfo"

function DaojuInfo:ctor() 
    self:init()
end

function DaojuInfo:init() 
    self.exchangeList = {}
    self.exchangeList["item1"] = {}
    self.exchangeList["item1"].id = 1000
    self.exchangeList["item1"].name = "30元话费"
    self.exchangeList["item1"].fee_num= 30
    self.exchangeList["item1"].ticket=600

    self.exchangeList["item2"] = {}
    self.exchangeList["item2"].id = 1001
    self.exchangeList["item2"].name = "50元话费"
    self.exchangeList["item2"].fee_num= 50
    self.exchangeList["item2"].ticket= 1000
    
end

function DaojuInfo:saveLevelCardConfig(model)
    -- self.daojulist ={}
    self.levelCard = {}
    if not model then return end
    local len = model.props_infos:len()
    -- message PropsInfo{
    --     optional int32 props_type = 1;      // 道具类型 0 无效 1. 金币 2.奖券 3.记牌器 4.等级卡。 背包中只包含3.4类型
    --     optional int64 remain_counts = 2;   // 本类型的剩余数量
    --     optional string desc = 3;           // 使用说明
    --     optional int32 level_card = 4;      // 等级卡类型时必须填充.标识所在等级
    --     optional string get_way_desc = 5;   // 获得途径
    -- }
    for i=1, len do
        local daoju = model.props_infos:get(i)
        -- self.daojulist[i] = {}
        -- self.daojulist[i].name = "等级卡"
        -- self.daojulist[i].amount = daoju.remain_counts
        -- self.daojulist[i].type = daoju.props_type
        if daoju.props_type == 4 then --等级卡
            -- self.daojulist[i].item_id = daoju.item_id
            local card = {}
            card.type = daoju.props_type
            card.level_card = daoju.level_card
            card.amount = daoju.remain_counts
            card.get_way_desc = daoju.get_way_desc
            card.desc = daoju.desc
            table.insert(self.levelCard,card)   
        end    
    end
    table.sort(self.levelCard,function ( a,b )
        return a.level_card < b.level_card
    end)
end

function DaojuInfo:saveConfig(model)
    self.newToolsList = {}
	self.daojulist ={}
    self.chanceCard = {}
    self.cardRemember = {}
    self.super_mulCard = {}
    local len = model.items:len()
    for i=1, len do
		local daoju = model.items:get(i)
		self.daojulist[i] = {}
		self.daojulist[i].name = daoju.name
        self.daojulist[i].amount = daoju.amount
        self.daojulist[i].type = daoju.type
        self.daojulist[i].item_id = daoju.item_id

        if daoju.type == 11 or daoju.type == 6 then -- 11时为保星卡 6 时为宝箱
            local newToolsList = {}
            newToolsList.name = daoju.name 
            newToolsList.amount = daoju.amount
            newToolsList.type = daoju.type 
            newToolsList.prop_id = daoju.prop_id 
            newToolsList.alias = daoju.alias 
            newToolsList.expire_time = daoju.expire_time
            newToolsList.desc = daoju.desc
            
            if daoju.type == 6 then
                newToolsList.reward_box = {}
                newToolsList.reward_box.reward_box = daoju.reward_box.reward_box
                newToolsList.reward_box.box_fee_diamond = daoju.reward_box.box_fee_diamond
                newToolsList.reward_box.match_box_lv = daoju.reward_box.match_box_lv
                newToolsList.reward_box.expire_date = daoju.reward_box.expire_date
            end
            table.insert(self.newToolsList,newToolsList)
        end

        if daoju.type == 3 then
            local temp_cardRemember = {}
            temp_cardRemember.name = daoju.name 
            temp_cardRemember.amount = daoju.amount
            temp_cardRemember.type = daoju.type 
            temp_cardRemember.prop_id = daoju.prop_id 
            temp_cardRemember.alias = daoju.alias 
            temp_cardRemember.expire_time = daoju.expire_time
            temp_cardRemember.desc = daoju.desc
            table.insert(self.cardRemember,temp_cardRemember)
        end

        if daoju.type == 9 then --超级加倍卡
            local super_mulCard = {}
            super_mulCard.name = daoju.name 
            super_mulCard.amount = daoju.amount
            super_mulCard.type = daoju.type 
            super_mulCard.prop_id = daoju.prop_id 
            super_mulCard.alias = daoju.alias 
            super_mulCard.expire_time = daoju.expire_time
            super_mulCard.desc = daoju.desc
            table.insert(self.super_mulCard,super_mulCard)
        end

        if daoju.type == 5 then 
            local temp_chanceCard = {}
            temp_chanceCard.name = daoju.name 
            temp_chanceCard.amount = daoju.amount
            temp_chanceCard.type = daoju.type 
            temp_chanceCard.prop_id = daoju.prop_id 
            temp_chanceCard.alias = daoju.alias 
            temp_chanceCard.expire_time = daoju.expire_time
            temp_chanceCard.item_id = daoju.item_id
            temp_chanceCard.desc = daoju.desc
            if string.len(daoju.name) >= 5 then
               temp_chanceCard.money =  string.sub(daoju.name,1,string.len(daoju.name) - 4 )
            end
            table.insert(self.chanceCard,temp_chanceCard)
        end
        logd("cache daoju list :"..i)
	end

    self.card_remember_left_times = model.card_remember_left_times or 0
    self.card_remember_daily_left_times = model.card_remember_daily_left_times or 0
    self:saveLevelCardConfig(model)
end
return DaojuInfo