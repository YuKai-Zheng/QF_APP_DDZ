local Invite=class("Invite",CommonWidget.BasicWindow)
local IButton = import(".IButton")

local fileName = "icon.jpg"
local share_img_path = cc.FileUtils:getInstance():getWritablePath()..fileName
local share_desc = ""


function Invite:ctor(paras)
    Invite.super.ctor(self, paras)
end

function Invite:init(paras)
    self:saveImage(cc.Sprite:create(GameRes.invite_img_1))
    self.cb = paras.cb
end

function Invite:initUI()
    --关闭界面
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes["inviteView_"..paras.type])
    ccui.Helper:seekWidgetByName(self.gui,"btn_close"):addTouchEventListener(
        function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:close()
                MusicPlayer:playMyEffect("BTN")
            end
        end
    )
    --点击空白处关闭界面
    ccui.Helper:seekWidgetByName(self.gui,"root"):addTouchEventListener(
        function (sender, eventType)
        end
    )

    --跳到活动
    if ccui.Helper:seekWidgetByName(self.gui,"btn_goto_activity") then
        ccui.Helper:seekWidgetByName(self.gui,"btn_goto_activity"):addTouchEventListener(
            function (sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    self.cb()
                    self:close()
                    qf.event:dispatchEvent(ET.SHOW_ACTIVE_VIEW)
                    qf.event:dispatchEvent(ET.GOTO_ACTIVITY,{name="activity_12",ref=UserActionPos.ACTIVITY_ELSE})
                    MusicPlayer:playMyEffect("BTN")
                end
            end
        )
    end

    --微信好友
    ccui.Helper:seekWidgetByName(self.gui,"btn_wx"):addTouchEventListener(
        function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                share_desc = string.format(GameTxt.invite_sns,Cache.user.invite_code)
                self.type = 3
                self.scene = 1
                self:share()
                MusicPlayer:playMyEffect("BTN")
            end
        end
    )

    --qq好友
    ccui.Helper:seekWidgetByName(self.gui,"btn_qq"):addTouchEventListener(
        function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                share_desc = string.format(GameTxt.invite_sns,Cache.user.invite_code)
                self.type = 1
                self.scene = 1
                self:share()
                MusicPlayer:playMyEffect("BTN")
            end
        end
    )

    --朋友圈
    ccui.Helper:seekWidgetByName(self.gui,"btn_pyq"):addTouchEventListener(
        function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                share_desc = string.format(GameTxt.invite_sns,Cache.user.invite_code)
                self.type = 3
                self.scene = 2
                self:share()
                MusicPlayer:playMyEffect("BTN")
            end
        end
    )

    --通讯录
    ccui.Helper:seekWidgetByName(self.gui,"btn_txl"):addTouchEventListener(
        function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                share_desc = string.format(GameTxt.invite_sms,Cache.user.invite_code)
                qf.platform:sendSms({body = share_desc})
                MusicPlayer:playMyEffect("BTN")
            end
        end
    )
end

function Invite:saveImage(node)
    local s1 = cc.Director:getInstance():getWinSize()
    local s = node:getContentSize()
    local scale = 1
    node:setVisible(true)
    node:setScale(scale)
    node:setAnchorPoint(0,0)
    node:setPosition(0,0)
    local jpg = fileName
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

function Invite:share()
    loga("-------share-------")
    --        share=paras.share, --1只分享大图  2是图文链接
    --        scene=paras.scene, --1发给朋友 2发朋友圈或qq空间
    --        localPath=paras.localPath, --本地图片绝对路径
    --        targetUrl=paras.targetUrl, --打开的链接
    --        description=paras.description, --描述
    --        title=paras.title, --标题
    local info ={
        type = self.type,
        share = 1,
        scene = self.scene,
        localPath = share_img_path,
        description = share_desc,
        cb = function ()
            self:close()
        end
    }
    qf.platform:sdkShare(info)
end

return Invite