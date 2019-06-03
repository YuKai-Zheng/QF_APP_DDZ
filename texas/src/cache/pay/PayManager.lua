--[[
    支付管理
]]
local PayManager = class("PayManager")

PayManager.TAG = "PayManager"

--支付方式
PAYMETHOD_TH_APPSTORE = 0
PAYMETHOD_APPSTORE = 501
PAYMETHOD_DUANXIN_YD = 41
PAYMETHOD_DUANXIN_LT = 28
PAYMETHOD_DUANXIN_DX_AIYOUXI = 11
PAYMETHOD_DUANXIN_DX_TIANYI = 3
PAYMETHOD_ZHIFUBAO = 39
PAYMETHOD_OPPO = 60
-- PAYMETHOD_ZHIFUBAO = 39
PAYMETHOD_BEE = 48

--ios屏蔽支付宝sdk支付
if  qf.device.platform == "ios" then
    PAYMETHOD_ZHIFUBAO=39
end
-- PAYMETHOD_WINXIN = 40
PAYMETHOD_WINXIN = 601  --微信换成官方支付
PAYMETHOD_BANK = 38
PAYMETHOD_QQ = 44
PAYMETHOD_SOUSUO = 39 --搜索现在支付宝
PAYMETHOD_HAIMA2 = 45 --海马IOS越狱支付2
PAYMETHOD_KUPAI2 = 46;   --//酷派支付
PAYMETHOD_EASY2PAY = 32
PAYMETHOD_CASHCARD = 33
PAYMETHOD_HAPPY_CASHCARD = 36
PAYMETHOD_TUREMONEY = 35
PAYMETHOD_POINTCARD = 34
PAYMETHOD_HUAWEI = 50

--道具id
-- KEY_HORN        = 1 -- 小喇叭

local DiamondInfo = import(".DiamondInfo")
local ProductInfo = import(".ProductInfo")

function PayManager:ctor(channel_name)
    self.diamond_info = DiamondInfo.new()
    self.product_info = ProductInfo.new()
end

function PayManager:initInfo(item_list) --此函数在登录成果后拉去服务器配置时调用
    self.channel_name = GAME_CHANNEL_NAME
	self.diamond_info:initDiamondInfo()
	self.diamond_info:initPayMethods()
    self.product_info:updateProduct(item_list)    --缓存用钻石/金币购买的商品信息
end

function PayManager:getPayGoldList()
    -- body
    local payGold = {"apl_diamond_12_188888","apl_diamond_68_888888"}
    return payGold
end

--获取所有支付方式
function PayManager:getPayMethods()
	return self.diamond_info:getPayMethods(self.channel_name)
end

--获取所有支付信息
function PayManager:getAllPayInfo()
    return self.diamond_info:getDiamondInfo()
end

--获取直接用RMB购买的金币的支付方式（传入item_name）
function PayManager:getPayMethodsByGoldItemName(goldItemName)
    local goldList = self.diamond_info:getBuyGoldWithRMBInfo()
    local paymethods = {}
    for i,v in ipairs(goldList) do
        if v.proxy_item_id == goldItemName then
            paymethods[#paymethods + 1] = v.paymethod
        end
    end
    return paymethods
end

--获取可以购买某一钻石数量的所有支付方式
function PayManager:getPayMethodsByGoldNum(diamond)
    local diamond_list = self.diamond_info:getBuyGoldInfo()
    local paymethods = {}
    for k, v in pairs(diamond_list) do
        if v.diamond == diamond then
            paymethods[#paymethods + 1] = v.paymethod
        end
    end
    return paymethods
end

--根据支付方式和钻石数量，获取支付信息
function PayManager:getPayInfoByGoldAndPaymethod(diamond, paymethod)
    local diamond_list = self.diamond_info:getBuyGoldInfo()
    local pay_info = {}
    for k, v in pairs(diamond_list) do
        if v.diamond == diamond and v.paymethod == paymethod then
            pay_info = clone(v)
            break
        end
    end
    return pay_info
end

--获取所有支付信息
function PayManager:getAllBuyGoldInfo()
    return self.diamond_info:getBuyGoldInfo()
end

--获取某一个支付方式对应的支付信息
function PayManager:getPayInfo(paymethod)
	local all_goldInfo = self.diamond_info:getDiamondInfo()
	local now_goldinfo = {}
	for k, v in pairs(all_goldInfo) do
        if  paymethod == v.paymethod  then
            table.insert(now_goldinfo,v)
        end
    end
    return now_goldinfo
end


--[[
    获取不重复的钻石信息列表
    钻石信息结构:
    {
        desc_name: 显示的商品名字
        diamond: 钻石数量
        cost: 价格
        level: 数量等级, 从1开始递增. 数量越多level值越大.
        hot: 热卖/促销标识, 参见 PAY_CONST 定义
    }
]]
function PayManager:getDiamondList()
    local diamond_info = self:getNoRepeatDiamondList()

    --钻石信息按从少到多排序
    local diamond_sort = clone(diamond_info)
    table.sort(diamond_sort, function(a, b)
        return a.diamond < b.diamond
    end)
    
    --记录钻石信息的等级
    local level = 1
    local ratio = 0--钻石兑换比例
    for k, v in pairs(diamond_sort) do
        if v.diamond/v.cost<ratio or ratio==0 then
            ratio=v.diamond/v.cost
        end
    end
    for k, v in pairs(diamond_sort) do
        
        for key, item in pairs(diamond_info) do
            item.ratio=ratio
            if item.diamond == v.diamond then
                item.level = level
                break
            end
        end
        level = level + 1
    end
    return diamond_info
end

--[[
    获取不重复的顺序的钻石信息列表
    钻石信息结构:
    {
        desc_name: 显示的商品名字
        diamond: 钻石数量
        cost: 价格
        level: 数量等级, 从1开始递增. 数量越多level值越大.
        hot: 热卖/促销标识, 参见 PAY_CONST 定义
    }
]]
function PayManager:getOrdinalDiamondList()
    local diamond_info = self:getNoRepeatDiamondList()

    --钻石信息按从少到多排序
    local diamond_sort = clone(diamond_info)
    table.sort(diamond_sort, function(a, b)
        return a.diamond < b.diamond
    end)
    
    --记录钻石信息的等级
    local level = 1
    local ratio = 0--钻石兑换比例
    for k, v in pairs(diamond_sort) do
        if  v.diamond/v.cost<ratio or ratio==0 then
            ratio=v.diamond/v.cost
        end
    end
    for k, v in pairs(diamond_sort) do
        v.ratio=ratio
        v.level = level
        level = level + 1
    end
    
    return diamond_sort
end

function PayManager:getNoRepeatDiamondList()
    local diamond_list = self.diamond_info:getDiamondInfo()
    local diamond_info = {}
    local function isExist(diamond_num)
        local exist = false
        for k, v in pairs(diamond_info) do
            if v.diamond == diamond_num then
                exist = true
                break
            end
        end
        return exist
    end
    
    --过滤重复的钻石信息
    for k, v in pairs(diamond_list) do
        if not isExist(v.diamond) then
            local item = {name_desc=v.name_desc, cost=v.cost, diamond=v.diamond, hot=v.hot}
            table.insert(diamond_info, item)
        end
    end

    return diamond_info
end

--获取可以购买某一钻石数量的所有支付方式
function PayManager:getPayMethodsByDiamondNum(diamond)
    local diamond_list = self.diamond_info:getDiamondInfo()
    local paymethods = {}
    for k, v in pairs(diamond_list) do
        if v.diamond == diamond then
            paymethods[#paymethods + 1] = v.paymethod
        end
    end
    return paymethods
end

--根据支付方式和钻石数量，获取支付信息
function PayManager:getPayInfoByDiamondAndPaymethod(diamond, paymethod)
    local diamond_list = self.diamond_info:getDiamondInfo()
    local pay_info = {}
    for k, v in pairs(diamond_list) do
        if v.diamond == diamond and v.paymethod == paymethod then
            pay_info = clone(v)
            break
        end
    end
    return pay_info
end

--根据支付方式和item_name，获取支付信息
function PayManager:getPayInfoByItemNameAndMethod(itemName, paymethod)
    local diamond_list = self.diamond_info:getBuyGoldWithRMBInfo()
    local pay_info = {}
    for k, v in pairs(diamond_list) do
        if v.proxy_item_id == itemName and v.paymethod == paymethod then
            pay_info = clone(v)
            break
        end
    end
    return pay_info
end

--根据支付方式获取支付信息（查询金币）
function PayManager:getPayInfoByPayMethod(paymethod)
    local gold_list = self.diamond_info:getBuyGoldWithRMBInfo()
    local pay_info = {}
    for k, v in pairs(gold_list) do
        if v.paymethod == paymethod then
            pay_info = clone(v)
            break
        end
    end
    return pay_info
end

--获取金币信息
function PayManager:getGoldInfo()
    local goldInfo = {}
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW or string.find(GAME_CHANNEL_NAME,"CN_IOS_APP")  ~= nil then --ios只有苹果支付
        local index = 1
        for i,j in pairs(self.diamond_info:getBuyGoldWithRMBInfo()) do
            for k,v in pairs(self.product_info:getGoldInfo()) do
                if v.item_name == j.proxy_item_id then
                    goldInfo[index] = v
                    index = index + 1
                    break
                end
            end
        end
    else
        goldInfo = self.product_info:getGoldInfo()
    end

    return goldInfo
end

-- 根据itemName获取金币信息
function PayManager:getGoldInfoByItemName(itemName)
    local goldInfo = {}
    local allGoldInfo = self:getGoldInfo()
    for k,v in pairs(allGoldInfo) do
        if v.item_name == itemName then
            goldInfo = clone(v)
            break
        end
    end
    return goldInfo
end

--获取全部道具信息
function PayManager:getToolsInfo()
    return self.product_info:getToolsInfo()
end

--获取指定的道具信息
function PayManager:getToolInfoByKey(key)
    local tools = self.product_info:getToolsInfo()
    for k, v in pairs(tools) do
        if v.key == key then
            return v
        end
    end
end

--根据商品(金币/道具)ID获取商品名字
function PayManager:getDisplayNameByItemId(item_id)
    return self.product_info:getDisplayNameByItemId(item_id)
end

--根据商品(金币/道具)ID获取商品信息
function PayManager:getDisplayItemInfoByItemId(item_id)
    return self.product_info:getDisplayItemByItemName(item_id)
end

--根据记牌器的商品信息
function PayManager:getCardRememberData()
    return self.product_info.foca_info
end

return PayManager