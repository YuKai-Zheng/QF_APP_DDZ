local M = class("Scheduler")


function M:ctor()
    -- body
    self.id = {}
end

function M:delayCall(delay,callback,...)
	local schedEntry
	local args = {...}
    schedEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function ()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedEntry)
            callback(self,unpack(args))
        end,
    delay, false)

    table.insert(self.id,schedEntry)
    return schedEntry
end


function M:scheduler(tival,callback,...)

    local schedEntry
    local args = {...}
    schedEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function ()
            callback(self,unpack(args))
        end,
    tival, false)

    table.insert(self.id,schedEntry)
    return schedEntry

end

function M:clearAll()
    -- body
    for k,v in pairs(self.id) do
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
    end
end

function M:unschedule(sid)
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sid)
end



Scheduler = M.new()