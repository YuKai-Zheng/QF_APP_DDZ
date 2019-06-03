-- 日志管理工具类类

local LogUtil = class("LogUtil")

local logDirName = "log"

function LogUtil:ctor()
    --print ("___________日志所在的文件夹位置：" .. self:getLogDirPath())
end

-- 保存日志到本地
function LogUtil:saveLogToFile(logTxt)
    if SAVE_LOG == false or type(logTxt) ~= 'string' then return end
	if logTxt == nil or logTxt == "" then return end
	local date = os.date("*t", timestamp)
    local month = string.format("%02d", date.month)
    local day = string.format("%02d", date.day)
    local hour = string.format("%02d", date.hour)
    local min = string.format("%02d", date.min)
    local sec = string.format("%02d", date.sec)
    local currentTime = date.year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" ..min .. ":" ..sec
	local flag = self:logFileOperate(self:getFileName(), "[ " .. currentTime .. " ]  " .. logTxt .. "\n")
	return flag
end

function LogUtil:logFileOperate(fileName, content)
    if qf and qf.platform then
        qf.platform:uploadError({content=content,debug="1"})
    else
    	local file = assert(io.open(fileName, 'r'))
    	if file then
            if file:write(content) == nil then return false end
            file:close()
            return true
        else
            return false
        end
    end
end

-- 获取日志文件名
function LogUtil:getFileName()
	local dirPath = self:getLogDirPath()
	local date = os.date("*t", timestamp)
    local month = string.format("%02d", date.month)
    local day = string.format("%02d", date.day)
    local timeStr = date.year .. "-" .. month .. "-" .. day
	local fileName = dirPath .. timeStr .. ".txt"
    if not CCFileUtils:sharedFileUtils():isFileExist(fileName) then
        self:removeOldTxt()
    end
	return fileName
end

-- 获取和创建文件夹
function LogUtil:getLogDirPath()	
	-- 获得文件保存路径
	local writeblePath = cc.FileUtils:getInstance():getWritablePath() .. logDirName
    if qf.device.platform == "android" then
        writeblePath = qf.platform:getExternalPath() .. "/" .. logDirName
    end
	if not CCFileUtils:sharedFileUtils():isFileExist(writeblePath) then
	    lfs.mkdir(writeblePath)
    end
    return writeblePath .. "/"
end

--只保存最近的5个log日志
function LogUtil:removeOldTxt( ... )
    local writeblePath = cc.FileUtils:getInstance():getWritablePath() .. logDirName
    local txtTabel = {}
    for file in lfs.dir(writeblePath) do
        if file ~="." and file ~=".." then
            table.insert(txtTabel,writeblePath.."/"..file)
        end
    end
    if #txtTabel>4 then
        os.remove(txtTabel[1])
    end
end

-- 保存日志到本地
function LogUtil:savenetErrorLogToFile(logParams)
    -- if SAVE_LOG == false or type(logParams) ~= 'table' then return end
    -- if type(logParams) ~= 'table' then return end
    if type(logParams) ~= 'table' and #logParams == 0  then 
        print("---------savenetErrorLogToFile----------------logParams_error--------------")
        return 
    end
    local date = os.date("*t", timestamp)
    local month = string.format("%02d", date.month)
    local day = string.format("%02d", date.day)
    local hour = string.format("%02d", date.hour)
    local min = string.format("%02d", date.min)
    local sec = string.format("%02d", date.sec)
    local currentTime = date.year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" ..min .. ":" ..sec
    logParams["currentTime"]=currentTime
    local flag = self:lognetErrorFileOperate(self:getnetErrorFileName(), logParams)
    return flag
end

function LogUtil:lognetErrorFileOperate(fileName, logParams)
    -- if qf and qf.platform then
    --     qf.platform:uploadError({content=content,debug="1"})
    -- else
    local file
    if not CCFileUtils:sharedFileUtils():isFileExist(fileName) then
        file = assert(io.open(fileName, 'a+'))
        file:close()
    end
    
    if qf.device.platform == "android" then
        file = assert(io.open(fileName, 'a+'))
    else
        file = assert(io.open(fileName, 'r+'))  
    end
    local log_nerErrorList = {}
    if file then
        local t = file:read("*all")
        file:close()
        if nil ~= t and "" ~= t then
           log_nerErrorList = json.decode( t )
        end
        table.insert(log_nerErrorList,logParams) 
        
        if #log_nerErrorList > 10 then
            loga("超过10条，更新...")
            table.remove(log_nerErrorList,1)
        end
        local jsonContent = json.encode(log_nerErrorList)
        local file1 = assert(io.open(self:getnetErrorFileName(), 'w+'))
        if file1:write(jsonContent) == nil then  
            file1:close()
            return false 
        end
        file1:close()
        return true
    else
        loga("----------lognetErrorFileOperate---------------error-")
        return false
    end
end

-- 获取日志文件名
function LogUtil:getnetErrorFileName()
    local dirPath = self:getLogDirPath()
    local fileName = dirPath .. "netError" .. ".txt"
    return fileName
end

-- 删除日志文件名
function LogUtil:removeNetErrorFileName()
    if CCFileUtils:sharedFileUtils():isFileExist(self:getnetErrorFileName()) then
        local file1 = assert(io.open(self:getnetErrorFileName(), 'w+'))
        file1:close()
    end
end

--读取保存的日志
function LogUtil:readNetErrorLogTxt( ... )
    local nerErrorPath = self:getnetErrorFileName()
    local log_nerErrorList = {}
    loga("----------readNetErrorLogTxt-------------nerErrorPath---"..nerErrorPath)
    if io.exists(nerErrorPath) then
        loga(nerErrorPath)
        local file = assert(io.open(nerErrorPath, 'r+'))
        if file then
            local t = file:read("*all")   
            loga(t)
            file:close()
            if nil ~= t and "" ~= t then
               log_nerErrorList = json.decode( t )
            end
        end
    end
    return log_nerErrorList
end

function LogUtil:removeAllTxt( ... )
    local writeblePath = cc.FileUtils:getInstance():getWritablePath() .. logDirName
    for file in lfs.dir(writeblePath) do
        if file ~="." and file ~=".." then          
            os.remove(writeblePath.."/"..file)
        end
    end
end

return LogUtil