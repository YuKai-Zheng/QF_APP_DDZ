
local IButton = class("IButton",function (paras) 
    return paras.node
end)

function IButton:setName(paras)
    self.name = paras.name
    if paras.index then
        local content = "";
        if paras.index == "601" then 
            content = GameTxt.string601 
        elseif paras.index == "602"  then 
            content = GameTxt.string602
        elseif paras.index == "603"  then 
            content = GameTxt.string603 
        elseif paras.index == "604" then
            content = GameTxt.string604 
        elseif paras.index == "605" then
            content = GameTxt.string605
        elseif paras.index == "606" then
            content = GameTxt.string606
        elseif paras.index == "610" then
            content = GameTxt.string610
        elseif paras.index == "614" then
            content = GameTxt.string614
        end
        self:setTitleText(content)
    end
    if paras.key then self.key = paras.key end
    if paras.seq then self.seq = paras.seq end
    if paras.roomid then self.roomid = paras.roomid end
    if paras.dst_desk_id then self.dst_desk_id = paras.dst_desk_id end
end

function IButton:ctor (paras) 

    self:addTouchEventListener(

            function (sender, eventType)
                if sender.clickable == false then return false end
                if eventType == ccui.TouchEventType.began then
                    return true
                elseif eventType == ccui.TouchEventType.moved then
                elseif eventType == ccui.TouchEventType.ended then
                    MusicPlayer:playMyEffect("BTN")
                    sender:click()
                elseif eventType == ccui.TouchEventType.canceled then
                end
            end
    ) 

    self.callback = function () logd(" no click event ","IButton")end
    --self:removeAllChildren()
    self.selected = false
end

function IButton:setCallback(cb) 
    self.callback = cb
end

function IButton:setSelect(bool)
    self.selected = bool;
end
function IButton:click () 
    if self.selected == false then
        self.callback(self)
    end
end

--[[--更新按钮的背景 以及内容显示

]]
function IButton:changeStatus(paras)
    
    if paras.coat and paras.type == 1 then
        local c = cc.Sprite:create(GameRes[paras.coat])
        c.setScale(c,-1,-1)
        c:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        self:removeAllChildren(true)
        self:addChild(c)
    end
    if paras.coat then
        local c = cc.Sprite:create(GameRes[paras.coat])
        c:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        self:removeAllChildren(true)
        self:addChild(c)
    end
end


return IButton