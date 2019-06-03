local DDZDesk = import('.DDZDesk.lua')
local EventDDZDesk = class("EventDDZDesk", DDZDesk)

function EventDDZDesk:ctor ()
    self.enterRef = GAME_DDZ_MATCH
end

--更新匹配界面相关信息
function EventDDZDesk:updateMathInfo(model)
    loga("updateMathInfo\n" .. pb.tostring(model))
    local props = {
        "predict_time",         -- 预计匹配时间
        "matching_time",        -- 已匹配时间
        "matching_timeout",     -- 匹配超时时间
    }
    self:_updateProps(props,model,self)
end

-- override 入场
function EventDDZDesk:updateCacheByEnter (model)
    EventDDZDesk.super.updateCacheByEnter(self, model)

    self:updateMathInfo(model)

    self.is_final_round = model.is_final_round  -- 是否是决胜局
    self.round_index = model.round_index + 1    -- 当前局数

    local propsTable = {
        "match_level", --DDZ赛事段位 从青铜一阶到最强王者段位===>10~140 以10的跨度
        "dan_grading", --DDZ具体赛事段位范围 10:青铜 20:白银 30:黄金 40:钻石 50:宗师 60:最强王者
        "star_number" --星星个数   -1: 表示没有星星
    }

    for i = 1, model.player_info:len() do
        local u1 = model.player_info:get(i)
        local u2 = self._player_info[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        self._player_info[u1.uin] = u2
    end
end

-- override 游戏开始
function EventDDZDesk:updateCacheByGamestart (model)
    EventDDZDesk.super.updateCacheByGamestart(self, model)

    self.matchGameEnd = false

    local propsTable = {
        "match_level", --DDZ赛事段位 从青铜一阶到最强王者段位===>10~140 以10的跨度
        "dan_grading", --DDZ具体赛事段位范围 10:青铜 20:白银 30:黄金 40:钻石 50:宗师 60:最强王者
        "star_number" --星星个数   -1: 表示没有星星
    }

    for i = 1, model.player_info:len() do
        local u1 = model.player_info:get(i)
        local u2 = self._player_info[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        self._player_info[u1.uin] = u2
    end

    self.round_index = model.round_index + 1
end

-- override 更新玩家信息
function EventDDZDesk:updatePlayerInfo (users)
    local propsTable = {
        "match_level", --DDZ赛事段位 从青铜一阶到最强王者段位===>10~140 以10的跨度
        "dan_grading", --DDZ具体赛事段位范围 10:青铜 20:白银 30:黄金 40:钻石 50:宗师 60:最强王者
        "star_number" --星星个数   -1: 表示没有星星
    }

    for i=1, users:len() do
        local u1 = users:get(i)
        local u2 = self._player_info[u1.uin] or {}
        self:_updateProps(propsTable,u1,u2)  -- 拷贝user 信息
        self._player_info[u1.uin] = u2
    end
end

--更新比赛详情
function EventDDZDesk:updateRoundDetails( model )
    self.roundDetailModel = {}
    for i=1, model.round_details:len() do
        local detailInfo = model.round_details:get(i)
        if detailInfo.detail_infos:len() > 0 then
            self.roundDetailModel[detailInfo.uin] = {}
            self.roundDetailModel[detailInfo.uin].uin = detailInfo.uin
            self.roundDetailModel[detailInfo.uin].nick = detailInfo.nick
            self.roundDetailModel[detailInfo.uin].match_record = {}--比赛记录

            for ii=1, detailInfo.detail_infos:len() do
                local info = detailInfo.detail_infos:get(ii)
                if info.round_index ~= -1 then
                    self.roundDetailModel[detailInfo.uin].match_record[info.round_index] = {}
                    self.roundDetailModel[detailInfo.uin].match_record[info.round_index].round_index = info.round_index
                    self.roundDetailModel[detailInfo.uin].match_record[info.round_index].score = info.score
                    self.roundDetailModel[detailInfo.uin].match_record[info.round_index].time_used = info.cost_time
                end
            end
        end
    end
end

--比赛结束
function EventDDZDesk:updateCacheByGameover( model )
    EventDDZDesk.super.updateCacheByGameover(self, model)
    loga("比赛结束:\n"..pb.tostring(model))

    -- self.matchGameEnd = true
    -- self.old_ddz_match_level = model.old_level
    self:updateCacheByOneGameover(model)
    -- --本场比赛没有结束
    -- if model.over_flag == 0 then
    --     return
    -- end

    -- self.overInfo = {}

    -- self._player_info[Cache.user.uin].finalReward = {}
    -- for i=1, model.round_details:len() do
    --     local detailInfo = model.round_details:get(i)

    --     self._player_info[detailInfo.uin].gameEndTable = {}


    --     if detailInfo.uin == Cache.user.uin then
    --         self._player_info[detailInfo.uin].top_reward = Cache.user:getRewardConfigByLevel(model.cur_level, 1)
    --         if model.cur_level >= Cache.user:getMaxLevel() then
    --             self._player_info[detailInfo.uin].next_level_reward = {}
    --         else
    --             self._player_info[detailInfo.uin].next_level_reward = Cache.user:getRewardConfigByLevel(model.cur_level + 10, 1)
    --         end
    --     end

    --     self._player_info[detailInfo.uin].match_record = {}--比赛记录

    --     for ii=1, detailInfo.detail_infos:len() do
    --         local info = detailInfo.detail_infos:get(ii)
    --         if info.round_index ~= -1 then
    --             self._player_info[detailInfo.uin].match_record[info.round_index] = {}
    --             self._player_info[detailInfo.uin].match_record[info.round_index].round_index = info.round_index
    --             self._player_info[detailInfo.uin].match_record[info.round_index].score = info.score
    --             self._player_info[detailInfo.uin].match_record[info.round_index].time_used = info.cost_time
    --         else
    --             self._player_info[detailInfo.uin].allScore = info.score
    --             self._player_info[detailInfo.uin].gameEndTable.rank = info.score
    --             self._player_info[detailInfo.uin].gameEndTable.score = info.score
    --             self._player_info[detailInfo.uin].gameEndTable.time = info.cost_time
    --             if detailInfo.uin == Cache.user.uin then
    --                 self.mine_score = info.score
    --             end
    --         end
    --     end
    --     if detailInfo.uin == Cache.user.uin then
    --         if detailInfo.award_type == 2 and detailInfo.award_count > 0 and self.mine_is_win ~= true then
    --             local info = {}
    --             info.type = detailInfo.award_type
    --             info.value = detailInfo.award_count
    --             table.insert(self._player_info[Cache.user.uin].finalReward, info)
    --         end
    --     end

    --     -- 升级
    --     self._player_info[detailInfo.uin].gameEndTable.levelStatus = 0
    --     --0:升,级变;1升,级不变;2降, 级变;3降,级不变
    --     self._player_info[detailInfo.uin].gameEndTable.levelStatus = detailInfo.match_level_change_type
    --     table.insert(self.overInfo,{uin = detailInfo.uin, rank= self._player_info[detailInfo.uin].allScore})
    -- end

    -- --再更新下吧，用于比赛完了结算
    -- self:updateRoundDetails(model)

    -- table.sort(self.overInfo,function( a,b )
    --     return a.rank > b.rank
    -- end)
    -- self.mineTime = 0
    -- self.detailInfo = clone(self._player_info)

    -- if model.app_add_result_info and model.app_add_result_info.cur_lv_exit_matchreward then
    --     local matchingReward = model.app_add_result_info.cur_lv_exit_matchreward
    --     for i=1, matchingReward:len() do
    --         local rewardInfo = matchingReward:get(i)
    --         if rewardInfo.uin == Cache.user.uin and rewardInfo.value > 0 then
    --             if rewardInfo.type ~= 2 then
    --                 local info = {}
    --                 info.type = rewardInfo.type 
    --                 info.value = rewardInfo.value
    --                 table.insert(self._player_info[Cache.user.uin].finalReward, info)
    --             elseif self.mine_is_win == true and rewardInfo.type == 2 then
    --                 local info = {}
    --                 info.type = rewardInfo.type 
    --                 info.value = rewardInfo.value
    --                 table.insert(self._player_info[Cache.user.uin].finalReward, info)
    --             end
    --         end
    --     end
    -- end
    
    self:updateResultMatchSettle(model)
end

function EventDDZDesk:updateResultMatchSettle( model )
    self.matchSettles = {}

    for i = 1, model.match_settle:len() do
        local data = model.match_settle:get(i)

        local settle = {}

        local props = {
            "uin",
            "nick",
            "reward_base",
            "reward_lv_up",
            "reward_landlord",
            "star_protect_remain_count",
            "star_protect_consume_dia",
            "is_season_settle",
            "star_protect_again",
            "star_protect_card_dia",
            "next_reward_base"
        }
        --更新桌子基本信息
        self:_updateProps(props,data,settle)
    
        local props_matchLevel = {
            "match_lv",
            "sub_lv",
            "star",
            "sub_lv_star_num"
        }
    
        settle.all_lv_info_now = {}
        settle.all_lv_info_bef = {}
    
        self:_updateProps(props_matchLevel, data.all_lv_info_now, settle.all_lv_info_now)
        self:_updateProps(props_matchLevel, data.all_lv_info_bef, settle.all_lv_info_bef)
    
        local props_box = {
            "reward_box",
            "box_fee_diamond",
            "match_box_lv"
        }
    
        settle.reward_box = {}
        self:_updateProps(props_box, data.reward_box, settle.reward_box)

        --table.insert( self.matchSettles,settle )
        self.matchSettles[settle.uin] = settle
    end

    

    dump(self.matchSettles, "赛事结算数据")
end

--每局游戏结束
function EventDDZDesk:updateCacheByOneGameover(model)
    EventDDZDesk.super.updateCacheByOneGameover(self, model)

    self.start_time = model.stay_time --DDZ赛事默认停留结算页面时间
    for i = 1, model.player_result:len() do
        local u1 = model.player_result:get(i)
        local u2 = self._player_info[u1.uin] or {}
        u2.match_record = u2.match_record or {}
        u2.match_record[self.round_index] = {}
        u2.match_record[self.round_index].win_gold = u1.win_gold
        u2.match_record[self.round_index].score = u1.score
    end
    self.detailInfo = clone(self._player_info)
end

function EventDDZDesk:clear()
    EventDDZDesk.super.clear(self)
end

return EventDDZDesk