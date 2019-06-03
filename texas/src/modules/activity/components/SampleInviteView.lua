local SampleInvite=class("SampleInvite",CommonWidget.BasicWindow)
SampleInvite.TAG = "SampleInvite"

local shareFileName = "icon.jpg"

function SampleInvite:ctor(paras)
    SampleInvite.super.ctor(self, paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.gui:setContentSize(self.winSize.width, self.winSize.height)
end

function SampleInvite:init()
    self:saveImage(cc.Sprite:create(GameRes.invite_img_1))
end

function SampleInvite:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.invite_pop)
	local bg = self.gui:getChildByName("bg")
	local innerBg = bg:getChildByName("inner_bg")
	local codeNumLb = innerBg:getChildByName("code_bg"):getChildByName("code_num_lb")
	codeNumLb:setString(Cache.user.uin)

	local weixin = innerBg:getChildByName("weixin")
	-- 微信好友
	addButtonEvent(weixin, function ()
		self.type = 3
		self.scene = 1
		self:share()
	end)

	local friend = innerBg:getChildByName("friend_circle")
	-- 微信朋友圈
	addButtonEvent(friend, function ()
		self.type = 3
		self.scene = 2
		self:share()
	end)

	--点击空白处关闭界面
    ccui.Helper:seekWidgetByName(self.gui,"root"):addTouchEventListener(
        function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:close()
            end
        end
    )
end

function SampleInvite:saveImage(node)
	local s1 = cc.Director:getInstance():getWinSize()
    local s = node:getContentSize()
    local scale = 1
    node:setVisible(true)
    node:setScale(scale)
    node:setAnchorPoint(0,0)
    node:setPosition(0,0)
    local jpg = shareFileName
    local target = cc.RenderTexture:create(s.width*scale, s.height*scale, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    target:retain()
    target:setPosition(cc.p(s1.width*scale / 2, s1.height*scale / 2))
    target:begin()
    node:visit()
    target:endToLua()
    target:saveToFile(jpg, cc.IMAGE_FORMAT_JPEG)
    target:release()
    node:setVisible(false)
end

function SampleInvite:share()
	local share_img_path = cc.FileUtils:getInstance():getWritablePath()..shareFileName
    local info ={
        type = self.type,
		share = 1,
		scene = self.scene,
		localPath = share_img_path,
		description = "xxxx",
        cb = function ()
            self:close()
        end
    }
    dump(info)
    qf.platform:sdkShare(info)
end

return SampleInvite