local M = class("TuiGuangFriendInfoView", CommonWidget.BasicWindow)

function M:ctor( paras )
    M.super.ctor(self, paras)
    self:initListView(self.data)
end

function M:init( paras )
    self.data = {}

    if paras and paras.model then
        for i = 1, paras.model.user_info:len() do
            local friend = {}
            friend.name = paras.model.user_info:get(i).name
            friend.created_date = paras.model.user_info:get(i).created_date
            friend.reward_num = paras.model.user_info:get(i).reward_num
            friend.reward_status = paras.model.user_info:get(i).reward_status

            table.insert( self.data,friend )
        end
    end
end

function M:initUI(  )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.tuiguangFriendInfoViewJson)

    self.btn_close = ccui.Helper:seekWidgetByName(self.gui,"btn_close")             --关闭按钮

    self.listview = ccui.Helper:seekWidgetByName(self.gui, "listview")

    self.panel_item = ccui.Helper:seekWidgetByName(self.gui, "panel_item")

    self.listview:setItemModel(self.panel_item)
end

function M:initClick(  )
    addButtonEvent(self.btn_close, function (  )
        self:close()
    end)
end

function M:initListView( data )
    if not data or #data <= 0 then
        self.listview:removeAllItems()
        return
    end

    if #self.listview:getItems() > #data then
        for i = 1, #self.listview:getItems() - #data do
            self.listview:removeLastItem()
        end
    end

    for i = 1, #data do
        local itemData = data[i]

        local item = self.listview:getItem(i - 1)

        if not isValid(item) then
            self.listview:pushBackDefaultItem()
            item = self.listview:getItem(i - 1)
            item:setVisible(true)
        end

        local img_line = item:getChildByName("img_line")
        local txt_name = item:getChildByName("txt_name")
        local txt_time = item:getChildByName("txt_time")
        local txt_reward = item:getChildByName("txt_reward")
        local txt_status = item:getChildByName("txt_status")

        if i == #data then
            img_line:setVisible(false)
        else
            img_line:setVisible(true)
        end

        txt_name:setString(itemData.name)
        txt_time:setString(itemData.created_date)
        txt_reward:setString(string.format( GameTxt.string_redpack,itemData.reward_num / 100))
        txt_status:setString(itemData.reward_status == 1 and GameTxt.redpack_success or GameTxt.redpack_fail)
    end
end

return M