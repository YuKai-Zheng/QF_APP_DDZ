local PopupWindow = class("PopupWindow", function()
    return cc.Node:create()
end)

PopupWindow.DEBUG = false
PopupWindow.TAG = "PopupWindow"

PopupWindow.POPUP_ACTION = enum(0, "JUMP_OUT")

function PopupWindow:ctor(paras)
    self._log("PopupWindow ctor")
    if paras.child == nil or paras.id == nil then
        return
    end
    self.poup_prop = {}
    self.poup_prop.id = paras.id
    self.poup_prop.child = paras.child
    self.poup_prop.bg_style = paras.bg_style or PopupManager.BG_STYLE.BLUR
    self.poup_prop.pop_action = paras.pop_action or PopupWindow.POPUP_ACTION.JUMP_OUT
    if self.DEBUG then dump(self.poup_prop) end
    self:initPopup()
end

function PopupWindow:initPopup()
    --将child添加至弹窗
    self.poup_prop.winSize = cc.Director:getInstance():getWinSize() 
    self:setContentSize(self.poup_prop.winSize)
    self:_addChildToCenter(self.poup_prop.child)
    --将弹窗添加到PopupLayer
    PopupManager:addPopupWindow(self.poup_prop.id, self)
    self:setVisible(false)
end

--弹出弹框
function PopupWindow:show(cb)
    self._log("PopupWindow show")
    self:showWithoutAction(cb);
end
--显示弹窗，无动画
function PopupWindow:showWithoutAction(cb)
    PopupManager:checkShowBackground(self.poup_prop.id, self.poup_prop.bg_style, function()
        self.poup_prop.child:setScale(1)
        self:setVisible(true)
        if cb then cb() end
    end)
end
--显示弹窗，带动画
function PopupWindow:showWithAction(cb)
    PopupManager:checkShowBackground(self.poup_prop.id, self.poup_prop.bg_style, function()
        self:_log("add background callback")
        self:setVisible(true)
        self:_runPopupAction(cb)
    end)
end

--隐藏弹框. 弹窗关闭后visible=false
function PopupWindow:hide(cb)
    self:hideWithoutAction(cb)
end
--隐藏弹框，无动画
function PopupWindow:hideWithoutAction(cb)
    self:setVisible(false)
    PopupManager:checkRemoveBackground()
    if cb then cb() end
end

--隐藏弹框，带动画
function PopupWindow:hideWithAction(cb)
    --先隐藏背景 再播关闭动画
    self:_runCloseAction(function()
        self:setVisible(false)
        self.poup_prop.child:setOpacity(255)
        PopupManager:checkRemoveBackground()
        if cb then cb() end
    end)
end

--关闭弹窗。弹窗关闭后remove
function PopupWindow:close(cb)
    self:closeWithoutAction(cb)
end

--无动画关闭弹窗
function PopupWindow:closeWithoutAction(cb)
    self:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function() 
                    self:removeFromParent()
                    PopupManager:checkRemoveBackground()
                    if cb then cb() end
                    qf.event:dispatchEvent(ET.POPLISTPOPUP)
                end)
            ))
end

--带动画关闭弹窗
function PopupWindow:closeWithAction(cb)
    self:_runCloseAction(function()
        if cb then cb() end
        self:removeFromParent()
        PopupManager:checkRemoveBackground()
        qf.event:dispatchEvent(ET.POPLISTPOPUP)
    end)
end


--析构。弹窗被移除时调用。如果被动被移除时需要调用某些代码，可以重写这个接口。
function PopupWindow:destructor()
    logd("PopupWindow destructor")
end

--打开弹窗动画
function PopupWindow:_runPopupAction(cb)
    if self.poup_prop.pop_action == PopupWindow.POPUP_ACTION.JUMP_OUT then
        if self.poup_prop.child then
            Display:showScalePop({view=self.poup_prop.child, cb=cb})
        end
    else
        if cb then cb() end
    end
end

--关闭弹窗动画
function PopupWindow:_runCloseAction(cb)
    if self.poup_prop.pop_action == PopupWindow.POPUP_ACTION.JUMP_OUT then
        if self.poup_prop.child then 
            Display:showScaleBack({view=self.poup_prop.child, cb=cb})
        end
    end
end

function PopupWindow:_log(str)
    --if self.DEBUG then loga("["..self.TAG.."]"..str) end
    if self.DEBUG then logd(str, TAG) end
end

--添加背景精灵
function PopupWindow:_addChildToCenter(node)
    if node ~= nil then
        local size = node:getContentSize()
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setPosition(cc.p(self.poup_prop.winSize.width / 2, self.poup_prop.winSize.height / 2))
        node:setScaleX(self.poup_prop.winSize.width / size.width)
        node:setScaleY(self.poup_prop.winSize.height / size.height)
        self:addChild(node, 0)
    end
end

return PopupWindow