--[[
    金币和道具信息的缓存.
    ----------------------------------------
    金币信息数据结构:
    {
        item_name: 商品的唯一标识，与服务器端对应
        price: 价格，需要多少钻石来兑换
        amount: 兑换金币的数量
        label: 热卖/促销标识. 参见 PAY_CONST 定义
        level: 等级，从1开始递增，金币数量越多level值越大
    }
    ----------------------------------------
    道具通用数据结构:
    {
        key: 道具类型. KEY_HORN/KEY_WEEK_CARD/..
        item_name: 商品的唯一标识，与服务器对应
        display_name: 显示的名字
        display_icon: 显示的图标
        other_props: 属性，每种道具有不一样的属性结构，见下面的描述
    }
]]

local ProductInfo = class("ProductInfo")

function ProductInfo:ctor()
    self.tools_info = {}
    self.gold_info = {} 
end

--道具信息初始化
function ProductInfo:initTools()
    self.tools_props = {}
    -- --礼物卡
    -- table.insert(self.tools_props, {
    --     key=KEY_GIFT_CARD,
    --     item_name="dm2prop_10w_gift_card",
    --     display_name=GameTxt.GiftCardShopName,
    --     display_icon=GameRes.shop_giftcard_icon,
    --     other_props={ description=string.format(GameTxt.giftcard_desc, 10) }
    -- })

end

--更新商品信息
function ProductInfo:updateProduct(item_list)
    self:initTools()
    self.gold_info = {}
    self.tools_info = {}
    self.foca_info = {}
    for i = 1, item_list:len() do
        local item = item_list:get(i)
        if item.type == PAY_CONST.ITEM_TYPE_GOLD then
            self:_updateGoldItem(item)
        elseif item.type == PAY_CONST.ITEM_TYPE_PROP then
            self:_updateToolsItem(item)
            self:_updateFocaItem(item)
        -- elseif item.type == PAY_CONST.ITEM_TYPE_FOCA then
        --     self:_updateFocaItem(item)
        end
    end

    --金币排序
    local sort_gold_asc = clone(self.gold_info)
    table.sort(sort_gold_asc, function(a, b)
        return a.amount < b.amount
    end)
    for k, v in pairs(sort_gold_asc) do
        for key, item in pairs(self.gold_info) do
            if item.item_name == v.item_name then
                item.level = k
            end
        end
    end
end

function ProductInfo:_updateToolsItem(item)
    --暂时只取用金币兑换的道具
    if item.currency ~= PAY_CONST.CURRENCY_GOLD then return end
    local toolItem = {}
    self:_updateProps({"name", "type", "currency", "price","amount","label","gift_id","add_count", "title", "is_show", "add_count64", "pop_desc", "pic_path", "item_info_desc"}, item, toolItem)
    table.insert( self.tools_info, toolItem )
    -- for k, v in pairs(self.tools_props) do
    --     if v.item_name == item.name then
    --         local t = clone(v)
    --         self:_updateProps({"currency", "price", "amount", "label","gift_id","is_show"}, item, t)
    --         table.insert(self.tools_info, t)
    --         break
    --     end
    -- end
end

function ProductInfo:_updateGoldItem(item)
    local t = {}
    self:_updateProps({"currency", "price", "amount", "label","gift_id","add_count","is_show"}, item, t)
    t.item_name = item.name
    table.insert(self.gold_info, t)
end

function ProductInfo:_updateFocaItem(item)
    local t = {}
    self:_updateProps({"currency", "price", "amount", "label","gift_id","add_count","type","title","is_show"}, item, t)
    t.item_name = item.name
    table.insert(self.foca_info, t)
end

function ProductInfo:_updateFocaInfo(model) 
    for i = 1, model.item_list:len() do
       local item = model.item_list:get(i)
       for k, v in pairs(self.foca_info) do
            if v.item_name == item.name then 
                self:_updateProps({"currency", "price","title"}, item, v)
            end
        end
    end
end

function ProductInfo:_updateProps(propsTable, src, dest)
    for k,v in pairs(propsTable) do
        dest[v] = src[v]
    end
end

function ProductInfo:getToolsInfo()
    return clone(self.tools_info)
end

function ProductInfo:getGoldInfo()
    return clone(self.gold_info)
end

function ProductInfo:getDisplayNameByItemId(item_name)
    local item = nil
    for k, v in pairs(self.gold_info) do
        if v.item_name == item_name then
            item = v
            break
        end
    end
    if item ~= nil then
        return tostring(item.amount)..GameTxt.gold_unit
    end

    for k, v in pairs(self.tools_info) do
        if v.item_name == item_name then
            item = v
            break
        end
    end


    for k, v in pairs(self.foca_info) do
        if v.item_name == item_name then
            item = v
            break
        end
    end

    if item ~= nil then
        return item.display_name
    end
end

function ProductInfo:getDisplayItemByItemName(item_name)
    local item = nil
    for k, v in pairs(self.gold_info) do
        if v.item_name == item_name then
            item = v
            break
        end
    end
    if item ~= nil then
        return item
    end

    for k, v in pairs(self.tools_info) do
        if v.item_name == item_name then
            item = v
            break
        end
    end
    if item ~= nil then
        return item
    end

    for k, v in pairs(self.foca_info) do
        if v.item_name == item_name then
            item = v
            break
        end
    end
    return item
end

return ProductInfo