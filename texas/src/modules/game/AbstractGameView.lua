
--[[
牌桌基类：View
--]]

local AbstractGameView = class("AbstractGameView", qf.view)
local Myself        = import(".components.user.Myself")
local User          = import(".components.user.User")
local RememberCard  = import(".components.card.RememberCard")
local Gameanimation = import(".components.animation.Gameanimation")
local BeautyEnterAnimat = import(".components.BeautyEnterAnimat")
local GameAnimationConfig = import(".components.animation.AnimationConfig")
local InteractPhizManager = import("src.modules.global.components.InteractPhizManager")
local Card = import(".components.card.Card")
local UserInfo = import(".components.userInfo")
local newUserInfo = import(".components.newUserInfo")
local Chat          = import(".components.Chat")
local GameRule = import(".components.GameRule")
local cardManage = import(".components.card.CardManage")
local GameExit = import(".components.GameExit")

AbstractGameView.TAG = "AbstractGameView"
function AbstractGameView:ctor( params )
    AbstractGameView.super.ctor(self, params)
    self.isshowGameInfo = true
	self:init(params)
end

function AbstractGameView:init( params )
	self:initData(params)

	self:initUI(params)

	self:initClick(params)

    self:showReview()
    
    self:fullScreenAdaptive()
	
	Util:delayRun(0.2, function()
        if isValid(self) then
            self:initCompontent()
        end
	end)
	
	Util:registerKeyReleased({self = self,cb = function ()
        self:quitRoomAction()
	end})
end

function AbstractGameView:initData( params )
	self.winSize = cc.Director:getInstance():getWinSize()
    self._users             = {}
    self.descLayerTable = {}
end

function AbstractGameView:initUI( params )
	-- body
	self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(DDZ_Res.gameViewJson)
    self:addChild(self.gui)
    self._device_layer = ccui.Helper:seekWidgetByName(self.gui,"device_layer")--设备信息层
    self.back = ccui.Helper:seekWidgetByName(self.gui,"back")--左上角下拉按钮
    self.menuItem = ccui.Helper:seekWidgetByName(self.gui,"quititemP")--列表模板
    self.menuP = ccui.Helper:seekWidgetByName(self.gui,"quit_panel")--列表层
    self.game_info = ccui.Helper:seekWidgetByName(self.gui,"game_info")             --牌桌底牌
    self.game_info:setVisible(false)
    self.diFen = ccui.Helper:seekWidgetByName(self.game_info,"difen_txt")             --牌桌的底分
   
    self.bottomTShi = ccui.Helper:seekWidgetByName(self.gui,"Panel_bottm_tishi") --牌桌下方提示框      Image_ti_shi1,Image_ti_shi2,Image_ti_shi3
    self.chatBtn = ccui.Helper:seekWidgetByName(self.gui,"chat")                    --牌桌右下方的聊天
    self.chatBtn:setVisible(false)

    -- 托管部分
    self.tuoGuanP  = ccui.Helper:seekWidgetByName(self.gui,"Panel_tuo_guan")    --托管界面
    self.tuoGuanBg = ccui.Helper:seekWidgetByName(self.tuoGuanP,"Image_tuo_guan_bg") -- 托管背景
    self.tuoGuanBtn = ccui.Helper:seekWidgetByName(self.gui,"tuoguan_btn") -- 托管按钮

    self.settingBtn = ccui.Helper:seekWidgetByName(self.gui,"btn_setting") -- 设置按钮
    self.taskBtn = ccui.Helper:seekWidgetByName(self.gui,"btn_task") -- 任务按钮
    self.btn_gameTask = ccui.Helper:seekWidgetByName(self.gui, "btn_gameTask")  --玩局有奖按钮
    self.btn_gameTask:setVisible(false)

    --底部提示框文字
    self.bottomTShiTxt1  = ccui.Helper:seekWidgetByName(self.bottomTShi,"Image_ti_shi1")    --当前没有大过上家的牌
    self.bottomTShiTxt2  = ccui.Helper:seekWidgetByName(self.bottomTShi,"Image_ti_shi2")    --您选择的牌不符合规则

    --游戏开始
    self.startP = ccui.Helper:seekWidgetByName(self.gui,"startP")--开始层
    self.showCardStartBtn = self.startP:getChildByName("start_showcard_btn") --明牌开始
    self.startBtn = self.startP:getChildByName("start_btn") --开始游戏

    --游戏结束
    self.newEndP = ccui.Helper:seekWidgetByName(self.gui,"newEndP")--开始层
    self.newEndP_showCardStartBtn = self.newEndP:getChildByName("start_showcard_btn") --明牌开始
    self.newEndP_startBtn = self.newEndP:getChildByName("start_btn") --开始游戏
    self.newEndP_calculateBtn = self.newEndP:getChildByName("calculate_btn") --游戏结算

    --底牌
    self.diCardLayer = ccui.Helper:seekWidgetByName(self.gui,"di_card_layer") --底牌层

    self.matchingTips = self.gui:getChildByName("matching_layer")

    local card_record = ccui.Helper:seekWidgetByName(self.gui,"Card_record")

    self.beiDescLayer = ccui.Helper:seekWidgetByName(self.gui,"bei_desc")
    self.classicDeskInfo = ccui.Helper:seekWidgetByName(self.gui,"classic_desk_info")

    self.beiTouchLayer = ccui.Helper:seekWidgetByName(self.gui,"bei_touch_layer")
    self.beiTouchLayer:setVisible(false)

    self.exchangeDeskBtn = ccui.Helper:seekWidgetByName(self.gui,"exchangeBtn")
    self.exchangeDeskBtn:setVisible(false)
    self.sendCard_node = ccui.Helper:seekWidgetByName(self.gui, "sendCard_node")
    self.jiaBeiFntTxt_node = self.sendCard_node:clone()
    self.gui:addChild(self.jiaBeiFntTxt_node, 100)
    self.jiaBeiFntTxt_node:setPosition(self.sendCard_node:getPosition())

    self.btn_beishu = ccui.Helper:seekWidgetByName(self.gui, "btn_beishu") --倍数按钮
    self.btn_beishu:setVisible(false)
    self.img_game_info_bg = ccui.Helper:seekWidgetByName(self.gui, "img_game_info_bg") --牌桌费率详情
    self.betNum = ccui.Helper:seekWidgetByName(self.btn_beishu,"txt")             --牌桌的倍数

    self.end_ani = ccui.Helper:seekWidgetByName(self.gui,"gameover_ani_node") --输了、赢了动画

    self:initBeiInfo()
    self.classicDeskInfo:setVisible(false)
    self:setGameInfoVisible(false)
    ccui.Helper:seekWidgetByName(self.gui,"deskname"):setVisible(false)
end

function AbstractGameView:initClick( params )
    loga("AbstractGameView   initClick")
	-- body
	addButtonEventMusic(self.back,DDZ_Res.all_music["BtnClick"],function( ... )--下拉列表按钮
        if self.finishInit then
            self.menuP:setVisible(true)
        end
    end)
    
    --点击空白
    addButtonEventNoVoice(self.gui,function( ... )
        self:bankClicked()
    end)
    
    --点击取消托管的空白
    addButtonEventNoVoice(self.tuoGuanP,function( ... )
        self:bankClicked()
    end)

    --聊天
    addButtonEvent(self.chatBtn,function ( )
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击斗地主聊天") end
        if not isValid(self._chat) then
            self._chat = Chat.new({view = self})
            self:addChild(self._chat, 300)
        end
        self._chat:show()
        if FULLSCREENADAPTIVE then
            self._chat:setPositionX(-(self.winSize.width -1980)/2)
        end
    end)

    --任务
    addButtonEventMusic(self.taskBtn,DDZ_Res.all_music["BtnClick"],function( ... )
        qf.event:dispatchEvent(ET.SHOW_REWARD_VIEW)
    end)
    --设置
    addButtonEventMusic(self.settingBtn,DDZ_Res.all_music["BtnClick"],function( ... )
        qf.event:dispatchEvent(ET.SHOW_SETTING_VIEW)
    end)
end

--过审修改
function AbstractGameView:showReview()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        -- self.chatBtn:setVisible(false)
    end
end

function AbstractGameView:getRoot()
    return LayerManager.GameLayer
end

--初始化倍数详情
function AbstractGameView:initBeiInfo()
    local index = 1
    local nameInfo = Cache.DDZDesk.enterRef ~= GAME_DDZ_MATCH and DDZ_TXT.gameBeiInfo or DDZ_TXT.matchGameBeiInfo
    for i = 1, 10 do
        local subDescLayer = self.beiDescLayer:getChildByName("desc_" .. i)
        if i ~= 6 or Cache.DDZDesk.enterRef ~= GAME_DDZ_MATCH then
            subDescLayer:setVisible(true)
            self.descLayerTable[i] = subDescLayer
            subDescLayer:getChildByName("name"):setString(nameInfo[index])
            index = index + 1
        else
            subDescLayer:setVisible(false)
        end
    end
end

--更新倍率详情
function AbstractGameView:updateMySelfBeiDetailInfo(paras)
    loga("更新游戏内倍率信息\n" .. pb.tostring(paras))
    if paras == nil then return end
    local beiDetailInfo = Cache.DDZDesk:getBeiDetailInfo()
    self.betNum:setString(Cache.DDZDesk.multipleInfo.multiple < 1 and 1 or Cache.DDZDesk.multipleInfo.multiple)

    local paras = {
        beiDetailInfo.init_multi ,
        beiDetailInfo.show_multi ,
        beiDetailInfo.qdz_multi ,
        beiDetailInfo.dipai_multi ,
        beiDetailInfo.bomb_multi ,
        beiDetailInfo.spring_multi ,
        beiDetailInfo.common_multi,
        beiDetailInfo.landloard_increase or beiDetailInfo.landlord_multi,
        beiDetailInfo.farmer_increase or beiDetailInfo.farmers_multi,
        beiDetailInfo.multiple or beiDetailInfo.total_multi,
    }

    for k,v in pairs(self.descLayerTable) do
        v:getChildByName("value"):setString(paras[k])
    end
end

--初始化牌桌信息
function AbstractGameView:initDeskDesc()
    ccui.Helper:seekWidgetByName(self.gui,"deskname"):setVisible(false)
    self.classicDeskInfo:setVisible(false)
end

--点击空白事件
function AbstractGameView:bankClicked( ... )
    self.menuP:setVisible(false)
    self.beiDescLayer:setVisible(false)
    if self._users and self._users[Cache.user.uin] then
        self._users[Cache.user.uin]:setCardsViewBySize()
        -- if self.clickGui then
        --     self.clickGui = nil
        --     self._users[Cache.user.uin]:setCardsViewBySize()
        -- else
        --     self.clickGui = true
        --     self:delayTimeRun(0.5,function( ... )
        --         self.clickGui = nil
        --     end)
        -- end
    end
    if self._card_record then
       self._card_record:clickBank()
    end
end

function AbstractGameView:quitRoomAction()

end

--换桌按钮逻辑
function AbstractGameView:updateExchangeDeskInfo()
	self.exchangeDeskBtn:setVisible(false)
end


----------------延时加载的UI资源-----------------


function AbstractGameView:initCompontent()
    self:initCardRecord()
    self:initAnimation()
    self:showDeviceStatus()
    self:initDiCard()
    self:updateMySelfInfo()
	self:initChat()
	self:initMenu()
    self.finishInit = true

    if Cache.DDZDesk.status >= GameStatus.FAPAI then
        self.img_game_info_bg:setVisible(false and self.isshowGameInfo)
    else
        self.img_game_info_bg:setVisible(true and self.isshowGameInfo)
    end

    qf.event:dispatchEvent(ET.CMD_GAME_TASK_REQ)
end

function AbstractGameView:initCardRecord()
    if not isValid(self._card_record) then
        local card_record = ccui.Helper:seekWidgetByName(self.gui,"Card_record")
        self._card_record  = RememberCard.new({node = card_record,view = self})
    end
end

--初始化动画类
function AbstractGameView:initAnimation()
    if not self.Gameanimation then
        self.animation_layout  =  cc.Layer:create()
        self:addChild(self.animation_layout)
        self.animation_layout:setZOrder(101)
        self.Gameanimation =  Gameanimation.new({view=self,node=self.animation_layout})  --初始化动画
    end
end

--显示电池电量和时间
function AbstractGameView:showDeviceStatus( ... )
    self.powerBar = ccui.Helper:seekWidgetByName(self._device_layer,"powerbar")
    self.timeTxt = ccui.Helper:seekWidgetByName(self._device_layer,"nowtime")
    self.signalImg = ccui.Helper:seekWidgetByName(self._device_layer,"signal")
    local cb = function ( power,time,signal )
        self.powerBar:setPercent(power)
        self.timeTxt:setString(time)
        self.signalImg:setVisible(true)
        if signal<=0 then
            self.signalImg:setVisible(false)
        elseif signal>3 then
            self.signalImg:loadTexture(string.format(DDZ_Res.signalImg,3),ccui.TextureResType.plistType)
        elseif signal>1 then
            self.signalImg:loadTexture(string.format(DDZ_Res.signalImg,2),ccui.TextureResType.plistType)
        else
            self.signalImg:loadTexture(string.format(DDZ_Res.signalImg,1),ccui.TextureResType.plistType)
        end
    end
    self.deviceStatus = CommonWidget.DeviceStatus.new({layer = self._device_layer,cb =cb,node = self })
    self.deviceStatus:startDeviceStatusMonitor()  --开始检测设备状态(电池电量, 网络信号)
end

--初始化地主三张牌
function AbstractGameView:initDiCard()
    if not self.DiCard then self.DiCard = {} end
    if #self.DiCard >= 3 then return end

    for k=1,3 do 
        local card = self.DiCard[k]
        if not isValid(card) then
            card = Card.new()
            self.diCardLayer:addChild(card)
        end
        card:setScale(0.5)
        card:setPosition(70+(k-1)*95,card:getContentSize().height/4+10)
        self.DiCard[k] = card
    end
end

--设置桌面信息(底分、倍数)
function AbstractGameView:setDeskInfo()
   
end

--初始化下拉列表
function AbstractGameView:initMenu()
    
end

--在无进桌数据时刷新自身数据
function AbstractGameView:updateMySelfInfo()

end

-- 初始化聊天
function AbstractGameView:initChat()
    if not isValid(self._chat) then
        self._chat = Chat.new({view = self})
        self:addChild(self._chat, 300)
    end
end

--iphoneX适配
function AbstractGameView:fullScreenAdaptive( ... )
	-- body
	  if FULLSCREENADAPTIVE and not self.haveSetDaptive then
		  self:setPositionX(self.winSize.width/2-1920/2)
		  self.menuP:setPositionX(self.menuP:getPositionX()-(self.winSize.width-1920)/4)
		  self.back:setPositionX(self.back:getPositionX()-(self.winSize.width-1920)/4)
		  self._device_layer:setPositionX(self._device_layer:getPositionX()-(self.winSize.width-1920)/4)
		  if self._chat then
			  self._chat:setPositionX(self._chat:getPositionX()-(self.winSize.width-1920)/4)
		  end
	  end
  end


----------------延时加载的UI资源--end---------------




-------------------牌桌数据信息-------------------------------
--设置地主额外获得的三张牌
function AbstractGameView:setDiCard()
    self:initDiCard()
    local cards = Cache.DDZDesk.commonCard
    if not cards or #cards<1 then
        for k,v in pairsByKeys(self.DiCard)do 
            v:removeAllChildren()
            v:showBackCard()
        end
        self.diCardLayer:getChildByName("bet"):setVisible(false)
        self.diCardLayer:getChildByName("bei_bg"):setVisible(false)
        return 
    else
        for k,v in pairsByKeys(cards)do 
            self.DiCard[k]:removeAllChildren()
            self.DiCard[k]:setCardValue(v,true)
        end
        --播放底牌动画
        self:playDiCardAni()
    end

    self.game_info:setVisible(true)
end

--播放底牌动画
function AbstractGameView:playDiCardAni()
    if not Cache.DDZDesk.multipleInfo.dipai_multi or not Cache.DDZDesk.multipleInfo.dipai_multi_type or Cache.DDZDesk.multipleInfo.dipai_multi < 1 then
        self.diCardLayer:getChildByName("bet"):setVisible(false)
        self.diCardLayer:getChildByName("bei_bg"):setVisible(false)
        return
    end
    self.diCardLayer:getChildByName("bet"):setVisible(true)
    self.diCardLayer:getChildByName("bet"):loadTexture(string.format(DDZ_TXT.hand_card_type_bei_img, Cache.DDZDesk.multipleInfo.dipai_multi), ccui.TextureResType.plistType)

    self.diCardLayer:getChildByName("bei_bg"):setVisible(true)
    self.diCardLayer:getChildByName("bei_bg"):setScale(0)
    self.diCardLayer:getChildByName("bei_bg"):getChildByName("txt"):setString(string.format(DDZ_TXT.HoleCardsType[Cache.DDZDesk.multipleInfo.dipai_multi_type], Cache.DDZDesk.multipleInfo.dipai_multi))
    self.diCardLayer:getChildByName("bei_bg"):runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.3, 1),
            cc.DelayTime:create(3),
            cc.CallFunc:create(function (sender)
                sender:setVisible(false)
                sender:setScale(0)
            end)
        ))
end

-------------------牌桌数据信息----end---------------------------




-------------------用户数据信息-------------------------------

--显示用户信息
function AbstractGameView:showUserInfo( paras )
    self.userInfo = PopupManager:push({class = newUserInfo, init_data = paras})
    PopupManager:pop()

    local userInfoView = PopupManager:getPopupWindowByUid(self.userInfo)
    if isValid(userInfoView) then
        userInfoView:updateUserInfo(paras)
    end
end

function AbstractGameView:getUser(i)
    if not i or not self._users then return end
    return self._users[i]
end

--获得对应seat的用户节点
function AbstractGameView:getUserPanel(seat)
    local cut = seat - Cache.user.meIndex
    if cut < 0 then
        cut = 3+cut
    end

    local name = "user_info"
    if cut == 2 then
        name = "user_first"
    end

    if cut == 1 then
        name = "user_second"
    end
    local node = ccui.Helper:seekWidgetByName(self.gui,name)
  
    return node,cut
end

-------------------用户数据信息--end-----------------------------




-------------------proto协议信息处理-------------------------------
--玩家进桌
function AbstractGameView:enterRoom(opuin, isReStart)
    -- loga("用户进桌 op_uin=" .. parameters.uin .. "   " .. pb.tostring(parameters))
    --游戏刚开始和断线重连
    if isReStart then self:cleanSendCardNode() end
    self:initCardRecord()
    self:updateTuoguangDeskInfo()
    
    if Cache.DDZDesk.status >= GameStatus.FAPAI then
        self.img_game_info_bg:setVisible(false and self.isshowGameInfo)
    else
        self.img_game_info_bg:setVisible(true and self.isshowGameInfo)
    end
    if opuin == Cache.user.uin or isReStart then
        if Cache.DDZDesk.status ~= GameStatus.READY then
            self.startP:setVisible(false)
        end
        Cache.DDZDesk:clearChat()
        self.allOutNum = 0
        --清理牌桌内已不存在的人员
        for k,v in pairs(self._users) do
            if k ~= Cache.user.uin then
                v:quitRoom(0)
            end
        end
        for k,v in pairs(Cache.DDZDesk._player_info) do
            if k == Cache.user.uin  then
                self.outUin = {}
                local info_node = ccui.Helper:seekWidgetByName(self.gui,"user_info")
                if not isValid(self._myself) then
                    self._myself    = Myself.new({node = info_node,view=self})
                end
                self._myself:clear()
                self._myself:show(0.2)
                self._users[k]  = self._myself
                if v.status == 1020 then
                    self._users[k]:ready()
                end
                self._users[k]:showAutoImg(v.isauto)
                self._users[k]:reconnect()
            else
                local user_node    = self:getUserPanel(v.seat_id)
                if user_node then
                    user_node:setVisible(true)
                    local user         = User.new({node = user_node,uin=v.uin,view=self})
                    self._users[v.uin] = user
                    user:clear()
                    user:show(0.2)
                    if v.status == 1020 then
                        self._users[k]:ready()
                    end
                    self._users[k]:showAutoImg(v.isauto)
                end
            end
            self:resetUserStatus(self._users[k], v)
        end
        if Cache.DDZDesk.status ~= GameStatus.READY then
            self:setDiCard()
        end
        self:reconnect()

        if Cache.DDZDesk.now_max_cards_uin~=Cache.user.uin and Cache.DDZDesk.now_max_cards and #Cache.DDZDesk.now_max_cards>0 then
            self._users[Cache.user.uin].CardView:clearOtherCards()
            self._users[Cache.user.uin].CardView:getAllCanOutCards(Cache.DDZDesk.now_max_cards,DDZ_cardManage:getChooseCardsType(self:assembleCards(Cache.DDZDesk.now_max_cards)))
        end
        -- self:setDeskInfo()
        -- self:initDeskDesc()
        self._card_record:showCardRemember()
    else
        local item = Cache.DDZDesk._player_info[opuin]
        self._users = self._users or {}
        if item then
            local user_node = self:getUserPanel(item.seat_id)
            user_node:setVisible(true)
            local user = self._users[item.uin]
            if not user then
                user = User.new({node = user_node,uin=item.uin,view=self})
                self._users[item.uin] = user
                user:show(0.2)
                user:clear()
            else
                user:show(0.2)
                user:clear()
            end
            user:reconnect(item)
            user:updateAutoStatus()
            self:resetUserStatus(user, item)
            if item.status == 1020 then
                user:ready()
            end
        end
    end
    self:dealUsersForNotInDesk()
    
    if Cache.DDZDesk.status >= GameStatus.FAPAI then
        self:matchSuccess()
    end

    if table.nums(Cache.DDZDesk._player_info) >= 3 then  --断线重连时控制聊天按钮的显示
        self.chatBtn:setVisible(true)
    else
        self.chatBtn:setVisible(false)
    end
end

function AbstractGameView:cleanSendCardNode()
    self.sendCard_node:removeAllChildren()

    for k,v in pairs(Cache.DDZDesk._player_info) do
        if isValid(self._users[k]) then
            self._users[k].sendcard_nodes = {}
            self._users[k].isShowCardAni = false
            if self._users[k].CardView then
                self._users[k].CardView.isShowCardAni = false
            end
        end
    end
end

function AbstractGameView:assembleCards(cards)
    local valueId = 0
    local cardsTable = {}
    for k,v in pairs(cards)do
        local syscard = {}
        local i,t = math.modf(v/4)
        local point = i + 3
        local color = math.fmod(v, 4)
        syscard.value = v
        syscard.valueId = valueId
        syscard.cardvalue = point
        syscard.color = color
        valueId = valueId + 1
        table.insert(cardsTable,syscard)
    end
    return cardsTable
end

--匹配成功(不管是经典场还是比赛场都可以)
function AbstractGameView:matchSuccess()
    self.startP:setVisible(false)
    self.matchingTips:setVisible(false)
    self:setGameInfoVisible(true)
end

--重新设置玩家的状态
function AbstractGameView:resetUserStatus(userNode, v)
    if Cache.DDZDesk.status == GameStatus.CALL_POINT and Cache.DDZDesk.next_uin ~= v.uin then
        if v.call_score ~= -1 then
            userNode:showCallPoints(v.call_score)
        end
    elseif Cache.DDZDesk.status == GameStatus.CALL_DOUBLE or Cache.DDZDesk.status == GameStatus.INGAME then
        if v.call_multiple ~= -1 then
            userNode:showCallDoubleNetReconnect(v.call_multiple)
        end
    end
    if Cache.DDZDesk.status == GameStatus.INGAME or Cache.DDZDesk.status == GameStatus.CALL_DOUBLE then
        userNode:changeHeadType(1,true)--头像变回去
    end
        
    if Cache.DDZDesk.status == GameStatus.INGAME and Cache.DDZDesk.now_max_cards_uin == v.uin and #Cache.DDZDesk.now_max_cards>0 then
        userNode:showOutCard(Cache.DDZDesk.now_max_cards,DDZ_cardManage:getChooseCardsType(self:assembleCards(Cache.DDZDesk.now_max_cards)))
    end

    if Cache.DDZDesk.status == GameStatus.INGAME then
        userNode:setCardNumBgVisible(true)
    end
end

--清理因再来一局时用户的不在桌上仍然在users数据信息里
function AbstractGameView:dealUsersForNotInDesk()
    local inGameUser = {}
    for k,v in pairs(self._users) do
        if k ~= Cache.user.uin then 
            local hasInDesk = 0
            for j,v in pairs(Cache.DDZDesk._player_info) do 
                if j == k and hasInDesk == 0 then
                    hasInDesk = 1
                end
            end
            if hasInDesk == 0 then   
            else
                inGameUser[k] = v
            end
        else
            inGameUser[k] = v
        end
    end 
	self._users = inGameUser
end

--更新托管按钮的显示和隐藏
function AbstractGameView:updateTuoguangDeskInfo()
    if Cache.DDZDesk.status >= GameStatus.FAPAI then
        self.tuoGuanBtn:setVisible(true)
        if Cache.DDZDesk._player_info[Cache.user.uin].isauto then
            self.tuoGuanBtn:loadTextureNormal(DDZ_Res.img_tuoguanBtn[2], ccui.TextureResType.plistType)
        else
            self.tuoGuanBtn:loadTextureNormal(DDZ_Res.img_tuoguanBtn[1], ccui.TextureResType.plistType)
        end
    else
        self.tuoGuanBtn:setVisible(false)
    end
end


--用户明牌 cmd
function AbstractGameView:userShowCard(model)
    --如果有多个，则间隔一段时间播放音效
    for i=1, model.show_cards:len() do
        local info = model.show_cards:get(i)
        if self._users[info.uin] then
            self._users[info.uin]:showLightCardTips()

            if info.uin == Cache.user.uin then
                self:showMultiAction(info.show_multi)
            end
        end
        self:delayTimeRun(0.06, function ( ... )
            DDZ_Sound:playSoundGame(DDZ_Sound.MINGPAI,Cache.DDZDesk._player_info[info.uin].sex)
            local cardTable = Cache.DDZDesk._player_info[info.uin].remain_cards
            table.sort(cardTable,function( a,b )
                return a<b 
            end)

            if self._users[info.uin] then
                self._users[info.uin]:ShowAllCards(cardTable)
            end
        end)
    end
end

--用户准备 cmd
function AbstractGameView:userReady(model)
	if model == nil then return end
    if self._users[model.uin] then
        self._users[model.uin]:ready()
    end
end

--更新托管状态
function AbstractGameView:updateUserAutoPlay(model)
    if model.uin == Cache.user.uin then
        self.tuoGuanBtn:setVisible(true)
        self.tuoGuanBtn:loadTextureNormal(DDZ_Res.img_tuoguanBtn[2], ccui.TextureResType.plistType)
    end
    self._users[model.uin]:showAutoImg(model.auto == 1)
end

--游戏开始
function AbstractGameView:gameStart( model )
    self:clearGame()
    self.outUin = {}
    self.allOutNum = 0
    self:matchSuccess()
	self.chatBtn:setVisible(true) 

	if table.nums(self._users) ~= 3 then
        self:enterRoom(model, true)
    end
    for k,v in pairs(self._users)do
        v:updateAutoStatus()
        v:sendCards(true)
        v:clearLightCard()
        v:updateChipAndGold()
        v:show(0.2)
    end
    self:setGameInfoVisible(true)
    self:updateExchangeDeskInfo()
    
    self.img_game_info_bg:setVisible(false and self.isshowGameInfo)
end

--抢地主/叫分阶段
function AbstractGameView:showCallPoints( info )
    self._users[info.op_uin]:showCallPoints(info.grab_action)
    if info.grab_action > 1 then
        self:showMultiAction(2)
    end
    if Cache.DDZDesk.enterRef ~= GAME_DDZ_MATCH then
        for k,v in pairsByKeys(self._users) do
            if v.isShowLightCardTips then 
               v.isShowLightCardTips = false
               v.hideLightCardTips()
            end
        end
    end
    if Cache.DDZDesk.status ~= GameStatus.CALL_POINT then
        self.betNum:setString(Cache.DDZDesk.multipleInfo.multiple)
        if Cache.DDZDesk.status == GameStatus.INGAME then 
            for k,v in pairsByKeys(self._users)do
                v:removeTimer()
                if k ~= Cache.user.uin then
                    v:showLightCard()
                else
                    v:removeBtnP()
                end
            end

            if Cache.DDZDesk.enterRef ~= GAME_DDZ_NEWMATCH then
                return
            end
        end
        DDZ_Sound:playSoundGame(DDZ_Sound.GetCard)
        for k,v in pairsByKeys(self._users)do
            if k == Cache.DDZDesk.landlord_uin then
                v:sendCards()
            end
            v:changeHeadType(1)
        end
        self:setDiCard()
    end
end

--加倍阶段
function AbstractGameView:showCallDouble( info )
    self:initCardRecord()
    self.betNum:setString(Cache.DDZDesk.multipleInfo.multiple)
    for k,v in pairs(Cache.DDZDesk.DoubleTable)do
        if Cache.DDZDesk.enterRef ~= GAME_DDZ_MATCH then
            if info.op_uin == k then
                self._users[k]:showCallDouble(v)
                if table.nums(Cache.DDZDesk.DoubleTable) <3 or k == Cache.DDZDesk.landlord_uin then
                    --if v==1 then
                        DDZ_Sound:playSoundGame(DDZ_Sound.JiaBei,Cache.DDZDesk._player_info[k].sex,v)
                    --end
                end
                if info.op_uin == Cache.user.uin and Cache.DDZDesk.DoubleTable[info.op_uin] > 0 then
                    self:showMultiAction(Cache.DDZDesk.DoubleTable[info.op_uin] * 2)
                end
            end
        else
            self._users[k]:showCallDouble(v)
            if table.nums(Cache.DDZDesk.DoubleTable) <3 or k == Cache.DDZDesk.landlord_uin then
                --if v==1 then
                    DDZ_Sound:playSoundGame(DDZ_Sound.JiaBei,Cache.DDZDesk._player_info[k].sex,v)
                --end
            end
        end
    end
    if Cache.DDZDesk.status == GameStatus.INGAME then
        self._card_record:showCardRemember()
        for k,v in pairs(Cache.DDZDesk.DoubleTable)do
            self._users[k]:clearUserTips()
        end
	end
	self:updateTuoguangDeskInfo()
end

--要不起显示
function AbstractGameView:showNotFollowUin( model )
    DDZ_Sound:playSoundGame(DDZ_Sound.YaoBuQi,Cache.DDZDesk._player_info[model.op_uin].sex)
    self._users[model.op_uin]:showNotFollow(true)
    --标识自动不要
    if Cache.DDZDesk.next_auto_buchu == 1 then
        -- self._users[model.op_uin]:showAutoImg(true)
    end
    --删除当前轮第一个人出的扑克
    table.insert(self.outUin,model.op_uin)
    if #self.outUin >= 3 - self.allOutNum then
        self._users[self.outUin[1]].outCardP:removeAllChildren()
        self._users[self.outUin[1]].outCardP:setVisible(false)
        table.remove(self.outUin,1)
    end
end

--玩家出牌
function AbstractGameView:outCards( model )
    --如果牌的类型是-1，则是不要，要不起
    if model and model.card_type == -1 then
        self:showNotFollowUin(model)
        -- return
    end
    
    local valueId = 0
    local cards = {}
    -- if Cache.DDZDesk.time_out_flag == 1 then
    --     self._users[model.uin]:showAutoImg(true)
    -- end
    for k ,v in pairs(self._users)do
        v.doubleTxt:setVisible(false)
    end 
    local uin = Cache.DDZDesk.now_max_cards_uin
    local max_player_info = Cache.DDZDesk._player_info[uin];
    local out_cards = max_player_info.out_cards
    if not max_player_info.out_cards_type then
        local tempCards = {}
        for k, v in pairs(out_cards) do
            local syscard = {}
            local i,t = math.modf(v/4)
            local point = i + 3
            local color = math.fmod(v, 4)
            syscard.value = v
            syscard.valueId = valueId
            syscard.cardvalue = point
            syscard.color = color
            valueId = valueId + 1
            -- local card = {value = v}
            table.insert(tempCards, syscard)
        end
        max_player_info.out_cards_type = DDZ_cardManage:getChooseCardsType(tempCards)
    end
    for k,v in pairs(out_cards) do
        local syscard = {}
        local i,t = math.modf(v/4)
        local point = i + 3
        local color = math.fmod(v, 4)
        syscard.value = v
        syscard.valueId = valueId
        syscard.cardvalue = point
        syscard.color = color
        valueId = valueId + 1
        table.insert(cards,syscard)
    end

    --当前操作者出的牌
    if not model.card_type then 
        model.card_type = DDZ_cardManage:getChooseCardsType(cards)
    end
        --删除当前轮第一个人出的扑克
    if #Cache.DDZDesk._player_info[model.op_uin].remain_cards > 0 and Cache.DDZDesk._player_info[model.op_uin].cards_num<1 then
        self.allOutNum = self.allOutNum + 1
    end
    table.insert(self.outUin,model.op_uin)

    if #self.outUin > 3 - self.allOutNum then
        self._users[self.outUin[1]].outCardP:removeAllChildren()
        self._users[self.outUin[1]].outCardP:setVisible(false)
        table.remove(self.outUin,1)
    end

    --判断自己能出的牌
    if model.op_uin ~= Cache.user.uin then
        self._users[Cache.user.uin].CardView:clearOtherCards()
        self._users[Cache.user.uin].CardView:getAllCanOutCards(out_cards, max_player_info.out_cards_type)
    end
    --出牌动画
    if self._users[model.op_uin] then
        if model.card_type ~= -1 then
            local cardNum = Cache.DDZDesk._player_info[model.op_uin].cards_num
            DDZ_Sound:playSoundGame(DDZ_Sound.OutCard)--播放扑克的大小
            DDZ_Sound:playSoundChuPai(model.card_type,cards[1].cardvalue,Cache.DDZDesk._player_info[model.op_uin].sex)--播放出牌的声音
            
            self._users[model.op_uin]:showOutCard(Cache.DDZDesk._player_info[model.op_uin].out_cards,model.card_type)--显示出的牌
            self._users[model.op_uin]:showAni(model.card_type)--显示出牌的动画

            if Cache.DDZDesk._player_info[model.op_uin].isShowCard and model.op_uin ~= Cache.user.uin then --显示明牌玩家的牌
                local usercards = Cache.DDZDesk._player_info[model.op_uin].remain_cards
                table.sort(usercards,function( a,b )
                    return a<b
                end)
                self._users[model.op_uin]:ShowAllCards(usercards)
            end
            if model.card_type >= 6 and model.card_type ~= 12 then
                self.endTime = 2
            else
                self.endTime = 0
            end

            if model.card_type == DDZ_CardType.cardType_WangZha or model.card_type == DDZ_CardType.cardType_ZhaDan then
                self:showMultiAction(2)
            end
        end
    end
    if Cache.DDZDesk._player_info[Cache.user.uin].use_card_remember == 1 then
        self:initCardRecord()
        self._card_record:updateCardRememberList()
    end
end

--每局结束后动画
function AbstractGameView:gameEndAni( ... )
    self:setGameInfoVisible(false)
end

--下一个玩家
function AbstractGameView:userHandleTurn( timer,player_op_left_time )
    if not timer then timer = 0 end
    for k,v in pairs(self._users)do
        --加倍
        if Cache.DDZDesk.status == GameStatus.CALL_DOUBLE then
            if Cache.DDZDesk:getUserCanCallDoudle(k) == true then
                if timer>0 then
                    self:delayTimeRun(timer,function()
                        local time = timer or 0
                        v:addTimer({passtime=time, leftTime = player_op_left_time})
                        if k ~= Cache.DDZDesk.op_uin then
                            v:clearUserTips()
                        end
                        if Cache.user.uin == k then
                            v:updateJiaBeiP()
                        end
                    end)
                else
                    local time = timer or 0
                    v:addTimer({passtime=time, leftTime = player_op_left_time})
                    if k ~= Cache.DDZDesk.op_uin then
                        v:clearUserTips()
                    end
                    if Cache.user.uin == k then
                        v:updateJiaBeiP()
                    end
                end
            else
                v:removeTimer()
                if Cache.user.uin == k then
                    v:removeBtnP()
                end
                if timer>0 then
                    self:delayTimeRun(timer,function()
                            if k ~= Cache.DDZDesk.op_uin then
                                v:clearUserTips()
                            end
                        end)
                else
                    if k ~= Cache.DDZDesk.op_uin then
                        v:clearUserTips()
                    end
                end
            end
        else
            --叫分和出牌
            if Cache.DDZDesk.next_uin == k then
                if timer>0 then
                    self:delayTimeRun(timer,function()
                        if Cache.DDZDesk.status == GameStatus.CALL_POINT and k == Cache.user.uin then
                            v:showJiaofenP()
                        else
                            v:removeCards()
                        end
                        if k ~= Cache.user.uin or not Cache.DDZDesk._player_info[Cache.user.uin].isauto then 
                            local time = timer or 0
                            v:addTimer({passtime=time, leftTime = player_op_left_time})
                            v:clearUserTips()
                        end  
                    end)
                else
                    if Cache.DDZDesk.status == GameStatus.CALL_POINT and k == Cache.user.uin then
                        v:showJiaofenP()
                    else
                        v:removeCards()
                    end
                    if k ~= Cache.user.uin or not Cache.DDZDesk._player_info[Cache.user.uin].isauto then 
                        local time = timer or 0
                        v:addTimer({passtime=time, leftTime = player_op_left_time})
                        v:clearUserTips()   
                    end 
                end
            else
                v:removeTimer()
                if Cache.user.uin == k then
                    v:removeBtnP()
                end
            end
        end
    end
end

--其他用户退场
function AbstractGameView:quitRoom(uin)
    dump(uin, "其他用户退场")
    if self._users[uin] then
        if Cache.user.uin == uin then
            self:clearDesk()
            if isValid(self._chat) then
                self._chat:setVisible(false)
            end
            self.back:setVisible(false)
            self._users[uin]:quitRoom(0.2)
        else
            self._users[uin]:quitRoom(0.2)
            if Cache.DDZDesk.status == GameStatus.READY then
                self._users[uin] = nil
            end
        end
    
        Cache.DDZDesk._player_info[uin] = nil
    else
        --没有的话，就是说他已经被踢了
        if uin == Cache.user.uin and Cache.DDZDesk.enterRef ~= GAME_DDZ_NEWMATCH then
            --这种只有经典场才会出现
            ModuleManager:remove("game")
            Cache.DDZDesk.startAgain = nil
            ModuleManager.DDZhall:show()
        end 
	end
	if not tolua.isnull(self) then
        self:updateExchangeDeskInfo()
    end
end

--显示托管
function AbstractGameView:showAutoPlayer(ishow)
    if ishow then
        self:bankClicked()
    end
    self.tuoGuanP:setVisible(ishow)
end

--播放春天动画
function AbstractGameView:playSpringAni( ... )
    self:initAnimation()
    self.Gameanimation:play({anim=GameAnimationConfig.SPRINGANIMATION,order=101})
end

function AbstractGameView:playNormalEndAni ( isWin )
    self.end_ani:setVisible(true)

    if Cache.user.uin == Cache.DDZDesk.landlord_uin then
        self.end_ani:loadTexture(isWin and DDZ_Res.end_win_lord or DDZ_Res.end_lose_lord)
    else
        self.end_ani:loadTexture(isWin and DDZ_Res.end_win_farmer or DDZ_Res.end_lose_farmer)
    end

    self.end_ani:setScale(0)
    self.end_ani:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.5, 1),
        cc.DelayTime:create(2),
        cc.CallFunc:create(function ( sender )
            self.end_ani:setVisible(false)
        end)
    ))
end

--显示结束动画
function AbstractGameView:showGameEndAni( iswin )
    self:initAnimation()
    self.Gameanimation:play({anim=iswin and GameAnimationConfig.Ani_GameWin or GameAnimationConfig.Ani_GameFail ,order=101})
end

--显示出牌提示1、当前没有大过上家的牌2、您选择的牌不符合规则3、对家手牌
function AbstractGameView:showOutCardsTips( paras )
    self.bottomTShi:stopAllActions()
    if paras.type ~= 3 then
        self.bottomTShi:runAction(cc.Sequence:create(cc.Show:create(),cc.FadeIn:create(0.5),cc.DelayTime:create(1),cc.FadeOut:create(0.5),cc.Hide:create()))
    else
        self.bottomTShi:runAction(cc.Sequence:create(cc.Show:create(),cc.FadeIn:create(0.5)))
    end
    for i=1,2,1 do
        if i == paras.type then
            self["bottomTShiTxt"..i]:setVisible(true)
        else
            self["bottomTShiTxt"..i]:setVisible(false)
        end
    end
end

-- 收到一条互动表情后播放互动动画 cmd
function AbstractGameView:interactPhizAnimation(model)
	--todo:此处应该判断旁观玩家是否在在桌子里
    local uin = model.from_uin
    local toUin = model.to_uin
    local phizId = model.expression_id
    local fromUser = self:getUserByCache(uin)
    local toUser = self:getUserByCache(toUin)
    if not toUser then return end
    local pos = nil
    local fromScale = nil
    local centerFromUser = nil
    local x ,y
    if fromUser == nil then
        x , y =  cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2
    else
        x , y = fromUser:getPosition()
        x=fromUser:getPositionX()+ccui.Helper:seekWidgetByName(fromUser,"aniP"):getPositionX()+ccui.Helper:seekWidgetByName(fromUser,"aniP"):getContentSize().width/2
        y=fromUser:getPositionY()+ccui.Helper:seekWidgetByName(fromUser,"aniP"):getPositionY()+ccui.Helper:seekWidgetByName(fromUser,"aniP"):getContentSize().height/2
    end
    centerFromUser=cc.p(x,y)

    local centerToUser 
    if toUser == nil then
        x , y =  cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2
    else
        x=toUser:getPositionX()+ccui.Helper:seekWidgetByName(toUser,"aniP"):getPositionX()+ccui.Helper:seekWidgetByName(toUser,"aniP"):getContentSize().width/2
        y=toUser:getPositionY()+ccui.Helper:seekWidgetByName(toUser,"aniP"):getPositionY()+ccui.Helper:seekWidgetByName(toUser,"aniP"):getContentSize().height/2
    
        -- if Cache.DDZDesk.status == GameStatus.INGAME or Cache.DDZDesk.status == GameStatus.CALL_DOUBLE then
        --     y = y + 110
        --     if toUin == Cache.user.uin then
        --         y = y + 80
        --     end
        -- end
    end
    centerToUser=cc.p(x,y)

    local isReverse = true

    local handler = nil
    handler = InteractPhizManager:playArmatureAnimation(centerFromUser, centerToUser, phizId, isReverse)
    if handler then
        for k, v in pairs(handler) do
            self:addChild(v, 21)
        end
    end
end



-------------------proto协议信息处理---end---------------------------




-------------------牌桌的重置、清理及断线重连的处理---------------------------

--重置桌子信息
function AbstractGameView:deskReset()
    self:clearGame()
    self:clearDesk()
end

--重置刚进桌的状态  --新增，待补充，慎重调用
function AbstractGameView:resetForNewStart( ... )
    -- body
    self:bankClicked()
    if self._card_record then
       self._card_record:currentGameOver() 
    end
    self.chatBtn:setVisible(false)

    
end

--重连
function AbstractGameView:reconnect( ... )
    if Cache.DDZDesk.status and Cache.DDZDesk.status ~= GameStatus.READY and Cache.DDZDesk.status ~= GameStatus.NONE then
        for k,v in pairs(self._users) do
            v:reconnect()
        end
        local timer = 0
        if Cache.DDZDesk.player_op_past_time then
            timer = Cache.DDZDesk.player_op_past_time + 1
        end
        qf.event:dispatchEvent(ET.USER_HANDLE_TURN,{player_op_past_time=timer})
    end
    self.betNum:setString(Cache.DDZDesk.multipleInfo.multiple < 1 and 1 or Cache.DDZDesk.multipleInfo.multiple)
end

--清理桌子
function AbstractGameView:clearGame( ... )
    self.betNum:setString(1)
    self:setDiCard()
    for k,v in pairsByKeys(self._users) do
        v:gameStartClear()
        v:clearUserTips()
        v:hideReadyMark()

        if k ~= Cache.user.uin then
            v:quitRoom()
        end
    end
    self.img_game_info_bg:setVisible(true and self.isshowGameInfo)
end

--清理桌面
function AbstractGameView:clearDesk( ... )
    for k,v in pairs(self._users)do
        v:clear(false)
    end
	self.bottomTShi:setVisible(false)	
	self.tuoGuanP:setVisible(false)
	self:updateExchangeDeskInfo()
	self:updateTuoguangDeskInfo()
end

function AbstractGameView:exit( ... )
    if self.sid then
        Scheduler:unschedule(self.sid)
        self.sid=nil
    end
    self:initCardRecord()
    self._card_record:clearTimer()
    MusicPlayer:stopMusic()
end

-------------------牌桌的重置、清理及断线重连的处理---end------------------------



-------------------动画资源的加载---------------------------



-------------------动画资源的加载----end-----------------------


function AbstractGameView:getSendCardNode()
    return self.sendCard_node
end

-----------------------------缺失方法----------------------------------
function AbstractGameView:updateUserInfo(paras)
    if Cache.user.uin == paras.uin then
        if self._users[Cache.user.uin] then
            self._users[Cache.user.uin]:updateChipAndGold()
        else
            self:updateMySelfInfo()
        end
    else
        if self._users[paras.uin] then
            self._users[paras.uin].info.gold = paras.remain_amount
            self._users[paras.uin]:updateScore()
            
            local userInfoView = PopupManager:getPopupWindowByUid(self.userInfo)
            if isValid(userInfoView) then
            userInfoViewo:updateUserGold(paras)
            end
        end
    end
end

--延时操作
function AbstractGameView:delayTimeRun( time,cb )
    self:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function( ... )
        cb(self)
    end)))
end


function AbstractGameView:deskUserFortuneInfoUpdate(model)
    for i = 1, model.fortune_infos:len() do
        local info = model.fortune_infos:get(i)
        self:updateUserInfo({uin = info.uin , remain_amount = info.gold})
    end
end

--聊天
function AbstractGameView:chat(model)
    if not isValid(self._chat) then
        self._chat:initChatRecord()
    end
    local isplayer
    for k,v in pairs(Cache.DDZDesk._player_info)do
        if k==model.op_uin then
            isplayer=true
            break
        end
    end
    if not isplayer then return end
    if Cache.user.uin == model.op_uin then
        self._chat:hide()
    end
    if self._users[model.op_uin] then
        self._users[model.op_uin]:showPopChat(model)
    end
    --语音
    if model.content_type == 3 then
        local index = self._chat:getChatListIndex(model.content)--第几条话
        if index then
            if self._users[model.op_uin]:getSexByCache(model.op_uin) == 0 then
                MusicPlayer:playEffectFile(string.format(DDZ_Res.all_music.CHAT_0,index))
            else
                MusicPlayer:playEffectFile(string.format(DDZ_Res.all_music.CHAT_1,index))
            end
        end
    end
end

function AbstractGameView:getUserByCache(uin)
    uin = uin or -1
    if uin == -1 then return nil,nil end
    local u = Cache.DDZDesk:getUserByUin(uin)
    if u == nil then return nil,nil end
    return self:getUser(uin),u
end

function AbstractGameView:openGameRule()
    PopupManager:push({class = GameRule})
    PopupManager:pop()
end

--更新金币
function AbstractGameView:updateUserGold( )
    for k,v in pairs(self._users) do
        v:updateScore()
    end
end

--设置牌桌上方信息显示
function AbstractGameView:setGameInfoVisible(isShow)
    if (Cache.DDZDesk.status == GameStatus.NONE) then
        self.game_info:setVisible(false)
    elseif (Cache.DDZDesk.status == GameStatus.READY) then
        self.game_info:setVisible(false)
        self.diCardLayer:setVisible(false)
    else
        self.game_info:setVisible(isShow)
        self.diCardLayer:setVisible(true)
    end
end

--[[下载图片]]
function AbstractGameView:setHeadByUrl(view,url)
    if view == nil or url == nil then return end
    local kImgUrl = url
    local taskID = qf.downloader:execute(kImgUrl, 10,
        function(path)
            if not tolua.isnull(view) then
                view:loadTexture(path)
                view:setVisible(true)
            end
        end,
        function()
        end,
        function()
        end
    )
end

--显示退出弹窗提示
function AbstractGameView:showGameExit(paras)
    PopupManager:push({class = GameExit, init_data=paras})
    PopupManager:pop()
end

--发送互动表情
function AbstractGameView:playInteractAnimation(paras)
    local playOnce = function()
        GameNet:send({cmd = CMD.CMD_INTERACT_PHIZ, body = paras.body, callback = function (rsp)
            if rsp.ret == 0 and rsp.model then
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = Cache.Config._errorMsg[rsp.ret]})
            end
        end})
    end

    if paras.isBurst then -- 连发
        local repeatAction = cc.Repeat:create(
            cc.Sequence:create(
                cc.CallFunc:create(function()
                    playOnce()
                end),
                cc.DelayTime:create(0.1)
            ),paras.burstNum
        )
        self.gui:runAction(repeatAction)
    else -- 单发
        playOnce()
    end
end
-------------------------END-----------------------------

function AbstractGameView:showMultiAction( count )
    if not isValid(self.beishu_FntNum) then
        self.beishu_FntNum = cc.LabelBMFont:create()
        self.beishu_FntNum:setFntFile(DDZ_Res.beishu_fnt)
        self.jiaBeiFntTxt_node:addChild(self.beishu_FntNum)
    end

    self.beishu_FntNum:setVisible(true)
    self.beishu_FntNum:setString("x" .. count)
    self.beishu_FntNum:setPosition(cc.p(0, 0))

    local movePos = self.btn_beishu:convertToWorldSpace(cc.p(self.betNum:getPosition()))
    movePos = self.jiaBeiFntTxt_node:convertToNodeSpace(movePos)
    dump(movePos)
    self.beishu_FntNum:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.MoveTo:create(0.5, movePos),
        cc.CallFunc:create(function (  )
            self.beishu_FntNum:setVisible(false)
            self.betNum:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.5, 3),
                cc.ScaleTo:create(0.5,1)
            ))
        end)
    ))
end

return AbstractGameView