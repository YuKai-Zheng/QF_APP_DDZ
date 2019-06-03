local Invite = class("Invite",CommonWidget.BasicWindow)
local IButton = import(".IButton")
local UserHead = import("...change_userinfo.components.userHead")--我的头像
local MatchAnimationNode = import("...game.components.animation.MatchAnimationNode")

local share_desc = ""

local StarPos = {
    {cc.p(0, 190)},
    {cc.p(-50,190),cc.p(50,190)},
    {cc.p(-100,160),cc.p(0,190),cc.p(100,160)},
    {cc.p(-105,170),cc.p(-40,200),cc.p(40,200),cc.p(105,170)},
    {cc.p(-120,145),cc.p(-65,175),cc.p(0,190),cc.p(65,175),cc.p(120,145)},
}

function Invite:ctor(paras)
    Invite.super.ctor(self, paras)
end
function Invite:show()
    Invite.super.show(self)
end
function Invite:init(paras)
    self.cb = paras.cb
    self:initData(paras)
    self:saveImage()
end

function Invite:initData(paras)
    self.fileName = paras.fileName--"icon.jpg"
    self.shareType = paras.shareType
    self.share_img_path = cc.FileUtils:getInstance():getWritablePath() .. self.fileName
    self.honorNode = paras.honorNode or nil
    self.gameResultNode = nil
    self.exchangeResultNode = nil
end

function Invite:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes["inviteView_"..paras.type])
    --关闭界面
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

function Invite:saveImage()
    -- 分享自己的邀请二维码
    if self.shareType == 1 then
        local imgName = string.format("qrCode_%d.png",Cache.user.uin)
        local textureName = cc.FileUtils:getInstance():getWritablePath() .. imgName
        local pos = cc.p(540, 400)
        local scale = 1
        if qf.device.platform == "android" then
            textureName = qf.platform:getExternalPath() .. "/" .. imgName
        end

        shareImgBgName = GameRes.invite_img_1

        local info = {
            parentFilePath = shareImgBgName,
            childFilePath = textureName,
            childPosition =  pos,
            convertFileName = self.fileName,
            bSave = true,
            scale = scale
        }
        Util:convertNodeToPictrue(info)
    end

    -- 分享微信公众号
    if self.shareType == 2 then
        Util:generatePic(self.fileName, GameRes.weixingongzonghao)
    end

    -- 分享比赛结果
    if self.shareType == 3 then
        self:updateGameResultInfo()
    end

    -- 分享兑换物品
    if self.shareType == 4 then
        self:updateExchangeResultInfo()
    end

    -- 分享赛季战报
    if self.shareType == 5 then
        self:updateMatchingHonorInfo()
    end
end

 function Invite:updateGameResultInfo(paras)
    if self.gameResultNode == nil then
        self.gameResultNode = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.shareGameResultJson)
    end
    local bg = self.gameResultNode:getChildByName("bg")

    local matchLevel = Cache.user.all_lv_info
    local match_lv = matchLevel.match_lv > 30 and matchLevel.match_lv / 10 or 1

    bg:getChildByName("golden"):loadTexture(string.format( DDZ_Res.matchLevelAnimation_icon, matchLevel.match_lv / 10), ccui.TextureResType.plistType)
    bg:getChildByName("golden"):getChildByName("title_content"):loadTexture(string.format( DDZ_Res.matchLevelAnimation_bottom,match_lv), ccui.TextureResType.plistType)

    local label = bg:getChildByName("golden"):getChildByName("title_content"):getChildByName("title")
    label:setFntFile(string.format( DDZ_Res.matchLevel_bottom_fnt, matchLevel.match_lv <= 30 and 1 or matchLevel.match_lv >= 60 and 7 or matchLevel.match_lv / 10 ))

    label:setString(Util:getMatchLevelTxt(matchLevel))

    bg:getChildByName("golden"):getChildByName("left"):loadTexture(string.format( DDZ_Res.matchLevelAnimation_wing,"left", matchLevel.match_lv/ 10), ccui.TextureResType.plistType)
    bg:getChildByName("golden"):getChildByName("right"):loadTexture(string.format( DDZ_Res.matchLevelAnimation_wing,"right", matchLevel.match_lv/ 10), ccui.TextureResType.plistType)

    local star_panel = bg:getChildByName("golden"):getChildByName("star_panel")

    if match_lv >= 70 then
        local star = cc.Sprite:create(DDZ_Res.match_xingxing)
        star:setPosition(StarPos[1][1])

        if matchLevel.star > 1 then
            local wangzheStarTxtNum = cc.LabelBMFont:create()
            wangzheStarTxtNum:setFntFile(DDZ_Res.wangzheStarNum)
            wangzheStarTxtNum:setString("x" .. nowLevel.star)
            wangzheStarTxtNum:setVisible(false)
            wangzheStarTxtNum:setPositionY(140)
            star_panel:addChild(wangzheStarTxtNum, 100)
        end
    else
        for i = 1, matchLevel.sub_lv_star_num do
            local star = cc.Sprite:create(DDZ_Res.match_xingxing)
            star:setPosition(StarPos[matchLevel.sub_lv_star_num][i])
            star_panel:addChild(star)
            if i > matchLevel.star then
                star:setTexture(DDZ_Res.match_xingxing_bg)
            end
        end
    end

    

    local userInfoNode = bg:getChildByName("userInfo")
    Util:updateUserHead(userInfoNode, Cache.user.portrait, Cache.user.sex, {add = true, sq = true, url = true})
    local nickName = Util:filterEmoji(Cache.user.nick) or ""
    userInfoNode:getChildByName("name"):setString(nickName)

    local fileName = string.format("qrCodeX279_%d.png",Cache.user.uin)
    qf.platform:createQRCode({
        qrCodeStr = HOST_SHARE_NAME .."/wx/user_share?uin=" .. Cache.user.uin,
        qyCodeFileName = fileName,
        size = 279
    })

    local textureName = cc.FileUtils:getInstance():getWritablePath() .. fileName
    if qf.device.platform == "android" then
        textureName = qf.platform:getExternalPath() .. "/" .. fileName
    end
    if self.gameResultNode:getChildByName("bg") then
        self.gameResultNode:getChildByName("bg"):getChildByName("qrCode"):loadTexture(textureName)
        Util:generateScreenPic(self.gameResultNode, self.fileName)
    end
 end

 function Invite:updateExchangeResultInfo(paras)
    self.exchangeResultNode = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.shareGoodExchangeJson)
    local bg = self.exchangeResultNode:getChildByName("bg")
    -- logo
    local logoImg = bg:getChildByName("logo")
    logoImg:loadTexture(GameRes.logo_img_1)

    local userInfoNode = bg:getChildByName("userInfo")
    Util:updateUserHead(userInfoNode, Cache.user.portrait, Cache.user.sex, {add = true, sq = true, url = true})
    local nickName = Util:filterEmoji(Cache.user.nick) or ""
    userInfoNode:getChildByName("name"):setString(nickName)

    local fileName = string.format("qrCodeX279_%d.png",Cache.user.uin)
    qf.platform:createQRCode({
        qrCodeStr = HOST_SHARE_NAME .."/wx/user_share?uin=" .. Cache.user.uin,
        qyCodeFileName = fileName,
        size = 279
    })
    local textureName = cc.FileUtils:getInstance():getWritablePath() .. fileName
    if qf.device.platform == "android" then
        textureName = qf.platform:getExternalPath() .. "/" .. fileName
    end
    if self.exchangeResultNode:getChildByName("bg") then
        self.exchangeResultNode:getChildByName("bg"):getChildByName("qrCode"):loadTexture(textureName)
        Util:generateScreenPic(self.exchangeResultNode, self.fileName)
    end
 end

function Invite:updateMatchingHonorInfo(paras)
    if self.honorNode == nil then
        self.honorNode = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.matchingHonor)
    end
    ccui.Helper:seekWidgetByName(self.honorNode,"panel_honer"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.honorNode,"panel_new_season"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.honorNode,"avatar_frame"):setVisible(true)
    ccui.Helper:seekWidgetByName(self.honorNode,"qrCode"):setVisible(true)

    local userInfoNode = ccui.Helper:seekWidgetByName(self.honorNode,"avatar_frame")
    ccui.Helper:seekWidgetByName(self.honorNode,"name"):setString(Cache.user.nick)

    local userHead = UserHead.new({})
    self.headInfoDetail = userHead:getUI()
    self.headInfoDetail:setVisible(true)

    local headInfoSize = userInfoNode:getContentSize()
    local headInfoDetailSize = self.headInfoDetail:getContentSize()

    self.headInfoDetail:setPosition( -(headInfoDetailSize.width*0.85 - headInfoSize.width)/2,-(headInfoDetailSize.height*0.85 - headInfoSize.height)/2)
    userInfoNode:addChild(self.headInfoDetail)
    self.headInfoDetail:setScale(0.85)
    userHead:loadHeadImage(Cache.user.portrait,Cache.user.sex,Cache.user.icon_frame)

    local fileName = string.format("qrCodeX279_%d.png",Cache.user.uin)
    qf.platform:createQRCode({
        qrCodeStr = HOST_SHARE_NAME .."/wx/user_share?uin=" .. Cache.user.uin,
        qyCodeFileName = fileName,
        size = 213
    })
    local textureName = cc.FileUtils:getInstance():getWritablePath() .. fileName
    if qf.device.platform == "android" then
        textureName = qf.platform:getExternalPath() .. "/" .. fileName
    end
    ccui.Helper:seekWidgetByName(self.honorNode,"qrCode"):loadTexture(textureName)

    Util:generateScreenPic(self.honorNode, self.fileName)
    ccui.Helper:seekWidgetByName(self.honorNode,"panel_honer"):setVisible(true)
    ccui.Helper:seekWidgetByName(self.honorNode,"avatar_frame"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.honorNode,"qrCode"):setVisible(false)
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
        localPath = self.share_img_path,
        description = share_desc,
        cb = function ()
            if self.cb then
                self.cb()
            end
            self:close()
        end
    }
    qf.platform:umengStatistics({umeng_key = "share"})--点击上报
    dump(info)
    qf.platform:sdkShare(info)
end

return Invite