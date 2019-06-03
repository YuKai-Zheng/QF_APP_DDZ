--
-- Author: Your Name
-- Date: 2018-07-17 15:53:53
--
local GuaguaCardInfo = class("GuaguaCardInfo",CommonWidget.BasicWindow)
GuaguaCardInfo.TAG = "GuaguaCardInfo"
local  GuaguaCardSiteInfo = import(".GuaguaCardSiteInfo")
function GuaguaCardInfo:ctor(paras)
    self.cb = paras.cb
    self.chanceParas = paras.detail
    GuaguaCardInfo.super.ctor(self, paras)
    self:getChanceInfo(paras)
    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
        bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
    end
end

function GuaguaCardInfo:getChanceInfo(paras)
   GameNet:send({cmd = CMD.GUAGUACARD_DETAIL_INFO_REQ,body={chance_card_name = self.chanceParas.name},callback=function(rsp)
        	if rsp.ret == 0 then
                self:reloadChanceCardWithData(rsp.model)
        	else
        		qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
        	end
    end})
end

function GuaguaCardInfo:init()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.GuaguaCardInfoJson)
    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"Image_close")
    self.exchangeP = ccui.Helper:seekWidgetByName(self.gui,"Panel_guaguaCard")
    self.checkSiteBtn = ccui.Helper:seekWidgetByName(self.exchangeP,"checkSite")--查看投注站按钮
    self.ListView_duihuan_introduce = ccui.Helper:seekWidgetByName(self.exchangeP,"ListView_duihuan_introduce")--兑换说明
    self.duihuancode_item = ccui.Helper:seekWidgetByName(self.exchangeP,"duihuancode_item")--兑换码列表item
    self.duihuancode_item_title = ccui.Helper:seekWidgetByName(self.exchangeP,"duihuancode_item_title")--兑换码列表item
    self.card_type_title = ccui.Helper:seekWidgetByName(self.exchangeP,"card_type_title")
    self.card_type_title:setString(self.chanceParas.name.."x"..self.chanceParas.amount)

    self.exchangeP:setVisible(true)
end
function GuaguaCardInfo:initUI()
	local  urlStr = self:getChanceCardUrl(self.chanceParas.item_id)
    local taskID = qf.downloader:execute(urlStr, 10,
        function(path)
            if not tolua.isnull( self ) then
                ccui.Helper:seekWidgetByName(self.exchangeP,"Image_dui_huan"):loadTexture(path)
            end
        end,
        function()
        end,
        function()
        end
    )
end

function GuaguaCardInfo:getChanceCardUrl(item_id)
    local urlStr = ""
    for i=1,#Cache.Config.chance_card_url_list do
        if Cache.Config.chance_card_url_list[i].item_id == item_id then
            urlStr = Cache.Config.chance_card_url_list[i].url
        end
    end
    return urlStr
end

function GuaguaCardInfo:initClick()
    addButtonEvent(self.checkSiteBtn, function( ... )
        PopupManager:push({class = GuaguaCardSiteInfo})
        PopupManager:pop()
    end)

    addButtonEvent(self.closeBtn, function( ... )
        -- body
        self:close()
    end) 
end
function GuaguaCardInfo:close()
    if self.cb then
        self.cb()
    end

    GuaguaCardInfo.super.close(self)
end

function GuaguaCardInfo:reloadChanceCardWithData(model)
	self.card_list = {}
	self.msg_desc = {}
	local len = model.card_list:len()
    for i=1, len do
		local cardInfo = model.card_list:get(i)
        local tempT = {}
		tempT.card_welfare_id = cardInfo.card_welfare_id
		tempT.effective_time  = cardInfo.effective_time 
		table.insert(self.card_list, tempT)
	end

	local len2 = model.desc:len()
    for i=1, len2 do
		local msg = model.desc:get(i)
		table.insert(self.msg_desc, msg)
	end  
    self:setGuaKaListWithData()
end

function GuaguaCardInfo:setGuaKaListWithData() 
    local node = cc.Node:create()
    self.ListView_duihuan_introduce:addChild(node)
    local  heightP = self.ListView_duihuan_introduce:getContentSize().height 
    local innerContentHeight = 0
    local  line_width= self.ListView_duihuan_introduce:getContentSize().width-20

    heightP = heightP - 30 
    innerContentHeight = innerContentHeight + 30
    local  line_width= self.ListView_duihuan_introduce:getContentSize().width-20
    local title_head = "我的兑换码"
    local contentLabel_head = cc.LabelTTF:create(title_head,GameRes.font1,36,cc.size(line_width,0))
    contentLabel_head:setAnchorPoint(cc.p(0,1))
    contentLabel_head:setColor( cc.c3b( 132, 88, 67 ) )
    contentLabel_head:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    contentLabel_head:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    contentLabel_head:setPosition( cc.p( 10,  heightP ) )
    heightP = heightP - contentLabel_head:getContentSize().height - 20 
    innerContentHeight = innerContentHeight + contentLabel_head:getContentSize().height + 20
    node:addChild(contentLabel_head)

    local item_head = self.duihuancode_item_title:clone()
    item_head:setVisible(true)
    
    item_head:setPosition(0 ,heightP)
    item_head:setAnchorPoint(cc.p(0,1))
    node:addChild(item_head) 
    heightP = heightP - item_head:getContentSize().height + 2 
    innerContentHeight = innerContentHeight + item_head:getContentSize().height - 2
    for i=1,#self.card_list do
            local item = self.duihuancode_item:clone()
            item:setVisible(true)
            
            item:setPosition(0 ,heightP)
            item:setAnchorPoint(cc.p(0,1))
            node:addChild(item) 
            heightP = heightP - item:getContentSize().height + 2 
            innerContentHeight = innerContentHeight + item:getContentSize().height - 2
            item:getChildByName("num"):setString(string.format("%03d", i))
            item:getChildByName("duihuancode"):setString(self.card_list[i].card_welfare_id)
            item:getChildByName("aviableTime"):setString(self.card_list[i].effective_time)   
    end
    
    heightP = heightP - 30 
    innerContentHeight = innerContentHeight + 30
    
    local title = "刮刮卡兑换说明："
    local contentLabel = cc.LabelTTF:create(title,GameRes.font1,36,cc.size(line_width,0))
    contentLabel:setAnchorPoint(cc.p(0,1))
    contentLabel:setColor( cc.c3b( 132, 88, 67 ) )
    contentLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    contentLabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    contentLabel:setPosition( cc.p( 10,  heightP ) )
    node:addChild(contentLabel)

    heightP = heightP - contentLabel:getContentSize().height - 20
    innerContentHeight = innerContentHeight + contentLabel:getContentSize().height + 20

    for i=1,#self.msg_desc do
        local title1 = self.msg_desc[i]
	    local contentLabel1 = cc.LabelTTF:create(title1,GameRes.font1,36,cc.size(line_width,0))
	    contentLabel1:setAnchorPoint(cc.p(0,1))
	    contentLabel1:setColor( cc.c3b( 180, 136, 107 ) )
	    contentLabel1:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	    contentLabel1:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	    contentLabel1:setPosition( cc.p( 10,  heightP ) )
	    heightP = heightP - contentLabel1:getContentSize().height - 5
        innerContentHeight = innerContentHeight + contentLabel1:getContentSize().height + 5
	    node:addChild(contentLabel1)   
    end

    if  innerContentHeight > self.ListView_duihuan_introduce:getContentSize().height then
    	self.ListView_duihuan_introduce:setInnerContainerSize(cc.size(self.ListView_duihuan_introduce:getContentSize().width,innerContentHeight))
        node:setPositionY(innerContentHeight-self.ListView_duihuan_introduce:getContentSize().height)
    else
        self.ListView_duihuan_introduce:setInnerContainerSize(cc.size(self.ListView_duihuan_introduce:getContentSize().width,innerContentHeight))
        node:setPositionY(0)
    end
end
return GuaguaCardInfo
