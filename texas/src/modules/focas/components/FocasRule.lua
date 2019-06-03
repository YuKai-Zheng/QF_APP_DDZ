local FocasRule = class("FocasRule",CommonWidget.BasicWindow)
FocasRule.TAG = "FocasRule"

function FocasRule:ctor(paras)
    FocasRule.super.ctor(self, paras)
    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
        bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
    end
end

function FocasRule:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.FocasRuleJson)
    self.titleTxt = ccui.Helper:seekWidgetByName(self.gui,"title_txt")--标题
    self.titleTxt:setString("福利规则")
    self.ruleP = ccui.Helper:seekWidgetByName(self.gui,"Panel_duo_bao")--规则层
    self.ruleP:setVisible(true)
    self.exchangeP = ccui.Helper:seekWidgetByName(self.gui,"Panel_dui_huan")--规则层
    self.exchangeP:setVisible(false)
    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"Image_close")
    self.scrollview = ccui.Helper:seekWidgetByName(self.gui,"rulelist")
    local contentLabel = cc.LabelTTF:create(GameTxt.focas_rule,GameRes.font1,50,cc.size(1200,0))
    contentLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    contentLabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    contentLabel:setAnchorPoint(0.5,1.0)
    contentLabel:setColor(cc.c3b(150,86,19))
    self.scrollview:setInnerContainerSize(cc.size(self.scrollview:getInnerContainerSize().width,contentLabel:getContentSize().height))
    self.scrollview:addChild(contentLabel)

    contentLabel:setPosition(self.scrollview:getInnerContainerSize().width/2,self.scrollview:getInnerContainerSize().height)
end

function FocasRule:initClick( ... )
    addButtonEvent(self.closeBtn, function( ... )
        self:close()
    end) 
end


function FocasRule:close() 
    if self.cb then
        self.cb()
    end

    FocasRule.super.close(self)
end
return FocasRule
