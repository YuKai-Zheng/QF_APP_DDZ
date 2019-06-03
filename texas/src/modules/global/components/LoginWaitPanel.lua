local LoginWaitPanel = class("LoginWaitPanel",function(paras) 
    return ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.loginLayoutJson)
end)

LoginWaitPanel.TAG = "LoginWaitPanel"

function LoginWaitPanel:ctor(parameters)
    self:init(parameters)
    self.bg= ccui.Helper:seekWidgetByName(self,"bg")
    if FULLSCREENADAPTIVE then
        -- self.bg:setPositionX(self.bg:getPositionX() + (self.winSize.width-1920)/2)
        -- self.logoImg:setPositionX(self.logoImg:getPositionX() - (self.winSize.width-1920)/2)
    end
end

function LoginWaitPanel:init(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    local tips = ccui.Helper:seekWidgetByName(self,"Image_6")--:setVisible(false)

    --香港/新加坡/菲律宾不显示健康游戏提示
    tips:setVisible(GAME_LANG ~= "zh_tr")

    local bg = cc.Sprite:create(GameRes["login_bg"])
    self:addChild(bg)
    if FULLSCREENADAPTIVE then
        bg:setScaleX(1.5)
    end
    bg:setPosition(self.winSize.width/2,bg:getContentSize().height/2 - 4)
    
    self.con = cc.Sprite:create()
    self:addChild(self.con)
    self.con:setAnchorPoint(cc.p(0,0))

    self.statusTxt = cc.LabelTTF:create("加载中", GameRes.font1, 40)
    self.con:addChild(self.statusTxt)
    self.statusTxt:setAnchorPoint(cc.p(0,0))

    self.spr = cc.Sprite:create(GameRes["login_1"])
    self.con:addChild(self.spr)
   	-- local ani = cc.Animation:create()
    -- for i=1,4 do
    --     ani:addSpriteFrameWithFile(GameRes["login_"..i])
    -- end
    -- ani:setDelayPerUnit(0.7)

    -- local seq = cc.RepeatForever:create(cc.Animate:create(ani))
    -- self.spr:runAction(seq)
    self:play()

    self.spr:setPosition(self.statusTxt:getPositionX() + self.statusTxt:getContentSize().width + self.spr:getContentSize().width/2,self.statusTxt:getPositionY() + self.statusTxt:getContentSize().height/2)
    self.con:setPosition(self.winSize.width/2 - self.spr:getContentSize().width/2 - self.statusTxt:getContentSize().width/2, 80)
    
    --叠加背景
    self.bgImg= ccui.Helper:seekWidgetByName(self,"bgimg")
    --太阳光
    self.sunShine= ccui.Helper:seekWidgetByName(self,"sunShine")
    --美女
    self.Beauty= ccui.Helper:seekWidgetByName(self,"beauty")
    self.Beauty:setPosition(547, 425)
    --美女层
    self.pan_all= ccui.Helper:seekWidgetByName(self,"Panel_4")
    -- logo
    self.logoImg = ccui.Helper:seekWidgetByName(self,"Image_9")

    ccui.Helper:seekWidgetByName(self,"Image_12"):setVisible(false)
    
    if string.find(GAME_CHANNEL_NAME,"CN_AD_OPPO1") then
        self.logoImg:loadTexture(GameRes.logo_img_oppo)
    else
        self.logoImg:loadTexture(GameRes.logo_img_1)
    end
    --光
    -- self.guangImg={}
    -- for i=1,4 do
    --     local guang=ccui.Helper:seekWidgetByName(self,"guang"..i)
    --     if i%2==0 then guang.rightdir=1
    --     else guang.rightdir=-1 end
    --     table.insert(self.guangImg,guang)
    -- end

    self:initAnimate()
    local is_review =0 ~= Util:binaryAnd(TB_SERVER_INFO.modules, TB_MODULE_BIT.MODULE_BIT_REVIEW) and true or false
    if not is_review then
        --self.bgImg:setVisible(false)
       -- self.Beauty:setVisible(true)
        -- if self.bueatyAnimate then 
        --     self.pan_all:removeChild(self.bueatyAnimate)
        --     self.bueatyAnimate=nil
        -- end
        -- for k,v in pairs(self.guangImg)do
        --     v:setVisible(false) 
        -- end
    end 
end

function LoginWaitPanel:initAnimate()
    self:addLoginLoadingAni()
    self:addLoginLoadingParticleAni()
end

function LoginWaitPanel:setTxt(txt)
	self.statusTxt:setString(txt)

	self.spr:setPosition(self.statusTxt:getPositionX() + self.statusTxt:getContentSize().width + self.spr:getContentSize().width/2,self.statusTxt:getPositionY() + self.statusTxt:getContentSize().height/2)
    self.con:setPosition(self.winSize.width/2 - self.spr:getContentSize().width/2 - self.statusTxt:getContentSize().width/2, 80)
end
function LoginWaitPanel:play()
	self.spr:stopAllActions()
	local ani = cc.Animation:create()
    for i=1,4 do
        ani:addSpriteFrameWithFile(GameRes["login_"..i])
    end
    ani:setDelayPerUnit(0.7)

    local seq = cc.RepeatForever:create(cc.Animate:create(ani))
    self.spr:runAction(seq)
end

--登录界面 动画
function LoginWaitPanel:addLoginLoadingAni() 
    local loginAni = ccs.Armature:create("loading")
    loginAni:getAnimation():playWithIndex(0)
    local size = self.bgImg:getSize()
    loginAni:setPosition(size.width/2,size.height/2)
    self.bgImg:addChild(loginAni)
end

--登录 粒子动画
function LoginWaitPanel:addLoginLoadingParticleAni()
    local sunAnimateAni = ccs.Armature:create("sunShineAnimate")
    sunAnimateAni:getAnimation():playWithIndex(0)
    local size = self.sunShine:getSize()
    sunAnimateAni:setPosition(size.width/2 - 300,size.height/2 -100)
    self.sunShine:addChild(sunAnimateAni)
end

return LoginWaitPanel