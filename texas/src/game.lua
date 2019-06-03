
require("src.config.init") --常量
require("src.framework.init") -- 加载框架'
require("src.core.Event") -- 加载事件部分
require("src.core.LayerManager") -- 加载层管理
require("src.common.init")
require("src.platform.init")
require("src.res.GameRes")
require("src.res.DDZGameRes")
require("src.res.cn.GameTxt")
require("src.res.cn.DDZGameTxt")
-- require("src.cache.init")
require("src.net.init")
require("src.modules.PopupManager")
require("src.modules.common.init") --ui通用接口
require("src.modules.ModuleManager") --//加载模块
require("src.modules.ResourceManager")
require("src.music.MusicPlayer")--音乐
import(".modules.game.components.DDZ_Sound")

DEV_SIZE = {w=1920 ,h=1080}

GAME_HELPER = import("src.modules.game.GameHelper").new()--牌桌辅助

CACHE_DIR = QNative:shareInstance():getCachePath().."/"
UPDATE_DIR = QNative:shareInstance():getUpdatePath().."/"
PERSIS_DIR = cc.FileUtils:getInstance():getWritablePath() .."persis/"

local m_instance
local Game = {}

local function new( o )
    o = o or {}
    setmetatable(o, {__index = Game})
    return o
end
local function getInstance()
    if not m_instance then
        m_instance = new()
        m_instance:init()
    end
    return m_instance
end

function Game.getInstance()
    return getInstance()
end

function Game:init()

    GAME_LANG = qf.platform:getLang()

    qf.platform:getRegInfo()

    self:initDir()

    qf.log:setLogLvl(qf.log.ERROR)

    self:initEvent()
    self:initProtobuf()

    self:initHost()

    self:initScene()
end

function Game:start()
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.Login_loading)
    armatureDataManager:addArmatureFileInfo(GameRes.sunAnimate)
    armatureDataManager:addArmatureFileInfo(GameRes.newLoadingAnimate) -- 加载动画
    ModuleManager.global:show()
    ModuleManager.boradcast:show()
    ModuleManager.login:show()

    -- for k, v in pairs(GameRes.preLoadingImg)do
    --     cc.Director:getInstance():getTextureCache():addImageAsync(v, function() end)
    -- end
end

function Game:initEvent( ... )
    QNative:shareInstance():registerApplicationActions(function (paras)
        qf.event:dispatchEvent(ET.APPLICATION_ACTIONS_EVENT, {type = paras})
    end)
end
function Game:initProtobuf( ... )
    local filePath = "res/texas_net.proto"
    local updatePath = QNative:shareInstance():getUpdatePath() .. "/" .. filePath
    if io.exists(updatePath) then
        filePath = updatePath
    end
    local directory, filename = self:copyToLocal(filePath)
    pb.import(filename, directory)
end
function Game:copyToLocal( relativeFilePath )
    -- 最后那段名字
    local filename = string.sub(relativeFilePath, string.find(relativeFilePath, "[^/]+$", 0))
    local srcFilePath = cc.FileUtils:getInstance():fullPathForFilename(relativeFilePath)
    
    local srcData = cc.FileUtils:getInstance():getDataFromFile(srcFilePath)
    local dstDirectory = cc.FileUtils:getInstance():getWritablePath()
    local dstFilePath = dstDirectory .. filename
    
    local f = assert(io.open(dstFilePath, "wb"))
    f:write(srcData)
    f:close()
    
    return dstDirectory, filename
end

function Game:initHost( ... )
    local winSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local radio = winSize.height / winSize.width
    
    -- 标准 0.5625
    -- 960*640  0.6666 最短
    -- 480*800 0.6 次短
    -- 若比率大于等于 0.6 则需要缩放部分元素
    
    if radio > 0.5634 then 
        FORCE_ADJUST_GAME = true
        GAME_RADIO = radio
    end
    -- 初始化host
    local channel = GAME_CHANNEL_NAME or "CN_NIL"
    channel = string.sub(channel, 0, 2)
    if qf.platform:isDebugEnv() == true then 
        -- HOST_NAME = HOST_TEST_NAME -- 已在热更新处赋值，如果去掉热更新，则必要要
        HOST_PAY_NAME = HOST_PAY_TEST_NAME
    elseif channel == "CN" then
        -- HOST_NAME = HOST_RELEASE_NAME -- 已在热更新处赋值，如果去掉热更新，则必要要
        HOST_PAY_NAME = HOST_PAY_RELEASE_NAME
    end
    
    -- 禁止在此处手动给HOST_NAME赋值，如有必要，修改channel或isDebugEnv的值
    
    PF_WINDOWS = qf.device.platform == "windows" -- 检查是否为windows
end

function Game:initScene()
    local gameScene = cc.Scene:create()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end

    LayerManager:init(gameScene)
    PopupManager:init()
    ModuleManager:init()
end

function Game:mkdir( dir )
    QNative:shareInstance():mkdir(dir)
end
function Game:rmdir( dir )
    qf.platform:removeDir(dir)
end

function Game:initDir()
    self:rmdir(CACHE_DIR)
    self:mkdir(CACHE_DIR) -- 重建缓存目录
    self:mkdir(PERSIS_DIR)-- 持久目录
    self:mkdir(UPDATE_DIR)-- 建更新目录
end

return Game