
--[[
比赛场: Controller
--]]

local AbstractGameController = import("..AbstractGameController")
local EventGameController = class("EventGameController", AbstractGameController)

local EventGameView = import(".EventGameView")
local EventDDZDesk = import("src.cache.desk.EventDDZDesk")

EventGameController.TAG = "EventGameController"
EventGameController.Name = "event"
function EventGameController:ctor( params )
	EventGameController.super.ctor(self, params)
end

function EventGameController:initView( params )
	local view = EventGameView.new(params)
	return view
end

function EventGameController:createDeskCache()
    Cache.DDZDesk = EventDDZDesk.new()
    Cache.DDZDesk.room_id = self.desk_cache.room_id
    Cache.DDZDesk.enterRef = self.desk_cache.enterRef
end

function EventGameController:show( params )
    Cache.DeskAssemble:setGameType(GAME_DDZ)
	self.desk_cache = Cache.DeskAssemble:getCache()

	EventGameController.super.show(self, params)
end

function EventGameController:enterRoomNotify(rsp)
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end
    local isComeBack = Cache.user.come_back
    EventGameController.super.enterRoomNotify(self, rsp)

    if table.nums(Cache.DDZDesk._player_info) < 3 then
        Cache.globalInfo:setStatUploadTime(STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_WAIT_SUCC_TIME)
        qf.event:dispatchEvent(ET.UPDATE_GAME_MATHING_VIEW, {
            firstEnterUser = Cache.DDZDesk.firstEnterUser,
            info = Cache.DDZDesk._player_info,
            time = Cache.DDZDesk.op_time_out, 
            cb = handler(self,self.MathingSuccess)
        })
    else
        --if isComeBack or Cache.user.old_roomid > 0 then
            qf.event:dispatchEvent(ET.REMOVE_GAME_MATHING_VIEW)
            self:MathingSuccess()
        -- else
        --     qf.event:dispatchEvent(ET.UPDATE_GAME_MATHING_VIEW, {
        --         firstEnterUser = Cache.DDZDesk.firstEnterUser,
        --         info = Cache.DDZDesk._player_info,
        --         time = Cache.DDZDesk.op_time_out, 
        --         cb = handler(self,self.MathingSuccess)
        --     })
        -- end
    end
end

function EventGameController:quitTableNotify(rsp)
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    EventGameController.super.quitTableNotify(rsp, self)

    if rsp.model.reason == GameExitReason.EVENT_OVER then
        return
    end

    if rsp.model.op_uin == Cache.user.uin then
        qf.event:dispatchEvent(ET.REMOVE_GAME_MATHING_VIEW)
    else
        Cache.DDZDesk:updateCacheByUserquit(rsp.model)

        if Cache.DDZDesk.status == GameStatus.READY and Cache.DDZDesk.round_index ==1 then
            qf.event:dispatchEvent(ET.UPDATE_GAME_MATHING_VIEW,{firstEnterUser = Cache.DDZDesk.firstEnterUser,info=Cache.DDZDesk._player_info,time=Cache.DDZDesk.op_time_out,cb=handler(self,self.MathingSuccess)})
        end
    end

    self.view:quitRoom(rsp.model.op_uin)
end

function EventGameController:MathingSuccess()
    if not isValid(self.view) then return end

    ModuleManager.matching:remove()
    self.view:setVisible(true)

    qf.platform:uploadEventStat({
        module = "performance",
        source = "pywxddz",
        event = STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_MATCH_WAIT_SUCC,
        value = 1,
        custom = Cache.user.match_level,
    })

    EventGameController.super.MathingSuccess(self)
end


return EventGameController