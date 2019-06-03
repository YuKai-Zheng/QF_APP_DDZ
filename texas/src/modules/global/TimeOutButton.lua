--[[
示例如下
local TimeOutButton = require("src.games.game_ddz.modules.global.TimeOutButton")
local timeBtn = TimeOutButton.new(self.bindWXBtn)
   timeBtn.callBack = function (Event)
       -- body
       if(Event == ET.EVENT_TIME_DOWN)then
            print("倒计时中")
        elseif(Event == ET.EVENT_TIME_BEGIN)then
            print("倒计时开始")
        else
            print("倒计时结束")
       end
   end

]]





local TimeOutButton = class("TimeOutButton",function (paras)
	return paras
 end)
--定时器时间设置
TimeOutButton.timeCount = 60
function TimeOutButton:ctor()
 	-- body
 	self:initUI()
 	TimeOutButton.callBack = function (Event)
 		-- body
 	end
end 
--初始化UI
function TimeOutButton:initUI()
	-- body
	self:setTitleText("发送验证码")
	-- self:setTitleFontSize(30)
	
	addButtonEvent(self, function ()
		self:setEnabled(false)
		self:setBright(false)
		self:setTouchEnabled(false)
		local time = self.timeCount
		self:setTitleText("发送验证码60S")
		if(TimeOutButton.callBack) then
			self.callBack(ET.EVENT_TIME_BEGIN)
		end
   		
   		self.callbackEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
   			-- body
			time = time - 1;
			if(TimeOutButton.callBack) then
				self.callBack(ET.EVENT_TIME_DOWN)
			end
			
			if(time == 0) then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.callbackEntry)
				self:setTitleText("发送验证码")
				self:ending()
			end
			print(time)
			self:setTitleText("发送验证码"..tostring(time).."S")
   		end,1,false)
    end)

end
--倒计时结束
function TimeOutButton:ending()
	-- body
	self:setEnabled(true)
	self:setBright(true)
	self:setTouchEnabled(true)
	if(TimeOutButton.callBack) then
		self.callBack(ET.EVENT_TIME_END)
	end
	
end

function TimeOutButton:remove()
	-- body
	if self.callbackEntry then

		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.callbackEntry)
	end
	

end

return TimeOutButton