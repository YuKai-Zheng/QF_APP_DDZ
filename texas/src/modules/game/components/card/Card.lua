local Card = class("Card", function ()
	return cc.Sprite:create()
end)
Card.TAG = "Card"
Card.pool = {}

local colorTable = {
	[0] = "r", 
	[1] = "h", 
	[2] = "m", 
	[3] = "f"
}

local colorTable_2 = {
    [0] = "1", 
	[1] = "2", 
	[2] = "2", 
	[3] = "1"
}

-- 获取牌信息
function Card:getCardInfo()
	local cardInfo = {}
	cardInfo.point = self.point
	cardInfo.color = self.color
	return cardInfo
end

-- 点数= cards[i]/4+1; 花色= cards[i]%4; 0红桃 1黑桃 2梅花 3方片
function Card:ctor(point,isShowSmallCard)
	self:init()
	self:setCardValue(point,isShowSmallCard)
end

function Card:setCardValue( point, isShowSmallCard)
	if point == nil then
		self:showBackCard()
		return
	elseif point == -1 then
		self.value = point
		self:setVisible(false)
		self:showBackCard()
		return 
	end

	self:init()
	local i,t = math.modf(point/4)

	--总值
	self.value = point
	self.isShowSmallCard = isShowSmallCard or false --是否是显示小牌
	--点数
	self.point = i + 3
	--花色
	self.color = math.fmod(point, 4)

	self:setUp()
end

-- 初始化
function Card:init()
	self:setTexture(DDZ_Res.poker_bg)
end

-- 显示牌背面
function Card:showBackCard( ... )
	self:setTexture(DDZ_Res.poker_back_bg)
end

-- 初始化子节点
function Card:setUp()
	if self.point >= 16 then
        self:setKingOrQueen()
    else
		self:setNormalPoint()
	end
end
--获得牌的点数
function Card:getCardValue()
	return self.point
end
--获得牌的花色
function Card:getCardColor()
	return self.color
end
--获得牌的值
function Card:getValue()
	return self.value
end

--设置明牌显示的图片
function Card:setMingPai(isDisplay)
	local pointSprite = cc.Sprite:create(DDZ_Res.poker_ming)
    pointSprite:setPosition(40,self:getContentSize().height-220)
    pointSprite:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(pointSprite, 2)
end

--设置地主显示的图片
function Card:setDiZhu(isDisplay)
	if not isDisplay then 
		if self.dizhuSprite then
			self.dizhuSprite:setVisible(false)
        end
		return 
	elseif self.dizhuSprite then
        self.dizhuSprite:setVisible(true)
		return 
	end
	self.dizhuSprite = cc.Sprite:create(DDZ_Res.poker_di_zhu)
    self.dizhuSprite:setPosition(self:getContentSize().width-5,self:getContentSize().height)
    self.dizhuSprite:setScale(0.8)
    self.dizhuSprite:setAnchorPoint(cc.p(1,1))
    self:addChild(self.dizhuSprite, 2)
end
-- 正常花色self.color
function Card:setNormalPoint()
	-- 设置点数
	local pointFlag = 1
	if  self.color == 0 or self.color == 3 then
		pointFlag = 0
	end

	local pointSprite = cc.Sprite:create(string.format(DDZ_Res.poker_point, self.point,pointFlag))
	
    --设置花色 小
	local colorSmallSprite = cc.Sprite:create(string.format(DDZ_Res.poker_color_small, colorTable[self.color]))
	
	if self.isShowSmallCard then 
		pointSprite:setPosition(80,self:getContentSize().height*3/4 - 2 )
		pointSprite:setScale(1.6)

		colorSmallSprite:setPosition(80,self:getContentSize().height/4 + 40)
		colorSmallSprite:setScale(2)
	else
        pointSprite:setPosition(40,self:getContentSize().height -47)
		pointSprite:setScale(1)
		colorSmallSprite:setPosition(40,self:getContentSize().height - 110)
		colorSmallSprite:setScale(1)
	end
	
	pointSprite:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(pointSprite, 2)

	colorSmallSprite:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(colorSmallSprite, 2)
	
    if self.isShowSmallCard then return end
    if self.point < 11 or self.point > 13 then
        local colorLargeSprite = cc.Sprite:create(string.format(DDZ_Res.poker_color_large, colorTable[self.color]))
        colorLargeSprite:setPosition(140,self:getContentSize().height - 200)
        colorLargeSprite:setAnchorPoint(cc.p(0.5,0.5))
        self:addChild(colorLargeSprite, 2)
    else
        local colorLargeSprite = cc.Sprite:create(string.format(DDZ_Res.poker_point_color_large, self.point, colorTable_2[self.color]))
        colorLargeSprite:setPosition(155,self:getContentSize().height - 190)
        colorLargeSprite:setAnchorPoint(cc.p(0.5,0.5))
        self:addChild(colorLargeSprite, 2)
    end

end

-- 大小王
function Card:setKingOrQueen()
	local pointFlag = self.point == 16 and 0 or 1
	local pointSprite = cc.Sprite:create(string.format(DDZ_Res.poker_point, self.point,pointFlag))
	pointSprite:setPosition(29,self:getContentSize().height / 2 + 10)
	pointSprite:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(pointSprite, 2)

	local centerSprite = cc.Sprite:create(string.format(DDZ_Res.poker_king, self.point,pointFlag))
	centerSprite:setPosition(145,self:getContentSize().height / 2 - 20)
	centerSprite:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(centerSprite, 2)
end



--设置暗色
function Card:dark() 
    self:setColor(Theme.Color.DARK)
end

--设置炸弹色(原谅色->绿色)
function Card:green() 
    self:setColor(cc.c3b(188,212,186))
end

--设置亮色
function Card:light() 
    self:setColor(Theme.Color.LIGHT)
end

--清理牌
function Card:clear()
    self:removeAllChildren()
    self:setVisible(true)
    self:setScale(1)
    self:setColor(cc.c3b(255,255,255))
    self:setOpacity(255)
    self:setZOrder(0)
    self.dizhuSprite = nil
end

function Card.getCard( ... )
    for i = 1, #Card.pool do
        local card = Card.pool[i]
        if isValid(card) then
            if not card:getParent() then
                card:clear()
                card:init()
                card:setCardValue(...)
                return card
            end
        end
    end

    local card = Card.createCard(...)
    card:retain()
    table.insert( Card.pool, card )
    return card
end

function Card.clearPool()
    for i = 1, #Card.pool do
        local card = Card.pool[i]
        if isValid(card) then
            card:removeFromParent()
            card:release()
        end
    end

    Card.pool = {}
end

Card.createCard = Card.new

function Card.new( ... )
    return Card.getCard(...)
end

-- function Card._new( ... )
--     local instance = Card.__create(...)
--     for k,v in pairs(Card) do instance[k] = v end

--     instance.class = Card
--     instance:ctor(...)
--     instance:retain()
--     return instance
-- end

return Card