local M = class("TuiGuangMainView", CommonWidget.BasicWindow)

local shareFileName = "icon.jpg"

function M:ctor( paras )
    M.super.ctor(self, paras)
    self:updateView()
end

function M:init(  )

end

function M:initUI(  )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.tuiguangViewJson)

    self.btn_close = ccui.Helper:seekWidgetByName(self.gui,"btn_close")             --关闭按钮
    self.btn_rule = ccui.Helper:seekWidgetByName(self.gui, "btn_rule")              --规则按钮
    self.btn_friend = ccui.Helper:seekWidgetByName(self.gui, "btn_friend")          --好友信息
    self.friend_txt = self.btn_friend:getChildByName("txt")                         --好友数量

    self.img_redpack_bg = ccui.Helper:seekWidgetByName(self.gui, "img_redpack_bg")
    self.btn_invite = self.img_redpack_bg:getChildByName("btn_invite")              --邀请按钮
    self.txt_invite_rewardNum = self.img_redpack_bg:getChildByName("txt_num")       --每邀请一位红包金额
    
    self.img_bottom = ccui.Helper:seekWidgetByName(self.gui, "img_bottom")
    self.img_txt_tip = self.img_bottom:getChildByName("img_txt_tip")
    self.btn_withdraw = self.img_bottom:getChildByName("btn_withdraw")              --提现按钮
    self.txt_withdraw_num = self.img_bottom:getChildByName("txt_withdraw_num")      --可提现数量

    self.txt_activity_desc = ccui.Helper:seekWidgetByName(self.gui, "txt_activity_desc")

    self.listview = ccui.Helper:seekWidgetByName(self.gui, "listview")

    self.panel_item = ccui.Helper:seekWidgetByName(self.gui, "panel_item")

    self.listview:setItemModel(self.panel_item)
end

function M:initClick(  )
    addButtonEvent(self.btn_close, function (  )
        self:close()
    end)

    addButtonEvent(self.btn_friend, function (  )
        qf.event:dispatchEvent(ET.SHOW_TUIGUANG_FRIENDINFO_VIEW)
    end)

    addButtonEvent(self.btn_invite, function (  )
        self:share()
        qf.platform:uploadEventStat({
            module = "app_share",
            source = "appwxddz",
            event = STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_SHARE_BTN,
            value = 1,
        })
    end)

    addButtonEvent(self.btn_rule, function (  )
        qf.event:dispatchEvent(ET.SHOW_TUIGUAN_RULE_VIEW)
    end)

    addButtonEvent(self.btn_withdraw, function (  )
        qf.event:dispatchEvent(ET.SHOW_TUIGUANG_OFFICIAL_VIEW)
    end)
end

function M:updateView(  )
    local activityData = Cache.Config:getTuiGuangInfo()
    if not activityData then return end
    self.friend_txt:setString(activityData.invitedInfo.invited_count .. "人>>")
    self.txt_invite_rewardNum:setString(activityData.reward_per_user / 100)
    self.txt_withdraw_num:setString(string.format( GameTxt.string_yuan, activityData.invitedInfo.reward_num / 100))

    self.txt_activity_desc:setString(GameTxt.tuiguangActivity_desc[activityData.isFinishBonus])

    self:initListView(activityData.task_list)
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

        local txt_desc = ccui.Helper:seekWidgetByName(item, "txt_desc")
        local btn = item:getChildByName("btn")
        local img_txt = btn:getChildByName("img_txt")
        local img_finish = item:getChildByName("img_finish")
        local txt_num = ccui.Helper:seekWidgetByName(item, "txt_num")

        txt_num:setString(string.format( GameTxt.string_yuan, itemData.reward_num / 100))
        txt_desc:setString(itemData.task_desc .. "(".. itemData.task_process.. "/" .. itemData.task_require .. ")")

        if itemData.task_status == 0 then
            btn:setVisible(true)
            btn:loadTextureNormal(GameRes.btn_blue)
            img_txt:loadTexture(GameRes.tuiguangBtnTxt_go)
            img_finish:setVisible(false)
        elseif itemData.task_status == 1 then
            btn:setVisible(true)
            btn:loadTextureNormal(GameRes.btn_red)
            img_txt:loadTexture(GameRes.tuiguangBtnTxt_get)
            img_finish:setVisible(false)
        elseif itemData.task_status == 2 then
            btn:setVisible(false)
            img_finish:setVisible(true)
        end

        btn.data = itemData

        addButtonEvent(btn, function ( sender )
            if sender.data.task_status == 0 then
                self:share()
            elseif sender.data.task_status == 1 then
                qf.event:dispatchEvent(ET.TUIGUANG_REWARD_REQ, {task_id = sender.data.task_id})
            end
        end)
    end
end

function M:share(  )
    local shareInfo = Cache.Config:getTuiGuangInfo().share_info
    local url = HOST_SHARE_NAME.. "/" .. shareInfo.url .. "?uin=" .. Cache.user.uin
    local share_img_path = self:writeShareImgPath("icon.png", GameRes.share_icon)
    local info ={
        type = 3,
        share = 2,
        scene = 1,
        description = shareInfo.content,
        title = shareInfo.title,
        localPath = share_img_path,
        url = url,
        cb = function ()
            loga("分享")
        end
    }

    dump(info)
    qf.platform:sdkShare(info)
end

--写入图片到可读写目录
function M:writeShareImgPath(filename, share_img_path)
    local writpath = cc.FileUtils:getInstance():getWritablePath()..filename;
    if cc.FileUtils:getInstance():isFileExist(writpath) then
        return writpath
    else
        local srcData = cc.FileUtils:getInstance():getDataFromFile(share_img_path)
        local f = assert(io.open(writpath, "wb"))
        f:write(srcData)
        f:close()
        return writpath
    end
end

return M