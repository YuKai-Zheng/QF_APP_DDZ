local DDZDesk = class("DDZDesk")

DDZDesk._player_info  = {}  --用户信息
DDZDesk.rankTable     = {}  --排名信息
DDZDesk.detailInfo = {} --单独存对局详情的表
DDZDesk.musicType = 1
DDZDesk.mineTime = 0
DDZDesk.mine_score = 0
DDZDesk.nowPoints = -1
DDZDesk.status = GameStatus.NONE
function DDZDesk:ctor ()
    self.can_showCard = true
    self.short_op_flag = 0
end

--获取桌子上的用户
function DDZDesk:getUserByUin(uin)
    if self._player_info[uin] then
        return self._player_info[uin]
    end
    return nil
end

--更新牌桌倍数信息
function DDZDesk:updateMulti(model)
    local props = {
        "multiple",          --总倍数
        "dipai_multi",      --底牌翻倍倍数
        "dipai_multi_type", --底牌翻倍类型 1:大王 2:小王 3:同花 4:顺子 5:大王小王 6:同花顺 7:三张
    }

    self.multipleInfo = self.multipleInfo or {}
    self:_updateProps(props,model,self.multipleInfo)
end

--更新牌桌基本信息
function DDZDesk:updateDeskBaseInfo(model)
    if model == nil then return end

    local props = {
        "name",
        "battle_type",      --对局类型： 1经典场 2.癞子玩法
        "max_round",        --最大局数
        "cap_score",        --地主封顶分数
        "allow_view",       --是否允许旁观 0 否， 1是
        "enter_fee",        --入局服务费
        "base_score"        --初始分
    }
    self:_updateProps(props,model,self)
end

-- 更新能否加倍信息
function DDZDesk:updateCanCallDoubleInfo(model)
    self.canCallDoubleInfo = {}
    for i=1, model:len() do
        local uin = model:get(i)
        self.canCallDoubleInfo[uin] = uin
    end
end

--入场
function DDZDesk:updateCacheByEnter( model )
    --loga("玩家入场\n" .. pb.tostring(model))
    self.musicType = 1
    self.first_grab_uin = 0
    
    self.can_showCard = true    --是否可明牌

    local baseProps = {
        --新增的
        "desk_id",
        "room_id",
        "status",           --游戏状态 0:准备中 10:叫分中 20:加倍中 30:游戏中
        "next_uin",         --轮到谁了， 断线重连有效
        "multiple",         --倍数
        "landlord_uin",     --地主id
        "op_left_time",     --玩家操作剩余过期时间
        "room_type",        --房间类型
        "last_uin",         --上一手牌是谁出的
        "desk_mode",        --1.标准模式 2.好友模式
        "max_grab_action",  --当前叫到的最大请地主类型值
        "round_id",         --牌桌uuid. 牌桌唯一标识
        "over_flag",        -- 整场牌桌结束标记 0否 1是
        "master_uin",       -- 房主的uin. 好友房则有房主。没有填充0
        "short_op_flag",    --当前操作者标记 0；无 1.当前操作者要不起。
        "card_counter_time",--记牌器弹窗显示时间
        "multi_min_gold",    --可以加倍的最小金币数
    }

    if model.has_cancel_show   and model.has_cancel_show   == 1 then
        self.can_showCard = false
    end

    --更新桌子基础属性
    self:_updateProps(baseProps,model,self)

    if model.uin == Cache.user.uin then
        self._player_info={}
        self.mine_score = 0
        self.mineTime = model.op_left_time or 0 --自己操作剩余时间
        Cache.DDZDesk.enterRef = model.desk_mode --重新更新下游戏类型
        self.firstEnterUser = nil
        self.chat = {}
    elseif not self.firstEnterUser then
        self.firstEnterUser = model.uin
    end

    self:updateMulti(model)
    self:updateDeskBaseInfo(model.cm_data)

    --更新玩家属性
    local propsTable = {
        "status", --状态 1010站起， 1018坐下未准备， 1020坐下已准备， 1030游戏中
        "nick",
        "seat_id",
        "sex",
        "uin",
        "openid",
        "is_robot",
        "portrait",
        "call_multiple", -- 玩家选择加倍的情况, -1:还没做出选择；0:不加倍；1:加倍
        "call_score", --叫分分数，-1:还未选择叫分 0:不叫分 1:1分 2:2分 3:3分 4:4分
        "auto_play", --是否是托管，0：否，1：是
        "gold",
        "show_multi", --玩家的明牌倍数 1：表示没明牌 大于1其他明牌
        "player_score", --玩家在牌桌内的分值情况。（好友房）
        "grab_action", --抢地主类型
        "icon_frame",
        "icon_frame_id"
    }

    --玩家亮牌信息,每个玩家剩余的手牌
    local deskCard = {}
    for i=1, model.card_list:len() do
        local cardInfo = model.card_list:get(i)
        deskCard[cardInfo.uin] = {}
        deskCard[cardInfo.uin].uin = cardInfo.uin
        deskCard[cardInfo.uin].cards = cardInfo.cards
        deskCard[cardInfo.uin].cards_num = cardInfo.cards_num
    end

    self.nowPoints = -1  --当前叫的分

    --玩家信息
    for i = 1, model.player_info:len() do
        local u1 = model.player_info:get(i)
        local u2 = self._player_info[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        self._player_info[u1.uin]             = u2
        self._player_info[u1.uin].remain_cards = {}

        --玩家手牌
        local handCards = deskCard[u1.uin].cards
        for i=1, handCards:len() do
            local card = handCards:get(i)
            table.insert(self._player_info[u1.uin].remain_cards, card)
        end
        self._player_info[u1.uin].cards_num = deskCard[u1.uin].cards_num
        
        --叫分情况
        if self.nowPoints < u1.call_score then
            self.nowPoints = u1.call_score
        end

        --托管情况
        if u1.auto_play == 1 then
            self._player_info[u1.uin].isauto = true
        else
            self._player_info[u1.uin].isauto = nil
        end
        --座位信息
        if u1.uin == Cache.user.uin then
            Cache.user.meIndex = u1.seat_id or -1
        end
        if model.uin == Cache.user.uin and not self.firstEnterUser and u1.uin ~= Cache.user.uin then
            self.firstEnterUser = u1.uin
        end
        self._player_info[u1.uin].isShowCard = false
        if u1.show_multi > 1 then
            self._player_info[u1.uin].isShowCard = true
        end

        self._player_info[u1.uin].all_lv_info = {}
        self._player_info[u1.uin].all_lv_info.match_lv = u1.all_lv_info.match_lv
        self._player_info[u1.uin].all_lv_info.sub_lv = u1.all_lv_info.sub_lv
        self._player_info[u1.uin].all_lv_info.sub_lv_star_num = u1.all_lv_info.sub_lv_star_num
        self._player_info[u1.uin].all_lv_info.star = u1.all_lv_info.star
    end

    --超级加倍卡
    if model.super_multi_card and model.uin == Cache.user.uin then
        Cache.user.super_multi_card_num = model.super_multi_card.counts
    end

    self:updateCanCallDoubleInfo(model.next_uin2)

    --公共牌、底牌
    self.commonCard = {}
    for i = 1, model.hole_cards:len() do
        local card = model.hole_cards:get(i)
        table.insert(self.commonCard,card)
    end

    --当前历史出牌记录
    self.now_max_cards_uin = 0
    self.now_max_cards = {}
    for i=1, model.last_cards:len() do
        local outCard = model.last_cards:get(i)
        self._player_info[outCard.uin].out_cards = {}
        if outCard.action == 1 then --0: 没有操作；1：出牌；2：不出
            for ii=1, outCard.cards:len() do
                local card = outCard.cards:get(ii)
                table.insert(self._player_info[outCard.uin].out_cards, card)
            end
            if self.now_max_cards_uin == 0 then
                self.now_max_cards_uin = outCard.uin
                self.now_max_cards = self._player_info[outCard.uin].out_cards
            end
        end
    end

    --记牌器相关【合服】
    if model.uin == Cache.user.uin then
        self._player_info[Cache.user.uin].use_card_remember = model.use_card_remember --是否显示记牌器
        self._player_info[Cache.user.uin].total_remain_cards = {}
        if model.total_remain_cards then
            for i = 1, model.total_remain_cards:len() do
                local card = model.total_remain_cards:get(i)
                table.insert(self._player_info[Cache.user.uin].total_remain_cards,card)
            end
        end
        --自己 ，去查询记牌器的商品信息
        self:getCardRememberData()
    end
end

--去查询记牌器的商品信息
function DDZDesk:getCardRememberData()
    self.cardRememberData = Cache.PayManager:getCardRememberData()
end

--叫分/抢地主
function DDZDesk:updateCacheByCallPoints( model )
    loga(os.date("%c", socket.gettime()))
    loga("玩家叫分:\n"..pb.tostring(model))

    --基础属性
    self.next_uin = model.next_uin
    self.op_left_time = model.op_left_time
    self.landlord_uin = model.landlord_uin
    self.max_grab_action = model.max_grab_action
    self.status = model.status --游戏状态 0:准备中 10:叫分中 20:加倍中 30:游戏中
    self.grab_action = model.grab_action
    self.first_grab_uin = model.first_grab_uin

    --当前叫分数量
    if self.nowPoints < model.grab_action then
        self.nowPoints = model.grab_action
    end
    
    --底牌翻倍倍数
    self.multipleInfo.dipai_multi = model.dipai_multi
    self.multipleInfo.dipai_multi_type = model.dipai_multi_type

    --三张底牌
    self.commonCard = {}
    for i = 1, model.hole_cards:len() do
        local card = model.hole_cards:get(i)
        table.insert(self.commonCard,card)
    end

    --玩家手牌
    for i = 1, model.card_list:len() do
        local u1 = model.card_list:get(i)
        self._player_info[u1.uin].remain_cards = {}
        self._player_info[u1.uin].cards_num = u1.cards_num
        for i = 1, u1.cards:len() do
            local card = u1.cards:get(i)
            table.insert(self._player_info[u1.uin].remain_cards,card)
        end
    end
    self:updateCanCallDoubleInfo(model.next_uin2)
end

--加倍
function DDZDesk:updateCacheByCallDouble( model )
    loga(os.date("%c", socket.gettime()))
    loga("加倍:\n"..pb.tostring(model))
    -- loga("加倍:\n"..pb.tostring(model))
    local props = {
        "op_uin","next_uin", "status", "op_left_time"
    }
    self:_updateProps(props,model,self)

    self.DoubleTable = self.DoubleTable or {}
    for i = 1, model.do_multi:len() do
        local doMultiInfo = model.do_multi:get(i)
        self.DoubleTable[doMultiInfo.uin] = doMultiInfo.result
    end
    self:updateCanCallDoubleInfo(model.next_uin2)
    
    --记牌器相关【合服】
    self._player_info[Cache.user.uin].use_card_remember = model.use_card_remember --是否显示记牌器
    self._player_info[Cache.user.uin].total_remain_cards = {}
    if model.total_remain_cards then
        for i = 1, model.total_remain_cards:len() do
            local card = model.total_remain_cards:get(i)
            table.insert(self._player_info[Cache.user.uin].total_remain_cards,card)
        end
    end
    --超级加倍卡
    if model.op_uin == Cache.user.uin then
        if model.super_multi_card then
            Cache.user.super_multi_card_num = model.super_multi_card.counts
        end
    end
end

--游戏开始
function DDZDesk:updateCacheByGamestart(model)
    loga(os.date("%c", socket.gettime()))
    loga("游戏开始:\n"..pb.tostring(model))
    self.firstCallLandlords = true
    self.first_grab_uin = 0
    local propsTable = {
        "status", --状态 1010站起， 1018坐下未准备， 1020坐下已准备， 1030游戏中
        "nick",
        "seat_id",
        "sex",
        "uin",
        "openid",
        "is_robot",
        "portrait",
        "call_multiple", -- 玩家选择加倍的情况, -1:还没做出选择；0:不加倍；1:加倍
        "call_score", --叫分分数，-1:还未选择叫分 0:不叫分 1:1分 2:2分 3:3分 4:4分
        "auto_play", --是否是托管，0：否，1：是
        "gold",
        "show_multi", --玩家的明牌倍数 1：表示没明牌 大于1其他明牌
        "player_score", --玩家在牌桌内的分值情况。（好友房）
        "grab_action", --抢地主类型
    }
    self.now_max_cards_uin = 0

    --玩家亮牌信息,每个玩家剩余的手牌
    local deskCard = {}
    for i=1, model.card_list:len() do
        local cardInfo = model.card_list:get(i)
        deskCard[cardInfo.uin] = {}
        deskCard[cardInfo.uin].uin = cardInfo.uin
        deskCard[cardInfo.uin].cards = cardInfo.cards
        deskCard[cardInfo.uin].cards_num = cardInfo.cards_num
    end

    for i = 1, model.player_info:len() do
        local u1 = model.player_info:get(i)
        local u2 = self._player_info[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        self._player_info[u1.uin] = u2
        self._player_info[u1.uin].remain_cards = {}

        --玩家手牌
        local handCards = deskCard[u1.uin].cards
        for i = 1, handCards:len() do
            local card = handCards:get(i)
            table.insert(self._player_info[u1.uin].remain_cards,card)
        end

        self._player_info[u1.uin].cards_num = deskCard[u1.uin].cards_num

        --托管情况
        if u1.auto_play == 1 then
            self._player_info[u1.uin].isauto = true
        else
            self._player_info[u1.uin].isauto = nil
        end

        if u1.uin == Cache.user.uin then
            Cache.user.meIndex = u1.seat_id or -1
        end
        if u1.show_multi > 1 then
            self._player_info[u1.uin].isShowCard = true
        else
            self._player_info[u1.uin].isShowCard = false
        end
    end

    self:_updateProps({"status","next_uin","max_grab_action","base_score","op_left_time"},model,self)
end

--更新操作者信息
function DDZDesk:updateOpUserInfo( model )
    local props = {"status", "next_uin", "op_left_time"}
    self:_updateProps(props,model,self)
end

--托管
function DDZDesk:updateCacheByAuto( model )
    loga(os.date("%c", socket.gettime()))
    loga("托管:\n"..pb.tostring(model))
    if model.auto == 1 then
        self._player_info[model.uin].isauto = true
    else
        self._player_info[model.uin].isauto = nil
    end
end

--出牌
function DDZDesk:updateCacheByOutCards( model )
    loga(os.date("%c", socket.gettime()))
    loga("出牌:\n"..pb.tostring(model))
    --更新操作者信息
    self:updateOpUserInfo(model)
    --只要是出了牌就是当前最大max的uin
    if model.card_type ~= -1 then
        self.now_max_cards_uin = model.op_uin
    end
    
    self.time_out_flag = 0  --这个先设置为不超时
    self.short_op_flag = model.short_op_flag --当前操作者标记 0；无 1.当前操作者要不起。
    self.server_replaced = model.server_replaced --服务器代打最后一手牌 1 是 0 否
    
    --出的牌信息
    if self._player_info[model.op_uin] then
        --打出去的牌
        self._player_info[model.op_uin].out_cards = {}
        for i = 1, model.play_cards:len() do
            local card = model.play_cards:get(i)
            table.insert(self._player_info[model.op_uin].out_cards,card)
        end

        local deskCard = {}
        for i=1, model.card_list:len() do
            local cardInfo = model.card_list:get(i)
            deskCard[cardInfo.uin] = {}
            deskCard[cardInfo.uin].uin = cardInfo.uin
            deskCard[cardInfo.uin].cards = cardInfo.cards
            deskCard[cardInfo.uin].cards_num = cardInfo.cards_num
        end
        --当前操作者手牌
        self._player_info[model.op_uin].remain_cards = {}
        for i = 1, deskCard[model.op_uin].cards:len() do
            local card = deskCard[model.op_uin].cards:get(i)
            table.insert(self._player_info[model.op_uin].remain_cards,card)
        end
        self._player_info[model.op_uin].cards_num = deskCard[model.op_uin].cards_num
        self._player_info[model.op_uin].out_cards_type = model.card_type
    end
    
    --记牌器相关【合服】
    -- if model.op_uin == Cache.user.uin then
        self._player_info[Cache.user.uin].total_remain_cards = {}
        if model.total_remain_cards then
            for i = 1, model.total_remain_cards:len() do
                local card = model.total_remain_cards:get(i)
                table.insert(self._player_info[Cache.user.uin].total_remain_cards,card)
            end
        end
    -- end
    self.status = GameStatus.INGAME
end

--更新玩家信息
function DDZDesk:updatePlayerInfo(users)
    local propsTable = {
        "status", --状态 1010站起， 1018坐下未准备， 1020坐下已准备， 1030游戏中
        "nick",
        "seat_id",
        "sex",
        "uin",
        "openid",
        "is_robot",
        "portrait",
        "call_multiple", -- 玩家选择加倍的情况, -1:还没做出选择；0:不加倍；1:加倍
        "call_score", --叫分分数，-1:还未选择叫分 0:不叫分 1:1分 2:2分 3:3分 4:4分
        "auto_play", --是否是托管，0：否，1：是
        "gold",
        "show_multi", --玩家的明牌倍数 1：表示没明牌 大于1其他明牌
        "player_score", --玩家在牌桌内的分值情况。（好友房）
        "grab_action", --抢地主类型
    }
    if self._player_info == nil then
        self._player_info = {}
    end
    --需要更新用户数据
    for i=1, users:len() do
        local u1 = users:get(i)
        local u2 = self._player_info[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        self._player_info[u1.uin] = u2

        --叫分情况
        if self.nowPoints < u1.call_score then
            self.nowPoints = u1.call_score
        end

        --托管情况
        if u1.auto_play == 1 then
            self._player_info[u1.uin].isauto = true
        else
            self._player_info[u1.uin].isauto = nil
        end

        --座位信息
        if u1.uin == Cache.user.uin then
            Cache.user.meIndex = u1.seat_id or -1
        end

        self._player_info[u1.uin].all_lv_info = {}
        self._player_info[u1.uin].all_lv_info.match_lv = u1.all_lv_info.match_lv
        self._player_info[u1.uin].all_lv_info.sub_lv = u1.all_lv_info.sub_lv
        self._player_info[u1.uin].all_lv_info.sub_lv_star_num = u1.all_lv_info.sub_lv_star_num
        self._player_info[u1.uin].all_lv_info.star = u1.all_lv_info.star
    end
    qf.event:dispatchEvent(ET.UPDATE_USER_GOLD)
end

--比赛结束
function DDZDesk:updateCacheByGameover( model )

end

function DDZDesk:updateCacheByOneGameover(model)
    loga(os.date("%c", socket.gettime()))
    loga("游戏结束111:\n"..pb.tostring(model))

    self.musicType = 1
    local props = {
        "is_winner",        --0:失败, 1:胜利
        "win_score",        --小于0失败 大于0胜利
        "cost_time",        --耗时:秒
        "landlord_uin",     --地主的uin
        "over_flag",        --整场结束标记位  0: 否  1: 是
        "is_abolish"        --是否是流局， 0: 不是  1: 是
    }
    --更新桌子基本信息
    self:_updateProps(props,model,self)

    --自己赢了没
    self.mine_is_win = false
    if model.is_winner == 1 then
        self.mine_is_win = true
    end
    self.win_type = model.spring_type --春天的类型，0：不是春天；1：春天；2：反春

    --更新玩家信息
    self:updatePlayerInfo(model.player_info)

    --玩家手牌
    for i=1, model.card_list:len() do
        local cardInfo = model.card_list:get(i)
        self._player_info[cardInfo.uin].remain_cards = {}
        local handCards = cardInfo.cards
        for i=1, handCards:len() do
            local card = handCards:get(i)
            table.insert(self._player_info[cardInfo.uin].remain_cards, card)
        end
        self._player_info[cardInfo.uin].cards_num = cardInfo.cards_num
    end

    self.nowPoints = -1

    for i = 1, model.player_result:len() do
        local u1 = model.player_result:get(i)
        local u2 = self._player_info[u1.uin] or {}
        u2.multiple = u1.multi
        u2.win_money = u1.win_gold --本副牌赢得金币
        u2.win_score = u1.score --本副牌赢得积分
        u2.base_socre = u1.base_socre --底分
        u2.calc_type = u1.calc_type --结算类型 0正常结算 1破产 2封顶
        if u2.uin == Cache.user.uin then
            Cache.user.IsNeedWaitInGameEndBankrupt = true
        end
    end

    self:updateGameEndMultis(model.multiple_info)

    for k,v in pairs(self._player_info) do
        v.isShowCard = nil
        v.status = 1020
    end

    --重置数据
    self.commonCard={}
    self.status = GameStatus.READY
    self.DoubleTable = {}
end

function DDZDesk:updateGameEndMultis( model )
    local info = {}
    -- loga("更新自己的倍率".."\n" .. pb.tostring(model))
    local props = {
        "multiple",     --玩家倍数（总倍数）--与进桌一致
        "init_multi",   --初始倍数
        "show_multi",   --明牌倍数
        "qdz_multi",      --抢地主倍数
        "dipai_multi",     --底牌倍数
        "bomb_multi",     --炸弹倍数
        "spring_multi",  --春天倍数
        "common_multi",     --公共倍数
        "landloard_increase",  --地主加倍倍数
        "farmer_increase",    --农民加倍
    }
    self.multipleInfo = self.multipleInfo or {}
    self.multipleInfo.multiple = model.total_multi
    self.multipleInfo.init_multi = model.init_multi
    self.multipleInfo.show_multi = model.show_multi
    self.multipleInfo.qdz_multi = model.qdz_multi
    self.multipleInfo.dipai_multi = model.dipai_multi
    self.multipleInfo.bomb_multi = model.bomb_multi
    self.multipleInfo.spring_multi = model.spring_multi
    self.multipleInfo.common_multi = model.common_multi
    self.multipleInfo.landloard_increase = model.landlord_multi
    self.multipleInfo.farmer_increase = model.farmers_multi
end

--用户退场
function DDZDesk:updateCacheByUserquit(model)
    loga("用户退场:\n"..pb.tostring(model))
    self.reason = model.reason
    if model.op_uin == Cache.user.uin then
        self:clear()
    else
        if self._player_info[model.op_uin] then
            self._player_info[model.op_uin] = nil
        end 
        if self.firstEnterUser == model.op_uin then
            for k,v in pairs(self._player_info)do
                if k ~=Cache.user.uin and v then
                    self.firstEnterUser = k
                    return 
                end
            end
            self.firstEnterUser = nil
        end
    end
end

--用户明牌
function DDZDesk:updateCacheByUserShowCard(model)
    for i=1, model.show_cards:len() do
        local showCardInfo = model.show_cards:get(i)
        self._player_info[showCardInfo.uin].remain_cards = {}
        --玩家手牌
        local handCards = showCardInfo.card_info.cards
        for j=1, handCards:len() do
            local card = handCards:get(j)
            table.insert(self._player_info[showCardInfo.uin].remain_cards, card)
        end
        self._player_info[showCardInfo.uin].cards_num = showCardInfo.card_info.cards_num
        self._player_info[showCardInfo.uin].show_multi = showCardInfo.show_multi
        self._player_info[showCardInfo.uin].isShowCard = true
    end
end

-- optional int64 multiple = 1;            //玩家倍数（总倍数）--与进桌一致
function DDZDesk:updateMySelfBeiInfo(model)
    local info = {}
    -- loga("更新自己的倍率".."\n" .. pb.tostring(model))
    local props = {
        "multiple",     --玩家倍数（总倍数）--与进桌一致
        "init_multi",   --初始倍数
        "show_multi",   --明牌倍数
        "qdz_multi",      --抢地主倍数
        "dipai_multi",     --底牌倍数
        "bomb_multi",     --炸弹倍数
        "spring_multi",  --春天倍数
        "common_multi",     --公共倍数
        "landloard_increase",  --地主加倍倍数
        "farmer_increase",    --农民加倍
    }
    self.multipleInfo = {}
    self:_updateProps(props,model,self.multipleInfo)
end

function DDZDesk:updateBeiInfo(model)
    local info = {}
    -- loga("更新自己的倍率".."\n" .. pb.tostring(model))
    local props = {
        --"multiple",
        "init_multi", 		--初始倍数
            "show_multi",     	--明牌倍数的值
            "spring_multi",		--春天倍数
            "dipai_multi",		--底牌倍数
            "bomb_multi",		--炸弹倍数
            "qdz_multi",		--抢地主倍数
            "common_multi",		--公共倍数
            "landlord_multi" ,  --地主加倍倍数
            "farmers_multi",	--农民加倍倍数
            "total_multi",		--总倍数
    }
    self.multipleInfo = self.multipleInfo or {}
    self:_updateProps(props,model,self.multipleInfo)
end

--同步人员金币信息到客户端
function DDZDesk:updateUserFortuneInfo(model)
    for i=1, model.fortune_infos:len() do
        local info = model.fortune_infos:get(i)
        self._player_info[info.uin].gold = info.gold
    end
end

-- 倍数详情
function DDZDesk:getBeiDetailInfo()
    return self.multipleInfo
end

-- 聊天表情
function DDZDesk:updateCacheByChat(model)
    loga("收到聊天表情\n" .. pb.tostring(model))
    local content=Util:filterEmoji(model.content or "")
    if content=="" then return end
    local sex = model.gender
    local rightUser = self._player_info[model.op_uin]
    if sex == nil and rightUser then
        sex = rightUser.sex or 0
    end
    local chat_table = {portrait=model.portrait,content=content,uin=model.op_uin,sex = sex}
    local index      = string.sub(model.content,1,1)
    loga("model.content:"..model.content)

    if model.content_type == 3 and string.len(model.content)>1 then 
        table.insert(self["chat"],chat_table)
    elseif model.content_type == 0 and string.len(model.content)>1 then
        chat_table = {portrait=model.portrait,content=content,uin=model.op_uin,emoji=true,sex = sex}
        table.insert(self["chat"],chat_table)
    end
    if #self["chat"]>20 then
        table.remove(self["chat"],1)
    end
end

function DDZDesk:getUserCanCallDoudle(uin)
    local flag = false
    if (self.canCallDoubleInfo and self.canCallDoubleInfo[uin]) or self.next_uin == uin then
        flag = true
    end

    return flag
end

function DDZDesk:getCurrentDiFen()
    if self.nowPoints <= 0 then
        return 1
    end
    return self.nowPoints
end

function DDZDesk:clearChat()
    -- body
    if self["chat"]~=nil then
        self["chat"]={}
    end
end

function DDZDesk:clear()
    for k,v in pairs(self._player_info) do
        if k ~= Cache.user.uin then
            self._player_info[k] = nil
        end
    end
    self.mine_score = 0
    self.round_index = 1
    self.mineTime = 0
    self["next_uin"]    = nil
    self.status         = nil
    self.firstEnterUser = nil
    self.can_showCard = true
    self.detailInfo = {}
end

--赋值方法
function DDZDesk:_updateProps( propsTable , src,dest )
    for k,v in pairs(propsTable) do
        if src[v] ~= nil then
            dest[v] = src[v]
        end
    end
end

--地主是否可加倍
function DDZDesk:isLordCanDouble()
    for k, v in pairs(self._player_info) do
        if v.gold < self.multi_min_gold then
            return false
        end
    end

    return true
end

--农民是否可加倍
function DDZDesk:isFarmerCanDouble()
    if self:getUserByUin(Cache.user.uin).gold < self.multi_min_gold then
        return false
    elseif self:getUserByUin(self.landlord_uin).gold < self.multi_min_gold then
        return false
    else
        return true
    end
end

function DDZDesk:setRoomId (room_id)
    self.room_id = room_id
end

return DDZDesk