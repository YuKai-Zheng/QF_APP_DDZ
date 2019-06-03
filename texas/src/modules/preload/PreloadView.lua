local PreloadView = class("PreloadView",qf.view)

PreloadView.TAG = "PreloadView"

function PreloadView:ctor(paras)
    PreloadView.super.ctor(self,paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:init()
end

--M.noviceViewJson = "cn/ui/novice_layout_1.json"--新手礼包通知界面
--M.getPicture1Json = "cn/ui/getpicture1.json"--拍照json1文件
--M.getPicture2Json = "cn/ui/getpicture2.json"--拍照json2文件
--M.changeUserinfoJson = "cn/ui/change_userinfo.json"--修改个人信息json文件
--M.friendViewJson = "cn/ui/FriendLayer_1.json"--好友界面json文件
--M.sendSuccJson = "cn/ui/FriendLayer_sendSucc.json"--  好友送礼界面json文件
--M.gameViewJson = "cn/ui/playGame_1.json"--  游戏内界面json文件
--M.gameChatJson = "cn/ui/gameChat_1.json"--  聊天信息界面json文件
--M.exitDialogJson = "cn/ui/exitDialog.json"--  退出游戏界面json文件
--M.gameLevelUpJson = "cn/ui/prompt_user.json"--  场次升级界面json文件
--M.gameShopJson = "cn/ui/game_shop_layout.json"--  游戏内商城json文件
--M.userInfoJson = "cn/ui/userinfo.json"--  个人信息界面json文件
--M.broadcastJson = "cn/ui/broadcast.json"--  广播json文件
--M.bankruptcyJson = "cn/ui/bankruptcy_1.json"--  领取救济金界面json文件
--M.globalPromit = "cn/ui/globlePromit_1.json"-- 公共提示框
--M.dayEventJson = "cn/ui/day_event.json"--  日常活动推荐活动json文件
--M.shopPromitJson = "cn/ui/shop_promit_layout.json"--  确认购买界面json文件
--M.taskFinishJson = "cn/ui/task_finish.json"--  完成任务界面json文件
--M.lobbyViewJson = "cn/ui/lobbyLayout_1.json"--  大厅界面json文件
--M.searchDeskJson = "cn/ui/lobbySearchDesk.json"--  搜索房间json文件
--M.passwordViewJson = "cn/ui/lobbySearchDesk.json"--  输入密码界面json文件
--M.mainViewJson = "cn/ui/main_1.json"--  主界面json文件
--M.dayRewardJson = "cn/ui/dayreward.json"--  签到界面json文件
--M.rankViewJson = "cn/ui/FrankLayout_1.json"--  排行界面json文件
--M.rewardViewJson = "cn/ui/reward.json"--  奖励界面json文件
--M.settingViewJson = "cn/ui/setting_1.json"--  设置界面json文件
--M.aboutViewJson = "cn/ui/about.json"--  关于界面json文件
--M.courseReturnJson = "cn/ui/course_return.json"--  新手教程返回界面json文件
--M.courseTipsJson = "cn/ui/course_tips.json"--  新手教程提示界面json文件
--M.texaShopJson = "cn/ui/texashop.json"--  商城界面json文件
--M.pcLoginJson  = "cn/ui/pcLogin_1.json" -- pc登录
--M.responseChallengeJson = "cn/ui/GameChallenge.json"--  响应挑战界面json文件

function PreloadView:init()
    local name = {
        "dayEventJson"--  日常活动推荐活动json文件
        ,"dayRewardJson"--  签到界面json文件
        ,"changeUserinfoJson"--修改个人信息json文件        
        ,"lobbyViewJson"--  大厅界面json文件        
        ,"rewardViewJson"--  奖励界面json文件
        ,"settingViewJson"--  设置界面json文件
        ,"aboutViewJson"--  关于界面json文件
        ,"agreementViewJson"--  用户协议界面json文件
        ,"privacyViewJson"--  隐私策略界面json文件
        ,"texaShopJson"--  商城界面json文件
        ,"passwordViewJson"--  输入密码界面json文件
        ,"noviceViewJson"--新手礼包通知界面
        ,"searchDeskJson"--  搜索房间json文件
        ,"mainViewJson"--  主界面json文件
        ,"courseReturnJson"--  新手教程返回界面json文件
        ,"courseTipsJson"--  新手教程提示界面json文件
        ,"pcLoginJson" -- pc登录
        ,"responseChallengeJson"--  响应挑战界面json文件
        ,"shopPromitJson"--  确认购买界面json文件
        ,"taskFinishJson"--  完成任务界面json文件
        ,"bankruptcyJson"--  领取救济金界面json文件
        ,"globalPromit"-- 公共提示框
        ,"gameViewJson"--  游戏内界面json文件
        ,"gameChatJson"--  聊天信息界面json文件
        ,"exitDialogJson"--  退出游戏界面json文件
        ,"gameLevelUpJson"--  场次升级界面json文件
        ,"userInfoJson"--  个人信息界面json文件
        ,"broadcastJson"--  广播json文件
        ,"getPicture1Json"--拍照json1文件
        ,"getPicture2Json"--拍照json2文件
    }
    local function preloadF()
        if name ~= nil and #name > 0 then
            self:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(0.2),
                    cc.CallFunc:create(function() 
                        local json = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes[name[#name]])
                        logd("加载文件-->"..name[#name],self.TAG)
                        self:addChild(json)
                        json:removeFromParent(true)
                        name[#name] = nil
                        return preloadF()
                    end)
            ))
        else
            logd("加载文件-->结束",self.TAG)
            qf.event:dispatchEvent(ET.PRELOAD_JSON_END)
        end
    end
    preloadF()
end

function PreloadView:getRoot() 
    return LayerManager.PreloadLayer
end

return PreloadView