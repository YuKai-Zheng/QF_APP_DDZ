local ChangeUserController = class("ChangeUserController",qf.controller)

local ChangeUserView = import(".ChangeUserInfoView")

ChangeUserController.TAG = "ChangeUserController"

function ChangeUserController:ctor(parameters)
    ChangeUserController.super.ctor(self)
end


function ChangeUserController:initModuleEvent()
    
end

function ChangeUserController:removeModuleEvent()
end

-- 这里注册与服务器相关的的事件，不销毁
function ChangeUserController:initGlobalEvent()
    qf.event:addEvent(ET.NET_USER_MODIFY_REQ,function(paras) 
        if paras.sex == nil or paras.nick == nil or paras.cb == nil then return end
        GameNet:send({cmd = CMD.USER_MODIFY,body = {sex = paras.sex,nick = paras.nick},callback = function(rsp) 
           paras.cb({callrsp=rsp,nick=paras.nick,sex=paras.sex})
        end})
    end)

    qf.event:addEvent(ET.SHOW_MYSELF_INFO_VIEW, handler(self, self.showMySelfView))
    qf.event:addEvent(ET.CHANGE_VIEW_UPDATE_USER_HEAD, handler(self, self.processChangeHeadNotify))
    qf.event:addEvent(ET.NET_DIAMOND_CHANGE_USERINFO_EVT, handler(self, self.onDiamondChanged))
    qf.event:addEvent(ET.USER_HEADBOX_RED_NTF, handler(self, self.onUserHeadBoxRedChange))
    qf.event:addEvent(ET.REFRESH_MYSELF_GOLD, handler(self, self.refreshGold))
end
function ChangeUserController:initGame()

end

function ChangeUserController:initView(parameters)

end

function ChangeUserController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"change_userinfo")
    ChangeUserController.super.remove(self)
end

--更改个人信息消息处理
function ChangeUserController:processChangeHeadNotify(model)
	if not self.myselfView then return end
    
    local myselfView = PopupManager:getPopupWindowByUid(self.myselfView)

    if isValid(myselfView) then
        myselfView:updateUserHead()
    end
end

function ChangeUserController:onDiamondChanged()
end

function ChangeUserController:onUserHeadBoxRedChange()
    if not self.myselfView then return end

    local myselfView = PopupManager:getPopupWindowByUid(self.myselfView)

    if isValid(myselfView) then
        myselfView:onUserHeadBoxRedChange()
    end
end

function ChangeUserController:refreshGold(  )
    if not self.myselfView then return end

    local myselfView = PopupManager:getPopupWindowByUid(self.myselfView)

    if isValid(myselfView) then
        myselfView:refreshGold()
    end
end

function ChangeUserController:showMySelfView( parameters )
    local prop = {}
    prop.isedit = parameters.isedit or false
    prop.isInGame = parameters.isInGame or false
    if parameters and parameters.localinfo then
        prop.localinfo = parameters.localinfo
    end
    if parameters and parameters.cb then
        prop.cb = parameters.cb
    end

    self.myselfView = PopupManager:push({class = ChangeUserView, init_data = prop})
    PopupManager:pop()
end

return ChangeUserController