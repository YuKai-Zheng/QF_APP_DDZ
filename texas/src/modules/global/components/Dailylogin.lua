local Dailylogin    = class("Dailylogin",CommonWidget.BasicWindow)


Dailylogin.Close        = 137         --关闭按钮
Dailylogin.Reward_btn   = 135         --领取按钮
Dailylogin.Reward_name  = "reward_"   --第几天
Dailylogin.Reward_big   = 6728         --超过七天

function Dailylogin:ctor(paras)
	Dailylogin.super.ctor(self, paras)
end

function Dailylogin:init( paras )
    self.closeDailyLogin=false
	if paras and paras.cb then self.cb=paras.cb end
end

function Dailylogin:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.DAILY_LOGIN_POP)
	self.close_btn  = ccui.Helper:seekWidgetByTag(self.gui,Dailylogin.Close)    --close
	self.reward_btn = ccui.Helper:seekWidgetByTag(self.gui,Dailylogin.Reward_btn)       --领取按钮
	self.reward_big = ccui.Helper:seekWidgetByTag(self.gui,Dailylogin.Reward_big)       --超过七天

	for i = 1,7 do
		self["reward_"..tostring(i)] = ccui.Helper:seekWidgetByName(self.gui,Dailylogin.Reward_name..tostring(i))   --第几天
	end

	cc.SpriteFrameCache:getInstance():addSpriteFrames(GameRes.Gold_plist)
end

function Dailylogin:initItem(data)
	-- body
	for i=1,data:len() do
		local v = data:get(i)
		local index      = v.days

		if index ~= 8 then
			local item       = self["reward_"..tostring(v.days)]

			local content    = ccui.Helper:seekWidgetByName(item,"content")

			local title      = ccui.Helper:seekWidgetByName(content,"title")
			local gold_num   = ccui.Helper:seekWidgetByName(content,"gold_num")
			title:setString(GameTxt.Daily_login[index])
			gold_num:setString(self:getItemDesc(v))
		else
			local item      =  self.reward_big
			local reward    = ccui.Helper:seekWidgetByName(item,"reward")
			local gold_num  = ccui.Helper:seekWidgetByName(reward,"gold_num")

			gold_num:setString(self:getItemDesc(v))
		end
	end
end

function Dailylogin:getItemDesc(cfg)
	local txt = ''
	if cfg.gold_num > 0 then
		txt = GameTxt.Daily_login_desc[1]..cfg.gold_num
	elseif cfg.diamond_num > 0 then
		txt = GameTxt.Daily_login_desc[2]..cfg.diamond_num
	elseif cfg.super_multi_card > 0 then
		txt = GameTxt.Daily_login_desc[3]..cfg.super_multi_card
	elseif cfg.oneday_remcard > 0 then
		txt = GameTxt.Daily_login_desc[4]..cfg.oneday_remcard
	end

	return txt
end

function Dailylogin:initClick()
	self.close_btn.noEffect = true
	addButtonEvent(self.close_btn,function ()
		-- body
		MusicPlayer:playMyEffect("CLICK") 
		self:close()
	end)
	self.reward_btn.noEffect = true
	addButtonEvent(self.reward_btn,function ()
		-- body
		MusicPlayer:playMyEffect("CLICK") 
		GameNet:send({cmd=CMD.EVENT_LOGIN_REWARD_GET,callback=function (rsp)
	      	if rsp.ret ~= 0 then    return end

		  	self:resetRewardBtn()

		  	if self.login_days <=7 then
		  	self:playReward(self.item)
		  	self.delayCall1=Scheduler:delayCall(0.6,function ( ... )
			  	-- body
			  		if self.closeDailyLogin~=nil and not self.closeDailyLogin then
			  			self:sprayGold()
			  		end
			  	end)
		  	else
		  		self:sprayGold()
		 	end

		 self.delayCall2=Scheduler:delayCall(4,function ( ... )
		  	-- body
		  	if self.closeDailyLogin~=nil and not self.closeDailyLogin then
		  		self:close()
		  	end
		  end)


	  end})
	end)
end

function Dailylogin:resetRewardBtn( ... )
	self.reward_btn:setBright(false)
	self.reward_btn:setTouchEnabled(false)
	self.reward_btn:getChildByName("img"):setVisible(false)
	self.reward_btn:getChildByName("img1"):setVisible(true)
end

--rewarded 显示已经领取的
function Dailylogin:rewarded(day)
	-- body
	local node 
	if day<8 then
		node= self[Dailylogin.Reward_name..tostring(day)]
	-- else
	-- 	node= self.big_item
	end
	local content = ccui.Helper:seekWidgetByName(node,"content")
	local reward  = ccui.Helper:seekWidgetByName(node,"rewarded")
	if reward then 
		reward:setVisible(true)
		local rgb = reward:getDisplayedColor()
	end
	if content then
		content:setColor(Theme.Color.DARK)
	end
end


--显示已领取的数据
function Dailylogin:initRewardData(model)
	-- body
	if model.gift_type <= 7 then
		self.item = self["reward_"..model.gift_type]
	end

	self.login_days = model.gift_type
	for i=1,self.login_days do
		if i <= 7 then
			if model.flag == 1 and i==model.gift_type then 
				break 
			elseif i==self.login_days and self.login_days<=7 then
				ccui.Helper:seekWidgetByName(self[Dailylogin.Reward_name..tostring(i)],"rewarded"):loadTexture(GameRes.DAILY_LOGIN_Today)
			-- elseif i==self.login_days and self.login_days>7 then
			-- 	self.big_item:getChildByName("rewarded"):loadTexture(GameRes.DAILY_LOGIN_Today)
			end
			if i<8 or model.flag ~= 1 then
				self:rewarded(i)
			end
	    end
	end
	-- for i=1,model.gift_config:len() do
	-- 	local reward = model.gift_config:get(i)
	-- 	self._loginReward[i] = {}
	-- 	self._loginReward[i].days = reward.days
	-- 	self._loginReward[i].Gifts = {}
	-- 	for j=1, reward.items:len() do
	-- 		local item =  reward.items:get(j)
	-- 		self._loginReward[i].Gifts[j] = {}
	-- 		self._loginReward[i].Gifts[j].type = item.type 
	-- 		self._loginReward[i].Gifts[j].amount = item.amount
	-- 		self._loginReward[i].Gifts[j].desc = item.desc
	-- 		self._loginReward[i].Gifts[j].activity_amount = item.activity_amount
	-- 	end

	-- end
	self:initItem(model.gift_config)
	self:xingxing(self.item,model.gift_type)
	if model.flag ~= 1 then
		self:resetRewardBtn()
	end
end

--显示星星
function Dailylogin:xingxing( node ,day)
	-- body
		-- body
	local armatureDataManager = ccs.ArmatureDataManager:getInstance()
	armatureDataManager:addArmatureFileInfo(GameRes.DAILY_REWARD_LIGHT)
	local   face = ccs.Armature:create("Login-to-reward")

	face:getAnimation():playWithIndex(0)
	face:setScale(1.2)
	node:addChild(face)
	local size
	if  day<8 then
		size= self["reward_"..day]:getSize()
	end
	face:setPosition(size.width/2,size.height/2)
	face:setName("xingxing")
end


function Dailylogin:close()
    self.closeDailyLogin=true
    
	if self.cb then
		self.cb()
    end
    
    Dailylogin.super.close(self)
end


--喷金币
function Dailylogin:sprayGold()

	MusicPlayer:playMyEffect("PENG") 
	local rate_v = (Display.cy+300) / 100
	local time_v = 1
	for i=1,25 do

		for j=1,15 do
			
			local rate   = math.random(50,100)  --随机初始速度
			if i >=18 then
				rate = math.random(30,70)
			end

			
			local rotate = math.random(0,17)    --随机初始角度
			local length = math.cos(math.rad(rotate)) * rate * rate_v
			local time   = math.cos(math.rad(rotate)) * rate/100

			local line_length = math.sin(math.rad(rotate)) * rate *rate_v



			local index  = math.random(1,16)
			local sprite = cc.Sprite:createWithSpriteFrameName(string.format("coin_%d.png",index))
			sprite.index = index
			sprite.id = Scheduler:scheduler(0.01,function ()
				-- body
				if self.closeDailyLogin==nil or self.closeDailyLogin==true and sprite.id then
					Scheduler:unschedule(sprite.id)
					sprite.id=nil
					return
				end
				if sprite.index>16 then
					sprite.index = 1
				end

				sprite:setSpriteFrame(string.format("coin_%d.png",sprite.index))
				sprite.index = sprite.index +1
				return true
			end)
			
			local ro = math.random(0,10)

			sprite:setRotation(ro*36)
			self:addChild(sprite)
			sprite:setScale(0.5)
			local y = math.random(-100,0)
			sprite:setPosition(Display.cx/2,y)
			sprite:setVisible(false)
			local random =math.random(-200,200)
			
			local tmp_line 
			local it    = math.random(0,1)
			if it ==0 then
				tmp_line = line_length 
			else
				tmp_line = -line_length
			end
			
			local ox = Display.cx/2+tmp_line
			local delay = cc.DelayTime:create((i-1)*0.035)
			local move = cc.MoveTo:create(time,cc.p(ox,length))
			local easeout = cc.EaseSineOut:create(move)
			local call = cc.CallFunc:create(function ()
				-- body
				sprite:setVisible(true)
			end)
			local call1= cc.CallFunc:create(function ()
				-- body
				if sprite.id then
					Scheduler:unschedule(sprite.id)
					sprite.id=nil
				end
				sprite:removeFromParent()
			end)

			local tmp_line_t 
			if it ==0 then
				tmp_line_t = ox +line_length 
			else
				tmp_line_t = ox-line_length
			end
		
			local move2 = cc.MoveTo:create(time,cc.p(tmp_line_t,0))
			local easein = cc.EaseSineIn:create(move2)	
			local sq = cc.Sequence:create(delay,call,easeout,easein,call1)
			sprite:runAction(sq)
		end
	end
end



--播放领取的一系列动画
function Dailylogin:playReward(node)

  local xingxing = node:getChildByName("xingxing")
  if xingxing then
  	xingxing:removeFromParent()
  end

  
  local armatureDataManager = ccs.ArmatureDataManager:getInstance()
  local   face
  if self.login_days <= 6 then
	  armatureDataManager:addArmatureFileInfo(GameRes.DAILY_REWARD)
	  face = ccs.Armature:create("Login-to-reward01")
	  face:setScale(1)

	  local size = self["reward_1"]:getSize()
  	  face:setPosition(size.width/2,size.height/2)
  end


  if self.login_days == 7 then
		armatureDataManager:addArmatureFileInfo(GameRes.DAILY_REWARD_2)
		face = ccs.Armature:create("Login-to-reward02")
		face:setScale(1)

		local size = self["reward_7"]:getSize()
		face:setPosition(size.width/2,size.height/2)
  end


  
  face:getAnimation():playWithIndex(0)
  node:addChild(face)
  


end



return Dailylogin