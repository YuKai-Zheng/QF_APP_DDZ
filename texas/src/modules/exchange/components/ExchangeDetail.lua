-- 奖品详情
local ExchangeDetail = class("ExchangeDetail", CommonWidget.BasicWindow)
ExchangeDetail.TAG = "ExchangeDetail"

function ExchangeDetail:ctor(paras)
    ExchangeDetail.super.ctor(self, paras)
end

function ExchangeDetail:init(paras)
    self.data = paras.info
end

function ExchangeDetail:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.exchangeDetailJson)

    self.btn_close = ccui.Helper:seekWidgetByName(self.gui, "btn_close")           -- 关闭按钮
    self.btn_exchange = ccui.Helper:seekWidgetByName(self.gui, "btn_exchange")     -- 兑换按钮
    self.img_commodity = ccui.Helper:seekWidgetByName(self.gui, "img_commodity")   -- 商品图片
    self.item_name = ccui.Helper:seekWidgetByName(self.gui, "item_name")           -- 商品名称
    self.item_intro = ccui.Helper:seekWidgetByName(self.gui, "item_intro")         -- 商品介绍
    self.item_remain = ccui.Helper:seekWidgetByName(self.gui, "item_remain")       -- 库存
    self.item_exchangeable = ccui.Helper:seekWidgetByName(self.gui, "item_exchangeable")   -- 今日可兑换
    self.txt_price = ccui.Helper:seekWidgetByName(self.gui, "txt_price")           -- 商品价格

    -- 加载商品图片
    if self.data.icon and self.data.icon ~= "" then
        qf.downloader:execute(self.data.icon, 10,
            function(path)
                self.img_commodity:loadTexture(path)
            end,function() end,function() end
        )
    end

    self.item_name:setString(self.data.name)
    self.item_intro:setString(self.data.desc)
    self.item_remain:setString(string.format(GameTxt.exchangeMall_storage, self.data.stock_num))
    self.item_exchangeable:setString(string.format(GameTxt.exchangeMall_remain, self.data.daily_exchange, self.data.daily_limit))
    self.txt_price:setString(self.data.info[1].num)
end

function ExchangeDetail:initClick(paras)
    addButtonEvent(self.btn_close, function(sender)
        self:close()
    end)
    addButtonEvent(self.btn_exchange, function(sender)
        if Cache.user.fucard_num < self.data.info[1].num then  -- 奖券不足
            qf.event:dispatchEvent(ET.SHOW_EXCHANGESHORTAGE_DIALOG)
        else
            -- 0不需要填写任何信息 1 填写地址信息 2 填写电话号码
            if self.data.need_addresses == 0 then
                self:buyCommodityWithNoBB()
            else
                qf.event:dispatchEvent(ET.SHOW_GETGOODS_DIALOG, {
                    item_type = self.data.need_addresses,
                    item_id = self.data.goods_id,
                    name=self.data.name,
                    value=self.data.info[1].num,
                    item_unique_id = nil,
                    item_pic =self.data.icon,
                    cb=handler(self,self.exit)
                })
            end
        end
        self:close()
    end)
end

-- 直接购买
function ExchangeDetail:buyCommodityWithNoBB()
    local body = {
        num = 1,
        goods_id = self.data.goods_id
    }
    local itemName = self.data.name
    local itemPic = self.data.icon
    local itemNum = self.data.info[1].num
    GameNet:send({cmd = CMD.EXCHANGE_WELFARE,body=body,callback=function(rsp)
        if rsp.ret == 0 then
            local info = {}
            local showString = "恭喜您成功兑换" .. itemName
            info = {getRewardType = 2, rewardInfo = {"","","","","","",showString}, rewardInfoUrl = {"","","","","","",itemPic}}
            qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, info)
            self:close()
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
        end
    end})
end

return ExchangeDetail