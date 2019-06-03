--[[
互动表情
--]]
local InteractPhizManager = class("InteractPhizManager")

function InteractPhizManager:ctor()
    for k, v in pairs(GameTxt.phizStrings) do
        local res = GameRes["chat_animation_"..v]
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(res)
    end
    self.anim_num = 0
end

-- 获取一条骨骼动画
function InteractPhizManager:getArmatureAnimation( name )
    local armature = ccs.Armature:create(name)
    local function animationEvent(armatureBack, movementType, movementID)
        if movementType == ccs.MovementEventType.complete then
            armature:removeFromParent(true)
            self.anim_num= self.anim_num-1
            if self.anim_num==0 then 
                --qf.event:dispatchEvent(ET.RESUME_USERINFO_OPACITY)  --恢复个人信息的透明度
            end
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationEvent)

    return armature
end

function InteractPhizManager:getBezierConfig( fromPos, toPos )
    local offPoint = cc.p(toPos.x - fromPos.x, toPos.y - fromPos.y)
    local controll1 = cc.p(fromPos.x, fromPos.y + 100)
    local controll2 = cc.p(fromPos.x + offPoint.x*3/5, toPos.y + 100)
    local bezierConfig = {controll1
        , controll2
        , toPos}
    return bezierConfig
end

-- 播放一条骨骼动画
function InteractPhizManager:playArmatureAnimation( fromPos, toPos, phizId, isReverse, fromScale, toScale)

    local ret = {}
    local armature = self:getArmatureAnimation(GameTxt.phizStrings[phizId])
    table.insert(ret, armature)
    self.anim_num= self.anim_num+1
    --qf.event:dispatchEvent(ET.SET_USERINFO_OPACITY)  --个人信息的透明度

    local spriteFrameCache = cc.SpriteFrameCache:getInstance()

    local sprite, res, pos, spriteChicken,sound
    local pos
    if 1 == phizId then -- 碰杯
        isReverse = not isReverse
        sound="phiz_py_ganbei"
        res = GameRes.interactPhizReady001
    elseif 2 == phizId then -- 炸弹
        sound="phiz_py_zhadan"
        res = GameRes.interactPhizReady004
    elseif 3 == phizId then -- 冰桶
        res = GameRes.interactPhizReady006
        sound="phiz_py_daoshui"
        pos = {}
        if isReverse then
            pos.x, pos.y = toPos.x + 80, toPos.y + 70
        else
            pos.x, pos.y = toPos.x - 80, toPos.y + 70
        end
    elseif 4 == phizId then -- 吻
        sound="phiz_py_qinwen"
        res = GameRes.interactPhizReady005
    elseif 5 == phizId then -- 点赞
        sound="phiz_py_dianzan"
        res = GameRes.interactPhizReady007
    elseif 6 == phizId then -- 玫瑰
        sound="phiz_py_meigui"
        res = GameRes.interactPhizReady008
    else
        return nil
    end
    local sprite = cc.Sprite:create(res)
    if isReverse then
        armature:setScaleX(-1)
        sprite:setFlippedX(true)
        if spriteChicken then
            spriteChicken:setFlippedX(true)
        end
    end
    armature:setPosition(toPos)
    sprite:setPosition(fromPos)
    armature:setVisible(false)
    armature:setScale(1.5)
    local delaytime
    if sound == "phiz_py_ganbei" then
        delaytime = 0.7
    elseif sound == "phiz_py_xihongshi" or sound=="phiz_py_dianzan" or sound=="phiz_py_meigui" then
        delaytime = 0.1
    else
        delaytime = 0.5
    end
    
    local toScaleParam = 1.5

    if fromScale then 
        sprite:setScale(fromScale)
        if toScale then
            toScaleParam = checkint(toScale)
        end
    end
    sprite:setScale(1.5)
    -- MusicPlayer:playMyEffect(sound)
    local bezierConfig = self:getBezierConfig(fromPos, pos or toPos)
    local spwan = cc.Spawn:create(cc.BezierTo:create(0.5, bezierConfig), 
                                    cc.ScaleTo:create(0.5,toScaleParam))
                
    sprite:runAction(cc.Sequence:create(spwan,
         cc.CallFunc:create(function( sender )
            armature:setVisible(true)
            armature:getAnimation():playWithIndex(0)
            -- sender:removeFromParent()
            sender:setVisible(false)
            if spriteChicken then
                spriteChicken:removeFromParent()
            end
        end),
        cc.DelayTime:create(delaytime),
        cc.CallFunc:create(function( sender )
            MusicPlayer:playMyEffect(sound)
            sender:removeFromParent()
        end)
        ))
    table.insert(ret, sprite)
    return ret
end

local interactPhizManager = InteractPhizManager.new()
return interactPhizManager