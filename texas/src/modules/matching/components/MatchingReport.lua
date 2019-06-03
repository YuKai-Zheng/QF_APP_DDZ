local MatchingReport = class("matchingReport", CommonWidget.BasicWindow)
MatchingReport.TAG = "matchingReport"

MatchingReport.BACK_TO_CLOSE = false

function MatchingReport:ctor(paras)
    MatchingReport.super.ctor(self, paras)

    if paras and paras.cb then
        self.cb=paras.cb
    end
end

function MatchingReport:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.matchingReportJson)

    local btn_open = ccui.Helper:seekWidgetByName(self.gui,"btn_open")
    btn_open:setTouchEnabled(false)

    self.winSize = cc.Director:getInstance():getWinSize()

    if FULLSCREENADAPTIVE then
        btn_open:setPositionX(btn_open:getPositionX()+(self.winSize.width - 1920)/2)
        self.gui:setPositionX((self.winSize.width - 1920)/2)
    end
    local size = cc.Director:getInstance():getWinSize()
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    local face0,face1,face2
    armatureDataManager:addArmatureFileInfo(GameRes.matchingReportAnimation)
    face2 = ccs.Armature:create("MatchReportAnimation")
    face2:setPosition(size.width/2-240,size.height/2+150)

    face2:getAnimation():playWithIndex(2)
    face2:getAnimation():setMovementEventCallFunc(function ()
        -- body
        face2:removeFromParent()
        face0 = ccs.Armature:create("MatchReportAnimation")
        face0:setPosition(size.width/2-240,size.height/2+150)
        face0:getAnimation():playWithIndex(0)
        self.gui:addChild(face0, 0)
        btn_open:setTouchEnabled(true)
    end)

    self.gui:addChild(face2, 0)

    addButtonEvent(btn_open, function()
        face1 = ccs.Armature:create("MatchReportAnimation")
        face1:setPosition(size.width/2-240,size.height/2+150)
        face1:getAnimation():playWithIndex(1)
        face1:getAnimation():setMovementEventCallFunc(function ()
            face0:removeFromParent()
            face1:removeFromParent()
            qf.event:dispatchEvent(ET.CMD_SHOW_MATCH_HONOR)
            self:close()
        end)
        self.gui:addChild(face1, 0)
    end)
end

return MatchingReport