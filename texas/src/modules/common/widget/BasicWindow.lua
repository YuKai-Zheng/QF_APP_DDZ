local M = class("BasicWindow", function (  )
    return cc.Node:create()
end)

M.TAG = "BasicWindow"

M.POPUP_ACTION = enum(0, "JUMP_OUT")

M.BACK_TO_CLOSE = true --手机返回键是否关闭
M.CLICK_BLANK_TO_CLOSE = false --是否点击空白处关闭
M.UNIQUE = true --界面是否唯一
M.ALWAYS_SHOW = false   --界面是否可重叠显示
M.IS_SWALLOW = true --不可触摸下层
M.TOP = false --界面是否请求在最顶部

function M:ctor( paras )
    paras = paras or {}

    self:_init(paras)
    self:init(paras)
    self:initUI(paras)
    self:clickBlank()
    self:initClick(paras)
    self:addGUI()
    self:setVisible(false)
    self:registerBack()
    self:addTouchLayer() --防止误触下层
end

--初始化基本数据
function M:_init( paras )
    self._uid = paras.uid --窗口的唯一标识
    self._data = paras.data --窗口数据
    self._init_data = paras
    self._is_action = paras.pop_action or false --窗口展示关闭是否动作展示
    self._bg_style = paras.bg_style or PopupManager.BG_STYLE.BLUR
    self._pop_action_type = paras.pop_action_type or M.POPUP_ACTION.JUMP_OUT
end

--初始化传入数据
function M:init( paras )
end

--初始化UI
function M:initUI( paras )
end

--初始化点击事件
function M:initClick( paras )
end

--默认将UI节点加入
function M:addGUI(  )
    if isValid(self.gui) then
        self:addChild(self.gui)
    end
end

function M:show( cb )
    if self._is_action then
        self:showWithAction(cb)
    else
        self:showWithoutAction(cb)
    end
end

function M:hide( cb )
    if self._is_action then
        self:hideWithAction(cb)
    else
        self:hideWithoutAction(cb)
    end
end

function M:close( cb )
    if self._is_action then
        self:closeWithAction(cb)
    else
        self:closeWithoutAction(cb)
    end
end

function M:showWithoutAction( cb )
    self:setVisible(true)
    if cb then cb() end
end

function M:showWithAction( cb )
    self.setVisible(true)
    self:_runPopupAction(cb)
end

function M:hideWithoutAction( cb )
    self:setVisible(false)
    if cb then cb() end
end

function M:hideWithAction( cb )
    self:_runCloseAction(function (  )
        self:setVisible(false)
        if cb then cb() end
    end)
end

function M:closeWithoutAction( cb )
    if cb then cb() end
    --延时关闭
    Util:delayRun(0.1,  function (  )
        local uid = self._uid
        PopupManager:remove(uid)
    end)
end

function M:closeWithAction( cb )
    self:_runCloseAction(function (  )
        if cb then cb() end

        local uid = self._uid
        PopupManager:remove(uid) --暂未实现
    end)
end

function M:_runPopupAction( cb )
    if self._pop_action_type == M.POPUP_ACTION.JUMP_OUT then
        Display:showScalePop({view=self, cb=cb})
    else
        if cb then cb() end
    end
end

function M:_runCloseAction( cb )
    if self._pop_action_type == M.POPUP_ACTION.JUMP_OUT then
        Display:showScaleBack({view=self, cb=cb})
    else
        if cb then cb() end
    end
end

function M:destructor(  )
    -- body
end

--注册返回键
function M:registerBack(  )
    Util:registerKeyReleased({self = self,cb = function ()
        if self.BACK_TO_CLOSE then
            self:close()
        end
	end})
end

--触摸注册 防止UI文件未选择分辨率适配导致点击到下方
function M:addTouchLayer(  )
    self.touchLayer = cc.Layer:create()
    self:addChild(self.touchLayer, -1)

    Util:addTouchEvent(self.touchLayer, self.IS_SWALLOW, handler(self, self.touchBegin), handler(self, self.touchMoved), handler(self, self.touchEnd))
end

function M:touchBegin( touch, event )
    -- body
end

function M:touchMoved( touch, event )
    -- body
end

function M:touchEnd( touch, event )
    if self.CLICK_BLANK_TO_CLOSE then
        self:close()
    end
end

function M:clickBlank(  )
    if isValid(self.gui) and self.gui.setTouchEnabled then
        self.gui:setTouchEnabled(true)
        addButtonEvent(self.gui, function (  )
            if self.CLICK_BLANK_TO_CLOSE then
                self:close()
            end
        end)
    end
end

return M