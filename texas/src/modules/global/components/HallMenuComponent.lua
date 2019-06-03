--大厅菜单栏
local M = class("HallMenuComponent", function (  )
    return ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.hall_menuJson)
end)

function M:ctor( paras )
    paras = paras or {}
    self:init(paras)
    self:initUI(paras)
    self:initClick()
    self:updateData()
end

function M:init( paras )
    self.return_cb = paras.return_cb
end

function M:initUI( paras )
    self.img_bg = self:getChildByName("img_bg")
    self.btn_return = self:getChildByName("btn_return")
    self.img_title = self:getChildByName("img_title")
    self.gold_layer = self:getChildByName("gold_layer")
    self.focas_layer = self:getChildByName("focas_layer")

    self.gold_num = self.gold_layer:getChildByName("gold_num")
    self.gold_add = self.gold_layer:getChildByName("btn_add")
    self.focas_num = self.focas_layer:getChildByName("focas_num")
    self.focas_add = self.focas_layer:getChildByName("btn_add")

    self.img_title:setVisible(false)

    if paras.title then
        self.img_title:loadTexture(paras.title.img, paras.title.type or ccui.TextureResType.localType)
    end

    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.gold_add:setVisible(false)
    end

    if paras.hideFocas or not TB_MODULE_BIT.BOL_MODULE_BIT_EXCHANGE_FUCARD then
        self:hideFocas()
    end

    if paras.hideGold then
        self:hideGold()
    end
end

function M:hideGold(  )
    self.gold_layer:setVisible(false)
    self.img_bg:setContentSize(cc.size(self.img_bg:getContentSize().width - 320, self.img_bg:getContentSize().height))

    self.focas_layer:setPositionX(self.gold_layer:getPositionX())
end

function M:hideFocas(  )
    self.focas_layer:setVisible(false)
    self.img_bg:setContentSize(cc.size(self.img_bg:getContentSize().width - 320, self.img_bg:getContentSize().height))
end

function M:initClick(  )
    addButtonEvent(self.btn_return, function (  )
        if self.return_cb then self.return_cb() end
    end)

    addButtonEvent(self.gold_layer, function (  )
        qf.platform:umengStatistics({umeng_key = "Shop"})
        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD})
    end)

    addButtonEvent(self.gold_add, function (  )
        qf.platform:umengStatistics({umeng_key = "Shop"})
        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD})
    end)

    addButtonEvent(self.focas_layer, function (  )
        qf.event:dispatchEvent(ET.SHOW_FOCASTASK_VIEW)
    end)

    addButtonEvent(self.focas_add, function (  )
        qf.event:dispatchEvent(ET.SHOW_FOCASTASK_VIEW)
    end)
end

function M:updateData(  )
    self.gold_num:setString(Util:getFormatString(Cache.user.gold))
    self.focas_num:setString(Cache.user.fucard_num)
end

function M:startAnimation(  )
    self.img_title:setVisible(true)
    self.img_title:setPositionY(200)

    self.img_title:runAction(cc.MoveTo:create(0.2, cc.p(self.img_title:getPositionX(), 100)))
end

return M