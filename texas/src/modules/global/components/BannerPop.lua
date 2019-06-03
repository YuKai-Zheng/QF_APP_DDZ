local BannerPop   = class("BannerPop",CommonWidget.BasicWindow)
BannerPop.TAG = "BannerPop"

function BannerPop:ctor(paras)
    if paras and paras.cb then self.cb = paras.cb end
    BannerPop.super.ctor(self,paras)
	self:loadActiveImg()
	if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.gui,"Panel_banner")
        bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
    end
end


function BannerPop:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.BANNER_POP)
	self.panel = ccui.Helper:seekWidgetByName(self.gui,"Panel_banner")
	self.backBtn = self.panel:getChildByName("back_btn")
	self.activityBg = ccui.Helper:seekWidgetByName(self.panel,"activityImg")

end

function BannerPop:initClick()
	addButtonEvent(self.backBtn,function ()
		-- body
		MusicPlayer:playMyEffect("CLICK") 
		self:close()
	end)
	self.gui:setTouchEnabled(true)
	self.panel:setTouchEnabled(false)

	self.activityBg:setTouchEnabled(true)
	addButtonEvent(self.activityBg,function(sender)
		-- if not self.btnCanTouch  then return end		
		self:close()
		qf.event:dispatchEvent(ET.EVENT_BANNER_GAME_MATCHING,{})
	end)	
end

-- 加载活动图
function BannerPop:loadActiveImg()
	self.panel:getChildByName("activityImg_0"):setVisible(false)
	if self.activityBg then
		self.activityBg:setVisible(true)
	end

	if #Cache.Config.banner_link_list == 0 then
        return
	end

	
	local item = Cache.Config.banner_link_list[1]
	local kImgUrl = item.url
	local reg = qf.platform:getRegInfo()
	
	local taskID = qf.downloader:execute(kImgUrl, 10,
		function(path)
			if not tolua.isnull( self ) then
				self.btnCanTouch = true
				-- if url == nil then return end
				-- self.activityBg.id = item.id
				-- self.activityBg.page_url = item.page_url
				self.activityBg:loadTexture(path)

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

function BannerPop:close()
    if self.cb then
        self.cb()
    end
    BannerPop.super.cloes(self)
end

return BannerPop
