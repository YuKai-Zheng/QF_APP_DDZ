local M = class("CardView")
local cardManage = import(".CardManage")
local Card = import(".Card")
function M:ctor(cardClickP,panel,parentView)
    self.nowCards={}
    self.normalCards={}
    self.numCards={}
    self.otherCards = {}
    self.cardClickP = cardClickP
    self.parentP = panel
    self.parentView = parentView
    self.parentPSizeX = self.parentP:getContentSize().width
    self:addEventWithCards()
    self.chooseIndex = 1
end

--发牌(扑克，直接显示还是有动画（isstart为true有动画）)
function M:showMineHandleCard(cards,isstart)
    if self.isShowCardAni then return end

    self.nowCards = {}
    self.parentP:removeAllChildren()

    for k,v in pairsByKeys(cards)do
        local card = Card.new(v,false)
        local syscard = {}
        syscard.card = card
        --syscard.real_value = v
        syscard.value = card:getValue()
        syscard.valueId = v 
        syscard.cardvalue = card:getCardValue()
        syscard.color = card:getCardColor()
        card:setVisible(false)
        self.parentP:addChild(card)
        table.insert(self.nowCards,syscard)
    end 
    self.normalCards = DDZ_cardManage:getCardsBySize(self.nowCards)
    self.numCards = DDZ_cardManage:getCardsByNum(self.nowCards)
    
    --self:showNowCardsUnShuffle()
    if isstart then
        self:showNowCardsUnShuffle()
    else
        self:updateCardsPosX(self.nowCards)
        self:showZhaDanColor()
    end
end

-- 不洗牌场发牌动画
function M:showNowCardsUnShuffle()
    if #self.nowCards == 0 then return end
    
    local time = 0.3 -- 发牌移动时间
    local mingPaiTime = 1
    self.isShowCardAni = true

    self:updateCardsPosX(self.nowCards, true, true)

    local index = 0 --牌堆索引
    local sendCardNode = self.parentView:getSendCardNode() --发牌节点

    self.sendcard_nodes = self.sendcard_nodes or {}
    local len = #self.sendcard_nodes > #self.nowCards and #self.sendcard_nodes or #self.nowCards
    --先创建精灵 ，最终动作移除
    for i = 1, len do
        local card = self.sendcard_nodes[i]
        if not isValid(card) then
            card = cc.Sprite:create(DDZ_Res.poker_send_bg)
            sendCardNode:addChild(card)
            self.sendcard_nodes[i] = card
        end
        
        if i <= #self.nowCards then
            
        else
            card:setVisible(false)
        end
    end

    local function sendCard()
        if not self.nowCards[index + 1] then
            self:updateCardsBySize()
            self.isShowCardAni = false
            qf.event:dispatchEvent(ET.CARD_SHOW_TIME_EVENT, {time = -1})

            local middlePosX = self.parentP:getContentSize().width / 2
            --手牌展开动画
            for i = 1, #self.nowCards do
                local card = self.nowCards[i].card
                local cardPosX = card:getPositionX()

                card:runAction(cc.Sequence:create(
                    cc.MoveTo:create(0.2, cc.p(middlePosX, card:getPositionY())),
                    cc.MoveTo:create(0.2, cc.p(cardPosX, card:getPositionY()))
                    
                ))
            end
            return
        end

        DDZ_Sound:playSoundGame(DDZ_Sound.FAPAI)

        local cardNum =math.min(6, #self.nowCards - index)

        if Cache.DDZDesk.enterRef ~= GAME_DDZ_MATCH and Cache.DDZDesk.status == GameStatus.FAPAI then
            qf.event:dispatchEvent(ET.CARD_SHOW_TIME_EVENT, {time = mingPaiTime})
        end

        for i = 1 , cardNum do
            local card = self.nowCards[#self.nowCards - index - i + 1].card
            local sendcard = self.sendcard_nodes[index + i]

            local movePos = self.parentP:convertToWorldSpace(cc.p(card:getPosition()))
            movePos = sendCardNode:convertToNodeSpace(movePos)
            if isValid(sendcard) then
                sendcard:runAction(cc.Sequence:create(
                    cc.CallFunc:create(function()
                        sendcard:setVisible(true)
                        sendcard:setPosition(cc.p(0, 0))
                    end),
                    cc.DelayTime:create(0.04 * i ),
                    cc.BezierTo:create(time, self.parentView:getBezierConfig(cc.p(0, 0), movePos)),
                    cc.CallFunc:create(function()
                        if isValid(card) then
                            card:setVisible(true)
                        end
                        sendcard:setVisible(false)

                        if cardNum == i then
                            index = index + cardNum
                            mingPaiTime = mingPaiTime + cardNum

                            self.parentP:runAction(cc.Sequence:create(
                                cc.DelayTime:create(0.3),
                                cc.CallFunc:create(function()
                                    sendCard()
                                end)
                            ))
                        end
                    end)
                ))
            else
                if isValid(card) then
                    card:setVisible(true)
                end
                if cardNum == i then
                    index = index + cardNum
                    mingPaiTime = mingPaiTime + cardNum

                    self.parentP:runAction(cc.Sequence:create(
                        cc.DelayTime:create(0.4),
                        cc.CallFunc:create(function()
                            sendCard()
                        end)
                    ))
                end
            end
        end
        
    end

    sendCard()
end

--显示炸弹
function M:showZhaDanColor(cards)
    if 1 then return end
    local cardsTable = {}
    local tempList =self.nowCards
    if cards then
        tempList = cards
    end
    for k,v in pairsByKeys(tempList)do
        if not cardsTable[v.cardvalue] then
            cardsTable[v.cardvalue] = {}
            cardsTable[v.cardvalue].size = 0
            cardsTable[v.cardvalue].point = v.cardvalue
            cardsTable[v.cardvalue].value = {}
        end
        if v.cardvalue >=16 then
            cardsTable[v.cardvalue].size = 9
        end
        cardsTable[v.cardvalue].size = cardsTable[v.cardvalue].size + 1
        table.insert(cardsTable[v.cardvalue],v)
    end
    for k,v in pairsByKeys(tempList)do
        if cardsTable[v.cardvalue].size>=4 and (v.cardvalue<16 or  v.cardvalue >=16 and cardsTable[16] and cardsTable[17] and #cardsTable[16] + #cardsTable[17] == 4) then
            v.iszhadan = true
            v.card:green()
        else
            v.iszhadan = nil
            v.card:light()
        end
    end
end

--按顺序显示扑克
function M:updateCardsBySize()
    self.sendCardStatus = nil 
    for k,v in pairsByKeys(self.normalCards)do
        v.isselect = false
    end
    self:updateCardsPosX(self.normalCards)
    self.nowCards = self.normalCards
    local cards = {}
    for k,v in pairsByKeys(self.nowCards)do
        table.insert(cards,v.valueId)
    end
    self:canOutCardsView()
    return cards
end

--按扑克个数显示扑克
function M:updateCardsByNum()
    self:updateCardsPosX(self.numCards)
    self.nowCards = self.numCards
    self:showZhaDanColor()
    local cards = {}
    for k,v in pairsByKeys(self.nowCards)do
        table.insert(cards,v.valueId)
    end
    return cards
end

--设置扑克的位置
function M:updateCardsPosX(cards,issendcard, notShow)
    if #cards <= 0 then return end
    local index = #cards
    local dis = #cards>12 and 80 or 120--牌的间距

    dis = (1600 / (#cards - 1)) > 120 and 120 or (1600 / (#cards - 1))

    local allWidth = dis * (#cards - 1) + cards[1].card:getContentSize().width
    for m,n in pairsByKeys(cards)do
        if not notShow then n.card:setVisible(true) end
        
        n.card:setZOrder(#cards-m)
        n.card:setPosition(cc.p(
            (allWidth / 2) - dis * (m - 1) - n.card:getContentSize().width / 2 + self.parentPSizeX / 2,
            n.card:getContentSize().height / 2
        ))
        n.cardPosX = (allWidth / 2) - dis * (m - 1) - n.card:getContentSize().width + self.parentPSizeX / 2
        if n.isselect then 
            n.card:setPositionY(n.card:getContentSize().height/2+30)
        end
        n.card:setDiZhu()
        --n.isselect = nil
        if m == 1 then 
            n.cardDis = n.card:getContentSize().width   
            if Cache.DDZDesk._player_info[Cache.user.uin].isShowCard then--显示明牌
                n.card:setMingPai()
            end
            if Cache.DDZDesk.landlord_uin == Cache.user.uin then--显示地主
                n.card:setDiZhu(true)
            end
        else
            n.cardDis = dis
        end
    end

    --为了双击屏幕把牌还原，在扑克那加个层
    self.cardClickP:setPositionX((self.parentPSizeX - allWidth) / 2)
    self.cardClickP:setContentSize(cc.size(allWidth + 10,cards[1].card:getContentSize().height*1.1))

end

--设置拖拽扑克的位置
function M:updateChooseCardsPos(cards,pos)
    -- local index = #cards
    -- dis = #cards>12 and 90 or 120--牌的间距
    -- for m,n in pairsByKeys(cards)do
    --     if tolua.isnull(n.card) then
    --         self._touchOut={}
    --         return 
    --     end
    --     n.card:setVisible(true)
    --     n.card:setZOrder(100+#cards-m)
    --     n.card:setPosition(pos.x+(index/2-m+0.5)*dis,pos.y+n.card:getContentSize().height/2)
    -- end
end

--扑克的点击事件
function M:addEventWithCards( ... )
    self.winSize = cc.Director:getInstance():getWinSize()
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:registerScriptHandler(function (touch,event)--点击开始
        if self.sendCardStatus then return end
        self._touchData = {}
        self._touchData.pos = touch:getLocation()
        if FULLSCREENADAPTIVE then 
            self._touchData.pos.x = self._touchData.pos.x - (self.winSize.width/2-1920/2)
        end
        self._touchOut = {}
        self._touchOut.status = false
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    listener1:registerScriptHandler(function (touch,event)--点击移动
        if self.sendCardStatus then return end
        local endpos = touch:getLocation()
        if FULLSCREENADAPTIVE then 
            endpos.x = endpos.x - (self.winSize.width/2-1920/2)
        end
        if self._touchOut.status then
            local pos = {x=endpos.x-self.parentP:getPositionX(),y=endpos.y-self.parentP:getPositionY()}
        else
            if self._touchData.pos.y > 120 and self._touchData.pos.y < 420 and endpos.y > 120 and endpos.y < 420 then
                local minX = math.min(endpos.x,self._touchData.pos.x)
                local maxX = math.max(endpos.x,self._touchData.pos.x)
                for k,v in pairsByKeys(self.nowCards)do
                    if v.cardPosX and 
                        ((v.cardPosX <= minX and v.cardPosX+v.cardDis >=  maxX) or--点击位置为一个扑克里面
                            (v.cardPosX <= minX and v.cardPosX+v.cardDis >=  minX) or
                            (v.cardPosX >= minX and v.cardPosX+v.cardDis <=  maxX) or
                            (v.cardPosX <= maxX and v.cardPosX+v.cardDis >=  maxX)) then 
                        if v and isValid(v.card) then
                            v.card:dark()
                            v.card.isDark = true
                        end
                    else
                        if v and isValid(v.card) then
                            v.card:light()
                            v.card.isDark = false
                        end
                    end
                end
            end
        end
        return true
    end,cc.Handler.EVENT_TOUCH_MOVED)
    listener1:registerScriptHandler(function (touch,event)--点击结束
        if self.sendCardStatus then return end
        local endpos = touch:getLocation()
        if FULLSCREENADAPTIVE then 
            endpos.x = endpos.x - (self.winSize.width/2-1920/2)
        end
        local minX = math.min(endpos.x,self._touchData.pos.x)
        local maxX = math.max(endpos.x,self._touchData.pos.x)
        local outCard = false
        local oneChooseCards = {}
        if self.parentView.firstChooseCard then
            for k,v in pairsByKeys(self.nowCards)do
                if v.card.isDark then
                    table.insert(oneChooseCards,v)
                end
            end
        end

        self.isTouchCards = false
        for k,v in pairsByKeys(self.nowCards)do
            if self._touchData.pos.y > 120 and self._touchData.pos.y < 420 and endpos.y > 120 and endpos.y < 420 then
                if v.cardPosX and not self._touchOut.status and
                    ((v.cardPosX <= minX and v.cardPosX+v.cardDis >=  maxX) or--点击位置为一个扑克里面
                        (v.cardPosX <= minX and v.cardPosX+v.cardDis >=  minX) or
                        (v.cardPosX >= minX and v.cardPosX+v.cardDis <=  maxX) or
                        (v.cardPosX <= maxX and v.cardPosX+v.cardDis >=  maxX)) then 
                    if not v.isselect then 
                        if  self._touchData.pos.y < 420 and endpos.y < 420 then
                            v.isselect = true
                            v.card:setPositionY(v.card:getContentSize().height/2+30)
                            self.isTouchCards = true
                        end
                    else
                        v.isselect = nil
                        v.card:setPositionY(v.card:getContentSize().height/2)
                        self.isTouchCards = true
                    end    
                end
            elseif
                self._touchData.pos.y > 120 and self._touchData.pos.y < 420 
                and endpos.y >= 420 
                and v.cardPosX <= self._touchData.pos.x and v.cardPosX+v.cardDis >=  self._touchData.pos.x then

                local isselect = v.isselect
                v.isselect = true
                self:canOutCardsView()
                outCard = self.parentView:outCardFun(true)
                v.isselect = isselect
                self.isTouchCards = true
            end
            if v and isValid(v.card) then 
                v.card:light()
                v.card.isDark = false
            end
        end
        self._touchOut = {}
        self:updateCardsPosX(self.nowCards)
        if not outCard then
            self:canOutCardsView(oneChooseCards)
        end
    end,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self.parentP:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.parentP)
end

--判断目前选择的牌能否出牌
function M:canOutCardsView( oneChooseCards )
    local tempCards = {}
    local isLianXuan = {index = 0,status = true}
    for k,v in pairsByKeys(self.nowCards)do
        if v.isselect or v.card:getPositionY() == v.card:getContentSize().height/2 + 30 then
            v.isselect = true
            table.insert(tempCards,v)
        end
    end
    if self.otherCards ~= nil and self.otherCards.cards ~= nil and tempCards and #tempCards>0 then
        local chooseOutCards = {}
        if self.mineAllCanOutCards and self.parentView.firstChooseCard and --智能选牌
            (self.otherCards.type == DDZ_CardType.cardType_DuiZi or
                self.otherCards.type == DDZ_CardType.cardType_SanZhang or
                self.otherCards.type == DDZ_CardType.cardType_SanDaiYi or
                self.otherCards.type == DDZ_CardType.cardType_SanDaiDui or
                self.otherCards.type == DDZ_CardType.cardType_ShunZi or
                self.otherCards.type == DDZ_CardType.cardType_LianDui or
                self.otherCards.type == DDZ_CardType.cardType_FeiJiDaiDan or
                self.otherCards.type == DDZ_CardType.cardType_Feiji or
                self.otherCards.type == DDZ_CardType.cardType_FeiJiDaiDui) then
            chooseOutCards = self:chooseCardWithAI(tempCards)
            if chooseOutCards and #chooseOutCards > 0 then
                self.parentView.firstChooseCard = nil
            else
                self.mineAllCanOutCards,chooseOutCards = DDZ_cardManage:getCardsList(self.nowCards,tempCards,self.otherCards,true)
            end
        else
            self.mineAllCanOutCards,chooseOutCards = DDZ_cardManage:getCardsList(self.nowCards,tempCards,self.otherCards,true)
        end
        if chooseOutCards and #chooseOutCards > 0 then
            self.parentView:canOutCardsView(true)
            return true
        else
            self.parentView:canOutCardsView(false)
            return false
        end 
    elseif tempCards and #tempCards>0 then
        if self.parentView.firstChooseCard then--智能选牌
            local chooseCards = DDZ_cardManage:chooseCardWithAI(self.nowCards,tempCards,oneChooseCards)
            if chooseCards and #chooseCards>0 then
                if oneChooseCards and #oneChooseCards>5 then
                    tempCards = chooseCards
                    for k,v in pairs(oneChooseCards)do
                        local choose = false
                        for m,n in pairs(chooseCards)do
                            if v.value == n.value then
                                choose = true
                                break
                            end
                        end
                        if not choose then
                            v.isselect = false
                            v.card:setPositionY(v.card:getContentSize().height/2)
                        end
                    end
                else
                    tempCards = chooseCards
                    for k,v in pairsByKeys(tempCards)do
                        if not v.isselect then
                            v.isselect = true
                            v.card:setPositionY(v.card:getContentSize().height/2+30)
                        end
                    end 
                end
                self.parentView.firstChooseCard = nil
            end
        end
        local cardstype = DDZ_cardManage:getChooseCardsType(tempCards)
        if cardstype ~= DDZ_CardType.cardType_Error then
            self.parentView:canOutCardsView(true)
            return true
        else
            self.parentView:canOutCardsView(false)
            return false
        end
    else
        if #self.nowCards ~= 0 then
            self.parentView:canOutCardsView(false)
        end
        return false
    end
end

function M:clearOtherCards()
    self.otherCards = {}
    self.chooseIndex = 1
end

--接牌的智能选牌(选的牌)
function M:chooseCardWithAI( tempCards )
    if (#tempCards)<3 and 
        (self.otherCards.type == DDZ_CardType.cardType_ShunZi or 
        self.otherCards.type == DDZ_CardType.cardType_LianDui or 
        self.otherCards.type == DDZ_CardType.cardType_Feiji or 
        self.otherCards.type == DDZ_CardType.cardType_FeiJiDaiDan or 
        self.otherCards.type == DDZ_CardType.cardType_FeiJiDaiDui) or #(self.otherCards.cards) < #tempCards then 
        return
    end
    for k=#self.mineAllCanOutCards,1,-1 do--和提示列表里面的扑克进行比较
        local v = self.mineAllCanOutCards[k]
        if DDZ_cardManage:getChooseCardsType(v) ~= DDZ_CardType.cardType_ZhaDan and DDZ_cardManage:getChooseCardsType(v) ~= DDZ_CardType.cardType_WangZha then
            local compareCards = {}
            if self.otherCards.type == DDZ_CardType.cardType_SanDaiYi or 
                self.otherCards.type == DDZ_CardType.cardType_SanDaiDui or 
                self.otherCards.type == DDZ_CardType.cardType_FeiJiDaiDan or 
                self.otherCards.type == DDZ_CardType.cardType_FeiJiDaiDui then 
                local cardsBySize,cardsByNum = DDZ_cardManage:analyzeCards(v)
                if cardsByNum[3] then
                    for m,n in pairs(cardsByNum[3])do
                        table.insertto(compareCards,v)
                    end
                end
            else
                compareCards = v
            end
            local chooseSucess = true

            for a,b in pairs(tempCards)do--选的扑克和提示的一致就行
                local nocard = false
                for m,n in pairsByKeys(compareCards)do
                    if b.cardvalue == n.cardvalue then
                        nocard = true
                        break
                    end
                end
                if not nocard then
                    chooseSucess = nil
                    break
                end
            end
            if chooseSucess then
                local cardsBySize,cardsByNum = DDZ_cardManage:analyzeCards(tempCards)
                local outCards = self:changeCardWithChoose(v,cardsBySize)
                for m,n in pairs(outCards) do
                    for a,b in pairs(self.nowCards)do
                        if n.value == b.value then
                            b.isselect = true
                            b.card:setPositionY(b.card:getContentSize().height/2+30)
                        end
                    end
                end
                return outCards
            end
        end
    end
end
--[[运算后得到的牌也许和玩家选择的值一样但并不是同一个，将玩家的扑克替换下运算后的扑克
    例：玩家有扑克：黑桃3,梅花3
    玩家选择黑桃3
    系统运算需要梅花3
    将运算结果列表中的梅花3用黑桃3替换
--]]
function M:changeCardWithChoose( outCards,chooseCardBySize )
    local endCard = outCards
    for k,v in pairsByKeys(endCard)do
        if chooseCardBySize[v.cardvalue] and  #chooseCardBySize[v.cardvalue]>0 then 
            for m,n in pairsByKeys(chooseCardBySize[v.cardvalue])do
                if n.value == v.value then 
                    endCard[k].iscommonValue = true 
                    chooseCardBySize[v.cardvalue][m].iscommonValue = true
                end
            end
        end
    end
    for k,v in pairsByKeys(endCard)do
        if chooseCardBySize[v.cardvalue] and  #chooseCardBySize[v.cardvalue]>0 and not v.iscommonValue then 
            for m,n in pairsByKeys(chooseCardBySize[v.cardvalue])do
                if n.cardvalue == v.cardvalue and not n.iscommonValue then 
                    chooseCardBySize[v.cardvalue][m].iscommonValue = true
                    endCard[k] = chooseCardBySize[v.cardvalue][m]
                end
            end
        end
    end
    return endCard
end


--判断选中的牌是否能出
function M:getOutCards( ... )
    local tempCards = {}
    local cards = {}
    for k,v in pairsByKeys(self.nowCards)do
        if v.isselect then
            table.insert(tempCards,v)
            table.insert(cards,v.valueId)
        end
    end 
    if tempCards and #tempCards>0 then
        local cardstype = DDZ_cardManage:getChooseCardsType(tempCards)
        loga(DDZ_CardType.cardTypeName[cardstype])
        return cards,cardstype
    end
    return cards,DDZ_CardType.cardType_Error
end

--判断是不是能一次性出完
function M:isCanOutAll( ... )
    local cardstype = DDZ_cardManage:getChooseCardsType(self.nowCards)
    if cardstype == DDZ_CardType.cardType_Error or  cardstype == DDZ_CardType.cardType_SiDaiDui or cardstype == DDZ_CardType.cardType_SiDaiEr then 
        return false
    else
        return true
    end
end

--获得所有能出的扑克（提示列表）
function M:getAllCanOutCards(cards,type)
    self.otherCards.cards = cards
    self.otherCards.type = type
    local includeZha = true
    self.mineAllCanOutCards = DDZ_cardManage:getCardsList(self.nowCards,nil,self.otherCards,includeZha)
    self.chooseIndex = 1
end
 
--显示选择的扑克
function M:showMineChooseCards(outcards,notneedchoose)
    if not self.otherCards or not self.otherCards.cards then
        self.mineAllCanOutCards = DDZ_cardManage:getCardsList(self.nowCards,nil,nil,true)
    end
    if not self.mineAllCanOutCards then 
        return nil
    end
    if self.chooseIndex > #self.mineAllCanOutCards then 
        self.chooseIndex = 1
    end
    local chooseCards = self.mineAllCanOutCards[self.chooseIndex]
    if outcards then 
        chooseCards = outcards
    end
    if not chooseCards then 
        return nil
    elseif notneedchoose then
        self:canOutCardsView()
        return true
    end
    for k,v in pairsByKeys(self.nowCards) do
        local ischoose = false
        if chooseCards and chooseCards.valueId then 
            if v.valueId == chooseCards.valueId then
                ischoose = true
            end
        else
            for m,n in pairsByKeys(chooseCards)do
                if v.valueId == n.valueId then
                    ischoose = true
                    break
                end
            end
        end
        if ischoose then
            v.isselect = true
            v.card:setPositionY(v.card:getContentSize().height/2+30)
        else
            v.isselect = nil
            v.card:setPositionY(v.card:getContentSize().height/2)
        end
    end
    self.parentView:canOutCardsView(true)
    self.chooseIndex = self.chooseIndex + 1
    return true
end

cardView = M
return cardView