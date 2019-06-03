local MyHeadBox   = class("MyHeadBox",CommonWidget.BasicWindow)
MyHeadBox.TAG = "MyHeadBox"
local HeadBoxItem = import(".headBoxItem")
local UserHead = import(".userHead")

function MyHeadBox:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
	MyHeadBox.super.ctor(self, paras)

	self:getHeadBoxListData()
	self:updateUserHeadView()
	if FULLSCREENADAPTIVE then
        local bg_layer = self.gui:getChildByName("deep_panel")
        bg_layer:setPositionX(bg_layer:getPositionX() - (self.winSize.width - 1980)/2)
        bg_layer:setContentSize(self.winSize.width, self.winSize.height)
    end
end

function MyHeadBox:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.myHeadBoxJson)
	self.bg = ccui.Helper:seekWidgetByName(self.gui,"bg")
	self.backBtn = self.bg:getChildByName("back")
	self.headInfo = ccui.Helper:seekWidgetByName(self.gui,"headInfo")
    self.deadLinePart = ccui.Helper:seekWidgetByName(self.gui,"deadLinePart")
	self.headBox_List = ccui.Helper:seekWidgetByName(self.gui,"headBos_List")
	self.listNumShow = ccui.Helper:seekWidgetByName(self.gui,"listNumShow")
	self.headBox_List_item = ccui.Helper:seekWidgetByName(self.gui,"Item")

end

function MyHeadBox:updateUserHeadView()
	if not self.userHead then
        self.userHead = UserHead.new({})
		self.headInfoDetail = self.userHead:getUI()
		self.headInfo:addChild(self.headInfoDetail)
	end
	self.headInfoDetail:setVisible(true)
	local headInfoSize = self.headInfo:getContentSize()
	local headInfoDetailSize = self.headInfoDetail:getContentSize()

	self.headInfoDetail:setPosition( -(headInfoDetailSize.width - headInfoSize.width)/2,-(headInfoDetailSize.height - headInfoSize.height)/2)
	self.userHead:loadHeadImage(Cache.user.portrait,Cache.user.sex,Cache.user.icon_frame,Cache.user.icon_frame_id)  
end

function MyHeadBox:getHeadBoxListData()
    GameNet:send({cmd=CMD.ICON_FRAME_LIST_EVT,body={},
        callback=function(rsp)
            if not isValid(self) then return end
            if rsp.ret == 0 then
                if rsp.model then
					Cache.user:updateUserHeadBox(rsp.model)
					self:initHeadBoxList()
                end
            end
        end
    })
end

function MyHeadBox:initHeadBoxList()
		self.headBox_List:setVisible(true)
		self.headBox_List:removeAllChildren()
	
		self.listItem = HeadBoxItem.new({}):getUI()
		local headBoxArr  = Cache.user.userHeadBoxList or {}
		self.headBox_List:setItemModel(self.headBox_List_item)
		self.headBox_List:setBounceEnabled(false)
	
		local len = 0
		local count = 0
		
		for index = 1, #headBoxArr do
			count = count + 1
			local info = headBoxArr[index]
			local item = self.headBox_List:getItem(index -1)
			if math.mod(len,3) == 0 then
				self.headBox_List:pushBackDefaultItem()
			end
			len = len+1
			local layout_item = self.headBox_List:getItem(math.floor((len-1)/3))
			layout_item:setVisible(true)
			local item = self.listItem:clone()
			item:setVisible(true)
			item:setPosition(math.mod(len-1,3)*(item:getContentSize().width + 25) + 25 ,0)
			layout_item:addChild(item)
			
			local head_box = ccui.Helper:seekWidgetByName(item,"headBox")
			ccui.Helper:seekWidgetByName(item,"itemTitle"):setString(info.name)
			local currentHeadBoxTag = ccui.Helper:seekWidgetByName(item,"currentHeadBoxTag")

			local  urlStr = info.path
			head_box:setVisible(true)
			-- if urlStr and string.len(urlStr) > 0 then 
			-- 	local taskID = qf.downloader:execute(urlStr, 10,
			-- 		function(path)
			-- 			if not tolua.isnull( item ) then
			-- 				head_box:loadTexture(path)
			-- 				head_box:setVisible(true)
			-- 			end
			-- 		end,
			-- 		function()
			-- 		end,
			-- 		function()
			-- 		end
			-- 	)
			-- else
			-- 	head_box:setVisible(true)
			-- end
			local level ,season = Util:getLevelHeadBoxTxt(info.id)

			head_box:loadTexture(string.format(GameRes.headLevelBox, level))
			if string.len(level) > 1 then
				ccui.Helper:seekWidgetByName(item,"seasonFont"):setVisible(true)
				ccui.Helper:seekWidgetByName(item,"seasonFont"):setString("S"..season) 
			else
				ccui.Helper:seekWidgetByName(item,"seasonFont"):setVisible(false)
			end
			
			item.in_use = info.in_use
			currentHeadBoxTag:setVisible(item.in_use)
			
            addButtonEvent(item,function( ... )
				if item.in_use then return end
				self:userHeadBox(info.id)
			end)
			
			if info.in_use then
				ccui.Helper:seekWidgetByName(self.headInfo,"headBoxTitle"):setString(info.name)
				Cache.user.icon_frame = info.path
				Cache.user.icon_frame_id = info.id
				self.userHead:loadHeadBoxImage(Cache.user.icon_frame,Cache.user.icon_frame_id)
				qf.event:dispatchEvent(ET.ICON_FRAME_CHANGE_NOT,{}) --同时更新主界面的头像
			end	
		end
		ccui.Helper:seekWidgetByName(self.listNumShow,"currentHeadBoxNum"):setString(count)
end



function MyHeadBox:userHeadBox(headId)
    GameNet:send({cmd=CMD.ICON_FRAME_USE_EVT,body={ id = headId},
		callback=function(rsp)
            if rsp.ret == 0 then
				self:getHeadBoxListData()
            end
        end
    })
end

function MyHeadBox:initClick()
	addButtonEvent(self.backBtn,function ()
		-- body
		MusicPlayer:playMyEffect("CLICK") 
		self:close()
	end)
	self.gui:setTouchEnabled(true)
	addButtonEvent(self.gui,function ()
		-- body
		MusicPlayer:playMyEffect("CLICK") 
		self:close()
	end)
end

function MyHeadBox:close()
    if self.cb then
        self.cb()
    end

    MyHeadBox.super.close(self)
end

return MyHeadBox