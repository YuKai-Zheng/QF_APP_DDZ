local Myself        = class("Myself",import(".User"))
local CardView = import("..card.CardView")

function Myself:ctor ( paras )
	Myself.super.ctor(self, paras)
	self:initCardsView()
end

--初始化
function Myself:init(paras)
	Myself.super.init(self,paras)
	self.info = Cache.DDZDesk._player_info[Cache.user.uin]

	self.cardClickP = ccui.Helper:seekWidgetByName(self,"cardClickP")--扑克层
	self.cardView = ccui.Helper:seekWidgetByName(self._parent_view.gui,"mine_cardP")--扑克层
	self.btnP = ccui.Helper:seekWidgetByName(self,"button_panel")--按钮层
	self.autoTips = ccui.Helper:seekWidgetByName(self,"autotips")--超时显示
	self.jiaofenP = ccui.Helper:seekWidgetByName(self.btnP,"jiaofenP") -- 叫分层
	self.jiabeiP = ccui.Helper:seekWidgetByName(self.btnP,"jiabeiP") -- 加倍层
	self.chupaiP = ccui.Helper:seekWidgetByName(self.btnP,"chupaiP") -- 出牌层
	self.buyaoBtn = ccui.Helper:seekWidgetByName(self.btnP,"btn_bu_yao")--不要按钮
	self.buyaoBtn.posx = self.buyaoBtn:getPositionX()
	self.hintBbtn = ccui.Helper:seekWidgetByName(self.btnP,"btn_ti_shi")--提示按钮
	self.hintBbtn.posx = self.hintBbtn:getPositionX()
	self.chupaiBtn = ccui.Helper:seekWidgetByName(self.btnP,"btn_chu_pai")--出牌按钮
    self.goldTxt = ccui.Helper:seekWidgetByName(self,"gold_layer"):getChildByName("num")
    self.gameover_score = ccui.Helper:seekWidgetByName(self, "gameover_score") --結算分数动画显示

	self.showCardP = ccui.Helper:seekWidgetByName(self.btnP,"showcardBtnP")--明牌按钮层
	self.showCardBtn = self.showCardP:getChildByName("showcard_btn")--明牌按钮

	--self.showCardP:setVisible(self.info.isShowCard)

	self.qiangP = ccui.Helper:seekWidgetByName(self.btnP,"qiangP")
	self.qiangBtn = self.qiangP:getChildByName("btn_qiang")
	self.buqiangBtn = self.qiangP:getChildByName("btn_buqiang")

	self.bujiaoBtn = ccui.Helper:seekWidgetByName(self.jiaofenP,"btn_bujiao")

	--加倍按钮
	self.jiabeiBtn = ccui.Helper:seekWidgetByName(self.jiabeiP,"btn_jiabei")
	self.bujiabeiBtn = ccui.Helper:seekWidgetByName(self.jiabeiP,"btn_bujiabei")
	self.superjiabeiBtn = ccui.Helper:seekWidgetByName(self.jiabeiP,"btn_super_jiabei") --超级加倍
	self.superMutilAniP = ccui.Helper:seekWidgetByName(self,"super_mutilP")
end

--隐藏奖券tips
function Myself:hideFocasTips()

end

function Myself:initData( paras )
	Myself.super.initData(self, paras)
    local reward = Cache.user.fucard_num or 0
	ccui.Helper:seekWidgetByName(self,"focas_layer"):getChildByName("num"):setString(tostring(reward))
    ccui.Helper:seekWidgetByName(self,"gold_layer"):setVisible(false)
	ccui.Helper:seekWidgetByName(self,"focas_layer"):setVisible(false)

    if Cache.DDZDesk.enterRef ~= GAME_DDZ_NEWMATCH then
		self.nickTxt:setPositionY(40)
		ccui.Helper:seekWidgetByName(self,"focas_layer"):setVisible(false)
		ccui.Helper:seekWidgetByName(self,"gold_layer"):setVisible(true)
        ccui.Helper:seekWidgetByName(self,"gold_layer"):getChildByName("num"):setString(Util:getFormatString(Cache.DDZDesk._player_info[self.info.uin].gold))
        ccui.Helper:seekWidgetByName(self,"gold_layer"):setPositionX(300)
        ccui.Helper:seekWidgetByName(self,"focas_layer"):setPositionX(700)
		self.btnP:setVisible(false)
    else
		-- if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
		-- 	ccui.Helper:seekWidgetByName(self,"gold_layer"):setVisible(true)
        -- end
        ccui.Helper:seekWidgetByName(self,"gold_layer"):setVisible(true)
        ccui.Helper:seekWidgetByName(self,"gold_layer"):setPositionX(500)
        ccui.Helper:seekWidgetByName(self,"focas_layer"):setVisible(true)
        ccui.Helper:seekWidgetByName(self,"focas_layer"):setPositionX(800)
		self.btnP:setVisible(true)
	end
	--初始是5倍
	self.showCardBeiCount = 5
end

--显示加倍状态
function Myself:showCallDouble(double)
	Myself.super.showCallDouble(self, double)
	if double == 2 then
		self.doubleTxt:setString("")
		self:showSuperMutilAni()
	end
end

--显示超级加倍动画
function Myself:showSuperMutilAni()
	if Cache.DDZDesk.status == GameStatus.INGAME then
		return
	end
	local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(DDZ_Res.superMutilAni)
    local gameButtonAni = ccs.Armature:create("superMutil")
    gameButtonAni:getAnimation():playWithIndex(0)
    local size = self.superMutilAniP:getContentSize()
    gameButtonAni:setPosition(size.width/2,size.height/2)
    self.superMutilAniP:addChild(gameButtonAni)
end

--更新得分
function Myself:updateScore( ... )
    if Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH then
        self.txt_match_level:setVisible(true)
        local levelNum = Util:getLevelNum(Cache.user.all_lv_info.sub_lv)
        self.txt_match_level:setString(Util:getMatchLevelTxt(Cache.user.all_lv_info))

        ccui.Helper:seekWidgetByName(self, "match_level_icon"):setVisible(true)
        ccui.Helper:seekWidgetByName(self, "match_level_icon"):loadTexture(string.format(GameRes.userLevelImg, math.ceil(Cache.user.all_lv_info.match_lv/10)))
    end
end

function Myself:resetActionBtn( ... )
	self.jiabeiP:setVisible(false)
	self.chupaiP:setVisible(false)
	self.showCardP:setVisible(false)
	self.qiangP:setVisible(false)
	self.jiaofenP:setVisible(false)
end

--清理扑克
function Myself:removeCards( ... )
	self.canOutAll = nil
	self.outCardP:removeAllChildren()
	self.outCardP:setVisible(false)
	if Cache.DDZDesk._player_info[Cache.user.uin].isauto then
		self.chupaiP:setVisible(false)
		return
	end
	self.btnP:setVisible(true)
	self.showCardP:setVisible(false)
	self.qiangP:setVisible(false)
	self.chupaiP:setVisible(true)
	self.jiabeiP:setVisible(false)
	self.jiaofenP:setVisible(false)
	self.chupaiBtn:setTouchEnabled(false)
	self.chupaiBtn:setBright(false)
	self.firstChooseCard = true

	if Cache.DDZDesk.now_max_cards_uin == 0 or Cache.DDZDesk.now_max_cards_uin == Cache.user.uin then
		--可以全部出
		if self.CardView:isCanOutAll() and Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH then 
			self.btnP:setVisible(false)
			self.canOutAll = true
			return 
		end
		self.buyaoBtn:setTouchEnabled(false)
		self.buyaoBtn:setBright(false)
		self.CardView:clearOtherCards()
		self.CardView:canOutCardsView()
		self.canOutCard = true
		self.buyaoBtn:setPositionX(self.buyaoBtn.posx)
		self.hintBbtn:setVisible(true)
		self.chupaiBtn:setVisible(true)
	else
		self.buyaoBtn:setTouchEnabled(true)
		self.buyaoBtn:setBright(true)
		local  canOutCard = self.CardView:showMineChooseCards(nil,true)
		if not canOutCard then
			self.canOutCard = false
			qf.event:dispatchEvent(ET.SHOW_OUTCARDS_TIPS,{type = 1})
			self.buyaoBtn:setPositionX(self.chupaiP:getContentSize().width / 2)
			self.hintBbtn:setVisible(false)
			self.chupaiBtn:setVisible(false)
		else
			self.buyaoBtn:setPositionX(self.buyaoBtn.posx)
			self.hintBbtn:setVisible(true)
			self.chupaiBtn:setVisible(true)
			self.canOutCard = true
		end
	end
end

function Myself:showAutoImg( isshow )
	qf.event:dispatchEvent(ET.SHOW_AUTO_PLAYER,{isshow = isshow})
end

--显示出牌按钮
function Myself:canOutCardsView( isshow )
	self.chupaiBtn:setTouchEnabled(isshow)
	self.chupaiBtn:setBright(isshow)
end

--显示明牌操作层
function Myself:showShowCardP(isshow)
    self.btnP:setVisible(isshow)
    self.showCardP:setVisible(isshow)
    if self.info.isShowCard then
        self.showCardP:setVisible(false)
    end
end

--不要
function Myself:buyaoFun()
	if self.isShowCardsWithNum then--不要后牌放下去
      	self:setCardsViewByNum()
    else
    	self:setCardsViewBySize()
    end
    self.chupaiP:setVisible(false)
    local cmd = Cache.DDZDesk.enterRef ~= GAME_DDZ_NEWMATCH and CMD.OUT_CARDS_REQ or CMD.NEWEVENT_DISCARD_REQ
	GameNet:send({cmd = cmd,body={},callback=function( rsp )
		if rsp.ret ~=0 then
			self.btnP:setVisible(true)
			qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
		end
	end})
end

--出牌
function Myself:outCardFun( onlyShowOut )
	if onlyShowOut and  (not self.chupaiP:isVisible() or not self.btnP:isVisible() or not self.chupaiBtn:isVisible() or not self.chupaiBtn:isBright()) then 
		return false
	end
	local cards,cardstype = self.CardView:getOutCards()
	if cardstype ~= DDZ_CardType.cardType_Error then
		self.btnP:setVisible(false)
		local info = {
			cards = cards
		}

		local cmd = Cache.DDZDesk.enterRef ~= GAME_DDZ_NEWMATCH and CMD.OUT_CARDS_REQ or CMD.NEWEVENT_DISCARD_REQ
		--出牌请求
		GameNet:send({cmd=cmd,body=info,callback=function( rsp )
			if rsp.ret ~=0 then
				self.btnP:setVisible(true)
				qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
			end
		end})
		return true
	elseif not onlyShowOut then
		qf.event:dispatchEvent(ET.SHOW_OUTCARDS_TIPS,{type = 2})
	end
	return false
end

function Myself:initClick( ... )
	--提示
	addButtonEventMusic(self.hintBbtn,DDZ_Res.all_music["BtnClick"],function( ... )--提示
		local  canOutCard = self.CardView:showMineChooseCards()
		if not canOutCard and Cache.DDZDesk.now_max_cards_uin ~= Cache.user.uin then
			qf.event:dispatchEvent(ET.SHOW_OUTCARDS_TIPS,{type = 1})
			self:buyaoFun()
		end
	end)

	--抢地主
    addButtonEventMusic(self.qiangBtn, DDZ_Res.all_music["BtnClick"], function ()
        local cmd = Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH and CMD.NEWEVENT_CALL_REQ or CMD.CALL_POINTS_REQ
		GameNet:send({cmd=cmd,body={grab_action = Cache.DDZDesk.max_grab_action + 1},callback=function( rsp )
            if rsp.ret ~=0 then
                self.qiangP:setVisible(true)
				qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
			else
				self.qiangP:setVisible(false)
			end
        end})
        self.qiangP:setVisible(false)
	end)

	--不抢
    addButtonEventMusic(self.buqiangBtn, DDZ_Res.all_music["BtnClick"], function ()
        local cmd = Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH and CMD.NEWEVENT_CALL_REQ or CMD.CALL_POINTS_REQ
		GameNet:send({cmd=cmd,body={grab_action = 0},callback=function( rsp )
			if rsp.ret ~=0 then
				self.qiangP:setVisible(true)
				qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
			else
				self.qiangP:setVisible(false)
			end
		end})
		self.qiangP:setVisible(false)
	end)

	--发牌过程中明牌
	addButtonEventMusic(self.showCardBtn, DDZ_Res.all_music["BtnClick"], function ()
		if Cache.DDZDesk.status ~= GameStatus.FAPAI then return end
		-- body
        self.showCardP:setVisible(false)
        local cmd = Cache.DDZDesk.enterRef ~= GAME_DDZ_NEWMATCH and CMD.SHOW_CARD_IN_GIVE_CARD or CMD.NEWEVENT_SHOW_CARD_REQ
		GameNet:send({cmd=cmd,body={show_multi = self.showCardBeiCount},callback=function( rsp )
			if rsp.ret ~=0 then	
				if not self.isShowCard and  Cache.DDZDesk.status == 5 then
					self.showCardP:setVisible(true)
				else  
					self.showCardP:setVisible(false)
				end
				qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
			else
				self.showCardP:setVisible(false)
			end
		end})
	end)
	
	--出牌
	addButtonEventMusic(self.chupaiBtn,DDZ_Res.all_music["BtnClick"], function()--出牌按钮
		self:outCardFun()
		self.chupaiP:setVisible(false)
	end)

	--不要
	addButtonEventMusic(self.buyaoBtn,DDZ_Res.all_music["BtnClick"], function()--不要按钮
		self:buyaoFun()
		self.chupaiP:setVisible(false)
	end)

	-- --不叫地主
	-- addButtonEventMusic(self.bujiaoBtn,DDZ_Res.all_music["BtnClick"], function( ... )--不叫按钮
	-- 	GameNet:send({cmd=CMD.MATCH_USER_CALL_REQ,body={grab_action = 0},callback=function( rsp )
	-- 			if rsp.ret ~=0 then
	-- 				qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
	-- 			end
	-- 		end})
	-- 	self.jiaofenP:setVisible(false)	
	-- end)

	-- for k=1,3 do
	-- 	local jiaofen = ccui.Helper:seekWidgetByName(self.jiaofenP,"btn_bei"..k)
	-- 	--叫地主
	-- 	addButtonEventMusic(jiaofen,DDZ_Res.all_music["BtnClick"],function( ... )--不叫按钮
	-- 		GameNet:send({cmd=CMD.MATCH_USER_CALL_REQ,body={grab_action = k},callback=function( rsp )
	-- 			if rsp.ret ~=0 then
	-- 				qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
	-- 			end
	-- 		end})
	-- 		self.jiaofenP:setVisible(false)
	-- 	end)
	-- end

	--超级加倍
	addButtonEventMusic(self.superjiabeiBtn,DDZ_Res.all_music["BtnClick"],function( ... )--超级加倍按钮
		local multilNum = 2
		if Cache.user.super_multi_card_num == 0 then
			qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = DDZ_TXT.no_call_double_card})
			multilNum = 0
		end
		self.jiabeiP:setVisible(false)
		self:removeTimer()
		local cmd = Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH and CMD.NEWEVENT_USER_MUTI_REQ or CMD.CALL_DOUBLE_REQ 
		GameNet:send({cmd=cmd, body={do_multi = multilNum},callback=function( rsp )
				if rsp.ret ~=0 then
					qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
				end
			end})
	end)

	--加倍
    addButtonEventMusic(self.jiabeiBtn,DDZ_Res.all_music["BtnClick"],function( ... )--加倍按钮
        dump(Cache.DDZDesk.multi_min_gold,"最小加倍金币")
		local multilNum = 1
        if Cache.DDZDesk.enterRef ~= GAME_DDZ_MATCH then
            if Cache.user.uin == Cache.DDZDesk.landlord_uin then
                if not Cache.DDZDesk:isLordCanDouble() then
                    multilNum = 0
                end
            else
                if not Cache.DDZDesk:isFarmerCanDouble() then
                    multilNum = 0
                end
            end
        end
		
        if multilNum == 0 then
            if Cache.user.gold < Cache.DDZDesk.multi_min_gold then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(DDZ_TXT.cannot_double_tips_2, Cache.DDZDesk.multi_min_gold)})
            else
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(DDZ_TXT.cannot_double_tips_1, Cache.DDZDesk.multi_min_gold)})
            end
		end

		self.jiabeiP:setVisible(false)
		self:removeTimer()
		local cmd = Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH and CMD.NEWEVENT_USER_MUTI_REQ or CMD.CALL_DOUBLE_REQ 
		GameNet:send({cmd=cmd, body={do_multi = multilNum},callback=function( rsp )
				if rsp.ret ~=0 then
					qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
				end
			end})
	end)

	--不加倍
	addButtonEventMusic(self.bujiabeiBtn,DDZ_Res.all_music["BtnClick"],function( ... )--不加倍按钮
		self.jiabeiP:setVisible(false)
		self:removeTimer()
		local cmd = Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH and CMD.NEWEVENT_USER_MUTI_REQ or CMD.CALL_DOUBLE_REQ
		GameNet:send({cmd=cmd, body={do_multi = 0},callback=function( rsp )
				if rsp.ret ~=0 then
					qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
				else
				end
			end})
	end)

	--个人信息
	addButtonEventMusic(self.playerP,DDZ_Res.all_music["BtnClick"],function ( )
		if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then Util:uploadError(" 点击大厅个人头像") end
        qf.platform:umengStatistics({umeng_key = "Personal_information"})--点击上报
        local updatepoint = function(...)
            -- body
            qf.event:dispatchEvent(ET.MAIN_UPDATE_SHORTCUT_NUMBER)
        end
        local localinfo = {gold = Cache.user.gold, 
            nick = Cache.user.nick, 
            portrait = Cache.user.portrait, 
        sex = Cache.user.sex}
        qf.event:dispatchEvent(ET.GLOBAL_SHOW_USER_INFO, {uin = Cache.user.uin, localinfo = localinfo, isedit = true,isInGame = true, cb = updatepoint})
	end)

end

--更新明牌按钮倍数
function Myself:updateShowCardBtnCount(paras)
	if Cache.DDZDesk.status ~= GameStatus.FAPAI or not paras then return end
	
	if Cache.DDZDesk._player_info[Cache.user.uin].isShowCard == true then
		self:showShowCardP(false)
		return
	end

	if Cache.DDZDesk.status > 5 then --当不处于发牌阶段时
	    return
	end

	local margin = math.ceil((paras.time + 1)/6)
	local num = 5 - margin
	if paras.time == -1 then
		self:showShowCardP(false)
		return
	end
	self:showShowCardP(true)
	self.showCardBeiCount = num
	loga("明牌倍数按钮变化  " .. self.showCardBeiCount)
	self.showCardBtn:getChildByName("txt"):setString(string.format(DDZ_TXT.classic_showcard_txt, self.showCardBeiCount))
end

--更新显示加倍层
function Myself:updateJiaBeiP( info )
	--托管不更新
	if Cache.DDZDesk._player_info[Cache.user.uin].isauto then
		return
    end
    
    self:clearStatusTxt()

	-- --自己不能加倍的(经典场都是可以加倍的)
	-- if not Cache.DDZDesk.canCallDoubleInfo[Cache.user.uin] and Cache.DDZDesk.enterRef ~= GAME_DDZ_MATCH then
	-- 	return
	-- end

	-- --已经加过倍
	-- if Cache.DDZDesk.DoubleTable and Cache.DDZDesk.DoubleTable[Cache.user.uin] then
	-- 	return
	-- end

	-- --比赛场判断农民是不是有加倍
	-- local flag = false
	-- for k,v in pairs(Cache.DDZDesk.DoubleTable) do
	-- 	--农民加倍了,那就是地主加倍了
	-- 	if v == 1 and k ~= Cache.DDZDesk.landlord_uin then
	-- 		flag = true
	-- 	end
	-- end

	self.btnP:setVisible(true)
	self.jiabeiP:setVisible(true)
	self.jiaofenP:setVisible(false)
	self.chupaiP:setVisible(false)
    self.qiangP:setVisible(false)

	--比赛场没有加倍
	if Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH or not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.jiabeiBtn:setPositionX(620)
		self.bujiabeiBtn:setPositionX(1300)
		self.superjiabeiBtn:setVisible(false)
	else
		self.superjiabeiBtn:setVisible(true)
		self:updateSuperBeiCardNum()
	end
end

--更新超级加倍卡信息
function Myself:updateSuperBeiCardNum()
	self.superjiabeiBtn:getChildByName("bei_img"):getChildByName("num"):setString(Cache.user.super_multi_card_num)
end

--显示叫分结果
function Myself:showCallPoints(score)
	Myself.super.showCallPoints(self, score)
	self.qiangP:setVisible(false)
	self.jiaofenP:setVisible(false)
end

--更新显示叫分层
function Myself:showJiaofenP( info )
	if Cache.DDZDesk._player_info[Cache.user.uin].isauto then
		return
    end
    self:clearStatusTxt()

	if Cache.DDZDesk.enterRef ~= GAME_DDZ_MATCH then
		self.qiangP:setVisible(true)
		self.btnP:setVisible(true)
		self.jiabeiP:setVisible(false)
		self.jiaofenP:setVisible(false)
        self.chupaiP:setVisible(false)
        self.showCardP:setVisible(false)
		if Cache.DDZDesk.max_grab_action == 0 or Cache.DDZDesk.max_grab_action == nil then
			self.qiangBtn:getChildByName("txt"):setString(DDZ_TXT.callTypeName[2])
			self.buqiangBtn:getChildByName("txt"):setString(DDZ_TXT.callTypeName[1])
		else
			self.qiangBtn:getChildByName("txt"):setString(DDZ_TXT.callTypeName[4])
			self.buqiangBtn:getChildByName("txt"):setString(DDZ_TXT.callTypeName[3])
		end
	else
		self.qiangP:setVisible(false)
        self.btnP:setVisible(true)
        self.showCardP:setVisible(false)

		self.jiabeiP:setVisible(false)
		self.jiaofenP:setVisible(true)
		self.chupaiP:setVisible(false)
		for k=1,3 do
			local jiaofen = ccui.Helper:seekWidgetByName(self.jiaofenP,"btn_bei"..k)
			if Cache.DDZDesk.nowPoints and Cache.DDZDesk.nowPoints>= k then
				jiaofen:setBright(false)
				jiaofen:setTouchEnabled(false)
			else
				jiaofen:setBright(true)
				jiaofen:setTouchEnabled(true)			
			end
		end
	end
end

function Myself:ShowAllCards()
	-- body
end

function Myself:clear( ... )
	Myself.super.clear(self)
	self.btnP:setVisible(false)

	self.cardsTable = {}
	self.canOutAll = nil
end
function Myself:gameStartClear( ... )
	Myself.super.gameStartClear(self)
	self.cardsTable = {}
	self:updateCardsView(false)
end

function Myself:removeBtnP( ... )
	self.btnP:setVisible(false)
end

--显示不要
function Myself:showNotFollow( isshow )
	self.notFollowImg:setVisible(isshow)
	if Cache.DDZDesk.next_uin ~= Cache.user.uin then
		self.btnP:setVisible(false)
	end
end

--重新设置信息
function Myself:reconnect(info)
	self.cardsTable = Cache.DDZDesk._player_info[Cache.user.uin].remain_cards
	self:updateCardsView()
end

--游戏开始发牌
function Myself:sendCards( isstart )
	self.cardsTable = Cache.DDZDesk._player_info[Cache.user.uin].remain_cards
	self:updateCardsView(isstart)
end

--初始化扑克视图
function Myself:initCardsView( ... )
	self.CardView = CardView.new(self.cardClickP,self.cardView,self)
end

--更新扑克视图(是否是刚发牌)
function Myself:updateCardsView(isstart)
    self.CardView:showMineHandleCard(self.cardsTable,isstart)
    if #self.cardsTable > 2 or #self.cardsTable == 0 then
        self:hideCardOverWarning()
    else
        self:showCardOverWarning()
    end
end

--将手牌按大小排列
function Myself:setCardsViewBySize()
	self.cardsTable = self.CardView:updateCardsBySize()
end

--将手牌按数目排列
function Myself:setCardsViewByNum()
	self.cardsTable = self.CardView:updateCardsByNum()
end

-- --更新金币显示
function Myself:updateChipAndGold()
	self.goldTxt:setString(Util:getFormatString(Cache.user.gold))
	local reward = Cache.user.fucard_num or 0
	ccui.Helper:seekWidgetByName(self,"focas_layer"):getChildByName("num"):setString(tostring(reward))
end

--退出房间
function Myself:quitRoom(times)
	loga("用户自己退出房间Myself:quitRoom")
    
    local quitGame
    quitGame = function (  )
        ModuleManager.DDZhall:remove()
        ModuleManager:remove("game")
        Cache.DDZDesk:clear()
    end
    
    qf.platform:umengStatistics({umeng_key = "GameToHall"})--点击上报
    if Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH then
        qf.event:dispatchEvent(ET.SHOW_MATCHHALL_VIEW, {cb = quitGame})
    else
        quitGame()
        ModuleManager.gameshall:initModuleEvent()
        ModuleManager.gameshall:show()
    end

    if Cache.DDZDesk.startAgain then
        Cache.DDZDesk.startAgain = nil
        if Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH then
        elseif Cache.DDZDesk.enterRef == GAME_DDZ_CLASSIC then
            ModuleManager.DDZhall:show()
        end
	end

	Cache.desk.is_play = -1
end

--清理显示操作文字
function Myself:clearStatusTxt()
    self.doubleTxt:setString("")
    --self.jiabeiTxt:setString("")
end

function Myself:showGameoverScore(score)
	local time = 0.5
	local distance = 100
	if score < 0 then
		self.gameover_score:setFntFile(DDZ_Res.gameover_score_fnt2)
		self.gameover_score:setText(Util:getFormatString(score))
	else
		self.gameover_score:setFntFile(DDZ_Res.gameover_score_fnt1)
		self.gameover_score:setText("+"..Util:getFormatString(score))
	end
	self.gameover_score:setVisible(true)
	self.gameover_score:runAction(cc.Sequence:create(
		cc.MoveBy:create(time, cc.p(0, distance)),
		cc.DelayTime:create(1),
		cc.CallFunc:create(function(sender)
			self.gameover_score:setVisible(false)
		end),
		cc.MoveBy:create(0, cc.p(0, -distance))
	))

	return time + 1
end

return Myself