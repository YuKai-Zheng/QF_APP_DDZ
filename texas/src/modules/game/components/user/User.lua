local User          =  class("User",function (paras)
	return paras.node
 end)
local Card = import("..card.Card")
local GameAnimationConfig = import("..animation.AnimationConfig")
local Useranimation = import(".Useranimation")
local Gift = import("..Gift")
local UserHead = import("....change_userinfo.components.userHead")--我的头像

function User:ctor ( paras )
	self._parent_view = paras.view
    self.winSize = cc.Director:getInstance():getWinSize()
	self:init(paras) 
	self:initClick()
	self:initData()
	self.sureDiZhu = false	
end

--初始化user
function User:init(paras)
	self.playerP = ccui.Helper:seekWidgetByName(self,"playerP") --个人头像层
	self.aniP = ccui.Helper:seekWidgetByName(self,"aniP") --头像处显示动画的悬挂层
	self.alertBg = ccui.Helper:seekWidgetByName(self,"alert")--计时头像
	self.timerTxt = self.alertBg:getChildByName("count")--计时头像
	self.headImg = ccui.Helper:seekWidgetByName(self,"icon")--头像
	--self.headImg1 = ccui.Helper:seekWidgetByName(self,"skin_img")--头像 --将要取消
	self.gift = ccui.Helper:seekWidgetByName(self,"gift")--礼物
	self.nickTxt = ccui.Helper:seekWidgetByName(self,"txt_user_name")--昵称
	self.rankingImg = ccui.Helper:seekWidgetByName(self,"Image_ji_you")--名次图片
	self.outCardP = ccui.Helper:seekWidgetByName(self,"outcardP")--出牌层
	self.showcardP = ccui.Helper:seekWidgetByName(self,"showcardP")--明牌层
	self.notFollowImg = ccui.Helper:seekWidgetByName(self,"buyaoImg")    --不要
	self.cardNumTxt = ccui.Helper:seekWidgetByName(self,"txt_dao_ji_num")       --剩余牌数
	self._bg= ccui.Helper:seekWidgetByName(self,"bg")             --玩家信息背景
	self.cardNumBg = ccui.Helper:seekWidgetByName(self,"Image_pai_bg")       --剩余牌数背景
	self.autoImg = ccui.Helper:seekWidgetByName(self,"autoing") --托管  
	self.doubleBg = ccui.Helper:seekWidgetByName(self, "doublebg") --加倍显示
    self.jiabeiTxt = ccui.Helper:seekWidgetByName(self, "jiabei_txt") --加倍显示
    self.doubleTxt = ccui.Helper:seekWidgetByName(self, "double_txt") --叫分显示
    self.gameover_score = ccui.Helper:seekWidgetByName(self, "gameover_score") --結算分数动画显示
    self.gameover_score.y = self.gameover_score:getPositionY()
	self.info = Cache.DDZDesk._player_info[paras.uin]
	self.selfSize          = self._bg:getContentSize()
	self.cardsTable = {}
	self.emojiAniP = self.aniP:clone()
	self.emojiAniP:setPosition(self.aniP:getPositionX(), self.aniP:getPositionY())
	self:addChild(self.emojiAniP, 1)
	self.readyMark = ccui.Helper:seekWidgetByName(self,"ready") --准备
    self.warnLight = ccui.Helper:seekWidgetByName(self,"warn_light") --剩余多少张牌预警
	self.img_jiabei = ccui.Helper:seekWidgetByName(self, "img_jiabei") --加倍显示
	
	self.doubleTxt:setScale(0.9)
	self.notFollowImg:setScale(1.2)


    self.txt_match_level = ccui.Helper:seekWidgetByName(self, "txt_match_level")
	if self.cardNumBg then
		self.cardNumBg:setVisible(false)
	end
end

function User:initData( ... )
	if not self.info then return end
	self.isReady = false
    local nickName = Util:filterEmoji(self.info.nick) or ""
	self.nickTxt:setString(Util:getCharsByNum(Util:filter_spec_chars(nickName),8))
	self:updateScore()
    self:updateChipAndGold()
 
	self:updateUserHeadView()
end

function User:updateUserHeadView()
	self.headImg:setContentSize(cc.size(140, 140))
    self.headImg:ignoreContentAdaptWithSize(false)
	self.headImg:setVisible(false)
	self.playerP:getChildByName("bg_1"):setVisible(false)

	if not self.userHead then
		self.userHead = UserHead.new({})
		self.headInfoDetail = self.userHead:getUI()
		self.playerP:addChild(self.headInfoDetail)
	end

	self.headInfoDetail:setVisible(true)
	local headInfoSize = self.playerP:getContentSize()
    local headInfoDetailSize = self.headInfoDetail:getContentSize()
	
	if self.info.uin == Cache.user.uin then
	    self.headInfoDetail:setPosition( -(headInfoDetailSize.width*0.70 - headInfoSize.width)/2,-(headInfoDetailSize.height*0.70 - headInfoSize.height)/2 + 2)
	else
        self.headInfoDetail:setPosition( -(headInfoDetailSize.width*0.70 - headInfoSize.width)/2,-(headInfoDetailSize.height*0.70 - headInfoSize.height) - 10)
	end
	
	self.headInfoDetail:setScale(0.70)
	self.userHead:loadHeadImage(self.info.portrait,self.info.sex,self.info.icon_frame,self.info.icon_frame_id)    
end


--设置分数
function User:updateScore( ... )
	if Cache.DDZDesk._player_info[self.info.uin] == nil then
		return
	end

    if Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH then
        ccui.Helper:seekWidgetByName(self.playerP, "gold"):setVisible(false)
        ccui.Helper:seekWidgetByName(self.playerP, "img_gold"):setVisible(false)
        self.txt_match_level:setVisible(true)
        local levelNum = Util:getLevelNum(self.info.all_lv_info.sub_lv)

        self.txt_match_level:setString(Util:getMatchLevelTxt(self.info.all_lv_info))
    end
    ccui.Helper:seekWidgetByName(self.playerP, "gold"):setString(Util:getFormatString(Cache.DDZDesk._player_info[self.info.uin].gold,0))
end

--初始化点击事件
function User:initClick( ... )
	addButtonEventMusic(self.playerP,DDZ_Res.all_music["BtnClick"],function ( )
		if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then return end
		local localinfo={
							gold=self.info.gold,--+Cache.user.chips, 
							nick=self.info.nick,
							portrait=self.info.portrait,
							sex=self.info.sex,
							uin=self.info.uin,
							dir=self:getName()
						}
		qf.event:dispatchEvent(ET.GAME_SHOW_USER_INFO,localinfo)
	end)
end

--明牌显示
function User:ShowAllCards( cards )
	self.outCardP:setVisible(false)
	self:showOutCard(cards,1,self.showcardP)
	if self.showcardP then
		self.showcardP:removeAllChildren()
	end
	self.allCards = {}
	if not cards or #cards < 1 then return end
	cards = self:outCardsChangeOder(cards)
	for k,v in pairsByKeys(cards)do
		local card = Card.new(v,true)
		card:setScale(0.35)
		self.showcardP:addChild(card)
		table.insert(self.allCards,card)
	end
	self:updateShowCardPAndOutCardP(true)
	if self:getName() == "user_first" then
		for k,v in pairsByKeys(self.allCards)do
			local index = k - 1
			local x = index%14*40+35
			local y = math.floor((#self.allCards-1)/14)*35+self.showcardP:getContentSize().height/2-10-math.floor(index/14) *45
			--最后一张设置为地主logo
			if Cache.DDZDesk.landlord_uin == self.info.uin and index == #self.allCards-1 then
				v:setDiZhu(true)
			end
			v:setPosition(x,y)
		end
	elseif self:getName() == "user_second" then
		for k,v in pairsByKeys(self.allCards)do
			local index = k - 1 
			local x = math.floor((#self.allCards-1)/14)>0 and -13*40+250+index%14*40 or -((#self.allCards-1)%14)*40+250+(index%14)*40
			local y = math.floor((#self.allCards-1)/14)*35+self.showcardP:getContentSize().height/2-12-math.floor(index/14)*45
			if Cache.DDZDesk.landlord_uin == self.info.uin and index == #self.allCards-1 then
				v:setDiZhu(true)
			end
			v:setPosition(x,y)
		end
	end
end

--显示玩家明牌的提示
function User:showLightCardTips()
	self.doubleTxt:setVisible(true)
	self.doubleTxt:setString("明牌")
	self.isShowLightCardTips = true
	Util:delayRun(1.5,function ()
		if self and self.isShowLightCardTips then
           self.doubleTxt:setVisible(false)
        end
    end)
end

--清除玩家明牌的提示
function User:hideLightCardTips()
	if self and self.doubleTxt then
		self.doubleTxt:setVisible(false)
    end
end

--显示亮的牌
function User:showLightCard()
	local cardTable = {}
	--要确定当前人员还在
	if Cache.DDZDesk._player_info[self.info.uin] then
		cardTable = self:outCardsChangeOder(Cache.DDZDesk._player_info[self.info.uin].remain_cards)
	end
	self:ShowAllCards(cardTable)
end

--清理亮的牌
function User:clearLightCard( ... )
	if self.showcardP then
		self.showcardP:removeAllChildren()
	end
end

function User:sendCardsActionUnShuffle()
    local allCardNum = Cache.DDZDesk._player_info[self.info.uin].cards_num
    local index = 0
    self.cardNumBg:setVisible(true)

    local time = 0.3

    local sendCardNode = self:getSendCardNode() --发牌节点

    local movePos = self:convertToWorldSpace(cc.p(self.cardNumBg:getPosition()))
    movePos = sendCardNode:convertToNodeSpace(movePos)

    self.sendcard_nodes = self.sendcard_nodes or {}
    local len = #self.sendcard_nodes > allCardNum and #self.sendcard_nodes or allCardNum
    --先创建精灵 ，最终动作移除
    for i = 1, len do
        local card = self.sendcard_nodes[i]
        if not isValid(card) then
            card = cc.Sprite:create(DDZ_Res.poker_send_bg)
            sendCardNode:addChild(card)
            self.sendcard_nodes[i] = card
        end
        
        if i <= allCardNum then
        else
            card:setVisible(false)
        end
    end
    
    local function sendCard()
        if index >= allCardNum then
            return
        end

        local num = math.min(allCardNum - index, 6)

        for i = 1, num do
            local sendcard = self.sendcard_nodes[index + i]
            if isValid(sendcard) then
            sendcard:runAction(cc.Sequence:create(
                cc.CallFunc:create(function()
                    sendcard:setVisible(true)
                    sendcard:setPosition(cc.p(0, 0))
                    sendcard:setScale(1)
                end),
                cc.DelayTime:create(0.05 * i),
                cc.Spawn:create(
                    cc.BezierTo:create(time, self:getBezierConfig(cc.p(0, 0), movePos)),
                    cc.ScaleTo:create(time, 0.5)
                ),
                cc.CallFunc:create(function()
                    sendcard:setVisible(false)
    
                    index = index + 1
                    self.cardNumTxt:setString(index)

                    if i == num then
                        self.playerP:runAction(
                            cc.Sequence:create(
                                cc.DelayTime:create(0.4),
                                cc.CallFunc:create(function()
                                    sendCard()
                                end)
                            )
                        )
                    end
                end)
			))
			else
				index = index + 1
				self.cardNumTxt:setString(index)

				if i == num then
					self.playerP:runAction(
						cc.Sequence:create(
							cc.DelayTime:create(0.4),
							cc.CallFunc:create(function()
								sendCard()
							end)
						)
					)
				end
			end
        end

    end

    sendCard()
end

--游戏开始发牌
function User:sendCards( isstart )
	self.cardsTable = Cache.DDZDesk._player_info[self.info.uin].remain_cards
    local cardnum = Cache.DDZDesk._player_info[self.info.uin].cards_num
    
	if isstart then
		cardnum = 0
		self.cardNumBg:setVisible(true)
        self.isShowCardAni = true
        self:sendCardsActionUnShuffle()
		self.cardNumTxt:runAction(cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(function( ... )
			cardnum = cardnum + 1

			if Cache.DDZDesk._player_info[self.info.uin].isShowCard and self.info.uin ~= Cache.user.uin then --明牌则显示扑克
				local cards = {}
				for k=1,cardnum do
					table.insert(cards,self.cardsTable[k])
				end
				table.sort(cards,function( a,b )
					return a<b
				end)
				self:ShowAllCards(cards)
			end
			-- if cardnum == Cache.DDZDesk._player_info[self.info.uin].cards_num then
			-- 	self.isShowCardAni = nil
			-- end
		end),cc.DelayTime:create(0.15)),Cache.DDZDesk._player_info[self.info.uin].cards_num))
	else
        self.cardNumTxt:setString(cardnum)

		if cardnum>0 then
			self.cardNumBg:setVisible(true)
		else
			self.cardNumBg:setVisible(false)
        end
        
        if cardnum > 2 or cardnum == 0 then
            self:hideCardOverWarning()
        else
            self:showCardOverWarning()
        end
		if Cache.DDZDesk._player_info[self.info.uin].isShowCard then--明牌则显示扑克
			table.sort(self.cardsTable,function( a,b )
				return a<b
			end)
			self:ShowAllCards(self.cardsTable)
		end
	end
end

function User:updateAutoStatus()
	local isAuto = Cache.DDZDesk._player_info[self.info.uin].isauto
	self:showAutoImg(isAuto)
end

--显示托管
function User:showAutoImg( isshow )
	self.autoImg:setVisible(isshow)
end

--退出房间
function User:quitRoom(times)
	self:removeTimer()
	self:clear()
	self.info.quit=nil
    local fadeout    = cc.Sequence:create(cc.FadeOut:create(times),cc.Hide:create())
    self:stopAllActions()
	self:runAction(fadeout)
end

--显示叫分状态
function User:showCallPoints(score)
	self.isShowLightCardTips = false
	self.doubleTxt:setVisible(true)
	if Cache.DDZDesk.enterRef == GAME_DDZ_MATCH then
		self.doubleTxt:setString(score == 0 and "不叫" or score.."分")
		DDZ_Sound:playSoundGame(DDZ_Sound.JiaoFen,Cache.DDZDesk._player_info[self.info.uin].sex, score)
	else
		local callType = 1
		--不叫
		if score == 0 then
			if (Cache.DDZDesk.first_grab_uin == self.info.uin or Cache.DDZDesk.first_grab_uin == 0) and Cache.DDZDesk.max_grab_action == 0 then
				callType = 1
			else
				callType = 3
			end
		--抢地主
		else
			if (Cache.DDZDesk.first_grab_uin == self.info.uin or Cache.DDZDesk.first_grab_uin == 0) and Cache.DDZDesk.max_grab_action == 1 then
				callType = 2
			else
				callType = 4
			end
		end
		self.doubleTxt:setString(DDZ_TXT.callTypeName[callType])
		DDZ_Sound:playSoundGame(DDZ_Sound.ToBeLord,Cache.DDZDesk._player_info[self.info.uin].sex, callType)
	end
end
--显示加倍状态
function User:showCallDouble(double)
	if Cache.DDZDesk.status == GameStatus.CALL_DOUBLE or Cache.DDZDesk.status == GameStatus.INGAME then
		self.doubleTxt:setVisible(true)
		self.isShowCallDoubleTips = true
		Util:delayRun(1.0,function ()	
			if self and self.isShowCallDoubleTips then
				self.isShowCallDoubleTips = false
				if self.isNeedHideCallDoubleTips then
					self.isNeedHideCallDoubleTips = false
					self.doubleTxt:setVisible(false)
				end
			end
		end)
	else
		self.doubleTxt:setVisible(false)
	end

	if self.doubleBg then
		self.doubleBg:setVisible(true)
	end
	--self.jiabeiTxt:setFntFile(double ~= 0 and DDZ_Res.doubleFont1 or DDZ_Res.doubleFont2)
    --self.jiabeiTxt:setString(DDZ_TXT.callDoubleName[double])
    if double > 0 then
        self.img_jiabei:loadTexture(DDZ_Res.img_jiabei[double], ccui.TextureResType.plistType)
        self.img_jiabei:setVisible(true)
    else
        self.img_jiabei:setVisible(false)
    end
	self.doubleTxt:setString(DDZ_TXT.callDoubleName[double])
	self:removeTimer()
end

--显示加倍状态--短线重连
function User:showCallDoubleNetReconnect(double)
	self.doubleTxt:setVisible(false)
	if self.doubleBg then
		self.doubleBg:setVisible(true)
	end
	--self.jiabeiTxt:setFntFile(double ~= 0 and DDZ_Res.doubleFont1 or DDZ_Res.doubleFont2)
    --self.jiabeiTxt:setString(DDZ_TXT.callDoubleName[double])
    if double > 0 then
        self.img_jiabei:loadTexture(DDZ_Res.img_jiabei[double], ccui.TextureResType.plistType)
        self.img_jiabei:setVisible(true)
    else
        self.img_jiabei:setVisible(false)
    end
	self.doubleTxt:setString(DDZ_TXT.callDoubleName[double])
	self:removeTimer()
end

--隐藏加倍状态
function User:hideDouble( ... )
	if self.doubleBg then
		self.doubleBg:setVisible(false)
	end
end

--显示不要
function User:showNotFollow( isshow )
	self.notFollowImg:setVisible(isshow)
end

--显示不要 加倍隐藏
function User:clearUserTips()
	if self.doubleTxt:isVisible() then	
		self.isNeedHideCallDoubleTips = true
		if not self.isShowCallDoubleTips then
			self.doubleTxt:setVisible(false)
        end
	end
	self:showNotFollow(false)
end

--显示准备
function User:ready()
	self.readyMark:setVisible(true)
	self.isReady = true
end

--隐藏准备
function User:hideReadyMark()
	if self.info.status == 1020 and Cache.DDZDesk.status < GameStatus.FAPAI then
		return
	end
	self.readyMark:setVisible(false)
	self.isReady = false
end

--分析扑克（获得扑克按个数分开和按大小分开的表）
function User:analyzeCards(cards)
    local cardsBySize = {}
    local cardsByNum = {} 
    for k,v in pairsByKeys(cards) do 
    	local value,t = math.modf(v/4)
		value = value + 3
        if not cardsBySize[value] then
            cardsBySize[value] = {}
        end
        table.insert(cardsBySize[value],v)
    end
    for k,v in pairsByKeys(cardsBySize)do
        local cardnum = #v
        if k == 16 and cardsBySize[17] then--王炸
            cardsByNum[9] = {}
            local wangzha = {
                v[1],cardsBySize[17][1]
            }
            table.insert(cardsByNum[9],wangzha)
            break
        else--普通炸弹
            if not cardsByNum[cardnum] then
                cardsByNum[cardnum] = {}
            end
            if cardnum > 4 then --
                for i = 4,cardnum do 
                    local zha = {}
                    for zhanum = 1 ,i do
                        table.insert(zha,v[zhanum])
                    end
                    if not cardsByNum[i] then
                        cardsByNum[i] = {}
                    end
                    table.insert(cardsByNum[i],zha)
                end
            end
            table.insert(cardsByNum[cardnum],v)
        end
    end
    return cardsBySize,cardsByNum
end

--他人出牌排序
function User:outCardsChangeOder( cards,card_type )
	local cardTable = {}
	if card_type == DDZ_CardType.cardType_FeiJiDaiDui 
		or card_type == DDZ_CardType.cardType_FeiJiDaiDan 
		or card_type == DDZ_CardType.cardType_SiDaiDui
		or card_type == DDZ_CardType.cardType_SiDaiEr
		or card_type == DDZ_CardType.cardType_SanDaiYi
		or card_type == DDZ_CardType.cardType_SanDaiDui then
		local cardSizeTable,cardNumTable = self:analyzeCards(cards)
		--提取出所有带牌的扑克
		if card_type == DDZ_CardType.cardType_FeiJiDaiDui 
			or card_type == DDZ_CardType.cardType_FeiJiDaiDan 
			or card_type == DDZ_CardType.cardType_SanDaiYi
			or card_type == DDZ_CardType.cardType_SanDaiDui then
			for k,v in pairs(cardNumTable[3])do
				table.insertto(cardTable,v)
			end
		else
			for k,v in pairs(cardNumTable[4])do
				table.insertto(cardTable,v)
			end
		end
		--排序所有带牌的扑克
		table.sort(cardTable,function ( a,b )
			return a>b
		end)
		--将一张隐藏的扑克至于带的牌和被带的牌两者之间
		table.insert(cardTable,-1)
		--提取出所有被带的扑克
		local followCard = {}
		if cardNumTable[2] and #cardNumTable[2]>0 then
			for m,n in pairs(cardNumTable[2])do
				table.insertto(followCard,n)
			end
		end
		if cardNumTable[1] and #cardNumTable[1]>0 then
			for m,n in pairs(cardNumTable[1])do
				table.insertto(followCard,n)
			end
		end
		--排序所有被带的扑克
		table.sort(followCard,function ( a,b )
			return a>b
		end)
		--将带的扑克和被带的扑克合并
		table.insertto(cardTable,followCard)
	else
		for k,v in pairs(cards)do
			local card = v
			if card >63 then
				card = card - 60
			end
			table.insert(cardTable,card)
		end
		table.sort(cardTable,function ( a,b )
			return a>b
		end)
	end
	return cardTable
end

--显示所有出的扑克
function User:showOutCard(cards,card_type,node)
	self:showNotFollow(false)
	if not node then
		node = self.outCardP 
	end
	self.outCardP:setVisible(true)
	node:removeAllChildren()
	node:setVisible(true)
    self.outCards = {}
    --cards = {1, 2 ,3 ,5,6,7, 9, 10,11,13,14,15}
	cards = self:outCardsChangeOder(cards,card_type)
	for k,v in pairs(cards)do
		local card = Card.new(v,false)
		card:setScale(0.65)
		node:addChild(card)
		table.insert(self.outCards,card)
	end
	self.cardsTable = Cache.DDZDesk._player_info[self.info.uin].remain_cards
	if self.info.uin == Cache.user.uin then
		if self.cardsTable and Cache.DDZDesk._player_info[self.info.uin].cards_num<1 then
			Cache.DDZDesk.mine_allOut =true
		end
		self:updateCardsView()
		if self.isShowCardsWithNum then
		  self:setCardsViewByNum()
		else
		  self:setCardsViewBySize()
		end
	elseif self.cardsTable and Cache.DDZDesk._player_info[self.info.uin].cards_num then
		self.cardNumTxt:setString(Cache.DDZDesk._player_info[self.info.uin].cards_num)
		if Cache.DDZDesk._player_info[self.info.uin].cards_num == 0 then
			self.cardNumBg:setVisible(false) 
		elseif Cache.DDZDesk._player_info[self.info.uin].cards_num <=2 then
            self:showCardOverWarning()
        else
            self:hideCardOverWarning()
		end
	end
	if self:getName() == "user_first" then
        local posX = 0
        local startPos = nil
        for k,v in pairs(self.outCards)do
			local index = k - 1
			if index%10 == 0 then posX = 0 end
			posX = posX +  (v:getValue()== -1 and 8 or 52 )
            local y = math.floor((#self.outCards-1)/10)*35+node:getContentSize().height/2-math.floor(index/10)*100
            if #self.outCards <= 10 then
                y = node:getContentSize().height / 2
            end
            if Cache.DDZDesk.landlord_uin == self.info.uin and index==#self.outCards-1 then
				v:setDiZhu(true)
			end
            v:setPosition(posX,y)
            if not startPos then
                startPos = cc.p(posX, y)
            else
                if startPos.x > posX then
                    startPos.x = posX
                end
            end
        end
        
        for k,v in pairs(self.outCards) do
            local pos = cc.p(v:getPosition())
            v:setScale(0.2)
            v:setPosition(cc.p(startPos.x - 200, startPos.y))
            v:runAction(cc.Sequence:create(
                cc.EaseSineOut:create(
                    cc.Spawn:create(
                        cc.MoveTo:create(0.1, startPos),
                        cc.ScaleTo:create(0.1, 0.65)
                    )
                ),
                cc.EaseSineOut:create(cc.MoveTo:create(0.2, pos))
            ))
        end
	elseif self:getName() == "user_second" then
        local posX = 0
        local startPos = nil
        
        local width = 0
        if #self.outCards > 10 then
            width = 9 * 52 + 170
        else
            width = (#self.outCards - 1) * 52 + 170
        end

        for k,v in pairs(self.outCards)do
			local index = k - 1
            if index%10 == 0 then
                if index >= 10 then
                    posX = -((#self.outCards - 10 - 1) * 52 + 170)
                else
                    posX = -width
                end
            end
			posX = posX +  (v:getValue()== -1 and 8 or 52 )
            local y = math.floor((#self.outCards-1)/10)*35+node:getContentSize().height/2-math.floor(index/10)*100+5

            if #self.outCards <= 10 then
                y = node:getContentSize().height / 2
            end

            if Cache.DDZDesk.landlord_uin == self.info.uin and index==#self.outCards-1 then
				v:setDiZhu(true)
			end

            v:setPosition(cc.p(posX, y))
            if not startPos then
                startPos = cc.p(posX, y)
            else
                if startPos.x < posX then
                    startPos.x = posX
                end
            end
        end
        
        for k,v in pairs(self.outCards) do
            local pos = cc.p(v:getPosition())
            v:setScale(0.2)
            v:setPosition(cc.p(startPos.x + 250, startPos.y))
            v:runAction(cc.Sequence:create(
                cc.EaseSineOut:create(
                    cc.Spawn:create(
                        cc.MoveTo:create(0.1, startPos),
                        cc.ScaleTo:create(0.1, 0.65)
                    )
                ),
                cc.EaseSineOut:create(cc.MoveTo:create(0.2, pos))
            ))
        end
	else
		local posX = node:getContentSize().width/2-math.floor(#self.outCards-1)*25-52
		if card_type == DDZ_CardType.cardType_FeiJiDaiDui 
			or card_type == DDZ_CardType.cardType_FeiJiDaiDan 
			or card_type == DDZ_CardType.cardType_SiDaiDui
			or card_type == DDZ_CardType.cardType_SiDaiEr
			or card_type == DDZ_CardType.cardType_SanDaiYi
			or card_type == DDZ_CardType.cardType_SanDaiDui then
			posX = posX + 11
		end
		for k,v in pairs(self.outCards)do
			local index = k - 1 
			if v:getValue()== -1 then
				posX = posX + 8
			else
				posX = posX + 52
			end
			local y = v:getContentSize().height*0.6/2
			if Cache.DDZDesk.landlord_uin == self.info.uin and index == #self.outCards-1 then
				v:setDiZhu(true)
			end
			v:setPosition(posX,y)
        end
        
        local middlePosX = node:getContentSize().width / 2
        for k,v in pairs(self.outCards) do
            local pos = cc.p(v:getPosition())

            v:setPositionX(middlePosX - (middlePosX - pos.x) / 5)

            v:runAction(cc.MoveTo:create(0.2, pos))
        end
	end
end

--更新明牌出牌位置
function User:updateShowCardPAndOutCardP(isShowCard)
	if self.info.uin == Cache.user.uin then
		return
	end
	if isShowCard then
		self.outCardP:setPositionY(-25)
		self.showcardP:setPositionY(225)
	else
		self.outCardP:setPositionY(-25)
		self.showcardP:setPositionY(225)
	end
end

--清理信息
function User:clear()
	self.info.rank = nil
	self.isReady = false
	self.notFollowImg:setVisible(false)
	self:showAutoImg(false)
	self.outCardP:removeAllChildren()
	self.outCardP:setVisible(false)
	self:updateShowCardPAndOutCardP(false)
	if self.showcardP then
		self.showcardP:removeAllChildren()
		self.showcardP:setVisible(false)
	end
	self:changeHeadType(2)
	if self.diZhuAni then
		self.diZhuAni:removeFromParent()
		self.diZhuAni = nil
	end
	if self.cardNumBg then
		self.cardNumBg:setVisible(false)
    end
    if self.img_jiabei then
        self.img_jiabei:setVisible(false)
    end
	self:hideReadyMark()
	self:hideCardOverWarning()
    self.cardTable = {}
    self._timev = 0
    self._preTimev = 0
    self.gameover_score:setVisible(false)
end

--确认地主后头像变换
function User:changeHeadType( type,noAni )
    if type==1 then 
        cc.SpriteFrameCache:getInstance():addSpriteFrames(DDZ_Res.doudizhu_Plist, DDZ_Res.doudizhu_Png)
        self.sureDiZhu = true
		self.headImg:ignoreContentAdaptWithSize(true)

		if noAni then
            if self.info.uin == Cache.DDZDesk.landlord_uin then
                self.userHead:loadHeadLordImage(DDZ_Res.DiZhuHead)
				self:showAni(0,2)
			else
				self.userHead:loadHeadLordImage(string.format(DDZ_Res.NongMingHead,self.info.sex))
			end
			return 
		end
		if self.info.uin == Cache.DDZDesk.landlord_uin then
            --self:showAni(0, 2)
            self:showDiZhuAniAction()
			self.userHead:loadHeadLordImage(DDZ_Res.DiZhuHead)
		else
			self.userHead:loadHeadLordImage(string.format(DDZ_Res.NongMingHead,self.info.sex))
		end
	else
		if self.diZhuAni then
			self.diZhuAni:removeFromParent()
			self.diZhuAni = nil
        end
        self:initData()
		self:resetEmojiPosition()
		self.sureDiZhu = false
    end
end

--显示扑克动画
function User:showAni(cardstype,anitype)
	--if Cache.DDZDesk._player_info[self.info.uin].cards_num <= 0 then return end
	
	local pos = {x=self.outCardP:getContentSize().width/2,y=self.outCardP:getContentSize().height/2}
	local ani=function( paras )
		local changeBone = function(node, type,bonename,index)
			local bone = node:getBone(bonename)
			bone:getDisplayManager():changeDisplayWithIndex(index,true)
		end 
		local armatureDataManager = ccs.ArmatureDataManager:getInstance()
		armatureDataManager:addArmatureFileInfo(paras.anim.res)
		local   face = ccs.Armature:create(paras.anim.name)
		local node = ccui.Layout:create()
		node:setContentSize(cc.size(1,1))
		if paras.scale then
			face:setScale(paras.scale)
		end
		face:setPosition(paras.position.x,paras.position.y)
		node:addChild(face)
		if paras.node then
		 	paras.node:addChild(node)
		else
			self.aniP:addChild(node)
        end
		face:getAnimation():playWithIndex(0)
        if paras.anim.name == "xiaodizhuwangguan" then 
            face:setPosition(cc.p(self.aniP:getContentSize().width / 2, self.aniP:getContentSize().height + 30))
			self.diZhuAni = face
		else
			face:getAnimation():setMovementEventCallFunc(function ()
				face:removeFromParent()
			end)
		end
		
	end
	local pos = {}
	if anitype == 1 then
		ani({node = self.aniP,anim=GameAnimationConfig.CHANGEHEAD,position={x=self.aniP:getContentSize().width/2,y=self.aniP:getContentSize().height/2}})
	elseif anitype == 2 then
		pos = {x=self.aniP:getContentSize().width,y=self.aniP:getContentSize().height+200}
		if self:getName() == "user_second" then
			pos.x = -50
		end
		ani({node = self.aniP,anim=GameAnimationConfig.XIAODIZHUWANGGUAN,position=pos})
	elseif cardstype == DDZ_CardType.cardType_FeiJiDaiDan or 
			cardstype == DDZ_CardType.cardType_Feiji or 
			cardstype == DDZ_CardType.cardType_FeiJiDaiDui then
		pos =  {x=self._parent_view:getContentSize().width/2-(FULLSCREENADAPTIVE and self.winSize.width/2-1920/2 or 0),
				y=self._parent_view:getContentSize().height/2}
		ani({node = self._parent_view,anim=GameAnimationConfig.FEIJI,position=pos})
	elseif cardstype == DDZ_CardType.cardType_WangZha then
		pos =  {x=self._parent_view:getContentSize().width/2-(FULLSCREENADAPTIVE and self.winSize.width/2-1920/2 or 0),
				y=self._parent_view:getContentSize().height/2}
		ani({node = self._parent_view,anim=GameAnimationConfig.WANGZHA,scale=2,position=pos})
		self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function( ... )
			local posx = self._parent_view:getPositionX()
			local posy = self._parent_view:getPositionY()
			self._parent_view:runAction(cc.Sequence:create(
				cc.MoveTo:create(0.02,cc.p(posx-10,posy+3)),
					cc.MoveTo:create(0.02,cc.p(posx+5,posy-5)),
					cc.MoveTo:create(0.02,cc.p(posx-2,posy-8)),
					cc.MoveTo:create(0.02,cc.p(posx+12,posy+10)),
					cc.MoveTo:create(0.02,cc.p(posx-5,posy+7)),
					cc.MoveTo:create(0.02,cc.p(posx+6,posy-8)),
						cc.MoveTo:create(0.02,cc.p(posx-5,posy+3)),
							cc.MoveTo:create(0.02,cc.p(posx+8,posy+6)),
								cc.MoveTo:create(0.02,cc.p(posx,posy))))
		end)))
	elseif cardstype == DDZ_CardType.cardType_ShunZi or 
			cardstype == DDZ_CardType.cardType_LianDui or 
			cardstype == DDZ_CardType.cardType_ZhaDan then
		self:showCardAni(cardstype)
	end
end

--显示炸弹、连对、顺子的动画
function User:showCardAni( cardstype )
	local pos = {x=self.outCardP:getContentSize().width/2,y=self.outCardP:getContentSize().height/2}
	local ani=function( paras )
		local changeBone = function(node, type,bonename,index)
			local bone = node:getBone(bonename)
			bone:getDisplayManager():changeDisplayWithIndex(index,true)
        end 
		local armatureDataManager = ccs.ArmatureDataManager:getInstance()
		armatureDataManager:addArmatureFileInfo(paras.anim.res)
		local   face = ccs.Armature:create(paras.anim.name)
		local node = ccui.Layout:create()
		node:setContentSize(cc.size(1,1))
		if paras.flipx then
			node:setScaleX(-1)
			if cardstype == DDZ_CardType.cardType_ShunZi then
				changeBone(face,cardstype,"A2double_text2",1)
				changeBone(face,cardstype,"text-shunzi",1)
				node:setPositionX(face:getContentSize().width*0.35)
			elseif cardstype == DDZ_CardType.cardType_LianDui then
				changeBone(face,cardstype,"A3_liandui_text",1)
				changeBone(face,cardstype,"Layer1",1)
				node:setPositionX(face:getContentSize().width*0.5)
			end
		else
			if cardstype == DDZ_CardType.cardType_LianDui then
				changeBone(face,cardstype,"A3_liandui_text",0)
				changeBone(face,cardstype,"Layer1",0)
			end
		end
		face:setPosition(paras.position.x,paras.position.y)
		node:addChild(face)
		if cardstype == DDZ_CardType.cardType_ZhaDan then
			paras.node:addChild(node)
			face:setScale(3.3)
			local sprite  = cc.Sprite:create(DDZ_Res.ZhaDanImg)
			sprite:setPosition(self.headImg:getWorldPosition().x,self.headImg:getWorldPosition().y)
			if FULLSCREENADAPTIVE then
				sprite:setPositionX(sprite:getPositionX()-(self.winSize.width/2-1920/2))
				face:setPositionX(face:getPositionX()-(self.winSize.width/2-1920/2))
				paras.position.x = paras.position.x - (self.winSize.width*3/4-1920*3/4)
			end
			sprite:setScale(0.5)
			sprite:setAnchorPoint(cc.p(0.5,0.5))
			local jumpX = 300
			local rot = 180
			if self:getName() == "user_first" then
				jumpX = 200
			elseif self:getName() == "user_second" then
				jumpX = 200
				rot = -180
			end
			sprite:runAction(cc.ScaleTo:create(0.5,0.7))
			sprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.1,rot)))
			sprite:runAction(cc.Sequence:create(
				cc.JumpTo:create(0.5,cc.p(paras.position.x,paras.position.y),jumpX,1),
				cc.CallFunc:create(function( ... )
					face:getAnimation():playWithIndex(0)
					face:getAnimation():setMovementEventCallFunc(function ()
						face:removeFromParent()
					end)
					sprite:removeFromParent()
				end)))
			paras.node:addChild(sprite,5)
		else
			self.outCardP:addChild(node)
			face:getAnimation():playWithIndex(0)
			face:getAnimation():setMovementEventCallFunc(function ()
				face:removeFromParent()
			end)
		end
	end
	local isFlipX = false
	if self:getName() == "user_second" then
		isFlipX = true
	end	
	if cardstype == DDZ_CardType.cardType_LianDui then
		ani({node = self.outCardP,flipx= isFlipX,cardstype = cardstype,anim=GameAnimationConfig.LIANDUI,position={x=pos.x,y=pos.y-20}})
	elseif cardstype == DDZ_CardType.cardType_ShunZi then
		ani({node = self.outCardP,flipx= isFlipX,cardstype = cardstype,anim=GameAnimationConfig.SHUNZI,position={x=pos.x,y=pos.y-20}})
	elseif cardstype == DDZ_CardType.cardType_ZhaDan then
		ani({node = self._parent_view,anim=GameAnimationConfig.ZHADAN,position={x=self._parent_view:getContentSize().width/2,y=self._parent_view:getContentSize().height/2}})
	end
end

--显示剩余牌预警
function User:showCardOverWarning( ... )
    loga("显示剩余牌预警")
    if not isValid(self.cardOverWarningAni) then
        local armatureDataManager = ccs.ArmatureDataManager:getInstance()
        armatureDataManager:addArmatureFileInfo(DDZ_Res.cardOverWarning)
        self.cardOverWarningAni = ccs.Armature:create("deng")
        self.cardOverWarningAni:getAnimation():playWithIndex(0)
        local size = self.warnLight:getSize()
        self.cardOverWarningAni:setPosition(size.width/2,size.height/2)
        self.warnLight:addChild(self.cardOverWarningAni)
    end

    self.warnLight:setVisible(true)
end

function User:hideCardOverWarning( ... )
	self.warnLight:setVisible(false)
end

--重新设置信息
function User:reconnect(info)
	--self.info = info
	self:removeTimer()
	self:sendCards()
end

--清理扑克
function User:removeCards( ... )
	self.outCardP:removeAllChildren()
	self.outCardP:setVisible(false)
end

-- 添加倒计时的时候，发送消息给 控制器,然后来改变按钮状态
function User:addTimer(paras)
	self.alertBg:setVisible(true)
	--是不是可以全部打出
	if self.canOutAll then 
		self.alertBg:setVisible(false)
		return 
	end
	self.canNoOut = nil
	if Cache.DDZDesk.status == GameStatus.CALL_POINT then --叫分/抢地主的时间
		
	elseif Cache.DDZDesk.status == GameStatus.CALL_DOUBLE then--加倍时间
		
	elseif Cache.DDZDesk.status ~= GameStatus.READY then
		if (self.info.uin == Cache.user.uin and self.canOutCard) or self.info.uin ~= Cache.user.uin then--游戏时间能出牌
			
		else--游戏中没有能出的牌
			self.canNoOut = true
		end
	end

	local costTime = paras and paras.passtime or 0
	if self.info.uin == Cache.user.uin then
		--叫分
		if Cache.DDZDesk.status == GameStatus.CALL_POINT then
			self.alertBg:setPositionX(960)
		elseif Cache.DDZDesk.status == GameStatus.INGAME then
			self.alertBg:setPositionX(700)
		else
            self.alertBg:setPositionX(700)
            if Cache.DDZDesk.enterRef == GAME_DDZ_NEWMATCH then
                self.alertBg:setPositionX(960)
            end
			if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
                self.alertBg:setPositionX(960)
			end 
        end
        
        local isAuto = Cache.DDZDesk._player_info[self.info.uin].isauto
        if isAuto then
            self.alertBg:setVisible(false)
        end
	end

	self._timev    = paras.leftTime - costTime 
	self._preTimev = paras.leftTime - costTime - 1 

	self.timerTxt.hideTime = nil
	self.timeoverPlayerMusic = true
	self:scheduleUpdateWithPriorityLua(handler(self,self._timeCounterInFrames),0)
end

function User:_timeCounterInFrames(dt)
	local preTime = self._timev
	self._timev = self._timev - dt
	if not self.timerTxt.hideTime then
		self.timerTxt:setString(math.floor(self._timev))
	end
	if self.info.uin == Cache.user.uin then
		Cache.DDZDesk.mineTime = Cache.DDZDesk.mineTime + dt
	end

	--玩家自己可操作时间<=4s则震动
	if self.info.uin == Cache.user.uin and self._timev <= 4 and not self.canNoOut then--倒计时震动
		if math.ceil(preTime) ~= math.ceil(self._timev) and math.ceil(self._timev) > 1 then
			qf.platform:playVibrate(500) -- 不连续震动
		end
		if not self.timeOut then
			--左右摆动
			self.alertBg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateTo:create(0.05,-15),cc.RotateTo:create(0.1,15),cc.RotateTo:create(0.05,0))))
			self.timeOut = true 
    		self.timeOverMusic = DDZ_Sound:playSoundGame(DDZ_Sound.TimeOver)
   		end
   	end
    --到时间了
	if math.floor(self._timev) <= -1 then
		if self.info.uin == Cache.user.uin then
			self.btnP:setVisible(false)
			self:removeTimer({timeover = true})
			self.timeoverPlayerMusic=nil

			--如果在游戏中，而且没有可以出的牌，则不要
			if Cache.DDZDesk.status == GameStatus.INGAME and not self.canOutCard then
				self:buyaoFun()
			end
		else
			self:removeTimer({timeover = true})
			self.timeoverPlayerMusic=nil
		end
	end
end

--移除倒计时
function User:removeTimer (paras)
	if self.timeOverMusic then 
		MusicPlayer:_stopEffect(self.timeOverMusic)
		self.timeOverMusic = nil
	end
	self.timeOut = nil
	self:unscheduleUpdate()
	self.timerTxt.hideTime = nil
	self.alertBg:stopAllActions()
	self.alertBg:setRotation(0)
	self.alertBg:setVisible(false)

end

--更新礼物节点
function User:updateGiftNode(icon)
	if self.gift == nil then return end
	self.gift:loadTexture(GameRes["gift_icon_s_1"..icon],"","")
end

--结束清桌子
function User:gameStartClear( ... )
	self.cardTable={}
	self.outCardP:setVisible(false)
	self.outCardP:removeAllChildren()
	if self.showcardP then
		self.showcardP:removeAllChildren()
	end
	if self.cardNumBg then
		self.cardNumBg:setVisible(false)
	end
	self:updateShowCardPAndOutCardP(false)
end

--更新礼物
function User:updateGiftInfo(paras)
	local userModel = Cache.DDZDesk:getUserByUin(paras.uin)
	if paras and paras >= 2000 and paras < 2006 then
		qf.event:dispatchEvent(ET.SHOW_GIFTCAR_ANI,{id = paras,txt = "妹妹的妹子",pos = self.gift:getWorldPosition(),cb = function ()
			self:updateGiftNode(paras)
		end,node = self})
	else
		self:updateGiftNode(paras)
	end
	--如果当前的用户礼物是空的，就改变其为最新的
	if userModel and userModel.decoration == -1 then 
	   userModel.gitModel = paras
	end
end

--更新金币显示
function User:updateChipAndGold()

	
end

--显示
function User:show(times)
	self:setVisible(true)
    local fadeout    = cc.FadeIn:create(times)
    self:stopAllActions()
	self:runAction(fadeout)
end

--渐变显示
function User:fadeShow(times)
	local fadein    = cc.FadeIn:create(times)
	self:setVisible(true)
	self:setOpacity(0)
	self:runAction(fadein)
end

--显示聊天
function User:showPopChat(paras)
	local index = string.sub(paras.content,1,1)
	local lenght = string.len(paras.content)
	local num = paras.content
	if paras.content_type == 0 and tonumber(num) and tonumber(num)>0 and tonumber(num)<=30 then
		self:emoji(num)
	elseif paras.content_type == 3 then
		local rotation = 0
		local flipx = false
		local content=Util:filterEmoji(paras.content or "")
		if content=="" then return end
        local pos = {x=self.playerP:getChildByName("bg"):getWorldPosition().x+self.playerP:getChildByName("bg"):getContentSize().width/ 4 ,y=self.playerP:getChildByName("bg"):getWorldPosition().y}

		if self:getName() == "user_second" then
			pos.x = self.playerP:getChildByName("bg"):getWorldPosition().x-self.playerP:getChildByName("bg"):getContentSize().width
			flipx = true
		end

		if FULLSCREENADAPTIVE then 
			pos.x = pos.x-(self.winSize.width/2-2020/2)
			pos.y = pos.y + 30
		end
		if not self.sureDiZhu then
			if self:getName() == "user_second" then
				pos.x = pos.x + 40
			else
				pos.x = pos.x - 40
			end
        end
		local chatNode = Useranimation:getChatNode({content =content,pos=pos,flipx = flipx,uin=paras.op_uin })
		self._parent_view:addChild(chatNode,9)
	end
end

function User:getSexByCache(uin)
    if uin == -1 then return 0 end
    local u = Cache.DDZDesk._player_info[uin]  
    if u == nil then return 0 end

    u.sex = u.sex==2 and 0 or u.sex
    return u.sex or 0

end

--显示表情
function User:emoji(index)
	local chat   = self._parent_view._chat
	local pos = {x=self.emojiAniP:getContentSize().width/2,y=self.emojiAniP:getContentSize().height/2}
	local face_res = "emoji"..tostring(index)..".png"
    local face =  cc.Sprite:createWithSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrameByName(face_res))
    face:runAction(cc.Sequence:create(
    	cc.ScaleTo:create(0.5, 1.2),
        cc.ScaleTo:create(0.5,0.8),
        cc.ScaleTo:create(0.5, 1.2),
        cc.ScaleTo:create(0.5,0.8),
        cc.ScaleTo:create(0.5, 1.2), 
        cc.CallFunc:create(function(sender) 
        	face:removeFromParentAndCleanup()
        end)
    ))
    face:setPosition(pos.x, pos.y)
    face:setZOrder(20)
    self.emojiAniP:setZOrder(5)
    self.emojiAniP:addChild(face)
end


--显示表情
function User:vipemoji(index)
	local chat   = self._parent_view._chat
	local pos = {x=self.emojiAniP:getContentSize().width/2,y=self.emojiAniP:getContentSize().height/2}
	self._parent_view.Gameanimation:playvipemoji({node=self.emojiAniP,index=index,position=pos,order=5})
end

--设置表情坐标位置
function User:resetEmojiPosition()
    self.emojiAniP:setPosition(cc.p(self.aniP:getPositionX(), self.aniP:getPositionY()))
end

function User:getSendCardNode()
    return self._parent_view:getSendCardNode()
end

--发牌
function User:getBezierConfig( fromPos, toPos )
    local offPoint = cc.p(toPos.x - fromPos.x, toPos.y - fromPos.y)
    local controll1 = cc.p(fromPos.x, fromPos.y + 200)
    local controll2 = cc.p(fromPos.x + offPoint.x* 4/5, toPos.y + 200)
    local bezierConfig = {controll1
        , controll2
        , toPos}
    return bezierConfig
end

--地主头像移动
function User:getBezierConfig_1( fromPos, toPos )
    local offPoint = cc.p(toPos.x - fromPos.x, toPos.y - fromPos.y)
    local controll1 = cc.p(fromPos.x, fromPos.y + 100)
    local controll2 = cc.p(fromPos.x + offPoint.x* 4/5, toPos.y + 100)
    local bezierConfig = {controll1
        , controll2
        , toPos}
    return bezierConfig
end

-- 设置手牌显示
function User:setCardNumBgVisible(bool)
	if self.cardNumBg then
		self.cardNumBg:setVisible(bool)
	end
end

function User:showGameoverScore(score)
	local time = 0.5
	local distance = 100
	local gameover_score_str = ""
	if score < 0 then
		self.gameover_score:setFntFile(DDZ_Res.gameover_score_fnt2)
		gameover_score_str = Util:getFormatString(score)
	else
		self.gameover_score:setFntFile(DDZ_Res.gameover_score_fnt1)
		gameover_score_str = "+"..Util:getFormatString(score)
	end

	local calc_typeInfo = Cache.DDZDesk.backUpOveroInfo[self.info.uin]

    if calc_typeInfo.calc_type == 1 then
		gameover_score_str = gameover_score_str.."(破产)"
	elseif calc_typeInfo.calc_type == 2 then
        gameover_score_str = gameover_score_str.."(封顶)"
	end
	
	self.gameover_score:setString(gameover_score_str)

    self.gameover_score:setPositionY(self.gameover_score.y)
	self.gameover_score:setVisible(true)
	self.gameover_score:runAction(cc.Sequence:create(
		cc.MoveTo:create(time, cc.p(self.gameover_score:getPositionX(), self.gameover_score.y + distance)),
		cc.DelayTime:create(1) --,
		-- cc.CallFunc:create(function(sender)
		-- 	self.gameover_score:setVisible(false)
		-- end),
		-- cc.MoveBy:create(0, cc.p(0, -distance))
	))

	return time
end

--执行地主确定动画和动作
function User:showDiZhuAniAction(  )
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameAnimationConfig.XIAODIZHUWANGGUAN.res)
    local face = ccs.Armature:create(GameAnimationConfig.XIAODIZHUWANGGUAN.name)
    local pos = cc.p(self.aniP:getContentSize().width / 2, self.aniP:getContentSize().height + 30)
    
    local node = ccui.Layout:create()
    node:setContentSize(cc.size(1,1))
    self.aniP:addChild(node)
    face:setPosition(pos.x,pos.y)
    node:addChild(face)

    face:getAnimation():playWithIndex(0)

    local sendCardNode = self:getSendCardNode() --发牌节点

    local movePos = self._parent_view:convertToWorldSpace(cc.p(sendCardNode:getPosition()))
    movePos = self.aniP:convertToNodeSpace(movePos)
    movePos = cc.p(movePos.x - 60, movePos.y -85)
    node:setPosition(movePos)

    face:getAnimation():setMovementEventCallFunc(function ()
        if self.info.uin == Cache.user.uin then
            node:runAction(cc.BezierTo:create(0.8, self:getBezierConfig_1(movePos, cc.p(0, 0))))
        else
            node:runAction(cc.MoveTo:create(0.8, cc.p(0, 0)))
        end
    end)

    self.diZhuAni = face
end

function User:clearInGameEnd(  )
    self:showAutoImg(false)
    self.info.rank = nil
	self.isReady = false
    self.notFollowImg:setVisible(false)
    if self.img_jiabei then
        self.img_jiabei:setVisible(false)
    end
    self:hideReadyMark()
    self:hideCardOverWarning()
end

return User