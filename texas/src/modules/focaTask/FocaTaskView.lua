local FocaTaskView = class("FocaTaskView", CommonWidget.BasicWindow)

FocaTaskView.TAG = "FocaTaskView"
FocaTaskView.LIST_ACTION_TAG = 1101

function FocaTaskView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    FocaTaskView.super.ctor(self,parameters)
    qf.platform:umengStatistics({umeng_key = "Task"})
end

function FocaTaskView:initUI(parameters)
    Cache.ActivityTaskInfo:clearInfo()--清除掉奖励信息
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.focaTaskViewJson)
    self.item = self.gui:getChildByName("item")
    self.listview = self.gui:getChildByName("listview")
    self.listview:setItemModel(self.item)
    self.focaBanner = ccui.Helper:seekWidgetByName(self.gui, "focaBanner")
    self.gui:getChildByName("bg"):setTouchEnabled(true)
    self.foca = ccui.Helper:seekWidgetByName(self.gui, "focaInfo"):getChildByName("foca")

    self.foca:getChildByName("focaNum"):setString(Cache.user.fucard_num)  
end

function FocaTaskView:initClick(  )
    addButtonEvent(self.gui:getChildByName("back_btn"), function (  )
        self:close()
    end)

    addButtonEvent(self.focaBanner, function (  )
        if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW and TB_MODULE_BIT.BOL_MODULE_BIT_EXCHANGE_FUCARD then
            self:close(function (  )
                qf.event:dispatchEvent(ET.SHOW_EXCHANGEMALL_VIEW)
            end)
        end
    end)

    addButtonEvent(self.focaBanner:getChildByName("btn_goCharge"), function (  )
        if TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW and TB_MODULE_BIT.BOL_MODULE_BIT_EXCHANGE_FUCARD then
            self:close(function (  )
                qf.event:dispatchEvent(ET.SHOW_EXCHANGEMALL_VIEW)
            end)
        end
    end)
end

function FocaTaskView:enterCoustomFinish()
    
    -- self:refreshListview()
end
--[[刷新Listview]]
function FocaTaskView:refreshListview()
    self.foca:getChildByName("focaNum"):setString(Cache.user.fucard_num) 
    loga("board_url"..Cache.ActivityTaskInfo.rewardList.board_url)
    self:setHeadByUrl(self.focaBanner,Cache.ActivityTaskInfo.rewardList.board_url)
    self:stopListDelayRun()
    self.boxItem = nil
    self.listview:removeAllChildren(true)

    local j = 1
    local foca_task_list = {}
    self.mannerAddPart = 0 

    local dataCoinGame = {
        activity_PBClass = "ActivityInfo",
        activity_type    = 1,
        board_type       = 0,
        board_url        = "",
        can_pick         = 1,
        content          = "玩局即可获得奖券，场次越高奖励越丰厚",
        end_time         = "2018-09-25",
        id               = 41,
        image_url        = "",
        only_pop         = 0,
        page_url         = "",
        reward_id        = 41,
        reward_type      = 1,
        show_board       = 0,
        title            = "欢乐模式玩游戏"
    }
    table.insert(foca_task_list,dataCoinGame)
    self.mannerAddPart = self.mannerAddPart + 1

    local dataWanYuanCompetition = {
        activity_PBClass = "ActivityInfo",
        activity_type    = 1,
        board_type       = 0,
        board_url        = "",
        can_pick         = 1,
        content          = "达到指定头衔，可获得奖券",
        end_time         = "2018-09-25",
        id               = 41,
        image_url        = "",
        only_pop         = 0,
        page_url         = "",
        reward_id        = 41,
        reward_type      = 1,
        show_board       = 0,
        title            = "排位赛"
    }
    table.insert(foca_task_list,dataWanYuanCompetition)
    self.mannerAddPart = self.mannerAddPart + 1

    if Cache.user.show_cumulate_login_or_not == 0 then
        local newUserReward = {
            activity_PBClass = "ActivityInfo",
            activity_type    = 1,
            board_type       = 0,
            board_url        = "",
            can_pick         = 1,
            content          = "累计登录7天送奖券",
            end_time         = "2018-09-25",
            id               = 43,
            image_url        = "",
            only_pop         = 0,
            page_url         = "",
            reward_id        = 43,
            reward_type      = 1,
            show_board       = 0,
            title            = "新手专属礼包"
        }
        table.insert(foca_task_list,newUserReward)
        self.mannerAddPart = self.mannerAddPart + 1
    end

    for i = 1 , #Cache.ActivityTaskInfo.rewardList.foca_task_list do
        local item = Cache.ActivityTaskInfo.rewardList.foca_task_list[i]
        table.insert(foca_task_list,item)
    end 
    
    if foca_task_list ~= nil and #foca_task_list > 0 then
        for i = 1 , #foca_task_list do
            self:listDelayRun(LIST_ITEM_TIME*(i - j),function()
            local info = foca_task_list[i]            
                j =  self:updateItem(info,i,j,1)
            end)
        end 
    end
end

function FocaTaskView:refreshTaskBtn(btn,status)
    if btn == nil or status == nil then return end
    if status == 1 then
        btn:setTouchEnabled(true)
        btn:loadTexture(GameRes.reward_get_btn)
    elseif status == 0 then
        btn:setTouchEnabled(false)
        btn:loadTexture(GameRes.reward_goon_btn)
    elseif status == 2 then
        btn:setTouchEnabled(false)
        btn:loadTexture(GameRes.reward_have_btn)
    end
end

function FocaTaskView:updateItem(info,i,j,index)
    self.listview:pushBackDefaultItem()
    local item = self.listview:getItem(i - j)
    item:setVisible(true)
    
    local btn = item:getChildByName("item_btn")
    btn:setTouchEnabled(true)
    item:getChildByName("title"):setString(info.title) 
    if info.activity_PBClass == "ActivityInfo" then
        local contentTable = string.split(info.content, "<br>")
        if #contentTable > 1 then
            item:getChildByName("subTitle"):setString(contentTable[2])
        else
            item:getChildByName("subTitle"):setString(info.content)
        end   
    elseif info.activity_PBClass == "TaskInfo" then
        item:getChildByName("subTitle"):setString(info.desc)
    else
        item:getChildByName("subTitle"):setString("")
    end
    item:getChildByName("item_img"):setVisible(false)
    if i < self.mannerAddPart + 1 then
        item:getChildByName("item_img"):setVisible(true)
        if info.title == "新手专属礼包" then 
            item:getChildByName("item_img"):loadTexture(GameRes.hongBao)
            btn:getChildByName("item_btnTitle"):setString("去完成")
            addButtonEvent(btn,function() 
                qf.event:dispatchEvent(ET.EVENT_CLOSE_FOCAS_CENTER_TO_ACTIVE_CENTER,{})
            end)
        elseif info.title == "排位赛" then
            item:getChildByName("item_img"):loadTexture(GameRes.rewardCup)
            btn:getChildByName("item_btnTitle"):setString("去参加")
            addButtonEvent(btn,function() 
                self:close(function (  )
                    qf.event:dispatchEvent(ET.EVENT_CLOSE_FOCAS_CENTER_TO_MATHINGE_CENTER,{})
                end) 
            end)
        elseif info.title == "欢乐模式玩游戏" then
            item:getChildByName("item_img"):loadTexture(GameRes.rewardCoinGame)
            btn:getChildByName("item_btnTitle"):setString("去玩游戏")
            addButtonEvent(btn,function() 
                self:close(function (  )
                    qf.event:dispatchEvent(ET.EVENT_JUMP_QUICK_COIN_GAME,{})
                end) 
            end)
        end
    else
        self:setHeadByUrl(item:getChildByName("item_img"),info.image_url)
        btn:getChildByName("item_btnTitle"):loadTexture(GameRes.qucanjiaImg)
        addButtonEvent(btn,function() 
            if info.page_url then
                self:showWebView(info.page_url)
                -- 活动页面点击上报
                qf.platform:umengStatistics({umeng_key = "Activity_"..info.id})
            end
        end)
    end
    Display:showScalePop({view = item})
    return j
end

function FocaTaskView:listDelayRun(time,cb)
    self.gui:getChildByName("listview"):runAction(cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    ))
end

function FocaTaskView:stopListDelayRun()
    self.gui:getChildByName("listview"):stopAllActions()
end

function FocaTaskView:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    action:setTag(self.LIST_ACTION_TAG)
    self:runAction(action)
end

--[[获取父控件中table中的控件并存储到son  table中]]
function FocaTaskView:getTableChild(keyTable,father,son)
    for key, v in pairs(keyTable) do
        son[v] = father:getChildByName(v)
    end
end

--[[下载图片]]
function FocaTaskView:setHeadByUrl(view,url)
    if view == nil or url == nil then return end
    local kImgUrl
    if Util:judgeHasHttpSuffex(RESOURCE_HOST_NAME,"http") then
        kImgUrl = RESOURCE_HOST_NAME.."/"..url
	else
        kImgUrl = HOST_PREFIX..RESOURCE_HOST_NAME.."/"..url
    end
    local reg = qf.platform:getRegInfo()
    local taskID = qf.downloader:execute(kImgUrl, 10,
        function(path)
            if not tolua.isnull( self ) then
                view:loadTexture(path)
            end
            view:setVisible(true)
        end,
        function()
        end,
        function()
        end
    )
end

function FocaTaskView:showWebView (uu,ref) 
    local reg = qf.platform:getRegInfo()
    if ref==nil then
      ref=UserActionPos.ACTIVITY_CENTER
    end
    self.url = HOST_PREFIX..HOST_NAME.."/"..uu.."?uin="..Cache.user.uin.."&key="..QNative:shareInstance():md5(Cache.user.key).."&channel="..reg.channel.."&version="..reg.version.."&ref="..ref
    loga(self.url)
    self:_showWebView(self.url)
end

function FocaTaskView:_showWebView(url)
    self.webIsShowing = true
    local winsize = cc.Director:getInstance():getWinSize()
    local fsize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local w = winsize.width
    local h = fsize.height*winsize.width/fsize.width
    local x = 0
    local y = 0
    logd(" -- show webview url="..url,self.TAG)
    qf.platform:showWebView({url=url,x=x,y=y,w=w,h=h,
        cb=function ( paras )
            if paras == "start" then 
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="add",txt=GameTxt.net005})
            else
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
            end
        end,
        cb2=function ( paras )
            logd("cb2   close webview",self.TAG)
            qf.event:dispatchEvent(ET.NET_ALL_ACTIVITY_REQ)
            self:webviewExit()
        end
    })
end

function FocaTaskView:webviewExit()
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
    self.webIsShowing = false
    qf.platform:removeWebView()
end


return FocaTaskView