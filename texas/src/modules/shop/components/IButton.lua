local IButton = class("IButton",function (parameters)
	return parameters.node
end)

function IButton:ctor(parameters)
    self:addTouchEventListener(
        function(sender , eventType)
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
    self.callback = function () logd("no click event","IButton")end
    --self.removeAllChilder()
    self.selected = false
end

function IButton:setCallback(cb)
    self.callback = cb
end

function IButton:setSelect(bool)
    if bool == true then
        self:setOpacity(0)
    else
        self:setOpacity(255)
    end
    self.selected = bool
end

function IButton:click()
    if self.selected == false then
            self.callback(self)
    end
end

return IButton