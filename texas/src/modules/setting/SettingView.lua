local SettingView = class("SettingView", CommonWidget.BasicWindow)

SettingView.TAG = "SettingView"

SettingView._ACTION_TAG = 201507081617      --开关动作tag
SettingView._MUSIC_TAG  = 201507081618      --音乐开关tag
SettingView._SOUND_TAG  = 201507081619      --音效开关tag
SettingView._SHOCK_TAG  = 201507081620      --震动开关tag

SettingView._FRAME_DELAY = 0.015            --帧间隔时间
SettingView._FRAME_LENGTH = 15              --开关序列帧数
SettingView._SWITCH_DELAY = 0.3           --开关点击间隔
SettingView.QuickStartGame = {    
    {name="斗地主",game="game_ddz"},      --快速开始游戏
    {name="双扣",game="game_shuangQ"},
    -- {name="拼三张",game="game_zjh"},
    -- {name="经典看牌",game="game_niuniu"}
}
local IButton = import(".components.IButton")
local AboutView = import(".components.AboutView")
local AgreementView = import(".components.AgreementView")
local PrivacyView = import(".components.PrivacyView")

function SettingView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    SettingView.super.ctor(self,parameters)
    self:showSetingView()
    self:QuickStartGameChoose()
    qf.platform:umengStatistics({umeng_key = "Setting"})
end

--[[第一个界面的控件表]]
SettingView.setList = {}
--[[setting_scrollview中的控件表]]
SettingView.setScrollviewList = {}

function SettingView:init()
    self.isHelp = 1 --记录在帮助页面下的哪一页
    self.isOption = 1 --操作介绍的位置
    self.isActing=false
end

function SettingView:initUI( ... )
    -- body
    local tableUI={}
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.settingViewJson)
    self.scrollview=ccui.Helper:seekWidgetByName(self.gui,"setting_scrollview")
    self.scrollview:setBounceEnabled(false)
    self.zhP=ccui.Helper:seekWidgetByName(self.gui,"zhP")
    -- self.ljksszP=ccui.Helper:seekWidgetByName(self.gui,"ljksszP")
    self.yxxxP=ccui.Helper:seekWidgetByName(self.gui,"yxxxP")
    self.qtP=ccui.Helper:seekWidgetByName(self.gui,"qtP")
    self.bindWXBtn = ccui.Helper:seekWidgetByName(self.zhP,"bindWXBtn")
    self.bindSuccessLabel = ccui.Helper:seekWidgetByName(self.zhP,"bindSuccessLabel")
    self.bindWechatTips = ccui.Helper:seekWidgetByName(self.gui,"bindWechatTips")
    self.zhbgimg = ccui.Helper:seekWidgetByName(self.gui,"zhbgimg")

    
    self.bindWechatTips:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.3,255),cc.DelayTime:create(3),cc.FadeTo:create(0.3,0),cc.DelayTime:create(10))))
    if Cache.user.is_bind_wx == 0 and Cache.Config.promoter_support and TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.bindWXBtn:setVisible(true)
        self.bindSuccessLabel:setVisible(false)
        self.bindWechatTips:setVisible(true)
    else
        self.bindWXBtn:setVisible(false)
        self.bindSuccessLabel:setVisible(true)
        self.bindWechatTips:setVisible(false)
    end

    if CHANNEL_NEED_WEIXIN_BAND_FLAG == false then
        self.bindWXBtn:setVisible(false)
        self.bindSuccessLabel:setVisible(false)
        self.bindWechatTips:setVisible(false)
        self.zhbgimg:getChildByName("bg"):setVisible(true)
    else
        self.zhbgimg:getChildByName("bg"):setVisible(false)
    end

    addButtonEvent(self.bindWXBtn,function()
        qf.event:dispatchEvent(ET.EVENT_BAND_WEIXIN,{cb = function (data)

            self.bindWXBtn:setVisible(false)
            self.bindSuccessLabel:setVisible(true)
            self.bindWechatTips:setVisible(false)
        end})
    end)

    if not Cache.Config.promoter_support or not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.bindSuccessLabel:setVisible(false)
    end

    table.insert(tableUI,self.zhP)
    table.insert(tableUI,self.yxxxP)
    table.insert(tableUI,self.qtP)

    self:initControl()
    self:initShowWord()
end

--[[初始化各个控件]]
function SettingView:initControl()
    self:getTableChild({"setting_title_img","setting_back_btn","setting_scrollview"},self.gui,self.setList)
    self:getTableChild({ "setting_account_txt","setting_version_txt"
        ,"setting_version","img_bg_abort","img_bg_protocol","img_bg_privacy","gameitemP","gamelist"
        ,"setting_music_btn_img"
        ,"setting_sound_btn_img","setting_shock_state_txt"
        ,"setting_sound_state_txt","setting_music_state_txt", "setting_shock_btn_img"},self.setList.setting_scrollview,self.setScrollviewList)
end

--[[初始化文字显示]]
function SettingView:initShowWord()
    self.setScrollviewList.setting_account_txt:setString(Cache.user.uin)                        --玩家账号
    self.setScrollviewList.setting_version:setString(GAME_BASE_VERSION)                            --版本
    self:updateGameConfig()
end

function SettingView:updateGameConfig()
    local b = cc.UserDefault:getInstance():getBoolForKey(SKEY.SETTINGS_MUSIC,MusicPlayer.hasMusic)
    self.setScrollviewList.setting_music_state_txt:setString(b and GameTxt.setting_txt_open or GameTxt.setting_txt_close)
    self.setScrollviewList.setting_music_btn_img:getChildByName("img"):loadTexture(b and GameRes.setting_btn_open or GameRes.setting_btn_openclose)
    local b = cc.UserDefault:getInstance():getBoolForKey(SKEY.SETTINGS_EFFECT,MusicPlayer.hasEffect)
    self.setScrollviewList.setting_sound_state_txt:setString(b and GameTxt.setting_txt_open or GameTxt.setting_txt_close)
    self.setScrollviewList.setting_sound_btn_img:getChildByName("img"):loadTexture(b and GameRes.setting_btn_open or GameRes.setting_btn_openclose)
    local b = cc.UserDefault:getInstance():getBoolForKey(SKEY.SETTINGS_SHOCK, true)
    self.setScrollviewList.setting_shock_state_txt:setString(b and GameTxt.setting_txt_open or GameTxt.setting_txt_close)
    self.setScrollviewList.setting_shock_btn_img:getChildByName("img"):loadTexture(b and GameRes.setting_btn_open or GameRes.setting_btn_openclose)
end

--[[进入初始最开始那一页]]
function SettingView:showSetingView()
    logd("初始开始的那一页",self.TAG)
    self:refreshBtnStatus({type="init",from={"music","sound","shock"},value={MusicPlayer.hasMusic,MusicPlayer.hasEffect,SHOCK_SETTING}})
end

--[[进入关于页面]]
function SettingView:showAboutView()
    PopupManager:push({class = AboutView})
    PopupManager:pop()
end
--[[进入用户协议页面]]
function SettingView:showAgreementView()
    PopupManager:push({class = AgreementView})
    PopupManager:pop()
end

--[[进入隐私策略页面]]
function SettingView:showPrivacyView()
    PopupManager:push({class = PrivacyView})
    PopupManager:pop()
end

-- --[[立即开始设置]]
function SettingView:QuickStartGameChoose(  )
    -- body
    local gamechoose=cc.UserDefault:getInstance():getStringForKey(SKEY.QUICKSTARTGAME,"game_ddz")
    self.gamelist={}
    dump(self.QuickStartGame)
    for m,n in pairs(self.QuickStartGame)do
        local game = n
        if n then
            local gameItem=self.setScrollviewList.gameitemP:clone()
            gameItem:setVisible(true)
            gameItem:getChildByName("gamename"):setString(game.name)
            gameItem:setName(game.game)
            if game.game==gamechoose then
                gameItem:getChildByName("gamechoose"):setVisible(true)
            else
                gameItem:getChildByName("gamechoose"):setVisible(false)
            end
            local gamename=game.game
            addButtonEvent(gameItem:getChildByName("gamechoosearea"),function ()
                cc.UserDefault:getInstance():setStringForKey(SKEY.QUICKSTARTGAME,gamename)
                for k,v in pairs(self.gamelist) do
                    if v:getName()==gamename then
                        v:getChildByName("gamechoose"):setVisible(true)
                    else
                        v:getChildByName("gamechoose"):setVisible(false)
                    end
                end
                qf.event:dispatchEvent(ET.SETTING_QUICK_START_CHOOSE_CHANGE)
            end)
            table.insert(self.gamelist,gameItem)
            self.setScrollviewList.gamelist:pushBackCustomItem(gameItem)
        end
    end
end

--[[刷新音乐，音效，震动按钮状态]]
function SettingView:refreshBtnStatus(paras)
    -- if MusicPlayer.hasMusic then
    --     self.setScrollviewList.setting_music_btn_img:loadTexture(GameRes.setting_btn_open)
    -- else
    --     self.setScrollviewList.setting_music_btn_img:loadTexture(GameRes.setting_btn_openclose)
    -- end
    -- if SHOCK_SETTING then
    --     self.setScrollviewList.setting_shock_btn_img:loadTexture(GameRes.setting_btn_open)
    -- else
    --     self.setScrollviewList.setting_shock_btn_img:loadTexture(GameRes.setting_btn_openclose)
    -- end
    -- if MusicPlayer.hasEffect then
    --     self.setScrollviewList.setting_sound_btn_img:loadTexture(GameRes.setting_btn_open)
    -- else
    --     self.setScrollviewList.setting_sound_btn_img:loadTexture(GameRes.setting_btn_openclose)
    -- end
    if paras.type == "init" then
        logd("初始打开设置界面",self.TAG)
    elseif paras.type == "switch" then
        logd("切换开关状态，已经赋值value",self.TAG)
    end
    self:switchChange(paras)
end

--[[初始化开关样式]]
-- function SettingView:initSwitch()
--     local plist = GameRes["setting_switch_plist"]
--     local plist1 = GameRes["setting_switch_plist1"]
--     local png = GameRes["setting_switch_png"]
--     self.posx = self.setScrollviewList.setting_music_btn_img:getContentSize().width/2
--     self.posy = self.setScrollviewList.setting_music_btn_img:getContentSize().height/2
--     self.frameCache = cc.SpriteFrameCache:getInstance()
--     self.frameCache:addSpriteFrames(plist,png)
    
--     self.animFrames = {}
--     for i=1,self._FRAME_LENGTH do
--         local frame = self.frameCache:getSpriteFrame(string.format("switch_%d.png", i))
--         self.animFrames[i] = frame
--     end


--     local plist1 = GameRes["setting_switch_plist1"]
--     local png1   = GameRes["setting_switch_png1"]
--     self.frameCache:addSpriteFrames(plist1,png1)
--     self.animFrames1 = {}
--     for i=1,self._FRAME_LENGTH do
--         local frame = self.frameCache:getSpriteFrame(string.format("switch1_%d.png", i))
--         self.animFrames1[i] = frame
--     end



--     self.switch_music = cc.Sprite:createWithSpriteFrame(self.animFrames[1])
--     self.switch_shock = cc.Sprite:createWithSpriteFrame(self.animFrames[1])
--     self.switch_sound = cc.Sprite:createWithSpriteFrame(self.animFrames[1])
--     self.switch_music:setVisible(false)
--     self.switch_shock:setVisible(false)
--     self.switch_sound:setVisible(false)
--     self.switch_music:setPosition(cc.p(self.posx,self.posy))
--     self.switch_shock:setPosition(cc.p(self.posx,self.posy))
--     self.switch_sound:setPosition(cc.p(self.posx,self.posy))
--     self.switch_music:setTag(self._MUSIC_TAG)
--     self.switch_shock:setTag(self._SHOCK_TAG)
--     self.switch_sound:setTag(self._SOUND_TAG)
--     self.setScrollviewList.setting_music_btn_img:addChild(self.switch_music)
--     self.setScrollviewList.setting_shock_btn_img:addChild(self.switch_shock)
--     self.setScrollviewList.setting_sound_btn_img:addChild(self.switch_sound)
-- end

-- @function 改变开关(type为init时，from为table，type为switch时，from为string)
-- @param self
-- @param {type="",value=bool,from=table or string}
function SettingView:switchChange(paras)
    -- local function playAnimation(paras,node)
    --     if paras.value == true then
    --         self.animFrames = {}
    --         for i=self._FRAME_LENGTH,1,-1 do
    --             local frame = self.frameCache:getSpriteFrame(string.format("switch1_%d.png", i))
    --             self.animFrames[self._FRAME_LENGTH+1-i] = frame
    --         end
    --     else
    --         self.animFrames = {}
    --         for i=1,self._FRAME_LENGTH do
    --             local frame = self.frameCache:getSpriteFrame(string.format("switch_%d.png", i))
    --             self.animFrames[i] = frame
    --         end
    --     end
    --     local animation = cc.Animation:createWithSpriteFrames(self.animFrames,self._FRAME_DELAY)
    --     local func = function()
    --         if self.isPlaying ~= self.isPlayingFlag then
    --             node:stopActionByTag(self._ACTION_TAG)
    --         end
    --     end
    --     local func_flag = function ()
    --         node:setVisible(true)
    --         node:getParent():getChildByName("img"):setVisible(false)
    --         if paras.value then
    --             node:getParent():getChildByName("img"):loadTexture(not paras.value and GameRes.setting_btn_open or GameRes.setting_btn_openclose)
    --         end
    --         if self.isPlaying == true then
    --             self.isPlaying = false
    --         else
    --             self.isPlaying = true
    --         end
    --     end
    --     local action = cc.Animate:create(animation)
    --     action:setTag(self._ACTION_TAG)
    --     node:runAction(cc.Sequence:create(cc.CallFunc:create(func_flag), cc.CallFunc:create(function( ... )
    --             node:setVisible(false)
    --             node:getParent():getChildByName("img"):setVisible(true)
    --             if not paras.value then
    --                 node:getParent():getChildByName("img"):loadTexture(not paras.value and GameRes.setting_btn_open or GameRes.setting_btn_openclose)
    --             end
    --     end)))
    -- end

    if paras.type == "init" then
        -- for key, var in pairs(paras.from) do
        -- 	if var == "music" then
        --         self.setScrollviewList.setting_music_btn_img:removeChildByTag(self._MUSIC_TAG)
        --         if paras.value[key] == true then
        --             self.switch_music = cc.Sprite:createWithSpriteFrame(self.animFrames1[self._FRAME_LENGTH])
                    
        --         else
        --             self.switch_music = cc.Sprite:createWithSpriteFrame(self.animFrames[1])
        --         end
        --         self.switch_music:setScale(1.3)
        --         self.switch_music:setTag(self._MUSIC_TAG)
        --         self.switch_music:setPosition(cc.p(self.posx,self.posy))
        --         self.setScrollviewList.setting_music_btn_img:addChild(self.switch_music)
        --     elseif var == "sound" then
        --         self.setScrollviewList.setting_sound_btn_img:removeChildByTag(self._SOUND_TAG)
        --         if paras.value[key] == true then
        --             self.switch_sound = cc.Sprite:createWithSpriteFrame(self.animFrames1[self._FRAME_LENGTH])
                    
        --         else
        --             self.switch_sound = cc.Sprite:createWithSpriteFrame(self.animFrames[1])
        --         end
        --         self.switch_sound:setScale(1.3)
        --         self.switch_sound:setTag(self._SOUND_TAG)
        --         self.switch_sound:setPosition(cc.p(self.posx,self.posy))
        --         self.setScrollviewList.setting_sound_btn_img:addChild(self.switch_sound)
        --     elseif var == "shock" then
        --         self.setScrollviewList.setting_shock_btn_img:removeChildByTag(self._SHOCK_TAG)
        --         if paras.value[key] == true then
        --             self.switch_shock = cc.Sprite:createWithSpriteFrame(self.animFrames1[self._FRAME_LENGTH])
                    
        --         else
        --             self.switch_shock = cc.Sprite:createWithSpriteFrame(self.animFrames[1])
        --         end
        --         self.switch_shock:setScale(1.3)
        --         self.switch_shock:setTag(self._SHOCK_TAG)
        --         self.switch_shock:setPosition(cc.p(self.posx,self.posy))
        --         self.setScrollviewList.setting_shock_btn_img:addChild(self.switch_shock)
        -- 	end
        -- end
    elseif paras.type == "switch" then
        if paras.from == "music" then
            self.setScrollviewList.setting_music_state_txt:setString(not paras.value and GameTxt.setting_txt_open or GameTxt.setting_txt_close)
        elseif paras.from == "sound" then
            self.setScrollviewList.setting_sound_state_txt:setString(not paras.value and GameTxt.setting_txt_open or GameTxt.setting_txt_close)
        elseif paras.from == "shock" then
            self.setScrollviewList.setting_shock_state_txt:setString(not paras.value and GameTxt.setting_txt_open or GameTxt.setting_txt_close)
        end
        self:updateGameConfig()
    end
    
end

function SettingView:showCancellation()
    qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content=GameTxt.cancellation_txt, type = 6,is_enabled = false,color=cc.c3b(143,80,39),fontsize=38,
            cb_consure = function ( ... )
                qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
            end,
            cb_cancel=function( ... )
        end})
end

--[[初始化按键]]
function SettingView:initClick()
    addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"setting_cancle_btn"),function() 
        self:showCancellation()
    end)

    loga( ModuleManager:judegeIsInMain())
    if string.find(GAME_CHANNEL_NAME,"CN_AD_OPPO1") or not ModuleManager:judegeIsInMain() then
       ccui.Helper:seekWidgetByName(self.gui,"setting_cancle_btn"):setVisible(false)
    end
    self.setScrollviewList.setting_music_btn_img = IButton.new({node=self.setScrollviewList.setting_music_btn_img})          --音乐开关
    self.setScrollviewList.setting_sound_btn_img = IButton.new({node=self.setScrollviewList.setting_sound_btn_img})          --音效开关
    self.setScrollviewList.setting_shock_btn_img = IButton.new({node=self.setScrollviewList.setting_shock_btn_img})          --震动开关
    --self.setScrollviewList.img_bg_teach = IButton.new({node=self.setScrollviewList.img_bg_teach})          --新手教程
    self.setScrollviewList.img_bg_abort = IButton.new({node=self.setScrollviewList.img_bg_abort})          --关于
    self.setScrollviewList.img_bg_agreement = IButton.new({node=self.setScrollviewList.img_bg_protocol})   --用户协议
    self.setScrollviewList.img_bg_privacy = IButton.new({node=self.setScrollviewList.img_bg_privacy})      --隐私策略
    --self.setScrollviewList.img_bg_help = IButton.new({node=self.setScrollviewList.img_bg_help})            --帮助
    self.gui:getChildByName("setting_background_img"):setTouchEnabled(true)
    
    self.setList.setting_back_btn = IButton.new({node=self.setList.setting_back_btn})                    --关闭
    self.gui:setTouchEnabled(true)
    self.gui = IButton.new({node=self.gui})                                --关闭
        
    self.setScrollviewList.setting_music_btn_img:setCallback(function() --音乐开关
        if self.isActing==false then
            self.isActing=true
            self.setScrollviewList.setting_music_btn_img:setSelect(false)
            local paras = {type="switch",value=MusicPlayer.hasMusic,from="music"}
            if MusicPlayer.hasMusic then
                MusicPlayer.hasMusic = false MusicPlayer:stopBackGround()
            else
                MusicPlayer.hasMusic = true MusicPlayer:playBackGround()
            end
            cc.UserDefault:getInstance():setBoolForKey(SKEY.SETTINGS_MUSIC,MusicPlayer.hasMusic)
            cc.UserDefault:getInstance():flush()
            self:refreshBtnStatus(paras)
            Cache.clickNum = 1
            Util:delayRun(self._SWITCH_DELAY,function() self.isActing=false end)
        end
    end
    )
    self.setScrollviewList.setting_sound_btn_img:setCallback(function() --音效开关
        if self.isActing==false then
            self.isActing=true
            self.setScrollviewList.setting_sound_btn_img:setSelect(false)
            local paras = {type="switch",value=MusicPlayer.hasEffect,from="sound"}
            if MusicPlayer.hasEffect then
                MusicPlayer.hasEffect = false
            else
                MusicPlayer.hasEffect = true
            end
            cc.UserDefault:getInstance():setBoolForKey(SKEY.SETTINGS_EFFECT,MusicPlayer.hasEffect)
            cc.UserDefault:getInstance():flush()
            self:refreshBtnStatus(paras)
            Cache.clickNum = 1
            Util:delayRun(self._SWITCH_DELAY,function() self.isActing=false end)
        end
    end
    )
    self.setScrollviewList.setting_shock_btn_img:setCallback(function() --震动开关
        if self.isActing==false then
            self.isActing=true
            self.setScrollviewList.setting_shock_btn_img:setSelect(false)
            local paras = {type="switch",value=SHOCK_SETTING,from="shock"}
            if SHOCK_SETTING then
                SHOCK_SETTING = false
            else
                SHOCK_SETTING = true
            end
            cc.UserDefault:getInstance():setBoolForKey(SKEY.SETTINGS_SHOCK,SHOCK_SETTING)
            cc.UserDefault:getInstance():flush()
            self:refreshBtnStatus(paras)
            Cache.clickNum = 1
            Util:delayRun(self._SWITCH_DELAY,function() self.isActing=false end)
        end
    end
    )
    -- self.setScrollviewList.img_bg_teach:setCallback(function() --新手教程
    --     self.setScrollviewList.img_bg_teach:setSelect(false)
    --     self:showCourseView()
    --     end
    -- )
    self.setScrollviewList.img_bg_abort:setCallback(function ()--关于
        self.setScrollviewList.img_bg_abort:setSelect(false)
        self:showAboutView()
        end
    )

    self.setScrollviewList.img_bg_agreement:setCallback(function ()--用户协议
        self.setScrollviewList.img_bg_agreement:setSelect(false)
        self:showAgreementView()
        end
    )

    self.setScrollviewList.img_bg_privacy:setCallback(function ()--隐私策略
        self.setScrollviewList.img_bg_privacy:setSelect(false)
        self:showPrivacyView()
        end
    )
    
    self.setList.setting_back_btn:setCallback(function ()--回退
            self:close()
        end
    )
    
    self.gui:setCallback(function ()--回退
    end
    )
end

function SettingView:getTableChild(keyTable,father,son)
	for key, v in pairs(keyTable) do
	   son[v] = ccui.Helper:seekWidgetByName(father, v)
	end
end

return SettingView