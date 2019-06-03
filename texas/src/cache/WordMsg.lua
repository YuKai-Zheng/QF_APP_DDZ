local WordMsg = class("WordMsg")

WordMsg.TAG = "WordMsg"
function WordMsg:ctor ()
    self.totalMsgList = {}
    self.curentIndex = 1
    self.deafIndex = 1
end

function WordMsg:setDeafultMsg( msg )
    self.deafultMsgList = {}--跑马灯默认显示文字
    for i = 1, msg:len() do             --获取场次信息
        local item = msg:get(i)
        local deafultMsg = {}
        deafultMsg.level = 200
        deafultMsg.nick = GameTxt.deafult_wordmsg_nick
        deafultMsg.content = item
        table.insert(self.deafultMsgList,deafultMsg)
    end
end

function WordMsg:getDeafultMsg()
    local msg = {}
    local nLen = #self.deafultMsgList
    for i=self.deafIndex,nLen do  
        msg =  self.deafultMsgList[i]
        break      
    end
    self.deafIndex = self.deafIndex+1
    if self.deafIndex>nLen then
        self.deafIndex  = 1
    end
    return msg
end
function WordMsg:saveMsg(paras)

	local msgItem = {}
	msgItem.level = paras.level
	msgItem.nick = paras.nick
	msgItem.content = paras.content
    msgItem.new_content = paras.new_content
    msgItem.contents={}
    msgItem.contents["str1"] = paras.contents["str1"]
    msgItem.contents["str2"] = paras.contents["str2"]
    msgItem.contents["str3"] = paras.contents["str3"]
    msgItem.contents["str4"] = paras.contents["str4"]
    table.insert(self.totalMsgList,msgItem)
    if #self.totalMsgList>10 then
        table.remove(self.totalMsgList,1)
    end
    self.curentIndex = #self.totalMsgList
end
function WordMsg:getMsg(level)

    local msg = {}
    local nLen = #self.totalMsgList
    for i=self.curentIndex,nLen do
        if level == 0 then
           msg =  self.totalMsgList[i]
           break
        else
           if self.totalMsgList[i].level == level then
              msg =  self.totalMsgList[i]
              break
           end
        end      
    end
    self.curentIndex = self.curentIndex+1
    if self.curentIndex>nLen then
    	self.curentIndex  = 1
    end
    return msg
end

function WordMsg:getAllMsg()

    local AllMsg = {}
    for k,v in pairs(self.deafultMsgList) do
        table.insert(AllMsg,v)
    end

    for k,v in pairs(self.totalMsgList) do
        table.insert(AllMsg,v)
    end
    return AllMsg
end

return WordMsg