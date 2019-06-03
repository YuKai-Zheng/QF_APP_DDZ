local BoradcastView = class("BoradcastView", qf.view)

BoradcastView.TAG = "BoradcastView"
function BoradcastView:ctor(parameters)
    BoradcastView.super.ctor(self,parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
end

function BoradcastView:init()
    self:boradcastInit()
end

--设置广播位置
function BoradcastView:setBroadCast(paras)
    self:boradcastInit()
    if self._boradcastBg then
        self._boradcastBg:setPosition(cc.p(self._boradcastBg_px+paras.x,self._boradcastBg_py+paras.y))
    end
end

function BoradcastView:showWordMsg()
    if self.wordMsgNode ~= nil then
       self.wordMsgNode:removeFromParent(true)
       self.wordMsgNode = nil
    end
    local bg = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.WordMsgJson)
    bg:setPositionY(self.winSize.hight)
    self:addChild(bg)
    
    bg:runAction(cc.Sequence:create(
        cc.EaseSineOut:create(cc.MoveBy:create(1,cc.p(0,-self.winSize.hight))),
        cc.CallFunc:create(function ( sender )
            --self:showBoradcastTxt(txt)
        end)
    ))
    self.wordMsgNode = bg
end
function BoradcastView:boradcastInit()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then  return end
    if self._boradcastBg == nil then
        self._boradcastBg  = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.broadcastJson)
        self._boradcastBg:setVisible(false)
        self._boradcastBg_px = self._boradcastBg:getPositionX()
        self._boradcastBg_py = self._boradcastBg:getPositionY()
        self:addChild(self._boradcastBg)
        self.move_root = ccui.Helper:seekWidgetByName(self._boradcastBg,"move_root")
        self.msgBgPosY = ccui.Helper:seekWidgetByName(self._boradcastBg,"img_bg"):getPositionY()
        self.isRuning = false
        qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_TXT)
        
        self.boradcastTable={}
    end
end

function BoradcastView:showBoradcast()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW   or not TB_MODULE_BIT.BOL_MODULE_BIT_BROADCAST_SYS_MSG  then 
        return 
    end
    self:boradcastInit()
    self._boradcastBg:setVisible(true)
end

function BoradcastView:hideBoradcast()
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then  return end
    self:boradcastInit()
    --self.isRuning=false
    self._boradcastBg:setVisible(false)
end

function BoradcastView:removeBoradcastChild( ... )
    -- body
    if self.move_root then
        self.move_root:removeAllChildren()
    end
    self.boradcastTable={}
end

--新版本系统广播
function BoradcastView:showBoradcastTxtWithSystem(info)
    -- body
    self:removeBoradcastChild()
    local txt_root = ccui.Helper:seekWidgetByName(self._boradcastBg,"txt_root")
    local cs = txt_root:getContentSize()
    local head=ccui.ImageView:create(GameRes.BroadcastSystemImg)
    head:setAnchorPoint(0,0.5)
    head:setPosition(0,cs.height*0.45)
    table.insert(self.boradcastTable,head)
    head:setScale(1.1)
    self.move_root:addChild(head)
    local nowX=head:getContentSize().width+10
    for i=1,2 do
        local laba
        if info.level~=0 then
            laba=ccui.ImageView:create(GameRes.BroadcastLabaImg)
        else
            laba=ccui.ImageView:create(GameRes.BroadcastHuaImg)
        end
        laba:setAnchorPoint(0,0.5)
        laba:setPosition(nowX,cs.height*0.5)
        table.insert(self.boradcastTable,laba)
        self.move_root:addChild(laba)
        nowX=nowX+laba:getContentSize().width+10
    end
    local content=info.new_content
    local strcontent=1
    if content==nil or content=="" or info.contents==nil then 
        local txt=ccui.Text:create(info.content,GameRes.font1,42)
        txt:setAnchorPoint(0,0.5)
        txt:setPosition(nowX,cs.height*0.5)
        table.insert(self.boradcastTable,txt)
        self.move_root:addChild(txt)
        nowX=nowX+txt:getContentSize().width
    else
        while(string.len(content)>=1 )do
            if string.find(content,"%#")==1 then
                local txt=ccui.Text:create(info.contents["str"..strcontent],GameRes.font1,42)
                txt:setAnchorPoint(0,0.5)
                txt:setColor(cc.c3b(217,172,58))
                txt:setPosition(nowX,cs.height*0.5)
                table.insert(self.boradcastTable,txt)
                self.move_root:addChild(txt)
                nowX=nowX+txt:getContentSize().width
                strcontent=strcontent+1
                if #content>1 then
                    content=string.sub(content,2,#content)
                else
                    break
                end
            else
                local txtcontent
                if string.find(content,"%#")  then 
                    txtcontent=string.sub(content,1,string.find(content,"%#")-1)
                    content=string.sub(content,string.find(content,"%#"),#content)
                else
                    txtcontent=content
                    content=""
                end
                local txt=ccui.Text:create(txtcontent,GameRes.font1,42)
                txt:setAnchorPoint(0,0.5)
                txt:setPosition(nowX,cs.height*0.5)
                table.insert(self.boradcastTable,txt)
                self.move_root:addChild(txt)
                nowX=nowX+txt:getContentSize().width
            end
            
        end
    end
    local distence = cs.width + nowX
    local time = distence/200
    self.move_root:stopAllActions()
    self.move_root:setPositionX(cs.width)
    self.isRuning = true
    self.move_root:runAction(
        cc.Sequence:create(
            cc.Show:create(),
            cc.MoveBy:create(time,cc.p(-distence,0)),
            cc.Hide:create(),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function ( sender )
                self._boradcastBg:setVisible(false)
            end),
            cc.DelayTime:create(10),
            cc.CallFunc:create(function ( sender )
                self.isRuning = false
                qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_TXT)
            end)
        )
    )

end

--新版本个人广播
function BoradcastView:showBoradcastTxtWithPersonal(info)

    self:removeBoradcastChild()
    local txt_root = ccui.Helper:seekWidgetByName(self._boradcastBg,"txt_root")
    local cs = txt_root:getContentSize()
    local laba=ccui.ImageView:create(GameRes.BroadcastGuangBoImg)
    laba:setAnchorPoint(0,0.5)
    laba:setPosition(0,cs.height*0.5)
    table.insert(self.boradcastTable,laba)
    self.move_root:addChild(laba)
    local head=ccui.Text:create("【"..info.nick.."】：",GameRes.font1,42)
    head:setAnchorPoint(0,0.5)
    head:setPosition(laba:getContentSize().width+20,cs.height*0.5)
    table.insert(self.boradcastTable,head)
    self.move_root:addChild(head)
    local nowX=head:getContentSize().width+10+laba:getContentSize().width+20

    local txt=ccui.Text:create(info.content,GameRes.font1,42)
    txt:setAnchorPoint(0,0.5)
    txt:setPosition(nowX,cs.height*0.5)
    table.insert(self.boradcastTable,txt)
    self.move_root:addChild(txt)
    nowX=nowX+txt:getContentSize().width
    local distence = cs.width + nowX
    local time = distence/200
    self.move_root:stopAllActions()
    self.move_root:setPositionX(cs.width)
    self.isRuning = true
    self.move_root:runAction(
        cc.Sequence:create(
            cc.Show:create(),
            cc.MoveBy:create(time,cc.p(-distence,0)),
            cc.Hide:create(),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function ( sender )
                self._boradcastBg:setVisible(false)
            end),
            cc.DelayTime:create(10),
            cc.CallFunc:create(function ( sender )
                self.isRuning = false
                qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_TXT)
            end)
        )
    )
end

function BoradcastView:showBoradcastTxt(info)
    if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW  then  return end
    local txt_root = ccui.Helper:seekWidgetByName(self._boradcastBg,"txt_root")
    if not txt_root or tolua.isnull(txt_root) then
        return 
    end
    local vValue = self:isLabaShow()
    if vValue or ModuleManager:judegeIsInLogin() then
        self:hideBoradcast()
    else
        self:showBoradcast()
    end
    local cs = txt_root:getContentSize()
    if info.level == 400 then
        --self.nick_text:setColor(cc.c3b(231,223,233))
        --self.msg_text:setColor(cc.c3b(231,223,233))
        if not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW then
            self:hideBoradcast()
            return
        end
        self:showBoradcastTxtWithPersonal(info)
        return 
    else
        --self.nick_text:setColor(cc.c3b(195,40,41))
        --self.msg_text:setColor(cc.c3b(231,223,233))
        self:showBoradcastTxtWithSystem(info)
        return
    end

end

function BoradcastView:showBoradcastTxt_inGame(info)
    self:showBoradcastTxt(info)
    local txt_root = ccui.Helper:seekWidgetByName(self._boradcastBg,"txt_root")
    if not txt_root or tolua.isnull(txt_root) then
        return 
    else
        return
    end
end

function BoradcastView:setXiaoLabaNum(model)
    if self._xiaoLaba then 
        self._xiaoLaba:setLabaNum(model)
    end
end

function BoradcastView:xiaolabaRefresh()
    if self._xiaoLaba then
        self._xiaoLaba:refreshListItem()
    end
end
function BoradcastView:isLabaShow()
    local bValue = false
    if self._xiaoLaba then

        bValue = self._xiaoLaba.isShow
    end
    return bValue
end


function BoradcastView:getRoot() 
    return LayerManager.BoradcastLayer
end

return BoradcastView