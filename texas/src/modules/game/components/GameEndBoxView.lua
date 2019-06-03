local M = class("GameEndBoxView", CommonWidget.BasicWindow)

function M:ctor( paras )
    M.super.ctor(self, paras)
end

function M:initUI( paras )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(DDZ_Res.matchBoxViewJson)

    self.btn = ccui.Helper:seekWidgetByName(self.gui, "btn")
    self.box_node = ccui.Helper:seekWidgetByName(self.gui, "box_node")
    self.txt_title = ccui.Helper:seekWidgetByName(self.gui, "txt_title")

    self.txt_title:setString(string.format( DDZ_TXT.boxViewTitle, Cache.user:getConfigByLevel(paras.match_lv).title ))
    self.match_box_lv = paras.match_box_lv

    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(DDZ_Res.boxAnimationJson)

    self.boxArmature = ccs.Armature:create("NewAnimation190124baoxiang")
    self.boxLightBG = ccs.Armature:create("NewAnimation190124baoxiang")
    self.boxEffect = ccs.Armature:create("NewAnimation190124baoxiang")

    self.box_node:addChild(self.boxLightBG)
    self.box_node:addChild(self.boxArmature)
    self.box_node:addChild(self.boxEffect)

    self.boxLightBG:getAnimation():play("Animation3guang_Copy1", -1, 0)
    self.boxArmature:getAnimation():play("Animation2tan", -1, 0)
    self.boxEffect:getAnimation():play("Animation3guang", -1, 0)
end

function M:initClick()
    addButtonEvent(self.btn, function (  )
        self:openBox()
    end)
end

function M:openBox(  )
    qf.event:dispatchEvent(ET.EVENT_OPEN_BAOXIANG,{
        match_box_lv = self.match_box_lv,
        cb = function (rsp)
            if rsp.ret == 0 then
                local paras = {
                    dismissCallBack = function (  )
                        if isValid(self) then
                            self:close()
                        end
                    end,
                    rewardInfo = {0, rsp.model.coupon}
                }
                qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, paras)
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                self:close()
            end
        end
    })
end

return M