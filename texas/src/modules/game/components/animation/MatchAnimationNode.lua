
local M = class("MatchAnimationNode", function(  )
    return cc.Node:create()
end)

local PlayAnimationName = {
    STAR_BG = "Animation1xxdibu",             --星槽
    STAR_ADD = "Animation3jiaxing",            --加星
    STAR_SHOW = "Animation4yiyouxing",          --显示星星
    STAR_BROKEN = "Animation7xingxingsuilie",     --碎星
    LEVEL_LESS = "Animation6jiangduan",          --段位掉落消失
    LEVEL_CHANGE = "Animation12huanduanwei2_huan", --更换段位显示
    LEVEL_DESC_SHOW = "Animation8duanwei1_wenzi",     --显示底部文字
    LIGHT_BG = "Animation9duanwei1_di15zhen",      --背景光照
    LIGHT_LINE_BG = "Animation10duanwei1_xunhuan2",      --背景流光
    LEVEL_SHOW = "Animation11duanwei1_Ayici",           --显示段位

    WANGZHESTAR_BG = "Animation1wzdi",
    WANGZHESTAR_ADD = "Animation2wzjiaxing",
    WANGZHESTAR_SHOW = "Animation3shibaixing",
    WANGZHETEXT_ADD = "Animation4jia1",
    WANGZHETEXT_LESS = "Animation5jian1"
}

local BoneName = {
    BADGE = "2zhong1",          --徽章图标
    BADGE_LEFT = "2zuochi",     --徽章左翅
    BADGE_RIGHT = "2youchi",     --徽章左翅
    BOTTOM_BG = "2xia1",        --底版横幅
}

local StarPos = {
    {cc.p(0, 190)},
    {cc.p(-50,190),cc.p(50,190)},
    {cc.p(-100,160),cc.p(0,190),cc.p(100,160)},
    {cc.p(-105,170),cc.p(-40,200),cc.p(40,200),cc.p(105,170)},
    {cc.p(-120,145),cc.p(-65,175),cc.p(0,190),cc.p(65,175),cc.p(120,145)},
}

function M:ctor(  )
    self.animationTable = {}
    self:init()
end

function M:init(  )
    ResourceManager:loadPlist(DDZ_Res.matchLevelAnimation_PLIST, DDZ_Res.matchLevelAnimation_PNG)
end

--开始动画播放 如果只想显示当前段位，传入的两个段位相同则可
function M:startAnimation( paras )
    local nowLevel = paras.all_lv_info_now
    local beforeLevel = paras.all_lv_info_bef
    self.finishCb = paras.cb

    self:removeAllChildren()

    if nowLevel.match_lv >= 70 or beforeLevel.match_lv >= 70 then
        self:wangzheAnimation(paras)
        return
    end

    if nowLevel.match_lv ~= beforeLevel.match_lv then
        --升段或调段
        self:levelChangeAnimation(paras, nowLevel.match_lv > beforeLevel.match_lv)
    elseif nowLevel.sub_lv ~= beforeLevel.sub_lv then
        --升段或掉段
        self:levelChangeAnimation(paras, nowLevel.sub_lv < beforeLevel.sub_lv)
    elseif nowLevel.star ~= beforeLevel.star then
        --升星或降星
        self:starChangeAnimation(paras, nowLevel.star > beforeLevel.star)
    else
        --等级太低无法下降
        self:stayAnimation(paras)
    end
end

function M:levelChangeAnimation( paras, isUp )
    local nowLevel = paras.all_lv_info_now
    local beforeLevel = paras.all_lv_info_bef

    if isUp then
        self.light_bg = self:addMatchArmature()
        self.level_bg = self:addMatchArmature()
        self.light_line_bg = self:addMatchArmature()
        self.bottom = self:addMatchArmature()

        self.bottom:getAnimation():setMovementEventCallFunc(function ( Armture, target )
            if target == ccs.MovementEventType.complete then
                if self.finishCb then
                    self.finishCb()
                    self.finishCb = nil
                end
            end
        end)

        self.bottom:getAnimation():setFrameEventCallFunc(function (  )
            self.light_line_bg:getAnimation():play(PlayAnimationName.LIGHT_LINE_BG)
            self:addLevelFnt(self.bottom, nowLevel)
        end)

        local starCallback = self:createStars(0, nowLevel.sub_lv_star_num, 1)

        self.level_bg:getAnimation():setMovementEventCallFunc(function ( Armature,target )
            if target == ccs.MovementEventType.complete then
                if starCallback then starCallback() end
                self.bottom:getAnimation():play(PlayAnimationName.LEVEL_DESC_SHOW, -1, 0)
            end
        end)

        self.level_bg:getAnimation():setFrameEventCallFunc(function (frame)
            self.light_bg:getAnimation():play(PlayAnimationName.LIGHT_BG)
        end)

        self:setBoneTexture(self.bottom, nowLevel)
        self:setBoneTexture(self.level_bg, nowLevel)
        self.level_bg:getAnimation():play(PlayAnimationName.LEVEL_SHOW, -1, 0)
    else
        self.level_bg = self:addMatchArmature()
        self.light_bg = self:addMatchArmature()
        self.level_change_bg = self:addMatchArmature()
        self.light_line_bg = self:addMatchArmature()
        self.bottom = self:addMatchArmature()

        self.bottom:getAnimation():setMovementEventCallFunc(function ( Armture, target )
            if target == ccs.MovementEventType.complete then
                if self.finishCb then
                    self.finishCb()
                    self.finishCb = nil
                end
            end
        end)

        self.bottom:getAnimation():setFrameEventCallFunc(function (  )
            self.light_line_bg:getAnimation():play(PlayAnimationName.LIGHT_LINE_BG)
            self:addLevelFnt(self.bottom, nowLevel)
        end)

        local brokenCallback, brokenStars
        brokenCallback, brokenStars= self:createStars(1, beforeLevel.sub_lv_star_num, 3, function (  )
            self.level_bg:getAnimation():play(PlayAnimationName.LEVEL_LESS, -1, 0)
            self.beforeLevelLabel:runAction(cc.FadeOut:create(0.5))
            for k, v in pairs(brokenStars) do
                if isValid(v) then
                    v:removeFromParent()
                end
            end
        end)

        local starCallback = self:createStars(nowLevel.star, nowLevel.sub_lv_star_num, 2)

        self.level_bg:getAnimation():setMovementEventCallFunc(function ( Armature,target )
            if target == ccs.MovementEventType.complete then
                self.level_bg:removeFromParent()
                self.level_change_bg:getAnimation():play(PlayAnimationName.LEVEL_CHANGE, -1, 0)
            end
        end)

        self.level_change_bg:getAnimation():setMovementEventCallFunc(function ( Armature, target )
            if target == ccs.MovementEventType.complete then
                if starCallback then starCallback() end
                self.bottom:getAnimation():play(PlayAnimationName.LEVEL_DESC_SHOW, -1, 0)
            end
        end)

        self.level_change_bg:getAnimation():setFrameEventCallFunc(function (frame)
            self.light_bg:getAnimation():play(PlayAnimationName.LIGHT_BG)
        end)

        self:setBoneTexture(self.level_bg, beforeLevel)
        self:setBoneTexture(self.level_change_bg, nowLevel)
        self:setBoneTexture(self.bottom, nowLevel)
        self.beforeLevelLabel = self:addLevelFnt(self.level_bg, beforeLevel)
        self.level_bg:getAnimation():play(PlayAnimationName.LEVEL_LESS)
        self.level_bg:getAnimation():gotoAndPause(1)
        if brokenCallback then brokenCallback() end
    end
end

function M:starChangeAnimation( paras, isUp )
    local nowLevel = paras.all_lv_info_now
    local beforeLevel = paras.all_lv_info_bef

    self.light_bg = self:addMatchArmature()
    self.level_bg = self:addMatchArmature()
    self.light_line_bg = self:addMatchArmature()
    self.bottom = self:addMatchArmature()

    self.bottom:getAnimation():setMovementEventCallFunc(function ( Armture, target )
        if target == ccs.MovementEventType.complete then
            if self.finishCb then
                self.finishCb()
                self.finishCb = nil
            end
        end
    end)

    self.bottom:getAnimation():setFrameEventCallFunc(function (  )
        self.light_line_bg:getAnimation():play(PlayAnimationName.LIGHT_LINE_BG)
        self:addLevelFnt(self.bottom, nowLevel)
    end)
        
    local callback
    if isUp then
        callback = self:createStars(beforeLevel.star, beforeLevel.sub_lv_star_num, 1)
    else
        callback = self:createStars(beforeLevel.star, beforeLevel.sub_lv_star_num, 3)
    end
    self.level_bg:getAnimation():setMovementEventCallFunc(function ( Armature,target )
        if target == ccs.MovementEventType.complete then
            if callback then callback() end
            self.bottom:getAnimation():play(PlayAnimationName.LEVEL_DESC_SHOW, -1, 0)
        end
    end)

    self.level_bg:getAnimation():setFrameEventCallFunc(function (frame)
        self.light_bg:getAnimation():play(PlayAnimationName.LIGHT_BG)
    end)

    self:setBoneTexture(self.level_bg, nowLevel)
    self:setBoneTexture(self.bottom, nowLevel)

    self.level_bg:getAnimation():play(PlayAnimationName.LEVEL_SHOW, -1, 0)
end

function M:stayAnimation( paras )
    local nowLevel = paras.all_lv_info_now
    local beforeLevel = paras.all_lv_info_bef

    self.light_bg = self:addMatchArmature()
    self.level_bg = self:addMatchArmature()
    self.light_line_bg = self:addMatchArmature()
    self.bottom = self:addMatchArmature()

    self.bottom:getAnimation():setMovementEventCallFunc(function ( Armture, target )
        if target == ccs.MovementEventType.complete then
            if self.finishCb then
                self.finishCb()
                self.finishCb = nil
            end
        end
    end)

    self.bottom:getAnimation():setFrameEventCallFunc(function (  )
        self.light_line_bg:getAnimation():play(PlayAnimationName.LIGHT_LINE_BG)
        self:addLevelFnt(self.bottom, nowLevel)
    end)
        
    local callback = self:createStars(nowLevel.star, nowLevel.sub_lv_star_num, 2)

    self.level_bg:getAnimation():setMovementEventCallFunc(function ( Armature,target )
        if target == ccs.MovementEventType.complete then
            if callback then callback() end
            self.bottom:getAnimation():play(PlayAnimationName.LEVEL_DESC_SHOW, -1, 0)
        end
    end)

    self.level_bg:getAnimation():setFrameEventCallFunc(function (frame)
        self.light_bg:getAnimation():play(PlayAnimationName.LIGHT_BG)
    end)

    self:setBoneTexture(self.level_bg, nowLevel)
    self:setBoneTexture(self.bottom, nowLevel)

    self.level_bg:getAnimation():play(PlayAnimationName.LEVEL_SHOW, -1, 0)
end

function M:wangzheAnimation( paras )
    local nowLevel = paras.all_lv_info_now
    local beforeLevel = paras.all_lv_info_bef

    if nowLevel.match_lv ~= beforeLevel.match_lv then
        --王者升掉段
        self:wangzheLevelUp(paras, nowLevel.match_lv > beforeLevel.match_lv)
    elseif nowLevel.star ~= beforeLevel.star then
        --王者升掉星
        self:wangzheStarChange(paras, nowLevel.star > beforeLevel.star)
    else
        --显示王者段位
        self:wangzheStay(paras)
    end
end

function M:wangzheLevelUp( paras, isUp )
    local nowLevel = paras.all_lv_info_now
    local beforeLevel = paras.all_lv_info_bef

    if isUp then
        self.light_bg = self:addMatchArmature()
        self.level_bg = self:addMatchArmature()
        self.light_line_bg = self:addMatchArmature()
        self.bottom = self:addMatchArmature()

        self.wangzheStarBG = self:addMatchArmature(true)
        self.wangzheStarAdd = self:addMatchArmature(true)
        self.wangzheStarBG:setPositionY(200)
        self.wangzheStarAdd:setPositionY(200)

        self.wangzheStarBG:getAnimation():setMovementEventCallFunc(function ( Armture, target )
            if target == ccs.MovementEventType.complete then
                self.wangzheStarAdd:getAnimation():play(PlayAnimationName.WANGZHESTAR_ADD, -1, 0)
            end
        end)

        self.bottom:getAnimation():setMovementEventCallFunc(function ( Armture, target )
            if target == ccs.MovementEventType.complete then
                

                if self.finishCb then
                    self.finishCb()
                    self.finishCb = nil
                end
            end
        end)

        self.bottom:getAnimation():setFrameEventCallFunc(function (  )
            self.light_line_bg:getAnimation():play(PlayAnimationName.LIGHT_LINE_BG)
            self:addLevelFnt(self.bottom, nowLevel)
        end)

        self.level_bg:getAnimation():setMovementEventCallFunc(function ( Armature,target )
            if target == ccs.MovementEventType.complete then
                self.wangzheStarBG:getAnimation():play(PlayAnimationName.WANGZHESTAR_BG, -1, 0)
                self.bottom:getAnimation():play(PlayAnimationName.LEVEL_DESC_SHOW, -1, 0)
            end
        end)

        self.level_bg:getAnimation():setFrameEventCallFunc(function (frame)
            self.light_bg:getAnimation():play(PlayAnimationName.LIGHT_BG)
        end)

        self:setBoneTexture(self.bottom, nowLevel)
        self:setBoneTexture(self.level_bg, nowLevel)
        self.level_bg:getAnimation():play(PlayAnimationName.LEVEL_SHOW, -1, 0)
    else
        self.light_bg = self:addMatchArmature()
        self.level_bg = self:addMatchArmature()
        self.level_change_bg = self:addMatchArmature()
        self.light_line_bg = self:addMatchArmature()
        self.bottom = self:addMatchArmature()

        self.starBg = self:addMatchArmature()
        self.starBg:setScale(1.7)
        self.starBg:setPosition(StarPos[1][1])
        self.brokenStar = self:addMatchArmature()
        self.brokenStar:setScale(1.7)
        self.brokenStar:setPosition(StarPos[1][1])

        self.starBg:getAnimation():setMovementEventCallFunc(function ( Armture, target )
            if target == ccs.MovementEventType.complete then
                self.starBg:removeFromParent()
                self.brokenStar:getAnimation():play(PlayAnimationName.STAR_BROKEN, -1, 0)
            end
        end)

        self.brokenStar:getAnimation():setMovementEventCallFunc(function ( Armture, target )
            if target == ccs.MovementEventType.complete then
                self.level_bg:getAnimation():play(PlayAnimationName.LEVEL_LESS, -1, 0)

                self.beforeLevelLabel:runAction(cc.FadeOut:create(0.5))
                self.brokenStar:runAction(cc.FadeOut:create(0.5))
            end
        end)

        local starCallback = self:createStars(nowLevel.star, nowLevel.sub_lv_star_num, 2, function (  )
        end)

        self.level_bg:getAnimation():setMovementEventCallFunc(function ( Armature,target )
            if target == ccs.MovementEventType.complete then
                self.level_bg:removeFromParent()
                self.level_change_bg:getAnimation():play(PlayAnimationName.LEVEL_CHANGE, -1, 0)
            end
        end)

        self.bottom:getAnimation():setMovementEventCallFunc(function ( Armture, target )
            if target == ccs.MovementEventType.complete then
                if self.finishCb then
                    self.finishCb()
                    self.finishCb = nil
                end
            end
        end)

        self.bottom:getAnimation():setFrameEventCallFunc(function (  )
            self.light_line_bg:getAnimation():play(PlayAnimationName.LIGHT_LINE_BG)
            self:addLevelFnt(self.bottom, nowLevel)
        end)

        self.level_change_bg:getAnimation():setMovementEventCallFunc(function ( Armature, target )
            if target == ccs.MovementEventType.complete then
                if starCallback then starCallback() end
                self.bottom:getAnimation():play(PlayAnimationName.LEVEL_DESC_SHOW, -1, 0)
            end
        end)

        self.level_change_bg:getAnimation():setFrameEventCallFunc(function (frame)
            self.light_bg:getAnimation():play(PlayAnimationName.LIGHT_BG)
        end)

        self:setBoneTexture(self.level_bg, beforeLevel)
        self:setBoneTexture(self.level_change_bg, nowLevel)
        self:setBoneTexture(self.bottom, nowLevel)
        self.beforeLevelLabel = self:addLevelFnt(self.level_bg, beforeLevel)
        self.level_bg:getAnimation():play(PlayAnimationName.LEVEL_LESS)
        self.level_bg:getAnimation():gotoAndPause(1)
        self.starBg:getAnimation():play(PlayAnimationName.STAR_SHOW, -1, 0)
    end
end

function M:wangzheStarChange( paras, isUp )
    local nowLevel = paras.all_lv_info_now
    local beforeLevel = paras.all_lv_info_bef
    local finishCb = paras.cb

    self.wangzheStarTxtNum = cc.LabelBMFont:create()
    self.wangzheStarTxtNum:setFntFile(DDZ_Res.wangzheStarNum)
    self.wangzheStarTxtNum:setString("x" .. nowLevel.star)
    self.wangzheStarTxtNum:setVisible(false)
    self.wangzheStarTxtNum:setPositionY(140)
    self:addChild(self.wangzheStarTxtNum, 100)

    self.light_bg = self:addMatchArmature()
    self.level_bg = self:addMatchArmature()
    self.light_line_bg = self:addMatchArmature()
    self.bottom = self:addMatchArmature()

    self.wangzheStar = self:addMatchArmature(true)
    self.wangzheStar:setPositionY(200)
    self.wangzheStarChangeTxt = self:addMatchArmature(true)
    self.wangzheStarChangeTxt:setPositionY(200)

    self.wangzheStarChangeTxt:getAnimation():setMovementEventCallFunc(function ( Armture, target )
        if target == ccs.MovementEventType.complete then
            if nowLevel.star > 1 then
                self.wangzheStarTxtNum:setString("x" .. nowLevel.star)
                self.wangzheStarTxtNum:setVisible(true)
            else
                self.wangzheStarTxtNum:setVisible(false)
            end
        end
    end)

    self.wangzheStar:getAnimation():setMovementEventCallFunc(function ( Armture, target )
        if target == ccs.MovementEventType.complete then
            if beforeLevel.star > 1 then
                self.wangzheStarTxtNum:setString("x" .. beforeLevel.star)
                self.wangzheStarTxtNum:setVisible(true)
            end

            self.wangzheStarChangeTxt:getAnimation():play( isUp and PlayAnimationName.WANGZHETEXT_ADD or PlayAnimationName.WANGZHETEXT_LESS, -1, 0)
        end
    end)

    self.bottom:getAnimation():setMovementEventCallFunc(function ( Armture, target )
        if target == ccs.MovementEventType.complete then
            if self.finishCb then
                self.finishCb()
                self.finishCb = nil
            end
        end
    end)

    self.bottom:getAnimation():setFrameEventCallFunc(function (  )
        self.light_line_bg:getAnimation():play(PlayAnimationName.LIGHT_LINE_BG)
        self:addLevelFnt(self.bottom, nowLevel)
    end)


    self.level_bg:getAnimation():setMovementEventCallFunc(function ( Armature,target )
        if target == ccs.MovementEventType.complete then
            self.wangzheStar:getAnimation():play(PlayAnimationName.WANGZHESTAR_SHOW, -1, 0)
            self.bottom:getAnimation():play(PlayAnimationName.LEVEL_DESC_SHOW, -1, 0)
        end
    end)

    self.level_bg:getAnimation():setFrameEventCallFunc(function (frame)
        self.light_bg:getAnimation():play(PlayAnimationName.LIGHT_BG)
    end)

    self:setBoneTexture(self.bottom, nowLevel)
    self:setBoneTexture(self.level_bg, nowLevel)
    self.level_bg:getAnimation():play(PlayAnimationName.LEVEL_SHOW, -1, 0)
end

function M:wangzheStay( paras )
    local nowLevel = paras.all_lv_info_now
    local beforeLevel = paras.all_lv_info_bef
    local finishCb = paras.cb

    if nowLevel.star > 1 then
        self.wangzheStarTxtNum = cc.LabelBMFont:create()
        self.wangzheStarTxtNum:setFntFile(DDZ_Res.wangzheStarNum)
        self.wangzheStarTxtNum:setString("x" .. nowLevel.star)
        self.wangzheStarTxtNum:setVisible(false)
        self.wangzheStarTxtNum:setPositionY(140)
        self:addChild(self.wangzheStarTxtNum, 100)
    end

    self.light_bg = self:addMatchArmature()
    self.level_bg = self:addMatchArmature()
    self.light_line_bg = self:addMatchArmature()
    self.bottom = self:addMatchArmature()

    self.wangzheStar = self:addMatchArmature(true)
    self.wangzheStar:setPositionY(200)

    self.wangzheStar:getAnimation():setMovementEventCallFunc(function ( Armture, target )
        if target == ccs.MovementEventType.complete then
            if isValid(self.wangzheStarTxtNum) then
                self.wangzheStarTxtNum:setVisible(true)
            end
        end
    end)

    self.bottom:getAnimation():setMovementEventCallFunc(function ( Armture, target )
        if target == ccs.MovementEventType.complete then
            if self.finishCb then
                self.finishCb()
                self.finishCb = nil
            end
        end
    end)

    self.bottom:getAnimation():setFrameEventCallFunc(function (  )
        self.light_line_bg:getAnimation():play(PlayAnimationName.LIGHT_LINE_BG)
        self:addLevelFnt(self.bottom, nowLevel)
    end)


    self.level_bg:getAnimation():setMovementEventCallFunc(function ( Armature,target )
        if target == ccs.MovementEventType.complete then
            self.wangzheStar:getAnimation():play(PlayAnimationName.WANGZHESTAR_SHOW, -1, 0)
            self.bottom:getAnimation():play(PlayAnimationName.LEVEL_DESC_SHOW, -1, 0)
        end
    end)

    self.level_bg:getAnimation():setFrameEventCallFunc(function (frame)
        self.light_bg:getAnimation():play(PlayAnimationName.LIGHT_BG)
    end)

    self:setBoneTexture(self.bottom, nowLevel)
    self:setBoneTexture(self.level_bg, nowLevel)
    self.level_bg:getAnimation():play(PlayAnimationName.LEVEL_SHOW, -1, 0)

end

--[[
    创建星星动画
    starNum: 当前星星数
    allStarNum: 总星槽数
    type:动画类型
    cb:执行完成回调

    返回星星动画执行回调
]]--
function M:createStars( starNum, allStarNum, type, cb )
    local stars = {}
    local armatures = {}
    for i = 1, allStarNum do
        local star = self:addMatchArmature()
        star:setPosition(StarPos[allStarNum][i])

        table.insert( stars,star )
        table.insert( armatures, star )
    end

    local callback
    callback = function (  )
        for i = 1, #stars do
            if i > starNum then
                stars[i]:getAnimation():play(PlayAnimationName.STAR_BG, -1, 0)
            else
                stars[i]:getAnimation():play(PlayAnimationName.STAR_SHOW, -1, 0)
            end
        end
    end

    local finishCallback

    if type == 1 then
        --卡槽加星
        local addStar = self:addMatchArmature()
        addStar:setZOrder(1)
        addStar:setPosition(StarPos[allStarNum][starNum + 1])
        
        addStar:getAnimation():setMovementEventCallFunc(function ( Armature, target )
            if target == ccs.MovementEventType.complete then
                if cb then cb() end
            end
        end)

        finishCallback = function (  )
            addStar:getAnimation():play(PlayAnimationName.STAR_ADD, -1, 0)
        end
        table.insert( armatures, addStar )
    elseif type == 2 then
        --显示星
        finishCallback = function (  )
            if cb then cb() end
        end
    elseif type == 3 then
        --碎星
        local brokenStar = self:addMatchArmature()
        brokenStar:setZOrder(1)
        brokenStar:setPosition(StarPos[allStarNum][starNum])
        
        brokenStar:getAnimation():setMovementEventCallFunc(function ( Armature, target )
            if target == ccs.MovementEventType.complete then
                brokenStar:removeFromParent()
                if cb then cb() end
            end
        end)

        local brokenStarBG = self:addMatchArmature()
        brokenStarBG:setPosition(stars[starNum]:getPosition())

        finishCallback = function (  )
            brokenStarBG:getAnimation():play(PlayAnimationName.STAR_BG, -1, 0)
            stars[starNum]:setVisible(false)--getAnimation():play(PlayAnimationName.STAR_BG, -1, 0)
            brokenStar:getAnimation():play(PlayAnimationName.STAR_BROKEN, -1, 0)
        end
        table.insert( armatures, brokenStar )
        table.insert( armatures, brokenStarBG )
    end

    stars[allStarNum]:getAnimation():setMovementEventCallFunc(function ( Armature,target )
        if target == ccs.MovementEventType.complete then
            if finishCallback then finishCallback() end
        end
    end)

    return callback, armatures
end

function M:addLevelFnt( armature, matchLevel )
    local label = cc.LabelBMFont:create()
    label:setFntFile(string.format( DDZ_Res.matchLevel_bottom_fnt, matchLevel.match_lv <= 30 and 1 or matchLevel.match_lv >= 60 and 7 or matchLevel.match_lv / 10 ))

    label:setString(Util:getMatchLevelTxt(matchLevel))
    armature:addChild(label, 100)
    label:setPositionY(-135)
    return label
end

--获取骨骼动画节点
function M:addMatchArmature(isWangzhe)
    local animation
    if not isWangzhe then
        local armatureDataManager = ccs.ArmatureDataManager:getInstance()
        armatureDataManager:addArmatureFileInfo(DDZ_Res.match_level_animation_json)

        animation = ccs.Armature:create("NewAnimationAPP190117duanwei1")
        self:addChild(animation)
    else
        local armatureDataManager = ccs.ArmatureDataManager:getInstance()
        armatureDataManager:addArmatureFileInfo(DDZ_Res.match_wangzhe_animation_json)

        animation = ccs.Armature:create("NewAnimation190118wangzhe")
        self:addChild(animation)
    end

    return animation
end

function M:setBoneTexture( armature, matchLevel )
    local icon = ccs.Skin:createWithSpriteFrameName(string.format( DDZ_Res.matchLevelAnimation_icon, matchLevel.match_lv / 10))
    local leftWing = ccs.Skin:createWithSpriteFrameName(string.format( DDZ_Res.matchLevelAnimation_wing,"left", matchLevel.match_lv/ 10))
    local rightWing = ccs.Skin:createWithSpriteFrameName(string.format( DDZ_Res.matchLevelAnimation_wing,"right", matchLevel.match_lv / 10))

    local match_lv = matchLevel.match_lv > 30 and matchLevel.match_lv / 10 or 1

    local bottom = ccs.Skin:createWithSpriteFrameName(string.format( DDZ_Res.matchLevelAnimation_bottom,match_lv ))

    local boneIcon = armature:getBone(BoneName.BADGE)
    local boneLeftWing = armature:getBone(BoneName.BADGE_LEFT)
    local boneRightWing = armature:getBone(BoneName.BADGE_RIGHT)
    local boneBottom = armature:getBone(BoneName.BOTTOM_BG)

    boneIcon:addDisplay(icon, 0)
    boneLeftWing:addDisplay(leftWing, 0)
    boneRightWing:addDisplay(rightWing, 0)
    boneBottom:addDisplay(bottom, 0)
end

return M