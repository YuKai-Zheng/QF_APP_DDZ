--[[
互动表情
--]]
local GiftAnimate = class("GiftAnimate")

function GiftAnimate:ctor()
    self.winSize = cc.Director:getInstance():getWinSize()
    self.aniTable = {}
    self.aniId = 0
    self.isPlay = nil
    self.aniSpriteTable = {}
end

function GiftAnimate:removeAniTable( ... )
    -- body
    self.aniTable = {}
    self.isPlay = nil
    for k,v in pairs(self.aniSpriteTable)do
        v:removeFromParent()
    end
    self.aniSpriteTable={}
end

function GiftAnimate:removeAniById(id)
    -- body
    for k,v in pairs(self.aniTable)do
        if id == v.id then
            table.remove(self.aniTable,k)
            break
        end
    end
    for k,v in pairs(self.aniSpriteTable)do
        v:removeFromParent()
    end
    self.aniSpriteTable = {}
    self:playGiftAni()
end

function GiftAnimate:playGiftAni( ... )
    -- body
    for k,v in pairs(self.aniTable)do
        self:playArmatureAnimation(v.paras,v.node,v.id)
        break
    end
end

function GiftAnimate:addGiftAni(paras,node)
    -- body
    local aniInfo = {}
    aniInfo.paras = paras
    aniInfo.id = self.aniId
    aniInfo.node = node
    table.insert(self.aniTable,aniInfo)
    if not self.isPlay then
        self:playArmatureAnimation(paras,node,self.aniId)
    end
    self.aniId = self.aniId + 1
end

-- 播放一条骨骼动画
function GiftAnimate:playArmatureAnimation(paras,node,id)
    self.isPlay = true
    if paras.id<2000 or paras.id>2005 then return end
    local carid = paras.id - 1999
    local isRichCar = false
    if carid>3 then isRichCar=true end

    --豪车多一个动画
    local sprite
    sprite = cc.Sprite:create(string.format(GameRes.gift_carBtn,paras.id))
    sprite:setOpacity(0)
    sprite.id = id
    if isRichCar then
        sprite:setPosition(self.winSize.width*3/4,self.winSize.height+sprite:getContentSize().height)
        sprite:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.8,cc.p(-sprite:getContentSize().width*2,self.winSize.height/2)),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function( ... )
                -- body
                sprite:setPosition(-sprite:getContentSize().width/2,self.winSize.height*3/4)
            end),
            cc.MoveTo:create(0.5,cc.p(self.winSize.width/2,self.winSize.height/2)),
            cc.DelayTime:create(0.5),
            cc.MoveTo:create(0.3,cc.p(self.winSize.width+sprite:getContentSize().width,self.winSize.height/6)),
            cc.CallFunc:create(function( ... )
                -- body
                sprite:setOpacity(255)
                sprite:removeChildByName("carAni")
            end),
            cc.DelayTime:create(0.2),
            cc.MoveTo:create(0.3,paras.pos),
            cc.CallFunc:create(function( ... )
                -- body
                --sprite:removeFromParent()
                -- self.isPlay = nil
                -- self:removeAniById(id)
                -- if paras.cb then 
                --     paras.cb(paras.node,paras.id)
                -- end
            end)
            ))
        MusicPlayer:playEffectFile(GameRes.all_music.giftCar)
    else
        sprite:setPosition(-sprite:getContentSize().width*1.5,self.winSize.height*3/4)
        sprite:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.9),
            cc.MoveTo:create(0.5,cc.p(self.winSize.width/2,self.winSize.height/2)),
            cc.DelayTime:create(0.5),
            cc.MoveTo:create(0.3,cc.p(self.winSize.width+sprite:getContentSize().width,self.winSize.height/6)),
            cc.CallFunc:create(function( ... )
                -- body
                sprite:setOpacity(255)
                sprite:removeChildByName("carAni")
            end),
            cc.DelayTime:create(0.2),
            cc.MoveTo:create(0.3,paras.pos),
            cc.CallFunc:create(function( ... )
                -- body
                --sprite:removeFromParent()
            end)
            ))
        MusicPlayer:playEffectFile(GameRes.all_music.giftCar1)
    end
        
    
    --加载车上的动画
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    if isRichCar then
        armatureDataManager:addArmatureFileInfo(GameRes.gift_carAni2)
    else
        armatureDataManager:addArmatureFileInfo(GameRes.gift_carAni1)
    end
    local carAni 
    if isRichCar then
        carAni = ccs.Armature:create("qiche_lanbo")
    else
        carAni = ccs.Armature:create("qiche_jiakechong")
    end
    sprite:addChild(carAni, 1)
    carAni:setName("carAni")
    carAni:setPosition(sprite:getContentSize().width / 2 + 4, sprite:getContentSize().height / 2 + 8)
    carAni:getAnimation():playWithIndex(0)
    local bone = carAni:getBone("car")
    local carBoneId = 0
    if isRichCar then
        carBoneId = carid-5 >= 0 and carid-5 or carid-2
    else
        carBoneId = carid -1
    end
    bone:getDisplayManager():changeDisplayWithIndex(carBoneId,true)

    -- local bone1 = carAni:getBone("车边光")
    -- local carEleImgId = carid
    -- if carid == 2 or carid == 5 or carid == 4 then
    --     carEleImgId = 2
    -- elseif carid == 3 then
    --     carEleImgId = 3
    -- end
    -- local carEle=cc.Sprite:create(string.format(GameRes.gift_carEle2,carEleImgId))
    -- bone1:addDisplay(carEle, 0)

    --文字背景
    local giftTips = cc.Sprite:create(GameRes.gift_carTxtBg)
    giftTips.id = id
    giftTips:setPosition(self.winSize.width/2,self.winSize.height*2/3)
    giftTips:setScale(1.5)
    giftTips:setVisible(false)
    giftTips:runAction(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.DelayTime:create(0.5),
        cc.Show:create(),
        cc.Spawn:create(
            cc.FadeIn:create(0.15),
            cc.ScaleTo:create(0.2,1.0)),
        cc.DelayTime:create(1),
        cc.Spawn:create(
            cc.FadeOut:create(0.2),
            cc.ScaleTo:create(0.2,1.3)),
        cc.CallFunc:create(function( ... )
            -- body
            --giftTips:removeFromParent()
            self.isPlay = nil
            self:removeAniById(id)
            if paras.cb then 
                paras.cb(paras.node,paras.id)
            end
        end)
        ))
    --车名
    local carname = cc.Sprite:create(string.format(GameRes.gift_carName,carid))
    carname:runAction(cc.Sequence:create(cc.DelayTime:create(2.7),cc.FadeOut:create(0.2)))
    carname:setPosition(giftTips:getContentSize().width*2/3,giftTips:getContentSize().height/2)
    giftTips:addChild(carname)
    --玩家名
    local playername = cc.LabelTTF:create(paras.txt,GameRes.font1,40)
    playername:runAction(cc.Sequence:create(cc.DelayTime:create(2.7),cc.FadeOut:create(0.2)))
    playername:setPosition(giftTips:getContentSize().width*1/3,giftTips:getContentSize().height/2)
    giftTips:addChild(playername)

    node:addChild(giftTips)
    node:addChild(sprite)
    table.insert(self.aniSpriteTable,giftTips)
    table.insert(self.aniSpriteTable,sprite)
end

local GiftAnimate = GiftAnimate.new()
return GiftAnimate