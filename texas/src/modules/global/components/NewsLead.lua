local NewsLead = class("NewsLead",function(paras) 
    return ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.NewsLeadJson)
end)
NewsLead.TAG = "NewsLead"



function NewsLead:ctor(paras)
    self:init(paras)
    self:initClick()
    self:initEffects()
end

function NewsLead:init(paras)
    
    self.closeP = ccui.Helper:seekWidgetByName(self,"closeP")
    self.playerImg= ccui.Helper:seekWidgetByName(self,"renwu")
    self.tipsBgImg= ccui.Helper:seekWidgetByName(self,"tipsbg")
    self.tipsImg= ccui.Helper:seekWidgetByName(self,"tips")
    self.quanImg= ccui.Helper:seekWidgetByName(self,"quan")
    self.prizeImg= ccui.Helper:seekWidgetByName(self,"prizeImg")

    if paras and paras.pos then
        local pos = paras.pos
        pos=cc.p(pos.x+42,pos.y+12)
        self.quanImg:setPosition(pos)
        self.quanImg:setScale(2.0)
        self.quanImg:setOpacity(0)

        self.prizeImg:setPosition(pos)
        self.prizeImg:setOpacity(0)

        self.tipsBgImg:setOpacity(0)
    end
end

function NewsLead:initEffects( ... )
    -- body
    self.playerImg:runAction(cc.EaseBackOut:create(cc.RotateTo:create(0.3,0)))
    self.prizeImg:runAction(cc.FadeIn:create(0.1))
    self.tipsBgImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.FadeIn:create(0.3)))
    self.quanImg:runAction(cc.Sequence:create(
        cc.Spawn:create(cc.ScaleTo:create(0.3,1),cc.FadeIn:create(0.3)),
        cc.CallFunc:create(function( ... )
            -- body
            self.quanImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.3,40)))
        end)))
end


function NewsLead:initClick( ... )
    -- body
    addButtonEvent(self.closeP,function (sender)
        qf.event:dispatchEvent(ET.REMOVE_NEWSLEAD)
    end)
end

return NewsLead
