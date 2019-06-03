--[[
-- 广告条
--]]
local M = class("AdView", function( args )
	return args.node
end)

function M:ctor( args )
    self.data = Cache.Config:getStoreActivities()
	self.adNum = #self.data -- 广告条数
	self.downloadNum = 0 -- 已下载的广告条数
	self.curIndex = 1 -- 当前显示的广告标号
    self.itemDefault = args.item

    self.itemPathList = {}
    self.items = {}

    self.itemSize = self.itemDefault:getContentSize()

	self.adSize = self:getContentSize()

    self:setTouchEnabled(false)

    self.handlerScrollTimer = nil
end

function M:startDownloadAd( ... )
	if self.adNum <= self.downloadNum then return end -- 已经没有可下载的广告条
    self.downloadNum = self.downloadNum + 1

    local kImgUrl = self.data[self.downloadNum].banner_url
    local reg = qf.platform:getRegInfo()
    loga("cnd资源加载M")
    if Util:judgeHasHttpSuffex(RESOURCE_HOST_NAME,"http") then
        kImgUrl = RESOURCE_HOST_NAME.."/"..kImgUrl.."?uin="..Cache.user.uin.."&key="..QNative:shareInstance():md5(Cache.user.key).."&channel="..reg.channel.."&version="..reg.version
    else
        kImgUrl = HOST_PREFIX..RESOURCE_HOST_NAME.."/"..kImgUrl.."?uin="..Cache.user.uin.."&key="..QNative:shareInstance():md5(Cache.user.key).."&channel="..reg.channel.."&version="..reg.version
    end
    loga("cnd资源加载M:"..kImgUrl)
    self.downloaderHandler = qf.downloader:execute(kImgUrl, 10, function(path)
        if not tolua.isnull( self ) then
           self:_downloadSuccess(kImgUrl, path)
        end
    end)
end

function M:_getItemPositionByIndex( index )
    local x, y = 0, 0
    y = self.adSize.height*(1 - index)

    return cc.p(x, y)
end

function M:_downloadSuccess(url, path)
    local t = {url=url, path=path}
    table.insert(self.itemPathList, t)

    local item = self.itemDefault:clone()
    self:addChild(item)
    item:setVisible(true)

    local image = ccui.ImageView:create(path)
    local size = image:getContentSize()
    
    image:setScaleX(self.itemSize.width/size.width)
    image:setScaleY(self.itemSize.height/size.height)

    image:setPosition(cc.p(self.itemSize.width*0.5, self.itemSize.height*0.5))

    item:addChild(image)
    item:setPosition(self:_getItemPositionByIndex(self.downloadNum))

    item._url = self.data[self.downloadNum].activity_url

    addButtonEvent(item, function( sender )
        self:_showWebView(sender._url)
    end)

    table.insert(self.items, item)

    self:startDownloadAd()

    self:_timerToScroll()

    qf.event:dispatchEvent(ET.EVENT_SHOP_AD_DOWN_FINISH)
end

-- 定时滚动
function M:_timerToScroll( ... )
    if self.handlerScrollTimer then return end

    local function _startScroll( ... )
        if 2 > self.downloadNum then return end -- 必须有2个及以上才支持滚动

        local nextIndex = self.curIndex + 1
        nextIndex = nextIndex <= self.downloadNum and nextIndex or 1

        self.item1 = self.items[self.curIndex]
        self.item2 = self.items[nextIndex]

        self.item1:setPosition(self:_getItemPositionByIndex(1))
        self.item2:setPosition(self:_getItemPositionByIndex(2))

        self.item1:runAction(cc.MoveBy:create(0.5, cc.p(0, self.adSize.height)))
        self.item2:runAction(cc.MoveBy:create(0.5, cc.p(0, self.adSize.height)))

        self.curIndex = nextIndex
    end
    self.handlerScrollTimer = self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(3.0)
        , cc.CallFunc:create(function( sender )
            _startScroll()
        end))))
end

function M:_showWebView(url) 
    local reg = qf.platform:getRegInfo()
    local url = HOST_PREFIX..HOST_NAME.."/"..url.."?uin="..Cache.user.uin
        .."&key="..QNative:shareInstance():md5(Cache.user.key)
        .."&channel="..reg.channel.."&version="..reg.version.."&ref="..UserActionPos.ACTIVITY_SHOP

    local winsize = cc.Director:getInstance():getWinSize()
    local fsize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local w = winsize.width
    local h = fsize.height*winsize.width/fsize.width
    local x = 0
    local y = 0
    qf.platform:showWebView({url=url,x=x,y=y,w=w,h=h,
        cb = function ( paras )
            if paras == "start" then
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=GameTxt.net005})
            else
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
            end
        end,
        cb2 = function ( paras )
            qf.platform:removeWebView()
        end
    })
end

return M