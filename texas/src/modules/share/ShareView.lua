local ShareView = class("ShareView", qf.view)
ShareView.TAG = "ShareView"

SHARE_SHOW_TYPE_JD = 1 --  经典场用户赢取为大盲的200倍
SHARE_SHOW_TYPE_BR = 2 --百人场赢取筹码大于10W且赢取大于自身下注前筹码的30%（需要调
SHARE_SHOW_TYPE_JF = 3 --用户积分兑换成功话费券兑换成功
SHARE_SHOW_TYPE_TS = 4 --用户为特殊牌型（葫芦及以上牌型）
SHARE_SHOW_TYPE_PH = 5 --排行榜
local fileName = "share.jpg"
local share_img_path = cc.FileUtils:getInstance():getWritablePath()..fileName
local share_title
local share_desc

function ShareView:ctor(para)
    self:reset()
    ShareView.super.ctor(self,para)
    share_desc = para.txt
--    performWithDelay(self,function()
    self:init(para)
--    end,5)
end

function ShareView:init(para)
    local s1 = cc.Director:getInstance():getWinSize()
    --底下的遮罩
    local layer = cc.Layer:create()
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(function(event,touch) return true end,cc.Handler.EVENT_TOUCH_BEGAN)
    listener1:registerScriptHandler(function(event,touch)end,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, layer)
    self:addChild(layer)

    -- if para.type > #self.uis then loge("----ui type error----",ShareView.TAG) end
    para.type = SHARE_SHOW_TYPE_PH
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.share_rank)
    -- local scale = s1.width / 1920
    -- self:setScale(scale)
    self:addChild(self.gui)
    self:initUI(para)
end

--初始化UI
function ShareView:initUI(data)
    dump(data)
    if data.type == SHARE_SHOW_TYPE_PH then --排行
        local labs = {
            "zzj",--周战绩
            "zyl",--周盈利
            "rdj",--日单局
            "cfb",--财富
            "sj_zzj",--世界周战绩
            "sj_zyl",--世界周盈利
            "sj_rdj",--世界日单局
            "sj_cfb",--世界财富
            "mn",--美女
            "szmn",--上周
        }
        local lab = "ui/share/share_rank/share_lab_"..labs[data.title]..".png"
        local img_rank =  "ui/share/share_rank/"..data.rank..".png"

        ccui.Helper:seekWidgetByName(self.gui,"pan_show"):getChildByName("lab_title"):loadTexture(lab)
        ccui.Helper:seekWidgetByName(self.gui,"pan_share"):getChildByName("lab_title"):loadTexture(lab)
        ccui.Helper:seekWidgetByName(self.gui,"pan_show"):getChildByName("img_rank_2"):loadTexture(img_rank)
        ccui.Helper:seekWidgetByName(self.gui,"pan_share"):getChildByName("img_rank_2"):loadTexture(img_rank)

        if data.rank < 4 then
            local img_icon =  "ui/share/share_rank/icon_"..data.rank..".png"
            ccui.Helper:seekWidgetByName(self.gui,"pan_show"):getChildByName("img_rank_1"):loadTexture(img_icon)
            ccui.Helper:seekWidgetByName(self.gui,"pan_share"):getChildByName("img_rank_1"):loadTexture(img_icon)
        else
            ccui.Helper:seekWidgetByName(self.gui,"pan_show"):getChildByName("img_rank_1"):setVisible(false)
            ccui.Helper:seekWidgetByName(self.gui,"pan_share"):getChildByName("img_rank_1"):setVisible(false)
        end
    end

    local showUserInfo = function(suffix)
        if ccui.Helper:seekWidgetByName(self.gui,"img_head"..suffix) then
            local function changeStatus(btn,paras)
                if paras.coat and paras.type == 1 then
                    local c = cc.Sprite:create(GameRes[paras.coat])
                    c.setScale(c,-1,-1)
                    c:setPosition(btn:getContentSize().width/2,btn:getContentSize().height/2)
                    btn:removeAllChildren(true)
                    btn:addChild(c)
                end
                if paras.coat then
                    local c = cc.Sprite:create(GameRes[paras.coat])
                    c:setPosition(btn:getContentSize().width/2,btn:getContentSize().height/2)
                    btn:removeAllChildren(true)
                    btn:addChild(c)
                end
            end
            local img_head = ccui.Helper:seekWidgetByName(self.gui,"img_head"..suffix)
            Util:updateUserHead(img_head,Cache.user.portrait,Cache.user.sex, {add=true, url=true})
            -- local scale = 184/130
            -- img_head:setScale(scale)
        end

        if ccui.Helper:seekWidgetByName(self.gui,"lab_name"..suffix) then
            ccui.Helper:seekWidgetByName(self.gui,"lab_name"..suffix):setString(Cache.user.nick)
        end

        if ccui.Helper:seekWidgetByName(self.gui,"lab_day"..suffix) then
            ccui.Helper:seekWidgetByName(self.gui,"lab_day"..suffix):setString(os.date("%Y-%m-%d", os.time()))
        end
    end

    showUserInfo("")
    showUserInfo("_1")
    ccui.Helper:seekWidgetByName(self.gui,"btn_wx"):addTouchEventListener(
        function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self.scene = 1
                self.type = 3
                self:saveImage(ccui.Helper:seekWidgetByName(self.gui,"pan_share"))
                MusicPlayer:playMyEffect("BTN")
            end
        end
    )

    ccui.Helper:seekWidgetByName(self.gui,"btn_qq"):addTouchEventListener(
        function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self.scene = 1
                self.type = 1
                self:saveImage(ccui.Helper:seekWidgetByName(self.gui,"pan_share"))
                MusicPlayer:playMyEffect("BTN")
            end
        end
    )

    ccui.Helper:seekWidgetByName(self.gui,"btn_fb"):addTouchEventListener(
        function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self.scene = 2
                self.type = 3
                self:saveImage(ccui.Helper:seekWidgetByName(self.gui,"pan_share"))
                MusicPlayer:playMyEffect("BTN")
            end
        end
    )

    ccui.Helper:seekWidgetByName(self.gui,"btn_close"):addTouchEventListener(
        function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:close()
                MusicPlayer:playMyEffect("BTN")
            end
        end
    )

end

function ShareView:saveImage(node)
    self:reset()
    local s1 = cc.Director:getInstance():getWinSize()
    local s = node:getContentSize()
    local scale = 0.5
    node:setVisible(true)
    node:setScale(scale)
    node:setAnchorPoint(cc.p(0,0))
    node:setPosition(cc.p(0,0))
    local jpg = fileName
    local target = cc.RenderTexture:create(s.width*scale, s.height*scale, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    target:retain()
    target:setPosition(cc.p(s1.width*scale / 2, s1.height*scale / 2))
    target:begin()
    node:visit()
    target:endToLua()
    target:saveToFile(jpg, cc.IMAGE_FORMAT_JPEG, false) -- JPG不支持RGBA，传3参数，第3个参数必须为false
    target:release()
    node:setVisible(false)

    local function checkFile()
        if cc.FileUtils:getInstance():isFileExist(share_img_path) then
            self:share()
            self:close()
        else
            performWithDelay(self,function()
                checkFile()
            end,0.5)
        end
    end
    checkFile()
end

function ShareView:share()
    --        share=paras.share, --1只分享大图  2是图文链接
    --        scene=paras.scene, --1发给朋友 2发朋友圈或qq空间
    --        localPath=paras.localPath, --本地图片绝对路径
    --        targetUrl=paras.targetUrl, --打开的链接
    --        description=paras.description, --描述
    --        title=paras.title, --标题
    local info ={
        type = self.type,
        share = 2,
        scene = self.scene,
        localPath = share_img_path,
        description = share_desc,
        cb = function () 
            if self.reset then
                self:reset() -- 这一步应该放到一个全局方法里，否则可能执行不到
            end
        end
    }
    qf.platform:sdkShare(info)
end

function ShareView:reset()
    local function  deleteFile(path)
        local targetPlatform = cc.Application:getInstance():getTargetPlatform()
        if targetPlatform == cc.PLATFORM_OS_WINDOWS then
            path = string.gsub(path, '/', '\\')
            os.execute("del "..path)
        else
    		if io.exists(path) then
				os.remove(path)
			end
        end
    end
    deleteFile(share_img_path)
end

function ShareView:getRoot()
    return LayerManager.PopupLayer
end

function ShareView:close()
    ModuleManager.share:remove()
end

return ShareView