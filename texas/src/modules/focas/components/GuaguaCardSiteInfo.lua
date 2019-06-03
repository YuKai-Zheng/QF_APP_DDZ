--
-- Author: Your Name
-- Date: 2018-07-17 17:52:11
--
local GuaguaCardSiteInfo = class("GuaguaCardSiteInfo",CommonWidget.BasicWindow)
GuaguaCardSiteInfo.TAG = "GuaguaCardSiteInfo"
function GuaguaCardSiteInfo:ctor(paras)
    self.cb = paras.cb
    GuaguaCardSiteInfo.super.ctor(self, paras)
    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
        bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
    end
end

function GuaguaCardSiteInfo:init()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.GuaguaCardSiteInfoJson)
    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"Image_close")
    self.guaguaSiteP = ccui.Helper:seekWidgetByName(self.gui,"Panel_guaguaSite")
    self.sureBtn = ccui.Helper:seekWidgetByName(self.guaguaSiteP,"sureBtn")--查看投注站按钮
    self.ListView_site = ccui.Helper:seekWidgetByName(self.guaguaSiteP,"ListView_site")--兑换码列表
    self.site_item = ccui.Helper:seekWidgetByName(self.guaguaSiteP,"site_item")--兑换码列表item

    self.guaguaSiteP:setVisible(true)
    self:setGuaKaListWithData()
end
function GuaguaCardSiteInfo:initClick()
    addButtonEvent(self.sureBtn, function( ... )
        self:close()
    end) 
    addButtonEvent(self.closeBtn, function( ... )
        -- body
        self:close()
    end) 
end
function GuaguaCardSiteInfo:close()
    if self.cb then
        self.cb()
    end

    GuaguaCardSiteInfo.super.close(self)
end

function GuaguaCardSiteInfo:setGuaKaListWithData() 
    local node = cc.Node:create()
    self.ListView_site:addChild(node)
    local  heightP = 520 
    local innerContentHeight = 0

    for k,v in pairs(Cache.Config._chanceCard_siteList) do
			local item = self.site_item:clone()
            item:setVisible(true)
            item:setPosition(0 ,heightP)
            item:setAnchorPoint(cc.p(0,1))
            node:addChild(item) 
            heightP = heightP - item:getContentSize().height + 2 
            innerContentHeight = innerContentHeight + item:getContentSize().height - 2
            item:getChildByName("city"):setString(v.city)
            item:getChildByName("address"):setString(v.address)
            item:getChildByName("phoneNumber"):setString(v.phone)
	end
    
    if  innerContentHeight + 20 > self.ListView_site:getContentSize().height then
    	self.ListView_site:setInnerContainerSize(cc.size(self.ListView_site:getContentSize().width,innerContentHeight + 20 ))
        node:setPositionY(innerContentHeight-self.ListView_site:getContentSize().height + 20)
    else
        self.ListView_site:setInnerContainerSize(cc.size(self.ListView_site:getContentSize().width,innerContentHeight + 20 ))
        node:setPositionY(0)
    end
 
end
return GuaguaCardSiteInfo