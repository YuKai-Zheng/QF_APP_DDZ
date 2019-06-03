


local M = class("M")

M.TAG = "Util"
M.UNIT_TYPE_NONE = 0
M.UNIT_TYPE_K = 1
M.UNIT_TYPE_M = 2
M.TIMERBOX_TIME = 0

function M:ctor()
	-- logd( " --- Util ctor ---" , self.TAG)
    self.data32 = {}
    for i=1,32 do
        self.data32[i]=2^(32-i)
    end
end


function M:getReivewFolder()
    local review_folder= "res/review/"
    return review_folder
end

function M:getHURLByUin( uin )
    if uin == nil then return "" end
    return  HOST_PREFIX..RESOURCE_HOST_NAME .."/cdn/portrait/"..uin;
end

function M:getHURLByUrl(url)
    if url == nil then return "" end
    return HOST_PREFIX ..HOST_NAME .."/media/"..url;
end

--判断请求地址包含http
function M:judgeHasHttpSuffex(str, key)
    if string.find(str, key) then
        return true
    else
        return false
    end
end

--四舍五入. num, 整数; n, 向第n位取整。 例如输入125，要输出130， 则n要传入2
function M:roundOff(num, n)
    if n > 0 then
        local scale = math.pow(10, n-1)
        return math.floor(num / scale + 0.5) * scale
    elseif n < 0 then
        local scale = math.pow(10, n)
        return math.floor(num / scale + 0.5) * scale
    elseif n == 0 then
        return num
    end
end

--由于数据的即时改变，没有富文本只能根据模板设置改变数据后的文本位置
--根据模板文本设置文本位置(模板文本(锚点需为0,0)，需要调整位置的文本列表(锚点虚为0,0.5))
function M:setTxtPositionByItem(itemP,txtList)
    local posX = itemP:getPositionX()-itemP:getContentSize().width/2
    for k,v in pairs(txtList)do
        v:setPositionX(posX)
        posX = posX + v:getContentSize().width
    end

end

function M:getByteCount( byte )
    local ret = 0
    if byte > 0 and byte <= 127 then
        ret = 1
    elseif byte >= 192 and byte < 223 then
        ret = 2
    elseif byte >= 224 and byte < 239 then
        ret = 3
    elseif byte >= 240 and byte <= 247 then
        ret = 4
    end
    return ret
end
function M:filterEmoji( source )--特殊表情奔溃问题解决方案
    local len = string.len(source)
    if len < 2 then return source end

    local ret_str = ""
    local i = 1
    while i <= len do
        local is_emoji = false
        local byte_1 = string.byte(source, i)
        if byte_1 == 240 then
            local byte_2 = string.byte(source, i + 1)
            if byte_2 == 159 then
                is_emoji = true
            end
        end
        local byte_count = self:getByteCount(byte_1)
        byte_count = byte_count < 1 and 1 or byte_count
        if not is_emoji then
            ret_str = ret_str..string.sub(source, i, i + byte_count - 1)
        else
            ret_str = ret_str .. "口"
        end
        i = i + byte_count
    end
    return ret_str
end


--判断是否是中文
function M:isLanguageChinese()
    if GAME_LANG == "cn" or GAME_LANG == "zh_tr" then
        return true
    else
        return false
    end
end
--设置时间宝箱时间
function M:setTimerBoxTime()
    -- body
    self.TIMERBOX_TIME = os.date("%H")*3600+os.date("%M")*60+os.date("%S")
end
--获得时间宝箱时间
function M:getTimerBoxTime( ... )
    -- body
    local nowtime = os.date("%H")*3600+os.date("%M")*60+os.date("%S")
    if nowtime<self.TIMERBOX_TIME then 
        nowtime = nowtime + 24*3600
    end
    return nowtime - self.TIMERBOX_TIME
end

--v, 数值; model, 保留小数点后..位
function M:getFormatUnit(v, model)
    local n = model or 2
    if type(v) ~= "number" then return v end
    local k = self:isLanguageChinese() and 10000 or 1000
    local m = self:isLanguageChinese() and 100000000 or 1000000
    local f = v
    local u = self.UNIT_TYPE_NONE
    if v >= m then
        f = v / m
        u = self.UNIT_TYPE_M
    elseif v >= k then
        f = v / k
        u = self.UNIT_TYPE_K
    end

    if u > self.UNIT_TYPE_NONE then
        local num = f * math.pow(10, n + 1)
        num = self:roundOff(num, 2) --四舍五入
        f = num / math.pow(10, n + 1)
    end
    return f, u
end

function M:getFormat(v,model)
    local n = model or 2
    local num, unit = self:getFormatUnit(v, model)
    local str = ""
    if unit == self.UNIT_TYPE_M then
        str = GameTxt.string012
    elseif unit == self.UNIT_TYPE_K then
        str = GameTxt.string011
    end


    return num, str
end



function M:getFormatK(v,model)
    local n = model or 2
    local num, unit = self:getFormatUnit(v, model)
    local str = ""
    if unit == self.UNIT_TYPE_M then
        str = GameTxt.string012
    elseif unit == self.UNIT_TYPE_K then
        str = GameTxt.string011

        if num >=1000 then
            local f   = num/1000 
            local num1 = f * math.pow(10, n + 1)
            num1 = self:roundOff(num1, 2) --四舍五入
            f = num1 / math.pow(10, n + 1) 

            num = f
            str = GameTxt.string013
        end
    end


    return num, str
end

function M:getFormatString(v,model)
    if v == nil then return "" end

    local absV = math.abs(v)
    local s,u = self:getFormat(absV,model)
    if s == nil then return "" end
    if u == nil then return s..""
    else
        if v<0 then
            return "-"..s..u
        else
            return s..u
        end
    end
end


function M:getFormatStringK(v,model)
   if v<100000 then
      model = model
    else
        model = 0
   end

   return self:getFormatStringKW(v,model)
end

function M:getFormatStringKW(v,model)
    if v == nil then return "" end
    local s,u = self:getFormatK(v,model)
    if s == nil then return "" end
    if u == nil then return s..""
    else return s..u end
end



--[[--返回插入特殊字符后的人民币 数字，88,888,888]]
function M:matchStr(num,letter)
	local appendStr = ""
    local  tempNum = num
    local tempstr = ""
    while tempNum>0 do
        if tempNum<1000 then
            tempstr = (tempNum%1000)..""
            if #appendStr>0 then
                appendStr = tempstr..letter..appendStr
                tempNum = math.floor(tempNum/1000)
            else
                appendStr = tempstr..""..appendStr
                tempNum = math.floor(tempNum/1000)
            end
        else
            if #appendStr == 0 then
                tempstr = (1000+tempNum%1000)..""
                appendStr = appendStr..""..string.sub(tempstr,2,4)
                tempNum = math.floor(tempNum/1000)
            else
                tempstr = (1000+tempNum%1000)..""
                appendStr = string.sub(tempstr,2,4)..letter..appendStr
                tempNum = math.floor(tempNum/1000)
            end
        end
	end
	if #appendStr==0 then
        appendStr = tempNum..""
	end
    return appendStr
end
-- 获取上次 在线的时间（如 几个小时前 几天前 几周前）
function M:formatTimer(lastTimer)
    local curTimerStr=""
    local curTimer = os.time()--秒
    local yearTimer = 12*30*24*3600
    local mothTimer = 30*24*3600--一个月有多少秒
    local weekTimer = 7*24*3600
    local dayTimer = 24*3600--一天多少秒
    local hourTimer = 3600--一小时是多少秒
    local minuteTmier = 60
    local DTimer = curTimer-lastTimer;
    if (math.floor(DTimer/yearTimer))>0 then
         curTimerStr = math.floor(DTimer/yearTimer)..GameTxt.TimerUnitStr[1]
    elseif (math.floor(DTimer/mothTimer))>0 then
        curTimerStr = math.floor(DTimer/mothTimer)..GameTxt.TimerUnitStr[2]
    elseif math.floor(DTimer/weekTimer)>0 then
        curTimerStr = math.floor(DTimer/weekTimer)..GameTxt.TimerUnitStr[3]
    elseif math.floor(DTimer/dayTimer)>0 then
        curTimerStr = math.floor(DTimer/dayTimer)..GameTxt.TimerUnitStr[4]
    elseif math.floor(DTimer/hourTimer)>0 then --小时
        curTimerStr = math.floor(DTimer/hourTimer)..GameTxt.TimerUnitStr[5]
    elseif math.floor(DTimer/minuteTmier)>0 then
        curTimerStr = math.floor(DTimer/minuteTmier)..GameTxt.TimerUnitStr[6]
    else
        curTimerStr = "1"..GameTxt.TimerUnitStr[6]
    end    
    return curTimerStr
end


function M:addNormalTouchEvent(node,func)
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(function (touch,event)
        local p = node:getParent()
        while p ~= nil do 
            if p:isVisible() == false then return false end
            p = p:getParent()
        end
        
        if func ~= nil then return func("began",touch,event) end
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    
    listener1:registerScriptHandler(function (touch ,event) 
        if func ~= nil then  func("move",touch,event) end
    end,cc.Handler.EVENT_TOUCH_MOVED)
    
    listener1:registerScriptHandler(function (touch ,event) 
        if func ~= nil then  func("end",touch,event) end
    end,cc.Handler.EVENT_TOUCH_ENDED)
    
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1,node)
end

--[[]]
function M:delayRun(time,cb,tag)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function () if cb then cb() end end))
    if tag then action:setTag(tag) end
    LayerManager.Global:runAction(action)
end

function M:delayRunForever(time, cb, tag)
    local once = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function () if cb then cb() end end))
    local action = cc.RepeatForever:create(once)
    if tag then action:setTag(tag) end
    LayerManager.Global:runAction(action)
end

function M:stopDelayRun(tag)
    if LayerManager.Global:getActionByTag(tag) then LayerManager.Global:stopActionByTag(tag) end
end
function M:runOnce( time, listener )
    local handle
    handle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        self:stopRun(handle)
        listener()
    end, time, false)
    return handle
end
function M:stopRun( handle )
    if handle then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handle)
        handle = nil
    end
end

function M:registerKeyReleased(paras)
    Cache.clickNum = 0
    local function onKeyReleased(keyCode, event)
        if keyCode == cc.KeyCode.KEY_BACK and Cache.clickNum == 0 then
            paras.cb()
            Cache.clickNum = 1
            Util:delayRun(0.2,function ()
                Cache.clickNum = 0
            end)
        end
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
    local eventDispatcher = paras.self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, paras.self)
    return listener
end

--处理字符串，只保留中文、英文、数字
function M:filter_spec_chars(s)
    local ss = {}
    local k = 1
    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
        if c<192 then
            if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then
                table.insert(ss, string.char(c))
            end
            k = k + 1
        elseif c<224 then
            k = k + 2
        elseif c<240 then
            if c>=228 and c<=233 then
                local c1 = string.byte(s,k+1)
                local c2 = string.byte(s,k+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
                    if c == 228 then a1 = 184
                    elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                        table.insert(ss, string.char(c,c1,c2))
                    end
                end
            end
            k = k + 3
        elseif c<248 then
            k = k + 4
        elseif c<252 then
            k = k + 5
        elseif c<254 then
            k = k + 6
        end
    end
    return table.concat(ss)
end

--截取指定长度的字符串
function M:getCharsByNum(s,num)
    local ss = {}
    local k = 1
    local numCount = 1
    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
        if c<192 then
            if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then
                table.insert(ss, string.char(c))
            end
            k = k + 1
            numCount = numCount + 1
        elseif c<240 then
            if c>=228 and c<=233 then
                local c1 = string.byte(s,k+1)
                local c2 = string.byte(s,k+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
                    if c == 228 then a1 = 184
                    elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                        table.insert(ss, string.char(c,c1,c2))
                    end
                end
            end
            k = k + 3
            numCount = numCount + 2
        end
        if numCount > num then
            return table.concat(ss)
        end
    end
    return table.concat(ss)
end

function M:UTF8length(str)
  return #(str:gsub('[\128-\255][\128-\255]',' '))
end

function M:subStringUTF8(s,n) 
    local ret = self:_subStringUTF8(s,n)
    if #ret == self:UTF8length(ret) then  --纯英文
        if #ret > n/2 then return string.sub(ret,1,n/2) end
    end
    return ret
end
function M:getFixName(s,byte)
    if s == nil then return 0 end
    local ret = self:subStringUTF8(s,(byte or 12))
    return ret
    --if ret ~= s then return ret.."..." else return ret end
end

function M:_subStringUTF8(s, n)
  local dropping = string.byte(s, n+1)
  if not dropping then return s end
  if dropping >= 128 and dropping < 192 then
    return self:_subStringUTF8(s, n-1)
  end
  return string.sub(s, 1, n)
end

--获取一个字符串的子字符串
function M:getSubString(str, start_index, end_index)
	end_index = end_index or self:UTF8length(str)
	--将utf8字符映射到表
	local tab = {}
	for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do 
		tab[#tab+1] = uchar
	end
	--获取子串
	local sub = ""
	for i = 1, #tab do
		if i >= start_index and i <= end_index then
			sub = sub .. tab[i]
		end
	end
	
	return sub
end

--去掉前后空格
function M:stringTrim(str)
	if str == nil then return nil end
	return string.match(str, "%s*(.-)%s*$")
end
function M:getTextureByPath(path)
    return cc.Sprite:create(path):getTexture()
end

--图片转存为jpg格式
function M:convertToJpg(path)
    local image = cc.Image:new()
    image:initWithImageFile(path)
    local format = image:getFileType()
    if format == cc.IMAGE_FORMAT_PNG then   --如果是png格式则转存为jpg
        logd("convert file path="..path, self.TAG)
        --[[
            cocos2d::Image类没有暴露saveImageToJPG方法, 而saveToFile是根据文件后缀名判断存储格式的
            因此先暂时命名为xx.jpg, 处理后再改回来
        ]]
        local temp_name = path..".jpg"
        image:saveToFile(temp_name)
        os.remove(path)
        os.rename(temp_name, path)
    end
end

-- key: 当是url时，extparas中url必须=true(90版本后,key必须为url,一律禁止通过传入uin来获取头像)
-- extparas.add 添加到node上
-- extparas.circle 是圆形图像
-- extparas.default 是指定默认头像
-- 一班的：如果extparas.add存在，可以不要extparas.scale参数
function M:updateUserHead(node, key, sex, extparas)
    -- 默认sex为0
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW and key and string.len(key)>3 and "IMG"==string.sub(key,1,3) then
        key=""
    end
    local head_image=node
    sex = sex or 0
    -- 获取下载地址
    if extparas and extparas.url then
        url = key
    else
        url = Util:getHURLByUin(key)
    end
    local function addChildToParent(parent, child)
        local head_url = parent:getChildByName("__head_url")
        if isValid(head_url) then
            head_url:removeFromParent()
        end
        parent:addChild(child)
        child:setName("__head_url")
        local _sz1 = parent:getContentSize()
        local _sz2 = child:getContentSize()
        child:setPosition(cc.p(_sz1.width/2, _sz1.height/2))
        local _sca = _sz1.width
        if extparas.scale then
            _sca = extparas.scale
        end
        child:setScale(_sca/_sz2.width)
    end
    -- 获取默认头像
    local _default = nil
    if extparas.default ~= nil then
    	_default = extparas.default	--使用指定的默认头像
        head_image.photo_path=_default
    else
		if extparas and extparas.circle then
			_default = GameRes.default_man_icon
			if 1 == sex then
				_default = GameRes.default_girl_icon
			end
        elseif extparas and extparas.sq then
            _default = GameRes.default_sq_man_icon
            if 1 == sex then
                _default = GameRes.default_sq_girl_icon
            end
		else
			_default = GameRes["user_default" .. sex]
		end
        head_image.photo_path=GameRes["user_default" .. sex]
    end
    if extparas.default then
        _default = extparas.default
        head_image.photo_path=_default
    end
    -- 以子节点的方式把下载的头像加载到node上
    if extparas and extparas.add then
        local _sprite = cc.Sprite:create(_default)
        addChildToParent(node, _sprite)
        node = _sprite
    elseif "cc.Sprite" == tolua.type(node) then -- sprite类型
        node:setTexture(_default)
        if extparas and extparas.scale then
            node:setScale(extparas.scale/node:getContentSize().width)
        end
    elseif "ccui.Button" == tolua.type(node) then -- sprite类型
        node:loadTextureNormal(_default)
        if extparas and extparas.scale then
            node:setScale(extparas.scale/node:getContentSize().width)
        end
        
    else -- ImageView类型
        if not extparas.nodefault then 
            node:loadTexture(_default)
        end
        if extparas and extparas.scale then
            node:setScale(extparas.scale/node:getContentSize().width)
        end
    end
    if key and string.len(key)>3 and "IMG"==string.sub(key,1,3) then
        local img =tonumber(string.sub(key,4,#key))
        if sex==0 then
            img = img <8 and img>0 and img or 1
        else
            img = img <7 and img>0 and img or 1
        end
        path=string.format(GameRes.DefaultHead,sex,img)

        local _sp= cc.Sprite:create(path)
        if not _sp then
             logd("Sprite:create fail. path: " .. path)
            return
         end
        local fileTexture = _sp:getTexture()
        -- cocos底层不够健壮，如果texture为null导致崩溃
        if not fileTexture then
            loge("getTexture fail. path: " .. path)
            return
        end 
        if extparas then
            if "cc.Sprite" == tolua.type(node) then -- sprite类型
                if extparas.circle then -- 是圆形则node必须是sprite类型
                    node:setTexture(Display:getCircleHead({file=path}):getTexture())
                elseif extparas.sq then -- add方式：则node已经是sprite类型(node = _sprite)
                    node:setTexture(Display:getSqHead({file=path}):getTexture())
                elseif extparas.add then -- add方式：则node已经是sprite类型(node = _sprite)
                    node:setTexture(fileTexture)
                else
                    node:setTexture(fileTexture)
                end
            elseif "ccui.Button" == tolua.type(node) then -- sprite类型
                node:loadTextureNormal(path)
            else -- ImageView类型
                node:loadTexture(path)
            end
            local scale = extparas.scale
            if scale then -- 如果需要进行缩放
                local sz = node:getContentSize()
                node:setScale(scale/sz.width)
            end
            if extparas.scb then -- 成功回调
                extparas.scb("success")
            end
        elseif "cc.Sprite" == tolua.type(node) then -- sprite类型
            node:setTexture(fileTexture)
        else -- ImageView类型
            node:loadTexture(path)
        end
        if head_image.updatePhoto then head_image:updatePhoto(path) end
        return
    end


    if url ==nil or string.len(url) == 0 then return end
    local downloadTaskID = qf.downloader:execute(url, 30,
        function (path)
			if not io.exists(path) then return end	--头像图片不存在则不加载. fix_bug_79
            if not extparas.nojpg then
                self:convertToJpg(path) --将头像转存为jpg格式(为解决用户上传png头像, 透明露出默认头像问题)
            end
            local _sp= cc.Sprite:create(path)
            if not _sp then
                 logd("Sprite:create fail. path: " .. path)
                return
             end
            local fileTexture = _sp:getTexture()

            -- cocos底层不够健壮，如果texture为null导致崩溃
            if not fileTexture then
                loge("getTexture fail. path: " .. path)
                return
            end 

            -- cc.Director:getInstance():getTextureCache():reloadTexture(path)
            if not node or tolua.isnull(node) then -- 如果在拉取头像的时候此node被移除
                return 
            end
            if extparas then
               
                if "cc.Sprite" == tolua.type(node) then -- sprite类型
                    if extparas.circle then -- 是圆形则node必须是sprite类型
                        node:setTexture(Display:getCircleHead({file=path}):getTexture())
                    elseif extparas.sq then -- add方式：则node已经是sprite类型(node = _sprite)
                        node:setTexture(Display:getSqHead({file=path}):getTexture())
                    elseif extparas.add then -- add方式：则node已经是sprite类型(node = _sprite)
                        node:setTexture(fileTexture)
                    else
                        node:setTexture(fileTexture)
                    end
                elseif "ccui.Button" == tolua.type(node) then -- sprite类型
                    node:loadTextureNormal(path)
                else -- ImageView类型
                    node:loadTexture(path)
                end
                local scale = extparas.scale
                if scale then -- 如果需要进行缩放
                    local sz = node:getContentSize()
                    node:setScale(scale/sz.width)
                end
                if extparas.scb then -- 成功回调
                    extparas.scb("success")
                end
            elseif "cc.Sprite" == tolua.type(node) then -- sprite类型
                node:setTexture(fileTexture)
            else -- ImageView类型
                node:loadTexture(path)
            end
            if head_image.updatePhoto then head_image:updatePhoto(path) end
            downloadTaskID = nil
        end
        , function ()
            if not node or tolua.isnull(node) then -- 如果在拉取头像的时候此node被移除
                return 
            end
            if extparas and extparas.fcb then -- 失败回调
                extparas.fcb("failed")
            end
        end
        , function ()
            if not node or tolua.isnull(node) then -- 如果在拉取头像的时候此node被移除
                return 
            end
            if extparas and extparas.tcb then -- 超时回调
                extparas.tcb("timeout")
            end
        end
    )
    node:registerScriptHandler(function(eventname)
        if eventname == "exit" then -- 还没有执行此任务的时候，node被移除
            qf.downloader:removeTask(downloadTaskID)
            downloadTaskID = nil
        end
    end)
    return downloadTaskID
end
-- 上传头像回调
function M:uploadUserIconCallback(status)
    if "-1" == status then
        Util:runOnce(0.1, function ( ... )
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.upload_user_icon_status_f1})
        end)
    elseif "0" == status then
        Util:runOnce(0.1, function ( ... )
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.upload_user_icon_status_0})
        end)
    elseif "1" == status then
		--头像更新处理要等待服务器广播,用服务器返回的头像url更新相关界面
        Util:runOnce(0.1, function ( ... )
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.head_tip3})
        end)
    end
end

function M:galleryUploadCallBack(status)
    if "-1" == status then
        logd("galleryUploadCallBack -1")
         Util:runOnce(0.1, function ( ... )
              logd("galleryUploadCallBack -1")
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.galleryUploadFail})
        end)
       
    elseif "0" == status then
          Util:runOnce(0.1, function ( ... )
             qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.galleryUploading})
         end)
        Util:runOnce(0.2, function ( ... )

              logd("galleryUploadCallBack 0")
            qf.event:dispatchEvent(ET.GALLERY_UPLOAD,status) -- 上传中
        end)
    elseif "1" == status then
        Util:runOnce(0.1, function ( ... )
          qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.galleryUploadSuc})
        end)
          logd("galleryUploadCallBack 1")

        Util:runOnce(0.2, function ( ... )
            qf.event:dispatchEvent(ET.GALLERY_UPLOAD,status) -- 上传成功
        end)
    end
end

function M:chipsAnimation(paras)
    
    local parent,x,y = cc.Node:create(),paras.x,paras.y
    if paras.scale then
        parent:setScale(paras.scale)
    end
    paras.parent:addChild(parent,10,10)
    local delay = paras.delay or 0
    local tempDelay = delay
    local shadow = cc.Sprite:create(GameRes.login_chip_shadow)
    local node = cc.Node:create()
    local time = 0.07
    local count = 5
    parent:addChild(node)
    shadow:setAnchorPoint(0.5,0)
    shadow:setPosition(x,y)
    parent:addChild(shadow,10)
    
    local img_1
    local img_2
    if paras.type == 1 then --跳动筹码
        img_1 = GameRes.login_chips_1
        img_2 = GameRes.login_chips_2
    elseif paras.type == 2 then --跳动金币
        img_1 = GameRes.login_golds_1
        img_2 = GameRes.login_golds_2
    elseif paras.type == 3 then --跳动金币
        img_1 = GameRes.login_golds_3
        img_2 = GameRes.login_golds_4

    end

    local first = self:_ChipsAnimation(0,parent,img_2,count,time,x-39,y+11)
    local third= self:_ChipsAnimation(0.8,parent,img_2,count,time,x+38,y+13)
    local second = self:_ChipsAnimation(0.4,parent,img_1,count,time,x-3.2,y-4)
    
    local function _chipsAction(chips)
        for k,v in pairs(chips) do
            v:runAction(cc.Sequence:create(
                cc.MoveBy:create(time*k,cc.p(0,k*20)),
                cc.MoveBy:create(time*k,cc.p(0,-k*20)),
                --            cc.CallFunc:create(function() 
                --                MusicPlayer:playMyEffect("CHIP")
                --            end),
                cc.DelayTime:create(((time)*2)*(count-k)+1)
            ))
        end
    end
    
    local countTime = 0.0
    local delayCount = 20.0
    local function updateAction()
        local dev = countTime/delayCount
        if countTime >  delayCount*7 then
        elseif dev == 1 or dev == 5 then
            _chipsAction(first)
        elseif dev == 2 or dev == 6 then
            _chipsAction(second)
        elseif dev == 3 or dev == 7 then
            _chipsAction(third)
        end
        if countTime >= delayCount*5 + tempDelay then
            countTime = countTime >= delayCount*9+tempDelay and 0 or countTime+1 
            tempDelay = tempDelay == 0 and 0 or delay + math.random(-0.5,0.5)*delay
        else
            countTime = countTime + 1
        end 
    end
    
    node:scheduleUpdateWithPriorityLua(updateAction,0)
end

function M:_ChipsAnimation(delaytime,parent,sprite,count,time,x,y)
    local chips = {}
    for i=1,count do
        local _chips = cc.Sprite:create(sprite)
        _chips:setAnchorPoint(0.5,0)
        _chips:setPosition(x,y+i*_chips:getContentSize().height*0.2)
        parent:addChild(_chips,10)
        chips[i] = _chips
    end
    
    return chips
    
end

---发牌通用动画
--@param c1 真正的牌
--@param c2 发的牌
--@param value 发的牌的值,如果不传就没有翻牌动画，有的话就有翻牌动画
--@param parent 牌的父节点
--@param dpoint 牌出来的位置
--@param delay 延时
--
function M:giveCardsAnimation(paras)
    if paras == nil then return end
    local c1,c2,parent,dpoint,value = paras.c1,paras.c2,paras.parent,paras.dpoint,paras.value
    local first = paras.first
    local action,z,delay,atime = paras.action,paras.z,paras.delay,paras.atime
    local scale,position,anchor = c1:getScale(),c1:getPosition(),c1:getAnchorPoint()
    -- logd("发牌--->scale"..scale.."  positionX-->"..c1:getPositionX())
    if c1 == nil or parent == nil or c2 == nil or dpoint == nil then return end
    dpoint = parent:convertToNodeSpace(dpoint)
    
    c2:setPosition(dpoint)
    c2:setScale(scale)
    c2:setLocalZOrder(10)
    c2:setVisible(false)
    atime = atime or 0.5
    action = action or cc.Sequence:create(
        cc.DelayTime:create(delay or 0),
        cc.CallFunc:create(function() 
            MusicPlayer:playMyEffect("FAPAI")
            c2:setVisible(true)
        end),
        cc.EaseOut:create(
            cc.MoveTo:create(atime,cc.p(first:getPositionX(),first:getPositionY())),2
            ),
        cc.DelayTime:create(0.3),
        cc.MoveTo:create(atime,cc.p(c1:getPositionX(),c1:getPositionY())),
        cc.CallFunc:create(function ( sender )
            c2:setLocalZOrder(z or 0)
            c2.value = value
            if value then sender:reverseSelf(nil,value)  end
        end)
    )
    
    c2:runAction(action)
end



--[[
分享图片 , 分享成功后 ， 看需要发送cmd是63给服务器，作为分享奖励
Util:sharePic(function ( ret )
    if ret == 0 then --成功
    elseif ret == 1 then 出错
    elseif ret == 2 then 用户取消
    end
    print(" --- share pic ret ---- "..ret)
end)
]]
function M:sharePic(cb)
    local filename = "textas_snap_"..os.time()..".jpg"
    --local title = 
    local function afterCaptured(succeed, outputFile)  -- outputFile 完整路径
        if succeed then
            qf.platform:sharePic({file=outputFile,cb=cb})
        else
            cclog("Capture screen failed.")
        end
    end
    cc.utils:captureScreen(afterCaptured, filename)
    

end


---[[
--通过输入两个点求两点组成的直线与X轴正半轴之间的角度
--@p1 为原点
--@p2 为处于的点
--]]
function M:getAngle(p1,p2)
    -- logd("两点坐标x1-->"..p1.x.."y1-->"..p1.y.."x2-->"..p2.x.."y2-->"..p2.y)
    if p1.y == p2.y then
        if p1.x <= p2.x then
            return 0
        else
            return 180
        end
    end
    if p1.x == p2.x then
        if p1.y > p2.y then
            return 90
        else
            return 270
        end
    end
    local dis = math.ceil(self:getLong(p1,p2))
    local dy = p1.y - p2.y
    local dx = p2.x - p1.x
    
    local angle = math.atan2(dy,dx)*180/math.pi
    
    return angle
end 
---[[
--通过输入两个点求两点之间的距离
--@p1 为中心点
--@p2 为处于的点
--]]
function M:getLong(p1,p2)
    local dx,dy = p1.x - p2.x,p1.y - p2.y
    local long = math.sqrt(dx*dx+dy*dy) 
    return long
end

function M:showBeautyAction(node,eyeTime)
    if node == nil then return end
    local beauty = node
    local mouse = beauty:getChildByName("mouse")
    local eye = beauty:getChildByName("eye")
    local mouse_animation = beauty:getChildByName("mouse_animation")
    local function _beautyAction(node,time,visibleTime,once,cb)
        if node == nil then return end
        node:setVisible(false)
        local temp = time
        node:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
                cc.CallFunc:create(function() 
                    temp = time + math.random(1,3)
                end),
                cc.DelayTime:create(temp),
                cc.CallFunc:create(function() 
                    node:setVisible(true)
                    if cb then cb() end
                end),
                cc.DelayTime:create(visibleTime),
                cc.CallFunc:create(function() 
                    node:setVisible(false)
                end),
                cc.DelayTime:create(visibleTime),
                cc.CallFunc:create(function() 
                    if once ~= true and temp%2 ~= 1 then
                        node:setVisible(true)
                    end
                end),
                cc.DelayTime:create(visibleTime*0.5),
                cc.CallFunc:create(function() 
                    node:setVisible(false)
                end)
        )))
    end
    _beautyAction(mouse,60,0.4,true,function()
        if mouse_animation == nil then return end 
        mouse_animation:setScale(0)
        mouse_animation:setOpacity(255)
        local tempP = cc.p(mouse_animation:getPositionX(),mouse_animation:getPositionY())
        mouse_animation:runAction(
            cc.Sequence:create(
                cc.CallFunc:create(function() 
                    mouse_animation:setVisible(true)
                end),
                cc.Spawn:create(
                    cc.ScaleTo:create(2,1.5),
                    --cc.MoveBy:create(2,cc.p(50,100)),
                     cc.FadeTo:create(2,0)
                ),
                cc.CallFunc:create(function() 
                    mouse_animation:setVisible(false)
                    mouse_animation:setPosition(tempP)
                end)
            )
        )
    end)
    _beautyAction(eye,eyeTime or 6,0.1,false)

end

function M:getOpenIDAndToken() 
    local openid = cc.UserDefault:getInstance():getStringForKey(SKEY.OPEN_ID,"null");
    local token  = cc.UserDefault:getInstance():getStringForKey(SKEY.TOKEN,"null");
    local ttt = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN);

    if(openid == "null") then
        return {openid=nil,token=nil}
    else
        local openid2 = ""
        for i=1,#openid do
            openid2 = openid2 .. string.char(string.byte(openid,i)-(i%2==0 and 5 or - 5))
        end
        return {openid=openid2,token=token,type=ttt}
    end
end

function M:setOpenIDAndToken(openid,token,type) 
    
    local _openid = ""
    for i=1,#openid do
        _openid = _openid .. string.char(string.byte(openid,i)+(i%2==0 and 5 or - 5))
    end
    
    cc.UserDefault:getInstance():setStringForKey(SKEY.OPEN_ID,_openid);
    cc.UserDefault:getInstance():setStringForKey(SKEY.TOKEN,token);
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE,type.."");
    cc.UserDefault:getInstance():flush();
end

function M:getQufanLoginInfo() 
    local openid = cc.UserDefault:getInstance():getStringForKey(SKEY.OPEN_ID,"null");
    local token  = cc.UserDefault:getInstance():getStringForKey(SKEY.TOKEN,"null");
    local ttt = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN);
    local code = cc.UserDefault:getInstance():getStringForKey(SKEY.VERIFY_CODE,"null");

    if(openid == "null") then
        return {openid=nil,token=nil}
    else
        local openid2 = ""
        for i=1,#openid do
            openid2 = openid2 .. string.char(string.byte(openid,i)-(i%2==0 and 5 or - 5))
        end
        return {openid=openid2,token=token,type=ttt,code=code}
    end
end

function M:setQufanLoginInfo(openid,token,type,code) 
    
    local _openid = ""
    for i=1,#openid do
        _openid = _openid .. string.char(string.byte(openid,i)+(i%2==0 and 5 or - 5))
    end
    
    cc.UserDefault:getInstance():setStringForKey(SKEY.OPEN_ID,_openid);
    cc.UserDefault:getInstance():setStringForKey(SKEY.TOKEN,token);
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE,type.."");
    cc.UserDefault:getInstance():setStringForKey(SKEY.VERIFY_CODE,code or "");
    cc.UserDefault:getInstance():flush();
end

function M:getMiGuToken()

    local token  = cc.UserDefault:getInstance():getStringForKey(SKEY.MIGU_TOKEN,"");
    if token == "" then
        token = tostring(math.random(2000000000))
        cc.UserDefault:getInstance():setStringForKey(SKEY.MIGU_TOKEN,token)
        cc.UserDefault:getInstance():flush()
    end
    
    return token
end

function M:fix2point(v)
    local strv = string.format("%.2f", v)
    return tonumber(strv)
end



function M:binary2int(arg)
    local   nr=0
    for i=1,32 do
        if arg[i] ==1 then
        nr=nr+self.data32[i]
        end
    end
    return  nr
end

function M:int2binary(arg)
    arg = arg >= 0 and arg or (0xFFFFFFFF + arg + 1)
    local   tr={}
    for i=1,32 do
        if arg >= self.data32[i] then
            tr[i]=1
            arg=arg-self.data32[i]
        else
            tr[i]=0
        end
    end
    return   tr
end

function M:binaryAnd(a,b)
    local   op1=self:int2binary(a)
    local   op2=self:int2binary(b)
    local   r={}
    
    for i=1,32 do
        if op1[i]==1 and op2[i]==1  then
            r[i]=1
        else
            r[i]=0
        end
    end
    return  self:binary2int(r)
end

function M:getIntPart(x)
	if x <= 0 then
	   return math.ceil(x);
	end

	if math.ceil(x) == x then
	   x = math.ceil(x);
	else
	   x = math.ceil(x) - 1;
	end
	return x;
end

--获取牌文件名
function M:getCardFileName( value )
    if value == nil then return nil end
    local _ctable = {"r","h","m","f"}
    local i,t = math.modf(value/4)

    i = i + 1
    if i == 14 then i = 1 end

    local c = math.fmod(value,4)
    local ret = nil

    if i < 10 then ret = "poker_".._ctable[(c+1)].."0"..i
    else ret= "poker_".._ctable[(c+1)]..i
    end
    return GameRes[ret]
end

--获取牌的描述.
function M:getCardDescription(value)
    if value == nil then return nil end
    local _ctable = {"红桃","黑桃","梅花","方块"}
    local i,t = math.modf(value/4)

    i = i + 1
    if i == 14 then i = 1 end

    local c = math.fmod(value,4)
    local cardtype = _ctable[(c+1)]
    local cardvalue = ""
    if i == 1 then
        cardvalue = "A"
    elseif i <= 10 then
        cardvalue = tostring(i)
    elseif i == 11 then
        cardvalue = "J"
    elseif i == 12 then
        cardvalue = "Q"
    elseif i == 13 then
        cardvalue = "K"
    end
    return cardtype..cardvalue
end

function M:getFriendRemark(uin,nick,hiding)
    if nick then
        if self:getHidingStatusFromNick(nick)==true then
            return nick, false    
        end
    end
    if uin and uin~=Cache.user.uin and Cache.FriendInfo.remarklist then--此判断无用，Cache.FriendInfo.remarklist没有元素
        for k,v in pairs(Cache.FriendInfo.remarklist) do
            if uin==v.uin then
                if string.len(v.nick)>0 then
                    return v.nick, true
                end
            end
        end
    end
    if nick then
        return nick, false
    else
        return "", false
    end
end

function M:isAllSpaceStr(str) -- 是否全是空格的字符串
   local haveNotSpaceChar=false
    for var=1, string.len(str)  do
       
       if 32~=string.byte(str, 1) then
           haveNotSpaceChar=true
           break
       end  
  end
     
    if haveNotSpaceChar==true then
       return false
       else
        return true
    end
end


function M:getHidingStatusFromNick(nick) -- 是否全是空格的字符串
   local isHiding=false
    local i, j = string.find(nick, "神秘人")
    if  i and  j then
        isHiding=true
    end

    return isHiding
end


function M:getMySubStr(str,from,to)--按个数截取中英混合字符
     
    logd("from.."..from)
    logd("to.."..to)
    local lenInByte = #str
    logd(" str..".. str)
     logd(" lenInByte..".. lenInByte)
    
    local cur_index=0
    local f_index=0
    local t_index=0 
      local i = 1
      for j=1,lenInByte+1 do
        if i <= lenInByte then
            logd("i.."..i)
            local curByte = string.byte(str, i)
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<223 then
                byteCount = 2
            elseif curByte>=224 and curByte<239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
            logd("curByte.."..curByte)
            logd("byteCount.."..byteCount)
            local char = string.sub(str, 1, 3)
            logd("char.."..char)
            cur_index=cur_index+1
            logd("cur_index:"..cur_index)
            if cur_index==from then
                f_index=i
                logd("f_index.."..f_index)
            end 
            i = i + byteCount
            if  cur_index==to then
                t_index=i-1
                logd("t_index.."..t_index)
            end
        else
            break
        end
    end
   if  f_index>0 and t_index>0 then
    logd("new_str")
      local new_str= string.sub(str, f_index, t_index)
      logd("new_str.."..new_str)
      if new_str then
        return new_str
      end
   end
  return  str
end 


function M:getMySplitStr(str,num)--按个数分割中英混合字符成若干字符 下标从 1开始
    local str_arr={}
    local from=1
    local to=num
    local lenInByte = #str
    local cur_index=0
    local f_index=0
    local t_index=0 
      local i = 1
      for j=1,lenInByte+1 do
        if i <= lenInByte then
            local curByte = string.byte(str, i)
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<223 then
                byteCount = 2
            elseif curByte>=224 and curByte<239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
            cur_index=cur_index+1
            if cur_index==from then
                f_index=i
            end 
            i = i + byteCount
            if  cur_index==to then
                t_index=i-1
            end
            if  f_index>0 and t_index>0 then
              local new_str= string.sub(str, f_index, t_index)
              if new_str then
                table.insert(str_arr,#str_arr+1,new_str)
                loge("new_str"..new_str)
              end
              f_index=0
              t_index=0
              from=to+1
              to=from+num-1
            end
        else
            break
        end
    end
   if f_index>0 and t_index==0 then
     local new_str= string.sub(str, f_index, lenInByte)
     loge("new_str"..new_str)
     if new_str then
        table.insert(str_arr,#str_arr+1,new_str)
     end
   end
  return  str_arr
end

function M:getMySplitStrWithLength(str,len,fontSize)--按长度分割中英混合字符成若干字符 下标从 1开始
     
      local str_arr={}
      local total_len=0
      local lenInByte = #str
      local f_index=1
      local t_index=1 
      local i = 1
      for j=1,lenInByte+1 do
        if i <= lenInByte then
            local curByte = string.byte(str, i)
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<223 then
                byteCount = 2
            elseif curByte>=224 and curByte<239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
            local char = string.sub(str, i, i+byteCount-1)
            local contentLabel = cc.LabelTTF:create(char, GameRes.font1, fontSize)
            local one_length=contentLabel:getContentSize().width
            total_len=total_len+one_length 
            if total_len>len then
                t_index=i-1 
                if  f_index>0 and t_index>0 and t_index>=f_index then
                  local new_str= string.sub(str, f_index, t_index)
                  if new_str then
                    table.insert(str_arr,#str_arr+1,new_str)
                  end
                  f_index=t_index+1
               end   
               total_len=one_length
            end
            i=i+byteCount

        else
            break
        end
    end
   if f_index>0  then
     local new_str= string.sub(str, f_index, lenInByte)
     if new_str then
        table.insert(str_arr,#str_arr+1,new_str)
     end
   end
  return  str_arr
end

--将时间戳转化为时间描述字符串, 2015-12-20 11:25
function M:getTimeDescription(timestamp)
    local date = os.date("*t", timestamp)
    local month = string.format("%02d", date.month)
    local day = string.format("%02d", date.day)
    local hour = string.format("%02d", date.hour)
    local min = string.format("%02d", date.min)
    local time_str = date.year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" ..min
    return time_str
end

--将时间戳转化为时间描述字符串, 11:25
function M:getDigitalTime(timestamp)
    local date = os.date("*t", timestamp)
    local hour = string.format("%02d", date.hour)
    local min = string.format("%02d", date.min)
    local time_str = hour .. ":" ..min
    return time_str
end

function M:getCanUseRemark() --判断有没有修改备注的权限
   if  Cache.FriendInfo.remark_status and Cache.FriendInfo.remark_status==0 then
        if Cache.user.vip_days>0 then
            return  true
        else
           return  false 
        end
    else
         return  true
    end
end

function M:getRequestConfigURL( ... )
    local info = qf.platform:getRegInfo()
    local MD5_FILE = "md5.txt" --原始md5列表配置文件
    local MD5_FILE_EX = QNative:shareInstance():getUpdatePath().."/md5.txt" --更新md5列表配置文件
    local content
    if not io.exists(MD5_FILE_EX) then
        content = cc.FileUtils:getInstance():getDataFromFile(MD5_FILE)
    else
        content = cc.FileUtils:getInstance():getDataFromFile(MD5_FILE_EX)
    end
    local md5 = QNative:shareInstance():md5(content)
    local version = tonumber(info.version or 0)
    local device_id = info.device_id
    device_id = string.urlencode(device_id)

    local channel = GAME_CHANNEL_NAME or "CN_MAIN"
    local lang = GAME_LANG
    if qf.platform:isDebugEnv() == true or string.find(channel, "CN") then
        HOST_NAME = HOST_CN_NAME 
    elseif string.find(channel, "HW") then
        HOST_NAME = HOST_HW_NAME
        lang = "hw"
    end
    RESOURCE_HOST_NAME = HOST_NAME 
    loga("======RESOURCE_HOST_NAME===111111==="..RESOURCE_HOST_NAME)

    local urlFormat = HOST_PREFIX.."%s/router/server_allocate?uin=%s&os=%s&pkg_name=%s&channel=%s&version=%d&md5=%s&lang=%s" -- 服务器路径
    local url = string.format(urlFormat, HOST_NAME, device_id, string.upper(info.os), GAME_PAKAGENAME, GAME_CHANNEL_NAME, version, md5, lang)
    return url
end

function M:getChatLayout(chatPop,content,fontSize,dis_x,dis_y) 
    dis_x=dis_x or  0  
    dis_y=dis_y or  0  
    local posx=0
    if  dis_x>0 then posx=math.abs(dis_x) end
    local layout = ccui.Layout:create() 
    layout:setAnchorPoint(0.0,0.5)
    layout:setClippingEnabled(true) 
    layout:setSize(CCSizeMake(chatPop:getContentSize().width-math.abs(dis_x) , chatPop:getContentSize().height*0.7))
    layout:setPosition(ccp(posx+5, chatPop:getContentSize().height/2+dis_y)) 
    --local arr_str=Util:getMySplitStr(content,11)
    local arr_str=Util:getMySplitStrWithLength(content,layout:getContentSize().width,fontSize)
    local pre_lb=nil
    local _contentLabels={}
    for k,v in pairs(arr_str) do
        local pos_y  = layout:getContentSize().height/2
        if pre_lb then pos_y=pre_lb:getPositionY()-layout:getContentSize().height end
        local contentLabel = cc.LabelTTF:create(v, GameRes.font1, fontSize)
        contentLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        contentLabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        contentLabel:setAnchorPoint(0.0,0.5)
        contentLabel:setPosition(0,pos_y)
        layout:addChild(contentLabel) 
        table.insert(_contentLabels,#_contentLabels+1,contentLabel)
        pre_lb=contentLabel
    end
    chatPop:addChild(layout)
    local num=#_contentLabels
    for i=1,num-1 do
        for k,v in pairs(_contentLabels) do
          Util:delayRun(1.0*i,function ( )
            if not  tolua.isnull(v) then v:runAction(cc.MoveBy:create(0.2, cc.p(0,layout:getContentSize().height))) end
           end)
         end
     end 
     return layout,num
end

function M:getChatLayoutEx(chatPop,content,fontSize,dis_x,dis_y) 

    local temp = cc.LabelTTF:create(content,GameRes.font1,fontSize)
    --temp:setSystemFontName(GameRes.font1);  
    --temp:setSystemFontSize(fontSize)
    --temp:setString(content)
    local  line_height=temp:getContentSize().height 
    logd("line_height:"..line_height)

    local layout = ccui.Layout:create() 
    layout:setAnchorPoint(0,0.5)
    layout:setClippingEnabled(true) 
    layout:setSize(cc.size(chatPop:getContentSize().width-math.abs(dis_x) , line_height))
    layout:setPosition(ccp(chatPop:getContentSize().width/2+dis_x/2, chatPop:getContentSize().height/2+dis_y)) 

    local  line_width= layout:getContentSize().width-30
    local contentLabel = cc.LabelTTF:create(content,GameRes.font1,fontSize,cc.size(line_width,0))
    --contentLabel:setDimensions(CCSizeMake(0,line_width))
    --contentLabel:setSystemFontName(GameRes.font1);  
    --contentLabel:setSystemFontSize(fontSize)
    --contentLabel:setString(content)
    --contentLabel:setWidth(line_width);  
    --contentLabel:setLineBreakWithoutSpace(true);
    --contentLabel:setMaxLineWidth(line_width);
    contentLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    contentLabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    contentLabel:setAnchorPoint(0.5,1.0)
    contentLabel:setPosition(layout:getContentSize().width/2,layout:getContentSize().height)

    layout:addChild(contentLabel)

    chatPop:addChild(layout)
    
    local  height=contentLabel:getContentSize().height   logd("height:"..height)
    local  line=math.ceil(height/line_height)  logd("line:"..line)
    for i=1,line-1 do
    Util:delayRun(1.0*(i),function( )
    if not tolua.isnull(contentLabel)   then 
       contentLabel:stopAllActions()
       contentLabel:runAction(cc.MoveBy:create(0.2,cc.p(0,line_height)))
    end
    end)
    end
    return layout,line
end

function M:getPayMethodRes( method_temp )
    --支付方式动态加载
    if method_temp == PAYMETHOD_APPSTORE then                                                   
        return GameRes.pay_item_as, GameRes.pay_item_as_0, GameRes.pay_item_img_as, GameTxt.string_pay_method_as
    elseif method_temp == PAYMETHOD_DUANXIN_YD or method_temp == PAYMETHOD_DUANXIN_LT or 
    method_temp == PAYMETHOD_DUANXIN_DX_AIYOUXI or method_temp == PAYMETHOD_DUANXIN_DX_TIANYI  then
        --短信
    elseif method_temp == PAYMETHOD_ZHIFUBAO or method_temp == PAYMETHOD_SOUSUO then
        return GameRes.pay_item_zfb, GameRes.pay_item_zfb_0, GameRes.pay_item_img_zfb, GameTxt.string_pay_method_zfb
    elseif method_temp == PAYMETHOD_WINXIN then
        return GameRes.pay_item_wx, GameRes.pay_item_wx_0, GameRes.pay_item_img_wx, GameTxt.string_pay_method_wx
    elseif method_temp == PAYMETHOD_BANK then
        return GameRes.pay_item_yl, GameRes.pay_item_yl_0, GameRes.pay_item_img_yl, GameTxt.string_pay_method_yl
    elseif method_temp == PAYMETHOD_QQ then
        
    elseif method_temp == PAYMETHOD_HAIMA2 then
        
    elseif method_temp == PAYMETHOD_KUPAI2 then
        
    end
    return GameRes.pay_item_wx, GameRes.pay_item_wx_0, GameRes.pay_item_img_wx, GameTxt.string_pay_method_wx
end

function M:getCarRes( level )
    local car_name
    if level == 1 then
        car_name = GameTxt.string_car_name_1
    elseif level == 2 then
        car_name = GameTxt.string_car_name_2
    elseif level == 3 then
        car_name = GameTxt.string_car_name_3
    elseif level == 4 then
        car_name = GameTxt.string_car_name_4
    elseif level == 5 then
        car_name = GameTxt.string_car_name_5
    elseif level == 6 then
        car_name = GameTxt.string_car_name_6
    end
    local car_path = string.format(GameRes.shop_car, level)
    return car_name, car_path
end

-- 根据金币获取跳转后游戏内商城标签
function M:getGameShopBookmarkByGold( gold )
    local enough, bookmark = Cache.QuickPay:isMoneyEnough(gold)

    if enough == Cache.QuickPay.JUDGE_ENOUGH.BOTH_NOT_ENOUGH then -- 金币和钻石都不足
        bookmark = PAY_CONST.BOOKMARK_ROOM.DIAMOND
    elseif enough == Cache.QuickPay.JUDGE_ENOUGH.DIAMOND_ENOUGH then -- 金币不足
        bookmark = PAY_CONST.BOOKMARK_ROOM.GOLD 
    else
        bookmark = PAY_CONST.BOOKMARK_ROOM.GOLD
    end



    return bookmark
end
-- 根据金币获取跳转后商城标签
function M:getShopBookmarkByGold( gold )
    local enough, bookmark = Cache.QuickPay:isMoneyEnough(gold)

    if enough == Cache.QuickPay.JUDGE_ENOUGH.BOTH_NOT_ENOUGH then -- 金币和钻石都不足
        bookmark = PAY_CONST.BOOKMARK.DIAMOND
    elseif enough == Cache.QuickPay.JUDGE_ENOUGH.DIAMOND_ENOUGH then -- 金币不足
        bookmark = PAY_CONST.BOOKMARK.GOLD 
    else
        bookmark = PAY_CONST.BOOKMARK.GOLD
    end

    return bookmark
end

--获取url对应的图片。如果已经下载下来，则返回文件名。否则返回nil
function M:getFilePathByUrl(url)
    if url == nil or string.len(url) == 0 then 
        return
    end
    local path = qf.downloader:getFilePathByUrl(url)
    if io.exists(path) then
        return path
    end
end

function M:judgeIsBankruptcy()
    local pick_times = Cache.Config:getBankruptcyFetchCount() or 0
    local gold = clone(Cache.user.gold)

    if Cache.DeskAssemble:judgeGameType(JDC_MATCHE_TYPE) then
        local userData = Cache.desk:getUserByUin(Cache.user.uin)
        --如果断线重连特殊情况，玩家正在游戏中则不显示跳动金币（破产）
        if (Cache.desk.status == GameStatus.GAME_STATE_INGAME) and userData then 
            return false 
        end
        
        local myChips = userData and userData.chips or 0
        gold = gold + myChips
    end 

    if pick_times >= Cache.Config.bankrupt_count or gold >= 200 then
        return false
    else
        return true
    end
end

--随机获取格言.
function M:getRandomMotto(motto_list)
    local list = motto_list or GameTxt.gameLoaddingTips001
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local motto = list[math.random(#list)] or ""
    return motto
end

--获取随机位置开始的一组格言
function M:getCycleMotto(motto_list)
    local list = motto_list or GameTxt.gameLoaddingTips001
    local cycle_motto = {}
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local index = math.random(#list)
    for i = index, #list do
        table.insert(cycle_motto, list[i])
    end
    for i = 1, index - 1 do
        table.insert(cycle_motto, list[i])
    end
    return cycle_motto
end

--将两个图片合成为一张图片
-- local info = {
--         parentFilePath = GameRes.invite_img_1,
--         childFilePath = GameRes.monthcard_icon,
--         childPosition =  cc.p(270, 480),
--         convertFileName = "iconTest1.jpg",
--         bSave = true,
--         scale = 1
--     }
-- Util:convertNodeToPictrue(info)
function M:convertNodeToPictrue(paras)
    local winSize = cc.Director:getInstance():getWinSize()
    local scale = 1
    
    local parentNode = cc.Sprite:create(paras.parentFilePath)
    local parentNodeSize = parentNode:getContentSize()
    parentNode:setVisible(true)
    parentNode:setAnchorPoint(0,0)
    parentNode:setPosition(0,0)

    local childNode = cc.Sprite:create(paras.childFilePath)
    childNode:setVisible(true)
    if paras.scale then
        scale = paras.scale
    end
    childNode:setScale(scale)
    childNode:setAnchorPoint(0.5,0.5)
    childNode:setPosition(paras.childPosition);

    parentNode:addChild(childNode)

    local target = cc.RenderTexture:create(parentNodeSize.width, parentNodeSize.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    target:retain()
    target:setPosition(cc.p(winSize.width / 2, winSize.height / 2))
    target:begin()
    parentNode:visit()
    target:endToLua()
    if paras.bSave then
        target:saveToFile(paras.convertFileName, cc.IMAGE_FORMAT_JPEG)
    end
    target:release()
    parentNode:setVisible(false)
end

--截图
-- node： 可以直接是当前场景
function M:generateScreenPic(node, fileName)
    local winSize = cc.Director:getInstance():getWinSize()
    local target = cc.RenderTexture:create(winSize.width, winSize.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)
    target:retain()
    target:setPosition(cc.p(winSize.width / 2, winSize.height / 2))
    target:begin()
    node:visit()
    target:endToLua()
    target:saveToFile(fileName, cc.IMAGE_FORMAT_PNG, true)
    target:release()
end

-- 保存图片
function M:generatePic(fileName, outFileName)
    local node = cc.Sprite:create(outFileName)
    local s1 = cc.Director:getInstance():getWinSize()
    local s = node:getContentSize()
    local scale = 1
    node:setVisible(true)
    node:setScale(scale)
    node:setAnchorPoint(0,0)
    node:setPosition(0,0)
    local jpg = fileName
    local target = cc.RenderTexture:create(s.width*scale, s.height*scale, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    target:retain()
    target:setPosition(cc.p(s1.width*scale / 2, s1.height*scale / 2))
    target:begin()
    node:visit()
    target:endToLua()
    target:saveToFile(jpg, cc.IMAGE_FORMAT_JPEG)
    target:release()
    node:setVisible(false)
end

--获取时区
function M:getTimezone()
    local now = os.time()
    return os.difftime(now, os.time(os.date("!*t", now)))/3600
end

function M:createSwallowTouchesLayer()
    local layer = cc.Layer:create()

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)

    local isInTouch = false
    local touchFirst = 1001
    local notTouchFirst = 1002

    listener:registerScriptHandler(function (touch,event)
        if not isInTouch then
            isInTouch = true
            listener:setSwallowTouches(false)
            touch.isInTouch = touchFirst
        else 
            touch.isInTouch = notTouchFirst
            listener:setSwallowTouches(true)
        end
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function (touch,event)
        listener:setSwallowTouches(false)
    end,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function (touch,event)
        if touch.isInTouch == touchFirst then
            isInTouch = false
        end
        listener:setSwallowTouches(false)
    end,cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function (touch, event)
        if touch.isInTouch == touchFirst then
            isInTouch = false
        end
        listener:setSwallowTouches(false)
    end, cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    self.cleanSwallowTouch = function()
        if isValid(layer) then
            isInTouch = false
        end
    end

    return layer
end

function M:cleanSwallowTouchesLayer()
    if self.cleanSwallowTouch then
        self:cleanSwallowTouch()
    end
end

-- upload error to server
function M:uploadError(msg)
    local host = HOST_PREFIX .. HOST_NAME .. "/client/exc/record"
    local uin = (Cache.user.uin or 0) .. ""
    local debug = qf.platform:isDebugEnv() == true and "1" or "0"
    local p = {host = host, content = msg, channel = GAME_CHANNEL_NAME, uid = uin, debug = debug, version = GAME_BASE_VERSION or ""}
    qf.platform:uploadError(p)
end

--增加layer触摸方法
function M:addTouchEvent(node, isSwallowTouches, began, moved, ended)
    if node.hasListener then loga("node.hasListener") end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(isSwallowTouches)
    listener:registerScriptHandler(began or function(touch, event) return true end, 40)
    listener:registerScriptHandler(moved or function(touch, event) end, 41)
    listener:registerScriptHandler(ended or function(touch, event) end, 42)
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
    node.hasListener = true
end

function M:removeTouchEvent(node)
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:removeEventListenersForTarget(node)
    node.hasListener = false
end

--保存闪屏数据
function M:flashBGSave( paras )
    if not paras then return end
    cc.UserDefault:getInstance():setIntegerForKey(SKEY.FLASH_TIME, paras.stay_sec or 3)
    cc.UserDefault:getInstance():setBoolForKey(SKEY.IS_FLASH, paras.status == 1)

    local flash_img = cc.UserDefault:getInstance():getStringForKey(SKEY.FLASH_IMG)

    local img_url = paras.img_url
    if not img_url or flash_img ==img_url then return end
    local path = "res/ui/global/"
    local FLASH_FILE_PATH = QNative:shareInstance():getUpdatePath() .. "/res/ui/global/flash_bg.png"

    local handler_http_req = cc.XMLHttpRequest:new()
    handler_http_req.timeout = 20

    local handler_scheduler = Util:runOnce(handler_http_req.timeout, function(...)
    end)

    handler_http_req:registerScriptHandler(function(event)
        Util:stopRun(handler_scheduler)
        handler_scheduler = nil
        if handler_http_req.status == 200 then
            
            io.writefile(FLASH_FILE_PATH, handler_http_req.response, "wb")
            cc.UserDefault:getInstance():setStringForKey(SKEY.FLASH_IMG, img_url)
        end
    end)

    --设置文件目录
    local split = string.split(path, "/")
    local prefix = QNative:shareInstance():getUpdatePath().. "/"
    for i = 1, #split - 1 do
        prefix = prefix .. split[i] .. "/"
        lfs.mkdir(prefix)
    end

    handler_http_req:open("GET", img_url)
    handler_http_req.responseType = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    handler_http_req:send()
end

--获取对应的等级的罗马数字
function M:getLevelNum(num)
    if num and num > 0 then
        if num == 1 then
           return "I"
        elseif num == 2 then
            return "II"
        elseif num == 3 then
            return "III"
        elseif num == 4 then
            return "IV"
        elseif num == 5 then
            return "V"
        elseif num == 6 then
            return "VI"
        elseif num == 7 then
            return "VII"
        elseif num == 8 then
            return "VIII"
        elseif num == 9 then
            return "IX"
        end
    else
        return ""
    end
end

function M:getMatchLevelTxt( matchInfo )
    if not matchInfo then return "" end

    local maxLevel = Cache.user:getMaxLevel()
    local level_num = ""
    if matchInfo.match_lv < maxLevel then
        level_num = self:getLevelNum(matchInfo.sub_lv)
    end

    local levelTxt = Cache.user:getConfigByLevel(matchInfo.match_lv).title .. level_num

    return levelTxt
end

function M:getLevelHeadBoxTxt( headId )
    local headBoxLevel = "0"
    local headBoxSeason = "1"
    if headId and string.len(headId) > 0 then
        local strList = string.split(headId, "_")
        for k,v in pairs(strList) do
            headBoxLevel = v
        end 
        headBoxSeason = strList[1]
    end
    return headBoxLevel,headBoxSeason
end

Util = M.new()
