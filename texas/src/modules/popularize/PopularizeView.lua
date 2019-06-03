local PopularizeView = class("PopularizeView", qf.view)
PopularizeView.TAG = "PopularizeView"

local InviteView = import("src.modules.share.components.Invite")
PopularizeView.BNT_NUMBER_BG_TAG = 1101
PopularizeView.BNT_NUMBER_NUMBER_TAG = 1102

--[[listview中的条目]]
PopularizeView.item = {}
--[[listview中的按钮]]
PopularizeView.btnList = {}
PopularizeView.activityInfo = {}

function PopularizeView:ctor(parameters)
	PopularizeView.super.ctor(self,parameters)
	self.winSize = cc.Director:getInstance():getWinSize()
	self:init()
	qf.platform:umengStatistics({umeng_key = "Event"})
end

function PopularizeView:initWithRootFromJson( ... )
	return GameRes.popularizeViewJson
end

function PopularizeView:isAdaptateiPhoneX( ... )
	return true
end

function PopularizeView:init()
	Display:closeTouch(self)
	
end

function PopularizeView:requestPromoteInfo()
	qf.event:dispatchEvent(ET.GET_PROMOTE_INFO)
end

function PopularizeView:updateInfo()
	self.itemInfo = {
		[1] = "ownPopularizePartView",
		[2] = "bindWXView",
		[3] = "MyAchievePartView",
		[4] = "recommendPersonView",
		[5] = "rewardRuleView"
	}
	if Cache.user.is_bind_wx == 1 then
		self.itemInfo[2] = ""
	end
	if CHANNEL_NEED_WEIXIN_BAND_FLAG == false then
		self.itemInfo[2] = ""
	end
	self.nowIndex = self.itemInfo[1]
	self.promoteCode:setString(Cache.user.promoter_code)

 	local promoteConfig = Cache.user.promoteConfig
	local value = {
		[2] = string.format(GameTxt.promote_ruler[2], string.format("%0.2f", promoteConfig.cost_to_promoter/100)),
		[5] = string.format(GameTxt.promote_ruler[5], string.format("%0.2f", promoteConfig.reward_fir_level/100)),
		[6] = string.format(GameTxt.promote_ruler[6], string.format("%0.2f", promoteConfig.reward_sec_level/100)),
		[7] = string.format(GameTxt.promote_ruler[7], string.format("%0.2f", promoteConfig.reward_rate_fir_level/100)),
		[8] = string.format(GameTxt.promote_ruler[8], string.format("%0.2f", promoteConfig.reward_rate_sec_level/100))
	}
	for i=1, 8 do
		local titleTxt = ccui.Helper:seekWidgetByName(self.rewardRuleView, "ruleTitle_" .. i)
		if value[i] then
			local str = value[i]
			titleTxt:setString(str)
		else
			titleTxt:setString(GameTxt.promote_ruler[i])
		end
	end

	local fileName = GameRes.tobePromoterTxt
	if Cache.user.is_self_promoter == 1 then
		fileName = GameRes.toSharePromoter
	end 
	self.ownPopularizeLayer:getChildByName("popularize_btn"):getChildByName("Image_36"):loadTexture(fileName)

	-- 我的业绩
	self.myAchieveInfo = self.myAchievementDetailView:getChildByName("myPopularize_info")
 	if Cache.user.is_self_promoter == 1 then
 		local promoterPerformance = Cache.user.promoterPerformance
		self.myAchieveInfo:getChildByName("totoal_money"):getChildByName("num"):setString(string.format("%0.2f", promoterPerformance.reward_sum/100))
		self.myAchieveInfo:getChildByName("canGetMoney"):getChildByName("num"):setString(string.format("%0.2f", promoterPerformance.valid_reward_sum/100))
		self.myAchieveInfo:getChildByName("leverFirstPersons"):getChildByName("num"):setString(promoterPerformance.fir_level_count)
		self.myAchieveInfo:getChildByName("leverSecondPersons"):getChildByName("num"):setString(promoterPerformance.sec_level_count)
 	end

 	self.rewardIntroduceTitle:setString(string.format(GameTxt.rewardIntroduceTxt, string.format("%0.2f", promoteConfig.reward_fir_level/100)))
 	self.recommendPerson:setVisible(false)
 	if Cache.user.is_self_promoter ~= 1 then
 		self.itemInfo[3] = ""
 		self.introduceTxt:setVisible(true)
 	else
 		self.introduceTxt:setVisible(false)
 	end

 	if Cache.user.is_show_prom_reg_tab == false then
 		self.recommendPerson:setVisible(false)
 		self.itemInfo[4] = ""
 	end

 	if Cache.user.my_promoter_uin and Cache.user.my_promoter_uin ~= "" and Cache.user.my_promoter_uin ~= 0 then
		self.recommendPerson:setVisible(true)
		self.recommend_person_code:setString(Cache.user.my_promoter_uin)
	end

 	-- 展示二维码
 	local fileName = string.format("qrCode_%d.png",Cache.user.uin)
 	qf.platform:createQRCode({
        qrCodeStr = HOST_SHARE_NAME .."/wx/user_share?uin=" .. Cache.user.uin,
        qyCodeFileName = fileName,
        size = 366
    })
    Util:delayRun(1/60, function ()
    	local textureName = cc.FileUtils:getInstance():getWritablePath() .. fileName
    	if qf.device.platform == "android" then
    		textureName = qf.platform:getExternalPath() .. "/" .. fileName
    	end
        
        self.ownPopularizeLayer:getChildByName("popularize_code"):loadTexture(textureName)
	 	-- self.myAchievementDetailView:getChildByName("popularize_code"):loadTexture(textureName)
    end)
 	

    local reg = qf.platform:getRegInfo()
	local getCndUrl = function (url)
		if Util:judgeHasHttpSuffex(RESOURCE_HOST_NAME,"http") then
			return RESOURCE_HOST_NAME .. "/media/" ..url
		else
			return HOST_PREFIX..RESOURCE_HOST_NAME .. "/media/" ..url
		end
    end


    -- 加载banner
    local bannerUrl = promoteConfig.banner_url
    qf.downloader:execute(bannerUrl, 10, function(path)
        if not tolua.isnull( self ) then
           self:refreshShowImage(bannerUrl, path, self.adImg)
        end
    end)

	-- 加载介绍图片
 	local introduceUrl = promoteConfig.how_to_promoter_url
 	qf.downloader:execute(introduceUrl, 10, function(path)
        if not tolua.isnull( self ) then
           self:refreshShowImage(introduceUrl, path, self.introduce)
        end
    end)
    loga(bannerUrl)
    loga(introduceUrl)
    self:insertPopularizeListItem()
end

--串号提示
function PopularizeView:showToolsTips( uin,cb )
    -- body
    self.toolTips = require("src.modules.common.widget.toolTip").new({surecb=cb})
    self.toolTips:setTipsType({removeClose=true,txtType=cc.TEXT_ALIGNMENT_CENTER})
    self.toolTips:hideOtherText()
    self.toolTips:setTipsText("您将绑定推荐人"..uin)
    self:addChild(self.toolTips,2)
end

function PopularizeView:refreshShowImage(url, path, parentNode)
	parentNode:removeAllChildren()
	local image = ccui.ImageView:create(path)
    local size = image:getContentSize()
    image:setScaleX(parentNode:getContentSize().width/size.width)
    image:setScaleY(parentNode:getContentSize().height/size.height)
    image:setPosition(cc.p(parentNode:getContentSize().width*0.5, parentNode:getContentSize().height*0.5))
    parentNode:addChild(image)
end

function PopularizeView:enterCoustomFinish()
	self:startAllTouch()
	loga("popularize ----------------------- action1")
	local panel =  self.root:getChildByName("popularizrPanel")
	self.listItem = panel:getChildByName("item")
	self.backBtn = panel:getChildByName("back_btn")
	self.listView = panel:getChildByName("popularizeItem_list")
	self.promoteCode = panel:getChildByName("myAcceptCode"):getChildByName("acceptCode")
	self.recommendPerson = panel:getChildByName("recommend_person")
	self.recommend_person_code = panel:getChildByName("recommend_person"):getChildByName("recommend_person_code")
	self.recommend_person_code:setString("--")
	self.adImg = panel:getChildByName("pan_logo")


	-- 我要推广
	self.ownPopularizePartView = panel:getChildByName("ownPopularizePartView")
    self.ownPopularizeLayer = self.ownPopularizePartView:getChildByName("ownPopularizeLayer")
    self.ownPopularizeMethodLayer = self.ownPopularizePartView:getChildByName("ownPopularizeMethodLayer")
    self.introduce = self.ownPopularizeMethodLayer:getChildByName("popularize_introduce")
    self.introduceTxt = self.ownPopularizeLayer:getChildByName("introduceTitle")
    self.introduceTxt:setVisible(false)

    -- 我的业绩
	self.MyAchievePartView = panel:getChildByName("MyAchievePartView")
    self.myAchievementDetailView = self.MyAchievePartView:getChildByName("myAchievementDetailView")
    self.noneAchieveView = self.MyAchievePartView:getChildByName("noneAchieveView")
	self.rewardIntroduceTitle = self.noneAchieveView:getChildByName("rewardIntroduceTitle")

    -- 推广员
	self.recommendPersonView = panel:getChildByName("recommendPersonView")
	self.bandRecommendView = self.recommendPersonView:getChildByName("bandRecommendView")
	self.noneRecommendPersonView = self.recommendPersonView:getChildByName("noneRecommendPersonView")

	--微信绑定
	self.bindWXView = panel:getChildByName("bindWXView")
	self.bindWXView:setVisible(false)
	--绑定微信按钮
	self.bindWXBtn1 = self.bindWXView:getChildByName("bindWXBtn")
	self.bindWXBtn2 = self.myAchievementDetailView:getChildByName("bindWXBtn")
	self.bindWechatTips = self.myAchievementDetailView:getChildByName("bindWechatTips")
	self.bindSuccess = self.bindWXView:getChildByName("bindSeccess")

	self.bind_wx_label = self.bindWXView:getChildByName("bind_wx_label")

   

	self.bindWechatTips:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.3,255),cc.DelayTime:create(3),cc.FadeTo:create(0.3,0),cc.DelayTime:create(10))))

	if Cache.user.is_bind_wx == 0 then
		self.bindWXBtn1:setVisible(true)
		self.bindWXBtn2:setVisible(true)
		self.bindSuccess:setVisible(false)
		self.bindWechatTips:setVisible(true)
	else
		self.bindWXBtn1:setVisible(false)
		self.bindWXBtn2:setVisible(false)
		self.bindSuccess:setVisible(true)
		self.bindWechatTips:setVisible(false)
	end

	addButtonEvent(self.bindWXBtn1,function()
        qf.event:dispatchEvent(ET.EVENT_BAND_WEIXIN,{cb = function (data)
            self.bindWXBtn1:setVisible(false)
			self.bindWXBtn2:setVisible(false)
			self.bindSuccess:setVisible(true)
			self.bindWechatTips:setVisible(false)
			
        end})
    end)

	if Cache.user.is_self_promoter == 1 then
		self.bind_wx_label:setString(GameTxt.bind_wechat_ispromoter)
	else
		self.bind_wx_label:setString(GameTxt.bind_wechat_notpromoter)
	end

	addButtonEvent(self.bindWXBtn2,function()
        qf.event:dispatchEvent(ET.EVENT_BAND_WEIXIN,{cb = function (data)
            self.bindWXBtn1:setVisible(false)
			self.bindWXBtn2:setVisible(false)
			self.bindSuccess:setVisible(true)
        end})
    end)


	-- 规则
	self.rewardRuleView = panel:getChildByName("rewardRuleView")

	self.bg = self.root:getChildByName("background")
	self:addClick()
	self:requestPromoteInfo()
end

function PopularizeView:closeAllTouch()
	self.canTouch = false
end

function PopularizeView:startAllTouch()
	self.canTouch = true
end

function PopularizeView:showWebView (uu,ref) 
	local reg = qf.platform:getRegInfo()
	if ref==nil then
	  ref=UserActionPos.ACTIVITY_CENTER
	end
	self.url = HOST_PREFIX..HOST_NAME.."/"..uu.."?uin="..Cache.user.uin.."&key="..QNative:shareInstance():md5(Cache.user.key).."&channel="..reg.channel.."&version="..reg.version.."&ref="..ref
	loga(self.url)
	self:_showWebView(self.url)
end

function PopularizeView:_showWebView(url)
	self:closeAllTouch()
end

function PopularizeView:gotoShopCb()
	self:_showWebView(self.url)
end

function PopularizeView:exitModel()
	if self.canTouch == false then return end
	    loga("popularize ----------------------- action7") 
		qf.event:dispatchEvent(ET.BG_CLOSE)
		qf.event:dispatchEvent(ET.MAIN_MOUDLE_VIEW_EXIT,{name="popularize",from=self.from.name})
end

function PopularizeView:showPopularizeItem()	
	if  self.nowIndex == "ownPopularizePartView" then 
		self.ownPopularizePartView:setVisible(true);
		self.MyAchievePartView:setVisible(false);
	    self.recommendPersonView:setVisible(false);
	    self.rewardRuleView:setVisible(false);
	    self.bindWXView:setVisible(false)
	end

	--绑定微信
	if self.nowIndex == "bindWXView" then
		self.bindWXView:setVisible(true)
		self.ownPopularizePartView:setVisible(false);
		self.MyAchievePartView:setVisible(false);
	    self.recommendPersonView:setVisible(false);
	    self.rewardRuleView:setVisible(false);
	end

	if self.nowIndex == "MyAchievePartView" then
		local promoterPerformance = Cache.user.promoterPerformance
		if promoterPerformance.reward_sum == 0 and promoterPerformance.valid_reward_sum == 0 and promoterPerformance.fir_level_count == 0 and promoterPerformance.valid_reward_sum == 0 then
			self.myAchievementDetailView:setVisible(false);
			self.noneAchieveView:setVisible(true);
		else
			self.myAchievementDetailView:setVisible(true);
			self.noneAchieveView:setVisible(false);
		end
		self.ownPopularizePartView:setVisible(false);
		self.MyAchievePartView:setVisible(true);
	    self.recommendPersonView:setVisible(false);
	    self.rewardRuleView:setVisible(false);
	    self.bindWXView:setVisible(false)
	end
    if self.nowIndex == "recommendPersonView" then
        self.ownPopularizePartView:setVisible(false);
		self.MyAchievePartView:setVisible(false);
	    self.recommendPersonView:setVisible(true);
	    self.rewardRuleView:setVisible(false);
	    self.bindWXView:setVisible(false)
	end
	if self.nowIndex == "rewardRuleView" then
        self.ownPopularizePartView:setVisible(false);
		self.MyAchievePartView:setVisible(false);
	    self.recommendPersonView:setVisible(false);
	    self.rewardRuleView:setVisible(true);
	    self.bindWXView:setVisible(false)
	end
end

function PopularizeView:insertPopularizeListItem()
	self.listView:removeAllItems()
	self.listView:setBounceEnabled(false)
	
	self.listView:setItemModel(self.listItem)
	local count = 1
	for index = 1,#self.itemInfo  do
		local value = self.itemInfo[index]
		if value ~= "" then
			self.listView:pushBackDefaultItem()
			local item = self.listView:getItem(count - 1)
			item:setVisible(true)
			local btn = item:getChildByName("btn")
			local titleImageNormal = btn:getChildByName("titleImageNormal")	
            local titleImageSelected = btn:getChildByName("titleImageSelected")                
            titleImageNormal:loadTexture(GameRes["popularize_titleItemImage_normal_"..(index)])
            titleImageSelected:loadTexture(GameRes["popularize_titleItemImage_selected_"..(index)])

			btn.tag = value
			item:setName(value)
			if item:getName() == self.nowIndex then
				btn:setBright(false)
				btn:setTouchEnabled(false)
				titleImageNormal:setVisible(false);
				titleImageSelected:setVisible(true);
				self:showPopularizeItem()
			else
				btn:setBright(true)
				btn:setTouchEnabled(true)
				titleImageNormal:setVisible(true);
				titleImageSelected:setVisible(false);
			end

			addButtonEvent(btn,function()
				if self.canTouch == false then return end
				btn:setBright(false)
				btn:setTouchEnabled(false)
			    btn:getChildByName("titleImageNormal"):setVisible(false)	
                btn:getChildByName("titleImageSelected"):setVisible(true)

                local oldIndex = self.nowIndex
        		local olditem = self.listView:getChildByName(oldIndex)
				local oldbtn = olditem:getChildByName("btn")
				oldbtn:setBright(true)
				oldbtn:setTouchEnabled(true)
			    oldbtn:getChildByName("titleImageNormal"):setVisible(true)	
                oldbtn:getChildByName("titleImageSelected"):setVisible(false)
				
				self.nowIndex = btn.tag
				self:showPopularizeItem()
			end)
			count = count + 1
		end
	end
	if count > 5 then
		self.listView:setBounceEnabled(true)
	end
end


function PopularizeView:addClick()
	
	self.bg:setTouchEnabled(true)
	self.root:setTouchEnabled(true)
	
	addButtonEvent(self.backBtn,function(sender)
		self:exitModel()
	end)

	local howToPolularize = self.ownPopularizeLayer:getChildByName("howToPolularize")
	local back_btn = self.ownPopularizeMethodLayer:getChildByName("back_btn")

	addButtonEvent(howToPolularize,function(sender)
		self.ownPopularizeLayer:setVisible(false);
		self.ownPopularizeMethodLayer:setVisible(true);
	end)

	addButtonEvent(back_btn,function(sender)
		self.ownPopularizeLayer:setVisible(true);
		self.ownPopularizeMethodLayer:setVisible(false);
	end)
	
	Util:registerKeyReleased({self = self,cb = function ()
		self:exitModel()
	end})

	-- 绑定推荐人
	local bandBtn = self.bandRecommendView:getChildByName("band_btn")
	local inputTxt = self.bandRecommendView:getChildByName("recommendIDInput")
	addButtonEvent(bandBtn,function(sender)
		local txt = inputTxt:getStringValue()
		if txt.length == 0 or txt == "" then
			qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.band_txt_error})
		else
			self:showToolsTips(txt,function( ... )
				GameNet:send({ cmd = CMD.RELATE_TO_PROMOTER_REQ, body = {promoter_id = txt},callback= function(rsp)
		            if rsp.ret ~= 0 then
		                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
		            else
		            	Cache.user.my_promoter_uin = txt
		            	self.recommendPerson:setVisible(true)
		            	self.recommend_person_code:setString(Cache.user.my_promoter_uin)
		                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.band_success})
		                qf.event:dispatchEvent(ET.GET_PROMOTE_INFO)
		            end
		        end})
			end)
			
		end
	end)

	local toSharefunc = function (fileName, shareType)
        PopupManager:push({class = InviteView, init_data = {
            type = 1,
			cb = function ()
			end,
			fileName = fileName,
			shareType = shareType
        }})
        PopupManager:pop()
	end

	local toBePromoterFun = function ( ... )
		-- 直接去支付
        local methods = Cache.QuickPay:getPayMethodsByGoldItemName("apl_rmb2gold_12_120000")
        if 1 >= #methods then -- 只有一种支付方式
            local payInfo = Cache.PayManager:getPayInfoByItemNameAndMethod("apl_rmb2gold_12_120000", methods[1])
            payInfo.ref = UserActionPos.ACTIVITY_SHOP
            qf.event:dispatchEvent(ET.GAME_PAY_NOTICE, payInfo)
        else
            local ret = {}
            ret.data = Cache.PayManager:getGoldInfoByItemName("apl_rmb2gold_12_120000")
            ret.method = methods
            ret.ref = UserActionPos.ACTIVITY_SHOP
            qf.event:dispatchEvent(ET.EVENT_SHOW_PAY_METHOD_VIEW, ret)
        end
        qf.platform:umengStatistics({umeng_key = "PayOnPromoter",umeng_value = "apl_rmb2gold_12_120000"}) -- 推广员支付点击上报
	end

	-- 去推广
	local shareBtn = self.ownPopularizeLayer:getChildByName("popularize_btn")
	addButtonEvent(shareBtn, function ()
		-- 如果不是推广员
		if Cache.user.is_self_promoter == 1 then
			toSharefunc("icon.jpg",1)
		else
			toBePromoterFun()
		end
	end)

	local toBtn = self.noneAchieveView:getChildByName("popularize_btn")
	addButtonEvent(toBtn, function ()
		toSharefunc("icon.jpg",1)
	end)

	local toShareBtn = self.myAchievementDetailView:getChildByName("popularize_btn")
	addButtonEvent(toShareBtn, function ()
		toSharefunc("weixinhao.jpg",2)
	end)

end

function PopularizeView:getRoot() 
	return LayerManager.Activity
end

function PopularizeView:exit()
	ccs.GUIReader:destroyInstance()
end

return PopularizeView