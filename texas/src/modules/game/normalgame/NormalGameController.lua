
--[[
经典场: Controller
--]]

local AbstractGameController = import("..AbstractGameController")
local NormalGameController = class("NormalGameController", AbstractGameController)

local NormalGameView = import(".NormalGameView")
local NormalDDZDesk = import("src.cache.desk.NormalDDZDesk")

NormalGameController.TAG = "NormalGameController"
NormalGameController.Name = "normal"
function NormalGameController:ctor( params )
	NormalGameController.super.ctor(self, params)
end

function NormalGameController:initView( params )
    NormalGameController.super.initView(self)
	local view = NormalGameView.new(params)
	return view
end

function NormalGameController:createDeskCache()
    Cache.DDZDesk = NormalDDZDesk.new()
    Cache.DDZDesk.room_id = self.desk_cache.room_id
    Cache.DDZDesk.enterRef = self.desk_cache.enterRef
end

function NormalGameController:show( params )
    Cache.DeskAssemble:setGameType(GAME_DDZ)
	self.desk_cache = Cache.DeskAssemble:getCache()
	NormalGameController.super.show(self, params)
end

function NormalGameController:initGlobalEvent( ... )
    qf.event:addEvent(ET.GAME_BUY_ITEM_CHANGE, handler(self, self.updateBuyItemsNum))
end

function NormalGameController:initModuleEvent(  )
    NormalGameController.super.initModuleEvent(self)
    --用户准备请求
    self:addModuleEvent(ET.USER_READY_REQ, handler(self, self.userReadyReq))
    --请求房间任务列表
    self:addModuleEvent(ET.CMD_GAME_TASK_REQ, handler(self, self.gameTaskReq))
    --房间列表刷新通知
    self:addModuleEvent(ET.GAME_TASK_CHANGE_NTF, handler(self, self.gameTaskChangeNtf))
end

function NormalGameController:userReadyReq( paras )
    if not isValid(self.view) then return end

    local readyReq
    readyReq = function( room_id )
        GameNet:send({
            cmd = CMD.READY_REQ,
            body = {
                start_type = paras.start_type,
                show_multi = paras.show_multi
            },
            callback = function ( rsp )
                if rsp.ret == 0 then
                else
                    if not isValid(self.view) then return end

                    self.view:checkGold({
                        roomid = room_id,
                        startType = paras.start_type,
                        show_multi = paras.show_multi
                    })
                end
            end
        })
    end
    --检测金币
    GameNet:send({
        cmd = CMD.CHECK_GOLD_LIMIT_REQ,
        body = {
            room_id = Cache.DDZDesk.room_id
        },
        callback = function ( rsp )
            if rsp.ret == 0 then
                local model = rsp.model
                if model then
                    local room_id = model.room_id

                    if model.flag == 0 then
                        readyReq(Cache.DDZDesk.room_id)
                    elseif model.flag == 1 then
                        qf.event:dispatchEvent(ET.MYSELF_QUIT_ROOM)

                        qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT, {
                            content = GameTxt.no_gold_tips,
                            type = 7,
                            color = cc.c3b(0, 0, 0),
                            fontsize = 34,
                            cb_consure = function(  )
                                qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})--点击上报
                                qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
                            end
                        })
                    elseif model.flag == 2 then
                        if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
                            qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = string.format(DDZ_TXT.should_to_advanced_room, Cache.DDZconfig:getRoomConfigByRoomId(room_id).room_name), type = 2,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                                Cache.DDZDesk.room_id = id
                                qf.event:dispatchEvent(ET.CHANGE_TABLE)
                            end,cb_cancel = function ()
                                Cache.DDZDesk.startAgain = true
                                qf.event:dispatchEvent(ET.MYSELF_QUIT_ROOM)
                            end})
                        end
                    end
                end
            else
                qf.event:dispatchEvent(ET.MYSELF_QUIT_ROOM)

                if rsp.ret == 1370 then
                        qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                        qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})--点击上报
                        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
                    end})
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                end
            end
        end
    })
end

function NormalGameController:quitTableNotify( rsp )
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    NormalGameController.super.quitTableNotify(self, rsp)

    Cache.DDZDesk:updateCacheByUserquit(rsp.model)

    if rsp.model.reason == GameExitReason.TIMEOUT then
        if rsp.model.op_uin == Cache.user.uin then
            for k, v in pairs(Cache.DDZDesk._player_info) do
                if k ~= Cache.user.uin then
                    self.view:quitRoom(k)
                end
            end
        else
            self.view:quitRoom(rsp.model.op_uin)
        end
    else
        self.view:quitRoom(rsp.model.op_uin)
    end
end

function NormalGameController:gameTaskReq(paras)
    if not isValid(self.view) then return end

    GameNet:send({cmd = CMD.GAME_TASK_REQ, body = {}, callback = function ( rsp )
        if not isValid(self.view) then return end
        if rsp.ret == 0 then
            Cache.Config:updateGameTaskInfo(rsp.model)

            if paras and paras.openGameTask then
                self.view:openGameTask()
            end
            self.view:updateGameTaskBtn()
        end
    end})
end

function NormalGameController:gameTaskChangeNtf(rsp)
    if not isValid(self.view) then return end
    if not rsp or not rsp.model then return end

    Cache.Config:updateGameTaskInfoByNtf(rsp.model)
    self.view:updateGameTask()
end

function NormalGameController:MathingSuccess()
    if not isValid(self.view) then return end

    ModuleManager.DDZhall:remove()
    NormalGameController.super.MathingSuccess(self)
end

function NormalGameController:removeModuleEvent()
    NormalGameController.super.removeModuleEvent(self)
    qf.event:removeEvent(ET.USER_READY_REQ)
end

function NormalGameController:updateBuyItemsNum()
    if not isValid(self.view) then return end
    self.view:updateBuyItems()
end

return NormalGameController