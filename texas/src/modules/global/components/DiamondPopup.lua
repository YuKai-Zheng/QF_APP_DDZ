--[[
    TODO: title_ready 帧事件的时间点；beam素材；diamond number骨骼  

    恭喜获得弹窗
    输入格式：getRewardType 1(恭喜获得：文字描述使用fnt) 2(获得物品:文字描述使用系统字体 必须由自己传入)
             isUser 是否可以使用道具 可传入跳转回调 userCallback
             rewardInfo 道具表 可用顺序传入{0,0,0} 当值不为表时 type为当前索引位 
                        最好使用 {
                            {type = 1,  类型
                            count = 2,  数量
                            imgLocal = "", 本地图片资源
                            imgUrl = "", 远端图片资源
                            desc = ""} 道具描述
                        }
]]

local DiamondPopup = class("DiamondPopup", CommonWidget.BasicWindow)

DiamondPopup.TEXT_ZORDER = 100
DiamondPopup.BLOOM_ZORDER = 100
DiamondPopup.PLUS_GAP = 10
DiamondPopup.BG_DARK_TAG = 999
DiamondPopup.UNIQUE = false

---以下常量与具体的骨骼动画ExportJson相关---
DiamondPopup.ARMATURE_ANIMATION_NAME = "NewAnimation123"    --Animation名字
DiamondPopup.ARMATURE_REWARD_ANIMATION_NAME = "rewardAnimation"    --奖励Animation名字
DiamondPopup.ARMATURE_DIAMOND_BONE = "diamond_num"          --钻石数量的骨骼名字
DiamondPopup.ARMATURE_STAR_1_BONE = "Layer1"                --星星的骨骼名字
DiamondPopup.ARMATURE_STAR_2_BONE = "Layer2"                --星星的骨骼名字
DiamondPopup.ARMATURE_RADIATIONBG_BONE = "Layer3"           --辐射背景的骨骼名字
DiamondPopup.ARMATURE_STAR_3_BONE = "Layer5"                --钻石数量的骨骼名字
DiamondPopup.ARMATURE_DIAMONDBG_BONE = "Layer7"             --钻石数量的骨骼名字
DiamondPopup.ARMATURE_TITLE_READY_EVENT = "title_ready"     --帧事件，标题已经弹出
DiamondPopup.ARMATURE_POP_FINISH_EVENT = "pop_finish"       --帧事件，弹框已经展开
DiamondPopup.BLOOM_OFFSET_X = 2                             --流光控件相对于中心点的x偏移，与title位置相关
DiamondPopup.BLOOM_OFFSET_Y = 236                           --流光控件相对于中心点的y偏移，与title位置相关

function DiamondPopup:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()

    DiamondPopup.super.ctor(self, paras)
end

--弹窗初始化+
function DiamondPopup:init(paras)
    self:createRotateAni()
    self:addParticleAni()
    
    self:setContentSize(self.winSize)
    self.getRewardType = paras.getRewardType or 1 -- 1恭喜获得 2兑换成功
    self.rewardInfo = paras.rewardInfo or {}  -- 奖励物品信息(可以传入数字和字符串) {99, 12, 22, 33, 44, 55} 分别是1金币、2奖券、3等级卡、4刮刮卡 5话费、6实物
    self.rewardInfoUrl = paras.rewardInfoUrl or {} -- 物品的url，和rewardInfo一一对应
    self.dismissCallBack = paras.dismissCallBack -- 消失回调
    self.isUser = paras.isUser
    self.userCallback = paras.userCallback
    self:playAnimation()

    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.DIAMOND_POPUP)
    self.gui:getChildByName("Image_1"):setScale(0)
    self.gui:getChildByName("Image_1"):runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.3,1)))

    self.itemP = ccui.Helper:seekWidgetByName(self.gui,"itemP")
    self.listP = ccui.Helper:seekWidgetByName(self.gui,"rewardP")
    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"closebtn")
    self.sharebtn = ccui.Helper:seekWidgetByName(self.gui,"shareBtn")
    self.title = ccui.Helper:seekWidgetByName(self.gui,"Image_2")
    dump(string.format(GameRes.get_reward_pop_title, 1))
    self.title:loadTexture(string.format(GameRes.get_reward_pop_title, 1))

    self.closeBtn:setAnchorPoint(0.5,0.5)

    if isUser  then
        self.closeBtn:setPositionX(340)
        self.sharebtn:setVisible(true)
        self.sharebtn:getChildByName("Image_19"):loadTexture(GameRes.exchangeToUser)
    else
        self.closeBtn:setPositionX(40)
        self.sharebtn:setVisible(false)
    end

    ccui.Helper:seekWidgetByName(self.gui,"lastLevelTips"):setVisible(false)
    self.closeBtn:getChildByName("exitGame_getFocaTips"):setVisible(false)

    addButtonEvent(self.closeBtn,function ()
        if self.dismissCallBack then
            self.dismissCallBack()
        end
        self:close()
    end)

    addButtonEvent(self.sharebtn,function ()
        if self.dismissCallBack then
            self.dismissCallBack()
        end
        if self.userCallback then
            self.userCallback()
        end

        self:close()
    end)

    if FULLSCREENADAPTIVE then
        self.gui:getChildByName("Image_1"):setPositionX(self.gui:getChildByName("Image_1"):getPositionX()+(self.winSize.width-1920)/2)
    end
    
    self.listP:setScale(0)
    local actionScale = cc.ScaleTo:create(0.5,1)
    self.listP:runAction(actionScale)
end

--恭喜获得动画 旋转动画
function DiamondPopup:createRotateAni()
    -- body
    local guang = cc.Sprite:create(GameRes.guang2Res)
    guang:setPosition(self.winSize.width/2,self.winSize.height/2)   
    self:addChild(guang)
    local sprite = cc.Sprite:create(GameRes.xuanzhuanRes)
    sprite:setPosition(self.winSize.width/2,self.winSize.height/2)
    self:addChild(sprite)
    local rotateAction = cc.RotateBy:create(8 , 360)
    local repeatAction = cc.RepeatForever:create(rotateAction)
    sprite:runAction(repeatAction)
end

--恭喜获得 粒子动画
function DiamondPopup:addParticleAni()
    -- body
    local particle = cc.ParticleSystemQuad:create(GameRes.congratulationPlist)
    particle:setTexture(cc.Director:getInstance():getTextureCache():addImage(GameRes.congratulationTexture))
    -- particle:setStartSize(20)
    -- particle:setSpeed(50)
    -- particle:setTotalParticles(15)
    particle:setPosition(self.winSize.width / 2, self.winSize.height/2)
    self:addChild(particle)
end

--恭喜获得 动画
function DiamondPopup:playAnimation()
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.congratulationAni)
    local congratulationAni = ccs.Armature:create("congratulationAni")
    congratulationAni:getAnimation():playWithIndex(0)
    congratulationAni:setPosition(self.winSize.width/2,self.winSize.height/2)
    self:addChild(congratulationAni)

end

function DiamondPopup:getRewardPosX(allCount)
    local posXs = {}
    if allCount <= 0 then
        return posXs
    end

    local allDis = (allCount - 1) * 300

    for i = 1, allCount do
        local posX = (allDis / 2) + (i - allCount) * 300
        table.insert( posXs,posX )
    end

    return posXs
end

--展示弹窗
function DiamondPopup:show()
    DiamondPopup.super.show(self, function (  )
        self:showReward()
    end)
end

function DiamondPopup:showReward(  )
    if not self.isShow then
        if (self.rewardInfo ~= nil and #self.rewardInfo > 0) then
            --钻石数量 >0, 播放弹窗骨骼动画
            self:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.01),
                cc.CallFunc:create(function()
                    if self.rewardInfo ~= nil and #self.rewardInfo > 0 then
                        for rewardType,rewardNum in ipairs(self.rewardInfo) do
                            -- 如果传的是数字
                            if type(rewardNum) == "number" then
                                if rewardNum > 0 then
                                    local rewardAnimation = self:getSingleRewardArmatureNode({type = rewardType, count = rewardNum})
                                    self.listP:addChild(rewardAnimation)
                                end
                            elseif type(rewardNum) == "string" then
                                if rewardNum ~= "" then
                                    local rewardAnimation = self:getSingleRewardArmatureNode({type = rewardType, count = rewardNum})
                                    self.listP:addChild(rewardAnimation)
                                end
                            elseif type(rewardNum) == "table" then
                                if rewardNum.type then
                                    local rewardAnimation = self:getSingleRewardArmatureNode(rewardNum)
                                    self.listP:addChild(rewardAnimation)
                                end
                            end
                        end

                        local posXs = self:getRewardPosX(self.listP:getChildrenCount())

                        local childs = self.listP:getChildren()
                        for i = 1, self.listP:getChildrenCount() do
                            childs[i]:setPosition(posXs[i], 0)
                        end
                    end
                end)))
        else
            --钻石数量 <=0, 没必要弹窗,直接移除
            self:close()
        end
    end
    self.isShow = true
end


--播放奖励动画
function DiamondPopup:getSingleRewardArmatureNode(paras)
    local item = self.itemP:clone()
    item:setVisible(true)

    dump(paras)
    local type = paras.type
    local count = paras.count or 0
    local imgLocal = paras.imgLocal
    local imgUrl = paras.imgUrl
    local desc = paras.desc

    local rewardNum = item:getChildByName("num")
    -- 只用于显示兑换相关的东西
    local rewardNomalTxt = item:getChildByName("normalTxt")

    if self.getRewardType == 2  then
        rewardNum:setVisible(false)
        rewardNomalTxt:setVisible(true)
        rewardNomalTxt:setString(desc)
    else
        if desc and desc ~= "" then
            rewardNum:setString(desc)
        else
            --奖励数量
            local name = ""
            if type<3 then
                name = count .. GameTxt.invite_award_type[type]
            elseif type == 9 then
                name = ""
            else
                name = Cache.user:getConfigByLevel(count*10).title.."卡"
            end
            rewardNum:setString(name)
            rewardNum:setVisible(true)
            rewardNomalTxt:setVisible(false)
        end
    end

    if imgLocal or imgUrl then
        if imgLocal then
            item:getChildByName("img"):loadTexture(imgLocal)
        else
            self:downloadPicture(item:getChildByName("img"), imgUrl)
        end
    else
        --更换背景  金币、奖券、等级卡、刮刮卡、 话费、实物
        if type == 1 then -- 金币
            item:getChildByName("img"):loadTexture(GameRes.global_got_diamond_ani_buygoldbg)
        elseif type == 2 then -- 奖券
            item:getChildByName("img"):loadTexture(GameRes.MatchingFocasImg)
        elseif type == 3 then -- 等级卡
            local nowLevel = count
            loga(string.format(GameRes.levelCardImg,nowLevel))
            item:getChildByName("img"):loadTexture(string.format(GameRes.levelCardImg,nowLevel))
        elseif type == 4 then --刮刮卡
            self:downloadPicture(item:getChildByName("img"), self.rewardInfoUrl[type])
        elseif type == 5 then --话费
            self:downloadPicture(item:getChildByName("img"), self.rewardInfoUrl[type])
        elseif type == 6 then --实物
            self:downloadPicture(item:getChildByName("img"), self.rewardInfoUrl[type])
        elseif type == 7 then --道具
            self:downloadPicture(item:getChildByName("img"), self.rewardInfoUrl[type])
            local size = item:getChildByName("img"):getContentSize()
            if size.height < 180 then 
                item:getChildByName("img"):setScale(1.5,1.5)
            end
        elseif type == 8 then --本地图标
            item:getChildByName("img"):loadTexture(string.format(self.rewardInfoUrl[type]))
        elseif type == 9 then --红包
            item:getChildByName("img"):loadTexture(GameRes.redpack_img)
            item:getChildByName("img"):setPositionY(item:getChildByName("img"):getPositionY() - 100)
            local redpack_num = cc.LabelBMFont:create()
            redpack_num:setFntFile(GameRes.tuiguangRedPack_numFnt)
            redpack_num:setString(string.format( GameTxt.string_yuan, count))
            item:getChildByName("img"):addChild(redpack_num)
            redpack_num:setPosition(cc.p(item:getChildByName("img"):getContentSize().width / 2, item:getChildByName("img"):getContentSize().height / 4 * 3))
        end
    end
   
    
    return item
end

-- 下载图片
function DiamondPopup:downloadPicture(sprite, url)
    if url == nil or sprite == nil then
        return
    end
    local taskID = qf.downloader:execute(url, 10,
        function(path)
            if not tolua.isnull( sprite ) then
                sprite:loadTexture(path)
            end
        end,
        function()
        end,
        function()
        end
    )
end

--添加标题流光效果
function DiamondPopup:addTitleBloom()
    self.bloom = CommonWidget.BloomNode.new({
        image = GameRes.global_got_diamond_title_shape,
        beam = GameRes.global_got_diamond_title_beam,
        create = false,
        move_back = false,
        move_forever = true,
        move_time = 1.5
    })
    self.bloom:setPosition(self.winSize.width/2 + self.BLOOM_OFFSET_X, self.winSize.height/2 + self.BLOOM_OFFSET_Y)
    self:addChild(self.bloom, self.BLOOM_ZORDER)
end

--播放标题流光效果
function DiamondPopup:playTitleBloom()
    if self.bloom then
        self.bloom:playAnimation()
    end
end

--停止播放标题流光效果
function DiamondPopup:stopTitleBloom()
    if self.bloom then
        self.bloom:stopAnimation()
        self.bloom:removeFromParent(true)
        self.bloom = nil
    end
end

function DiamondPopup:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end

function DiamondPopup:registerBack()
    Util:registerKeyReleased({self = self,cb = function ()
        if self.dismissCallBack then
            self.dismissCallBack()
        end
        self:close()

        if self.goldFlag == true then
            qf.event:dispatchEvent(ET.SHOW_EXCHANGEMALL_VIEW)
            Util:delayRun(0.1, function ( ... )
                qf.event:dispatchEvent(ET.EVENT_JUMP_QUICK_COIN_GAME,{})
            end)
        end
    end})
end

return DiamondPopup