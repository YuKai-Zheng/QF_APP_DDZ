local ExchangeInfo = class("ExchangeInfo",CommonWidget.BasicWindow)
ExchangeInfo.TAG = "ExchangeInfo"
local  ExchangeTips = import(".ExchangeTips")
local  GetGoods = import(".GetGoods")
local  GuaguaCardSiteInfo = import(".GuaguaCardSiteInfo")

function ExchangeInfo:ctor(paras)
    ExchangeInfo.super.ctor(self, paras)
    self:initView()
    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
        bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
    end
end

function ExchangeInfo:init(paras)
    if paras and paras.cb then
        self.cb = paras.cb
    end
    if paras and paras.item_id then
        self.item_id = paras.item_id
    end
end

function ExchangeInfo:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.FocasRuleJson)
    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"Image_close")
    self.exchangeP = ccui.Helper:seekWidgetByName(self.gui,"Panel_dui_huan")--规则层
    self.sureBtn = ccui.Helper:seekWidgetByName(self.exchangeP,"exchangebtn")--确认按钮
    -- self.guaKa_listView = ccui.Helper:seekWidgetByName(self.exchangeP,"ListView_guaKaInfroduce")--刮卡列表
    self.jump_site_btn = ccui.Helper:seekWidgetByName(self.exchangeP,"jump_site_btn")--刮卡列表

    self.exchangeP:setVisible(true)
end
function ExchangeInfo:initView()
    self.msg = Cache.focasInfo:getWelFareDetailById(self.item_id);
    if self.msg.item_id ~= self.item_id then 
        self:close()
    end
    local taskID = qf.downloader:execute(self.msg.pic, 10,
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
    --Util:updateUserHead(ccui.Helper:seekWidgetByName(self.exchangeP,"Image_dui_huan"),self.msg.pic, 0, {nojpg = true, url=true})--物品图片
    local txt_gui_ze1 = ccui.Helper:seekWidgetByName(self.exchangeP,"txt_gui_ze1")
    txt_gui_ze1:setString(self.msg["name"])
    local txt_gui_ze2 = ccui.Helper:seekWidgetByName(self.exchangeP,"txt_gui_ze2")
    txt_gui_ze2:setString(self.msg["desc"])
    ccui.Helper:seekWidgetByName(self.exchangeP,"txt_sheng_yu2"):setString(self.msg["stock_now"])
    ccui.Helper:seekWidgetByName(self.exchangeP,"txt_dui_huan2"):setString(self.msg["today_buy"])
    ccui.Helper:seekWidgetByName(self.exchangeP,"txt_dui_huan3"):setString("/"..self.msg["bet_max"].."件")
    ccui.Helper:seekWidgetByName(self.exchangeP,"txt_dui_huan_num"):setString(Util:getFormatString(self.msg["bet_min"]))
    local txt_dui_huan1 = ccui.Helper:seekWidgetByName(self.exchangeP,"txt_dui_huan1")
    local txt_dui_huan2 = ccui.Helper:seekWidgetByName(self.exchangeP,"txt_dui_huan2")
    local txt_dui_huan3 = ccui.Helper:seekWidgetByName(self.exchangeP,"txt_dui_huan3")
    txt_dui_huan2:setPositionX(txt_dui_huan1:getContentSize().width+txt_dui_huan1:getPositionX())
    txt_dui_huan3:setPositionX(txt_dui_huan2:getContentSize().width+txt_dui_huan2:getPositionX())
    local txt_sheng_yu1 = ccui.Helper:seekWidgetByName(self.exchangeP,"txt_sheng_yu1")
    local txt_sheng_yu2 = ccui.Helper:seekWidgetByName(self.exchangeP,"txt_sheng_yu2")
    local txt_sheng_yu3 = ccui.Helper:seekWidgetByName(self.exchangeP,"txt_sheng_yu3")
    txt_sheng_yu2:setPositionX(txt_sheng_yu1:getContentSize().width+txt_sheng_yu1:getPositionX())
    txt_sheng_yu3:setPositionX(txt_sheng_yu2:getContentSize().width+txt_sheng_yu2:getPositionX())

    if self.msg.item_type == 5 then
        txt_gui_ze2:setVisible(false)
        self:setGuaKaListWithData()
        self.jump_site_btn:setVisible(false)
    else
        txt_gui_ze2:setVisible(true)
        self.jump_site_btn:setVisible(false)
    end
    
end
function ExchangeInfo:initClick()
    addButtonEvent(self.sureBtn, function( ... )
        if self.msg.bet_min > Cache.user.fucard_num then 
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.noFocasForExchangTips,time = 2})
            return
        end
        
        if self.msg.item_type == 2 or self.msg.item_type == 3 or self.msg.item_type == 6 or self.msg.item_type == 7 or self.msg.item_type == 8 then
            PopupManager:push({class = GetGoods, init_data = {item_type = self.msg.item_type,item_id = self.msg.item_id,name=self.msg.name,value=self.msg.bet_min,item_unique_id = nil,item_pic =self.msg.pic,cb=handler(self,self.close)}})
            PopupManager:pop()
        else
            PopupManager:push({class = ExchangeTips, init_data = {item_type=self.msg.item_type,name=self.msg.name,value=self.msg.bet_min,item_id=self.msg.item_id,item_pic =self.msg.pic,cb=handler(self,self.close)}})
            PopupManager:pop()
        end
    end) 
    addButtonEvent(self.gui, function( ... )
    end)   
    addButtonEvent(self.closeBtn, function( ... )
        -- body
        self:close()
    end) 

    addButtonEvent(self.jump_site_btn, function( ... )
        PopupManager:push({class = GuaguaCardSiteInfo})
        PopupManager:pop()
    end) 

    
end

function ExchangeInfo:checkSiteInfo() 
    -- body
    PopupManager.push({class = GuaguaCardSiteInfo})
    PopupManager:pop()
end
function ExchangeInfo:close() 
    if self.cb then
        self.cb()
    end

    ExchangeInfo.super.close(self)
end

function ExchangeInfo:setGuaKaListWithData() 
    local contentNode = self.exchangeP:getChildByName("desc_layer")
    CommonWidget.RichTextNode.new({
        node = contentNode,
        text = self.msg.desc,
        targetTxtValue = "<WebSite>",
        targetTxtColor = cc.c3b(255, 0, 0),
        targetFontSize = 40,
        normalColor = cc.c3b(180, 136, 107),
        normalFontSize = 40,
        cb = function ( ... )
            self:checkSiteInfo()
        end
    })
end
return ExchangeInfo
