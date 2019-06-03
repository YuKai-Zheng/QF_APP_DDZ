
local Net = class("Net")
local NetSerializer = import(".NetSerializer")

Net.TAG = "NET-UTIL"

local NUM_ERROR_REQUEST = 3 --onConnectError触发多少次进行重连

function Net:ctor()
    -- 每个address尝试连接几次
    self.tryTimesPerAddress = 3

    self.time_pause_net = 0 --游戏切入后台，网络被暂停的时间

    -- 连接失败的次数
    self.connectTryTimes = 0
    -- 地址列表
    self.addressList = {}

    self.num_connect_error = 0 --onConnectError触发的次数
    self.is_requesting_address = false --标记是否正在拉取服务器地址

    self.net_serializer = NetSerializer.new()
end

function Net:start(addressList)
    --用新的一组地址进行连接服务器时，一定要把拉取服务器地址标记置为false
    --而此时一定是：1，已经拉取到了服务器地址；2，不需要进行拉取
    self.is_requesting_address = false

    self.addressList = addressList
    -- 清除
    self.connectTryTimes = 0

    self:connect()
end

--连接服务器
--return 1已经连接了服务器无需再连接 2服务器地址为空 addres正常连接服务器
function Net:connect()
    --已经连接上了无需再连接了
    if self:isConnected() then
        return 0
    end
    --地址为空直接返回
    if #self.addressList == 0 then
        -- 内容为空
        return 1
    end

    local function execConnect( index )
        local address = self.addressList[index]

        logd("connectTryTimes: " .. tostring(self.connectTryTimes), self.TAG)
        logd("index: " .. tostring(index) .. ", host: " .. tostring(address[1]) .. ", port: " .. tostring(address[2]) , self.TAG)

        ferry.ScriptFerry:getInstance():init(address[1], address[2])

        if not ferry.ScriptFerry:getInstance():isRunning() then
            ferry.ScriptFerry:getInstance():start()
        else
            ferry.ScriptFerry:getInstance():connect()
        end
    end

    local function calcAddressIndex( ... )
        return math.floor(self.connectTryTimes / self.tryTimesPerAddress) + 1
    end
    -- lua 索引要+1的
    local addressIndex = calcAddressIndex()

    local ret
    if addressIndex > #self.addressList then
        -- 说明已经超过最后的address了，要重新获取了
        -- 但为了保证有connect，防止服务器地址一直拉取失败，只能从头再使用一遍了
        self.connectTryTimes = 0
        addressIndex = calcAddressIndex()

        execConnect(addressIndex)

        ret = 2
    else
        execConnect(addressIndex)

        ret = self.addressList[addressIndex]
    end

    -- 累加一次
    self.connectTryTimes = self.connectTryTimes + 1

    --onConnectError触发次数置为0
    --onConnectError只有在connect之后才会触发
    self.num_connect_error = 0

    return ret
end

function Net:clearTryTimesForCurrentAddress()
    -- 将针对当前地址的错误次数清零
    -- 当连接成功的时候，调用这个函数
    
    -- logd("connectTryTimes before: " .. tostring(self.connectTryTimes), self.TAG)
    self.connectTryTimes = math.floor(self.connectTryTimes / self.tryTimesPerAddress) * self.tryTimesPerAddress
    -- logd("connectTryTimes after: " .. tostring(self.connectTryTimes), self.TAG)
end

--[[--

]]
function Net:onMsg(paras)
    self.net_serializer:onMessage(paras)
end

function Net:getDataBySignedBody( signedbody, cmd )
    return self.net_serializer:getDataBySignedBody(signedbody, cmd)
end

--[[--
cmd = number
body = table
callback = function () end
timeout=0.5
penetrate=true
hanlder=nil
若有回调则不调用onmessage
否则传给onmessage
若发送的单向事件，不填回调，penetrate为false即可

wait  界面是否显示等待
txt 界面显示等待的文字
]]

function Net:send(paras)

    if paras.cmd == nil  then
        loge(" send cmd error  , args #1 cannot nil" , self.TAG)
    end

    local timeout = paras.timeout or 20
    local callback = paras.callback or nil
    local handler = paras.handler or nil
    local body = paras.body or {}
    local box = self.net_serializer:packBox({method="req",cmd=paras.cmd,body=body})

    local wait = paras.wait or false
    local txt = paras.txt

    if wait == true then qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=txt}) end

    -- dump(timeout)

    ferry.ScriptFerry:getInstance():send(box,
        function(event)
            if wait == true then qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"}) end
            if event:getWhat() == ferry.EventType.timeout or event:getWhat() == ferry.EventType.error then
                logd("  --- ferry.EventType.timeout or ferry.EventType.error --- ")
                if callback then callback({ret=NET_WORK_ERROR.TIMEOUT}) end
                logd("  --- call back ----- ")
            elseif event:getWhat() == ferry.EventType.recv then
                if (event:getBox() and callback) then
                    local unpackparas = self.net_serializer:unpackBox(event:getBox())
                    if unpackparas ~= nil then callback(unpackparas)
                    else logd(" error on reiv body " , self.TAG)
                    end
                end
            else
            --loge("----- unkown error ------ ")
            end
        end
        ,timeout,handler)
end

function Net:onConnect(paras)
    qf.event:dispatchEvent(ET.LOGIN_NET_GOTO_LOGIN)
    self.cancellation = false--在这里要把注销开关关掉
    self.loginlation = false

    -- 清除错误次数
    self:clearTryTimesForCurrentAddress()
end

function Net:reReg()

    local funcid = nil
    funcid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        self:onConnect()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(funcid)
    end,2,false)
end

function Net:disconnect(paras)
    self.cancellation = paras ~= nil and paras.is_cancellation or false
    self.loginlation = paras ~= nil and paras.is_loginlation or false
    ferry.ScriptFerry:getInstance():disconnect()
end

function Net:onDisconnect(paras)
    if self.cancellation == true then
        return
    end

    qf.event:dispatchEvent(ET.NET_DISCONNECT_NOTIFY, {})    --断网通知, 需要重新加载的模块需要处理此消息
    local _type = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    if VAR_LOGIN_TYPE_NO_LOGIN ~= _type then
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",reConnect = 1 ,txt=GameTxt.reConnect})
    end

    local ret = self:connect()
    if ret == 1 or ret == 2 then
        self:onAllAddressFailed()
    end
end

function Net:isConnected()
    return ferry.ScriptFerry:getInstance():isConnected()
end

function Net:delAllRspCbs()
    ferry.ScriptFerry:getInstance():delAllRspCallbacks()
end

function Net:resume()
    self.time_pause_net = checkint(qf.time.getTime()) - self.time_pause_net
    ferry.ScriptFerry:getInstance():resumeSchedule()
end

function Net:pause()
    self.time_pause_net = checkint(qf.time.getTime())
    ferry.ScriptFerry:getInstance():pauseSchedule()
end

function Net:isPause( )
    ferry.ScriptFerry:getInstance():isSchedulePaused()
end

function Net:DelAllEvents()
    ferry.ScriptFerry:getInstance():clearEvents()
end

function Net:clean()
    self:delAllRspCbs()
    self:DelAllEvents()
end

function Net:onSendError(paras)
    logd( "Net:onSendError --" , self.TAG)
end

function Net:onConnectError(paras)
    logd( "Net:onConnectError --" , self.TAG)

    self.num_connect_error = self.num_connect_error + 1
    --error错误次数太多则判断重连
    --onConnectError是connect触发的，一定是先触发onDisconnect,进行connnect再触发onConnnectError
    if self.num_connect_error > NUM_ERROR_REQUEST then
        local ret = self:connect()
        if ret == 1 or ret == 2 then
            if not self.is_requesting_address then --正在重新拉取服务器地址列表
                self:onAllAddressFailed()
            end
        end
    end
end

function Net:onUncauthError(paras)
    logd( "Net:onUncauthError --" , self.TAG)
end

function Net:onAllAddressFailed()
    logd( "Net:onAllAddressFailed --" , self.TAG)

    self.is_requesting_address = true

    --@tomas 2017-5-11 18:03
    --既然都失败了就不会再connect了 没必要在disconnect
    -- 先不要重连了
    -- self:disconnect()

    -- TODO 要重新拉取address列表
    self:requeryAddressList()
end

function Net:stopAddressRequest( ... )
    if self.handler_request then
        self.handler_request:abort()
        self.handler_request = nil
    end

    Util:stopRun(self.handler_timer_timeout)
    self.handler_timer_timeout = nil

    Util:stopRun(self.handler_timer_delay)
    self.handler_timer_delay = nil
end
-- 重新拉取address列表
function Net:requeryAddressList( ... )
    local url = Util:getRequestConfigURL()
    local timeout = 5
    local function queryAddress( ... )
        self:stopAddressRequest()

        self.handler_request = cc.XMLHttpRequest:new()

        local function onRequestFailed ()
            self:stopAddressRequest()
            -- 下载失败1后重试
            self.handler_timer_delay = Util:runOnce(1, queryAddress)
        end
        local function onResponse( event )
            if self.handler_request and self.handler_request.status == 200 then
                local response = self.handler_request.response
                TB_SERVER_INFO = json.decode(response)

                self:stopAddressRequest()

                self:start(TB_SERVER_INFO.server_list)
            else
                onRequestFailed()
            end
        end
        -- 超时定时器
        self.handler_timer_timeout = Util:runOnce(timeout, onRequestFailed)

        self.handler_request:registerScriptHandler(function(event)
            onResponse(event)
        end)

        self.handler_request.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
        self.handler_request:open("GET", url)
        self.handler_request:send()
    end
    queryAddress()
end

return Net
