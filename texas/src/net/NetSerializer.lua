--[[

	网络消息序列化与反序列化
	2017/6/1
	raintian
	
]]

local NetSerializer = class("NetSerializer")

local ETAdapter = import(".ETAdapter")
local PBAdapter = import(".PBAdapter")

local OPTIONAL_VAL = 1    --数值(optional int32,string...)
local OPTIONAL_MSG = 2    --结构(optional message)
local REPEATED_VAL = 3    --数值数组(repeated int32,string...)
local REPEATED_MSG = 4    --结构数组(repeated message)

function NetSerializer:ctor()
	
	self.md5Secret = QNative:shareInstance():getSignKey()
	
    self.etAdapter = ETAdapter.new()
    self.pbAdapter = PBAdapter.new()
	
end

--封装box
function NetSerializer:packBox(msg)

    local box = ferry.ScriptFerry:getInstance():createBox()
    box:setCmd(msg.cmd)
	
	--先序列化业务逻辑的body
	local serializedBody = ""
    local pname = self.pbAdapter:findPBNameByCmd({method=msg.method,cmd=msg.cmd})
	--加判断兼容空包
	if pname then
		logd(" use ".. pname .. " pack body ~ cmd=" .. msg.cmd)
		local model = pb.new(pname)
		self:packPB(model, msg.body)
		serializedBody = pb.serializeToString(model)
	end
	
	--从550版本开始增加协议签名，flag使用二进制第二位
	box:setBody(self:packSafeShell(serializedBody, msg.cmd))
	box:setFlag(0x02)
	
    return box
end

--PB包装
function NetSerializer:packPB(_m,_t)
	for k, v in pairs(_t) do
		local data_type = self:getDataType(v)
		if data_type == OPTIONAL_MSG then
			self:packPB(_m[k], v)
		elseif data_type == REPEATED_MSG then
			for key, value in pairs(v) do
				self:packPB(_m[k]:add(), value)
			end
		elseif data_type == OPTIONAL_VAL then
			_m[k] = v
		elseif data_type == REPEATED_VAL then
			for key, value in pairs(v) do
				_m[k]:add(value)
			end
		end
	end
end

--签名包装
function NetSerializer:packSafeShell(serializedBody, msgCmd)
	
	--safeShell字段填充
	local safeShell = {}
	safeShell.sign_type = 1;						--目前使用md5签名校验
	safeShell.encrypt_type = 0;						--默认不对body加密
	safeShell.uid = (Cache.user.uin or 0);			--登录填0，其他填uin
	safeShell.random = math.floor(math.random() * 10^8)	--随机数(int32)
	safeShell.time = os.time();						--本地时间
	safeShell.time_zone = Util:getTimezone();		--本地时区
	safeShell.version = GAME_VERSION_CODE;			--版本号
	safeShell.channel = GAME_CHANNEL_NAME;			--渠道号
	
	local extraTable = {cmd = msgCmd}
	safeShell.extra = qf.json.encode(extraTable)	--额外附加信息，json字符串
	safeShell.body = serializedBody;				--序列化body
	
	--构造md5签名
	safeShell.sign = self:createSign(safeShell)
	
	--获取PB结构体名称
	local safeShellPBName = self.pbAdapter:getSafeShellPBName()
	
	--创建pb
	local safeShellModel = pb.new(safeShellPBName)
	self:packPB(safeShellModel, safeShell)
	
	local buffer = pb.serializeToString(safeShellModel)
	return buffer
	
end

--获取数据类型
function NetSerializer:getDataType(m)
    if type(m) == "table" then
        if m[1] ~= nil then
            if type(m[1]) == "table" then
                return REPEATED_MSG
            else
                return REPEATED_VAL
            end
        else
            return OPTIONAL_MSG
        end
    else
        return OPTIONAL_VAL
    end
end

--获取Config的数据，并md5校验
function NetSerializer:getDataBySignedBody(signedbody, cmd)
    local needSign = UNITY_PAY_SECRET .. signedbody.body

    local body = nil
    local sign2 = QNative:shareInstance():md5(needSign)

    if signedbody.sign == sign2 then
        body = signedbody.body
    else
        return nil
    end

    local pname = self.pbAdapter:findPBNameByCmd({method="rsp",cmd=cmd})
    if pname == nil then return nil end
    local model = pb.new(pname)
    pb.parseFromString(model, body)
    return {model=model}
end

--解包
function NetSerializer:unpackBox(box)
    local ret = nil
    if box:getRet() == 0 then
        ret = {}
        ret.cmd = box:getCmd()
        ret.ret = box:getRet()
        
		--获取SafeShellBody
        local safeShellBody = box:getBody()
		if (not safeShellBody) or (#safeShellBody == 0) then return nil end
        
		--解包SafeShell并做签名校验
		local body = self:unpackSafeShell(safeShellBody, ret.cmd)
		
		--业务body为nil，说明签名校验失败或者其他错误
		if body == nil then return nil end
		
		--加判断兼容空包
		if #body > 0 then 
			--解包业务逻辑body
			local pname = self.pbAdapter:findPBNameByCmd({method="rsp",cmd=box:getCmd()})
			if pname == nil then return nil end
			local model = pb.new(pname)
			pb.parseFromString(model, body)
			
			ret.model = model
		end
		
        return ret
    else
        ret = {}
        ret.cmd = box:getCmd()
        ret.ret = box:getRet()
        return ret
    end
end

--解包safeShell, 并做签名校验
function NetSerializer:unpackSafeShell(safeShellBody, cmd)
	local safeShellPBName = self.pbAdapter:getSafeShellPBName()
	
	local safeShellModel = pb.new(safeShellPBName)
	pb.parseFromString(safeShellModel, safeShellBody)
	
	--生成客户端签名
	local clientSign = self:createSign(safeShellModel)
	
	--签名校验
	local ret = nil
	if clientSign == safeShellModel.sign then
		ret = safeShellModel.body
	else
		loge("sign check fail!!! cmd="..cmd.." clientSign:"..clientSign.." serverSign:"..safeShellModel.sign)
		
		--签名校验失败会弹出提示，先保留这个提示
		qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=GameTxt.net_serializer_sign_error..cmd})
	end
	
	return ret
end

--解包服务端推送消息
function NetSerializer:onMessage(paras)
	
	local unpackParas = self:unpackBox(paras)
    if unpackParas == nil then
		loge("error 服务器主动下发消息接收错误 .... ")
		return 
	end
    
	local event = self.etAdapter:findEventByCmd(unpackParas.cmd)
    if event == nil then 
        loge("error , 未定义的cmd与事件.."..unpackParas.cmd)
        return 
    end

    qf.event:dispatchEvent(event, unpackParas)
end

--转换为十六进制字符串
function NetSerializer:getHex(var)
	local ret = string.format("%X", var)
	if #ret == 1 then return "0"..ret
	else return ret end
end

--构造签名
function NetSerializer:createSign(safeShell)
	
	--构造签名原始字符串
	local signOrigin = self.md5Secret.."|"..safeShell.sign_type.."|"..safeShell.encrypt_type.."|"..
			safeShell.uid.."|"..safeShell.random.."|"..safeShell.time.."|"..safeShell.time_zone.."|"..
			safeShell.version.."|"..safeShell.channel.."|"..safeShell.extra.."|"..safeShell.body
			
	--生成签名
	local sign = QNative:shareInstance():md5(signOrigin)
	
	--logd("createSign signOrigin="..signOrigin)
	--logd("createSign signHex="..signHex)
	--logd("createSign sign="..sign)
	
	return sign
end

return NetSerializer