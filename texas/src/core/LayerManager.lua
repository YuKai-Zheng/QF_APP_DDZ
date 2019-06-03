--[[
    Layer管理器
    1.将一些主要的Layer预加载，添加到主Scene中
    2.主要负责预加载创建
]]

LayerManager = {}
LayerManager.TAG = "layerManager"

local defaultZorder = 2
local topZorder = 100

function LayerManager:init(parameters)
	self._root = parameters

    self.layerConfig = {
        {"PreloadLayer" , 0},
        {"MainLayer" , 0},
        {"GameLayer" , defaultZorder},
        {"Matching" , 0},
        {"BoradcastLayer" , 1},
        {"FriendLayer" , defaultZorder},
        {"RewardLayer" , defaultZorder},
        {"LobbyLayer" , defaultZorder},
        {"ChoseHallLayer" , 0},
        {"CustomizeLayer" , defaultZorder},
        {"SettleLayer" , 3},
        {"Activity" , defaultZorder},
        {"Popularize" , defaultZorder},
        {"ChangeUserLayer" , defaultZorder},
        {"GiftLayer" , defaultZorder},
        {"GamesRecordLayer" , defaultZorder},
        {"Setting" , defaultZorder},
        {"Focas" , defaultZorder},
        {"Exchange" , defaultZorder},
        {"Shop" , defaultZorder},
        {"LabaLayer" , defaultZorder},
        {"LoginRewardLayer" , defaultZorder},
        {"DaojuLayer" , 4},
        {"PopupLayer" , 13},
        {"LoginLayer" , 10},
        {"Global" , 14},
        {"QufanLoginLayer" , 12},
    }
	
    self:initLayers()
    self:addSwallowTouchesLayer()
	self:registerLayerEvent()
	logd("src.core.layerManager init success !",self.TAG)
end

function LayerManager:initLayers()
    for _,config in ipairs(self.layerConfig) do
        self:addLayer(config[1], config[2])
    end
end

function LayerManager:addLayer(name, zorder)
    local layer = cc.Layer:create()
    if zorder > 0 then
        self._root:addChild(layer, zorder)
    else
        self._root:addChild(layer)
    end
    self[name] = layer
end

function LayerManager:registerLayerEvent()
    -- TODO
end

function LayerManager:addSwallowTouchesLayer()
    local layer = Util:createSwallowTouchesLayer()
    self._root:addChild(layer, topZorder)

    self.swallTouchLayer = layer
end

