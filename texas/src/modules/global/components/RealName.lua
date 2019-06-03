local TimeOutButton = require("src.modules.global.TimeOutButton")
local VerifyIDCard = require("src.common.VerifyIDCard")
local RealName = class("RealName", CommonWidget.BasicWindow)
RealName.TAG = "RealName"


function RealName:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    if paras.cb then
       self.cb = paras.cb
    end
    RealName.super.ctor(self, paras)
end

function RealName:init(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.realNameJson)
    self.closeP= ccui.Helper:seekWidgetByName(self.gui,"closeP")
    self.closeBtn = ccui.Helper:seekWidgetByName(self.gui,"closeBtn")--关闭按钮
    self.getSecurityBtn = ccui.Helper:seekWidgetByName(self.gui,"getSecurityBtn")--获取验证码按钮
    self.attestationBtn = ccui.Helper:seekWidgetByName(self.gui,"attestationBtn")--认证按钮
    self.panelName = ccui.Helper:seekWidgetByName(self.gui,"panel_name")
    self.panelCard = ccui.Helper:seekWidgetByName(self.gui,"panel_card")
    -- self.textField_name= ccui.Helper:seekWidgetByName(self.gui,"textField_name")--名字键盘
    -- self.textField_card = ccui.Helper:seekWidgetByName(self.gui,"textField_card")--身份证号键盘
    self.textField_mobile = ccui.Helper:seekWidgetByName(self.gui,"textField_mobile")--手机号码键盘
    self.textField_security = ccui.Helper:seekWidgetByName(self.gui,"textField_security")--验证码键盘
    self.alertView = ccui.Helper:seekWidgetByName(self.gui,"alertView")--提示框
    self.alertLab = ccui.Helper:seekWidgetByName(self.gui,"alertLab")--提示label
    self.alectLabel_2 = ccui.Helper:seekWidgetByName(self.gui,"alectLabel_2")--奖券label
    self.alectLabel_1 = ccui.Helper:seekWidgetByName(self.gui,"alectLabel_1")--奖券label

    self.textField_name = self:createTextField({
        parent = self.panelName,
        size = cc.size(611, 68),
        name = 'ttf_name',
        fontSize = 53,
        maxLength = 20,
        placeHolder = GameTxt.realname_name,
        placeHolderFontColor = cc.c3b(100, 100, 100),
    })

    self.textField_card = self:createTextField({
        parent = self.panelCard,
        size = cc.size(611, 68),
        name = 'ttf_card',
        fontSize = 53,
        maxLength = 20,
        placeHolder = GameTxt.realname_card,
        placeHolderFontColor = cc.c3b(100, 100, 100),
    })

    self.textField_name:setPosition(13, 16)
    self.textField_name:setAnchorPoint(0, 0)

    self.textField_card:setPosition(13, 16)
    self.textField_card:setAnchorPoint(0, 0)

    for i,v in ipairs(Cache.ActivityTaskInfo.rewardList.sys_task_list) do
        print(i,v.id)
        if v.id == "60" then
        	self.alectLabel_2:setString(v.desc)
        end 
    end
    --设置键盘占位符颜色
    -- self.TextField_name:setPlaceholderFontColor(ccc3(116,115,111))
    print(self.textField_name)
    print(self.textField_name)
    -- self.TextField_name:setPlaceHolder("点击编辑签名，最多40个汉字");                  --输入占位文本内容
    -- self.TextField_name:setPlaceHolderColor(cc.c3b(236,253,255));                      --设置占位文本的颜色（默认是灰黑色）
    self.getSecurityBtn:setTitleColor(cc.c3b(255,255,255))
    self.timeBtn = TimeOutButton.new(self.getSecurityBtn)
    self.timeBtn.callBack = function (Event)
       -- body
       if(Event == ET.EVENT_TIME_DOWN)then
            
        elseif(Event == ET.EVENT_TIME_BEGIN)then
            print("倒计时开始")
            self.getSecurityBtn:setTitleColor(cc.c3b(100,100,100))
        else
            print("倒计时结束")
       end
    end
    addButtonEvent(self.attestationBtn,function ()
   	-- body
   		self:attestationMessageAction()
    end)
end
function RealName:initClick( ... )
	-- body
    addButtonEvent(self.closeBtn,function (sender)
        self:close()
    end)
end
function RealName:close()
    self.timeBtn:remove()
    if self.cb then
        self.cb()
    end
    RealName.super.close(self)
    qf.event:dispatchEvent(ET.SHOW_FREEGOLDSHORTCUT)
end
--点击认证
function RealName:attestationMessageAction()
	local name = self.textField_name:getText()
	local card = self.textField_card:getText()
	local mobile = self.textField_mobile:getStringValue()
	local security = self.textField_security:getStringValue()
	if #name == 0 then 
		self:alertViewShowMessage("请填写姓名")
		return
	end
	if #card == 0 then 
		self:alertViewShowMessage("请填写身份证号")
		return
	end
	
	local nameHaveEnglish = self:checkStringHaveEnglish(name)
	print(nameHaveEnglish)
	if nameHaveEnglish then
		self:alertViewShowMessage("姓名格式不正确")
		return
	end

	local verifyID = VerifyIDCard.new()
    local code = verifyID:verifyIDCard(card)
    if not (code == 0) then
		self:alertViewShowMessage("身份证格式不正确")
		return
	end

 	GameNet:send({cmd = CMD.CHECK_USERID_REQ,body = {real_name = name,id_card = card},callback = function ( rsp )
		-- body
		if rsp.ret ~= 0 then 
			loga("实名认证失败" .. rsp.ret)
			qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
		else
			loga("实名认证成功" .. rsp.ret)
			-- qf.event:dispatchEvent(ET.NET_USER_TASKLIST_REQ)
			qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.ckeck_userid_success})
			self:close()
		end
	end})	
end

function RealName:createTextField(args)
    local editTxt = cc.EditBox:create(args.size, cc.Scale9Sprite:create())          --输入框尺寸，背景图片
    editTxt:setName(args.name or 'ttf_name')                                        --设置输入框name
    editTxt:setFontSize(args.fontSize or 24)                                        --设置输入设置字体的大小
    editTxt:setFontColor(args.fontColor or cc.c3b(0, 0, 0))                         --设置字体颜色
    editTxt:setMaxLength(args.maxLength or 100)                                     --设置输入最大长度
    editTxt:setPlaceHolder(args.placeHolder or "")                                  --设置预制提示文本
    editTxt:setPlaceholderFontColor(args.placeHolderFontColor or cc.c3b(0, 0, 0))   --设置预制文本字体颜色
    editTxt:setInputMode(args.mode or cc.EDITBOX_INPUT_MODE_ANY)                    --设置输入模型
    editTxt:setReturnType(args.return_mode or cc.KEYBOARD_RETURNTYPE_DONE)          --键盘return类型
    args.parent:addChild(editTxt, 99)

    return editTxt
end

--提示语
function RealName:alertViewShowMessage(message)
	-- body
	print(message)
	self.alertLab:setString(message)
	local actionFadeIn =cc.FadeIn:create(0)
	local actionFadeOut = cc.FadeOut:create(1.5)
	self.alertView:setVisible(true)
	local function alertViewHiden()
		-- body
		self.alertView:setVisible(false)
	end
  	local action = cc.Sequence:create(actionFadeIn,actionFadeOut,actionFadeIn,cc.CallFunc:create(alertViewHiden))
	self.alertView:runAction(action)
end


--判断名字输入是否包含英文大小写
function RealName:checkStringHaveEnglish(str)
	-- body
	local lenInByte = #str
	local have = false
	for i=1,lenInByte do
		local curByte = string.byte(str,i)
		if curByte<=127 then
			have = true
		end
	end
	return have
end
--判断手机号
function RealName:CheckIsMobile(str)
	return string.match(str,"[1][3,4,5,7,8]%d%d%d%d%d%d%d%d%d") == str;
end
return RealName