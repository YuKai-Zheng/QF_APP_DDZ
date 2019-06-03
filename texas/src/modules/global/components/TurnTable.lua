

local TurnTable = class("TurnTable", CommonWidget.BasicWindow)
local BloomNode = import("src.modules.common.widget.BloomNode")
TurnTable.TAG = "TurnTable"


TurnTable.Config={--本地缓存数据
    {id = 5, count = 888, type = 1, desc = "金币  x 888"},
    {id = 2, count = 1, type = 3, desc = "记牌器(1天)  x 1"},
    {id = 9, count = 1, type = 10, desc = "iPhoneX  x 1"},
    {id = 7, count = 2888, type = 1, desc = "金币  x 2888"},
    {id = 1, count = 5888, type = 1, desc = "金币  x 5888"},
    {id = 3, count = 50, type = 2, desc = "奖券  x 50"},
    {id = 6, count = 3, type = 4, desc = "超级加倍卡  x 3"},
    {id = 4, count = 50, type = 11, desc = "50元话费"},
    {id = 8, count = 200, type = 2, desc = "奖券  x 200"},
    {id = 0, count = 600, type = 2, desc = "奖券  x 600"}
}

function TurnTable:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    TurnTable.super.ctor(self, paras)
    self:initEffects()
    self:initData(paras)
    if paras and paras.cb then self.cb=paras.cb end
end
  
function TurnTable:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.TurnTableJson)

    self.closeBtn=ccui.Helper:seekWidgetByName(self.gui,"btn_close")
    self.goBtn=ccui.Helper:seekWidgetByName(self.gui,"btn_pointer")

    self.turntableImg=ccui.Helper:seekWidgetByName(self.gui,"turntable")

    self.nogameImg=ccui.Helper:seekWidgetByName(self.gui,"nogameImg")
    self.nogameText0=ccui.Helper:seekWidgetByName(self.gui,"text0")
    self.nogameText1=ccui.Helper:seekWidgetByName(self.gui,"text1")
    self.nogameText3 = ccui.Helper:seekWidgetByName(self.gui,"text3")
    
    self.tipsImg=ccui.Helper:seekWidgetByName(self.gui,"tipsImg")
    self.tipsTxt = self.tipsImg:getChildByName("txt")

	self.goEffetsImg=ccui.Helper:seekWidgetByName(self.gui,"goeffe")
    self.bgImg=ccui.Helper:seekWidgetByName(self.gui,"bgImg")
    self.nameEffetsImg=ccui.Helper:seekWidgetByName(self.gui,"nameeffect")
    self.lightEffetsImg=ccui.Helper:seekWidgetByName(self.gui,"light")
    self.time0Text=ccui.Helper:seekWidgetByName(self.gui,"time1")
    self.time1Text=ccui.Helper:seekWidgetByName(self.gui,"time2")

    self.leftTimeCount = ccui.Helper:seekWidgetByName(self.goBtn,"txt")
    self.durationTime = ccui.Helper:seekWidgetByName(self.gui,"durationTime")

    --查询下更新数据
    GameNet:send({ cmd = CMD.GET_DAY_LOGIN_REWARD_CFG,callback= function(rsp)
        if rsp.ret == 0 then
            if isValid(self) then
                self:initData(rsp.model)
            end
        end
    end})
end

 function TurnTable:updateBaseInfo()
    --剩余多少次可以抽奖
    self.leftTimeCount:setString(string.format(GameTxt.tunrtable_num_string, Cache.user.lucky_wheel_play_times))
    if Cache.user.lucky_wheel_play_times == 0 and Cache.user.lucky_wheel_play_amount ==0 then
        self.leftTimeCount:setVisible(false)
    else
        self.leftTimeCount:setVisible(true)
    end

    self.tipsTxt:setString(Cache.user.lucky_wheel_play_type)

    --活动时间
    local time = string.split(Cache.user.lucky_wheel_open_days, "|")
    self.durationTime:setString(string.format(GameTxt.turntable_duration_time, time[1], time[2]))
 end

function TurnTable:initData(paras)
    self:updateBaseInfo()
    --剩余次数是0
    if paras.left_time then
        Cache.user.lucky_wheel_play_times = paras.left_time  --剩余多少次可以抽
    end

    if paras.is_right_time then
        Cache.user.lucky_wheel_play_amount = paras.is_right_time --还有多少局可以领取
    end
    
    if Cache.user.lucky_wheel_play_times > 0 or Cache.user.lucky_wheel_play_amount > 0 then
        self.nogameImg:setVisible(false)
        self.goBtn:setTouchEnabled(true)
        self.goBtn:setBright(true)
        self.tipsImg:loadTexture(GameRes.TurnTable_tip_1)
        self.tipsTxt:setVisible(true)
    else
        -- 如果此时还剩下0局可获取抽奖的话那么就是已经领取完了
        if Cache.user.lucky_wheel_play_amount == 0 then
            self.tipsImg:loadTexture(GameRes.TurnTable_tip_2)
            self.tipsTxt:setVisible(false)
        end
        self.goEffetsImg:pause()
        self.goBtn:setTouchEnabled(false)
        self.goBtn:setBright(false)
    end
end

function TurnTable:initEffects( ... )
	-- body
    self.goEffetsImg:runAction(cc.RepeatForever:create(
    	cc.Sequence:create(
    	cc.Spawn:create(cc.FadeOut:create(0.5),cc.ScaleTo:create(0.5,1.5)),
    	cc.DelayTime:create(1.0),cc.CallFunc:create(function()
    		-- body
    		self.goEffetsImg:setOpacity(255)
    		self.goEffetsImg:setScale(1.0)
    	end)
    	)
    	))
    self.bgImg:stopAllActions()
    local bloom = BloomNode.new({
            image=GameRes.img_TurnTable_shape,
            create=false,
            move_back=false,
            move_forever=false,
            move_time=1.5
        })
    bloom:setPosition(self.nameEffetsImg:getPositionX(),self.nameEffetsImg:getPositionY())
    --bloom:setTag(self.SHOPCAR_BLOOM_TAG)
    self.bgImg:addChild(bloom, 1)
    self.bgImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(3.0),cc.CallFunc:create(function()
            bloom:playAnimation()       -- step1, 闪光
        end))))
end

function TurnTable:turnOver(paras)
    -- body
    MusicPlayer:playMyEffect("DIAMOND_POPUP")
    qf.event:dispatchEvent(ET.UPDATETURNICON)
    local rewardInfo = {}
    if self.Config[paras.index].type == 1 then
        rewardInfo = {self.Config[paras.index].count,0}
    elseif self.Config[paras.index].type == 2 then
        rewardInfo = {0,self.Config[paras.index].count}    
    end

    if self.Config[paras.index].type < 3 then
        qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {diamond = self.Config[paras.index].count, free=0,buyGoodsType= self.Config[paras.index].type,rewardInfo = rewardInfo, dismissCallBack = function ()
            if not isValid(self) then return end
            if paras.remain_times and paras.remain_times==0 then
                self:close()
            else
                self.lightEffetsImg:setVisible(false)

                self.turntableImg:setRotation(self.turntableImg:getRotation()%360)
            end
        end})
    elseif self.Config[paras.index].type == 3 then
        local daoju = self.Config[paras.index].desc 
        local daojuItemPic = GameRes.rememberCardImg
        qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {getRewardType = 2, rewardInfo = {"","","","","","","",daoju}, rewardInfoUrl = {"","","","","","","",daojuItemPic},dismissCallBack = function ()
            if not isValid(self) then return end
            if paras.remain_times and paras.remain_times==0 then
                self:close()
            else
                self.lightEffetsImg:setVisible(false)
                self.turntableImg:setRotation(self.turntableImg:getRotation()%360)
            end
        end})
    elseif self.Config[paras.index].type == 4 then
        local daoju = self.Config[paras.index].desc 
        local daojuItemPic = GameRes.super_multi_card
        qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, {getRewardType = 2, rewardInfo = {"","","","","","","",daoju}, rewardInfoUrl = {"","","","","","","",daojuItemPic},dismissCallBack = function ()
            if not isValid(self) then return end
            if paras.remain_times and paras.remain_times==0 then
                self:close()
            else
                self.lightEffetsImg:setVisible(false)
                self.turntableImg:setRotation(self.turntableImg:getRotation()%360)
            end
        end})
    else
        self.lightEffetsImg:setVisible(false)
        self.turntableImg:setRotation(self.turntableImg:getRotation()%360)
    end

    self.closeBtn:setTouchEnabled(true)
    qf.event:dispatchEvent(ET.MAIN_UPDATE_SHORTCUT_NUMBER)
end

function TurnTable:initClick( ... )
	-- body
	local turn=function( ... )
		-- body
		self.turntableImg:setRotation(self.turntableImg:getRotation()+10)
	end
    addButtonEvent(self.closeBtn,function (sender)
        self:close()
    end)
	local randTurns=math.random(8,10)
    local turnRsp=function(paras)
        --[[message LuckyWheelRewardRsp{
            optional int32 index=1;           // 停在那个奖励上
            optional int32 remain_times=2;    // 剩余可转次数,暂时为每个时段一次,可在服务端设置
            optional int32 reward_type=3;     // 奖励类型 1:金币 2：钻石 3：金卡 4：银卡
            optional int64 reward_nums=4;     // 获奖数量
            optional string reward_desc=5;     // 获奖说明
            optional string Reserve=6;         // 预留字段
        }--]]
        loga("停在那个奖励上" .. paras.index)
        loga("剩余可转次数" .. paras.remain_times)
        loga("奖励类型" .. paras.reward_type)
        loga("获奖数量" .. paras.reward_nums)
        loga("获奖说明" .. paras.reward_desc)
        loga(paras.left_time)

        Cache.user.lucky_wheel_play_times = paras.remain_times
        Cache.user.lucky_wheel_play_amount = tonumber(paras.Reserve)

        local randnum = 36
        local randAngle = self.Config[paras.index].id*36+randnum
        randAngle = -randAngle+randTurns*360

        local speed=1
        local timessss = os.time()
        self:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(0.01),
            cc.CallFunc:create(function( ... )
                -- body
                if self.turntableImg:getRotation()<=360 then
                    if self.turntableImg:getRotation()<40 then
                        speed=speed*1.03
                    else
                        speed=self.turntableImg:getRotation()*0.06
                    end
                elseif randAngle-self.turntableImg:getRotation()<1440 and randAngle-self.turntableImg:getRotation()>0 then
                    speed=(randAngle-self.turntableImg:getRotation())*0.015
                    if speed<0.3 then speed=0.3 end
                elseif self.turntableImg:getRotation()>=randAngle then
                    if self.lightEffetsImg then
                        self.lightEffetsImg:setVisible(true)
                        self.lightEffetsImg:setRotation(-randnum+36)
                    end

                    local turntablelight=0
                    
                    if paras.remain_times and paras.remain_times>0 then
                        self.goBtn:setTouchEnabled(true)
                    end
                    self:stopAllActions()
                    self:updateBaseInfo()
                    self:turnOver(paras)
                end
                if self.turntableImg:getRotation()+speed>randAngle then
                    speed=randAngle-self.turntableImg:getRotation()
                end
                self.turntableImg:setRotation(self.turntableImg:getRotation()+speed)
        end))))
    end
    addButtonEvent(self.goBtn,function(sender)
        self.goBtn:setTouchEnabled(false)
        self.goEffetsImg:stopAllActions()
        self.closeBtn:setTouchEnabled(false)
        if Cache.user.lucky_wheel_play_amount > 0 and Cache.user.lucky_wheel_play_times == 0 then
            self.closeBtn:setTouchEnabled(true)
            self.goBtn:setTouchEnabled(true)
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.more_game_to_turn_table, Cache.user.lucky_wheel_play_amount)})
        else
            GameNet:send({cmd=CMD.CMD_GET_LUCKY_WHEEL_REWARD, body={refer=UserActionPos.TURN_REF},callback=function ( rsp )
                loga(rsp.ret)
                if rsp.ret == 0 and rsp.model ~= nil then
                    turnRsp(rsp.model)
                else
                    self.goBtn:setTouchEnabled(true)
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                    self.closeBtn:setTouchEnabled(true)
                end
            end})
        end
        
    end)
end

function TurnTable:close()
    if self.turnlight then
        Scheduler:unschedule(self.turnlight)
        self.turnlight=nil
    end
    if self.turntime then
        Scheduler:unschedule(self.turntime)
        self.turntime=nil
    end
    if self.cb then
        self.cb()
    end

    TurnTable.super.close(self)
end

return TurnTable
