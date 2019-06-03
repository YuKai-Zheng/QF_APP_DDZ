local M = class("RedPackageRewardView", CommonWidget.BasicWindow)

M.BACK_TO_CLOSE = false

function M:ctor( args )
    M.super.ctor(self, args)
end

function M:initUI(  )
    local winSize = cc.Director:getInstance():getWinSize()

    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.redPackageAnimation)
    self.gui = ccs.Armature:create("NewAnimationdonghua02")

    self.gui:setPosition(cc.p(winSize.width / 2, winSize.height / 2))

    self.btn_open = ccui.Button:create()
    self.btn_confirm = ccui.Button:create()
    self.btn_exchange = ccui.Button:create()
    self.txt_tip = ccui.Text:create(GameTxt.redpack_tip,GameRes.font1, 30)
    self.txt_num = cc.LabelBMFont:create()
    self.txt_num:setFntFile(GameRes.redPack_fnt)
    self.txt_num:setString("500奖券")
    self.txt_num:setVisible(false)
    self.txt_num:setPositionY(-40)
    self.gui:addChild(self.txt_num, 100)

    self.btn_open:loadTextureNormal(DDZ_Res.global_TouMing_Png)
    self.btn_open:ignoreContentAdaptWithSize(false)
    self.btn_open:setContentSize(cc.size(210, 210))
    self.btn_confirm:loadTextureNormal(DDZ_Res.global_TouMing_Png)
    self.btn_confirm:ignoreContentAdaptWithSize(false)
    self.btn_confirm:setContentSize(cc.size(360, 130))

    self.btn_exchange:loadTextureNormal(GameRes.redPack_btn_exchange)
    self.txt_tip:setColor(cc.c3b(252, 176,0))

    self.gui:addChild(self.btn_open, 100)
    self.gui:addChild(self.btn_confirm, 100)
    self.gui:addChild(self.btn_exchange, 100)
    self.gui:addChild(self.txt_tip, 100)

    self.btn_open:setPositionY(-200)
    self.btn_confirm:setPositionY(-180)
    self.btn_confirm:setVisible(false)

    self.btn_exchange:setPositionY(-290)

    self.btn_exchange:setVisible(false)
    self.txt_tip:setVisible(false)
    self.txt_tip:setPositionY(-420)
    dump(self.btn_exchange:getContentSize())

    self.gui:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.RotateTo:create(0.03, 5),
            cc.RotateTo:create(0.06, -5),
            cc.RotateTo:create(0.06, 5),
            cc.RotateTo:create(0.06, -5),
            cc.RotateTo:create(0.03, 0),
            cc.DelayTime:create(0.5)
        )
    ))
end

function M:initClick(  )
    addButtonEvent(self.btn_open, function (  )
        self.btn_open:setVisible(false)
        self.gui:stopAllActions()
        self.gui:setRotation(0)

        GameNet:send({
            cmd = CMD.NEW_USER_PLAY_REWARD,
            body = {},
            callback = function ( rsp )
                dump(rsp.ret)
                if rsp.ret == 0 then
                    self:playAnim()
                    --更新数据
                    Cache.user:updateNewUserPlayTask({status = 3})
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                    if rsp.ret == NET_WORK_ERROR.TIMEOUT then
                        self.btn_open:setVisible(true)
                    else
                        self:close()
                    end
                end
            end
        })
    end)

    addButtonEvent(self.btn_confirm, function (  )
        self:close()
    end)

    addButtonEvent(self.btn_exchange, function (  )
        self:close(function (  )
            qf.event:dispatchEvent(ET.SHOW_EXCHANGEMALL_VIEW)
        end)
    end)

end

function M:playAnim( model )
    self.gui:getAnimation():playWithIndex(0)

    local function animationEvent(armatureBack, movementType, movementID)
        --if movementType == ccs.MovementEventType.complete then
            self.btn_confirm:setVisible(true)
            self.btn_exchange:setVisible(true)
            self.txt_tip:setVisible(true)
            self.txt_num:setVisible(true)
        --end
    end
    --self.gui:getAnimation():setMovementEventCallFunc(animationEvent)
    self.gui:getAnimation():setFrameEventCallFunc(animationEvent)
end

return M