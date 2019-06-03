local Coin = class("Coin",function ( paras )
	--return cc.Sprite:create(GameRes.anima_gold_1)
    return cc.Sprite:create(GameRes.reward_gold_01)
end)


function Coin:ctor(paras) 


	self:init()

end


function Coin:init( paras )
	local ani = cc.Animation:create()
    for i=2,9 do
        ani:addSpriteFrameWithFile(GameRes["reward_gold_0"..i])
    end

    ani:addSpriteFrameWithFile(GameRes.reward_gold_01)
    ani:setDelayPerUnit(0.1)

    self:runAction(cc.RepeatForever:create(cc.Animate:create(ani)))
end

function Coin:updateStatus(dx,dy , dr)
	self:setPositionX(self:getPositionX() - dx)
    self:setPositionY(self:getPositionY() - dy)
    self:setRotation (self:getRotation()  + dr);
end

return Coin