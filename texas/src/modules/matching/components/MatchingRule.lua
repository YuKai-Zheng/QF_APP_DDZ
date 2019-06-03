local MatchingRule = class("MatchingRule", CommonWidget.BasicWindow)
MatchingRule.TAG = "MatchingRule"

function MatchingRule:ctor(paras)
    self.toolType = 1
    MatchingRule.super.ctor(self, paras)
    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
        bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
    end
    self:initRule()
end

function MatchingRule:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.MatchingRuleJson)
    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"closebtn")
    self.ruleScrollView = ccui.Helper:seekWidgetByName(self.gui,"ruleScrollView")
    self.gameRule = ccui.Helper:seekWidgetByName(self.ruleScrollView,"gameRule")

    self.tools_part = ccui.Helper:seekWidgetByName(self.gui,"tools_part")
    self.reward = ccui.Helper:seekWidgetByName(self.tools_part,"reward")
    self.playMethod = ccui.Helper:seekWidgetByName(self.tools_part,"playMethod")

end

function MatchingRule:initRule( ... )
    local kImgUrl = Cache.user.ddz_match_config.match_rule_path
    self:downLoadRule(kImgUrl)
end

function MatchingRule:downLoadRule(kImgUrl)
    local reg = qf.platform:getRegInfo()
    loga(kImgUrl)
    self.gameRule:setVisible(false)
    self.reward:setTouchEnabled(false)
    self.playMethod:setTouchEnabled(false)
    local taskID = qf.downloader:execute(kImgUrl, 10,
        function(path)
            if not tolua.isnull( self ) then
                self.gameRule:setVisible(true)
                self.reward:setTouchEnabled(true)
                self.playMethod:setTouchEnabled(true)
                self.gameRule:loadTexture(path)
                local size = self.gameRule:getContentSize()
                self.ruleScrollView:setInnerContainerSize(cc.size(self.ruleScrollView:getInnerContainerSize().width,size.height))
            end
        end,
        function()
        end,
        function()
        end
    )
end

function MatchingRule:initClick( ... )
    addButtonEvent(self.closeBtn, function( ... )
        self:close()
    end) 

    addButtonEvent(self.reward, function( ... )
        if self.toolType ~= 1 then
            self.toolType = 1
            self:toolsChoose()
        end
    end) 

    addButtonEvent(self.playMethod, function( ... )
        if self.toolType ~= 2 then
            self.toolType = 2
            self:toolsChoose()
        end
    end) 
end

function MatchingRule:toolsChoose(...) 

    self.reward = ccui.Helper:seekWidgetByName(self.tools_part,"reward")
    self.playMethod = ccui.Helper:seekWidgetByName(self.tools_part,"playMethod")
    
    if self.toolType == 1 then
        ccui.Helper:seekWidgetByName(self.reward,"btnReward"):setVisible(true)
        ccui.Helper:seekWidgetByName(self.reward,"btnReward_title"):loadTexture(GameRes.reward_title_selected)
        ccui.Helper:seekWidgetByName(self.playMethod,"btnPlayMethod"):setVisible(false)
        ccui.Helper:seekWidgetByName(self.playMethod,"btnPlayMethod_title"):loadTexture(GameRes.playMethod_title_normal)
        local kImgUrl = Cache.user.ddz_match_config.match_rule_path
        self:downLoadRule(kImgUrl)
    else
        ccui.Helper:seekWidgetByName(self.reward,"btnReward"):setVisible(false)
        ccui.Helper:seekWidgetByName(self.reward,"btnReward_title"):loadTexture(GameRes.reward_title_normal)
        ccui.Helper:seekWidgetByName(self.playMethod,"btnPlayMethod"):setVisible(true)
        ccui.Helper:seekWidgetByName(self.playMethod,"btnPlayMethod_title"):loadTexture(GameRes.playMethod_title_selected)
        local kImgUrl = Cache.user.ddz_match_config.match_desc_path
        self:downLoadRule(kImgUrl)
    end
end

return MatchingRule
