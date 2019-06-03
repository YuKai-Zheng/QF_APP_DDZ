local NewFirstGame = class("newFirstGame", CommonWidget.BasicWindow)
NewFirstGame.TAG = "newFirstGame"

NewFirstGame.BACK_TO_CLOSE = false

function NewFirstGame:ctor(paras)
    NewFirstGame.super.ctor(self, paras)
    if paras and paras.cb then
        self.cb=paras.cb
    end
end

function NewFirstGame:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.newFirstGameJson)
    self.bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
    self.panel_items = ccui.Helper:seekWidgetByName(self.gui,"panel_items")
    self.item = ccui.Helper:seekWidgetByName(self.gui,"item")
    self.btn_reward = ccui.Helper:seekWidgetByName(self.gui,"btn_reward")

    local items = {}
    local goldNum = tonumber(Cache.user.gold)
    local focaNum = tonumber(Cache.user.fucard_num)
    local super_mulCardInfo = Cache.daojuInfo.super_mulCard or {}
    local cardRememberInfo = Cache.daojuInfo.cardRemember or {}
    local super_mulCardNum = 0
    local cardRememberNum = 0
    for i,v in pairs(super_mulCardInfo) do
        super_mulCardNum = super_mulCardNum + v.amount
    end
    for i,v in pairs(cardRememberInfo) do
        cardRememberNum = cardRememberNum + v.amount
    end

    if goldNum > 0 then
        local item1 = self.item:clone()
        item1:getChildByName("item_icon"):loadTexture(GameRes.newFirstGame_item4)
        item1:getChildByName("item_type"):setString("金币")
        item1:getChildByName("item_num"):setString("x"..goldNum)

        table.insert(items, item1)
    end
    if focaNum > 0 then
        local item2 = self.item:clone()
        item2:getChildByName("item_icon"):loadTexture(GameRes.newFirstGame_item3)
        item2:getChildByName("item_type"):setString("奖券")
        item2:getChildByName("item_num"):setString("x"..focaNum)

        table.insert(items, item2)
    end
    if super_mulCardNum > 0 then
        local item3 = self.item:clone()
        item3:getChildByName("item_icon"):loadTexture(GameRes.newFirstGame_item2)
        item3:getChildByName("item_type"):setString("超级加倍卡")
        item3:getChildByName("item_num"):setString("x"..super_mulCardNum)

        table.insert(items, item3)
    end
    if cardRememberNum > 0 then
        local item4 = self.item:clone()
        item4:getChildByName("item_icon"):loadTexture(GameRes.newFirstGame_item1)
        item4:getChildByName("item_type"):setString("记牌器")
        item4:getChildByName("item_num"):setString("x"..cardRememberNum)

        table.insert(items, item4)
    end

    self.item:setVisible(false)
    
    if #items == 1 then
        items[1]:setPositionX(280)
    elseif #items == 2 then
        items[1]:setPositionX(130)
        items[2]:setPositionX(430)
    elseif #items == 3 then
        items[1]:setPositionX(0)
        items[2]:setPositionX(280)
        items[3]:setPositionX(560)
    end

    for k, v in pairs(items) do
        self.panel_items:addChild(v)
    end
end

function NewFirstGame:initClick()
    addButtonEvent(self.btn_reward,function (sender)
        self:close()
        GameNet:send({cmd=CMD.APP_NEW_USER_GIFT,callback= function(rsp)
            if rsp.ret == 0 then
                if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击斗地主经典场快速开始") end
                -- GameNet:send({cmd=CMD.QUICK_START,body={play_mode=1},callback=function(rsp)
                --     local model = rsp.model
                --     if model then
                --         if model.room_id < 0 then
                --             qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[3]})
                --             if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
                --                 qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                --                     qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})--点击上报
                --                     qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
                --                 end})
                --             end
                --         else
                --             Cache.DDZDesk.enterRef = GAME_DDZ_CLASSIC
                --             qf.event:dispatchEvent(ET.ROOM_CHECK, {roomid = model.room_id, desk_mode = GAME_DDZ_CLASSIC})
                --             Cache.user.app_new_user_reg_gift_click_status = 2
                --             self:closeView()
                --         end
                --     else
                --         -- loga("快速开始获取失败！")
                --     end
                -- end})
                Cache.user.app_new_user_reg_gift_click_status = 2
                self:close()
            end
        end})
    end)
end

function NewFirstGame:closeView()
    self:close()
end

return NewFirstGame