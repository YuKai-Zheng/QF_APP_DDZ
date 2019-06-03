local M = class("RedPackageRewardOpenView", CommonWidget.BasicWindow)

M.BACK_TO_CLOSE = false

function M:ctor( paras )
    M.super.ctor(self, paras)
end

function M:initUI( paras )
    local winSize = cc.Director:getInstance():getWinSize()
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.redPackageOpenAnimation)
    self.gui = ccs.Armature:create("NewAnimationdonghua03")

    self.gui:setPosition(cc.p(winSize.width / 2, winSize.height / 2))

    self.btn_confirm = ccui.Button:create()
    self.btn_exchange = ccui.Button:create()
    self.txt_tip = ccui.Text:create(GameTxt.redpack_tip,GameRes.font1, 30)
    self.txt_num = cc.LabelBMFont:create()
    self.txt_num:setFntFile(GameRes.redPack_fnt)
    self.txt_num:setString(string.format( GameTxt.gameTask_reward_txt[2],paras.num )) 
    self.txt_num:setVisible(false)
    self.txt_num:setPositionY(-40)
    self.gui:addChild(self.txt_num, 100)

    self.btn_confirm:loadTextureNormal(DDZ_Res.global_TouMing_Png)
    self.btn_confirm:ignoreContentAdaptWithSize(false)
    self.btn_confirm:setContentSize(cc.size(360, 130))

    self.btn_exchange:loadTextureNormal(GameRes.redPack_btn_exchange)
    self.txt_tip:setColor(cc.c3b(252, 176,0))

    self.gui:addChild(self.btn_confirm, 100)
    self.gui:addChild(self.btn_exchange, 100)
    self.gui:addChild(self.txt_tip, 100)

    self.btn_confirm:setPositionY(-180)
    self.btn_confirm:setVisible(false)

    self.btn_exchange:setPositionY(-290)
    self.btn_exchange:setVisible(false)
    self.txt_tip:setVisible(false)
    self.txt_tip:setPositionY(-420)
    self:playAnim()
end

function M:initClick(  )
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

    local function animationEvent()
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