
--[[
经典场: View
--]]

local AbstractGameView = import("..AbstractGameView")
local NormalGameView = class("NormalGameView", AbstractGameView)
local NormalGameEnd = import("..components.NormalGameEnd")
local GameAnimationConfig = import("..components.animation.AnimationConfig")
local GameTaskView = import("..components.GameTaskView")

NormalGameView.TAG = "NormalGameView"
function NormalGameView:ctor( params )
	NormalGameView.super.ctor(self, params)
end

function NormalGameView:initUI( params )
	NormalGameView.super.initUI(self, params)
	self.classicDeskInfo:setVisible(false)
    self.startP:setVisible(true)
    self.newEndP:setVisible(false)
    self:updateBuyItems()
end

function NormalGameView:initClick( params )
    NormalGameView.super.initClick(self, params)
	-- 换桌
    addButtonEventMusic(self.exchangeDeskBtn,DDZ_Res.all_music["BtnClick"],function() 
        qf.event:dispatchEvent(ET.CHANGE_TABLE)
	end)
	
	--明牌开始
    addButtonEventMusic(self.showCardStartBtn, DDZ_Res.all_music["BtnClick"], function ()
        self:checkGold({
            roomid = Cache.DDZDesk.room_id,
            startType = GAME_START_TYPE.SHOW,
            showMulti = 5
        })
    end)

    --开始游戏
    addButtonEventMusic(self.startBtn, DDZ_Res.all_music["BtnClick"], function ()
        self:checkGold({
            roomid = Cache.DDZDesk.room_id,
            startType = GAME_START_TYPE.NORMAL,
            showMulti = 0
         })
    end)

    --明牌开始
    addButtonEventMusic(self.newEndP_showCardStartBtn, DDZ_Res.all_music["BtnClick"], function ()
        self:checkGold({
            roomid = Cache.DDZDesk.room_id,
            startType = GAME_START_TYPE.SHOW,
            showMulti = 5
        })
        self:dealCardRecordAtGameEnd()
    end)

    addButtonEventMusic(self.back,DDZ_Res.all_music["BtnClick"],function( ... )--下拉列表按钮
        self:quitRoomAction()
    end)

    --开始游戏
    addButtonEventMusic(self.newEndP_startBtn, DDZ_Res.all_music["BtnClick"], function ()
        self:checkGold({
            roomid = Cache.DDZDesk.room_id,
            startType = GAME_START_TYPE.NORMAL,
            showMulti = 0
         })
         self:dealCardRecordAtGameEnd()
    end)

    --结算
    addButtonEventMusic(self.newEndP_calculateBtn, DDZ_Res.all_music["BtnClick"], function ()
        self:dealCardRecordAtGameEnd()
        local normalGameEndView = PopupManager:getPopupWindowByUid(self.normalGameEnd)
        if not isValid(normalGameEndView) then
            self.normalGameEnd = PopupManager:push({class = NormalGameEnd, init_data = {endTime = 0, view = self}})
            PopupManager:pop()
        else
            normalGameEndView:updateGameEndInfo({endTime = 0})
        end
    end)

    -- 点击查看倍数信息
    addButtonEventMusic(self.btn_beishu,DDZ_Res.all_music["BtnClick"],function()
        if not self.beiDescLayer:isVisible() then
            GameNet:send({cmd=CMD.BEI_INFO_UPDATE,callback= function(rsp)
                if rsp.ret == 0 then
                    Cache.DDZDesk:updateBeiInfo(rsp.model.multiple_info)
                    self:updateMySelfBeiDetailInfo(rsp.model.multiple_info)
                    self.beiDescLayer:setVisible(true)
                end
            end})
        else 
            self.beiDescLayer:setVisible(false)
        end
	end)

	--托管
    addButtonEventMusic(self.tuoGuanBtn,DDZ_Res.all_music["BtnClick"],function( ... )  
        GameNet:send({cmd=CMD.AUTO_PLAY_REQ,body={auto = 1},callback = function (rsp)
            if rsp.ret == 0 then
                Cache.DDZDesk._player_info[Cache.user.uin].isauto = true
                self:bankClicked()
                self.tuoGuanP:setVisible(true)
                --self.tuoGuanBtn:setVisible(false)
                self:updateTuoguangDeskInfo()
            else
                loga("托管失败！ ret=" .. rsp.ret)
            end
        end})
    end)

    --取消托管
    addButtonEventMusic(ccui.Helper:seekWidgetByName(self.tuoGuanP,"Button_tuo_guan"),DDZ_Res.all_music["BtnClick"],function( ... ) 
        GameNet:send({cmd = CMD.AUTO_PLAY_REQ,body={auto = 0},callback = function (rsp)
            if rsp.ret == 0 then
                Cache.DDZDesk._player_info[Cache.user.uin].isauto = nil
                self.tuoGuanP:setVisible(false)
                self:updateTuoguangDeskInfo()
            else
                loga("取消托管失败！ ret=" .. rsp.ret)
            end
        end})
    end)
    
    addButtonEvent(self.btn_gameTask, function (  )
        qf.event:dispatchEvent(ET.CMD_GAME_TASK_REQ, {openGameTask = true})
    end)
end

function NormalGameView:dealCardRecordAtGameEnd( ... )
    self:initCardRecord()
    self:updateBuyItems(true)
end

function NormalGameView:quitRoomAction()
    NormalGameView.super.quitRoomAction(self)
    if Cache.DDZDesk.status == GameStatus.READY then
        Cache.DDZDesk.startAgain = nil
        qf.event:dispatchEvent(ET.RE_QUIT)
    else
        if Cache.DDZDesk.status and Cache.DDZDesk.status > 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.quit_error})
        else
            local info = Cache.Config:getGameTaskStatusByRoomId(Cache.DDZDesk.room_id)
            local data = info.data
            local str = ""
            if data == nil then -- 无任务
                str = GameTxt.gameExit_normal_1
            else
                str = string.format(GameTxt.gameExit_normal, data.condition - data.progress)
            end
            qf.event:dispatchEvent(ET.SHOW_GAME_EXIT_VIEW, {
                content=str,
                confirmCb=function()
                    qf.event:dispatchEvent(ET.MYSELF_QUIT_ROOM)
                end
            })
            return
        end
    end
    self.menuP:setVisible(false)
    qf.event:dispatchEvent(ET.REFRESH_LISTEN)
    Cache.DDZDesk.startAgain = true
end


--检测用户金币是否足够
function NormalGameView:checkGold(paras)
    if paras == nil then return end
    GameNet:send({cmd=CMD.CHECK_GOLD_LIMIT_REQ,body = {room_id = paras.roomid},callback=function(rsp)
        if rsp.ret == 0 then
            local model = rsp.model
            if model then
                local id = model.room_id
                if model.flag == 0 then --入场
                    self:requestGameStart(paras)
                    return
                elseif model.flag == 1 then 
                    qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_tips, type = 7,color = cc.c3b(0,0,0),fontsize = 34,cb_consure = function( ... )
                        qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})--点击上报
                        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
                    end, cb_cancel = function ( ... )
                        ModuleManager:remove("game")
                        ModuleManager:removeExistView()
                        ModuleManager.DDZhall:show()
                    end})
                elseif model.flag == 2 then
                    self:requestGameStart(paras)
                    return
                else
                    ModuleManager:remove("game")
                    ModuleManager:removeExistView()
                    ModuleManager.DDZhall:show()
                end
            end
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            ModuleManager:remove("game")
            ModuleManager:removeExistView()
            ModuleManager.DDZhall:show()
        end
    end})
end

--经典场用户自己选择
function NormalGameView:requestGameStart(paras)
    if paras == nil then
        loga("paras是空的 GameView:requestGameStart")
        return
    end

    self.startP:setVisible(false)
    self:matchingStartAni()

    qf.event:dispatchEvent(ET.GAME_INPUT_REQ, {
        roomid = paras.roomid,
        startType = paras.startType,
        showMulti = paras.showMulti
     })
end

--初始化牌桌信息
function NormalGameView:initDeskDesc()
    NormalGameView.super.initDeskDesc(self)
    self:initNormalGameDeskInfo()
end

--经典场次桌子信息
function NormalGameView:initNormalGameDeskInfo()
    ccui.Helper:seekWidgetByName(self.gui,"deskname"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.gui, "desk_title"):setVisible(true)
	local desk_name_txt = DDZ_TXT.classic_desk_name
	if Cache.DDZconfig:getRoomConfigByRoomId(Cache.DDZDesk.room_id).play_mode == GameConstants.BATTLE_TYPE_UNSHUFFLE then
		desk_name_txt = DDZ_TXT.unshuffle_desk_name
	end
	self.classicDeskInfo:setVisible(true)
	self.classicDeskInfo:getChildByName("desk_name"):setString(string.format(desk_name_txt, Cache.DDZconfig:getRoomConfigByRoomId(Cache.DDZDesk.room_id).room_name, Cache.DDZconfig:getRoomConfigByRoomId(Cache.DDZDesk.room_id).base_chip))
    self.classicDeskInfo:getChildByName("desk_desc"):setString(string.format(DDZ_TXT.classic_desk_desc, Cache.DDZconfig:getRoomConfigByRoomId(Cache.DDZDesk.room_id).enter_fee,Cache.DDZconfig:getRoomConfigByRoomId(Cache.DDZDesk.room_id).cap_score))
    
    self.img_game_info_bg:getChildByName("txt_cost"):setString(Cache.DDZconfig:getRoomConfigByRoomId(Cache.DDZDesk.room_id).enter_fee)
    self.img_game_info_bg:getChildByName("txt_capping"):setString(Util:getFormatString(Cache.DDZconfig:getRoomConfigByRoomId(Cache.DDZDesk.room_id).cap_score))
end

function NormalGameView:initBuyItemPanel(isEnd)
    self.buy_item_panel = ccui.Helper:seekWidgetByName(self.gui,"buy_item_panel")
    if Cache.DDZDesk.status == GameStatus.NONE or isEnd then
        local item = null
        local num
        local daojvInfo

        for k,v in pairs(Cache.Config:getIngameBuyList()) do
            num = 0
            daojvInfo = {}
            item = self.buy_item_panel:getChildByName("buy_" .. k)
            if v.name == "cards_remember" then
                item:getChildByName("image_bg"):loadTexture(DDZ_Res.global_card_record_tip)
                daojvInfo = Cache.daojuInfo.cardRemember or {}
            elseif v.name == "cards_remember_daily" then
                item:getChildByName("image_bg"):loadTexture(DDZ_Res.global_card_record_tip)
                daojvInfo = Cache.daojuInfo.cardRemember or {}
            elseif v.name == "super_multi_card" then
                item:getChildByName("image_bg"):loadTexture(DDZ_Res.global_card_multi_tip)
                daojvInfo = Cache.daojuInfo.super_mulCard or {}
            end

            if v.currency == 0 then -- 金币支付
                item:getChildByName("img_type"):loadTexture(DDZ_Res.global_coin_icon)
            elseif v.currency == 3 then -- 福卡支付
                item:getChildByName("img_type"):loadTexture(GameRes.reward_get_type_2)
                item:getChildByName("img_type"):setContentSize(40, 48)
            end

            for i,val in pairs(daojvInfo) do
                if val.name == v.name then
                    num = num + val.amount
                end
            end
            if num and num > 0 then
                local red_point = item:getChildByName("red_point")
                red_point:setVisible(true)
                red_point:getChildByName("txt_num"):setString(num)
            end
            item:getChildByName("coinCost"):setString(v.price)
            item:getChildByName("title"):setString(v.title)

            addButtonEvent(item,function()
                local enter_limit_low = Cache.DDZconfig:getRoomConfigByRoomId(Cache.DDZDesk.room_id).enter_limit_low
                if v.currency == 0 and Cache.user.gold < (v.price + enter_limit_low) then
                    qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT,{content = GameTxt.no_gold_buy_tips, type = 7,color=cc.c3b(0,0,0),fontsize=34,cb_consure=function( ... )
                        qf.platform:umengStatistics({umeng_key = "ToPayOnNormalGame"})--点击上报
                        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD,ref=UserActionPos.NORMALGAME_REF})
                    end})
                elseif v.currency == 3 and Cache.user.fucard_num < v.price then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "您的奖券不足"})
                else
                    qf.event:dispatchEvent(ET.NET_PRODUCT_EXCHANGE_BY_DIAMOND, {item_name = v.name, ref = UserActionPos.SHORTCUT_REF , scene = "ingame", cb = function(paras)
                        if paras then
                            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = v.title..DDZ_TXT.buy_success.."！"})
                            self:updateBuyItems()
                        else
                            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = DDZ_TXT.buy_fail})
                        end
                    end})
                end
            end)
        end
        self.game_info:setVisible(false)
        self.buy_item_panel:setVisible(true)
        ccui.Helper:seekWidgetByName(self.gui,"Card_record"):setVisible(false)
    else
        self.buy_item_panel:setVisible(false)
        ccui.Helper:seekWidgetByName(self.gui,"Card_record"):setVisible(true)
    end
end

function NormalGameView:updateBuyItems(isEnd)
    GameNet:send({ cmd = CMD.CMD_GET_DAOJU_LIST ,wait=true,txt=GameTxt.net002,
    callback= function(rsp)
        if rsp.ret ~= 0 then
            --不成功提示
            loga("不成功提示")
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        else
            loga("成功提示")
            if rsp.model ~= nil then 
                Cache.daojuInfo:saveConfig(rsp.model)
                self:initBuyItemPanel(isEnd)
                if isValid(self._card_record) then
                    self._card_record:updateRedNum()
                end
            end
        end
        --logd(pb.tostring(rsp.model),self.TAG)
    end})
end

--换桌按钮逻辑
function NormalGameView:updateExchangeDeskInfo()
    NormalGameView.super.updateExchangeDeskInfo(self)
    
    local normalGameEndView = PopupManager:getPopupWindowByUid(self.normalGameEnd)

    if isValid(normalGameEndView) then return end
    -- 经典场才有换桌，要小于三个人，换桌显示
    if  table.nums(Cache.DDZDesk._player_info) < 3 then
        Cache.globalInfo:setStatUploadTime(STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_WAIT_SUCC_TIME)
        self.exchangeDeskBtn:setVisible(true)
    end
end

-- 游戏匹配中
function NormalGameView:matchingStartAni( ... )
    self.startP:setVisible(false)
    self.newEndP:setVisible(false)
    
    self.matchingTips:removeAllChildren()
    self.matchingTips:setVisible(true)
    self.buy_item_panel:setVisible(false)
    ccui.Helper:seekWidgetByName(self.gui,"Card_record"):setVisible(true)

    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(DDZ_Res.simpleMathgingSuccess)
    local gameButtonAni = ccs.Armature:create("wenzi")
    gameButtonAni:setScale(0.7)
    gameButtonAni:getAnimation():playWithIndex(0)
    local size = self.matchingTips:getSize()
    gameButtonAni:setPosition(size.width/2,size.height/2)
    self.matchingTips:addChild(gameButtonAni)
end

--设置桌面信息(底分、倍数)
function NormalGameView:setDeskInfo()
	local difenNum = Cache.DDZconfig:getRoomConfigByRoomId(Cache.DDZDesk.room_id).base_chip
    self.diFen:setString(difenNum)
end

-------------------proto协议信息处理------------------------------
function NormalGameView:enterRoom(opuin, isReStart)
	NormalGameView.super.enterRoom(self, opuin,isReStart)
	if opuin == Cache.user.uin or isReStart then
		self:updateTuoguangDeskInfo()
		self:setDeskInfo()
        self:initDeskDesc()
        self:initBuyItemPanel()
		-- self:initMenu()
	else

	end
	--不管是谁进来
    if table.nums(Cache.DDZDesk._player_info) < 3 then
        Cache.globalInfo:setStatUploadTime(STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_WAIT_SUCC_TIME)        
        self:matchingStartAni()
	end
	
	self:updateExchangeDeskInfo()
end

-- --更新托管按钮的显示和隐藏
-- function NormalGameView:updateTuoguangDeskInfo()
-- 	NormalGameView.super.updateTuoguangDeskInfo(self)
-- 	if  Cache.DDZDesk.status == GameStatus.INGAME and not Cache.DDZDesk._player_info[Cache.user.uin].isauto then
-- 		self.tuoGuanBtn:setVisible(true)
-- 	end
-- end


--用户明牌 cmd
function NormalGameView:userShowCard(model)
	NormalGameView.super.userShowCard(self, model)
end

--用户准备 cmd
function NormalGameView:userReady(model)
	NormalGameView.super.userReady(self, model)
    self:updateExchangeDeskInfo()
end

--游戏开始
function NormalGameView:gameStart(model)
	NormalGameView.super.gameStart(self, model)
end

--抢地主/叫分阶段
function NormalGameView:showCallPoints( info )
	NormalGameView.super.showCallPoints(self, info)
	self:setDeskInfo()
end

--加倍阶段
function NormalGameView:showCallDouble( info )
	NormalGameView.super.showCallDouble(self, info)
end

--要不起显示
function NormalGameView:showNotFollowUin( model )
    NormalGameView.super.showNotFollowUin(self, model )
end

--玩家出牌
function NormalGameView:outCards( model )
	NormalGameView.super.outCards(self, model)
end

--显示游戏结束窗口
function NormalGameView:GameEnd( model )
	self:setDeskInfo()
    -- self:initCardRecord()
    if Cache.DDZDesk.is_abolish == 1 then return end
    self._users[Cache.user.uin]:resetActionBtn()

    local score_time = 0;

    self.endTime = 1
    --清理托管层
    self.tuoGuanP:setVisible(false)

    for k,v in pairs(self._users)do
        score_time = v:showGameoverScore(Cache.DDZDesk.backUpOveroInfo[k].win_money)
        v:clearInGameEnd()
        if k ~= Cache.user.uin then
            v:showLightCard()
        end
    end

    self.endTime = self.endTime + score_time

    if Cache.DDZDesk.win_type ~= 0 then
        self:delayTimeRun(self.endTime,function( ... )
            self:playSpringAni()
        end)
    else
        self:delayTimeRun(self.endTime,function( ... )
            self:playNormalEndAni(Cache.DDZDesk.mine_is_win == true)
        end)
    end

    self.endTime = self.endTime + 2.5

    self:delayTimeRun(self.endTime,function( ... )
        self.newEndP:setVisible(true)
    end)

    --当局结束，隐藏记牌器
    self._card_record:currentGameOver()  
    self.game_info:setVisible(true)
    self.diCardLayer:setVisible(true)
    -- self:updateBuyItems(true)
    ccui.Helper:seekWidgetByName(self.gui,"Card_record"):setVisible(false)
end

 --收到玩家退卓的消息
function NormalGameView:quitRoom(uin)
	NormalGameView.super.quitRoom(self, uin)
end


-------------------proto协议信息处理---end---------------------------

--清理桌面
function NormalGameView:clearDesk( ... )
	NormalGameView.super.clearDesk(self)
	self.tuoGuanP:setVisible(false)
	self:updateExchangeDeskInfo()
	self:updateTuoguangDeskInfo()
end

----------------延时加载的UI资源-----------------

function NormalGameView:initCompontent()
    NormalGameView.super.initCompontent(self)
    self.btn_beishu:setVisible(true)
    self:setDeskInfo()

    self:checkRedPackageTip()
end

-- 初始化菜单栏
function NormalGameView:initMenu()
    local menuTable = {}    
	self.menuP:setBackGroundImage(DDZ_Res.menuP_large)
	self.quitGameBtn = self.menuItem:clone()--退出按钮
	self.quitGameBtn:getChildByName("quit"):setBackGroundImage(DDZ_Res.menu_Quit,ccui.TextureResType.plistType)
	table.insert(menuTable,self.quitGameBtn)
	addButtonEventMusic(self.quitGameBtn,DDZ_Res.all_music["BtnClick"],function( ... )
		self:quitRoomAction()
	end)

    self.detailBtn = self.menuItem:clone()--详情按钮
    self.detailBtn:getChildByName("quit"):setBackGroundImage(DDZ_Res.menu_Detail,ccui.TextureResType.plistType)
    table.insert(menuTable,self.detailBtn)

    local lastBtn = menuTable[#menuTable]
    if lastBtn then
        lastBtn:getChildByName("line"):setVisible(false)
    end
    addButtonEventMusic(self.detailBtn,DDZ_Res.all_music["BtnClick"],function( ... )
        self:openGameRule()
        self.menuP:setVisible(false)
    end)

    self.menuP:setContentSize(cc.size(self.menuP:getContentSize().width,30+(#menuTable)*self.menuItem:getContentSize().height))
    self.menuP:setPositionY(Display.cy-5-self.menuP:getContentSize().height)
    local y=self.menuP:getContentSize().height-15
    for k,v in pairs(menuTable)do
        self.menuP:addChild(v)
        y=y-self.menuItem:getContentSize().height
        v:setPosition(14,y)
    end
end

--在无进桌数据时刷新自身数据
function NormalGameView:updateMySelfInfo()
    --更新下金币
    local myselfNode = ccui.Helper:seekWidgetByName(self.gui,"user_info")
    ccui.Helper:seekWidgetByName(myselfNode,"gold_layer"):setVisible(true)
    ccui.Helper:seekWidgetByName(myselfNode,"gold_layer"):getChildByName("num"):setString(Util:getFormatString(Cache.user.gold))
    ccui.Helper:seekWidgetByName(myselfNode,"focas_layer"):setVisible(false)

    --更新下头像
    local headNode = ccui.Helper:seekWidgetByName(myselfNode,"icon")
    Util:updateUserHead(headNode, Cache.user.portrait, Cache.user.sex, { url=true})

    local headBox = ccui.Helper:seekWidgetByName(myselfNode,"userHeadBox")
    
    headBox:setVisible(true)
    if Cache.user.icon_frame_id then
        -- self:setHeadByUrl(headBox,Cache.user.icon_frame)  
        local level,season = Util:getLevelHeadBoxTxt(Cache.user.icon_frame_id)
        headBox:loadTexture(string.format(GameRes.headLevelBox, level))
        if string.len(level) > 1 then
            ccui.Helper:seekWidgetByName(headBox,"season_font"):setVisible(true)
            ccui.Helper:seekWidgetByName(headBox,"season_font"):setString("S"..season) 
        else
            ccui.Helper:seekWidgetByName(headBox,"season_font"):setVisible(false)
        end
    end
end

----------------延时加载的UI资源---end--------------

function NormalGameView:resetForNewStart( ... )
	-- body
	NormalGameView.super.resetForNewStart(self)
    self.startP:setVisible(true)
    self.newEndP:setVisible(false)
    
    self:checkRedPackageTip()
end

function NormalGameView:checkRedPackageTip(  )
    if Cache.user.app_new_user_play_task.status == 1 then
        if isValid(self.tipDialog) then return end
        self.tipDialog = ccui.ImageView:create(GameRes.nextrewardbgPng)
        self.tipDialog:ignoreContentAdaptWithSize(false)
        self.tipDialog:setContentSize(cc.size(self.tipDialog:getContentSize().width + 50, self.tipDialog:getContentSize().height))
        local txt = ccui.Text:create()
        txt:setFontSize(40)
        txt:setColor(cc.c3b(182, 92, 58))
        txt:setText(GameTxt.redPackageTip)
        self.tipDialog:addChild(txt)
        txt:setPosition(cc.p(self.tipDialog:getContentSize().width / 2, self.tipDialog:getContentSize().height / 5 * 3))

        self.startBtn:addChild(self.tipDialog)
        self.tipDialog:setAnchorPoint(cc.p(0, 0))
        self.tipDialog:setPosition(cc.p(self.startBtn:getContentSize().width / 3 * 2, self.startBtn:getContentSize().height / 3 * 2))
    else
        if isValid(self.tipDialog) then
            self.tipDialog:removeFromParent()
        end
    end
end

function NormalGameView:updateGameTask(  )
    local gameTaskView = PopupManager:getPopupWindowByUid(self.gameTask)
    if isValid(gameTaskView) then
        gameTaskView:updateData()
    end
    self:updateGameTaskBtn()
end

function NormalGameView:updateGameTaskBtn(  )
    local taskInfo = Cache.Config:getGameTaskStatusByRoomId(Cache.DDZDesk.room_id)

    if not taskInfo then
        self.btn_gameTask:setVisible(false)
    else
        local data = taskInfo.data
        if taskInfo.type == 1 then
            self.btn_gameTask:getChildByName("img_light"):setVisible(false)
            self.btn_gameTask:getChildByName("img_btn"):getChildByName("txt"):setVisible(true)
            self.btn_gameTask:getChildByName("img_btn"):getChildByName("txt"):setString("(" .. data.progress .. "/" .. data.condition .. ")")
            self.btn_gameTask:getChildByName("img_btn"):getChildByName("img"):loadTexture(DDZ_Res.gameTask_txt[2], ccui.TextureResType.plistType)
        elseif taskInfo.type == 2 then
            self.btn_gameTask:getChildByName("img_light"):setVisible(true)
            self.btn_gameTask:getChildByName("img_btn"):getChildByName("txt"):setVisible(false)
            self.btn_gameTask:getChildByName("img_btn"):getChildByName("img"):loadTexture(DDZ_Res.gameTask_txt[1], ccui.TextureResType.plistType)
        else
            self.btn_gameTask:getChildByName("img_light"):setVisible(false)
            self.btn_gameTask:getChildByName("img_btn"):getChildByName("txt"):setVisible(false)
            self.btn_gameTask:getChildByName("img_btn"):getChildByName("img"):loadTexture(DDZ_Res.gameTask_txt[2], ccui.TextureResType.plistType)
        end

        self.btn_gameTask:setVisible(true)
    end
end

function NormalGameView:openGameTask(  )
    local gameTaskView = PopupManager:getPopupWindowByUid(self.gameTask)
    
    if isValid(gameTaskView) then
        gameTaskView:updateData(true)
        return
    end

    self.gameTask = PopupManager:push({class = GameTaskView, show_cb = function()
        local gameTaskView = PopupManager:getPopupWindowByUid(self.gameTask)
        if isValid(gameTaskView) then
            gameTaskView:updateData(true)
        end
    end})
    PopupManager:pop()
end

return NormalGameView