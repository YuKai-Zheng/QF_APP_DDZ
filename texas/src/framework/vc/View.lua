

local View = class("View",function() return cc.Layer:create() end)
View.TAG = "View"

function View:ctor(parameters)
    self:getRoot():addChild(self)

    if self:initWithRootFromJson() then 
        self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(self:initWithRootFromJson())
        self:addChild(self.root)
    end

    if self:isAdaptateiPhoneX() and self.root and FULLSCREENADAPTIVE then
        self.root:setPositionX((cc.Director:getInstance():getWinSize().width-1920)/2)
    end

    if parameters ~= nil and parameters.style ~= nil and parameters.id ~= nil then
        self._withBackground = true
        self:setTag(parameters.id)
        PopupManager:checkShowBackground(parameters.id, parameters.style)
    else
        self._withBackground = false
    end

	self:registerScriptHandler(function (event)
		if event == "enter" then
			self:enter()
		elseif event == "exit" then
			self:exit()
		elseif event == "enterTransitionFinish"then

			self:enterTransitionFinish()
		elseif event == "exitTransitionStart" then
			self:exitTransitionStart()
		elseif event == "cleanup"then 
			self:cleanup()
		end
	end)
end

function View:initTouchEvent(paras)
	if self.TAG==View.TAG then return end--自己本身不需要弹
    
    if 1 then return end
    local layer = cc.Layer:create()
    local parent = self--ccui.Helper:seekWidgetByName(self.gui,"pan_container")
    local zOrder = parent:getLocalZOrder()
    parent:addChild(layer, 20)

    self._touchData = {}

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:registerScriptHandler(function (touch,event)
        self._touchData = {}
        self._touchData.pos = touch:getLocation()
        self._touchData.time = os.time()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)

    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, layer)
end

function View:initWithRootFromJson()
    logw(" -- if you use cocosStudio, you must overite this method！", self.TAG)
    return nil
end

function View:existBackground()
    return self._withBackground
end

function View:isAdaptateiPhoneX()
    return false
end



function View:getRoot()
    loge(" -- you must overite this method !",self.TAG)
	return nil
end

function View:enter() logd("enter function , empty ", self.TAG) end
function View:exit() logd("exit function , empty ", self.TAG) end
function View:enterTransitionFinish () logd("enterTransitionFinish function , empty ", self.TAG) end
function View:exitTransitionStart () logd("exitTransitionStart function , empty ", self.TAG) end
function View:cleanup() logd("cleanup function , empty ", self.TAG) end
function View:enterCoustomFinish() logd("enterCoustomFinish function , empty ", self.TAG) end
function View:exitCoustomStart() logd("exitCoustomFinish function , empty ", self.TAG) end

return View