local ShopView = class("ShopView", CommonWidget.BasicWindow)


local BuyCommonView = import(".components.BuyCommonView")
local BookmarkView = import(".components.BookmarkView")
local MoneyItem = import(".components.MoneyItem")
local AdView = import(".components.AdView")

ShopView.ALWAYS_SHOW = true
ShopView.TAG = "ShopView"
function ShopView:ctor(args)
    ShopView.super.ctor(self, args)
    self:updateWithData()

    self.adView:startDownloadAd()
    self:_statUserAction()
end

function ShopView:init( args )
    self.selectdBookmark = args and args.bookmark or PAY_CONST.BOOKMARK.GOLD -- 当前所在的标签页
    self.ref = args.ref
end

function ShopView:initLoadingView()
    -- body
    self.loadingView = self.gui:getChildByName("loadingTips")
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.ShopLoadingAni)
    local loadingAni = ccs.Armature:create("shoploading")
    loadingAni:setPosition(self.loadingView:getContentSize().width/2,self.loadingView:getContentSize().height/2+30)
    loadingAni:getAnimation():playWithIndex(0)
    self.loadingView:addChild(loadingAni)
end

function ShopView:initUI( args )
    -- 标签
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.shopOfBestDesignJson)
    local listviewBookmark = self.gui:getChildByName("listview_bookmark")
    local itemBookmark = self.gui:getChildByName("item_bookmark")
    itemBookmark:setVisible(false)
    self.img_bg = ccui.Helper:seekWidgetByName(self.gui,"img_bg")
    self.bookmarkView = BookmarkView.new({node=listviewBookmark, item=itemBookmark, bookmark=self.selectdBookmark})
    -- 广告
    local panAdd = self.gui:getChildByName("pan_ad")
    local itemAd = self.gui:getChildByName("item_ad")
    self.adView = AdView.new({node=panAdd, item=itemAd})
    -- 购买砖石、购买金币、购买道具承载体scrollview
    local scrollviewCommon = self.gui:getChildByName("scrollview_common_view")
    local itemCommon = self.gui:getChildByName("item_common")
    self.buyCommonView = BuyCommonView.new({node=scrollviewCommon, item=itemCommon,ref=self.ref})

    -- 当前金币
    local panCurGold =  ccui.Helper:seekWidgetByName(self.gui,"pan_cur_gold")
    self.itemCurGold = MoneyItem.new({node=panCurGold, name="gold"})

    -- 关闭按钮
    self.btnExit = ccui.Helper:seekWidgetByName(self.gui,"btn_exit")

    self.menu_coin =  ccui.Helper:seekWidgetByName(self.img_bg,"menu_coin")
    self.menu_tools =  ccui.Helper:seekWidgetByName(self.img_bg,"menu_tools")

    -- QQ号
    self.lblQq = self.img_bg:getChildByName("lbl_qq")
    -- self.shopLog = self.gui:getChildByName("Image_5")
    if FULLSCREENADAPTIVE then
        local pX = (cc.Director:getInstance():getWinSize().width-1920)/2
        self.gui:setPositionX(self.gui:getPositionX()+pX)
    end


    if string.len(Cache.Config.qq_prompt) > 0 and string.len(Cache.Config.qq_prompt_last) > 0 then
        if GAME_LANG == "zh_tr" then
            self.lblQq:setString(Cache.Config.qq_prompt..": \n"..Cache.Config.qq_prompt_last)
        else
            self.lblQq:setString(Cache.Config.qq_prompt..": "..Cache.Config.qq_prompt_last)
        end
    else
        self.lblQq:setVisible(false)
    end

    local posy = self.buyCommonView:getPositionY()
    self.posyCommonView = posy

    self:adjustCommonView(1)

    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
        self.lblQq:setVisible(false)
        panCurGold:setVisible(false)
    end

    self:initLoadingView()
    self:initWithData(args)
    self:updateMenu()
end

function ShopView:initWithData( args )
    self.itemCurGold:updateWithNumber(Cache.user.gold)
end

function ShopView:initClick( ... )
    addButtonEvent(self.btnExit, function( sender )
        self:close()
    end)

    addButtonEvent(self.menu_coin, function (sender)
        if self.selectdBookmark ~= PAY_CONST.BOOKMARK.GOLD then
            qf.event:dispatchEvent(ET.EVENT_SHOP_JUMP_TO_BOOKMARK, {bookmark=PAY_CONST.BOOKMARK.GOLD})
        end
    end)

    addButtonEvent(self.menu_tools, function (sender)
        dump(self.selectdBookmark)
        if self.selectdBookmark ~= PAY_CONST.BOOKMARK.PROPS then
            qf.event:dispatchEvent(ET.EVENT_SHOP_JUMP_TO_BOOKMARK, {bookmark=PAY_CONST.BOOKMARK.PROPS})
        end
    end)
end

--更新功能选择菜单的状态
function ShopView:updateMenu()  
    if self.selectdBookmark == PAY_CONST.BOOKMARK.GOLD then
        self.menu_coin:getChildByName("normal"):setVisible(false)
        self.menu_coin:getChildByName("selected"):setVisible(true)
        self.menu_tools:getChildByName("normal"):setVisible(true)
        self.menu_tools:getChildByName("selected"):setVisible(false)
    else
        self.menu_coin:getChildByName("normal"):setVisible(true)
        self.menu_coin:getChildByName("selected"):setVisible(false)
        self.menu_tools:getChildByName("normal"):setVisible(false)
        self.menu_tools:getChildByName("selected"):setVisible(true)
    end
end

function ShopView:updateWithData( args )
    if self.selectdBookmark ~= PAY_CONST.BOOKMARK.EXCHANGE then
        self.buyCommonView:updateWithData({bookmark=self.selectdBookmark})
    end
end
-- 更新金币、砖石数量
function ShopView:updateMoneyNumber( kind )
    if not kind then
        self.itemCurGold:updateWithNumber(Cache.user.gold)
        self.itemCurDiamond:updateWithNumber(Cache.user.diamond)
    elseif 1 == kind then
        self.itemCurGold:updateWithNumber(Cache.user.gold)
    else
        --self.itemCurDiamond:updateWithNumber(Cache.user.diamond)
    end
end
-- 更新话费劵数量
function ShopView:updateTicketNumber( num )
    self.ticketNum = num

end
-- 跳转到指定的标签页
function ShopView:jumpToBookmark( bookmark )
    if self.selectdBookmark == bookmark then return end

    self.selectdBookmark = bookmark
    self:updateWithData()

    self:updateMenu()
end

-- 调整buyCommonView的位置
function ShopView:adjustCommonView( direction )
    if 1 == direction then
        self.buyCommonView:setPositionY(self.posyCommonView)
    else
        self.buyCommonView:setPositionY(self.posyCommonView)
    end
end

-- 用户行为统计
function ShopView:_statUserAction( ... )
    local currency
    if self.selectdBookmark == PAY_CONST.BOOKMARK.GOLD then
        currency = PAY_CONST.CURRENCY_GOLD
    elseif self.selectdBookmark == PAY_CONST.BOOKMARK.DIAMOND then
        currency = PAY_CONST.CURRENCY_DIAMOND
    else
        return 
    end
    
    -- 数据上报
    qf.event:dispatchEvent(ET.USER_ACTION_STATS_EVT, {
        ref = UserActionPos.SHOP_REF,
        currency = currency
    })
end

function ShopView:refreshShopList()
    if self.buyCommonView then
        self.buyCommonView:updateWithData({bookmark=self.selectdBookmark})
    end
end


return ShopView