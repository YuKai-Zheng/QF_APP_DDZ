local GameAnimationConfig = import(".animation.AnimationConfig")
local Chat = class("Chat",function(paras)
	return cc.Node:create()
end)

Chat.Emoji_listview_panel = 505     --表情的listview容器 非贵族
Chat.Emoji_item           = 508     --表情的listview的模板item
Chat.Emoji_exp            = 509     --emoji表情模板
Chat.Emoji_basic_hide     = 519     --发表情没被选中
Chat.Emoji_boble_hide     = 521     --发贵族表情没被选中
Chat.Emoji_basic_show     = 513     --发表情被选中
Chat.Emoji_boble_show     = 516     --发贵族表情被选中
Chat.Emoji_boble_panle    = 523     --贵族panel
Chat.Chat_panel           = 506     --文字聊天panel
Chat.Chat_item            = 525     --文字聊天item模板
Chat.Record_panel         = 507     --聊天记录panel
Chat.Emoji_panel          = 510     --表情的容器
Chat.Record_item          = 532     --聊天记录item
Chat.Emoji_nochoose_btn   = 4905   --选择表情的image
Chat.Emoji_choose_btn     = 4672     --已选择表情的image
Chat.Chat_nochoose_btn    = 4904   --选择文字的image
Chat.Chat_choose_btn      = 4674     --已选择文字的image
Chat.Record_nochoose_btn  = 4676     --选择聊天记录的image
Chat.Record_choose_btn    = 4676     --已选择聊天记录的image
Chat.Send                 = 500     --发送
Chat.Input                = 535     --内容
Chat.Vemoji_listview_panel= 1253    --表情的listview容器 非贵族
Chat.Vemoji_item          = 1257    --表情的listview的模板item
Chat.Vemoji_exp           = 1255    --emoji表情模板

--表情配置
Chat.Emoji_index = {
	[1] = {
		animation = GameAnimationConfig.EMOJI1,
		index     = 1,
	},
	[2] = {
		animation = GameAnimationConfig.EMOJI1,
		index     = 3,
	},
	[3] = {
		animation = GameAnimationConfig.EMOJI1,
		index     = 2,
	},	
	[4] = {
		animation = GameAnimationConfig.EMOJI1,
		index     = 4,
	},	
	[5] = {
		animation = GameAnimationConfig.EMOJI2,
		index     = 0,
	},	
	[6] = {
		animation = GameAnimationConfig.EMOJI2,
		index     = 1,
	},	
	[7] = {
		animation = GameAnimationConfig.EMOJI2,
		index     = 2,
	},
	[8] = {
		animation = GameAnimationConfig.EMOJI1,
		index     = 0,
	},	
	[9] = {
		animation = GameAnimationConfig.EMOJI3,
		index     = 0,
	},	
	[10] = {
		animation = GameAnimationConfig.EMOJI3,
		index     = 1,
	},
	[11] = {
		animation = GameAnimationConfig.EMOJI3,
		index     = 2,
	},
	[12] = {
		animation = GameAnimationConfig.EMOJI3,
		index     = 3,
	},

	[13] = {
		animation = GameAnimationConfig.EMOJI3,
		index     = 4,
	},
	[14] = {
		animation = GameAnimationConfig.EMOJI3,
		index     = 5,
	},

	[15] = {
		animation = GameAnimationConfig.EMOJI2,
		index     = 3,
	},	

	[16] = {
		animation = GameAnimationConfig.EMOJI2,
		index     = 4,
	},	
	[17] = {
		animation = GameAnimationConfig.EMOJI2,
		index     = 5,
	},	

	[18] = {
		animation = GameAnimationConfig.EMOJI4,
		index     = 0,
	},	

	[19] = {
		animation = GameAnimationConfig.EMOJI4,
		index     = 1,
	},
	[20] = {
		animation = GameAnimationConfig.EMOJI4,
		index     = 2,
	},
	[21] = {
		animation = GameAnimationConfig.EMOJI4,
		index     = 3,
	},
	[22] = {
		animation = GameAnimationConfig.EMOJI4,
		index     = 4,
	},
	[23] = {
		animation = GameAnimationConfig.EMOJI4,
		index     = 5,
	},
	[24] = {
		animation = GameAnimationConfig.EMOJI4,
		index     = 6,
	},

	[25] = {
		animation = GameAnimationConfig.EMOJI5,
		index     = 0,
	},
	[26] = {
		animation = GameAnimationConfig.EMOJI5,
		index     = 1,
	},
	[27] = {
		animation = GameAnimationConfig.EMOJI5,
		index     = 2,
	},
	[28] = {
		animation = GameAnimationConfig.EMOJI5,
		index     = 3,
	},
	[29] = {
		animation = GameAnimationConfig.EMOJI5,
		index     = 4,
	},
	[30] = {
		animation = GameAnimationConfig.EMOJI5,
		index     = 5,
	},
}






--Chat 文字列表
Chat.chat_word = {
	"和你合作真是太愉快了", 
	"快点啊，等得我花都谢了", 
	"小伙伴，你和地主是一家吧", 
	"你这么厉害，你家人知道吗", 
	"啊，糟了", 
	"别吵了别吵了，专心玩游戏吧", 
	"不胜利，吾宁死", 
	"怎么又断线了，网络也太差了", 
	"不要走，决战到天亮", 
	"土豪，我们做朋友吧"
}

function Chat:ctor(paras)
	if qf.device.platform == "ios" then
		self.isIosVersion=true
    end
  	self.winSize      = cc.Director:getInstance():getWinSize()
	self._parent_view = paras.view

	self:initGui()

	self:initEmoji()

	self:initVipEmoji()

	self:initChatList()

	self:initClickEvent()

	self:initSend()

	self:initKeyBoard()
	
	self.type = "zha"
	if  paras.chat_list then
		self.type = 'kan'
	end
	if FULLSCREENADAPTIVE then
		self.gui:setContentSize(self.gui:getContentSize().width+self.winSize.width-1920,self.gui:getContentSize().height)
	end
end	



--function--
function Chat:initSend()
	self.send.noEffect = true
	addButtonEvent(self.send,function ()
		-- body
		local content = self.input:getStringValue()
		GameNet:send({cmd=CMD.CHAT,body={content_type = 3,content=content}})
		self.input:setText("")
		self:hide()
	end)
end

--初始化画面
function Chat:initGui()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(DDZ_Res.chatViewJson)
    self:addChild(self.gui)

    local winsize = cc.Director:getInstance():getWinSize()

    self:setVisible(false)
    self.emoji_panel                     = ccui.Helper:seekWidgetByTag(self.gui,Chat.Emoji_panel)                       --表情容器
    self.emoji_listview_panel            = ccui.Helper:seekWidgetByTag(self.gui,Chat.Emoji_listview_panel)              --表情listview容器
    self.emoji_item                      = ccui.Helper:seekWidgetByTag(self.gui,Chat.Emoji_item)  		                --表情的listview的模板item
    self.emoji_exp                       = ccui.Helper:seekWidgetByTag(self.gui,Chat.Emoji_exp) 		                --emoji表情模板
    self.emoji_basic_hide                = ccui.Helper:seekWidgetByTag(self.gui,Chat.Emoji_basic_hide) 		            --发表情没被选中
    self.emoji_boble_hide                = ccui.Helper:seekWidgetByTag(self.gui,Chat.Emoji_boble_hide) 		            --发贵族表情没被选中      
    self.emoji_basic_show                = ccui.Helper:seekWidgetByTag(self.gui,Chat.Emoji_basic_show) 		            --e发表情被选中
    self.emoji_boble_show                = ccui.Helper:seekWidgetByTag(self.gui,Chat.Emoji_boble_show) 		            --发贵族表情被选中 
    self.emoji_boble_panle               = ccui.Helper:seekWidgetByTag(self.gui,Chat.Emoji_boble_panle) 	            --贵族panel
    self.chat_panel                      = ccui.Helper:seekWidgetByTag(self.gui,Chat.Chat_panel) 	                    --文字聊天panel
    self.chat_item                       = ccui.Helper:seekWidgetByTag(self.gui,Chat.Chat_item) 	                    --文字聊天item模板
	self.emoji_nochoose_btn              = ccui.Helper:seekWidgetByTag(self.gui,Chat.Emoji_nochoose_btn) 	            --选择表情的image
	self.emoji_choose_btn                = ccui.Helper:seekWidgetByTag(self.gui,Chat.Emoji_choose_btn) 	                --已选择表情的image
	self.chat_nochoose_btn               = ccui.Helper:seekWidgetByTag(self.gui,Chat.Chat_nochoose_btn) 	            --选择文字的image
	self.chat_choose_btn                 = ccui.Helper:seekWidgetByTag(self.gui,Chat.Chat_choose_btn) 	                --已选择文字的image
	self.record_nochoose_btn             = ccui.Helper:seekWidgetByTag(self.gui,Chat.Record_nochoose_btn) 	            --选择聊天记录的image
	self.record_choose_btn               = ccui.Helper:seekWidgetByTag(self.gui,Chat.Record_choose_btn) 	            --已选择聊天记录的image
	self.record_panel                    = ccui.Helper:seekWidgetByTag(self.gui,Chat.Record_panel) 	                    --聊天记录panel
	self.record_item                     = ccui.Helper:seekWidgetByTag(self.gui,Chat.Record_item) 	                    --聊天记录item
	self.send                            = ccui.Helper:seekWidgetByTag(self.gui,Chat.Send) 	                            --发送
	self.input                           = ccui.Helper:seekWidgetByTag(self.gui,Chat.Input) 	                        --内容
	self.vemoji_listview_panel           = ccui.Helper:seekWidgetByTag(self.gui,Chat.Vemoji_listview_panel)             --表情的listview容器 非贵族
	self.vemoji_item                     = ccui.Helper:seekWidgetByTag(self.gui,Chat.Vemoji_item)                       --表情的listview的模板item
	self.vemoji_exp                      = ccui.Helper:seekWidgetByTag(self.gui,Chat.Vemoji_exp)   

	if  not true then
		ccui.Helper:seekWidgetByTag(self.gui,530):setVisible(false)
		ccui.Helper:seekWidgetByTag(self.gui,517):setVisible(false)
	end

	self.chatP=ccui.Helper:seekWidgetByName(self.gui,"chatP")
	self.chatBg=ccui.Helper:seekWidgetByName(self.chatP,"bg")
	self.chatBg:setPosition(winsize.width - 30, 120)
	self.chatBgPos=cc.p(self.chatBg:getPositionX(),self.chatBg:getPositionY())

	self.chat_send_bt_ios = ccui.Helper:seekWidgetByName(self.gui,"btn_send_ios")
    self.chat_back_bt_ios = ccui.Helper:seekWidgetByName(self.gui,"btn_back_ios")
    self.chat_delete_bt_ios =ccui.Helper:seekWidgetByName(self.gui,"btn_delete_ios")    
    self.btn_edit_box_ios = ccui.Helper:seekWidgetByName(self.gui,"btn_edit_box_ios")
    self.chat_edit_box_for_ios=ccui.Helper:seekWidgetByName(self.gui,"chat_edit_box_for_ios")

    local bg= ccui.Helper:seekWidgetByName(self.gui,"img_edit_box_bg")
    if not self.editName then 
    	self.editName=cc.EditBox:create(cc.size(bg:getContentSize().width*0.9,bg:getContentSize().height),cc.Scale9Sprite:create())
    	self.editName:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
        --logd("editbox:%d",self.editName:setTag())
    	self.editName:setAnchorPoint(cc.p(0,0.5))
        self.editName:setPosition(cc.p(0,bg:getContentSize().height/2))
        local targetPlatform = cc.Application:getInstance():getTargetPlatform()
        if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then
            self.editName:setFontName(GameRes.font1)
        else
            self.editName:setFontName(GameRes.font1)
        end
        self.editName:setFontColor(cc.c3b(0,0,0))
        self.editName:setFontSize(40)
        --self.editName:setPlaceHolder(GameTxt.string632)
        self.editName:setMaxLength(100)
        self.editName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        bg:addChild(self.editName,10)
        self.editName:registerScriptEditBoxHandler(function(strEventName,sender) 
            logd("聊天输入event-->"..strEventName,self.TAG)
            if strEventName == "began" then

            elseif strEventName == "changed" then

             elseif strEventName == "ended" then
                
            elseif strEventName == "return" then
                logd("keyboradreturn....")
                if string.len(self.editName:getText())>0 then
                   local content = self.editName:getText()
					self.input:setText(content)
               	end
           end

        end)
    end
end


function Chat:initKeyBoard( ... )
	local winsize = cc.Director:getInstance():getWinSize()
    local fsize = cc.Director:getInstance():getOpenGLView():getFrameSize()
        
    local box_width=self.chat_edit_box_for_ios:getContentSize().width
    self.chat_edit_box_for_ios:setAnchorPoint(0.5,0.0)
    self.chat_edit_box_for_ios:setPositionX(winsize.width/2)
    local  rate=winsize.width/box_width
    self.chat_edit_box_for_ios:setScale(rate)
	-- body
	local func1= function(rate)
		if tolua.isnull( self.chat_edit_box_for_ios ) then
            return
        end
        local h=rate*winsize.height-5  
        self.chat_edit_box_for_ios:setPositionY(h)
    end

    local func2= function(rate)
    	if tolua.isnull( self.chat_edit_box_for_ios ) then
            return
        end
    	self:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(
                    function() 
                        self:closeVirtualBox() 
                    end
                )))
    end

     local func3= function(rate)
           if self.editName ==nil then 
               return
           end
           if tolua.isnull( self.editName ) then
            return
           end
          self.editName:setText("") 
          self.input:setText("")
     end

    if self.isIosVersion==true then
        local posx= self.chat_delete_bt_ios:getPositionX()/self.chat_edit_box_for_ios:getContentSize().width
        qf.platform:listenKeyboardShow({show_cb = func1,delete_cb=func3,x_rate=posx})
        qf.platform:listenKeyboardHide({hide_cb = func2})
    end
end


--初始化聊天的列表
function Chat:initChatList()
	self.chat_panel:setItemModel(self.chat_item)
	for i=1,#Chat.chat_word do
    	self.chat_panel:pushBackDefaultItem()
    	local layout_item = self.chat_panel:getItem(i - 1)
    	local font        = ccui.Helper:seekWidgetByName(layout_item,"font")
    	font:setString(Chat.chat_word[i])
    	addButtonEventNoVoice(layout_item,function ()
			GameNet:send({cmd=CMD.CHAT,body={content_type = 3,content=Chat.chat_word[i]}})
			self:hide()
    	end)
    end

end

--初始化表情图像
function Chat:initEmoji()
	-- body
	self.emoji_listview_panel:setItemModel(self.emoji_item)
    for i=1,6 do
    	self.emoji_listview_panel:pushBackDefaultItem()
    	local layout_item = self.emoji_listview_panel:getItem(i - 1)
    	for j = (i-1)*4+1, (i-1)*4+4 do
    		if j<= 24 then
    			local less = math.modf(j%4)
    			if less == 0 then
    				less = 4
    			end
	    		local Sprite = self.emoji_exp:clone()
		    	Sprite:loadTexture("emoji"..tostring(j)..".png",1)
		    	Sprite:setPosition(20+(less-1)*40,50)
				layout_item:addChild(Sprite)
				Sprite:setScale(0.3)
				Sprite:setTouchEnabled(true)

				--点击播放
				addButtonEventNoVoice(Sprite,function ()
					GameNet:send({cmd=CMD.CHAT,body={content_type = 0,content=tostring(j)}})
					self:hide()
				end)
			end
    	end
    end
end


--初始化VIP表情图像
function Chat:initVipEmoji()
	-- body

	if  not true then
		return 
	end

	self.vemoji_listview_panel:setItemModel(self.vemoji_item)

    for i=1,6 do
    	self.vemoji_listview_panel:pushBackDefaultItem()
    	local layout_item = self.vemoji_listview_panel:getItem(i - 1)
    	for j = (i-1)*3+1, (i-1)*3+3 do
    		if j<= 20 then

    			local less = math.modf(j%3)
    			if less == 0 then
    				less = 3
    			end
	    		local Sprite = self.vemoji_exp:clone()
	
		    	Sprite:loadTexture("vip_emoji_"..tostring(j)..".png",1)
		    	Sprite:setPosition(100+(less-1)*200,120)
				layout_item:addChild(Sprite)
				Sprite:setScale(0.8)
				Sprite:setTouchEnabled(true)

				--点击播放
				addButtonEventNoVoice(Sprite,function ()
					GameNet:send({cmd=CMD.CHAT,body={content_type = 0,tostring(j)}})
				end)
			end
    	end
    end
end


function Chat:getList()
	-- body
	return Cache.DDZDesk.chat
end

--初始化聊天记录
function Chat:initChatRecord()

	self.record_panel:setItemModel(self.record_item)
	self.record_panel:removeAllChildren()



	local item = self:getList()
	if item then
	for i=1,#item do

    	self.record_panel:pushBackDefaultItem()
    	local layout_item   = self.record_panel:getItem(i - 1)
    	local font          = nil
    	local icon          = nil
    	local emoji          = nil
    	local font_r        = ccui.Helper:seekWidgetByName(layout_item,"font_r")
    	local icon_r        = ccui.Helper:seekWidgetByName(layout_item,"icon_r")
    	local emoji_r        = ccui.Helper:seekWidgetByName(layout_item,"emoji_r")
    	local font_l        = ccui.Helper:seekWidgetByName(layout_item,"font_l")
    	local icon_l        = ccui.Helper:seekWidgetByName(layout_item,"icon_l")
    	local emoji_l        = ccui.Helper:seekWidgetByName(layout_item,"emoji_l")

    	font_r:setVisible(false)
    	icon_r:setVisible(false)
    	emoji_r:setVisible(false)
    	font_l:setVisible(false)
    	icon_l:setVisible(false)
    	emoji_l:setVisible(false)
    	
    	if item[i].uin ~= Cache.user.uin then
    		font = font_r
    		icon = icon_r
    		emoji = emoji_r
    	else
    		font = font_l
    		icon = icon_l
    		emoji = emoji_l
    		--默认显示33的字符就需要换行了
    		if #item[i].content <=33 then
    			font:setTextHorizontalAlignment(2)
    		end
	    	
    	end
    	local content=Util:filterEmoji(item[i].content or "")
    	font:setString(content)

    	Util:updateUserHead(icon, item[i].portrait, item[i].sex, {add=true, sq=true, url=true})
    	
  
    	if item[i].emoji then
    		local index      = string.sub(item[i].content,1,1)
    		local content=string.sub(item[i].content,2,string.len(item[i].content))
    		local png
   			if index == "#" then
   				png="emoji"..content..".png" 
   			elseif index == "$" then
   				png="vip_emoji_"..content..".png" 
   				emoji:setScale(0.7)
   			end
    		if index== "#" and string.len(item[i].content)>1 and tonumber(content)>0 and tonumber(content)<=30 or index== "$" and string.len(item[i].content)>1 and tonumber(content)>0 and tonumber(content)<=18 then
	    		emoji:loadTexture(png,ccui.TextureResType.plistType)
	    		emoji:setVisible(true)
	    	else
	    		font:setString(item[i].content)
    			font:setVisible(true)
	    	end
    	else
    		font:setString(item[i].content)
    		font:setVisible(true)
    	end
    	icon:setVisible(true)
    	addButtonEventNoVoice(layout_item,function( ... )
    		-- body
    		self.input:setText("")
    		self.input:setText(item[i].content)
    	end)
    end
	end

    self.record_panel:jumpToBottom()
end

function Chat:getChatListIndex(chatContent)--获得是第几条话语
	-- body
	for i=1,#Chat.chat_word do
    	if Chat.chat_word[i]==chatContent then
    		return i
  	  	end
    end
end

--初始化按钮事件
function Chat:initClickEvent()
	--显示贵族
	addButtonEvent(self.emoji_boble_hide,function()
		self.emoji_basic_hide:setVisible(true)
		self.emoji_basic_show:setVisible(false)		
		self.emoji_boble_hide:setVisible(false)
		self.emoji_boble_show:setVisible(true)
		self.emoji_boble_panle:setVisible(true)
		self.emoji_listview_panel:setVisible(false)

		self.vemoji_listview_panel:setVisible(true)

	end)


	--显示基本
	addButtonEvent(self.emoji_basic_hide,function()
		self.emoji_basic_hide:setVisible(false)
		self.emoji_basic_show:setVisible(true)		
		self.emoji_boble_hide:setVisible(true)
		self.emoji_boble_show:setVisible(false)
		self.emoji_boble_panle:setVisible(false)
		self.emoji_listview_panel:setVisible(true)
		self.vemoji_listview_panel:setVisible(false)
	end)

	--显示emoji
	addButtonEvent(self.emoji_nochoose_btn,function()

		self.emoji_nochoose_btn:setVisible(false)
		self.emoji_choose_btn:setVisible(true)
		self.chat_nochoose_btn:setVisible(true)
		self.chat_choose_btn:setVisible(false)
		self.record_nochoose_btn:setVisible(true)
		self.record_choose_btn:setVisible(false)

		self.emoji_panel:setVisible(true)
		self.chat_panel:setVisible(false)
		self.record_panel:setVisible(false)
	end)

	--显示文字聊天
	addButtonEvent(self.chat_nochoose_btn,function()

		self.emoji_nochoose_btn:setVisible(true)
		self.emoji_choose_btn:setVisible(false)
		self.chat_nochoose_btn:setVisible(false)
		self.chat_choose_btn:setVisible(true)
		self.record_nochoose_btn:setVisible(true)
		self.record_choose_btn:setVisible(false)

		self.emoji_panel:setVisible(false)
		self.chat_panel:setVisible(true)
		self.record_panel:setVisible(false)
	end)

	--显示聊天记录
	addButtonEvent(self.record_nochoose_btn,function()
		self.emoji_nochoose_btn:setVisible(true)
		self.emoji_choose_btn:setVisible(false)
		self.chat_nochoose_btn:setVisible(true)
		self.chat_choose_btn:setVisible(false)
		self.record_nochoose_btn:setVisible(false)
		self.record_choose_btn:setVisible(true)

		self.emoji_panel:setVisible(false)
		self.chat_panel:setVisible(false)
		self.record_panel:setVisible(true)
	end)

	addButtonEvent(self.gui ,function ()
		-- body
		if self.chat_edit_box_for_ios:isVisible()==true  then
			self:closeVirtualBox()
		end
		self.chatP:setVisible(true)
		self:hide()
	end)

	if self.isIosVersion then
		self.isIosVersion=true
		self.input:addEventListenerTextField(function (targe,eventType) 
	        if eventType == ccui.TextFiledEventType.attach_with_ime then
	        	self:setVirtualEditBox()
	        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
	         	--self:closeVirtualBox()
	        elseif eventType == ccui.TextFiledEventType.insert_text then
	    		if string.len(self.input:getStringValue())>0 and self.editName then
		        	self.editName:setText(self.input:getStringValue())
    			end
	        elseif eventType == ccui.TextFiledEventType.delete_backward then
	        	
	        	if self.editName then
		        	self.editName:setText(self.input:getStringValue())
    			end
	        end
	    end)
		self.chat_send_bt_ios.noEffect = true
		addButtonEvent(self.chat_send_bt_ios,function ()
			-- body
			if self.editName and self.editName:getText()~="" then 
				local content = self.editName:getText()
				GameNet:send({cmd=CMD.CHAT,body={content_type = 3, content=content}})
				self.editName:setText("")
				self:closeVirtualBox()
				self.input:setText("")
				self:hide()
			end
		end)
		self.chat_back_bt_ios.noEffect = true
		addButtonEvent(self.chat_back_bt_ios,function ()
			-- body
			self.chatback=true
			if self.editName then 
				local content = self.editName:getText()
				self.input:setText(content)
			end
			self:closeVirtualBox()
		end)
		self.chat_delete_bt_ios.noEffect = true
		addButtonEvent(self.chat_delete_bt_ios,function ()
			-- body
			self.input:setText("")
			self.editName:setText("")
		end)
	end
end

--显示chat面板
function Chat:show()
	self:initChatRecord()
	self:setOpacity(0)
	self:setVisible(true)
	self.chatP:setVisible(true)
	local bg=ccui.Helper:seekWidgetByName(self.chatP,"bg")
	bg:setAnchorPoint(1, 0)
	--ccui.Helper:seekWidgetByName(self.chatP,"bg"):setScaleY(0.1)
	--ccui.Helper:seekWidgetByName(self.chatP,"bg"):runAction(cc.ScaleTo:create(0.3,1))
	local p1 = cc.p(self.chatBgPos.x,self.chatBgPos.y)
    local p2 = cc.p(self.chatBgPos.x,-self.winSize.height*0.2)
    local p3 = cc.p(self.chatBgPos.x,self.winSize.height*0.55)
    
    bg:setPosition(p1)
    bg:setScale(0,0)
    bg:setVisible(true)
    bg:runAction(cc.Sequence:create(
        cc.EaseSineOut:create(cc.ScaleTo:create(0.2,1))
    ))

	-- local fadein  = cc.FadeIn:create(0.5)
	-- local scaleto = cc.ScaleTo:create(0.3,1)
	-- local spawn   = cc.Spawn:create(fadein,scaleto)
	-- self:runAction(fadein)
end


--影藏chat面板
function Chat:hide()
	local bg=ccui.Helper:seekWidgetByName(self.chatP,"bg")
	local p1 = cc.p(self.chatBgPos.x,self.winSize.height*0.5)
    local p2 = cc.p(self.chatBgPos.x,-self.winSize.height*0.2)
    local p3 = cc.p(self.chatBgPos.x,self.winSize.height*0.55)
        
    bg:runAction(cc.Sequence:create(
        -- cc.EaseSineIn:create(cc.ScaleTo:create(0.1,0,0)),
        cc.CallFunc:create(function(sender)
            self:setVisible(false)
        end)
    ))
	if self.chat_edit_box_for_ios and self.chat_edit_box_for_ios:isVisible() then
        self.chat_edit_box_for_ios:setVisible(false)
        self.isShowVirtualEditBoxing=false
    end
end


function Chat:setVirtualEditBox()
    local winsize = cc.Director:getInstance():getWinSize()
    local fsize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    self.chat_edit_box_for_ios:setVisible(true)
	self.chatP:setVisible(false)
        
    local box_width=self.chat_edit_box_for_ios:getContentSize().width
    self.chat_edit_box_for_ios:setAnchorPoint(0.5,0.0)
    self.chat_edit_box_for_ios:setPositionX(winsize.width/2)
    local  rate=winsize.width/box_width
    self.chat_edit_box_for_ios:setScale(rate)


    if string.len(self.input:getStringValue())>0 then
        self.editName:setText(self.input:getStringValue())
    -- else
    --     self.input:setPlaceHolder(GameTxt.string632)
    end
    self.isShowVirtualEditBoxing=true
    qf.platform:openKeyboard({close = 0})
  
end


function Chat:closeVirtualBox(hide)
	-- if self.editName then
	--     self.input:setText(self.editName:getText())
	-- end
    if self.isIosVersion==true then
      qf.platform:closeKeyboard({close = 1})
    end
	if self.isIosVersion==true then
	     self.chat_edit_box_for_ios:setVisible(false)
	     self.chatP:setVisible(true)
	     --self.editName:setAttachWithIME(false)
	     --self.editName:setText("")
	     --self.editName.num=0
	     --self.arrow_text:setVisible(false)
	     --self.arrow_text:setPosition(self.editName:getContentSize().width+1,self.editName:getContentSize().height*0.5)
	  end
 
end

return Chat