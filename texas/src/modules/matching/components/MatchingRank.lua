local MatchingRank = class("matchingRank", CommonWidget.BasicWindow)
MatchingRank.TAG = "matchingRank"

local UserHead = import("...change_userinfo.components.userHead")--我的头像
local CustomScrollView = import("...common.widget.CustomScrollView")--滚动容器

function MatchingRank:ctor(paras)
    MatchingRank.super.ctor(self, paras)

    if paras and paras.cb then
        self.cb=paras.cb
    end
end

function MatchingRank:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.matchingRankJson)
    
    self.winSize = cc.Director:getInstance():getWinSize()

	self.panel = ccui.Helper:seekWidgetByName(self.gui,"panel")
	self.panel_list = ccui.Helper:seekWidgetByName(self.gui,"panel_list")
	self.item = ccui.Helper:seekWidgetByName(self.gui,"item")--排行榜item
	self.my_rank_bg = ccui.Helper:seekWidgetByName(self.gui,"my_rank_bg")--自己排行榜item

    if FULLSCREENADAPTIVE then
        self.panel:setPositionX(self.panel:getPositionX()-(self.winSize.width - 1920))
        self.gui:setPositionX((self.winSize.width - 1920)/2)
    end

    self.item:setVisible(false)

    self:initList()
end

function MatchingRank:init()
    self.data = Cache.Config:getMatchRankInfo()
end

function MatchingRank:initList()
    for i=1, #self.data do
        if Cache.user.uin == self.data[i].uin then
            if self.data[i].rank <= 0 or self.data[i].rank > 100 then
                self.my_info = table.remove(self.data, i)
            else
                self.my_info = self.data[i]
            end
        end
    end
    self.scroll_rank_list = CustomScrollView.new({
            defaultNode = self.item,
            datalist = {},
            updata = handler(self,self.updateRankItem),
            direction = ccui.ScrollViewDir.vertical,
            delay = 0.1,
            limitMaxNum = 8
        })
    self.scroll_rank_list:setContentSize(self.panel_list:getContentSize().width, self.panel_list:getContentSize().height)
    self.scroll_rank_list:setShowActionEnabled(true)
    self.panel_list:addChild(self.scroll_rank_list)

    self.scroll_rank_list:refreshData(self.data, true)

    self:initMyRank()
end

function MatchingRank:updateRankItem(info, item)
    local bg = item:getChildByName("bg")
    local icon_rank = item:getChildByName("icon_rank")
    local panel_avatar = item:getChildByName("panel_avatar")
    local lbl_award = item:getChildByName("lbl_award")
    local lbl_rank = item:getChildByName("lbl_rank")
    local info_bg = item:getChildByName("info_bg")
    local icon_level = info_bg:getChildByName("icon_level")
    local lbl_level = info_bg:getChildByName("lbl_level")
    local icon_sub_level = info_bg:getChildByName("icon_sub_level")
    local lbl_sub_level = info_bg:getChildByName("lbl_sub_level")

    local nick = Util:filterEmoji(info.nick) or ""
    item:getChildByName("name"):setString(nick)
    lbl_level:setString(self:getLevelDesc(info.level, info.sub_lv))
    lbl_sub_level:setString("x"..info.star)
    item:getChildByName("lbl_award"):setString(Util:getFormatString(info.coupon))
    icon_level:loadTexture(string.format(GameRes.userLevelImg, info.level/10))

    if info.rank <= 3 then
        icon_rank:setVisible(true)
        lbl_rank:setVisible(false)
        icon_rank:loadTexture(string.format(GameRes.matching_rank, info.rank))
    else
        icon_rank:setVisible(false)
        lbl_rank:setVisible(true)
        lbl_rank:setString(info.rank)
    end

    self.userHead = UserHead.new({})
    self.headInfoDetail = self.userHead:getUI()
    self.headInfoDetail:setVisible(true)

    local headInfoSize = panel_avatar:getContentSize()
    local headInfoDetailSize = self.headInfoDetail:getContentSize()

    self.headInfoDetail:setPosition( -(headInfoDetailSize.width*0.66 - headInfoSize.width)/2,-(headInfoDetailSize.height*0.66 - headInfoSize.height)/2)
    panel_avatar:addChild(self.headInfoDetail)
    self.headInfoDetail:setScale(0.66)

    self.userHead:loadHeadImage(info.icon,0)

    if info.uin == Cache.user.uin then
        self.my_info = info
        bg:loadTexture(GameRes.matching_rank_bg2)
    else
        bg:loadTexture(GameRes.matching_rank_bg1)
    end
end

function MatchingRank:initMyRank()
    if self.my_info == null then
        self.my_info = self.data[#self.data]
    end

    local data = self.my_info
    local item = self.my_rank_bg
    local bg = item:getChildByName("bg")
    local icon_rank = item:getChildByName("my_icon_rank")
    local no_rank = item:getChildByName("no_rank")
    local panel_avatar = item:getChildByName("panel_avatar")
    local lbl_award = item:getChildByName("lbl_award")
    local lbl_rank = item:getChildByName("my_lbl_rank")
    local info_bg = item:getChildByName("info_bg")
    local icon_level = info_bg:getChildByName("icon_level")
    local lbl_level = info_bg:getChildByName("lbl_level")
    local icon_sub_level = info_bg:getChildByName("icon_sub_level")
    local lbl_sub_level = info_bg:getChildByName("lbl_sub_level")

    item:getChildByName("name"):setString(data.nick)
    lbl_level:setString(self:getLevelDesc(data.level, data.sub_lv))
    lbl_sub_level:setString("x"..data.star)
    item:getChildByName("lbl_award"):setString(Util:getFormatString(data.coupon))
    icon_level:loadTexture(string.format(GameRes.userLevelImg, data.level/10))

    local offsetX = lbl_level:getContentSize().width > 125 and lbl_level:getContentSize().width - 125 or 0
    icon_sub_level:setPositionX(icon_sub_level:getPositionX() + offsetX)
    lbl_sub_level:setPositionX(lbl_sub_level:getPositionX() + offsetX)

    if data.rank <=0 or data.rank > 100 then
        icon_rank:setVisible(false)
        lbl_rank:setVisible(false)
        no_rank:setVisible(true)
    elseif data.rank <= 3 then
        icon_rank:setVisible(true)
        lbl_rank:setVisible(false)
        icon_rank:loadTexture(string.format(GameRes.matching_rank, data.rank))
    else
        icon_rank:setVisible(false)
        lbl_rank:setString(data.rank)
    end

    self.userHead = UserHead.new({})
    self.headInfoDetail = self.userHead:getUI()
    self.headInfoDetail:setVisible(true)

    local headInfoSize = panel_avatar:getContentSize()
    local headInfoDetailSize = self.headInfoDetail:getContentSize()

    self.headInfoDetail:setPosition( -(headInfoDetailSize.width*0.66 - headInfoSize.width)/2,-(headInfoDetailSize.height*0.66 - headInfoSize.height)/2)
    panel_avatar:addChild(self.headInfoDetail)
    self.headInfoDetail:setScale(0.66)

    self.userHead:loadHeadImage(data.icon,0)
end

function MatchingRank:initClick()
    addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"panel"), function()
        self:close()
    end)
    addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"btn_exit"), function()
        self:close()
    end)
end

function MatchingRank:getLevelDesc(lv, sublv)
    local str = GameTxt.match_level_desc[lv]
    if lv ~= 70 then
        str = str .. GameTxt.match_sub_level_desc[sublv]
    end
    return str
end

return MatchingRank

