local HallView          = class("HallView", qf.view)
local BloomNode         = import("src.modules.common.widget.BloomNode")
HallView.TAG            = "hallView"
local GameAnimationConfig = import("..game.components.animation.AnimationConfig")
local HallItem = import(".components.HallItem")

local HallMenuComponent = import("src.modules.global.components.HallMenuComponent")

function HallView:ctor(parameters)
    HallView.super.ctor(self,parameters)
    self.upAreaBtn_hall = {}--上面的
    self:initData(parameters)
    self:initPublicModule()
    self:initButtonEvents()
    --self:initChangciInfoNew()
    self:updateUserInfo()
    self:firstPayBtnAni()
    self:initMenu()
    -- self:playBtnEffect()
    if FULLSCREENADAPTIVE then
        self.topTools:setPositionX(self.topTools:getPositionX()+(self.winSize.width/2-1920/2)*3/5 - 15)
    end

    Util:delayRun(0.1, function()
        if isValid(self) then
            self:getHallGameRoomInfo()
        end
    end)
    -- self:initUpBtnTable()
end

function HallView:initData(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
end

function HallView:initPublicModule()
    if Cache.DDZDesk.enterRef == GAME_DDZ_MATCH then return end
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.gameHallJSON)
    self.quick_start = ccui.Helper:seekWidgetByName(self.root, "quick_start")
    --self.listItem = ccui.Helper:seekWidgetByName(self.root, "changci_item")
    self.listView = ccui.Helper:seekWidgetByName(self.root,"gameP")

    self.listView_vertical = ccui.Helper:seekWidgetByName(self.root,"gameP_vertical") 
    self.item_vertical = ccui.Helper:seekWidgetByName(self.root, "item_vertical")
    --self.listItem_vertical = ccui.Helper:seekWidgetByName(self.root, "changci_item_vertical")

    self.listView:setClippingEnabled(false)
    self.listView_vertical:setClippingEnabled(false)

    self.topTools = ccui.Helper:seekWidgetByName(self.root, "topTools") --顶部工具栏

    -- 上边按钮栏
    self.settingBtn = ccui.Helper:seekWidgetByName(self.topTools, "setting") --设置按钮
    
    self.packBtn = ccui.Helper:seekWidgetByName(self.topTools, "package") -- 背包
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.packBtn:setVisible(false)
    else
        self.packBtn:setVisible(true)
    end

    self:addChild(self.root)
end

function HallView:enterAnimation()
    self.listView:setPositionX(self.winSize.width)
    self.listView:runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.1,cc.p((self.winSize.width - self.listView:getContentSize().width)*0.5 - (self.winSize.width - 1920)/2,178)),
            cc.CallFunc:create(function (  )
                if isValid(self) then
                    self.menu:startAnimation()
                end
            end)
        )
    )
end

--初始化button事件
function HallView:initButtonEvents()
    if Cache.DDZDesk.enterRef == GAME_DDZ_MATCH then return end
    -- 快速开始
    addButtonEvent(self.quick_start,function ()
        self:quickStartGame()
    end)

    addButtonEvent(self.settingBtn, function (sender)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅设置") end
        qf.event:dispatchEvent(ET.SHOW_SETTING_VIEW)
        qf.platform:umengStatistics({umeng_key = "Set_up"})--点击上报
    end)

    addButtonEvent(self.packBtn, function (sender)
        qf.event:dispatchEvent(ET.SHOW_DAOJU_VIEW)
        qf.platform:umengStatistics({umeng_key = "pack"})--点击上报
    end)

    -- 安卓返回键
    Util:registerKeyReleased({self = self,cb = function ()
        self:goBcak()
    end})
end

--更新基本信息
function HallView:updateUserInfo()
    if Cache.DDZDesk.enterRef == GAME_DDZ_MATCH then return end
    -- 更新信息栏
    if isValid(self.menu) then
        self.menu:updateData()
    end
end

--初始化listView
function HallView:initChangciInfoNew(model)
    if Cache.DDZDesk.enterRef == GAME_DDZ_MATCH then return end
    local roomConfigArr  = Cache.DDZconfig:getRoomConfigByType(Cache.DDZDesk.enterRef)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(GameRes.newDDZCoinGame_plist, GameRes.newDDZCoinGame_png)
    
    local roomConfigCount = table.nums(roomConfigArr)

    if #roomConfigArr <= 4 then
        self:initChangciInfoNew_horizon(model)
        self:enterAnimation()
    else
        self:initChangciInfoNew_vertical(model)
    end
    ccui.Helper:seekWidgetByName(self.quick_start,"quickGameName"):setString(self.quickName)
end

function HallView:getHallGameRoomInfo()
    qf.event:dispatchEvent(ET.GET_QUICK_START_ROOMID,{cb = function (rsp)
        local model = rsp.model
        if model then
            if model.room_id > 0 then
                self.quickRoomId = model.room_id
            end
        end
        GameNet:send({cmd=CMD.HALL_SELECT_PLAY,body={},callback=function(rsp)
            local model = rsp.model
            if not isValid(self) then return end
            if rsp.ret == 0 then
                self:initChangciInfoNew(rsp.model)
            end
        end})
    end})
end

function HallView:getRoomSourceIndex(info)
    if info.room_type == 1 then
        return 1
    elseif info.room_type == 3 then
        if info.room_name == "新手场" then
            return 2
        elseif info.room_name == "初级场" then
            return 3
        elseif info.room_name == "中级场" then
            return 4
        elseif info.room_name == "高级场" then
            return 5
        elseif info.room_name == "顶级场" then
            return 5
        else
            return 5
        end
    end  
end

function HallView:initChangciInfoNew_horizon(model)
    self.listItem = HallItem.new({type = 1}):getUI()
    self.listView:setVisible(true)
    self.listView_vertical:setVisible(false)

    local roomConfigArr  = Cache.DDZconfig:getRoomConfigByType(Cache.DDZDesk.enterRef)
    self.listView:setItemModel(self.listItem)
    self.listView:setBounceEnabled(false)
    self.listView:setTouchEnabled(false)
    
    local itemNum = 0
    for index = 1, #roomConfigArr do
        self.listView:pushBackDefaultItem()
        itemNum = itemNum + 1
        local info = roomConfigArr[index]
        local roomLevelIndex = self:getRoomSourceIndex(info)
        local item = self.listView:getItem(index -1)
        item:setVisible(true)
        ccui.Helper:seekWidgetByName(item,"base_num"):setString(info.base_chip)
        local limit_num = ccui.Helper:seekWidgetByName(item,"limit_num")
        limit_num:setString(info.carry_desc)
        if info.disable == 1 then
            ccui.Helper:seekWidgetByName(item,"gameItem"):setTouchEnabled(false)
            ccui.Helper:seekWidgetByName(item,"gameItem"):loadTexture(string.format(GameRes.game_item,1),ccui.TextureResType.plistType)
            ccui.Helper:seekWidgetByName(item,"lock"):setVisible(true)
            ccui.Helper:seekWidgetByName(item,"base_layer"):setVisible(false)
            ccui.Helper:seekWidgetByName(item,"limit_layer"):setVisible(false)
        else
            ccui.Helper:seekWidgetByName(item,"gameItem"):setTouchEnabled(true)
            ccui.Helper:seekWidgetByName(item,"gameItem"):loadTexture(string.format(GameRes.game_item,roomLevelIndex),ccui.TextureResType.plistType)
            ccui.Helper:seekWidgetByName(item,"lock"):setVisible(false)
            ccui.Helper:seekWidgetByName(item,"base_layer"):setVisible(true)
            ccui.Helper:seekWidgetByName(item,"base_img"):loadTexture(string.format(GameRes.game_hall_difen,roomLevelIndex), ccui.TextureResType.plistType)
            
            ccui.Helper:seekWidgetByName(item,"limit_layer"):setVisible(true) 
            ccui.Helper:seekWidgetByName(item,"limit_icon"):loadTexture(GameRes.poker_icon, ccui.TextureResType.plistType)
            if roomLevelIndex > 4 then
                ccui.Helper:seekWidgetByName(item,"base_num"):setFntFile(string.format(GameRes.game_hall_font,roomLevelIndex - 1))
                ccui.Helper:seekWidgetByName(item,"user_num_img"):loadTexture(string.format(GameRes.num_icon,roomLevelIndex - 1), ccui.TextureResType.plistType)
            else
                ccui.Helper:seekWidgetByName(item,"base_num"):setFntFile(string.format(GameRes.game_hall_font,roomLevelIndex))
                ccui.Helper:seekWidgetByName(item,"user_num_img"):loadTexture(string.format(GameRes.num_icon,roomLevelIndex), ccui.TextureResType.plistType)
            end
            
            if info.room_type == 3 then
                ccui.Helper:seekWidgetByName(item,"hot_tag"):setVisible(true)
            else
                ccui.Helper:seekWidgetByName(item,"hot_tag"):setVisible(false)
            end
     
            if roomLevelIndex == 1 then
                limit_num:setColor(cc.c3b(159,221,197))
            elseif roomLevelIndex == 2 then
                limit_num:setColor(cc.c3b(105,215,225))
            elseif roomLevelIndex == 3 then
                limit_num:setColor(cc.c3b(115,221,244))
            elseif roomLevelIndex > 3 then
                limit_num:setColor(cc.c3b(200,185,241))
            end
        end
        if self.quickRoomId and info.room_id == self.quickRoomId then
            local armatureDataManager = ccs.ArmatureDataManager:getInstance()
            armatureDataManager:addArmatureFileInfo(GameRes.horizonItemSelected)
            self.horizonItemAni = ccs.Armature:create("horizonItemSelected")
            self.horizonItemAni:getAnimation():playWithIndex(0)
            local size = ccui.Helper:seekWidgetByName(item,"gameItem"):getSize()
            self.horizonItemAni:setPosition(size.width/2,size.height/2)
            ccui.Helper:seekWidgetByName(item,"gameItem"):addChild(self.horizonItemAni)

            self.quickName = "经典  "
            if info.room_type == 3 then
                self.quickName = "不洗牌  "
            end
            self.quickName = self.quickName..info.room_name
        end

        addButtonEvent(ccui.Helper:seekWidgetByName(item,"gameItem"),function ()
            Cache.DDZDesk.enterRef = GAME_DDZ_CLASSIC
            self:gotoClassicGameView(info.room_id)
            ccui.Helper:seekWidgetByName(item,"gameItem"):setScale(1.0)
        end,function ( )
            ccui.Helper:seekWidgetByName(item,"gameItem"):setScale(1.1)
        end,function ( )
            -- ccui.Helper:seekWidgetByName(item,"gameItem"):setScale(1.1)
        end,function ( )
            ccui.Helper:seekWidgetByName(item,"gameItem"):setScale(1.0)
        end)

        for i = 1, model.room:len() do
            local v = model.room:get(i)
            if v.room_id == info.room_id then
                info.cur_online = v.cur_online or 0
                local users_num = ccui.Helper:seekWidgetByName(item,"users_num")
                users_num:setString(Util:getFormatString(info.cur_online))
            end
        end
    end

    if #roomConfigArr < 4 then
        self.listView:pushBackDefaultItem()
        local roomLevelIndex = 5
        local item = self.listView:getItem(itemNum)
        item:setVisible(true)
        ccui.Helper:seekWidgetByName(item,"base_num"):setString("")
        local limit_num = ccui.Helper:seekWidgetByName(item,"limit_num")
  

            ccui.Helper:seekWidgetByName(item,"gameItem"):setTouchEnabled(true)
            ccui.Helper:seekWidgetByName(item,"gameItem"):loadTexture(string.format(GameRes.game_item,roomLevelIndex),ccui.TextureResType.plistType)
            ccui.Helper:seekWidgetByName(item,"lock"):setVisible(true)
            ccui.Helper:seekWidgetByName(item,"base_layer"):setVisible(false)
            ccui.Helper:seekWidgetByName(item,"limit_layer"):setVisible(false)
           
        
            -- ccui.Helper:seekWidgetByName(item,"limit_icon"):loadTexture(GameRes.poker_icon, ccui.TextureResType.plistType)
            if roomLevelIndex > 4 then
                ccui.Helper:seekWidgetByName(item,"base_num"):setFntFile(string.format(GameRes.game_hall_font,roomLevelIndex - 1))
                ccui.Helper:seekWidgetByName(item,"user_num_img"):loadTexture(string.format(GameRes.num_icon,roomLevelIndex - 1), ccui.TextureResType.plistType)
            else
                ccui.Helper:seekWidgetByName(item,"base_num"):setFntFile(string.format(GameRes.game_hall_font,roomLevelIndex))
                ccui.Helper:seekWidgetByName(item,"user_num_img"):loadTexture(string.format(GameRes.num_icon,roomLevelIndex), ccui.TextureResType.plistType)
            end
               
            ccui.Helper:seekWidgetByName(item,"hot_tag"):setVisible(false)
   
     
            if roomLevelIndex == 1 then
                limit_num:setColor(cc.c3b(159,221,197))
            elseif roomLevelIndex == 2 then
                limit_num:setColor(cc.c3b(105,215,225))
            elseif roomLevelIndex == 3 then
                limit_num:setColor(cc.c3b(115,221,244))
            elseif roomLevelIndex > 3 then
                limit_num:setColor(cc.c3b(200,185,241))
            end

        addButtonEvent(ccui.Helper:seekWidgetByName(item,"gameItem"),function ()
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.coinGameEnable})
            ccui.Helper:seekWidgetByName(item,"gameItem"):setScale(1.0)
        end,function ( )
            ccui.Helper:seekWidgetByName(item,"gameItem"):setScale(1.1)
        end,function ( )
            -- ccui.Helper:seekWidgetByName(item,"gameItem"):setScale(1.1)
        end,function ( )
            ccui.Helper:seekWidgetByName(item,"gameItem"):setScale(1.0)
        end)

        for i = 1, model.room:len() do
            local users_num = ccui.Helper:seekWidgetByName(item,"users_num")
            users_num:setString("----")
        end
    end
end


function HallView:initChangciInfoNew_vertical(model)
    self.listView:setVisible(false)
    self.listView_vertical:setVisible(true)
    self.listView_vertical:removeAllChildren()

    self.listItem_vertical = HallItem.new({type = 2}):getUI()
    local roomConfigArr  = Cache.DDZconfig:getRoomConfigByType(Cache.DDZDesk.enterRef)
    self.listView_vertical:setItemModel(self.item_vertical)
    self.listView_vertical:setBounceEnabled(false)

    local len = 0
    local count = 0

    if #roomConfigArr > 6 then self.listView_vertical:setClippingEnabled(true) end
    
    for index = 1, #roomConfigArr do
        count = count + 1
        local info = roomConfigArr[index]
        local item = self.listView_vertical:getItem(index -1)
        if math.mod(len,3) == 0 then
            self.listView_vertical:pushBackDefaultItem()
        end
        len = len+1
        local layout_item = self.listView_vertical:getItem(math.floor((len-1)/3))
        layout_item:setVisible(true)
        local item = self.listItem_vertical:clone()
        item:setVisible(true)
        item:setPosition(math.mod(len-1,3)*(item:getContentSize().width + 70),0)
        layout_item:addChild(item)
        
        local users_num = ccui.Helper:seekWidgetByName(item,"users_num")
        users_num:setString(Util:getFormatString(info.cur_online))
        ccui.Helper:seekWidgetByName(item,"base_num"):setString(info.base_chip)
        local limit_num = ccui.Helper:seekWidgetByName(item,"limit_num")
        limit_num:setString(info.carry_desc)
        item:setTouchEnabled(false)
        if info.disable == 1 then
            ccui.Helper:seekWidgetByName(item,"gameItem_vertical"):setTouchEnabled(false)  
            ccui.Helper:seekWidgetByName(item,"gameItem_vertical"):loadTextureNormal(GameRes.game_item_normal,ccui.TextureResType.plistType)
            ccui.Helper:seekWidgetByName(item,"lock"):setVisible(true)
            ccui.Helper:seekWidgetByName(item,"base_layer"):setVisible(false)
            ccui.Helper:seekWidgetByName(item,"limit_layer"):setVisible(false)
        else 
            ccui.Helper:seekWidgetByName(item,"gameItem_vertical"):setTouchEnabled(true)  
            ccui.Helper:seekWidgetByName(item,"lock"):setVisible(false)
            ccui.Helper:seekWidgetByName(item,"base_layer"):setVisible(true) 
            ccui.Helper:seekWidgetByName(item,"limit_layer"):setVisible(true)  
      
            if info.room_type == 3 then
                ccui.Helper:seekWidgetByName(item,"gameItem_vertical"):loadTexture(GameRes.game_item_noRander,ccui.TextureResType.plistType)
                -- ccui.Helper:seekWidgetByName(item,"gameItem_vertical"):loadTexturePressed(GameRes.game_item_noRander,ccui.TextureResType.plistType)
                ccui.Helper:seekWidgetByName(item,"base_num"):setFntFile(GameRes.game_hall_font_noRander)
                ccui.Helper:seekWidgetByName(item,"user_num_img"):loadTexture(GameRes.num_icon_noRander,ccui.TextureResType.plistType)
                ccui.Helper:seekWidgetByName(item,"base_img"):loadTexture(GameRes.game_hall_difen_noRander, ccui.TextureResType.plistType)
                ccui.Helper:seekWidgetByName(item,"limit_icon"):loadTexture(GameRes.poker_icon_noRander, ccui.TextureResType.plistType)
                ccui.Helper:seekWidgetByName(item,"hot_tag"):setVisible(true)
                ccui.Helper:seekWidgetByName(item,"room_group"):setVisible(false)
                ccui.Helper:seekWidgetByName(item,"room_name"):setVisible(true)
                ccui.Helper:seekWidgetByName(item,"room_name"):setString(info.room_name)
                users_num:setColor(cc.c3b(141,220,251))
                limit_num:setColor(cc.c3b(141,220,251))
            else
                ccui.Helper:seekWidgetByName(item,"gameItem_vertical"):loadTexture(GameRes.game_item_normal,ccui.TextureResType.plistType)
                -- ccui.Helper:seekWidgetByName(item,"gameItem_vertical"):loadTexturePressed(GameRes.game_item_normal,ccui.TextureResType.plistType)
                ccui.Helper:seekWidgetByName(item,"base_num"):setFntFile(GameRes.game_hall_font_normal)
                ccui.Helper:seekWidgetByName(item,"user_num_img"):loadTexture(GameRes.num_icon_normal,ccui.TextureResType.plistType)
                ccui.Helper:seekWidgetByName(item,"base_img"):loadTexture(GameRes.game_hall_difen_normal, ccui.TextureResType.plistType)
                ccui.Helper:seekWidgetByName(item,"limit_icon"):loadTexture(GameRes.poker_icon_normal, ccui.TextureResType.plistType)
                ccui.Helper:seekWidgetByName(item,"hot_tag"):setVisible(false)
                ccui.Helper:seekWidgetByName(item,"room_group"):setVisible(true)
                ccui.Helper:seekWidgetByName(item,"room_name"):setVisible(false)
                users_num:setColor(cc.c3b(90,224,155))
                limit_num:setColor(cc.c3b(90,224,155))
            end
        end   
        if self.quickRoomId and info.room_id == self.quickRoomId then
            local armatureDataManager = ccs.ArmatureDataManager:getInstance()
            armatureDataManager:addArmatureFileInfo(GameRes.verticalItemSelected)
            self.verticalItemAni = ccs.Armature:create("verticalItemSelected")
            self.verticalItemAni:getAnimation():playWithIndex(0)
            local size = item:getSize()
            self.verticalItemAni:setPosition(size.width/2,size.height/2)
            ccui.Helper:seekWidgetByName(item,"gameItem_vertical"):addChild(self.verticalItemAni)
            self.quickName = "经典  "
            if info.room_type == 3 then
                self.quickName = "不洗牌  "
            end
            self.quickName = self.quickName..info.room_name
        end

        addButtonEvent(ccui.Helper:seekWidgetByName(item,"gameItem_vertical"),function ()
            Cache.DDZDesk.enterRef = GAME_DDZ_CLASSIC
            self:gotoClassicGameView(info.room_id) 
            ccui.Helper:seekWidgetByName(item,"gameItem_vertical"):setScale(1.0)
        end,function ()
            ccui.Helper:seekWidgetByName(item,"gameItem_vertical"):setScale(1.1)
        end,function ()
        end,function ()
            ccui.Helper:seekWidgetByName(item,"gameItem_vertical"):setScale(1.0)
        end)

        for i = 1, model.room:len() do
            local v = model.room:get(i)
            if v.room_id == info.room_id then
                info.cur_online = v.cur_online or 0
                local users_num = ccui.Helper:seekWidgetByName(item,"users_num")
                users_num:setString(Util:getFormatString(info.cur_online))
            end
        end
    end
end


function HallView:quickStartGame()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击斗地主经典场快速开始") end
    GameNet:send({cmd=CMD.QUICK_START,body={play_mode=1},callback=function(rsp)
        local model = rsp.model
        if model then
            if model.room_id < 0 then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[3]})
                if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
                    qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                        qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})--点击上报
                        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
                    end})
                end
            else
                self:gotoClassicGameView(model.room_id)
            end
        else
            -- loga("快速开始获取失败！")
        end
    end})
end

--只有经典场进场金币检测
function HallView:goldCheckRequest(roomId)
    qf.event:dispatchEvent(ET.GOLD_CHECK, roomId)
end

function HallView:gotoClassicGameView(roomid)
    if self.isClick then return end
    self.isClick = true

    Util:delayRun(0.5, function()
        self.isClick = false
    end)
    
    -- 牌桌检测
    qf.event:dispatchEvent(ET.ROOM_CHECK, {roomid = roomid, desk_mode = GAME_DDZ_CLASSIC})
end

function HallView:ReturnMainView( ... )
    ModuleManager.DDZhall:remove()
    ModuleManager.gameshall:initModuleEvent()
    ModuleManager.gameshall:show()
    ModuleManager.gameshall:showReturnHallAni()
    qf.platform:umengStatistics({umeng_key = "GameToHall"})--点击上报
end

function HallView:goBcak()
    -- self.root:runAction(cc.Sequence:create(cc.FadeTo:create(0.3,0)))
    -- self:runAction(cc.Sequence:create(
    --     cc.MoveBy:create(0.1,cc.p(733,0)),
    --     cc.CallFunc:create(function ( sender )
    --         Cache.user:updateLoginTipPopValue(true)
    --         self:ReturnMainView()
    --    end)))
    -- ModuleManager.gameshall:show()
    self:ReturnMainView()
end

function HallView:firstPayBtnAni(  )
    if not Cache.user.firstChargeConfInfo  or not Cache.user.firstChargeConfInfo.hasEntryControl or not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then 
        ccui.Helper:seekWidgetByName(self.topTools,"shouChong"):setVisible(false)
        return 
    end
    self.shouChong = ccui.Helper:seekWidgetByName(self.root,"shouChong")
    self.shouChong:setVisible(true)
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.firstPayAni)
    local firstPayBtnAni = ccs.Armature:create("firstPay")
    firstPayBtnAni:setPosition(firstPayBtnAni:getContentSize().width/2,firstPayBtnAni:getContentSize().height/2 + 10)
    self.shouChong:addChild(firstPayBtnAni,0)
    firstPayBtnAni:getAnimation():playWithIndex(0)
    
    self.shouChong.tag = 7605
    -- table.insert(self.upAreaBtn_hall, self.shouChong)

    addButtonEvent(self.shouChong, function (sender)
        firstPayBtnAni:setScale(1.0)
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅新手礼包") end
        qf.event:dispatchEvent(ET.SHOW_FIRSTRECHARGE_POP)
        qf.platform:umengStatistics({umeng_key = "firstRecharge"})--点击上报
    end, function ()
        firstPayBtnAni:setScale(1.1)
    end, nil, function ()
        firstPayBtnAni:setScale(1.0)
    end)
end

-- 初始化顶部栏按钮位置
-- function HallView:initUpBtnTable(...)--初始化上部按钮的位置
--     if self.upAreaBtn_hall and #self.upAreaBtn_hall >= 1 then 
--         for i = 1, #self.upAreaBtn_hall do
--             local size = self.upAreaBtn_hall[i]:getContentSize()
--             self.upAreaBtn_hall[i]:setPositionX(140 + (i - 1) * 175 + 178 - size.width)
--             if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
--                 self.upAreaBtn_hall[i]:setVisible(false)
--                 self.upAreaBtn_hall[i]:setTouchEnabled(false)
--             else
--                 self.upAreaBtn_hall[i]:setVisible(true)
--                 self.upAreaBtn_hall[i]:setTouchEnabled(true)
--             end
--         end
--     end
-- end


function HallView:delayRun(time, cb)
    if time == nil or cb == nil then return end
    self:runAction(
        cc.Sequence:create(cc.DelayTime:create(time), 
            cc.CallFunc:create(function() 
                cb()
            end)
        ))
end

function HallView:getRoot() 
    return LayerManager.ChoseHallLayer
end

function HallView:initMenu(  )
    self.menu = HallMenuComponent.new({return_cb = function (  )
        self:goBcak()
    end})
    self.root:addChild(self.menu, 100)
end

return HallView
