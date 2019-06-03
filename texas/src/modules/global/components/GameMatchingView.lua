--赛事匹配弹窗界面
local M = class("GameMatchingView", CommonWidget.BasicWindow)

function M:ctor( paras )
    M.super.ctor(self, paras)
end

function M:init( paras )
    self.timeOutCount = 0
end

function M:initUI(  )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(DDZ_Res.gameMatchingViewJson)

    self.cancle_mathing_btn = ccui.Helper:seekWidgetByName(self.gui, "cancle_mathing_btn")
    self.time = ccui.Helper:seekWidgetByName(self.gui, "time")

    self.time:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.CallFunc:create(function (  )
                local min = string.format("%02d",math.modf(self.timeOutCount/60))
                local sce = string.format("%02d",math.mod(self.timeOutCount,60))
                self.time:setString(min..":"..sce)

                self.timeOutCount = self.timeOutCount + 1

                if self.timeOutCount >= Cache.DDZDesk.matching_timeout then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = DDZ_TXT.match_timeout})

                    Cache.DDZDesk.startAgain = nil
                    qf.event:dispatchEvent(ET.RE_QUIT)
                    self:close()
                end
            end),
            cc.DelayTime:create(1)
        )
    ))

    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(DDZ_Res.matchingAnimation)

    for i = 1, 3 do
        local head = ccui.Helper:seekWidgetByName(self.gui, "user_" .. i)
        local animationLayer = head:getChildByName("animation_layer")
        animationLayer:setVisible(true)

        local turnicon = ccs.Armature:create("guiangquan")
        animationLayer:addChild(turnicon, 0)
        turnicon:setName("matchingAni")
        turnicon:setPosition(animationLayer:getContentSize().width / 2, head:getContentSize().height / 2)
        turnicon:getAnimation():playWithIndex(0)
    end
end

function M:initClick(  )
    addButtonEvent(self.cancle_mathing_btn, function (  )
        Cache.DDZDesk.startAgain = nil
        qf.event:dispatchEvent(ET.RE_QUIT)
        self:close()
    end)
end

function M:updateUI( paras )
    dump(paras, "更新匹配")
    for i = 1, 3 do
        local head = ccui.Helper:seekWidgetByName(self.gui, "user_" .. i)
        local animationLayer = head:getChildByName("animation_layer")
        animationLayer:setVisible(true)
        head:loadTexture(DDZ_Res.mathingHeadImg0)
    end

    local index = 2
    for k,v in pairs(paras.info) do
        local head
        dump(v)
        if v.uin == Cache.user.uin then
            head = ccui.Helper:seekWidgetByName(self.gui, "user_1")
        else
            head = ccui.Helper:seekWidgetByName(self.gui, "user_" .. index)
            index = index + 1
        end

        head:getChildByName("animation_layer"):setVisible(false)
        head:loadTexture(string.format(DDZ_Res.mathingHeadImg1,v.sex))
    end

    if index > 3 then
        self.cancle_mathing_btn:setVisible(false)
        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(function (  )
                if paras.cb then
                    paras.cb()
                end
                ModuleManager.matching:remove()
                self:close()
            end)
        ))
    end
end

--注册返回键
function M:registerBack(  )
    Util:registerKeyReleased({self = self,cb = function ()
        if self.BACK_TO_CLOSE then
            Cache.DDZDesk.startAgain = nil
            qf.event:dispatchEvent(ET.RE_QUIT)
            self:close()
        end
	end})
end

return M