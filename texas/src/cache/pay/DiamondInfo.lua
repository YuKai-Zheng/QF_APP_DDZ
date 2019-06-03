--[[
    支付方式及钻石购买数据
]]
local DiamondInfo = class("DiamondInfo")

DiamondInfo.TAG = "DiamondInfo"

local DIAMOND = GameTxt.shop_currency_diamond
local GOLD = GameTxt.shop_currency_gold

DiamondInfo.cnApple = {}
DiamondInfo.cn_normal = {}

function DiamondInfo:ctor()
    
end

function DiamondInfo:initDiamondInfo()
    self:initcnNormal()
    self:initBuyGoldWithRMB()

    self:initDefaultGoodsInfoByChannel()
end
function DiamondInfo:initPayMethods()    
    self.paymethods_app = {}
    if Cache.PayManager.payMethods then
        self:updatePaymethods(Cache.PayManager.payMethods)
    elseif string.find(GAME_CHANNEL_NAME,"CN_IOS_APP")  ~= nil then
        self:init_paymethods_ios_app()
    else
        self:init_paymethods_android_app()
    end
end

function DiamondInfo:initDefaultGoodsInfoByChannel()
    self.allInfo = self.cn_normal
    if string.find(GAME_CHANNEL_NAME, "CN_IOS_APP") then
        self.allInfo = self.buyGoldWithRMG
    elseif string.find(GAME_CHANNEL_NAME, "CN_AD_APPWYDDZ")
    or string.find(GAME_CHANNEL_NAME, "CN_AD_OPPO1") then
        self.allInfo = self.cn_normal
    end
end

--获取钻石购买信息
function DiamondInfo:getDiamondInfo()
    return clone(self.allInfo)
end

--获取金币购买信息
function DiamondInfo:getBuyGoldInfo()
    return clone(self.buyGold)
end

--获取直接用RMB购买信息
function DiamondInfo:getBuyGoldWithRMBInfo()
    return clone(self.allInfo)
end

--用RMB直接买金币(android)
function DiamondInfo:initcnNormal()
    self.cn_normal = {}

    if string.find(GAME_CHANNEL_NAME, "CN_AD_OPPO1") then   --OPPO
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_OPPO, name_desc = "60000"..GOLD,hot = 0, proxy_item_id = "apl_rmb2gold_6_60000", item_id = "apl_rmb2gold_6_60000",cost = 6,  old_cost = 6, currency = "CNY", gold = 60000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_OPPO, name_desc = "60000"..GOLD,hot = 0, proxy_item_id = "apl_first_recharge_6", item_id = "apl_first_recharge_6",cost = 6,  old_cost = 6, currency = "CNY", gold = 60000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_OPPO, name_desc = "60000"..GOLD,hot = 0, proxy_item_id = "apl_discount_goods_recharge_6", item_id = "apl_discount_goods_recharge_6",cost = 6,  old_cost = 6, currency = "CNY", gold = 60000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_OPPO, name_desc = "120000"..GOLD,hot = 2, proxy_item_id = "apl_rmb2gold_12_120000", item_id = "apl_rmb2gold_12_120000",cost = 12, old_cost = 12, currency = "CNY", gold = 120000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_OPPO, name_desc = "260000"..GOLD,hot = 0, proxy_item_id = "apl_rmb2gold_25_260000", item_id = "apl_rmb2gold_25_260000",cost = 25, old_cost = 25, currency = "CNY", gold = 260000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_OPPO, name_desc = "550000"..GOLD,hot = 2, proxy_item_id = "apl_rmb2gold_50_550000", item_id = "apl_rmb2gold_50_550000",cost = 50, old_cost = 50, currency = "CNY", gold = 550000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_OPPO, name_desc = "1130000"..GOLD,hot = 2, proxy_item_id = "apl_rmb2gold_98_1130000", item_id = "apl_rmb2gold_98_1130000",cost = 98, old_cost = 98, currency = "CNY", gold = 1130000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_OPPO, name_desc = "2380000"..GOLD,hot = 0, proxy_item_id = "apl_rmb2gold_198_2380000", item_id = "apl_rmb2gold_198_2380000",cost = 198, old_cost = 198, currency = "CNY", gold = 2380000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_OPPO, name_desc = "4080000"..GOLD,hot = 0, proxy_item_id = "apl_rmb2gold_328_4080000", item_id = "apl_rmb2gold_328_4080000",cost = 328, old_cost = 328, currency = "CNY", gold = 4080000})
    else
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN, name_desc = "60000"..GOLD,hot = 0, proxy_item_id = "apl_rmb2gold_6_60000", item_id = "apl_rmb2gold_6_60000",cost = 6,  old_cost = 6, currency = "CNY", gold = 60000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN, name_desc = "60000"..GOLD,hot = 0, proxy_item_id = "apl_first_recharge_6", item_id = "apl_first_recharge_6",cost = 6,  old_cost = 6, currency = "CNY", gold = 60000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN, name_desc = "60000"..GOLD,hot = 0, proxy_item_id = "apl_discount_goods_recharge_6", item_id = "apl_discount_goods_recharge_6",cost = 6,  old_cost = 6, currency = "CNY", gold = 60000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN, name_desc = "120000"..GOLD,hot = 2, proxy_item_id = "apl_rmb2gold_12_120000", item_id = "apl_rmb2gold_12_120000",cost = 12, old_cost = 12, currency = "CNY", gold = 120000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN, name_desc = "260000"..GOLD,hot = 0, proxy_item_id = "apl_rmb2gold_25_260000", item_id = "apl_rmb2gold_25_260000",cost = 25, old_cost = 25, currency = "CNY", gold = 260000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN, name_desc = "550000"..GOLD,hot = 2, proxy_item_id = "apl_rmb2gold_50_550000", item_id = "apl_rmb2gold_50_550000",cost = 50, old_cost = 50, currency = "CNY", gold = 550000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN, name_desc = "1130000"..GOLD,hot = 2, proxy_item_id = "apl_rmb2gold_98_1130000", item_id = "apl_rmb2gold_98_1130000",cost = 98, old_cost = 98, currency = "CNY", gold = 1130000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN, name_desc = "2380000"..GOLD,hot = 0, proxy_item_id = "apl_rmb2gold_198_2380000", item_id = "apl_rmb2gold_198_2380000",cost = 198, old_cost = 198, currency = "CNY", gold = 2380000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_WINXIN, name_desc = "4080000"..GOLD,hot = 0, proxy_item_id = "apl_rmb2gold_328_4080000", item_id = "apl_rmb2gold_328_4080000",cost = 328, old_cost = 328, currency = "CNY", gold = 4080000})
    
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO, name_desc = "60000"..GOLD,hot = 0, proxy_item_id = "apl_rmb2gold_6_60000", item_id = "apl_rmb2gold_6_60000",cost = 6,  old_cost = 6, currency = "CNY", gold = 60000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO, name_desc = "60000"..GOLD,hot = 0, proxy_item_id = "apl_first_recharge_6", item_id = "apl_first_recharge_6",cost = 6,  old_cost = 6, currency = "CNY", gold = 60000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO, name_desc = "60000"..GOLD,hot = 0, proxy_item_id = "apl_discount_goods_recharge_6", item_id = "apl_discount_goods_recharge_6",cost = 6,  old_cost = 6, currency = "CNY", gold = 60000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO, name_desc = "120000"..GOLD,hot = 2, proxy_item_id = "apl_rmb2gold_12_120000", item_id = "apl_rmb2gold_12_120000",cost = 12, old_cost = 12, currency = "CNY", gold = 120000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO, name_desc = "260000"..GOLD,hot = 0, proxy_item_id = "apl_rmb2gold_25_260000", item_id = "apl_rmb2gold_25_260000",cost = 25, old_cost = 25, currency = "CNY", gold = 260000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO, name_desc = "550000"..GOLD,hot = 2, proxy_item_id = "apl_rmb2gold_50_550000", item_id = "apl_rmb2gold_50_550000",cost = 50, old_cost = 50, currency = "CNY", gold = 550000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO, name_desc = "1130000"..GOLD,hot = 2, proxy_item_id = "apl_rmb2gold_98_1130000", item_id = "apl_rmb2gold_98_1130000",cost = 98, old_cost = 98, currency = "CNY", gold = 1130000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO, name_desc = "2380000"..GOLD,hot = 0, proxy_item_id = "apl_rmb2gold_198_2380000", item_id = "apl_rmb2gold_198_2380000",cost = 198, old_cost = 198, currency = "CNY", gold = 238000})
        table.insert(self.cn_normal,{paymethod = PAYMETHOD_ZHIFUBAO, name_desc = "4080000"..GOLD,hot = 0, proxy_item_id = "apl_rmb2gold_328_4080000", item_id = "apl_rmb2gold_328_4080000",cost = 328, old_cost = 328, currency = "CNY", gold = 4080000})
    end
end

--用RMB直接买金币(ios)
function DiamondInfo:initBuyGoldWithRMB( ... )
    self.buyGoldWithRMG = {}
    local appstore_product_id = {}

    --各路马甲计费点配置, 按价格从高到低的顺序
    local IMP_PRODUCT_TAB = {
        --斗地主
        ["CN_IOS_APPDDZ"] = {
            "com.hyz.wyddz_6yuan_zs_v1",
            "com.hyz.wyddz_12yuan_zs_v1",
            "com.hyz.wyddz_25yuan_zs_v1",
            "com.hyz.wyddz_50yuan_zs_v1",
            "com.hyz.wyddz_98yuan_zs_v1",
            "com.hyz.wyddz_198yuan_zs_v1",
            "com.hyz.wyddz_328yuan_zs_v1"
        }
    }

    if IMP_PRODUCT_TAB[GAME_CHANNEL_NAME] then
        appstore_product_id = IMP_PRODUCT_TAB[GAME_CHANNEL_NAME]
    end

    table.insert(self.buyGoldWithRMG,{paymethod = PAYMETHOD_APPSTORE,name_desc = "60000"..GOLD, hot = 0, proxy_item_id = "apl_rmb2gold_6_60000",  item_id = appstore_product_id[1],  cost = 6,  old_cost = 6, currency = "CNY", gold = 60000} )
    table.insert(self.buyGoldWithRMG,{paymethod = PAYMETHOD_APPSTORE,name_desc = "60000"..GOLD, hot = 0, proxy_item_id = "apl_first_recharge_6",  item_id = appstore_product_id[1],  cost = 6,  old_cost = 6, currency = "CNY", gold = 60000} )
    table.insert(self.buyGoldWithRMG,{paymethod = PAYMETHOD_APPSTORE,name_desc = "60000"..GOLD, hot = 0, proxy_item_id = "apl_discount_goods_recharge_6",  item_id = appstore_product_id[1],  cost = 6,  old_cost = 6, currency = "CNY", gold = 60000} )
    table.insert(self.buyGoldWithRMG,{paymethod = PAYMETHOD_APPSTORE,name_desc = "120000"..GOLD, hot = 2, proxy_item_id = "apl_rmb2gold_12_120000",   item_id = appstore_product_id[2],   cost = 12,   old_cost = 12,   currency = "CNY", gold = 120000  } )
    table.insert(self.buyGoldWithRMG,{paymethod = PAYMETHOD_APPSTORE,name_desc = "260000"..GOLD, hot = 2, proxy_item_id = "apl_rmb2gold_25_260000",  item_id = appstore_product_id[3],  cost = 25,  old_cost = 25,  currency = "CNY", gold = 260000 } )
    table.insert(self.buyGoldWithRMG,{paymethod = PAYMETHOD_APPSTORE,name_desc = "550000"..GOLD, hot = 2, proxy_item_id = "apl_rmb2gold_50_550000",   item_id = appstore_product_id[4],   cost = 50,   old_cost = 50,   currency = "CNY", gold = 550000  } )
    table.insert(self.buyGoldWithRMG,{paymethod = PAYMETHOD_APPSTORE,name_desc = "1130000"..GOLD, hot = 2, proxy_item_id = "apl_rmb2gold_98_1130000",  item_id = appstore_product_id[5],  cost = 98,  old_cost = 98,  currency = "CNY", gold = 1130000 } )
    table.insert(self.buyGoldWithRMG,{paymethod = PAYMETHOD_APPSTORE,name_desc = "2380000"..GOLD, hot = 2, proxy_item_id = "apl_rmb2gold_198_2380000",   item_id = appstore_product_id[6],   cost = 198,   old_cost = 198,   currency = "CNY", gold = 2380000  } )
    table.insert(self.buyGoldWithRMG,{paymethod = PAYMETHOD_APPSTORE,name_desc = "4080000"..GOLD, hot = 2, proxy_item_id = "apl_rmb2gold_328_4080000",  item_id = appstore_product_id[7],  cost = 328,  old_cost = 328,  currency = "CNY", gold = 40800000 } )
end

--每个渠道的支付方式配置
function DiamondInfo:init_paymethods_ios_app()
    self.paymethods_app[1] = PAYMETHOD_APPSTORE

    if not TB_MODULE_BIT.BOL_MODULE_BIT_STORE then
        return
    end

    self.paymethods_app[2] = PAYMETHOD_ZHIFUBAO
    self.paymethods_app[3] = PAYMETHOD_WINXIN
end

function DiamondInfo:updatePaymethods( list )
    self.paymethods_app = {}
    local paymethods = string.split(list,"|")
    if string.find(GAME_CHANNEL_NAME, "CN_IOS_APP") then
        table.insert(self.paymethods_app,PAYMETHOD_APPSTORE)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_STORE then
            return
        end
        for k,v in pairs(paymethods)do
            if tonumber(v) == 1 then 
                table.insert(self.paymethods_app,PAYMETHOD_WINXIN)
            elseif tonumber(v)==2 then
                table.insert(self.paymethods_app,PAYMETHOD_ZHIFUBAO)
            end
        end
    elseif string.find(GAME_CHANNEL_NAME, "CN_AD_APPWYDDZ") then
        for k,v in pairs(paymethods)do
            if tonumber(v) == 1 then 
                table.insert(self.paymethods_app,PAYMETHOD_WINXIN)
            elseif tonumber(v)==2 then
                table.insert(self.paymethods_app,PAYMETHOD_ZHIFUBAO)
            end
        end
    else
        for k,v in pairs(paymethods)do
            if tonumber(v) == 1 then 
                table.insert(self.paymethods_app,PAYMETHOD_WINXIN)
            elseif tonumber(v)==2 then
                table.insert(self.paymethods_app,PAYMETHOD_ZHIFUBAO)
            elseif tonumber(v)==3 then
                table.insert(self.paymethods_app,PAYMETHOD_OPPO)
            end
        end
    end
end


--每个渠道的支付方式配置
function DiamondInfo:init_paymethods_android_app()
    if string.find(GAME_CHANNEL_NAME, "CN_AD_OPPO1") then
        self.paymethods_app[1] = PAYMETHOD_OPPO
    else
        self.paymethods_app[1] = PAYMETHOD_ZHIFUBAO
        self.paymethods_app[2] = PAYMETHOD_WINXIN
    end

end

function DiamondInfo:getPayMethods()
    local paymethods = {}
    paymethods = self.paymethods_app
    return clone(paymethods)
end


return DiamondInfo
