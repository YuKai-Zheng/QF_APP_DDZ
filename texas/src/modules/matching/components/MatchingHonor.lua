local MatchingHonor = class("matchingHonor", CommonWidget.BasicWindow)
MatchingHonor.TAG = "matchingHonor"

local UserHead = import("...change_userinfo.components.userHead")--我的头像
local MatchAnimationNode = import("...game.components.animation.MatchAnimationNode")
local InviteView = import("src.modules.share.components.Invite")

function MatchingHonor:ctor(paras)
    MatchingHonor.super.ctor(self, paras)

    if paras and paras.cb then
        self.cb=paras.cb
    end
end

function MatchingHonor:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.matchingHonor)

    self.data = Cache.Config:getMatchHallInfo()
    self.settle_info = self.data.settle_info

	self.title = ccui.Helper:seekWidgetByName(self.gui,"title")--标题
	self.panel_level = ccui.Helper:seekWidgetByName(self.gui,"panel_level")--段位动画容器
	self.panel_honer = ccui.Helper:seekWidgetByName(self.gui,"panel_honer")--奖励界面容器
	self.panel_new_season = ccui.Helper:seekWidgetByName(self.gui,"panel_new_season")--新赛季界面容器
	self.btn_confirm = ccui.Helper:seekWidgetByName(self.gui,"btn_confirm")--确定
	self.btn_showoff = ccui.Helper:seekWidgetByName(self.gui,"btn_showoff")--取消
	self.btn_start = ccui.Helper:seekWidgetByName(self.gui,"btn_start")--开始游戏
    self.btn_close = ccui.Helper:seekWidgetByName(self.gui,"btn_close")--关闭
    self.avatar_frame = ccui.Helper:seekWidgetByName(self.gui,"avatar_frame")
    
    self.matchIcon = MatchAnimationNode.new()
	local size = self.panel_level:getContentSize()
	self.matchIcon:setPosition(size.width/2, size.height/2)
    self.panel_level:addChild(self.matchIcon)

    self.cur_level_info = {
		match_lv = self.data.match_level,
		sub_lv = self.data.sub_level,
		star = self.data.star_number,
		sub_lv_star_num = self.data.star_max_number
    }

    self:updateView(0)
end

function MatchingHonor:updateView(status)
    -- 页面状态  0-奖励界面  1-炫耀界面  2-新赛季开启界面
    if status == 0 then
        self:initHonorView()
    elseif status == 1 then
        self:initShareView()
    elseif status == 2 then
        self:initNewSeasonView()
    end
end

function MatchingHonor:initHonorView()
    self.panel_honer:setVisible(true)
    self.panel_new_season:setVisible(false)
    self.avatar_frame:setVisible(false)

    self.beat_num = ccui.Helper:seekWidgetByName(self.gui,"beat_num")
    self.beat_num_bg = ccui.Helper:seekWidgetByName(self.gui,"beat_num_bg")
    self.item = ccui.Helper:seekWidgetByName(self.gui,"item")
    self.panel_item = ccui.Helper:seekWidgetByName(self.gui,"panel_item")
    self.item:setVisible(false)

    self.title:setString(string.format(GameTxt.match_honor_title_1, self.settle_info.season_sn, GameTxt.match_level_desc[self.data.match_level]..GameTxt.match_sub_level_desc[self.data.sub_level]))

    -- self.settle_info.season_award = {
    --     {award_type=1,award_num=20}
    -- }
	local paras = {
		all_lv_info_now = self.cur_level_info,
		all_lv_info_bef = self.cur_level_info
	}
    self.matchIcon:startAnimation(paras)

    if self.settle_info.defeat_num == -1 or self.settle_info.defeat_num == 0 then
        self.beat_num:setString(string.format(string.format(GameTxt.match_honor_share, self.data.season_sn, self.data.season_date_range)))
    else
        self.beat_num:setString(string.format(GameTxt.match_honor_beat, self.settle_info.defeat_num))
    end

    if self.beat_num:getContentSize().width > 680 then
        self.beat_num_bg:setContentSize(self.beat_num:getContentSize().width+200, 123)
        self.beat_num:setPositionX(self.beat_num_bg:getContentSize().width / 2)
    end

    local item_num = 0
    for k,v in pairs(self.settle_info.season_award) do
        local item_data = v
        local item = self.item:clone()
        local icon = item:getChildByName("item_icon")
        local name = item:getChildByName("item_name")
        local num = item:getChildByName("item_num")

        if item_data.award_type == 1 then
            name:setString("保星卡")
            icon:loadTexture(GameRes.matchingHoner_item_1)
        elseif item_data.award_type == 2 then
            name:setString("头像框")
            icon:loadTexture(item_data.icon_frame_path)
        end
        num:setString("x" .. item_data.award_num)
        if #self.settle_info.season_award == 1 then
            item:setPosition(300,80)
        elseif #self.settle_info.season_award == 2 then
            item:setPosition(k*200,80)
        end
        if item_data.award_num ~= 0 then
            item:setVisible(true)
            self.panel_item:addChild(item)
            item_num = item_num + 1
        end
    end

    if item_num == 0 then
        ccui.Helper:seekWidgetByName(self.gui,"lbl_bag"):setVisible(false)
        ccui.Helper:seekWidgetByName(self.gui,"panel_item"):setVisible(false)
    end
end

function MatchingHonor:initShareView()
    local picName = "MatchHoner.png"
    
    local toSharefunc = function (fileName, shareType)
        PopupManager:push({class = InviteView, init_data = {
            type = 1,
            fileName =  Cache.user.uin  .. picName,
            shareType = 5,
            honorNode = self.gui
        }})
        PopupManager:pop()
    end
    toSharefunc()
end

function MatchingHonor:initNewSeasonView()
    self.avatar_frame:setVisible(false)
    self.beat_num_bg:setVisible(false)
    
    -- 暂时写死为重置到青铜III
    local paras = {
		all_lv_info_bef = self.cur_level_info,
		all_lv_info_now = {
            match_lv = 10,
            sub_lv = 3,
            star = 1,
            sub_lv_star_num = 3
        }
	}
    self.matchIcon:startAnimation(paras)
    self.title:setString(string.format(GameTxt.match_honor_title_2, self.settle_info.season_sn+1))
    self.beat_num_bg = ccui.Helper:seekWidgetByName(self.gui,"beat_num_bg")

    self.panel_honer:setVisible(false)
    self.panel_new_season:setVisible(true)
end

function MatchingHonor:initClick()
    addButtonEvent(self.btn_confirm, function()
        self:updateView(2)
    end)
    addButtonEvent(self.btn_showoff, function()
        self:updateView(1)
    end)
    addButtonEvent(self.btn_start, function()
        self:close()
        qf.platform:umengStatistics({umeng_key = "ToGameOnMatching"})--点击上报
		-- 牌桌检测
		qf.event:dispatchEvent(ET.ROOM_CHECK, {desk_mode = GAME_DDZ_NEWMATCH})
    end)
    addButtonEvent(self.btn_close, function()
        self:close()
    end)
end

function MatchingHonor:close()
    qf.event:dispatchEvent(ET.MATCH_VIEW_UPDATE)
    MatchingHonor.super.close(self)
end

return MatchingHonor