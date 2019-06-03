local MatchingDetail = class("MatchingDetail",function(paras) 
    return cc.Layer:create()
end)

MatchingDetail.TAG = "MatchingDetail"

function MatchingDetail:ctor(paras)
    --self.cb = paras.cb
    self:init()
end

function MatchingDetail:init()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.matchingDetail)
    self:addChild(self.root)

    self.data = Cache.Config:getMatchHallInfo().app_info
    self.list_info = self.data.award_conf

    self.item = ccui.Helper:seekWidgetByName(self.root,"item")
    self.list_view = ccui.Helper:seekWidgetByName(self.root,"list_view")
    self.list_view:setItemModel(self.item)
    self.item:setVisible(false)

    for i=2,#self.list_info do
        self.list_view:pushBackDefaultItem()
        local item = self.list_view:getItem(i-2)
        local item_level = item:getChildByName("item_level")
        local item_reward = item:getChildByName("item_reward")
        local item_status = item:getChildByName("item_status")
        local info = self.list_info[i]
        item_level:setString(GameTxt.match_level_desc[info.match_lv])
        item_reward:setString("x" .. info.coupon_num)
        if info.match_lv > self.data.season_max_lv then
            item_status:setString(GameTxt.match_reward_status_2)
        else
            item_status:setString(GameTxt.match_reward_status_1)
            item_status:setColor(cc.c3b(255,241,204))
        end
        item:setVisible(true)
    end
    addButtonEvent(self.root, function()
        self:close()
    end)
end

function MatchingDetail:close()
    self:removeFromParent()
 end

return MatchingDetail