--[[
--热更新
--]]

require "json"
require("src.config.init")
require("src.framework.init")
require("src.res.GameRes")
require("src.res.DDZGameRes")
require("src.common.init")
require("src.platform.init")
require("src.core.Event")
require("src.music.MusicPlayer") --音乐
require("src.res.cn.GameTxt")
require("src.cache.init")


local GlobalPromit = require("src.modules.global.components.GlobalPromit")
local HotUpdateHelper = require("src.update.HotUpdateHelper")
local TAG_GLOBAL_PROMIT = 1001

local HotUpdateMain = {}
local m_instance
local function new( o )
	o = o or {}
	setmetatable(o, {__index=HotUpdateMain})
	return o
end
local function getInstance( ... )
	if not m_instance then
		m_instance = new()
	end
	return m_instance
end

local function main()
    local instance = getInstance()
    instance:init()
    instance:initUI()
end

function HotUpdateMain:init( ... )
    self.gameHelper={}
	self.helper = HotUpdateHelper.getInstance()
    self.helper:init({callback=handler(self, self.handlerDownload)})
    
    self.helper:createUpdateFolder()

    self:setMaidenResSearchPath()

    self.helper:setResSearchPath()
end

function HotUpdateMain:initUI()
	self.win_size = cc.Director:getInstance():getWinSize()

	self.scene = cc.Scene:create()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(self.scene)
    else
        cc.Director:getInstance():runWithScene(self.scene)
    end

	self.layer = cc.Layer:create()
	self.layer:setTouchEnabled(true)
	self.scene:addChild(self.layer)

    self:registerScriptHandler()

    local flashTime =  cc.UserDefault:getInstance():getIntegerForKey(SKEY.FLASH_TIME, 3)
    local isflash = cc.UserDefault:getInstance():getBoolForKey(SKEY.IS_FLASH, false)

    if isflash then
        self.flashBg = ccui.ImageView:create(GameRes.flash_bg)
        
        self.flashlogo = ccui.ImageView:create(GameRes.flash_logo)
        self.flashlogo:setPosition(cc.p(self.flashlogo:getContentSize().width / 2 + 50, self.win_size.height - self.flashlogo:getContentSize().height / 2 - 50))
        if string.find(GAME_CHANNEL_NAME,"CN_AD_OPPO1") then
            self.flashlogo:loadTexture(GameRes.logo_img_oppo)
        else
            self.flashlogo:loadTexture(GameRes.flash_logo)
        end
        self.layer:addChild(self.flashlogo, 101)
        self.layer:addChild(self.flashBg, 100)
        local size = self.flashBg:getContentSize()
        if size.width < self.win_size.width then size.width = self.win_size.width end
        size.height = self.win_size.height
        self.flashBg:ignoreContentAdaptWithSize(false)
        self.flashBg:setContentSize(size)
        self.flashBg:setPosition(cc.p(self.win_size.width / 2, self.win_size.height / 2))
        self.flashBg:runAction(cc.Sequence:create(
            cc.DelayTime:create(flashTime),
            cc.CallFunc:create(function (  )
                --若更新和配置在闪屏前结束，则不移除闪屏，等待切换场景
                --if not self.finishDownload then
                    self.flashBg:removeFromParent()
                    self.flashlogo:removeFromParent()
                --end
                self.finishFlash = true
                self:gameStart()
            end)
        ))
    else
        self.finishFlash = true
    end

    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.hotUpdateJson)
    self.layer:addChild(self.root)

    self.pan_all = self.root:getChildByName("pan_all")
    self.pan_progress = ccui.Helper:seekWidgetByName(self.root, "pan_progress")
    --进度提示
    self.pan_progress_tip = self.pan_progress:getChildByName("pan_txt")

    self.bar_progress = self.pan_progress:getChildByName("bar_progress")
    --进度半分比
    self.lbl_num = self.pan_progress_tip:getChildByName("lbl_num")
    --具体的下载大小
    self.lbl_percect = self.pan_progress_tip:getChildByName("lbl_perfect")

    self.loadingFly = self.bar_progress:getChildByName("fly")

    self.img_loadding_bg = self.pan_all:getChildByName("Image_26")

    -- logo
    self.img_logo = ccui.Helper:seekWidgetByName(self.root, "img_logo")

    if string.find(GAME_CHANNEL_NAME,"CN_AD_OPPO1") then
        self.img_logo:loadTexture(GameRes.logo_img_oppo)
    else
        self.img_logo:loadTexture(GameRes.logo_img_1)
    end

    self:initLoadding()
end

--初始化loadding
function HotUpdateMain:initLoadding( ... )
    self.img_loadding = cc.Sprite:create()
    self.img_loadding:setAnchorPoint(cc.p(0, 0))
    self.pan_all:addChild(self.img_loadding, 3)

    local statusTxt = cc.Sprite:create(GameRes.login_bg_txt1)
    statusTxt:setAnchorPoint(cc.p(0,0))
    self.img_loadding:addChild(statusTxt)
    local txt_size = statusTxt:getContentSize()

    local spr = cc.Sprite:create()
    self.img_loadding:addChild(spr)

    cc.SpriteFrameCache:getInstance():addSpriteFrames(GameRes.login_plist, GameRes.login_png)
    local frames = Display:newFrames("login_%d.png", 1, 4)
    local ani = Display:newAnimation(frames, 0.7)

    local seq = cc.RepeatForever:create(cc.Animate:create(ani))
    spr:runAction(seq)

    spr:setPosition(txt_size.width + LOGIN_LOADING_ARMATURE_WIDTH * 0.5, txt_size.height * 0.5)

    self.img_loadding:setPosition(self.win_size.width * 0.5 - LOGIN_LOADING_ARMATURE_WIDTH * 0.5 - txt_size.width * 0.5, 80)

    --资质信息，针对要求选择一个
    local verifyInfo = ccui.Helper:seekWidgetByName(self.root, "verifyInfo")
    
    if VERIFY_TXT_NEED then
        self.img_loadding_bg:setScale(1.6)
        self.img_loadding:setPosition(self.win_size.width * 0.5 - LOGIN_LOADING_ARMATURE_WIDTH * 0.5 - txt_size.width * 0.5, 130)
        -- verifyInfo:setPositionY(65) 
    else
        verifyInfo:loadTexture(GameRes.health_advice)
        -- verifyInfo:setPositionY(45)
    end
end

function HotUpdateMain:showToolsTips(msg)
    if self.toolTips then return end

    self.toolTips = require("src.modules.common.widget.toolTip").new()
    self.toolTips:removeCloseTouch()
    self.toolTips:setTipsText(msg)
    self.layer:addChild(self.toolTips,2)
    if self.toolsTipsSch then
        Scheduler:unschedule(self.toolsTipsSch)
        self.toolsTipsSch=nil
    end
    self.toolsTipsSch =  Scheduler:scheduler(60,function( ... )
        -- body
        self.helper:init({callback=handler(self, self.handlerDownload)})
    end)
end
function HotUpdateMain:removeToolsTips( ... )
    -- body
    if not self.toolTips then return end
    self.toolTips:removeFromParent()
    self.toolTips=nil
    if self.toolsTipsSch then
        Scheduler:unschedule(self.toolsTipsSch)
        self.toolsTipsSch=nil
    end
end

function HotUpdateMain:registerScriptHandler( ... )
    -- 绑定Node事件
    local function onNodeEvent(eventName)
        if eventName == "enter" then
        	self:onEnter()
        elseif eventName == "exit" then
        end
    end
    self.layer:registerScriptHandler(onNodeEvent)
end
function HotUpdateMain:onEnter( ... )
	self.helper:startDownload({load_type=0})
end

function HotUpdateMain:playLoadingFlyAnimation( ... )
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.loadingFly)
    local loadingFlyArmatrue = ccs.Armature:create("loadingFly")
    self.loadingFly:addChild(loadingFlyArmatrue, 0)
    loadingFlyArmatrue:setPosition(self.loadingFly:getContentSize().width / 2, self.loadingFly:getContentSize().height / 2)
    loadingFlyArmatrue:getAnimation():playWithIndex(0)
    -- 记录初始位置
    self.flyPos_X = self.loadingFly:getPositionX()
end

function HotUpdateMain:updateFlyPos(percent)
    if 0 == Util:binaryAnd(TB_SERVER_INFO.modules, TB_MODULE_BIT.MODULE_BIT_REVIEW) then return end
    local width = self.bar_progress:getContentSize().width
    margin = (width -self.loadingFly:getContentSize().width)/100
    self.loadingFly:setPositionX(self.flyPos_X + margin*percent)
end

--开始更新文件
function HotUpdateMain:startDownloadUpdateFile( ... )
    dump(TB_SERVER_INFO.modules)
    if 0 ~= Util:binaryAnd(TB_SERVER_INFO.modules, TB_MODULE_BIT.MODULE_BIT_REVIEW) then
        self.pan_progress:setVisible(true)
        self.img_loadding:setVisible(false)
        self.img_loadding_bg:setVisible(false)
        self:playLoadingFlyAnimation()
        self:updateProgress()
    else
        if self.isGetTotalSize then return end
    end
    self.helper:startDownload({load_type=2})
end
--更新进度条
function HotUpdateMain:updateProgress( ... )
    --四舍五入. num, 整数; n, 向第n位取整。 例如输入125，要输出130， 则n要传入2
    local roundOff =function(num, n)
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
    self.current_count = self.current_count > self.current_total_count and self.current_total_count or self.current_count
    local percent = self.current_count*100/self.current_total_count

    local percent = percent * math.pow(10, 3)
    percent = roundOff(percent, 2) --四舍五入
    percent = percent / math.pow(10, 3)
    local percent =percent
    percent = (self.current_count*100/self.current_total_count) > 100 and 100 or percent
    loga(percent)
    self.lbl_num:setString(percent.."%")
    self.lbl_percect:setString(string.format("(%dk/%dk)", self.current_count, self.current_total_count))

    self.bar_progress:setPercent(percent)
    self:updateFlyPos(percent)
    
    local size = self.bar_progress:getContentSize()
    if percent<1 then percent = 1 
    elseif percent>99 then percent = 99 end 
    local posx = size.width*percent/100
    local img = self.pan_progress:getChildByName("img_1")
    local bg = self.pan_progress:getChildByName("img_progress_bg")
    img:setPositionX(bg:getPositionX()+posx)
end

--[[
name = "result", load_type=type --完成了第几步
name = "progress", count=n --下载更新文件，count当前下载了多少
--]]
function HotUpdateMain:handlerDownload( args )
	local name = args.name
    if name == "progress" then --下载更新文件的过程
		self.current_count = args.count
		self:updateProgress()
	elseif name == "result" then --某个阶段完成
		self:downloadFinish(args.load_type)
        if args.load_type == 0 then 
            self:removeToolsTips()
        end
    elseif name == "stopSocket" then --停服
        self:showToolsTips(args.msg and args.msg or "")
	end
end

--某个阶段下载完成
function HotUpdateMain:downloadFinish( load_type, args )
	if load_type == 0 then --配置下载完成
        self:downloadConfigListSuccess()
	elseif load_type == 1 then --md5文件下载完成
        self:downloadMd5FileSuccess()
	elseif load_type == 2 then --更新文件下载完成
        self.helper:setDownloadFinish(true) --下载完成
        self:enterGame()
	end
end
--下载配置文件成功
function HotUpdateMain:downloadConfigListSuccess( ... )
    local function _callback( ... )
        --检查增量更新的方式，是否需要更新
        local hot_type = self.helper:getHotUpdateType()
        if hot_type == 1 or hot_type == 2 or hot_type == 3 then
            self.helper:startDownload({load_type=1})
        else
            self:enterGame()
        end
    end

    --检查是否需要大版本更新或停服提示
    local is_need_full, content = self.helper:checkFullDoseUpdate()
    if is_need_full then --需要提示
        self:tipWithFullDose({content=content, callback=_callback})
    else
        _callback()
    end
end
--大版本更新或停服提示
function HotUpdateMain:tipWithFullDose( args )
    local content = args.content
    local function _callback( _type )
        if 2 ~= content.pkg_status then --不是强制更新要把提示界面移除
            self.layer:removeChildByTag(TAG_GLOBAL_PROMIT, true)
        end
        if 1 == content.server_status then --停服
            Util:runForever(60, function( ... )
                self.helper:onDownloadFail()
            end)
            return
        end

        if _type == 1 then --更新大版本不用热更新
            qf.platform:updateGame({url=content.pkg_url})
            if 1 == content.pkg_status then --建议更新大版本，进入游戏

                self:enterGame()
            else --强制更新，停留在此界面
            end
        else --不更新大版本，需要热更新
            if args.callback then
                args.callback()
            end
        end
    end

    content.updateGame = _callback
    local promit = GlobalPromit.new(content)
    promit:setPosition(self.win_size.width/2, self.win_size.height/2)
    self.layer:addChild(promit, 1, TAG_GLOBAL_PROMIT)
end
--增量更新提示
function HotUpdateMain:tipWithDeltaUpdate( args )
    local content = args.content
    local function _callback( _type ) 
        self.layer:removeChildByTag(TAG_GLOBAL_PROMIT, true)
        if _type == 1 then
            self:consureDeltaUpdate()
        else
            self:cancelDeltaUpdate()
        end
    end
    content.updateGame = _callback
    local promit = GlobalPromit.new(content)
    promit:setPosition(self.win_size.width/2, self.win_size.height/2)
    self.layer:addChild(promit, 1, TAG_GLOBAL_PROMIT)
end
--在提示弹窗中取消增量更新
function HotUpdateMain:cancelDeltaUpdate( ... )
    if qf.platform:isEnabledWifi() then --wifi下后台更新
        self:downloadInback()
    else
        self:enterGame()
    end
end
--确认要进行增量更新
function HotUpdateMain:consureDeltaUpdate( ... )
    self:startDownloadUpdateFile()
end

--下载配置文件成功
function HotUpdateMain:downloadMd5FileSuccess( ... )
    local count = self.helper:getLastedFileCount() --获取剩余要更新文件数量
    local hot_type = self.helper:getHotUpdateType()
    if count == 0 or hot_type == 0 then --没有需要更新的文件或不需要更新
        self.helper:setDownloadFinish(true) --下载完成
        self:enterGame()
    elseif hot_type==1 or hot_type==2 then
        local is_need_tip = true
        local total_byte = self.helper:getLastedTotalByte()
        if hot_type == 2 then --强制更新
            is_need_tip = false
        else
            if total_byte < 2048 then
                is_need_tip = false
            end
        end

        self.current_total_count = total_byte
        self.current_count = 0

        if is_need_tip then --需要提示用户有热更新
            local content = {
                ["type"] = 0
                , pkg_status = 1
                , des = string.format(GameTxt.hot_update_string_7, total_byte/1024)
            }
            self:tipWithDeltaUpdate({content=content})
        else
            self:startDownloadUpdateFile()
        end
    else
        local total_byte = self.helper:getLastedTotalByte()
        self.current_total_count = total_byte
        self.current_count = 0

        if hot_type == 2 then --强制更新
            self:startDownloadUpdateFile()
        else
            self:downloadInback({load_type=2})
        end
    end
end
--进入游戏之前，把缓存的lua文件全部清除
function HotUpdateMain:cleanLuaCache( ... )
    for k, _ in pairs(package.loaded) do
        if string.find(k, "src.") then
            package.loaded[k] = nil 
            package.preload[k] = nil 
        end
    end
end
--后台下载
function HotUpdateMain:downloadInback( args )
    args = args or {}
    local load_type = args.load_type or 2
    
    self.helper:resetCallback()
    self.helper:startDownload({load_type=load_type})

    self:enterGame()
end
function HotUpdateMain:enterGame( ... )
    self.finishDownload = true
    --完成新资源的下载,开始加载资源
    self:cleanLuaCache()
    self.helper:willEnterGame()
    self:setReivewFolder()

    -- 延迟0.1s进入游戏
    if self.pan_progress_tip then
        self.pan_progress_tip:setVisible(false)
    end

    self:requireLuaAnew()

    ResourceManager:preLoad()
    self:gameStart()
end

function HotUpdateMain:gameStart(  )
    if not self.finishDownload then return end
    if not self.finishFlash then return end
    
    Util:runOnce(0.1, function( ... )
        local Game = require "src.game"
        Game.getInstance():start()
    end)
end

function HotUpdateMain:requireLuaAnew( ... )
    -- body
    GAME_LANG = qf.platform:getLang()
    package.loaded["json"] = nil
    package.loaded["src.config.init"] = nil
    package.loaded["src.framework.init"] = nil
    package.loaded["src.res.GameRes"] = nil
    package.loaded["src.common.init"] = nil
    package.loaded["src.platform.init"] = nil
    package.loaded["src.core.Event"] = nil
    package.loaded["src.music.MusicPlayer"] = nil
    package.loaded["src.modules.global.components.GlobalPromit"] = nil
    package.loaded["src.update.HotUpdateHelper"] = nil
    package.loaded["src.res."..GAME_LANG..".GameTxt"] = nil
    package.loaded["src.cache.init"] = nil

    require "json"
    require("src.config.init")
    require("src.framework.init")
    require("src.res.GameRes")
    require("src.common.init")
    require("src.platform.init")
    require("src.core.Event")
    require("src.music.MusicPlayer") --音乐
    require("src.modules.global.components.GlobalPromit")
    require("src.update.HotUpdateHelper")
    require("src.modules.ResourceManager")
    GAME_LANG = qf.platform:getLang()
    qf.platform:getIfScreenFrame()
    require("src.res."..GAME_LANG..".GameTxt")
    require("src.cache.init")
end

--设置过审目录
function HotUpdateMain:setReivewFolder( ... )
    local is_review = 0 ~= Util:binaryAnd(TB_SERVER_INFO.modules, TB_MODULE_BIT.MODULE_BIT_REVIEW) and true or false
     if not is_review then
        local review_folder = Util:getReivewFolder()
        if review_folder then
            cc.FileUtils:getInstance():addSearchPath(review_folder,true)
        end
    else --充质资源搜索目录
        self:resetResSearchPath()
    end
    --判断并记录当前的过审状态
    local status = cc.UserDefault:getInstance():getStringForKey(SKEY.REVIEW_STATUS,"450:false")
    local array_status = string.split(status,":")
    local version_code = tonumber(qf.platform:getRegInfo().version or 0)

    if checkint(array_status[1]) ~= checkint(version_code) or array_status[2] ~= tostring(is_review) then
        local value = checkint(version_code)..":"..tostring(is_review)
        cc.UserDefault:getInstance():setStringForKey(SKEY.REVIEW_STATUS,value)
        cc.UserDefault:getInstance():flush()
    end
end

--重置资源搜索目录，删除maiden_folder
function HotUpdateMain:resetResSearchPath( ... )
    -- body
    local search_paths = cc.FileUtils:getInstance():getSearchPaths()
    local reivew_folder = Util:getReivewFolder()
    if reivew_folder then
        for k,v in pairs(search_paths) do
            if v==reivew_folder then
                table.remove(search_paths,k)
                break
            end
        end
        cc.FileUtils:getInstance():setSearchPaths(search_paths)
    end
end

--检查是否过审是否需要替换热更新界面资源
function HotUpdateMain:setMaidenResSearchPath( ... )
    -- body
    local status = cc.UserDefault:getInstance():getStringForKey(SKEY.REVIEW_STATUS,"380:true")
    local array_status = string.split(status,":")
    local version_code = tonumber(qf.platform:getRegInfo().version or 0)
    if checkint(array_status[1]) ~= checkint(version_code) or array_status[2] == "false" then
        self.is_review=true
        local reivew_folder = Util:getReivewFolder()
        if reivew_folder then
            cc.FileUtils:getInstance():addSearchPath(reivew_folder)
        end
    end
end

main()
