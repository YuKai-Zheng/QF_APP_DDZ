local M = class("ShopToolDetailView", CommonWidget.BasicWindow)

function M:ctor( paras)
    self.cb = paras.cb
    M.super.ctor(self, paras)
end

function M:initUI(  )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.shopToolDetailJson)

    self.txt_item_name = ccui.Helper:seekWidgetByName(self.gui, "txt_item_name")
    self.txt_detail = ccui.Helper:seekWidgetByName(self.gui, "txt_detail")
    self.btn_buy = ccui.Helper:seekWidgetByName(self.gui, "btn_buy")
    self.txt_num = ccui.Helper:seekWidgetByName(self.btn_buy, "txt_num")
    self.img_item = ccui.Helper:seekWidgetByName(self.gui, "img_item")
    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui, "close")

    self.txt_item_name:setString(self._data.title)
    self.txt_num:setString(self._data.price)
    self.img_item:loadTexture(GameRes.tool_icon_loadding)

    if self._data.pic_path and self._data.pic_path ~= "" then
        local taskID = qf.downloader:execute(self._data.pic_path, 10,
            function(path)
                if isValid( self.img_item ) then
                        self.img_item:loadTexture(path)
                end
                end,
                function()
                end,
                function()
                end
        )
    else
        local imgPath = GameRes.rememberCardImg

        if self._data.name == "super_multi_card" then
            imgPath = GameRes.super_multi_card
        end

        self.img_item:loadTexture(imgPath)
    end

    
end

function M:initClick(  )
    addButtonEvent(self.btn_buy, function (  )
        if self.cb then self.cb() end
        self:close()
    end)

    addButtonEvent(self.gui, function (  )
    end)

    addButtonEvent(self.closeBtn, function ( )
        self:close()
    end)
end

return M