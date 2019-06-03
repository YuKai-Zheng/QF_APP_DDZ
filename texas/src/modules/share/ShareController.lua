local ShareController = class("ShareController",qf.controller)
ShareController.TAG = "ShareController"
local shareView = import(".ShareView")
local   playAnimCall = nil
function ShareController:ctor(parameters)
    ShareController.super.ctor(self)
end

function ShareController:initModuleEvent()

end

function ShareController:removeModuleEvent()
end

-- 这里注册与服务器相关的的事件，不销毁
function ShareController:initGlobalEvent()

    --特殊牌型准备关闭界面了
    qf.event:addEvent(ET.SHARE_HIDE,function(paras)
        if self.view then
            self:remove()
            self.view = nil
        end
    end)
    
    --经典场赢钱需要等动画播放到win的时候才开始截图
    qf.event:addEvent(ET.SHARE_CHECK_SHOW,function(paras)
        if playAnimCall then
            playAnimCall()
        end
    end)

    --積分兌換通知
    qf.event:addEvent(ET.NET_SCORE_CLIENT_SHARE,function(paras)--服务器告诉可以分享了
        if self.scoreExchangeWebViewIsOpen then --如果积分中打开了webview
            self.scoreExchangeWebViewIsOpen = false  
            qf.platform:removeWebView()  
        end 
        
        local txt = paras.model.item_type == 3 and GameTxt.share_txt_3 or GameTxt.share_txt_4
        txt = string.format(txt,paras.model.item_name)
        self:show({type = SHARE_SHOW_TYPE_JF ,item_id = paras.model.item_id , txt = txt})
        if not paras.isShopView then
            qf.event:dispatchEvent(ET.ACTIVITY_HIDE_WEBVIEW)
        end
    end)

    qf.event:addEvent(ET.SHOW_SHARE,function(paras)
        if paras.type and paras.type == SHARE_SHOW_TYPE_PH then--排行榜
            paras ={type = paras.type , title = paras.title , rank = paras.rank ,txt = string.format(GameTxt.share_txt_5,GameTxt.share_labs[paras.title],paras.rank) }
            self:show(paras)
        else--特殊牌型
            if self.view then
                self:remove()
                self.view = nil
            end
            self:show({type = SHARE_SHOW_TYPE_TS ,txt = string.format(GameTxt.share_txt_2,paras.txt)})
        end
    end)

    qf.event:addEvent(ET.CHECK_WIN_SHARE,function(paras)
        playAnimCall = nil
        local isWin = false
        local len = paras.model.winners:len()
        for i=1, len do
           local uin = paras.model.winners:get(i)
           if uin == Cache.user.uin then
                isWin = true
           end
        end
        
        if not isWin then return end
        
        local allChip = 0
        local len1 = paras.model.result:len()
        for i=1, len1 do
            local ret = paras.model.result:get(i)
            local len2 = ret.settle:len()
            for j=1, len2 do
                local set = ret.settle:get(j)
                if set.uin == Cache.user.uin then
                    allChip = allChip+set.chips
                end
            end
        end
    
        local big_blind, small_blind =  Cache.desk:getRoomBlind()   --只有经典场才有胜局分享
        --loga("赢："..allChip.." 大盲："..big_blind.."倍数："..Cache.Config.when_to_share.classic_win_big_blind)
        if allChip/big_blind >= Cache.Config.when_to_share.classic_win_big_blind then
            playAnimCall = function()
                self:show({type = SHARE_SHOW_TYPE_JD ,chip = allChip , txt = string.format(GameTxt.share_txt_1,allChip)})
            end
        end
    end)
    
    --排行榜
    --type固定传5 或者 SHARE_SHOW_TYPE_PH
    --title 为什么榜传以下索引 如上周美女排行 则传 10
    --   {
    --        "周战绩榜",
    --        "周盈利榜",
    --        "日单局榜",
    --        "财富榜",
    --        "世界周战绩榜",
    --        "世界周盈利榜",
    --        "世界日单局榜",
    --        "世界财富榜",
    --        "美女排行",
    --        "上周美女排行"
    --    }
    --rank 1到3的数字
    --    self:show({type = SHARE_SHOW_TYPE_JD ,chip = 9876 , txt = "999"})
    --    qf.event:dispatchEvent(ET.SHOW_SHARE,{type = 5 , title = 1 , rank = 8 })
    --    self:show({type = SHARE_SHOW_TYPE_JF ,item_id = 10 , txt = "asdf asdf "})
    --    self:show({type = SHARE_SHOW_TYPE_JD ,chip = "123456" , txt = "test"})
end

function ShareController:show(para)
    if string.find(GAME_CHANNEL_NAME,"CN_BAIDU") ~= nil then 
        return
    end
--    if true then return end  -- 屏蔽分享

    if self.view then
            logd("shareView existed" , ShareController.TAG)
            return
    end
    ShareController.super.show(self,para)
    playAnimCall = nil
end

function ShareController:initView(para)
    qf.event:dispatchEvent(ET.MODULE_SHOW,"share")
    para.id = PopupManager.POPUPVIEW.share
    para.style = PopupManager.BG_STYLE.NONE
    self.view = shareView.new(para)
    return self.view
end

function ShareController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"share")
    ShareController.super.remove(self)
end

return ShareController