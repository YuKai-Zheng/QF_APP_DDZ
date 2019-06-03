local MatchingView = class("MatchingView", qf.view)

MatchingView.TAG = "MatchingView"
local MatchingRule = import(".components.MatchingRule")
local MatchingRank = import(".components.MatchingRank")
local MatchingDetail = import(".components.MatchingDetail")
local MeteorNode = import("..common.widget.MeteorNode")
local MatchAnimationNode = import("..game.components.animation.MatchAnimationNode")

local HallMenuComponent = import("src.modules.global.components.HallMenuComponent")

local GUIDE_ZORDER = 10

function MatchingView:ctor(parameters)
    MatchingView.super.ctor(self,parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
	self:initData()
	self:init()
    self:initClick()
	self:initHallView()
	self:initGuide()
    self:initSettle()
    self:initMenu()
end

function MatchingView:initWithRootFromJson( ... )
    return GameRes.matchingHallViewJson
end

function MatchingView:init()
	self.closeBtn = ccui.Helper:seekWidgetByName(self.root, "backAction")--关闭按钮
	self.fkBtn = ccui.Helper:seekWidgetByName(self.root, "focasP")--奖券购买按钮
	self.goldBtn = ccui.Helper:seekWidgetByName(self.root, "goldP")--金币购买按钮
	self.level = ccui.Helper:seekWidgetByName(self.root, "level")--当前等级
	self.startGameBtn = ccui.Helper:seekWidgetByName(self.root, "startGame")--开始比赛按钮
	self.duihuanBtn = ccui.Helper:seekWidgetByName(self.root,"duihuanBtn")--兑换按钮
	
    self.btn_bg = ccui.Helper:seekWidgetByName(self.root,"btn_bg")--左侧按钮容器
	self.ruleBtn = ccui.Helper:seekWidgetByName(self.root, "ruleBtn")--规则按钮
	self.rankBtn = ccui.Helper:seekWidgetByName(self.root, "rankBtn")--排行榜按钮

    self.panel_right = ccui.Helper:seekWidgetByName(self.root,"panel_right")--右侧容器
	
	self.lbl_time = ccui.Helper:seekWidgetByName(self.root,"lbl_time")--赛事时间
	self.bm_next_level = ccui.Helper:seekWidgetByName(self.root,"bm_next_level")--下个段位（右）
	self.bm_next_win_reward = ccui.Helper:seekWidgetByName(self.root,"bm_next_win_reward")--下个段位获胜奖励（右）
	self.one_game_reward = ccui.Helper:seekWidgetByName(self.root,"one_game_reward")--每局奖励气泡
	self.lbl_one_game_reward = ccui.Helper:seekWidgetByName(self.root,"lbl_one_game_reward")--每局奖励文字
	self.lbl_fee = ccui.Helper:seekWidgetByName(self.root,"lbl_fee")--报名费
	self.panel_detail = ccui.Helper:seekWidgetByName(self.root,"panel_detail")--细节面板点击容器
	self.img_season = ccui.Helper:seekWidgetByName(self.root,"img_season")--赛季图片

	self.one_game_reward:setVisible(false)
	self.lbl_next_level_left = ccui.Helper:seekWidgetByName(self.root,"lbl_next_level_left")--下个段位（左）
	self.lbl_next_reward_left = ccui.Helper:seekWidgetByName(self.root,"lbl_next_reward_left")--下个段位奖励（左）
	self.detailBtn = ccui.Helper:seekWidgetByName(self.root,"detailBtn")--问号按钮
	self.lbl_to_best_1 = ccui.Helper:seekWidgetByName(self.root,"lbl_to_best_1")
    self.lbl_to_best_2 = ccui.Helper:seekWidgetByName(self.root,"lbl_to_best_2")
    
    self.menu_panel = ccui.Helper:seekWidgetByName(self.root, "menu_panel")

    if FULLSCREENADAPTIVE then
        local bg_layer = ccui.Helper:seekWidgetByName(self.root, "upbg")
        bg_layer:setVisible(false)
        bg_layer:setContentSize(bg_layer:getContentSize().width+(self.winSize.width - 1920), bg_layer:getContentSize().height)
        bg_layer:setPositionX(bg_layer:getPositionX()-(self.winSize.width - 1920)/2)
        self.duihuanBtn:setPositionX(self.duihuanBtn:getPositionX()+(self.winSize.width - 1920) -10)
        self.btn_bg:setPositionX(self.btn_bg:getPositionX()-(self.winSize.width - 1920)/2)
        self.root:setPositionX((self.winSize.width - 1920)/2)

        self.menu_panel:setPositionX(self.menu_panel:getPositionX() - (self.winSize.width - 1920)/2)
    end
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW or not TB_MODULE_BIT.BOL_MODULE_BIT_EXCHANGE_FUCARD then
    	self.duihuanBtn:setVisible(false)
    	if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
	    	self.ruleBtn:setVisible(false)
	    	self.fkBtn:setVisible(false)
	    end
    end
    Util:registerKeyReleased({self = self,cb = function ()
        self:exitModel()
	end})

	self:addMeteorEffectToButton(self.startGameBtn)
end

--初始化数据
function MatchingView:initData()
	self.data = Cache.Config:getMatchHallInfo()
end

--开始匹配的触发
function MatchingView:clickStartAction()
    qf.platform:umengStatistics({umeng_key = "ToGameOnMatching"})--点击上报

		qf.platform:uploadEventStat({
			module = "performance",
			source = "pywxddz",
			event = STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_MATCH_CLICK_WAIT,
			value = 1,
			custom = self.data.match_level,
		});
		-- 牌桌检测
		qf.event:dispatchEvent(ET.ROOM_CHECK, {desk_mode = GAME_DDZ_NEWMATCH})
end

--初始化点击事件
function MatchingView:initClick( ... )
	self.fkBtn:setTouchEnabled(true)
	addButtonEvent(self.fkBtn, function( ... )
		qf.event:dispatchEvent(ET.SHOW_FOCASTASK_VIEW)
	end)
	self.goldBtn:setTouchEnabled(true)
	addButtonEvent(self.goldBtn, function( ... )
		qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD})
	end)
	addButtonEvent(self.closeBtn, function( ... )
		self:exitModel()
	end)
	addButtonEvent(self.duihuanBtn, function( ... )
        qf.event:dispatchEvent(ET.SHOW_EXCHANGEMALL_VIEW)
	end)
	addButtonEvent(self.startGameBtn, function( ... )
		self:clickStartAction()
	end)

    addButtonEvent(self.ruleBtn, function( ... )
        PopupManager:push({class = MatchingRule})
        PopupManager:pop()
	end)

	addButtonEvent(self.panel_detail, function( ... )
		local matchingDetail = MatchingDetail.new()

		if FULLSCREENADAPTIVE then
        	matchingDetail:setPositionX(matchingDetail:getPositionX()+(self.winSize.width - 1920)/2)
		end
     	self:addChild(matchingDetail,2)
	end)

	addButtonEvent(self.rankBtn, function( ... )
		GameNet:send({cmd=CMD.MATCH_RANK_REQ,callback=function(rsp) 
            Cache.Config:updateMatchRankInfo(rsp.model)
            PopupManager:push({class = MatchingRank})
            PopupManager:pop()
		end})
	end)
end

function MatchingView:updateUserInfo( ... )
	ccui.Helper:seekWidgetByName(self.fkBtn,"num"):setString(Cache.user.fucard_num)
    ccui.Helper:seekWidgetByName(self.goldBtn,"num"):setString(Util:getFormatString(Cache.user.gold))
    
    if isValid(self.menu) then
        self.menu:updateData()
    end
end

--显示当前等级
function MatchingView:initLevel( ... )
	if self.matchIcon then
		self.matchIcon:removeFromParent()
	end
	self.matchIcon = MatchAnimationNode.new()
	local size = self.level:getContentSize()
	self.matchIcon:setPosition(size.width/2, size.height/2 + 100)
	self.level:addChild(self.matchIcon)
	local cur_level_info = {
		match_lv = self.data.match_level,
		sub_lv = self.data.sub_level,
		star = self.data.star_number,
		sub_lv_star_num = self.data.star_max_number
	}
	local paras = {
		all_lv_info_now = cur_level_info,
		all_lv_info_bef = cur_level_info
	}
	self.matchIcon:startAnimation(paras)
end

function MatchingView:initHallView()
	self:initLevel()
	self:updateUserInfo()

	local level = self.data.match_level			-- 当前段位
	local app_info = self.data.app_info
	local max_level = app_info.season_max_lv	-- 赛季最高段位

	if level == 70 then
		-- 下一段位
		self.bm_next_level:setString(GameTxt.match_next_reward_highest_1)
		self.bm_next_win_reward:setString(GameTxt.match_next_reward_highest_2)
		ccui.Helper:seekWidgetByName(self.root, "icon_reward"):setVisible(false)
	else
		-- 下一段位
		self.bm_next_level:setString(string.format(GameTxt.match_next_level, GameTxt.match_level_desc[level+10]))
		-- 下段位每局奖励
		self.bm_next_win_reward:setString(string.format(GameTxt.match_next_reward, app_info.next_lv_award or 0))
	end

	if max_level == 70 then
		-- 下一段位（左）
		ccui.Helper:seekWidgetByName(self.root, "icon_reward_left"):setVisible(false)
		self.lbl_to_best_1:setString(string.format(GameTxt.match_next_level_hightest_1, app_info.king_rank))
		self.lbl_to_best_2:setString(GameTxt.match_next_level_hightest_2)
		self.lbl_to_best_1:setVisible(true)
		self.lbl_to_best_2:setVisible(true)

		self.detailBtn:setVisible(false)
		self.lbl_next_level_left:setVisible(false)
		self.lbl_next_reward_left:setVisible(false)
	else
		-- 下段位晋级奖励
		self.lbl_next_reward_left:setString("x" .. app_info.award_conf[max_level/10 + 1].coupon_num)
		-- 下一段位（左）
		self.lbl_next_level_left:setString(string.format(GameTxt.match_next_level_left, GameTxt.match_level_desc[max_level+10]))
	end

	-- 赛季时间
	self.lbl_time:setString(self.data.season_date_range)
	-- 报名费
	self.lbl_fee:setString(string.format(GameTxt.match_hall_fee, self.data.session_info[1].enter_fee))
	-- 当前每局奖励
	self.lbl_one_game_reward:setString(string.format(GameTxt.match_current_reward, app_info.cur_lv_award or 0))
	-- 调整气泡长度
	if self.lbl_one_game_reward:getContentSize().width > 330 then
		self.one_game_reward:setContentSize(self.lbl_one_game_reward:getContentSize().width+30, 103)
	end
	ccui.Helper:seekWidgetByName(self.root, "icon_reward_0"):setPositionX(269)
	-- 设置气泡是否显示
	self.one_game_reward:setVisible(app_info.is_pop_bubble)

    self.img_season:loadTexture(string.format(GameRes.matchingSImg, self.data.season_sn))
    
    
end

function MatchingView:initGuide()
	if self.data.guide_status == 1 then return end

	GameNet:send({cmd=CMD.MATCH_GUIDE_REQ,body={guide_type = 1,guide_status=1},callback=function(rsp) end})
	self.guide_layer_1 = ccui.Helper:seekWidgetByName(self.root,"guide_layer_1")
	self.img_guide_1 = ccui.Helper:seekWidgetByName(self.root,"img_guide_1")
	self.img_guide_2 = ccui.Helper:seekWidgetByName(self.root,"img_guide_2")
	self.guide_tip = ccui.Helper:seekWidgetByName(self.root,"guide_tip")
	self.guide_step = 1

	local armatureDataManager = ccs.ArmatureDataManager:getInstance()
	armatureDataManager:addArmatureFileInfo(GameRes.matchingGuideAnimation)

	function gotoNextStep()
		if self.guide_step == 1 then
			self.one_game_reward:setVisible(false)
			self.guide_tip:setVisible(true)
			self.guide_layer_1:setVisible(true)
			self.img_guide_1:setVisible(true)
			self.panel_right:setZOrder(GUIDE_ZORDER)
			self.startGameBtn:setTouchEnabled(false)
		elseif self.guide_step == 2 then
			self.img_guide_1:setVisible(false)
			self.img_guide_2:setVisible(true)
			self.panel_right:setZOrder(1)
			self.level:setZOrder(GUIDE_ZORDER)
		elseif self.guide_step == 3 then
			self.guide_layer_1:setOpacity(0)
			self.guide_tip:setVisible(false)
			self.img_guide_2:setVisible(false)
			self.level:setZOrder(1)
			self.panel_right:setZOrder(GUIDE_ZORDER)
			self.startGameBtn:setTouchEnabled(true)

			local size = cc.Director:getInstance():getWinSize()
			self.face1 = ccs.Armature:create("MatchGuideAnimation")
			self.face1:getAnimation():playWithIndex(0)
			self.face2 = ccs.Armature:create("MatchGuideAnimation")
			self.face2:getAnimation():playWithIndex(1)
			self.face1:setPosition(size.width/2,size.height/2)
			self.face2:setPosition(size.width/2,size.height/2)
			self.root:addChild(self.face1, GUIDE_ZORDER)
			self.root:addChild(self.face2, GUIDE_ZORDER)
			self.face1:setPositionX(self.face1:getPositionX()-(self.winSize.width - 1920)/2)
			self.face2:setPositionX(self.face2:getPositionX()-(self.winSize.width - 1920)/2)
		elseif self.guide_step == 4 then
			self.one_game_reward:setVisible(true)
			self.face1:removeFromParent()
			self.face2:removeFromParent()
			self.guide_layer_1:setVisible(false)
			self.panel_right:setZOrder(1)
		end
	end

	addButtonEvent(self.guide_layer_1, function( ... )
		self.guide_step = self.guide_step + 1
		gotoNextStep()
	end)

	gotoNextStep()
end

--开始按钮流光效果
function MatchingView:addMeteorEffectToButton(button)
	local armatureDataManager = ccs.ArmatureDataManager:getInstance()
	local size = button:getContentSize()
    armatureDataManager:addArmatureFileInfo(GameRes.matchingStartBtnAnimation)
    local face = ccs.Armature:create("MatchingStartBtn")
	face:setPosition(size.width/2-2,size.height/2-3)
	
	face:getAnimation():playWithIndex(0)
	button:addChild(face, 0)
end

function MatchingView:initSettle()
	self:delayRun(1, function()
		if self.data.settle_info.season_sn ~= 0 then
			qf.event:dispatchEvent(ET.CMD_SHOW_MATCH_REPORT)
		end
	end)
end

function MatchingView:delayRun(time, cb)
    if time == nil or cb == nil then return end
    self:runAction(
        cc.Sequence:create(cc.DelayTime:create(time), 
            cc.CallFunc:create(function()
                cb()
            end)
        ))
end

function MatchingView:updateView()
	self:initData()
	self:initLevel()
	self:initHallView()
	self:initSettle()
	self:initGuide()
end

function MatchingView:exitModel()
	self.root:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,0)))
	self.level:setVisible(false)
    self:runAction(cc.Sequence:create(
        cc.FadeTo:create(0.2,0),
        cc.CallFunc:create(function ( sender )
            Cache.user:updateLoginTipPopValue(true)
            self:ReturnMainView()
       end)))
    ModuleManager.gameshall:show()
end

function MatchingView:ReturnMainView( ... )
    qf.event:dispatchEvent(ET.BG_CLOSE)
	qf.event:dispatchEvent(ET.MAIN_MOUDLE_VIEW_EXIT,{name="matching",from= self.from and self.from.name or ""})
    ModuleManager.gameshall:getView():enterMainView(false)
	ModuleManager.gameshall:noAddNewPopup()
    ModuleManager.gameshall:showReturnHallAni()
    qf.platform:umengStatistics({umeng_key = "GameToHall"})--点击上报
end

function MatchingView:getRoot()
    return LayerManager.Matching
end

function MatchingView:initMenu(  )
    self.menu = HallMenuComponent.new({
        return_cb = function (  )
            self:exitModel()
        end,
        title = {img = GameRes.matchingTitle}
    })
    self.menu_panel:addChild(self.menu)
    self.menu:setPositionY(-self.menu:getContentSize().height)

    self.menu:startAnimation()
end

return MatchingView