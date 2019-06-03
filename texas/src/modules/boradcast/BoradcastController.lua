
local BoradcastController = class("BoradcastController",qf.controller)

BoradcastController.TAG = "BoradcastController"
local BoradcastView = import(".BoradcastView")

function BoradcastController:ctor(parameters)
    BoradcastController.super.ctor(self)
    self._newWorldMsgList={}
    self._broadcast = {}
end


function BoradcastController:initModuleEvent()

end

function BoradcastController:removeModuleEvent()

end
-- 这里注册与服务器相关的的事件，不销毁
function BoradcastController:initGlobalEvent()
    -- 设置广播位置
    qf.event:addEvent(ET.SETBROADCAST, handler(self, self.setBroadCast))
    qf.event:addEvent(ET.NET_BROADCAST_OTHER_EVT,handler(self,self.getBroadcast))
    qf.event:addEvent(ET.GLOBAL_SHOW_BROADCASE_TXT,handler(self,self._showBroadcast))
    qf.event:addEvent(ET.GLOBAL_SHOW_BROADCASE_LAYOUT,handler(self,self._showBroadcast_layout))
    qf.event:addEvent(ET.GLOBAL_HIDE_BROADCASE_LAYOUT,handler(self,self._hideBroadcast_layout))
    qf.event:addEvent(ET.EVENT_QUERY_DAOJU_BY_ID,function(paras)
        if paras ==nil or paras.prop_id == nil then
            return
        end 
        GameNet:send({cmd=CMD.EVENT_QUERY_DAOJU_BY_ID,body={prop_id = paras.prop_id},
            callback=function(rsp)
                logd(" 请求喇叭个数回调："..tostring(rsp))
                if rsp.ret ~= 0 then
                    --不成功提示
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                end
                self.view:setXiaoLabaNum(rsp.model)
            end})
    end)
    qf.event:addEvent(ET.REFRESH_LABA_MSG_LIST,function(paras)
        self.view:xiaolabaRefresh()
    end)
end


function BoradcastController:_showBroadcast_inGame ()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        return
    end
    self._showBroadcastIng = false  
    for k,v in pairs(self._broadcast) do
        self._showBroadcastIng = true  
        self.view:showBoradcastTxt_inGame(v) 
        table.remove(self._broadcast,1) 
            break
    end
end
function BoradcastController:_showBroadcast()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        return
    end
    --if ModuleManager:judegeIsInMain() then
        self:showWorldMsg () 
    -- elseif ModuleManager:judgeIsInNormalGame() then
    --     self:_showBroadcast_inGame()
    -- end
end

--新世界广播
function BoradcastController:showWorldMsg() 
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then  return end
    if self.view.isRuning then return end
    local msgItem = {}
    if not self._broadcast or #self._broadcast<1 then
        msgItem = Cache.wordMsg:getDeafultMsg()
    else
        for k ,v in pairs(self._broadcast)do
            msgItem = v
            table.remove(self._broadcast,1)
            break
        end
    end
    
    if msgItem.content == nil or msgItem.content == "" then 
        self.view:hideBoradcast()
    return end
    self.view:showBoradcastTxt(msgItem)
end

--设置广播位置
function BoradcastController:setBroadCast(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        return
    end
    self.view:setBroadCast(paras)
end

function BoradcastController:_showBroadcast_layout ()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then  return end
    if self.view.isRuning then
        self.view:showBoradcast()
    end
end
function BoradcastController:_hideBroadcast_layout()
    self.view:hideBoradcast()
end

function BoradcastController:getBroadcast(paras)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then return end
    paras = paras.model
    loga(pb.tostring(paras),self.TAG)
    local level = paras.level or 4
    local msgItem = {}
    msgItem.level = paras.level
    msgItem.nick = paras.nick
    msgItem.content = paras.content
    msgItem.new_content = paras.new_content
    msgItem.contents={}
    msgItem.contents["str1"] = paras.contents["str1"]
    msgItem.contents["str2"] = paras.contents["str2"]
    msgItem.contents["str3"] = paras.contents["str3"]
    msgItem.contents["str4"] = paras.contents["str4"]
    Cache.wordMsg:saveMsg(msgItem)
    
    local vValue = self.view:isLabaShow()
    if vValue then
        qf.event:dispatchEvent(ET.REFRESH_LABA_MSG_LIST)
    end

    table.insert(self._broadcast,msgItem) 
    if #self._broadcast >2 then --超过限制条数就移除旧的消息
        table.remove(self._broadcast,1)
    end
    --if ModuleManager:judegeIsInMain() then
        self:showWorldMsg () 
    -- else 
    --     self:_showBroadcast_inGame() 
    -- end
end


function BoradcastController:initGame()
end

function BoradcastController:initView(parameters)
    local view = BoradcastView.new(parameters)
    return view
end


function BoradcastController:remove()
    BoradcastController.super.remove(self)
end

return BoradcastController