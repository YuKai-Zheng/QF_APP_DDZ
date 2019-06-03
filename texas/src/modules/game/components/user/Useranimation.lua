local Useranimation      =  class("Useranimation")
Useranimation.TAG        = "Useranimation"

-- 聊天文字
function Useranimation:getChatNode( paras )
    local image = nil
    local chatPop = nil
    if paras.flipx == true then
        image = DDZ_Res.game_chatBg_right
        chatPop = cc.Scale9Sprite:create(image)
        chatPop:setCapInsets(cc.rect(16,0,87,87))
        chatPop:setAnchorPoint(cc.p(1,0.5))
    else
        image = DDZ_Res.game_chatBg_left
        chatPop = cc.Scale9Sprite:create(image)
        chatPop:setCapInsets(cc.rect(48,0,87,87))
        chatPop:setAnchorPoint(cc.p(0,0.5))
    end
    
    local fontSize = 35
    local temp = cc.LabelTTF:create(paras.content,GameRes.font1,fontSize)

    chatPop:setPreferredSize(cc.size(temp:getContentSize().width + 60,87))


    local layout, num = Util:getChatLayoutEx(chatPop, paras.content, fontSize, 10, 0)
    if paras.flipx == true then
        layout:setPosition(10,45)
    else
        layout:setPosition(35,45)
    end
    
    chatPop:setPosition(paras.pos.x,paras.pos.y)

    local function getDisAction(scale)
        scale = scale or 1.05
        return cc.Sequence:create(cc.DelayTime:create(num*1.0+0.5)
            , cc.Spawn:create(
                cc.FadeTo:create(1.0, 0),
                cc.ScaleBy:create(0.5,scale))
            , cc.CallFunc:create(function ( sender )
                sender:removeFromParent(true)
            end))
    end
    chatPop:runAction(getDisAction(1.1))
    layout:runAction(getDisAction(1.04))

    return chatPop
end




return Useranimation