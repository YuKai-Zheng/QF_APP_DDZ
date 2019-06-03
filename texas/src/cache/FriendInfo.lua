local FriendInfo = class("FriendInfo")

FriendInfo.TAG = "FriendInfo"
FriendInfo.isJustView = false --如果是从好友列表中进入好友牌局的观战 进入桌子后不主动坐下
FriendInfo.redPointNum = 0 --小红点

function FriendInfo:updateFriendList(model)
	if model ~= nil then
		--loga(pb.tostring(model))
	end
    local filename = {
        "nick",
        "uin",
        "title",
        "win",
        "lose",
        "sex",
        "gold",
        "send_gift_flag",
        "vip_days",
        "portrait",
        online_info = {
            "status",
            "desk_id",
            "room_id",
            "desc",
            "last_online_time",
            "ip",
            "port",
            "room_type",
            "desk_type"
        }
    }
    self[1] = {}--好友列表
    if model == nil  or model.friends:len() == 0 then self[1].number = 0
    else
        self[1].number = model.friends:len()
        for i = 1, model.friends:len() do
            self[1][i] = {}
            self:copyFiled(filename,model.friends:get(i),self[1][i])
        end
    end
    
    filename = {
        "uin",
        "nick",
        "gold",
        "status",
        "sex",
        "gift_id",
        "vip_days",
        "portrait",
        online_info = {
            "status",
            "desk_id",
            "room_id",
            "desc",
            "last_online_time",
            "ip",
            "port",
            "room_type"
        }
    }
    
    self[2] = {}--好友列表
    if model == nil  or model.messages:len() == 0 then self[2].number = 0
    else
        self[2].number = model.messages:len()
        for i = 1, model.messages:len() do
            self[2][i] = {}
            self:copyFiled(filename,model.messages:get(i),self[2][i])
        end
    end
    
    filename = {
        "uin",
        "nick",
        "gift_id",
        "gift_gold",        
        "sex",
        "vip_days",
        "portrait"
    }

    self[3] = {}--好友列表
    if model == nil  or model.requests:len() == 0 then self[3].number = 0
    else
        self[3].number = model.requests:len()
        for i = 1, model.requests:len() do
            self[3][i] = {}
            self:copyFiled(filename,model.requests:get(i),self[3][i])
        end
    end
    qf.event:dispatchEvent(ET.REFRESH_FRIEND_LISTVIEW,{chooice = 1})
end

function FriendInfo:updateOnLineFriendList(model)
    self[4] = {}
    local filename = {
        "desk_id",
        "sex",
        "nick",
        "uin",
        "gold",
        "portrait"
    }
    if model then
        for i = 1, model.friends:len() do
            self[4][i] = {}
            self:copyFiled(filename,model.friends:get(i),self[4][i])
        end
    end
end

function FriendInfo:updateCollectList(type,model)

    local filename = {
        "gold",
        "is_friend",
        "sex",
        "nick",
        "uin",
        "portrait"
    }
    self[type] = {}--搜索的

    qf.event:dispatchEvent(ET.REFRESH_FRIEND_LISTVIEW,{chooice = 2})
end

function FriendInfo:cancelAttention(key)
    if self[2][key] then self[2][key] = nil end
end

function FriendInfo:haveSendGift(key)
    if self[1][key] then self[1][key].send_gift_flag = 1 end
end

function FriendInfo:haveSendGiftByUin(uin)
    for k,v in pairs(self[1]) do
        if v[k].uin == uin then
            self[1][k].send_gift_flag = 1
        end
    end
end

function FriendInfo:updateGiftList(model)
    self.giftList = {}
    local filename = {
        "seq",
        "from_uin",
        "from_nick",
        "gold",
        "send_time",
        "status",
        "desc"
    }
    if model == nil or model.send_list:len() == 0 then self.giftList.number = 0
    else
        self.giftList.number = model.send_list:len()
        self.giftList["send_limit"] = model.send_limit
        self.giftList["period"] = model.period
        for i = 1,model.send_list:len() do
            self.giftList[i] = {}
            self:copyFiled(filename,model.send_list:get(i),self.giftList[i])
        end
    end
end

function FriendInfo:clearInfo()
    for i = 1 , 4 do
        self[i] = {}
    end
end


function FriendInfo:copyFiled(p,s,d)
    for k,v in pairs(p) do
        if type(v) == "table" then
            d[k] = {}
            self:copyFiled(v,s[k],d[k])
        else
            d[v] = s[v]
        end    
    end
end

function FriendInfo:saveRemarkList(model)
    self.remarklist ={}
    self.remark_status=model.remark_status
    for i=1 ,model.remarks:len() do
        local data = model.remarks:get(i)
        local info = {
                        uin = data.uin,--uin
                        nick = data.nick --nick
                      }
       
        table.insert(self.remarklist,#self.remarklist+1,info)
    end
end
return FriendInfo