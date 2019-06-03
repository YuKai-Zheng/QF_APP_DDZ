local GetGoods = class("GetGoods",CommonWidget.BasicWindow)

GetGoods.TAG = "GetGoods"
function GetGoods:ctor(paras)
    self.cb = paras.cb
    self.item_type = paras.item_type
    self.item_id = paras.item_id
    self.item_unique_id = paras.item_unique_id
    self.item_num = paras.value
    GetGoods.super.ctor(self, paras)

    if FULLSCREENADAPTIVE then
        self.winSize = cc.Director:getInstance():getWinSize()
        self.gui:setContentSize(self.winSize.width, self.winSize.height)
        self.panel1:setPositionX(self.panel1:getPositionX()+(self.winSize.width - 1980)/2)
        self.panel2:setPositionX(self.panel2:getPositionX()+(self.winSize.width - 1980)/2)
    end
end

function GetGoods:init(paras)
    --初始化
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.GetGoodsJson)
    self.panel1 = ccui.Helper:seekWidgetByName(self.gui,"Panel_1")
    self.panel2 = ccui.Helper:seekWidgetByName(self.gui,"Panel_2")
    self.btnCancel2 = ccui.Helper:seekWidgetByName(self.panel2,"Button_cancel")
    self.btnCommit2 = ccui.Helper:seekWidgetByName(self.panel2,"Button_ti_jiao")
    self.btnOk2 = ccui.Helper:seekWidgetByName(self.panel2,"Button_ok")
    self.btnClose2 = ccui.Helper:seekWidgetByName(self.panel2,"closebtn")
    self.btnCommit1 = ccui.Helper:seekWidgetByName(self.panel1,"Button_ti_jiao")
    self.btnOk1 = ccui.Helper:seekWidgetByName(self.panel1,"Button_ok")
    self.btnClose1 = ccui.Helper:seekWidgetByName(self.panel1,"closebtn")
    self.txtName1 = ccui.Helper:seekWidgetByName(self.panel1,"txt_name")
    self.txtPhoneNum1 = ccui.Helper:seekWidgetByName(self.panel1,"txt_phone_num")
    self.txtPhoneNum1_1 = ccui.Helper:seekWidgetByName(self.panel1,"txt_phone_num1")
    self.itemInduce1 = ccui.Helper:seekWidgetByName(self.panel1,"txt_introduce")

    self.txtName2 = ccui.Helper:seekWidgetByName(self.panel2,"txt_name")
    self.txtPhoneNum2 = ccui.Helper:seekWidgetByName(self.panel2,"txt_phone")
    self.txtYouBian2 = ccui.Helper:seekWidgetByName(self.panel2,"txt_you_bian")
    self.txtDiZhi2 = ccui.Helper:seekWidgetByName(self.panel2,"txt_di_zhi")
    self.itemInduce2 = ccui.Helper:seekWidgetByName(self.panel2,"txt_introduce")


    self:addEventListenerTextField(self.txtName1)
    self:addEventListenerTextField(self.txtPhoneNum1)
    self:addEventListenerTextField(self.txtPhoneNum1_1)

    self:addEventListenerTextField(self.txtName2)
    self:addEventListenerTextField(self.txtPhoneNum2)
    self:addEventListenerTextField(self.txtYouBian2)
    self:addEventListenerTextField(self.txtDiZhi2)

    --根据传来的值来判断显示的界面(虚拟物品/实体物品)改为了必填所有信息

    if self.item_type == 2 then
        self.panel1:setVisible(true)
        self.panel2:setVisible(false)
        self.btnCommit1:setVisible(true)
        self.btnOk1:setVisible(false) 
        ccui.Helper:seekWidgetByName(self.panel1,"Image_phone_bg"):setVisible(true)
        self.txtPhoneNum1:setText(Cache.user.phone)
        self.txtPhoneNum1_1:setText(Cache.user.phone)
        self.itemInduce1:setString(string.format(GameTxt.focas_exchange_tips,paras.value,paras.name))
    elseif self.item_type == 1 then
        self.panel1:setVisible(false)
        self.panel2:setVisible(true)
        self.btnCommit2:setVisible(true)
        self.btnOk2:setVisible(false)
        self.btnCancel2:setVisible(false)
        ccui.Helper:seekWidgetByName(self.panel2,"Image_bg1"):setVisible(true)
        ccui.Helper:seekWidgetByName(self.panel2,"Image_bg2"):setVisible(true)
        ccui.Helper:seekWidgetByName(self.panel2,"Image_bg3"):setVisible(true)
        ccui.Helper:seekWidgetByName(self.panel2,"Image_bg4"):setVisible(true)
        self.txtName2:setText(Cache.user.real_name)
        self.txtPhoneNum2:setText(Cache.user.phone)
        self.txtYouBian2:setText(Cache.user.post_code)
        self.txtDiZhi2:setText(Cache.user.address)
        self.itemInduce2:setString(string.format(GameTxt.focas_exchange_tips,paras.value,paras.name))
    end
    --btn事件监听
    addButtonEvent(self.btnClose1, function( ... )
        self:close()
    end)
    addButtonEvent(self.btnClose2, function( ... )
        self:close()
    end)

    addButtonEvent(self.btnCommit1, function( ... )
        -- 兑换话费
        --提交时进行判断是否可以提交
        if self.txtPhoneNum1:getStringValue() == ""then
             qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.focas_phone_nil,time = 2})
        elseif string.len(self.txtPhoneNum1:getStringValue()) ~= 11 then
             qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.focas_phone_len,time = 2})
        elseif self.txtPhoneNum1_1:getStringValue() ~= self.txtPhoneNum1:getStringValue() then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.exchangeMall_diff_phonenumber,time = 2})
        else
            local info = {
                num = 1,
                goods_id = self.item_id,
                phone = self.txtPhoneNum1:getStringValue()
            }
            qf.event:dispatchEvent(ET.EVETNT_USER_RECORD_INFO,info)
            local item_type = paras.item_type
            local itemName = paras.name
            local itemPic = paras.item_pic
            GameNet:send({cmd = CMD.EXCHANGE_WELFARE,body=info,callback=function(rsp)
                if rsp.ret == 0 then
                    local info = {}
                    local showString = "恭喜您成功兑换" .. itemName.."，24小时内到账哦~"
                    info = {getRewardType = 2, rewardInfo = {"","","","",showString}, rewardInfoUrl = {"","","","",itemPic}}
                    qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, info)
                    self:close()
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
                end
            end})
            if self.cb then
                self.cb()
            end
        end
    end)

    addButtonEvent(self.btnCommit2, function( ... )
        -- body
        --提交时进行判断是否可以提交
        if self.txtName2:getStringValue() == "" then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.focas_name_nil,time = 2})
        elseif self.txtPhoneNum2:getStringValue() == "" then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.focas_phone_nil,time = 2})
        elseif self.txtDiZhi2:getStringValue() == "" then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.focas_di_zhi,time = 2})
        else
            self.btnCommit2:setVisible(false)
            self.btnOk2:setVisible(true)
            self.btnCancel2:setVisible(true)
            ccui.Helper:seekWidgetByName(self.panel2,"Image_bg1"):setVisible(false)
            ccui.Helper:seekWidgetByName(self.panel2,"Image_bg2"):setVisible(false)
            ccui.Helper:seekWidgetByName(self.panel2,"Image_bg3"):setVisible(false)
            ccui.Helper:seekWidgetByName(self.panel2,"Image_bg4"):setVisible(false)
            self.txtName2:setTouchEnabled(false)
            self.txtPhoneNum2:setTouchEnabled(false)
            self.txtYouBian2:setTouchEnabled(false)
            self.txtDiZhi2:setTouchEnabled(false)
        end
    end)
    addButtonEvent(self.btnCancel2, function( ... )
        -- body
        self.btnCommit2:setVisible(true)
        self.btnOk2:setVisible(false)
        self.btnCancel2:setVisible(false)
        ccui.Helper:seekWidgetByName(self.panel2,"Image_bg1"):setVisible(true)
        ccui.Helper:seekWidgetByName(self.panel2,"Image_bg2"):setVisible(true)
        ccui.Helper:seekWidgetByName(self.panel2,"Image_bg3"):setVisible(true)
        ccui.Helper:seekWidgetByName(self.panel2,"Image_bg4"):setVisible(true)
        self.txtName2:setTouchEnabled(true)
        self.txtPhoneNum2:setTouchEnabled(true)
        self.txtYouBian2:setTouchEnabled(true)
        self.txtDiZhi2:setTouchEnabled(true)
    end)
    addButtonEvent(self.btnOk2, function( ... )
        -- 获取实物
        if self.item_id then 
            local item_type = paras.item_type
            local itemName = paras.name
            local itemPic = paras.item_pic
            GameNet:send({cmd = CMD.EXCHANGE_USER_INFO, body={
                phone=self.txtPhoneNum2:getStringValue(),
                recipients=self.txtName2:getStringValue(),
                address=self.txtDiZhi2:getStringValue()
            },callback=function(rsp)
                if rsp.ret==0 then
                    Cache.ExchangeMallInfo:setUserInfo(rsp.model)

                    local info = Cache.ExchangeMallInfo:getUserInfo()
                    Cache.user.real_name = info.recipients
                    Cache.user.post_code = info.post_code
                    Cache.user.address = info.address
                    Cache.user.phone = info.phone
                    local body = {
                        num = 1,
                        goods_id = self.item_id,
                        -- phone = Cache.user.phone,
                        address = Cache.user.address
                        -- post_code = Cache.user.post_code
                    }
                    GameNet:send({cmd = CMD.EXCHANGE_WELFARE,body=body,callback=function(rsp)
                        if rsp.ret == 0 then
                            local info = {}
                            local showString = "恭喜您成功兑换"..itemName..",我们将于7个工作日内发货"
                            info = {getRewardType = 2, rewardInfo = {"","","","","",showString}, rewardInfoUrl = {"","","","","",itemPic}}

                            qf.event:dispatchEvent(ET.WELFARE_INDIANNA_RECORD)
                            qf.event:dispatchEvent(ET.GLOBAL_DIAMOND_ANIMATION_SHOW, info)
                            self:close()
                        else
                            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
                        end
                    end})
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret],time = 2})
                end
            end})
        end
        if self.cb then
            self.cb()
        end
    end)
end
--监听输入框的一个状态
function GetGoods:addEventListenerTextField(textField , phoneNum)
    textField:addEventListenerTextField(function(targe,eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
            if textField:getStringValue() == "" then
                textField:setColor(cc.c3b(160,138,119))
            end
        elseif eventType == ccui.TextFiledEventType.insert_text then
            if textField:getStringValue() ~= nil then
                textField:setColor(cc.c3b(143,80,39))
            end
        end
    end)
end

return GetGoods
