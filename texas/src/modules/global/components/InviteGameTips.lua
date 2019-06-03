

local InviteGameTips = class("InviteGameTips",CommonWidget.BasicWindow)
InviteGameTips.tag = "InviteGameTips"


function InviteGameTips:ctor( paras )
    self.winSize = cc.Director:getInstance():getWinSize()
    InviteGameTips.super.ctor(self, paras)
end

function InviteGameTips:init( paras )
	-- body
	self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.inviteGameJson)
	self.refuse = ccui.Helper:seekWidgetByName(self.gui,"refuse")
	self.accept = ccui.Helper:seekWidgetByName(self.gui,"accept")
	self.close_btn = ccui.Helper:seekWidgetByName(self.gui,"close_btn")
    self.bg_panel = ccui.Helper:seekWidgetByName(self.gui,"bg_panel")

    self.accept_level = ccui.Helper:seekWidgetByName(self.gui,"levelDec")

    local maxLevel = Cache.user:getMaxLevel()
    local levelNum = Util:getLevelNum(Cache.user.all_lv_info.sub_lv)
    local level_title
    if Cache.user.all_lv_info.match_lv == maxLevel then 
        level_title = (Cache.user:getConfigByLevel(Cache.user.ddz_match_level).title)..GameTxt.matchingTitleWithPoint
    else
        level_title = Cache.user:getConfigByLevel(Cache.user.ddz_match_level).title .. levelNum .. GameTxt.matchingTitleWithPoint
    end
    self.accept_level:setString(level_title)
end

function InviteGameTips:initClick(  )
	
    addButtonEvent(self.refuse,function (sender)
        self:close()
        qf.event:dispatchEvent(ET.CHANGEREFUSE)
    end)
    addButtonEvent(self.accept,function (sender)
        qf.event:dispatchEvent(ET.ACCEPTINVITE)
        qf.platform:umengStatistics({umeng_key = "game_invite_accept"})
        self:close()
    end)
    addButtonEvent(self.close_btn,function (sender)
        self:close()
        qf.event:dispatchEvent(ET.CHANGEREFUSE)
    end)
    addButtonEvent(self.bg_panel,function (sender)
        self:close()
        qf.event:dispatchEvent(ET.CHANGEREFUSE)
    end)
end

function InviteGameTips:close()
    if self.cb then
        self.cb()
    end
    InviteGameTips.super.close(self)
end

return InviteGameTips