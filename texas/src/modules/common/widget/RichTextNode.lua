
local RichTextNode = class("RichTextNode",function (paras)
    return paras.node
end)

RichTextNode.TAG = "RichTextNode"

function RichTextNode:ctor(paras)
    if not paras.node or paras.color then
        logd("RichTextNode init fail, invalid paras!")
        return
    end
    self:init()
    self:initData(paras)
end

function RichTextNode:init()
    self.txtValue = ""
    self.targetTxtValue = ""
    self.normalFontSize = 32
    self.targetFontSize = 32
    self.normalColor = cc.c3b(0,0,0)
    self.targetTxtColor = cc.c3b(0,0,0)
    self.txtLableItems = {}
    self.frameUpdateAction = nil
    self.cb = nil
end

-- text 传入的字符
-- targetTxtValue 需要特殊处理的字符的配对表示如：<WebSite>指定投注站<WebSite>
-- targetTxtColor 需要特殊处理的颜色
-- normalColor 正常颜色
-- targetTxtColor 需要特殊处理的字符颜色
-- targetFontSize 需要特殊处理的字符字体大小
-- normalFontSize 正常字符字体大小
-- frameUpdataAction 内容大小变化事件
-- cb 点击事件

-- CommonWidget.RichTextNode.new({
--         node = detailLayer,
--         text = "1.这是一段很长生成的大家啊道具按实际达拉斯建档立卡圣大声道多撒多暗伤打算打算打算的撒暗伤大声道暗伤诞节阿斯兰的爱神的箭拉上\n2.测试等的肯德基快乐大指定投注站健康指定投注站街上扣篮大赛\n3.至大大大大山洞爱仕达都好大红爱仕达大山洞暗红色的",
--         targetTxtValue = "指定投注站",
--         targetTxtColor = cc.c3b(120, 255, 86),
--         targetFontSize = 40,
--         cb = function ()
--             
--         end,
--         frameUpdateAction = function (height)
--             
--         end
--     })

function RichTextNode:initData(paras)
    if paras.text and type(paras.text) == 'string' then
        self.txtValue = paras.text
    end

    if paras.targetTxtValue and type(paras.targetTxtValue) == 'string' then
        self.targetTxtValue = paras.targetTxtValue
    end

    if paras.targetTxtColor then
        self.targetTxtColor = paras.targetTxtColor
    end
    if paras.cb then
        self.cb = paras.cb
    end

    if paras.normalColor then
        self.normalColor = paras.normalColor
    end

    if paras.normalFontSize then
        self.normalFontSize = paras.normalFontSize
    end

    if paras.targetFontSize then
        self.targetFontSize = paras.targetFontSize
    end

    if paras.frameUpdateAction then
        self.frameUpdateAction = paras.frameUpdateAction
    end

    self:layoutTxt()
end

function RichTextNode:layoutTxt()
    local txtTable = self:splitTxt(self.txtValue , self.targetTxtValue)
    local now_pos  = cc.p(0,self:getContentSize().height)
    local itemH = 0
    for k,v in pairs(txtTable) do
        now_pos.x = 0
        now_pos.y = now_pos.y - (self.targetFontSize+10) or 0
        for m,n in pairs(v)do
            -- if n == self.targetTxtValue then
            if n == self.targetWebSite then
                local pos_x, pos_y, textNode  = self:getStringLen(n, self.targetFontSize, self.targetTxtColor, self:getContentSize().width, now_pos, 0, self, true,self.cb)
                now_pos.x = pos_x
                now_pos.y = pos_y
            elseif n ~= "" then
                local pos_x, pos_y, textNode  = self:getStringLen(n, self.normalFontSize, self.normalColor, self:getContentSize().width, now_pos, 0, self)
                now_pos.x = pos_x
                now_pos.y = pos_y
            end
        end
    end
    local lastNode = self.txtLableItems[#self.txtLableItems]
    if self.frameUpdateAction and lastNode then
        self.frameUpdateAction(math.abs(now_pos.y) + lastNode:getContentSize().height)
    end
end

function RichTextNode:splitTxt(txt, targetTxt)
    if not txt or txt == "" then
        return {}
    end 
    
    local endtable = {}
    local detailTable = string.split(txt, "<!n>")
    for k,v in pairs(detailTable)do
        local txttable = string.split(v, targetTxt)
        local temp = {}
        for m=1,#txttable do
            table.insert(temp,txttable[m])
            if m % 2 == 0 then
                self.targetWebSite = txttable[m]
            end
            -- if m ~= #txttable then
            --     table.insert(temp,targetTxt)
            -- end
        end
        table.insert(endtable,temp)
        
    end
    dump(endtable)
    return  endtable
end

function RichTextNode:getStringLen(str,fontSize,color,maxwidth,Nowpos,basePosX,parent,isNeedLine,callBack)
    -- body
    local lenInByte = #str
    local width = 0
    local i = 1
    local txt=""
    local noeLine=0
    local text
    local textTable={}
    while true do
        if i <= lenInByte then
            local curByte = string.byte(str, i)
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<223 then
                byteCount = 2
            elseif curByte>=224 and curByte<239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
            local char = string.sub(str, i, i+byteCount-1)
            i = i + byteCount
            if byteCount == 1 then
                width = width + fontSize * 0.5
            else
                width = width + fontSize
            end
            if width+Nowpos.x>=maxwidth then
                text=ccui.Text:create(txt,GameRes.font1,fontSize)
                text:setAnchorPoint(0,0.5)
                text:setPosition(Nowpos.x,Nowpos.y)
                text:setColor(color)
                parent:addChild(text)
                if isNeedLine then
                    local line=ccui.Text:create("——",GameRes.font1,fontSize)
                    line:setAnchorPoint(0,1)
                    line:setColor(color)
                    line:setScaleX(text:getContentSize().width/line:getContentSize().width)
                    line:setPosition(Nowpos.x,Nowpos.y)
                    parent:addChild(line)
                end
                Nowpos.x=basePosX
                Nowpos.y=Nowpos.y-fontSize-10
                width=0
                txt=""
            end
            txt=txt..char
        else
            if txt~="" then
                text=ccui.Text:create(txt,GameRes.font1,fontSize)
                text:setAnchorPoint(0,0.5)
                text:setPosition(Nowpos.x,Nowpos.y)
                text:setColor(color)
                parent:addChild(text)
                if isNeedLine then
                    local line=ccui.Text:create("——",GameRes.font1,fontSize)
                    line:setAnchorPoint(0,1)
                    line:setColor(color)
                    line:setScaleX(text:getContentSize().width/line:getContentSize().width)
                    line:setPosition(Nowpos.x,Nowpos.y)
                    parent:addChild(line)
                end
            end
            break
        end
    end
    if text == nil then return 0,0,0, nil end
    table.insert(self.txtLableItems, text)

    if callBack then
        text:setTouchEnabled(true)
        addButtonEvent(text, callBack)
    end
    return text:getPositionX()+text:getContentSize().width, text:getPositionY(), text
end

return RichTextNode