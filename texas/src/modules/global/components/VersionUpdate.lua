
local VersionUpdate = class("VersionUpdate", function(paras)
    return cc.Layer:create()
end)
VersionUpdate.TAG = "VersionUpdate"

function VersionUpdate:ctor(paras)
    self:init(paras)
    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.root,"bg")
        -- bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.root:setContentSize(self.winSize.width, self.winSize.height)
        -- self.root:setPositionX(-(self.winSize.width - 1980)/2)
    end
end

function VersionUpdate:init(paras)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.versionUpdate)
    self:addChild(self.root)
	self.btn_exit = ccui.Helper:seekWidgetByName(self.root,"btn_exit")
	self.btn_update = ccui.Helper:seekWidgetByName(self.root,"btn_update")
    local bg = ccui.Helper:seekWidgetByName(self.root,"bg")
    self.dec_bg = ccui.Helper:seekWidgetByName(self.root,"Image_3")
    self.decContent = self.dec_bg:getChildByName("content")
    self.descLb = self.decContent:getChildByName("desc")

    CommonWidget.RichTextNode.new({
        node = self.descLb,
        text = paras.desc and paras.desc or "",
        targetTxtValue = "<WebSite>",
        targetTxtColor = cc.c3b(255, 0, 0),
        targetFontSize = 38,
        normalColor = cc.c3b(180, 136, 107),
        normalFontSize = 38,
        cb = function ( ... )
            
        end,
        frameUpdateAction = function (height)
            self.decContent:setInnerContainerSize(cc.size(self.decContent:getContentSize().width,height))
            if height > self.decContent:getContentSize().height then
                self.descLb:setPositionY(self.decContent:getContentSize().height + height/2)
            else
                self.descLb:setPositionY(self.decContent:getContentSize().height)
            end
        end
    })

    -- 强制更新
    if paras.update_type and paras.update_type == 2 then
        self.btn_update:setPositionX(bg:getContentSize().width/2)
        self.btn_exit:setVisible(false)
    end
   
    addButtonEvent(self.btn_exit, function( ... )
        -- body
        self:close()
    end)    
    addButtonEvent(self.btn_update, function( ... )
        if paras.update_add then
            qf.platform:versionUpdate({url = paras.update_add})
        end
    end) 
end

function VersionUpdate:close() 
   self:removeFromParent()
end

return VersionUpdate
