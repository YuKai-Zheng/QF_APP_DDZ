local ExchangeMallInfo = class("ExchangeMallInfo")

ExchangeMallInfo.TAG = "ExchangeMallInfo"
function ExchangeMallInfo:ctor()
    self:init()
end

function ExchangeMallInfo:init()
    
end

function ExchangeMallInfo:saveConfig(model)
    -- 兑换物品和分类 奖券兑换
    self.classifyList = {}
    local props1 = {"classify_id", "name", "goods", "icon", "tag"}
    for i=1,model.classify:len() do
        self.classifyList[i] = {}
        self:copyFiled(props1, model.classify:get(i), self.classifyList[i])

        self.classifyList[i].goods = {}
        for j=1, model.classify:get(i).goods:len() do
            self.classifyList[i].goods[j] = {}
            self:copyFiled({"goods_id", "name", "info", "icon", "desc", "need_addresses", "discount", "hot_tag", "stock_num", "daily_limit", "daily_exchange","is_shuffling"}, model.classify:get(i).goods:get(j), self.classifyList[i].goods[j])
            -- self:saveGoodsInfo(self.classifyList[i].goods[j].info, model.classify:get(i).goods:get(j).info)
            -- self.classifyList[i].goods[j].info = {}
            for k=1, model.classify:get(i).goods:get(j).info:len() do
                local t1 = self.classifyList[i].goods[j].info:get(k).estate_type
                local t2 = self.classifyList[i].goods[j].info:get(k).num
                self.classifyList[i].goods[j].info = {}
                self.classifyList[i].goods[j].info[k] = {}
                self.classifyList[i].goods[j].info[k].estate_type = t1
                self.classifyList[i].goods[j].info[k].num = t2
            end
        end
    end

    -- 用户身上的奖券信息
    self.user_estateList = {}
    local props2 = {"estate_type", "num"}
    for i=1,model.user_estate:len() do
        self.user_estateList[i] = {}
        self:copyFiled(props2, model.user_estate:get(i), self.user_estateList[i])
    end

    -- 用户地址
    self.address_info = {}
    local props3 = {"phone", "recipients", "address"}
    self:copyFiled(props3, model.info, self.address_info)
    Cache.user.real_name = self.address_info.recipients
    Cache.user.post_code = self.address_info.post_code
    Cache.user.address = self.address_info.address
    Cache.user.phone = self.address_info.phone
end

function ExchangeMallInfo:setUserInfo(model)
    self.userExchangeInfo = {}

    self:copyFiled({"phone", "recipients", "address"}, model.info, self.userExchangeInfo)
end

function ExchangeMallInfo:SaveWelfareIndianaRecord( model )--夺宝记录与领奖记录
       self.my_receive_record = {}--我的领奖记录

       for i=1 ,model.record:len() do
           local data = model.record:get(i)
           local info = {}
           info.name = data.name
           info.receive_time = data.time
           info.status = data.status
           table.insert(self.my_receive_record,info)
       end
   end

function ExchangeMallInfo:getUserInfo()
    return self.userExchangeInfo
end

function ExchangeMallInfo:getClassifyList()
    return self.classifyList
end

function ExchangeMallInfo:getUserEstateList()
    return self.user_estateList
end

function ExchangeMallInfo:getAddressInfo()
    return self.address_info
end

function ExchangeMallInfo:copyFiled(p,s,d)
    for k,v in pairs(p) do
        if type(v) == "table" then
            d[k] = {}
            self:copyFiled(v,s[k],d[k])
        else
            d[v] = s[v]
        end
    end
end

return ExchangeMallInfo