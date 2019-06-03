local M = class("CardManage")
local cardType = import(".CardType")

-- // 点数= cards[i]/4+1; 花色= cards[i]%4; 0红 1黑 2梅 3方
local function getCardFileName (value)
    if value == nil then return nil end
    local point = value

    local i,t = math.modf(point/4)
    local c = math.fmod(point,4)
    local ret = nil
    local cardinfo = {}
    cardinfo.cardvalue = i + 3
    cardinfo.color = c
    cardinfo.value = point
    cardinfo.real_value = value
    return cardinfo
end

--获得三张携带的扑克(带的牌的牌型（1、单牌，2、对子）,带的牌的数目,能选的所有按数目排列的牌,选中牌后需要加入的表)
local function getFollowCard( cardtype,num,minecardsByNum,cardTable )
    local minecardsByNum1 = minecardsByNum[1] and #minecardsByNum[1] or 0
    local minecardsByNum2 = minecardsByNum[2] and #minecardsByNum[2] or 0
    local minecardsByNum3 = minecardsByNum[3] and #minecardsByNum[3] or 0
    if cardtype == 1 then --带单牌
        if num > minecardsByNum1+minecardsByNum2*2+minecardsByNum3*2 then return end--三张最多带2张牌
        local tempCards ={}
        local needCardsNum = 1
        if num<=minecardsByNum1 then needCardsNum = 1 
        elseif num<=minecardsByNum2+minecardsByNum1 then needCardsNum = 2             
        else needCardsNum = 3
        end
        local nowChooseNum = 0
        for k,v in pairsByKeys(minecardsByNum)do--把所有能带的牌加入零时列表
            if k<=needCardsNum then
                for m,n in pairsByKeys(v)do
                    for x,y in pairsByKeys (n)do
                        nowChooseNum = nowChooseNum + 1
                        table.insert(tempCards,y) 
                    end
                    if nowChooseNum>=num then
                        break
                    end
                end
                if nowChooseNum>=num then
                    break
                end
            end
        end
        table.sort(tempCards,function( a,b )--给零时列表排序，获取小的扑克
            return a.cardvalue<b.cardvalue
        end)
        for i=1,num do
            table.insert(cardTable,tempCards[i]) 
        end
    else--带对子
        if num > 2*(minecardsByNum2+minecardsByNum3) then return end--三张最多带2张牌
        local tempCards ={}
        local nowChooseNum = 0
        for k,v in pairsByKeys(minecardsByNum)do--把所有能带的牌加入零时列表
            if k==2 or k==3 then 
                for m,n in pairsByKeys(v)do
                    local duizi = {}
                    table.insert(duizi,n[1]) 
                    table.insert(duizi,n[2]) 
                    nowChooseNum = nowChooseNum + 2
                    table.insert(tempCards,duizi) 
                    if nowChooseNum>=num then
                        break
                    end
                end
            end
            if nowChooseNum>=num then
                break
            end
        end
        for i=1,num/2 do--获取零食扑克的最小的几个加入队列
            for k,v in pairsByKeys(tempCards[i])do
                table.insert(cardTable,v) 
            end
        end
    end
end



function M:ctor( ... )
	

end
 
--分析扑克（获得扑克按个数分开和按大小分开的表）
function M:analyzeCards(cards)
    local cardsBySize = {}
    local cardsByNum = {} 
    for k,v in pairsByKeys(cards) do 
        if not cardsBySize[v.cardvalue] then
            cardsBySize[v.cardvalue] = {}
        end
        table.insert(cardsBySize[v.cardvalue],v)
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
--判断最大值
function M:getMaxCards( cardsTable )
    local maxCard = 0
    if cardsTable.type == DDZ_CardType.cardType_SanZhang or
        cardsTable.type == DDZ_CardType.cardType_SanDaiYi or
        cardsTable.type == DDZ_CardType.cardType_SanDaiDui or 
        cardsTable.type == DDZ_CardType.cardType_Feiji or
        cardsTable.type == DDZ_CardType.cardType_FeiJiDaiDan or
        cardsTable.type == DDZ_CardType.cardType_FeiJiDaiDui or
        cardsTable.type == DDZ_CardType.cardType_SiDaiDui or
        cardsTable.type == DDZ_CardType.cardType_SiDaiEr then
        local tempCards = {}
        for k,v in pairsByKeys(cardsTable.cards)do
            table.insert(tempCards,getCardFileName(v))
        end
        local cardsBySize,cardsByNum = self:analyzeCards(tempCards)
        for k,v in pairsByKeys(cardsByNum)do
            if k >2 then
                for m,n in pairsByKeys(v)do
                    if maxCard<n[1].cardvalue then
                        maxCard = n[1].cardvalue
                    end
                end
            end
        end
    else
        maxCard = getCardFileName(cardsTable.cards[1]).cardvalue
    end
    return maxCard
end

--提示获取能出的扑克列表(所有的手牌，选择的牌，他人出的牌)
function M:getCardsList(allCards,chooseCards,otherCards,includeZha)
    local tempAllCards = clone(allCards)
    local cardsBySize = {}
    local cardsByNum = {}
    local outCards = {}
    local otherMaxCard = 0
    local otherCardsTable = {}
	cardsBySize,cardsByNum = self:analyzeCards(tempAllCards)
    if otherCards and #otherCards.cards>0 then --根据其他人的扑克判断自己手中比他大的扑克有哪些
        for k,v in pairs(otherCards.cards) do
            table.insert(otherCardsTable,v)
        end
        otherCards.cards = otherCardsTable
        table.sort(otherCards.cards,function( a,b )
            return a > b
        end)
        otherMaxCard = self:getMaxCards(otherCards)
        local cardNum = #(otherCards.cards)
        if otherCards.type ~= DDZ_CardType.cardType_Error then
            local otherCardsType = otherCards.type
            local info ={
                minecardsBySize=cardsBySize,
                minecardsByNum=cardsByNum,
                maxcard=otherMaxCard,
                cardnum=cardNum,
                includeZha=true,
                chooseCards = chooseCards,
                cardtype = otherCardsType
            }
            if otherCardsType == DDZ_CardType.cardType_SanZhang or
                otherCardsType == DDZ_CardType.cardType_SanDaiYi or
                otherCardsType == DDZ_CardType.cardType_SanDaiDui or
                otherCardsType == DDZ_CardType.cardType_FeiJiDaiDan or
                otherCardsType == DDZ_CardType.cardType_Feiji  or
                otherCardsType == DDZ_CardType.cardType_FeiJiDaiDui then
                otherCardsType = DDZ_CardType.cardType_SanZhang
            elseif otherCardsType == DDZ_CardType.cardType_SiDaiEr or
                otherCardsType == DDZ_CardType.cardType_SiDaiDui then
                otherCardsType = DDZ_CardType.cardType_SiDaiDui
            elseif otherCardsType == DDZ_CardType.cardType_WangZha then
                return outCards,nil
            end
            outCards = self["getCardsWithType"..otherCardsType](self,info)
        end
    else--获取提示列表
        if self:getChooseCardsType(tempAllCards)~=DDZ_CardType.cardType_Error then 
            table.insert(outCards,tempAllCards)
        else
            local info ={
                minecardsBySize=cardsBySize,
                minecardsByNum=cardsByNum,
                maxcard=2,
                cardnum=1,
                includeZha=false,
                onlynowType = true,
                cardtype = DDZ_CardType.cardType_DanZhang
            }
            local cards0 = self["getCardsWithType0"](self,info)--将单牌加入提示列表
            info.cardnum = 2
            info.cardtype = DDZ_CardType.cardType_DuiZi
            local cards1 = self["getCardsWithType1"](self,info)--将单牌加入提示列表
            info.cardnum = 4
            info.cardtype = DDZ_CardType.cardType_SanDaiYi
            local cards4 = self["getCardsWithType2"](self,info)--将三带一加入提示列表
            if not cards4 or #cards4<1 then
                info.cardnum = 3
                info.cardtype = DDZ_CardType.cardType_SanZhang
                cards4 = self["getCardsWithType2"](self,info)--将三张加入提示列表
            end
            info.cardnum = 4
            info.cardtype = DDZ_CardType.cardType_ZhaDan
            local cards9 = self["getCardsWithType19"](self,info)--将四张加入提示列表
            for k,v in pairs(cards0)do
                table.insert(outCards,v)
            end
            for k,v in pairs(cards1)do
                table.insert(outCards,v)
            end
            for k,v in pairs(cards4)do
                table.insert(outCards,v)
            end
            for k,v in pairs(cards9)do
                table.insert(outCards,v)
            end
        end
    end
    local outChooseCards = {}
    if chooseCards then --从选择的扑克中显示能出的牌
        local choosecardtype = self:getChooseCardsType(chooseCards)
        local cardsTable = {}
        local cards = {}
        for k,v in pairs(chooseCards) do
            table.insert(cards,v.value)
        end
        cardsTable.cards = cards
        table.sort(cardsTable.cards,function( a,b )
            return a > b
        end)
        local maxCard = self:getMaxCards(cardsTable)
        if choosecardtype ~= otherCards.type then
            if choosecardtype == DDZ_CardType.cardType_ZhaDan or choosecardtype == DDZ_CardType.cardType_WangZha then 
                outChooseCards = chooseCards
            end
        else
            if maxCard > otherMaxCard and #chooseCards==#(otherCards.cards) then
                outChooseCards = chooseCards
            end
        end
    end
    return outCards,outChooseCards
end

--智能选牌
function M:chooseCardWithAI( allCards,chooseCard,oneChooseCards )
    local outCards = {}
    dump(oneChooseCards)
    if oneChooseCards and #oneChooseCards>5 then
        local canOutCards = {}
        local cardsBySize,cardsByNum = self:analyzeCards(oneChooseCards)
        if cardsByNum[3] and #cardsByNum[3]>2 then--飞机
            local nowTable = {}
            local nowValue = 0
            local copyCards = tbl_copy(cardsByNum)
            for k,v in pairsByKeys(cardsBySize)do
                if (nowValue == 0 or k == nowValue + 1) and #v == 3 then
                    nowValue = k
                    table.insertto(nowTable,v)
                    for m,n in pairsByKeys(copyCards[#v])do
                        if n[1].cardvalue==k then
                            copyCards[#v][m]=nil
                        end
                    end
                else
                    if #nowTable>=6 then--判断是否可以组成飞机
                        --给飞机带牌，优先带对子，没有再考虑带单牌
                        local tableNum = #nowTable
                        getFollowCard(2,#nowTable/3,copyCards,nowTable)
                        if tableNum==#nowTable then
                            getFollowCard(1,#nowTable/3,copyCards,nowTable)
                        end
                        table.insert(canOutCards,tbl_copy(nowTable))
                    end
                    nowValue = 0
                    nowTable = {}
                    copyCards = tbl_copy(cardsByNum)
                    if #v == 3 then
                        nowValue = k
                        table.insertto(nowTable,v)
                        for m,n in pairsByKeys(copyCards[#v])do
                            if n[1].cardvalue==k then
                                copyCards[#v][m]=nil
                            end
                        end
                    end
                end
            end   
            if #nowTable>=6 then--判断是否可以组成飞机
                --给飞机带牌，优先带对子，没有再考虑带单牌
                local tableNum = #nowTable
                getFollowCard(2,#nowTable/3,copyCards,nowTable)
                if tableNum==#nowTable then
                    getFollowCard(1,#nowTable/3,copyCards,nowTable)
                end
                table.insert(canOutCards,tbl_copy(nowTable))
            end     
        end
        --判断连对
        local nowTable = {}
        local nowValue = 0
        for k,v in pairsByKeys(cardsBySize)do
            if (nowValue == 0 or k == nowValue + 1) and #v >= 2 and #v <= 3 and k<15 then
                nowValue = k
                table.insert(nowTable,v[1])
                table.insert(nowTable,v[2])
            else
                if #nowTable>=6 then--判断是否可以组成连对
                    table.insert(canOutCards,tbl_copy(nowTable))
                end
                nowValue = 0
                nowTable = {}
                if #v >= 2 and #v <= 3 then
                    nowValue = k
                    table.insert(nowTable,v[1])
                    table.insert(nowTable,v[2])
                end
            end
        end 
        if #nowTable>=6 then--判断是否可以组成连对
            table.insert(canOutCards,tbl_copy(nowTable))
        end
        dump(canOutCards)
        --判断顺子
        nowTable = {}
        nowValue = 0
        for k,v in pairsByKeys(cardsBySize)do
            if (nowValue == 0 or k == nowValue + 1) and k<15 and #v<4 then
                nowValue = k 
                table.insert(nowTable,v[1])
            else
                if #nowTable>=5 then--判断是否可以组成顺子
                    table.insert(canOutCards,tbl_copy(nowTable))
                end
                nowValue = k
                nowTable = {}
                table.insert(nowTable,v[1])
            end
        end 
        if #nowTable>=5 then--判断是否可以组成顺子
            table.insert(canOutCards,tbl_copy(nowTable))
        end
        dump(canOutCards)
        if #canOutCards>0 then--从所有选出来的牌型中选出数目最多并且跨度最大的牌
            for k,v in pairs(canOutCards)do
                if #outCards < #v then
                    outCards = v
                elseif #outCards == #v then
                    local outCardsBySize,outCardsByNum = self:analyzeCards(outCards)
                    local vBySize,vByNum = self:analyzeCards(v)
                    if table.nums(outCardsBySize) < table.nums(vBySize) then
                        outCards = v
                    end
                end
            end
            return outCards
        end
    elseif #chooseCard<5 and #chooseCard>1 then
        local cardsBySize,cardsByNum = self:analyzeCards(allCards)
        local chooseCardBySize,chooseCardByNum = self:analyzeCards(chooseCard)
        local info ={
                    minecardsBySize=cardsBySize,
                    minecardsByNum=cardsByNum,
                    cardnum=5,
                    includeZha=false,
                    onlynowType = true,
                    cardtype = DDZ_CardType.cardType_ShunZi,
                    maxoutcard = chooseCardByNum[1] and #chooseCardByNum[1]>=1 and chooseCardByNum[1][1][1].cardvalue
                }
        local outCards = {}
        if #chooseCard == 2 then
            if chooseCardByNum[1] and #chooseCardByNum[1]>1 and chooseCardByNum[1][2][1].cardvalue<15 then--点击/连选 C D （D>C）两张不同的牌（大小王、2不算在内）
                if chooseCardByNum[1][2][1].cardvalue - chooseCardByNum[1][1][1].cardvalue <=4 then--D-C<=4  组成最大 的5张的顺子，将剩余牌升起
                    info.maxcard=chooseCardByNum[1][2][1].cardvalue-2
                else--D-C>4 组成以C起始D收尾的顺子，将剩余牌升起
                    info.cardnum = chooseCardByNum[1][2][1].cardvalue - chooseCardByNum[1][1][1].cardvalue+1
                    info.maxcard=chooseCardByNum[1][2][1].cardvalue-1
                end
                outCards = self["getCardsWithType6"](self,info)
            end 
        elseif #chooseCard == 3 then
            if chooseCardByNum[1] and #chooseCardByNum[1]==1 
                and chooseCardByNum[2] and #chooseCardByNum[2]==1 and chooseCardByNum[1][1][1].cardvalue>chooseCardByNum[2][1][1].cardvalue and chooseCardByNum[2][1][1].cardvalue<15 then -- 点击/连选  CCD（D>C）三张牌（大小王、2不算在内）
                info.cardtype = DDZ_CardType.cardType_LianDui
                info.maxoutcard = info.maxoutcard -1
                if chooseCardByNum[1][1][1].cardvalue-chooseCardByNum[2][1][1].cardvalue<=2 then
                    info.cardnum = 6
                    info.maxcard= chooseCardByNum[1][1][1].cardvalue-2
                else
                    info.maxoutcard = chooseCardByNum[2][1][1].cardvalue
                    info.cardnum = (chooseCardByNum[1][1][1].cardvalue - chooseCardByNum[2][1][1].cardvalue+1)*2
                    info.maxcard = chooseCardByNum[2][1][1].cardvalue + info.cardnum/2 - 2
                end
                outCards = self["getCardsWithType7"](self,info)
            end
        elseif #chooseCard == 4 then
            if chooseCardByNum[1] and #chooseCardByNum[1]==1 
                and chooseCardByNum[3] and #chooseCardByNum[3]==1 and chooseCardByNum[1][1][1].cardvalue>chooseCardByNum[3][1][1].cardvalue and chooseCardByNum[3][1][1].cardvalue<15 then -- 点击/连选  CCD（D>C）三张牌（大小王、2不算在内）
                info.cardtype = DDZ_CardType.cardType_SanZhang
                info.maxoutcard = info.maxoutcard -1
                if chooseCardByNum[1][1][1].cardvalue-chooseCardByNum[3][1][1].cardvalue<=1 then
                    info.cardnum = 6
                    info.maxcard= chooseCardByNum[1][1][1].cardvalue-2
                else
                    info.maxoutcard = chooseCardByNum[3][1][1].cardvalue
                    info.cardnum = (chooseCardByNum[1][1][1].cardvalue - chooseCardByNum[3][1][1].cardvalue+1)*3
                    info.maxcard = chooseCardByNum[3][1][1].cardvalue + info.cardnum/3 - 2
                end
                outCards = self["getCardsWithType2"](self,info)
            end
        end
        if outCards and #outCards>0 then --去除多余的扑克
            local endCard = outCards[#outCards]
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
                            endCard[k] = chooseCardBySize[v.cardvalue][m]
                        end
                    end
                end
            end
            return endCard
        end
    end
    return nil
end

--单张(我的扑克按大小排序，我的扑克按数目排序，他人扑克最大的值，他人扑克数目)
function M:getCardsWithType0(info)
    local cards={}
    for k,v in pairsByKeys(info.minecardsByNum)do
        --把所有的比当前牌大的单张加进列表
        if k == 1 then--只加单牌
            for m,n in pairsByKeys(v)do
                if n[1].cardvalue>info.maxcard then
                    table.insert(cards,n[1])
                end
            end
        elseif not info.onlynowType and k<4 then--将对子和三张拆了
            for m,n in pairsByKeys(v)do
                if n[1].cardvalue>info.maxcard then
                    table.insert(cards,n[1])
                end
            end
        end
    end
    -- table.sort(cards,function( a,b )
    --     return a.cardvalue<b.cardvalue
    -- end)
    --把炸弹加进去
    if info.includeZha then 
        info.maxcard = 2
        local zhadan = self:getCardsWithType19(info)
        for k,v in pairsByKeys(zhadan)do
            table.insert(cards,v)
        end
    end
    return cards
end

--对子(我的扑克按大小排序，我的扑克按数目排序，他人扑克最大的值，他人扑克数目)
function M:getCardsWithType1(info)
    local cards={}
    for k,v in pairsByKeys(info.minecardsByNum)do
        --把所有的比当前牌大的单张加进列表
        if k == 2 or (not info.onlynowType and k==3) then--只加单牌
            for m,n in pairsByKeys(v)do
                if n[1].cardvalue>info.maxcard then
                    table.insert(cards,{n[1],n[2]})
                end
            end
        end
    end
    -- table.sort(cards,function( a,b )
    --     return a[1].cardvalue<b[1].cardvalue
    -- end)
    --把炸弹加进去
    if info.includeZha then 
        info.maxcard = 2
        local zhadan = self:getCardsWithType19(info)
        for k,v in pairsByKeys(zhadan)do
            table.insert(cards,v)
        end
    end
    return cards
end

--连对(我的扑克按大小排序，我的扑克按数目排序，他人扑克最大的值，他人扑克数目)(我的扑克按大小排序，我的扑克按数目排序，他人扑克最大的值，他人扑克数目)
function M:getCardsWithType7(info)
    -- body
    local cards={}
    info.cardnum = info.cardnum/2
    local mincardValue =  info.maxcard - info.cardnum + 2--出的牌需要比最小的大1
    for k=mincardValue,info.maxoutcard or 15-info.cardnum,1 do
        local cardTable = {}
        for v=k,k+info.cardnum-1,1 do
            if not info.minecardsBySize[v] or #info.minecardsBySize[v] < 2 or #info.minecardsBySize[v]==4 then
                cardTable = {}
                break
            else
                table.insert(cardTable,info.minecardsBySize[v][1])
                table.insert(cardTable,info.minecardsBySize[v][2])
            end
        end
        if cardTable and #cardTable==info.cardnum*2 then
            table.insert(cards,cardTable)
        end
    end
    --把炸弹加进去
    if info.includeZha then 
        info.maxcard = 2
        local zhadan = self:getCardsWithType19(info)
        for k,v in pairsByKeys(zhadan)do
            table.insert(cards,v)
        end
    end
    return cards
end

--顺子(我的扑克按大小排序，我的扑克按数目排序，他人扑克最大的值，他人扑克数目)
function M:getCardsWithType6(info)
    local cards={}
    local mincardValue =  info.maxcard - info.cardnum + 2--出的牌需要比最小的大2
    for k=mincardValue,info.maxoutcard or 15-info.cardnum,1 do-- 取最小能出的扑克到最大能出的扑克中间的所有值判断
        local cardTable = {}
        for v=k,k+info.cardnum-1,1 do--计算当前能出扑克之后的cardnum位是否符合顺子
            if not info.minecardsBySize[v] or #info.minecardsBySize[v] < 1 or #info.minecardsBySize[v]==4 then
                cardTable = {}
                break
            else
                table.insert(cardTable,info.minecardsBySize[v][1])
            end
        end
        if cardTable and #cardTable==info.cardnum then
            table.insert(cards,cardTable)
        end
    end
    --把炸弹加进去
    if info.includeZha then 
        info.maxcard = 2
        local zhadan = self:getCardsWithType19(info)
        for k,v in pairsByKeys(zhadan)do
            table.insert(cards,v)
        end
    end
    return cards
end
--三张(我的扑克按大小排序，我的扑克按数目排序，他人扑克最大的值，他人扑克数目)
function M:getCardsWithType2(info)
    local cards={}
    if info.cardnum <= 5 then--三张
        for k,v in pairsByKeys(info.minecardsBySize)do
            --把所有的比当前牌大的三张加进列表
            if k>info.maxcard and #v==3 then 
                local cardTable = v
                local minecardsByNum = tbl_copy(info.minecardsByNum)
                for m,n in pairsByKeys(minecardsByNum[#v])do
                    if n[1].cardvalue==k then
                        minecardsByNum[#v][m]=nil
                    end
                end
                if info.cardtype == DDZ_CardType.cardType_SanDaiYi then--三带一
                    getFollowCard(1,1,minecardsByNum,cardTable)
                elseif info.cardtype == DDZ_CardType.cardType_SanDaiDui then--三带对
                    getFollowCard(2,2,minecardsByNum,cardTable)
                end
                if #cardTable == info.cardnum then
                    table.insert(cards,cardTable)
                end
            end
        end
        table.sort(cards,function( a,b )
            return a[1].cardvalue<b[1].cardvalue
        end)
    else--连三张
        if info.cardtype == DDZ_CardType.cardType_SanDaiYi or info.cardtype == DDZ_CardType.cardType_FeiJiDaiDan then
            info.cardnum = info.cardnum/4
        elseif info.cardtype == DDZ_CardType.cardType_SanDaiDui or info.cardtype == DDZ_CardType.cardType_FeiJiDaiDui then
            info.cardnum = info.cardnum/5
        else
            info.cardnum = info.cardnum/3
        end
        local mincardValue =  info.maxcard - info.cardnum + 2--出的牌需要比最小的大2
        for k=mincardValue,info.maxoutcard or 15-info.cardnum,1 do
            local cardTable = {}
            local minecardsByNum = tbl_copy(info.minecardsByNum) 
            for v=k,k+info.cardnum-1,1 do
                if not info.minecardsBySize[v] or #info.minecardsBySize[v] < 3 or #info.minecardsBySize[v]==4 then
                    cardTable = {}
                    break
                else
                    table.insert(cardTable,info.minecardsBySize[v][1])
                    table.insert(cardTable,info.minecardsBySize[v][2])
                    table.insert(cardTable,info.minecardsBySize[v][3])
                    for m,n in pairsByKeys(minecardsByNum[#info.minecardsBySize[v]])do
                        if n[1].cardvalue==v then
                            minecardsByNum[#info.minecardsBySize[v]][m]=nil
                        end
                    end
                end
            end
            if cardTable and #cardTable==info.cardnum*3 then--添加三张携带的扑克进列表
                if info.cardtype == DDZ_CardType.cardType_SanDaiYi or info.cardtype == DDZ_CardType.cardType_FeiJiDaiDan then--三带1
                    getFollowCard(1,info.cardnum,minecardsByNum,cardTable)
                    if #cardTable == info.cardnum*4 then
                        table.insert(cards,cardTable)
                    end
                elseif info.cardtype == DDZ_CardType.cardType_SanDaiDui or info.cardtype == DDZ_CardType.cardType_FeiJiDaiDui then--三带两对子
                    getFollowCard(2,info.cardnum*2,minecardsByNum,cardTable)
                    if #cardTable == info.cardnum*5 then
                        table.insert(cards,cardTable)
                    end
                elseif info.cardtype == DDZ_CardType.cardType_SanZhang then
                    table.insert(cards,cardTable)
                end
            end
        end
    end
    --把炸弹加进去
    if info.includeZha then 
        info.maxcard = 2
        local zhadan = self:getCardsWithType19(info)
        for k,v in pairsByKeys(zhadan)do
            table.insert(cards,v)
        end
    end
    return cards
end

-- --三条带一(我的扑克按大小排序，我的扑克按数目排序，他人扑克最大的值，他人扑克数目)
-- function M:getCardsWithType5(minecardsBySize,minecardsByNum,maxcard,cardnum,includeZha)
--     local cards={}
--     for k,v in pairs(minecardsBySize)do
--         --把所有的比当前牌大的对子加进列表
--         if k>maxcard and #v>=cardnum then 
--             local card = {v[1],v[2],v[3]}
--             table.insert(cards,card)
--         end
--     end
--     table.sort(cards,function( a,b )
--         return a[1].cardvalue<b[1].cardvalue
--     end)
--     --把炸弹加进去
--     if info.includeZha then 
--         for k,v in pairsByKeys(info.minecardsByNum[4])do
--             for m,n in pairs(v)do 
--                 table.insert(cards,n)
--             end
--         end
--     end
--     return cards
-- end

-- --三带一对(我的扑克按大小排序，我的扑克按数目排序，他人扑克最大的值，他人扑克数目)
-- function M:getCardsWithType6(minecardsBySize,minecardsByNum,maxcard,cardnum,includeZha)
--     local cards={}
--     cardnum = cardnum/3
--     local mincardValue =  maxcard - cardnum + 2--出的牌需要比最小的大2
--     for k=mincardValue,15-cardnum,1 do
--         local cardTable = {}
--         for v=k,k+cardnum-1,1 do
--             if not minecardsBySize[v] or #minecardsBySize[v] < 3 then
--                 cardTable = {}
--                 break
--             else
--                 table.insert(cardTable,minecardsBySize[v][1])
--                 table.insert(cardTable,minecardsBySize[v][2])
--                 table.insert(cardTable,minecardsBySize[v][3])
--             end
--         end
--         if cardTable and #cardTable==cardnum*3 then
--             table.insert(cards,cardTable)
--         end
--     end
--     --把炸弹加进去
--     if info.includeZha then 
--         for k,v in pairsByKeys(info.minecardsByNum[4])do
--             for m,n in pairs(v)do 
--                 table.insert(cards,n)
--             end
--         end
--     end
--     return cards
-- end

--四带二(我的扑克按大小排序，我的扑克按数目排序，他人扑克最大的值，他人扑克数目)
function M:getCardsWithType12(info)

    local cards={}
    local minecardsByNum1 = info.minecardsByNum[1] and #info.minecardsByNum[1] or 0
    local minecardsByNum2 = info.minecardsByNum[2] and #info.minecardsByNum[2] or 0
    local minecardsByNum3 = info.minecardsByNum[3] and #info.minecardsByNum[3] or 0
    if (not info.minecardsByNum[4] or #info.minecardsByNum[4]<1) and not info.minecardsByNum[9] then 
        return 
    end

    if info.minecardsByNum[9] then
        for m,n in pairsByKeys(info.minecardsByNum[9])do
            local outCards = tbl_copy(n)
            table.insert(cards,outcard)
        end
    end
    
    if info.minecardsByNum[4] then
    --把所有的比当前牌大的炸弹加进列表
        for m,n in pairsByKeys(info.minecardsByNum[4])do
            if n[1].cardvalue>info.maxcard then
                local outcard=tbl_copy(n)
                if info.cardnum == 6 and minecardsByNum1+minecardsByNum2*2+minecardsByNum3*2>=2 then--4带2
                    getFollowCard(1,2,info.minecardsByNum,outcard)
                elseif info.cardnum == 8 and minecardsByNum2+minecardsByNum3>=2 then--四带两对子
                    getFollowCard(2,4,info.minecardsByNum,outcard)
                end
                table.insert(cards,outcard)
            end
        end
    end
    --把炸弹加进去
    if info.includeZha then 
        info.maxcard = 2
        local zhadan = self:getCardsWithType19(info)
        for k,v in pairsByKeys(zhadan)do
            table.insert(cards,v)
        end
    end
    return cards
end
--炸弹(我的扑克按大小排序，我的扑克按数目排序，他人扑克最大的值，他人扑克数目)
function M:getCardsWithType19(info)
    local cards={}
    --把所有的比当前牌大的炸弹加进列表
    if info.minecardsByNum[4] then
        for m,n in pairs(info.minecardsByNum[4])do
            if n[1].cardvalue>info.maxcard then
                table.insert(cards,n)
            end
        end
        table.sort(cards,function( a,b )
            return a[1].cardvalue<b[1].cardvalue
        end)
    end
    if info.minecardsByNum[9] then
        table.insert(cards,info.minecardsByNum[9][1])
    end
    return cards
end

--根据选中的手牌判断牌型
function M:getChooseCardsType(cards)
    if not cards or #cards<1 then return DDZ_CardType.cardType_Error end
    local cardsType = DDZ_CardType.cardType_Error
    if #cards == 1 then --单牌直接返回
        cardsType = DDZ_CardType.cardType_DanZhang
    else
        --先对选中的扑克排序
        table.sort( cards, function( a,b )
            return a.value < b.value
        end)
        local cardsNum = #cards 
        local isShunzi = true--默认所有扑克值能组成顺子
        local cardsBySize,cardsByNum = self:analyzeCards(cards)--将扑克按大小和数目分开
        --判断顺序：三张、顺子、对子（连对、王炸）、炸弹（四带二）
        if cardsByNum[3] and not cardsByNum[9] and not cardsByNum[4] then--判断是否是三张、三带一、三带二、飞机 去除王炸和炸弹
            local sanzhangNum = 0--判断三张的数目
            local cardValue 
            for k,v in pairsByKeys(cardsByNum[3])do--判断三张是否是连续的
                if not cardValue then 
                    cardValue = v[1].cardvalue 
                    sanzhangNum = 1
                elseif v[1].cardvalue ~= cardValue+1 and v[1].cardvalue ~= cardValue-1 or v[1].cardvalue>14 then
                    sanzhangNum = 0
                    break
                else
                    cardValue = v[1].cardvalue 
                    sanzhangNum = sanzhangNum + 1
                end
            end
            if sanzhangNum >0 then
                if 4*(#cardsByNum[3]) == cardsNum then--判断是否是3带1或飞机带单张
                    if sanzhangNum==1 then
                        cardsType = DDZ_CardType.cardType_SanDaiYi
                    else
                        cardsType = DDZ_CardType.cardType_FeiJiDaiDan
                    end
                elseif 5*(#cardsByNum[3]) == cardsNum then--判断是否是3带对或飞机带对子
                    local isDuizi = true
                    for k,v in pairs(cardsByNum)do
                        if k ~= 2 and k ~= 4 and k~=3 then
                            isDuizi = false
                            break
                        end
                    end
                    if isDuizi then
                        if sanzhangNum==1 then
                            cardsType = DDZ_CardType.cardType_SanDaiDui
                        else
                            cardsType = DDZ_CardType.cardType_FeiJiDaiDui
                        end
                    end 
                elseif sanzhangNum*3 == cardsNum then
                    if sanzhangNum==1 then
                        cardsType = DDZ_CardType.cardType_SanZhang
                    else
                        cardsType = DDZ_CardType.cardType_Feiji
                    end
                end
            end
        elseif cardsByNum[1] and #cardsByNum[1] == cardsNum and cardsNum >= 5 then--判断是否是顺子
            local cardValue 
            for k,v in pairsByKeys(cardsByNum[1])do--判断是否是顺子
                if not cardValue then 
                    cardValue = v[1].cardvalue 
                    sanzhangNum = 1
                elseif v[1].cardvalue  ~= cardValue+1 or v[1].cardvalue>14 then
                    isShunzi = false
                    break
                else
                    cardValue = v[1].cardvalue 
                    sanzhangNum = sanzhangNum + 1
                end
            end
            if isShunzi then
                cardsType = DDZ_CardType.cardType_ShunZi
            end
        elseif cardsByNum[4] and not cardsByNum[9] then--判断是否是炸弹或4带二
            if cardsNum == 4 then 
                cardsType = DDZ_CardType.cardType_ZhaDan
            elseif cardsNum == 6 then--判断是否是炸弹带两对、炸弹本身就是对子
                cardsType = DDZ_CardType.cardType_SiDaiEr
            elseif cardsNum == 8 and (cardsByNum[2] and #cardsByNum[2]==2) then--判断是否是炸弹带两对、炸弹本身就是对子
                cardsType = DDZ_CardType.cardType_SiDaiDui   
            end
        elseif cardsByNum[2] and #cardsByNum[2]*2 == cardsNum then--判断是否是对子、连对、王炸
            if #cardsByNum[2] >= 3 then
                local cardValue 
                for k,v in pairsByKeys(cardsByNum[2])do--判断是否是连对
                    if not cardValue then 
                        cardValue = v[1].cardvalue 
                        sanzhangNum = 1
                    elseif v[1].cardvalue ~= cardValue+1 or v[1].cardvalue>14 then
                        isShunzi = false
                        break
                    else
                        cardValue = v[1].cardvalue 
                        sanzhangNum = sanzhangNum + 1
                    end
                end
                if isShunzi then
                    cardsType = DDZ_CardType.cardType_LianDui
                end
            elseif #cardsByNum[2] == 1 then
                cardsType = DDZ_CardType.cardType_DuiZi
            end
        elseif cardsByNum[9] then--王炸
            if cardsNum == 2 then 
                cardsType = DDZ_CardType.cardType_WangZha
            end
        end

        
    end
    
    return cardsType
end

--将扑克按大小排序
function M:getCardsBySize(cards)
    local tempCards = cards
    table.sort(tempCards, function(a, b)
        return a.value < b.value
    end)
    return tempCards
end
--将扑克按数量排序
function M:getCardsByNum(cards)
    local cardsTable = {}
    local cardsTable1 = {}
    for k,v in pairs(cards)do
        if not cardsTable[v.card:getCardValue()] then
            cardsTable[v.card:getCardValue()] = {}
            cardsTable[v.card:getCardValue()].size = 0
            cardsTable[v.card:getCardValue()].point = v.card:getCardValue()
            cardsTable[v.card:getCardValue()].value = {}
        end
        if v.card:getCardValue() >=16 then
             cardsTable[v.card:getCardValue()].size = 9
        end
        cardsTable[v.card:getCardValue()].size = cardsTable[v.card:getCardValue()].size + 1
        table.insert(cardsTable[v.card:getCardValue()].value,v)
    end
    for k ,v in pairs(cardsTable)do 
        table.insert(cardsTable1,v)
    end
    table.sort(cardsTable1, function(a, b)
        return a.size == b.size and a.point<b.point or a.size < b.size
    end)
    local cardsList = {}
    for k ,v in pairsByKeys(cardsTable1)do
        for m,n in pairsByKeys(v.value)do
            table.insert(cardsList,n)
        end
    end
    return cardsList
end

--将扑克按数量排序
function M:geRememberCardsByNum(cards)
    local rememberCards = {}
    for i=3,17 do
        rememberCards[i] = {}
    end
    
    if cards == nil then
        return rememberCards
    end

    for k,v in pairs(cards)do
        local point = v
        local cardPoint = 0
        local i,t = math.modf(point/4)
        cardPoint = i + 3
        table.insert(rememberCards[cardPoint], v)
    end
    return rememberCards
end

DDZ_cardManage = M.new()