local ActivityView = class("ActivityView", CommonWidget.BasicWindow)
local InviteView = import(".components.SampleInviteView")
local NewUserDailyReward = import(".components.NewUserDailyReward")
local IButton = import(".components.IButton")

ActivityView.TAG = "ActivityView"

ActivityView.BNT_NUMBER_BG_TAG = 1101
ActivityView.BNT_NUMBER_NUMBER_TAG = 1102

--[[listview中的条目]]
ActivityView.item = {}
--[[listview中的按钮]]
ActivityView.btnList = {}
ActivityView.activityInfo = {}

function ActivityView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
	ActivityView.super.ctor(self,parameters)
	
	qf.platform:umengStatistics({umeng_key = "Event"})
end

function ActivityView:init(parameters)
    if parameters.cb then
        self.cb = paras.cb
    end
	self.nowIndex = 1
	self.bookmark = parameters.bookmark
	self.isInsertActivity = true
end

function ActivityView:initUI(  )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.activityViewNewJson)

    self:startAllTouch()
	local panel =  self.gui:getChildByName("activityPanel")
	self.listItem = panel:getChildByName("item")
	self.backBtn = panel:getChildByName("back_btn")
	self.listView = panel:getChildByName("activity_list")
	self.bg = self.gui:getChildByName("background")
	self.activityBg = ccui.Helper:seekWidgetByName(self.gui,"activityImg")
end

function ActivityView:enterCoustomFinish()
	qf.event:dispatchEvent(ET.NET_ALL_ACTIVITY_REQ) --活动列表
	qf.event:dispatchEvent(ET.EVENT_NEWUSER_LOGIN_REWARD_GET) 
end

function ActivityView:closeAllTouch()
	self.canTouch = false
end

function ActivityView:startAllTouch()
	self.canTouch = true
end

function ActivityView:webviewExit()
	qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
	self.webIsShowing = false
	qf.platform:removeWebView()
end

function ActivityView:showWebView (uu,ref) 
	local reg = qf.platform:getRegInfo()
	if ref==nil then
	  ref=UserActionPos.ACTIVITY_CENTER
	end
	self.url = HOST_PREFIX..HOST_NAME.."/"..uu.."?uin="..Cache.user.uin.."&key="..QNative:shareInstance():md5(Cache.user.key).."&channel="..reg.channel.."&version="..reg.version.."&ref="..ref
	loga("======activeWebViewUrl = "..self.url)
	self:_showWebView(self.url)
end

function ActivityView:_showWebView(url)
	self:closeAllTouch()
	self.webIsShowing = true
	local winsize = cc.Director:getInstance():getWinSize()
	local fsize = cc.Director:getInstance():getOpenGLView():getFrameSize()
	local w = winsize.width
	local h = fsize.height*winsize.width/fsize.width
	local x = 0
	local y = 0
	logd(" -- show webview url="..url,self.TAG)
	qf.platform:showWebView({url=url,x=x,y=y,w=w,h=h,
		cb=function ( paras )
			if paras == "start" then 
				qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=GameTxt.net005})
			else
				qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
			end
		end,
		cb2=function ( paras )
			logd("cb2   close webview",self.TAG)
			qf.event:dispatchEvent(ET.NET_ALL_ACTIVITY_REQ)
			self:webviewExit()
		end
	})
	self:delayRun(1,function()
		self:startAllTouch()
	end)
end

function ActivityView:gotoShopCb()
	self:_showWebView(self.url)
end

function ActivityView:refreshActivity(model)
	if Cache.ActivityTaskInfo.rewardList.all_activity == nil or #Cache.ActivityTaskInfo.rewardList.all_activity == 0 then return end
	local itemLen = #Cache.ActivityTaskInfo.rewardList.all_activity
	for index = 1, itemLen do
		local activitModel = self:getActivityModel(index)
		if activitModel.only_pop == 0 then
			local item = self.listView:getItem(index - 1)
			local btn = item:getChildByName("btn")
			local redNumer = btn:getChildByTag(self.BNT_NUMBER_BG_TAG)
			local can_pick = activitModel.can_pick
			if redNumer ~= nil and can_pick == 0 then 
				redNumer:setVisible(false)
			end
		end
	end
end

-- 加载活动图
function ActivityView:loadActiveImg()
	if self.inviteTask then 
		self.inviteTask:setVisible(false)
	end
	if self.inviteFinishInfo then
		self.inviteFinishInfo:setVisible(false)
	end

	local pannel = self.gui:getChildByName("activityPanel")
	pannel:getChildByName("activityImg_0"):setVisible(true)
	if self.activityBg then
		self.activityBg:setVisible(true)
	end

	local item = Cache.ActivityTaskInfo.rewardList.all_activity[self.nowIndex]
	local kImgUrl = item.board_url
	local reg = qf.platform:getRegInfo()
    
    self.newUerReward = ccui.Helper:seekWidgetByName(self.gui,"newUerReward")
	if item.id == 4 then --新手礼包
        self.versionUpdate = NewUserDailyReward.new({superLayer = self.newUerReward})
        self.activityBg:setVisible(false)
        self.newUerReward:setVisible(true)
	    return
	end
	
	self.activityBg:setVisible(true)
	if self.newUerReward then
        self.newUerReward:setVisible(false)
	end

	if Util:judgeHasHttpSuffex(RESOURCE_HOST_NAME,"http") then
        kImgUrl = RESOURCE_HOST_NAME.."/"..kImgUrl.."?uin="..Cache.user.uin.."&key="..QNative:shareInstance():md5(Cache.user.key).."&channel="..reg.channel.."&version="..reg.version
	else
        kImgUrl = HOST_PREFIX..RESOURCE_HOST_NAME.."/"..kImgUrl.."?uin="..Cache.user.uin.."&key="..QNative:shareInstance():md5(Cache.user.key).."&channel="..reg.channel.."&version="..reg.version
	end
	
	loga("kImgUrl："..kImgUrl)
	self.activityBg:loadTexture(GameRes.img_active_loading)
	local taskID = qf.downloader:execute(kImgUrl, 10,
		function(path)
			if not tolua.isnull( self ) then
				self.btnCanTouch = true
				if url == nil then return end
				self.activityBg.id = item.id
				self.activityBg.page_url = item.page_url
				self.activityBg:loadTexture(path)
				-- 活动显示上报
				qf.platform:umengStatistics({umeng_key = "ActivityShow_"..self.activityBg.id})
			end
		end,
		function()
			self.btnCanTouch = true
		end,
		function()
			self.btnCanTouch = true
		end
	)
end

-- 获取活动数据
function ActivityView:getActivityModel(index)
	local activitModel = Cache.ActivityTaskInfo.rewardList.all_activity[index]
	return activitModel
end

function ActivityView:updateNowIndex()
	if self.bookmark == nil then return end
	local itemLen = #Cache.ActivityTaskInfo.rewardList.all_activity
	for index = 1,itemLen do
		local activitModel = self:getActivityModel(index)
		if activitModel.id == self.bookmark then
			self.nowIndex = index
		end
	end
end

function ActivityView:insertActivity(model)
	loga("====ActivityView:insertActivity===11111==")
	if Cache.ActivityTaskInfo.rewardList.all_activity == nil or #Cache.ActivityTaskInfo.rewardList.all_activity == 0 then 
		local pannel = self.gui:getChildByName("activityPanel")
		pannel:getChildByName("activityImg_0"):setVisible(false)
		pannel:getChildByName("activityImg"):setVisible(false)
		ccui.Helper:seekWidgetByName(self.gui,"noActivity"):setVisible(true)
		return 
	end
	self:updateNowIndex()
	local itemLen = #Cache.ActivityTaskInfo.rewardList.all_activity
	self.listView:setBounceEnabled(false)
	if itemLen > 4 then
		self.listView:setBounceEnabled(true)
	end

	if self.isInsertActivity then
		loga("====ActivityView:insertActivity====222222=")
		self.isInsertActivity = false
		self.listView:setItemModel(self.listItem)
		for index = 1,itemLen do
			local activitModel = self:getActivityModel(index)
			if activitModel.only_pop == 0 then
				self.listView:pushBackDefaultItem()
				local item = self.listView:getItem( index - 1)
				item:setVisible(true)
				local btn = item:getChildByName("btn")
				btn.tag = index
				item.itemId = activitModel.id
				item.can_pick = activitModel.can_pick
				if index == self.nowIndex then
					btn:setBright(false)
					btn:setTouchEnabled(false)
					self:loadActiveImg()
					item.can_pick = 0
					if activitModel.can_pick == 1 then 
					   self:activeFinished(activitModel.id)
				    end
				end
				addButtonEvent(btn,function() 
					if self.canTouch == false then return end
					btn:setBright(false)
					btn:setTouchEnabled(false)
					local olditem = self.listView:getItem(self.nowIndex - 1)
					local oldbtn = olditem:getChildByName("btn")
					oldbtn:setBright(true)
					oldbtn:setTouchEnabled(true)
					self.nowIndex = btn.tag
					self:loadActiveImg()
					item.can_pick = 0
					if activitModel.can_pick == 1 then 
					   self:activeFinished(activitModel.id)
				    end
				    btn:getChildByTag(self.BNT_NUMBER_BG_TAG):setVisible(false)
				end)

				local redNumberNode = cc.Sprite:create(GameRes.bnt_number_bg)
				local cs = btn:getContentSize()
				redNumberNode:setScale(0.8)
				redNumberNode:setTag(self.BNT_NUMBER_BG_TAG)
				redNumberNode:setPosition(cs.width*0.9,cs.height*0.9)
				btn:addChild(redNumberNode)
				redNumberNode:setVisible(false)

				if item.can_pick == 1 then 
					redNumberNode:setVisible(true)
				end
				--活动窗口文本解析
				-- local text = {}
				-- local str = activitModel.content
				-- if str ~= nil and str ~= "" then
				-- 	local t1=string.find(str,"<b>")
				-- 	local t2=string.find(str,"</b>")
				-- 	text[1] = string.sub(str,t1+3,t2-1)  --第一行文本
				-- 	loga(text[1])
				-- 	item:getChildByName("name"):setString(text[1])
				-- end

				item:getChildByName("name"):setString(activitModel.title)

				local activity_type = item:getChildByName("status")
				if activitModel.activity_type>0 then
					activity_type:setVisible(true)
					activity_type:loadTexture(GameRes["activity_status"..activitModel.activity_type])
				else
					activity_type:setVisible(false)
				end
			end
		end 
	else
		self:refreshActivity(model)
	end
end

function ActivityView:activeFinished(activit_id)
    GameNet:send({cmd = CMD.ACTIVITY_FINISHED_REQ,body={activity_id = activit_id}})
    local number = Cache.Config.FinishActivityNum or 0
    if number > 0 then
    	number = number - 1
    end
    qf.event:dispatchEvent(ET.MAIN_UPDATE_BNT_NUMBER,{name="activity",number = number,
        addNumber = 0})
end


function ActivityView:initClick()
	self.bg:setTouchEnabled(true)

	local panel = self.gui:getChildByName("activityPanel")
	panel:setTouchEnabled(true)
	
	addButtonEvent(self.backBtn,function(sender) 
		self:close()
	end)
	self.activityBg:setTouchEnabled(true)
	addButtonEvent(self.activityBg,function(sender)
		if not self.btnCanTouch or not self.activityBg.page_url or not self.activityBg.id or self.activityBg.page_url == "" then return end
		local url = self.activityBg.page_url--.."?uin="..Cache.user.id.."&key=".."&channel=".."&version="..
			if url == "ddz_match_join_game" then
				self:close()
			    qf.event:dispatchEvent(ET.EVENT_BANNER_GAME_MATCHING,{})
			else
				self:showWebView(url)
			-- 活动页面点击上报
			    qf.platform:umengStatistics({umeng_key = "Activity_"..self.activityBg.id})
			end
	end)
end

--[[下载图片]]
function ActivityView:setHeadByUrl(view,url,count)
	if view == nil or url == nil then return end
	view:removeAllChildren()
	local path = CACHE_DIR.."activity_"..count
	-- logd( " --- downloadingUserHead -- " .. path .. " " .. url , self.TAG)
	
	local taskID = qf.downloader:execute(url, 10,
			function(path)
				if not tolua.isnull( self ) then
					self:downloadHeadSuccess(view, url, count,path)
				end
			end,
			function() 
			end,
			function() 
			end
	)
end

function ActivityView:downloadHeadSuccess(view,url,count,path)
	if view == nil or url == nil then return end
	--local path = CACHE_DIR.."activity_"..count
	return self:setHeadByImg(view,path)
end

function ActivityView:setHeadByImg(view,img)
	if view == nil or img == nil then return end
	local p = cc.Sprite:create(img)
	local cs = view:getContentSize()
	local posx, posy = view:getPositionX(), view:getPositionY()
	local cp = p:getContentSize()
	p:setScaleX(cs.width/cp.width)
	p:setScaleY(cs.height/cp.height)
	p:setPosition(cs.width/2,cs.height/2)
	view:addChild(p) 
end

function ActivityView:updateTaskListView( ... )
    local taskListView = self.inviteTask:getChildByName("tack_listView")
    if taskListView == nil then return end
	taskListView:removeAllChildren()
	for index=1,#Cache.InviteInfo.inviteAwardList do
		local awardModel = Cache.InviteInfo.inviteAwardList[index]
		local itemCell = self.gui:getChildByName("item"):clone()
		-- 没有积分
		if awardModel.activity == 0 then
			itemCell = self.gui:getChildByName("item_1"):clone()
		end
		taskListView:pushBackCustomItem(itemCell)
		itemCell:setVisible(true)
		itemCell:getChildByName("item_title_lb"):setString(awardModel.desc)
		if awardModel.activity > 0 then
			itemCell:getChildByName("num_lb"):setString(awardModel.completeAwardCount)
			itemCell:getChildByName("Label_90"):setString("/" ..awardModel.awardNum)
		end

		local itemBtn = itemCell:getChildByName("item_action_btn")
		itemBtn:setTouchEnabled(true)
		if awardModel.bRePick == 1 then
			itemBtn:loadTextureNormal(GameRes.invite_receive_btn)
			itemBtn:getChildByName("Image_91"):loadTexture(GameRes.invite_txt_receive)
			addButtonEvent(itemBtn, function ()
				-- 领取奖励
				GameNet:send({cmd = CMD.GET_INVITE_REWARD, body = {uin = Cache.user.uin, reward_type = awardModel.type}, callback = function (rsp)
					if rsp.ret == 0 then
						if rsp.model then
							if rsp.model.error_code ~= 0 then
								local errorMesg = rsp.model.error_msg
								if errorMesg and errorMesg ~= "" then
									-- 显示错误信息
									qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = errorMesg})
								end
							else
								-- 领取奖励
								self:setInviteInfo()
								local awardNumInfo = {awardModel.goldNum, awardModel.focasNum, awardModel.activity}
								qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {diamond_free = 0,diamond_num = 0,rewardInfo = awardNumInfo})
							end
						end
					end
				end})
			end)
		else
			if awardModel.isFinish == true then
				itemBtn:setTouchEnabled(false)
				itemBtn:loadTextureNormal(GameRes.invite_finish_task_btn)
				itemBtn:getChildByName("Image_91"):setVisible(false)
			else
				itemBtn:loadTextureNormal(GameRes.invite_toInvite_btn)
				itemBtn:getChildByName("Image_91"):loadTexture(GameRes.invite_txt_toInvite)
				addButtonEvent(itemBtn, function ()
					-- 去邀请
					self:showToInvite()
				end)
			end
		end

		-- 设置奖励
		itemCell:getChildByName("reward_1"):getChildByName("reward_count"):setString(awardModel.goldNum)
		itemCell:getChildByName("reward_2"):getChildByName("reward_count"):setString(awardModel.focasNum)
		if itemCell:getChildByName("reward_3") then
			itemCell:getChildByName("reward_3"):getChildByName("reward_count"):setString(awardModel.activity)
		end
	end
end

-- 显示规则
function ActivityView:showInviteRulerPop()
	if self.inviteRulerPop == nil then
		self.inviteRulerPop = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.invite_ruler_pop)
		self.inviteRulerPop:setContentSize(self.winSize.width, self.winSize.height)
		if FULLSCREENADAPTIVE then
			self.inviteRulerPop:setPositionX(self.inviteRulerPop:getPositionX() - (self.winSize.width -1980)/2 -28)
		end
		local bg = self.inviteRulerPop:getChildByName("bg")
		local scrollView = bg:getChildByName("inner_bg"):getChildByName("scrollView")
		local contentLabel = cc.LabelTTF:create(GameTxt.friend_invite_ruler,GameRes.font1,40,cc.size(scrollView:getInnerContainerSize().width,0))
	    contentLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	    contentLabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
	    contentLabel:setAnchorPoint(0.5,1.0)
	    contentLabel:setColor(cc.c3b(150,86,19))
	    scrollView:setInnerContainerSize(cc.size(scrollView:getInnerContainerSize().width,contentLabel:getContentSize().height))
	    scrollView:addChild(contentLabel)

	    contentLabel:setPosition(scrollView:getInnerContainerSize().width/2,scrollView:getInnerContainerSize().height)

		addButtonEvent(self.inviteRulerPop, function ()
			self.inviteRulerPop:removeFromParent()
			self.inviteRulerPop = nil
		end)
	end
	self.gui:addChild(self.inviteRulerPop)
end

function ActivityView:setToBindPop( ... ) 

	local function setAwardTxt()
		local bg = self.toBindPop:getChildByName("bg")
		local innerBg = bg:getChildByName("inner_bg")
		local rewardTxt = innerBg:getChildByName("txt_subtitle")
		if Cache.InviteInfo.inviteAwardInfo then
			if Cache.InviteInfo.inviteAwardInfo.activityNum > 0 then
				rewardTxt:setString(string.format(GameTxt.invite_bind_award_2,Cache.InviteInfo.inviteAwardInfo.money,Cache.InviteInfo.inviteAwardInfo.focasNum,Cache.InviteInfo.inviteAwardInfo.activityNum))
			else
				rewardTxt:setString(string.format(GameTxt.invite_bind_award_1,Cache.InviteInfo.inviteAwardInfo.money,Cache.InviteInfo.inviteAwardInfo.focasNum))
			end 
		end
	end
	if self.toBindPop == nil then
		self.toBindPop = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.invite_bind_pop)
		self.toBindPop:setContentSize(self.winSize.width, self.winSize.height)
		if FULLSCREENADAPTIVE then
			self.toBindPop:setPositionX(self.toBindPop:getPositionX() - (self.winSize.width -1980)/2 -28)
		end
		local bg = self.toBindPop:getChildByName("bg")
		local innerBg = bg:getChildByName("inner_bg")

		local cancleBtn = innerBg:getChildByName("cancle_btn")
		local closePop = function ()
			if self.toBindPop then
				self.toBindPop:removeFromParent()
				self.toBindPop = nil
			end
		end

		addButtonEvent(cancleBtn, function ()
			closePop()
		end)

		local bindBtn = innerBg:getChildByName("bind_btn")
		local inviteCodeTf = innerBg:getChildByName("code_bg"):getChildByName("code_num_tf")
		addButtonEvent(bindBtn, function ()
			self:bindAction(inviteCodeTf, closePop)
		end)

		-- 设置奖励文本
		setAwardTxt()
	else
		setAwardTxt()
	end
	return self.toBindPop
end

-- 设置邀请详情
function ActivityView:setInviteDetailPop( ... )
	if self.inviteDetailPop == nil then
		self.inviteDetailPop = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.invite_detail_pop)
		self.inviteDetailPop:setContentSize(self.winSize.width, self.winSize.height)
		if FULLSCREENADAPTIVE then
			self.inviteDetailPop:setPositionX(self.inviteDetailPop:getPositionX() - (self.winSize.width -1980)/2 -28)
		end
		addButtonEvent(self.inviteDetailPop, function ()
			self.inviteDetailPop:removeFromParent()
			self.inviteDetailPop = nil
		end)
	end
	return self.inviteDetailPop
end

-- 新用户绑定
function ActivityView:bindAction(codeTf, cb)
	-- 获取邀请码
	local inviteCode = tonumber(codeTf:getStringValue())
	if inviteCode == nil then
		qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = GameTxt.invite_bind_error})
		return 
	end

	if inviteCode == Cache.user.uin then
		qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = GameTxt.friend_invite_myself_error})
		return
	end

	GameNet:send({cmd = CMD.BIND_INIVTE, body = {uin = Cache.user.uin, invite_uin = inviteCode}, callback = function (rsp)
		if rsp.ret == 0 then
			if rsp.model then
				if cb then cb() end
				self:setInviteInfo()
				-- 领取奖励
				local awardNumInfo = {Cache.InviteInfo.inviteAwardInfo.money, Cache.InviteInfo.inviteAwardInfo.focasNum, Cache.InviteInfo.inviteAwardInfo.activityNum}
				qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {diamond_free = 0,rewardInfo = awardNumInfo})
			end
		else
			if Cache.Config._errorMsg[rsp.ret] then
				qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = Cache.Config._errorMsg[rsp.ret]})
			end
		end
	end})
end

-- 显示邀请分享
function ActivityView:showToInvite( ... )
    PopupManager:push({class = InviteView})
    PopupManager:pop()
end

-- 邀请绑定
function ActivityView:showToBindPop( ... )
	self:setToBindPop()
	if self.toBindPop then
		self.gui:addChild(self.toBindPop)
	end
end

-- 显示邀请明细
function ActivityView:showInviteDetailPop( ... )
	self:setInviteDetailPop()
	if self.inviteDetailPop then
		local totalCount = self.inviteDetailPop:getChildByName("bg"):getChildByName("total_count_lb")
		totalCount:setString(string.format(GameTxt.friend_invite_count_txt, Cache.InviteInfo.inviteCnt))
		self.gui:addChild(self.inviteDetailPop)
		self:updateInviteDetailInfo()
	end
end

function ActivityView:updateInviteDetailInfo()
	GameNet:send({cmd = CMD.GET_INVITE_RECORDS, body = {uin = Cache.user.uin}, callback = function (rsp)
	    if rsp.ret == 0 then
	    	-- 更新数据
	        Cache.InviteInfo:updateInviteRecord(rsp.model)
	        local inviteDetailListView = self.inviteDetailPop:getChildByName("bg"):getChildByName("detail_listView")
			inviteDetailListView:removeAllChildren()
			
			inviteDetailListView:setItemModel(item)
			
			for index = 1,#Cache.InviteInfo.inviterecord do
				local recordModel = Cache.InviteInfo.inviterecord[index]
				local item = self.inviteDetailPop:getChildByName("item"):clone()
				inviteDetailListView:pushBackCustomItem(item)
				item:getChildByName("Label_101"):setString(Util:getTimeDescription(recordModel.date))
				item:getChildByName("Label_102"):setString(recordModel.nick)
				item:getChildByName("Label_103"):setString(recordModel.inviteUin)
			end
		end
	end})
	
end
--[[下载图片end]]

function ActivityView:delayRun(time,cb)
	local action = cc.Sequence:create(
		cc.DelayTime:create(time),
		cc.CallFunc:create(function (  )
			if cb then cb() end
		end)
	)
	self:runAction(action)
end

function ActivityView:close(  )
    --if self.canTouch == false then return end
	if self.webIsShowing then 
		self:startAllTouch()
		self.webIsShowing= false 
		qf.platform:removeWebView()
    end
    
    if self.cb then
        self.cb()
    end
    
    ActivityView.super.close(self)
end

return ActivityView
