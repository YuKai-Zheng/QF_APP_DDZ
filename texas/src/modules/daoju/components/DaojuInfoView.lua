local M = class("DaojuInfoView", CommonWidget.BasicWindow)

function M:ctor( paras)
    self.cb = paras.cb
    M.super.ctor(self, paras)
end

function M:initUI( paras )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.Daoju_detailJson)

    self.name = ccui.Helper:seekWidgetByName(self.gui, "name")
    self.daoju_desc = ccui.Helper:seekWidgetByName(self.gui, "daoju_desc")
    self.deadTime = ccui.Helper:seekWidgetByName(self.gui, "deadTime")
    self.daoju_icon = ccui.Helper:seekWidgetByName(self.gui, "daoju_icon")
    self.btnClose = ccui.Helper:seekWidgetByName(self.gui, "btn_daojuclose")
    self.deadTime:setVisible(false)

    self.daoju_icon:loadTexture(GameRes.tool_icon_loadding)
    
    loga("========DaojuInfoView================")
    dump(paras)
    self.daojuData = paras.data

    if self.daojuData.type == 3 then -- 记牌器
        self.daoju_icon:loadTexture(string.format(GameRes.rememberCardImg))
        self.name:setString(self.daojuData.alias)
        self.daoju_desc:setString(self.daojuData.desc)
    elseif self.daojuData.type == 11 or  self.daojuData.type == 6 then --保星卡和宝箱
        -- body
        self.name:setString(self.daojuData.alias)
        self.daoju_desc:setString(self.daojuData.desc)
        if self.daojuData.type == 11 then
            self.daoju_icon:loadTexture(string.format(GameRes.baoxingka))
        else
            self.daoju_icon:loadTexture(string.format(GameRes.baoxiang))
            self.name:setString(GameTxt.match_level_desc[self.daojuData.reward_box.match_box_lv] .. "宝箱")
            self.daoju_desc:setString(GameTxt.match_level_desc[self.daojuData.reward_box.match_box_lv] .. "宝箱")
            self.deadTime:setString(self.daojuData.reward_box.expire_date)
            self.deadTime:setVisible(true)
        end
    elseif self.daojuData.type == 4 then --等级卡
        local level = self.daojuData.level_card
        local nowLevel = math.ceil(level/10)
        self.daoju_icon:loadTexture(string.format(GameRes.levelCardImg,nowLevel))
        self.name:setString(Cache.user.ddz_match_config.detail[level].title.."卡")
        self.daoju_desc:setString(self.daojuData.descsc)
    elseif self.daojuData.type == 9 then --超级加倍卡
        self.daoju_icon:loadTexture(GameRes.super_multi_card)
        self.name:setString(self.daojuData.alias)
        self.daoju_desc:setString(self.daojuData.desc)
    elseif self.daojuData.type == 5 then
        self.name:setString(self.daojuData.name)
        self.daoju_desc:setString(self.daojuData.desc)
        local  urlStr = self:getChanceCardUrl(v.item_id)
        local taskID = qf.downloader:execute(urlStr, 10,
            function(path)
                if isValid( self.daoju_icon ) then
                        self.daoju_icon:loadTexture(path)
                end
                end,
                function()
                end,
                function()
                end
        )
    end

    -- if self._data.pic_path and self._data.pic_path ~= "" then
    --     local taskID = qf.downloader:execute(self._data.pic_path, 10,
    --         function(path)
    --             if isValid( self.img_item ) then
    --                     self.img_item:loadTexture(path)
    --             end
    --             end,
    --             function()
    --             end,
    --             function()
    --             end
    --     )
    -- else
    --     local imgPath = GameRes.rememberCardImg

    --     if self._data.name == "super_multi_card" then
    --         imgPath = GameRes.super_multi_card
    --     end

    --     self.img_item:loadTexture(imgPath)
    -- end

    
end

function M:getChanceCardUrl(item_id)
    local urlStr = ""
    for i=1,#Cache.Config.chance_card_url_list do
        if Cache.Config.chance_card_url_list[i].item_id == item_id then
            urlStr = Cache.Config.chance_card_url_list[i].url
        end
    end
    return urlStr
end

function M:initClick(  )
    addButtonEvent(self.btnClose, function (  )
        if self.cb then self.cb() end
        self:close()
    end)

    addButtonEvent(self.gui, function (  )
    end)
end

return M