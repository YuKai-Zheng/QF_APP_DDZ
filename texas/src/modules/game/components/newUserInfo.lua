local M = class("newUserInfo", CommonWidget.BasicWindow)
local UserHead = import("...change_userinfo.components.userHead")--我的头像
local CustomScrollView = import("...common.widget.CustomScrollView")--滚动容器

M.CLICK_BLANK_TO_CLOSE = true

function M:ctor( paras )
    self.winSize = cc.Director:getInstance():getWinSize()
    M.super.ctor(self, paras)
end

function M:init( paras )
end

function M:initUI( paras )
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(DDZ_Res.newUserInfoJson)
    self.panel = ccui.Helper:seekWidgetByName(self.gui, "panel")
    self.headInfo = ccui.Helper:seekWidgetByName(self.panel, "headInfo")
    self.sexImage = ccui.Helper:seekWidgetByName(self.panel, "sexImage")
    self.nick_txt = ccui.Helper:seekWidgetByName(self.panel, "nick_txt")
    self.currentLevel = ccui.Helper:seekWidgetByName(self.panel, "currentLevel")
    self.coin_num = ccui.Helper:seekWidgetByName(self.panel, "coin_num")
    self.winrate_txt = ccui.Helper:seekWidgetByName(self.panel, "winrate_txt")
    self.panel_ani = ccui.Helper:seekWidgetByName(self.panel, "panel_ani")
    self.ani_select = ccui.Helper:seekWidgetByName(self.panel, "ani_select")

    self.aniItem = ccui.Helper:seekWidgetByName(self.gui, "aniItem")

    self:updateUserInfo( paras )
end

function M:updateUserInfo( paras )
    self.paras = paras
    self.uin = paras.uin
    self.isBurst = cc.UserDefault:getInstance():getBoolForKey(SKEY.BURST_INTERACT,true) -- 连发
    self.burstNum = 5   -- 连发数
    self.interactTime = Cache.Config:getInteractTime() or 0

    local offsetX = 0

    if FULLSCREENADAPTIVE then
        offsetX = (self.winSize.width - 1980)/2
    end
    if paras.dir == "user_first" then
        self.panel:setPositionX(320 + offsetX)
    else
        self.panel:setPositionX(self.panel:getPositionX() + offsetX/2)
    end

    self:getMatchingResultInfo()
    self:initNameInfo()
    self:initCoinInfo()
    self:initAniInfo()
    self:setSelect(self.isBurst == nil and true or self.isBurst)
end

function M:getMatchingResultInfo()
    GameNet:send({cmd=CMD.USER_INFO,body={other_uin=self.uin},
        callback=function(rsp)
            if rsp.ret == 0 then
                if rsp.model then
                    self:updateUserMatchingInfo(rsp.model)
                end
            end
        end
    })
end

function M:updateUserMatchingInfo(model)
    if model.match_max_level and model.match_max_level > 0 then
        self.currentLevel:getChildByName("num"):setString(Cache.user:getConfigByLevel(model.match_max_level).title)
    else
        self.currentLevel:getChildByName("num"):setString(Cache.user:getConfigByLevel(10).title)
    end

    self.winrate_txt:setString(model.win_prob or "0")

    self.sexImage:loadTexture(string.format(GameRes.img_user_info_my_sex, model.sex))

    local levelNum = Util:getLevelNum(model.all_lv_info.sub_lv)
    local maxLevel = Cache.user:getMaxLevel()
    if model.all_lv_info.match_lv == maxLevel then
        self.currentLevel:getChildByName("num"):setString(Cache.user:getConfigByLevel(model.all_lv_info.match_lv).title)
    else
        self.currentLevel:getChildByName("num"):setString(Cache.user:getConfigByLevel(model.all_lv_info.match_lv).title .. levelNum)
    end

    self:initHeadInfo(model)
end

function M:initHeadInfo(model)
    if not self.userHead then
        self.userHead = UserHead.new({})
        self.headInfoDetail = self.userHead:getUI()
        self.headInfoDetail:setScale(0.75)
		self.headInfo:addChild(self.headInfoDetail)
    end

    self.headInfoDetail:setVisible(true)
    self.userHead:loadHeadImage(model.portrait,model.sex,model.icon_frame,model.icon_frame_id)
end

function M:initNameInfo()
    local nickName = Util:filterEmoji(self.paras.nick) or ""
    self.nick_txt:setString(Util:getCharsByNum(Util:filter_spec_chars(nickName),12))
end

function M:initCoinInfo()
    self.coin_num:setString(Util:getFormatString(self.paras.gold))
end

function M:initAniInfo()
    self.panel_ani:removeAllChildren()

    local info = {}

    for i=1, #DDZ_Res.InteractivePressive do
        table.insert(info, {id=i, res=DDZ_Res.InteractivePressive[i]})
    end

    local updateBtn = function(info, item)
        item:loadTextureNormal(info.res)

        local time = os.time() - self.interactTime
        if time < 5 then
            item:getChildByName("mask"):setVisible(true)
            item:getChildByName("txt_time"):setVisible(true)
            local repeatAction = cc.Repeat:create(
                cc.Sequence:create(
                    cc.CallFunc:create(function()
                        item:getChildByName("txt_time"):setString(5-time)
                        time = time + 1
                    end),
                    cc.DelayTime:create(1)
                ),5-time)

            item:runAction(cc.Sequence:create(
                repeatAction,
                cc.CallFunc:create(function()
                    item:getChildByName("mask"):setVisible(false)
                    item:getChildByName("txt_time"):setVisible(false)
                end)
            ))
        end

        addButtonEvent(item, function()
            self:sendAnimation(info.id)
        end)
    end

    self.scroll_rank_list = CustomScrollView.new({
        defaultNode = self.aniItem,
        datalist = {},
        updata = updateBtn,
        direction = ccui.ScrollViewDir.horizontal,
        delay = 0,
        limitMaxNum = 5,
        margin = 30
    })
    self.scroll_rank_list:setContentSize(self.panel_ani:getContentSize().width, self.panel_ani:getContentSize().height)
    self.scroll_rank_list:setShowActionEnabled(false)
    self.panel_ani:addChild(self.scroll_rank_list)

    self.scroll_rank_list:refreshData(info, true)
end

function M:sendAnimation(id)
    if os.time() - self.interactTime < 5 then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = "您发的表情太多了，休息一会再发哦~"})
        return
    end

    Cache.Config:setInteractTime(os.time())
    self.panel_ani:stopAllActions()

    local body = {to_uin = self.uin, expression_id = id, times = self.isBurst and self.burstNum or 1}
    qf.event:dispatchEvent(ET.PLAY_INTERACT_ANIMATION, {
        body = body,
        isBurst = self.isBurst,
        burstNum = self.burstNum
    })

    self:close()
end

function M:setSelect(bool)
    self.ani_select:getChildByName("selected"):setVisible(bool)
    cc.UserDefault:getInstance():setBoolForKey(SKEY.BURST_INTERACT,bool)
    self.isBurst = bool
end

function M:initClick(paras)
    addButtonEvent(self.ani_select, function()
        self:setSelect(not self.isBurst)
    end)
end

return M