local GlobalInfo = class("GlobalInfo")

GlobalInfo.TAG = "GlobalInfo"

function GlobalInfo:ctor()
    self._global_info = {}
    self._uploadTimeTab = {}
end

function GlobalInfo:set(key, value)
    self._global_info[key] = value
end

function GlobalInfo:get(key)
    return self._global_info[key]
end

function GlobalInfo:setStatUploadTime()
    self._uploadTimeTab[type] = qf.time.getTime()
end

function GlobalInfo:getStatUploadTime()
    local curTime = qf.time.getTime()
    local saveTime = self._uploadTimeTab[type]
    if saveTime then
        local instance = (curTime - saveTime) * 1000
        self._uploadTimeTab[type] = nil
        return instance
    end
    return nil
end

return GlobalInfo