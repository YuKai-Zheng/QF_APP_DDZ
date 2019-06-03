local HallController = class("HallController",qf.controller)
HallController.TAG = "HallController"

local hallView = import(".HallView")


function HallController:ctor(parameters)
    HallController.super.ctor(self)
end

function HallController:initView(parameters)
    qf.event:dispatchEvent(ET.MODULE_SHOW,"DDZhall")
    local view = hallView.new(parameters)
    return view
end

function HallController:initGlobalEvent( ... )
    qf.event:addEvent(ET.QUICKSTARTCLICK,handler(self,self.autoStart))
    qf.event:addEvent(ET.ENTERGAMECLICK,handler(self,self.enterGame))
end

function HallController:initModuleEvent()
    self:addModuleEvent(ET.GLOBAL_FRESH_LOBBIES_GOLD, handler(self, self.updateUserInfo))
    self:addModuleEvent(ET.EVT_USER_FOCARD_CHANGE_HALLVIEW, handler(self, self.updateUserInfo))
    
    qf.event:addEvent(ET.HIDE_FIRSTRECHARGE_ENTRY_hallView,function ( ... )
        if self.view then
            self.view:removefirstRechargeEntry()
        end
    end) 
end

function HallController:removeModuleEvent()
    qf.event:removeEvent(ET.GLOBAL_FRESH_LOBBIES_GOLD)
    qf.event:removeEvent(ET.EVT_USER_FOCARD_CHANGE_HALLVIEW)
    qf.event:removeEvent(ET.HIDE_FIRSTRECHARGE_ENTRY_hallView)
end

--快速开始
function HallController:autoStart( ... )
    -- body
    if isValid(self.view) then
        self.view:quickStartGame()
    end
end

function HallController:updateUserInfo( ... )
    if self.view == nil then
        return
    end
    self.view:updateUserInfo()
end

function HallController:enterGame( paras )
    -- body
    ModuleManager.DDZhall:getView():setPosition(-19200,0)
    if self.view then
        self.view:enterGame(paras)
    else
        self.view:enterGame(paras)
    end
end

return HallController