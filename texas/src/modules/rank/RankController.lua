
local RankController = class("RankController",qf.controller)

RankController.TAG = "RankController"

function RankController:ctor(parameters)
    RankController.super.ctor(self)
    
end


function RankController:initModuleEvent()

end

function RankController:removeModuleEvent()

end


-- 这里注册与服务器相关的的事件，不销毁
function RankController:initGlobalEvent()
end


function RankController:initGame()
	
end

function RankController:initView(parameters)
    local view = nil;
    return view
end


function RankController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"rank")
    RankController.super.remove(self)
end

return RankController