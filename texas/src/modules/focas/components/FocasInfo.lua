local FocasInfo = class("FocasInfo", CommonWidget.BasicWindow)
FocasInfo.TAG = "FocasInfo"
local MineRecord = import(".MineRecord")
local GetFocas = import(".GetFocas")
function FocasInfo:ctor(paras)
    FocasInfo.super.ctor(self, paras)
    self:initCheckClick()
    self.index = paras.index
    self:initDuobaoView(paras)
    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        local bg = ccui.Helper:seekWidgetByName(self.gui,"Image_1")
        bg:setPositionX(bg:getPositionX()+(self.winSize.width - 1980)/2)
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
    end
end

function FocasInfo:init(paras)
    if paras and paras.cb then
        self.cb = paras.cb
    end
end

function FocasInfo:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.FocasInfoJson)
    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"closebtn")
    self.checkP = ccui.Helper:seekWidgetByName(self.gui,"checkP")--选择层

    self.detailsP = ccui.Helper:seekWidgetByName(self.gui,"detailsP")--夺宝详情
    self.oldwinnerList = ccui.Helper:seekWidgetByName(self.gui,"ListView_wang_qi")--往期得主层
    self.oldwinnerItem = ccui.Helper:seekWidgetByName(self.gui,"wang_qi_item")--往期得主
    self.bg1 = ccui.Helper:seekWidgetByName(self.detailsP,"Image_bg1")--夺宝详情背景
    self.bg2 = ccui.Helper:seekWidgetByName(self.detailsP,"Image_bg2")--夺宝详情背景
    self.bg3 = ccui.Helper:seekWidgetByName(self.gui,"Image_bg3")--夺宝详情背景
    self.winnerP = ccui.Helper:seekWidgetByName(self.detailsP,"xing_yun")--中奖人层
    self.winByTimeP = ccui.Helper:seekWidgetByName(self.detailsP,"timingP")--限时中奖层
    self.winByTimerP = ccui.Helper:seekWidgetByName(self.detailsP,"jin_du_tiao")--满次中奖层
    self.setGoodsNumP = ccui.Helper:seekWidgetByName(self.detailsP,"jion_duo_bao")--夺宝选择次数层
    self.duobaoNum = ccui.Helper:seekWidgetByName(self.setGoodsNumP,"jion_num")--我要参见的次数
    self.duobaoTime = 1
    self.duobaoNum:setString(self.duobaoTime)
    self.duobaoBtn = ccui.Helper:seekWidgetByName(self.detailsP,"jion_btn")--夺宝按钮  
    self.duobaoFocasNum = ccui.Helper:seekWidgetByName(self.duobaoBtn,"jion_btn_txt1")--购买所需奖券数
    self.waitTxt = ccui.Helper:seekWidgetByName(self.detailsP,"deng_dai")--等待开奖字样
end

--初始化界面参数
function FocasInfo:initDuobaoView(paras)
    -- body
    if not self.index then return end
    self.msg = nil
    for k,v in pairs(Cache.focasInfo.indianaDetail) do
        if self.index == v.item_id then
            self.msg = v
            break
        end
    end 
    if not self.msg then 
        self:close()
    end
    ccui.Helper:seekWidgetByName(self.detailsP,"name"):setString(self.msg.name)--物品名称0
    ccui.Helper:seekWidgetByName(self.detailsP,"goodstimer"):setString("[第"..self.msg.periods_now.."/"..self.msg.periods_all.."期]")--第几期
    ccui.Helper:seekWidgetByName(self.detailsP,"goodsinfo"):setString(self.msg.desc)--物品描述
    local taskID = qf.downloader:execute(self.msg.pic, 10,
        function(path)
            if not tolua.isnull( self ) then
                ccui.Helper:seekWidgetByName(self.detailsP,"goodsimg"):loadTexture(path)
            end
        end,
        function()
        end,
        function()
        end
    )
    --Util:updateUserHead(ccui.Helper:seekWidgetByName(self.detailsP,"goodsimg"),self.msg.pic, 0, {nojpg = true, url=true})--物品图片
    if self.duobaoTime > 1 and (self.duobaoTime >= self.msg.bet_max*0.05 or (self.duobaoTime > self.msg.bet_max - self.msg.bet_times_now and self.msg.type==1)) then
        if self.duobaoTime > self.msg.bet_max - self.msg.bet_times_now and self.msg.type==1 then 
            self.duobaoTime = self.msg.bet_max - self.msg.bet_times_now
        elseif self.duobaoTime >= self.msg.bet_max*0.05 then
            self.duobaoTime = math.ceil(self.msg.bet_max*0.05)
        end
    end
    if self.duobaoTime*self.msg.bet_min > Cache.user.fucard_num then
        self.duobaoTime = math.floor(Cache.user.fucard_num/self.msg.bet_min)
    end
    if self.duobaoTime < 1 then self.duobaoTime = 1 end
    self.duobaoFocasNum:setString(self.duobaoTime * self.msg.bet_min)
    self.duobaoNum:setString(self.duobaoTime)

    self.duobaoFocasNum:setString(self.duobaoTime * self.msg.bet_min)--夺宝价格
    ccui.Helper:seekWidgetByName(self.detailsP,"duo_bao_txt"):setString("我有"..#self.msg.my_lucky_num.."个夺宝码")
    addButtonEvent(ccui.Helper:seekWidgetByName(self.detailsP,"duo_bao"),function( ... )
        local info = {
            index = #self.msg.my_lucky_num,
            list = self.msg.my_lucky_num
        }
        PopupManager:push({class = MineRecord, init_data = info})
        PopupManager:push()
    end)
    self.waitTxt:setVisible(false)
    --通过开奖类型来显示不同的界面    1.满人开奖,2.定时开奖
    if self.msg["type"] ==1 then
        self.bg1:setVisible(false)
        self.bg2:setVisible(true)
        self.winByTimerP:setVisible(true) 
        local percent = self.msg.bet_times_now*100/self.msg.bet_max
        ccui.Helper:seekWidgetByName(self.winByTimerP,"jin_du"):setPercent(percent>100 and 100 or percent) 
        --由于数据的即时改变，没有富文本只能根据模板设置改变数据后的文本位置
        local jindu_txt = ccui.Helper:seekWidgetByName(self.winByTimerP,"jin_du_txt")
        local jindu_txt1 = ccui.Helper:seekWidgetByName(self.winByTimerP,"jin_du_txt1")
        local jindu_txt2 = ccui.Helper:seekWidgetByName(self.winByTimerP,"jin_du_txt2")
        local jindu_txt3 = ccui.Helper:seekWidgetByName(self.winByTimerP,"jin_du_txt3")
        jindu_txt:setString("已抢"..self.msg.bet_times_now.."/"..self.msg.bet_max.."次")
        jindu_txt2:setString(self.msg.bet_times_now)
        jindu_txt3:setString("/"..self.msg.bet_max.."次")
        Util:setTxtPositionByItem(jindu_txt,{jindu_txt1,jindu_txt2,jindu_txt3})
        --判断正在进行中还是已结束  1.进行中,2结束
        if self.msg["status"] == 1 then
            self.setGoodsNumP:setVisible(true)
            self.duobaoBtn:setVisible(true)
            self.winnerP:setVisible(false)
            if self.msg.bet_times_now == self.msg.bet_max then
                self:showWaitStatus()
            end
        else
            self.setGoodsNumP:setVisible(false)
            self.duobaoBtn:setVisible(false)
            Util:updateUserHead(ccui.Helper:seekWidgetByName(self.winnerP,"xing_yun_tou_xiang"),self.msg.winner_pic, self.msg.winner_sex, {url=true})
            ccui.Helper:seekWidgetByName(self.winnerP,"xing_yun_name"):setString(self.msg.winner_nick)
            ccui.Helper:seekWidgetByName(self.winnerP,"xing_yun_num"):setString(self.msg.winner_bet_times)
            ccui.Helper:seekWidgetByName(self.winnerP,"Label_46"):setString("幸运号"..self.msg.winner_lucky_num)
            if self.msg.winner_bet_times ~= 0 then 
                self.winnerP:setVisible(true)
            end
        end
    else
        self.bg1:setVisible(false)
        self.bg2:setVisible(true)
        self.winByTimeP:setVisible(true) 
        --由于数据的即时改变，没有富文本只能根据模板设置改变数据后的文本位置
        local ding_shi_txt = ccui.Helper:seekWidgetByName(self.winByTimeP,"ding_shi_txtbg")
        local ding_shi_txt1 = ccui.Helper:seekWidgetByName(self.winByTimeP,"ding_shi_txt1")
        local ding_shi_num1 = ccui.Helper:seekWidgetByName(self.winByTimeP,"ding_shi_num1")
        local ding_shi_txt3 = ccui.Helper:seekWidgetByName(self.winByTimeP,"ding_shi_txt3")
        local ding_shi_num2 = ccui.Helper:seekWidgetByName(self.winByTimeP,"ding_shi_num2")
        local ding_shi_txt5 = ccui.Helper:seekWidgetByName(self.winByTimeP,"ding_shi_txt5")
        --ding_shi_txt:setVisible(true)
        ding_shi_txt:setString("已抢"..self.msg.bet_times_now.."次，至少"..self.msg.bet_max.."次开奖")
        ding_shi_num1:setString(self.msg.bet_times_now)
        ding_shi_num2:setString(self.msg.bet_max)
        Util:setTxtPositionByItem(ding_shi_txt,{ding_shi_txt1,ding_shi_num1,ding_shi_txt3,ding_shi_num2,ding_shi_txt5})
        --判断正在进行中还是已结束1.进行中,2.已结束 0等待开奖中
        if self.msg["status"] == 1 then
            self.setGoodsNumP:setVisible(true)
            self.duobaoBtn:setVisible(true)
            self.winnerP:setVisible(false)
            if self.detailsP.time == 0 and tonumber(self.msg.open_time) <= 0 then 
                self:showWaitStatus()
            else
                self:startRunTime(self.msg.open_time*100)
            end
        elseif self.msg.status == 0 then --正在进行
            self.setGoodsNumP:setVisible(true)
            self.duobaoBtn:setVisible(true)
            self.winnerP:setVisible(false)
            self:showWaitStatus()
        else
            self.setGoodsNumP:setVisible(false)
            self.duobaoBtn:setVisible(false)
            Util:updateUserHead(ccui.Helper:seekWidgetByName(self.winnerP,"xing_yun_tou_xiang"),self.msg.winner_pic, self.msg.winner_sex, {url=true})
            ccui.Helper:seekWidgetByName(self.winnerP,"xing_yun_name"):setString(self.msg.winner_nick)
            ccui.Helper:seekWidgetByName(self.winnerP,"xing_yun_num"):setString(self.msg.winner_bet_times)
            ccui.Helper:seekWidgetByName(self.winnerP,"Label_46"):setString("幸运号"..self.msg.winner_lucky_num)
            if self.msg.winner_bet_times ~= 0 then 
                self.winnerP:setVisible(true)
            end
        end
    end
end

--等待状态的显示 1.满人开奖,2.定时开奖
function FocasInfo:showWaitStatus()
    self.setGoodsNumP:setVisible(false)
    self.duobaoBtn:setVisible(false)
    self.bg1:setVisible(true)
    self.bg2:setVisible(false)
    self.waitTxt:setVisible(true)
end

function FocasInfo:startRunTime(time)--时间转换（数字转成分，秒，毫秒）例1000 = 00,10,00
    local detailsP = ccui.Helper:seekWidgetByName(self.gui,"detailsP")--夺宝详情

    local timeConvert = function( time )--时间转换（数字转成分，秒，毫秒）例1000 = 00,10,00
        local ms = time % 100 /10                        --秒钟
        local sec = ((time - ms) / 100) % 60          --分钟
        local min = ((time - ms) / 100 - sec) / 60   --小时
        local str_ms = string.format("%1d", ms)
        local str_sec = string.format("%02d", sec)
        local str_min = string.format("%02d", min)
        return str_min,str_sec,str_ms
    end
    local time = tonumber(time)-(math.ceil(socket.gettime()*100)-self.msg.open_time_with_ms)
    if not (detailsP.time and math.abs(detailsP.time - time)<2) then
        detailsP.time = time
    end
    if not detailsP.isrunAction then 
        detailsP.isrunAction = true
        detailsP:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function( ... )
                    if detailsP.time>0 and self.msg.status == 1 then
                        detailsP.time = tonumber(self.msg.open_time*100)-(math.ceil(socket.gettime()*100)-self.msg.open_time_with_ms)
                    else
                        detailsP.time = 0
                        if self.msg.status == 0 then
                            self:showWaitStatus()
                        end
                        detailsP.isrunAction = false
                        detailsP:stopAllActions()
                    end
                    local min,sec,ms = timeConvert(detailsP.time)
                    ccui.Helper:seekWidgetByName(detailsP,"time_txt_fen_num"):setString(min)
                    ccui.Helper:seekWidgetByName(detailsP,"time_txt_num"):setString(sec)
                    ccui.Helper:seekWidgetByName(detailsP,"time_txt_haomiao_num"):setString(ms)
                end),cc.DelayTime:create(0.01))))
    end
end

function FocasInfo:initClick( ... )
    addButtonEvent(self.closeBtn, function( ... )
        self:close()
    end) 
    
    addButtonEvent(self.duobaoBtn,function( ... )
        if self.duobaoBtn.touch then 
            return
        end 
        if self.msg.bet_min>Cache.user.fucard_num then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.noFocasTips,time = 2})
            PopupManager:push({class = GetFocas, init_data = {hideGotoFocasHall = true}})
            PopupManager:pop()
            return
        end
        local info ={
            uin=Cache.user.uin,
            item_unique_id= self.msg.item_unique_id,
            bet_fucard_num=self.duobaoTime*self.msg.bet_min,
            item_id = self.msg.item_id
        }
        self.duobaoBtn.touch =true 
        self.duobaoBtn:setOpacity(100)
        self.duobaoBtn:setTouchEnabled(false)
        self.duobaoBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
            self.duobaoBtn.touch = nil
            self.duobaoBtn:setTouchEnabled(true)
            self.duobaoBtn:setOpacity(255)
        end)))
        dump(info)
        GameNet:send({cmd=CMD.IN_INDIANA, body=info,
                callback=function(rsp)
                    if rsp.ret == 0 then
                        local LuckyNumList = {}--幸运数字
                        for i=1 ,rsp.model.lucky_num:len() do
                            local data = rsp.model.lucky_num:get(i)
                            table.insert(LuckyNumList,data.lucky_num)
                        end
                        if self.duobaoTime >= self.msg.bet_max*0.05 or (self.duobaoTime > self.msg.bet_max - self.msg.bet_times_now and self.msg.type ==1 ) then
                            if (self.duobaoTime > self.msg.bet_max - self.msg.bet_times_now and self.msg.type==1) then 
                                self.duobaoTime = self.msg.bet_max - self.msg.bet_times_now
                            elseif self.duobaoTime >= self.msg.bet_max*0.05 then
                                self.duobaoTime = math.ceil(self.msg.bet_max*0.05)
                            end
                            self.duobaoFocasNum:setString(self.duobaoTime * self.msg.bet_min)
                            self.duobaoNum:setString(self.duobaoTime)
                        end

                        --self.duobaoTime = 1
                        --self.duobaoFocasNum:setString(self.msg.bet_min)
                        qf.event:dispatchEvent(ET.GET_WELFARD_INDIANA_LIST)
                        --等待开奖后台需一秒才有玩家信息，所以隔2秒刷新次
                        self.gui:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function( ... )
                            qf.event:dispatchEvent(ET.GET_WELFARD_INDIANA_LIST)
                        end)))
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.duobaoScess,time = 2})
                    else
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
                    end
                end
            })
    end)
end

--初始化往期得主列表
function FocasInfo:initOldWinnerList()
    self.oldwinnerList:removeAllChildren()
    self.oldwinnerList:setItemModel(self.oldwinnerItem)

    local index = 0
    for k,v in pairs(Cache.focasInfo.receive_record) do
            self.oldwinnerList:pushBackDefaultItem()
            local goods = self.oldwinnerList:getItem(index)
            Util:updateUserHead(ccui.Helper:seekWidgetByName(goods,"item_tou_xiang"),v.pic, v.sex, {url=true})
            ccui.Helper:seekWidgetByName(goods,"item_qi_shu"):setString("第"..v.periods_now.."期")
            ccui.Helper:seekWidgetByName(goods,"item_name"):setString(v.winner_nick)
            ccui.Helper:seekWidgetByName(goods,"item_ci"):setString("参加了"..v.winner_bet_times.."次")
            ccui.Helper:seekWidgetByName(goods,"item_time"):setString(v.open_time)
            ccui.Helper:seekWidgetByName(goods,"item_xing_yun_num"):setString("幸运号"..v.winner_lucky_num)
        index = index + 1
    end
end

--初始化选择界面按钮
function FocasInfo:initCheckClick( ... )
    --增加夺宝次数
    local duobaoBtn = ccui.Helper:seekWidgetByName(self.checkP,"checkbtn1")
    duobaoBtn:setTouchEnabled(false)
    local duihuanBtn = ccui.Helper:seekWidgetByName(self.checkP,"checkbtn2")
    duihuanBtn:setTouchEnabled(true)
    local duobaoTxt = ccui.Helper:seekWidgetByName(self.checkP,"checktxt1")
    local duihuanTxt = ccui.Helper:seekWidgetByName(self.checkP,"checktxt2")

    --增加和减少夺宝次数
    local duobaoAddBtn = ccui.Helper:seekWidgetByName(self.detailsP,"jion_jia")
    local duobaoDecBtn = ccui.Helper:seekWidgetByName(self.detailsP,"jion_jian")
   
    
    duobaoBtn:setOpacity(255)
    duihuanBtn:setOpacity(0)
    duobaoTxt:setFntFile(GameRes.AppreciateTipsFnt1)
    duihuanTxt:setFntFile(GameRes.AppreciateTipsFnt2)
    --夺宝按钮
    addButtonEvent(duobaoBtn, function( ... )
        self.detailsP:setVisible(true)
        self.oldwinnerList:setVisible(false)
        duobaoBtn:setTouchEnabled(false)
        duihuanBtn:setTouchEnabled(true)
        duobaoBtn:setOpacity(255)
        duihuanBtn:setOpacity(0)
        duobaoTxt:setFntFile(GameRes.AppreciateTipsFnt1)
        duihuanTxt:setFntFile(GameRes.AppreciateTipsFnt2)
        self.bg3:setVisible(false)
        
    end) 
    --兑换按钮
    addButtonEvent(duihuanBtn, function( ... )
        self.detailsP:setVisible(false)
        self.oldwinnerList:setVisible(true)
        duobaoBtn:setTouchEnabled(true)
        duihuanBtn:setTouchEnabled(false)
        duobaoBtn:setOpacity(0)
        duihuanBtn:setOpacity(255)
        duihuanTxt:setFntFile(GameRes.AppreciateTipsFnt1)
        duobaoTxt:setFntFile(GameRes.AppreciateTipsFnt2)
        self.bg3:setVisible(true)
        qf.event:dispatchEvent(ET.HIS_INDIANA_RECORD,{item_id = self.index})
    end) 
       addButtonEvent(duobaoAddBtn, function( ... )
        if self.duobaoTime >= self.msg.bet_max*0.05 or (self.duobaoTime > self.msg.bet_max - self.msg.bet_times_now and self.msg.type==1) then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.tooMoreFocasTips,time = 2})
            return 
        end
        if self.duobaoTime*self.msg.bet_min > Cache.user.fucard_num then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.noFocasTips,time = 2})
            return 
        end
        self.duobaoTime = self.duobaoTime + 1
        self.duobaoFocasNum:setString(self.duobaoTime * self.msg.bet_min)
        self.duobaoNum:setString(self.duobaoTime)
    end)
    --减少夺宝次数
     addButtonEvent(duobaoDecBtn, function( ... )
        if self.duobaoTime>1 then 
            self.duobaoTime = self.duobaoTime -1
            self.duobaoFocasNum:setString(self.duobaoTime * self.msg.bet_min)
            self.duobaoNum:setString(self.duobaoTime)
        end
    end)
end

function FocasInfo:close() 
    if self.cb then
        self.cb()
    end

    FocasInfo.super.close(self)
end
return FocasInfo
