local M = class("TuiGuangController", qf.controller)
local TuiGuangMainView = import(".components.TuiGuangMainView")
local TuiGuangRuleView = import(".components.TuiGuangRuleView")
local TuiGuangOfficalView = import(".components.TuiGuangOfficalView")
local TuiGuangFriendInfoView = import(".components.TuiGuangFriendInfoView")

M.TAG = "TuiGuangController"

function M:initGlobalEvent(  )
    qf.event:addEvent(ET.SHOW_TUIGUANG_VIEW, handler(self, self.showTuiGuangView))
    qf.event:addEvent(ET.SHOW_TUIGUAN_RULE_VIEW, handler(self, self.showTuiGuangRuleView))
    qf.event:addEvent(ET.SHOW_TUIGUANG_OFFICIAL_VIEW, handler(self, self.showTuiGuangOfficialView))
    qf.event:addEvent(ET.SHOW_TUIGUANG_FRIENDINFO_VIEW, handler(self, self.showTuiGuangFriendInfoView))

    qf.event:addEvent(ET.TUIGUANGINFO_REQ, handler(self, self.getTuiGuangInfoReq))
    qf.event:addEvent(ET.TUIGUANG_REWARD_REQ, handler(self, self.tuiGuangRewardReq))

    qf.event:addEvent(ET.TUIGUANG_INFO_NTF, handler(self, self.updateTuiGuangInfo))

    qf.event:addEvent(ET.TUIGUANG_FRIEND_REQ, handler(self, self.getTuiGuangFriendReq))
end

function M:showTuiGuangView(  )
    qf.event:dispatchEvent(ET.TUIGUANGINFO_REQ, {cb = function (  )
        self.tuiGuangView = PopupManager:push({class = TuiGuangMainView})
        PopupManager:pop()
    end})
end

function M:showTuiGuangRuleView(  )
    PopupManager:push({class = TuiGuangRuleView})
    PopupManager:pop()
end

function M:showTuiGuangOfficialView(  )
    PopupManager:push({class = TuiGuangOfficalView})
    PopupManager:pop()
end

function M:showTuiGuangFriendInfoView(  )
    qf.event:dispatchEvent(ET.TUIGUANG_FRIEND_REQ, {
        cb = function ( model )
            PopupManager:push({class = TuiGuangFriendInfoView, init_data = {model = model}})
            PopupManager:pop()
        end
    })
end

function M:getTuiGuangInfoReq( paras )
    loga("发送推广请求")
    GameNet:send({
        cmd = CMD.TUIGUANG_INFO_REQ,
        callback = function ( rsp )
            if rsp.ret == 0 then
                local model = rsp.model
                Cache.Config:setTuiGaungInfo(model)
                local tuiGuangView = PopupManager:getPopupWindowByUid(self.tuiGuangView)
                if paras and paras.cb then
                    paras.cb()
                elseif isValid(tuiGuangView) then
                    tuiGuangView:updateView()
                end

                qf.event:dispatchEvent(ET.UPDATE_TUIGUANG_QIPAO)
            end
        end
    })
end

function M:tuiGuangRewardReq( paras )
    loga("请求领取奖励id:".. paras.task_id)
    GameNet:send({
        cmd = CMD.TUIGUANG_REWARD_REQ,
        body = paras,
        callback = function ( rsp )
            dump(rsp.ret, "领取奖励")
            if rsp.ret == 0 then
                dump(rsp.model.reward_num)
                qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {rewardInfo = {0,0,0,0,0,0,0,0,rsp.model.reward_num / 100}})
            end
        end
    })
end

function M:updateTuiGuangInfo( rsp )
    loga("收到推广更新通知")
    local model = rsp.model
    dump(pb.tostring(model), "推广数据")
    Cache.Config:updateTuiGuangInfo(rsp.model)

    local tuiGuangView = PopupManager:getPopupWindowByUid(self.tuiGuangView)
    if isValid(tuiGuangView) then
        tuiGuangView:updateView()
    end

    qf.event:dispatchEvent(ET.UPDATE_TUIGUANG_QIPAO)
end

function M:getTuiGuangFriendReq( paras )
    GameNet:send({
        cmd = CMD.TUIGUANG_FRIEND_REQ,
        callback = function ( rsp )
            local model = rsp.model

            if rsp.ret == 0 then
                if paras and paras.cb then
                    paras.cb(model)
                end
            end
        end
    })
end

return M