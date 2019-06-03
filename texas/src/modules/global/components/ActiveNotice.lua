local ActiveNotice = class("ActiveNotice",CommonWidget.BasicWindow)

function ActiveNotice:ctor(paras)
    ActiveNotice.super.ctor(self, paras)
    self:initTouchEvent()
    self:delayRun(0.01,function ( )
         self:getActiveList(paras)
    end)
end

function ActiveNotice:init( paras )
    self.shopinfo= paras
    self.currentIndex = 1
    self.activeNum = 0
    self._actvieList = {}
    self.active_url = ""
    self.btn_type = 0

    self.btnCanTouch = false
    self.canTouch = false
end

function ActiveNotice:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.ActiveNoticeJson)
    self.gui:setAnchorPoint(0.5,0.5)
end

function ActiveNotice:show()
    ActiveNotice.super.show(self)
end

function ActiveNotice:initClick()
    local btn_close = ccui.Helper:seekWidgetByName(self.gui,"btn_close")
    addButtonEvent(btn_close,function ( sender )
        self:close()
    end)
    
    local p_join = self.gui:getChildByName("content_layer")
    addButtonEvent(p_join,function ( sender )
        self:joinActvie()
    end)
end

function ActiveNotice:checkBoxSitch()
    local index = self.currentIndex
    local  num = self.activeNum
    -- for i=1,num do
    --     self.check_items[i]:setTexture(GameRes.activity_icon_hide)
    -- end

    -- local checkTemp =self.check_items[index]
    -- if checkTemp ~= nil then
    --     checkTemp:setTexture(GameRes.activity_icon_show)
    -- end

    self.btnCanTouch = false
    local item = self._actvieList[tostring(index)]
    self.active_url = item.page_url
    self.btn_type = item.board_type
    self:loadActiveImg(item)
end

function ActiveNotice:showCheckBoxByNum()
    -- self.gui:getChildByName("check_item1"):setVisible(false)
    -- self.gui:getChildByName("check_item2"):setVisible(false)
    -- self.gui:getChildByName("check_item3"):setVisible(false)

    -- local  num = self.activeNum
    -- local mid_x=ccui.Helper:seekWidgetByName(self.gui,"img_bg"):getContentSize().width/2
    -- local mid_y=230
    -- mid_x=self.gui:getChildByName("check_item2"):getPositionX()
    -- mid_y=self.gui:getChildByName("check_item2"):getPositionY()
    -- local mid_index=num/2
    -- if num%2==0 then --偶数
    --     mid_x=mid_x-50/2
    --     mid_index=math.floor(num/2)
    -- else --奇数
    --     mid_index=math.ceil(num/2)    
    -- end   
    -- for i=1,num do
    --     self.check_items[i]:setVisible(true) 
    --     local pos_x=mid_x-(mid_index-i)*50 
    --     self.check_items[i]:setPosition(pos_x,mid_y)
    -- end
end

function ActiveNotice:loadActiveImg(item)

    self.activeId = item.id
    self.pageUrl = item.page_url
    local kImgUrl =item.board_url
    local reg = qf.platform:getRegInfo()

    if Util:judgeHasHttpSuffex(RESOURCE_HOST_NAME,"http") then
        kImgUrl = RESOURCE_HOST_NAME.."/"..kImgUrl.."?uin="..Cache.user.uin.."&key="..QNative:shareInstance():md5(Cache.user.key).."&channel="..reg.channel.."&version="..reg.version
	else 
        kImgUrl = HOST_PREFIX..RESOURCE_HOST_NAME.."/"..kImgUrl.."?uin="..Cache.user.uin.."&key="..QNative:shareInstance():md5(Cache.user.key).."&channel="..reg.channel.."&version="..reg.version
    end
    --local path = CACHE_DIR.."active"..self.activeId
    loga(kImgUrl)

    local taskID = qf.downloader:execute(kImgUrl, 10,
        function(path)
            if not tolua.isnull( self ) then
               self:downloadImgSuccess(kImgUrl,path)
            end
        end,
        function()
            self.btnCanTouch = true
        end,
        function()
            self.btnCanTouch = true
        end
    )
end

function ActiveNotice:downloadImgSuccess(url,path)
    self.btnCanTouch = true  
    if url == nil then return end
    --local path = CACHE_DIR.."active"..self.activeId
    local img_active1= ccui.Helper:seekWidgetByName(self.gui,"img_active1")
    --img_active1:setVisible(true)
    img_active1:loadTexture(path)
    local content_layer=ccui.Helper:seekWidgetByName(self.gui,"content_layer")
    -- content_layer:setContentSize(img_active1:getContentSize())
    -- content_layer:setPosition(Display.cx/2-content_layer:getContentSize().width/2,Display.cy/2-content_layer:getContentSize().height/2)
    local btnClose = ccui.Helper:seekWidgetByName(self.gui,"btn_close")
    btnClose:setPosition(img_active1:getPositionX() + img_active1:getContentSize().width/2, img_active1:getPositionY() + img_active1:getContentSize().height/2)

    -- 添加点击事件
    addButtonEvent(img_active1,function(sender)
        if not self.btnCanTouch or not self.pageUrl or not self.activeId or self.pageUrl == "" then return end
        self:showWebView(self.pageUrl)
        -- 活动页面点击上报
        qf.platform:umengStatistics({umeng_key = "Activity_".. self.activeId})
    end)
end
function ActiveNotice:EnterActionDone()
    
end

function ActiveNotice:startRemoveAction()
	
end

function ActiveNotice:getActiveList(model)
    self._actvieList = {}
    self.activeNum =1
    --self.check_items={}
    local item = model
    self._actvieList[tostring(self.activeNum)] = item
    -- for i=1,model.activities:len() do
    --     local item = model.activities:get(i)
    --     if  item.show_board == 1  then
    --         self.activeNum = self.activeNum + 1 
    --         self._actvieList[tostring(self.activeNum)] = item
    --         -- local sp = cc.Sprite:create(GameRes.activity_icon_hide)
    --         -- --ccui.Helper:seekWidgetByName(self.gui,"img_bg"):addChild(sp,5)
    --         -- self.gui:addChild(sp,5)
    --         -- table.insert(self.check_items,sp)
    --     end
    -- end
    self:showCheckBoxByNum()
    self:checkBoxSitch()
end
--初始化点击事件
function ActiveNotice:initTouchEvent ()
    local layer = ccui.Helper:seekWidgetByName(self.gui,"content_layer")
    layer.noEffect = true
    local rect = layer:getBoundingBox()
    rect.x = 0
    rect.y = 0
    self._touchData = {}
    local firstX = 0
    local img_active1= ccui.Helper:seekWidgetByName(self.gui,"img_active1")
    local content_layer=ccui.Helper:seekWidgetByName(self.gui,"content_layer")
    content_layer:setContentSize(img_active1:getContentSize().width + 100, img_active1:getContentSize().height + 100)
    content_layer:setPosition(Display.cx/2-content_layer:getContentSize().width/2,Display.cy/2-content_layer:getContentSize().height/2)
end

function ActiveNotice:showWebView (uu) 
    local reg = qf.platform:getRegInfo()
    self.url = HOST_PREFIX..HOST_NAME.."/"..uu.."?uin="..Cache.user.uin.."&key="..QNative:shareInstance():md5(Cache.user.key).."&channel="..reg.channel.."&version="..reg.version.."&ref="..UserActionPos.ACTIVITY_NOTICE
    self:_showWebView(self.url)
end

function ActiveNotice:_showWebView(url)
    self:closeAllTouch()
    self.webIsShowing = true
    local winsize = cc.Director:getInstance():getWinSize()
    local fsize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local w = winsize.width
    local h = fsize.height*winsize.width/fsize.width
    local x = 0
    local y = 0
    loga(url)
    qf.platform:showWebView({url=url,x=x,y=y,w=w,h=h,
        cb=function ( paras )
            if paras == "start" then 
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=GameTxt.net005})
            else
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
            end
        end,
        cb2=function ( paras )
            self.webIsShowing = false
            qf.platform:removeWebView()
            self:close()
        end
        })
    self:delayRun(1,function() 
        self:startAllTouch()
    end)
end

function ActiveNotice:closeAllTouch()
    self.canTouch = false
end

function ActiveNotice:startAllTouch()
    self.canTouch = true
end

function  ActiveNotice:joinActvie()
    if self.btn_type == 0 then             -- 活动详情
        if self.active_url ~= "" then
            self:showWebView(self.active_url)
            self:close()
        end
    elseif self.btn_type == 1 then         -- 商城
        self:close()
        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK,{name="shop"})
    elseif self.btn_type == 2 then         -- 游戏大厅
        self:close()
        qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK,{name="hall"})
    end
end

function ActiveNotice:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end

return ActiveNotice