--[[
    牌桌内通用常量整理
]]
local GameConstants = class("GameConstants")
--[[
    不分场次通用布局
]]
GameConstants.LAYOUT_COMMON = {}
GameConstants.LAYOUT_COMMON.DESK_OFFSET = -10   --牌桌中线偏移
GameConstants.LAYOUT_COMMON.DESK_POS_X = 0    --牌桌中线x坐标
GameConstants.LAYOUT_COMMON.TOTAL_CHIPS_TXT_POS = cc.p(0, 761)   --底池位置
--[[
    5人场布局
    if self.seatLimit == 5 then
        self.DESK_CARD_POSY = self.winSize.height*0.52
        self.DESK_CHIPS_RADIO = 0.61
        self:initFiveUser()
    elseif self.seatLimit == 9 then
        self.DESK_CARD_POSY = self.winSize.height*0.5
        self.DESK_CHIPS_RADIO = 0.59
        self:initNineUser()
    end

]]
GameConstants.LAYOUT_5 = {}
GameConstants.LAYOUT_5.DESK_CARDS_POS = cc.p(0,562) --公共牌坐标
GameConstants.LAYOUT_5.DESK_CARD_SEND_Y = 302       --发牌的位置y坐标
GameConstants.LAYOUT_5.DESK_CHIPS_X = 922           --底池筹码x坐标
GameConstants.LAYOUT_5.DESK_CHIPS_Y = 659           --底池筹码y坐标
GameConstants.LAYOUT_5.DESK_TXT_POS = cc.p(0, 464)  --桌面文字位置
GameConstants.LAYOUT_5.USER_SCALE = 1.08            --玩家node scale
GameConstants.LAYOUT_5.USER_POS = {{960, 280}       --玩家位置
        , {430, 280}
        , {190, 660}
        , {1730, 660}
        , {1490, 280}
    }


--[[
    9人场布局
]]
GameConstants.LAYOUT_9 = {}
GameConstants.LAYOUT_9.DESK_CARDS_POS = cc.p(0,540) --公共牌坐标
GameConstants.LAYOUT_9.DESK_CARD_SEND_Y = 324       --发牌的位置y坐标
GameConstants.LAYOUT_9.DESK_CHIPS_X = 922           --底池筹码x坐标
GameConstants.LAYOUT_9.DESK_CHIPS_LINE1_Y = 637     --底池筹码第一行
GameConstants.LAYOUT_9.DESK_CHIPS_LINE2_Y = 405     --底池筹码第二行
GameConstants.LAYOUT_9.DESK_TXT_POS = cc.p(0, 443)  --桌面文字位置
GameConstants.LAYOUT_9.USER_SCALE = 1               --玩家node scale
GameConstants.LAYOUT_9.USER_POS = {{960, 270}       --玩家位置
        , {430, 270}
        , {140, 460}
        , {200, 790}
        , {540, 920}
        , {1380, 920}
        , {1720, 790}
        , {1780, 460}
        , {1490, 270}
    }
    
--[[
    牌桌组件层级
--]]
GameConstants.DESK_CARD_Z = 1           --桌牌层级: 由0调整到1，使发牌时盖住筹码
GameConstants.DEALER_Z = 0              --庄家标识层级
GameConstants.CHIP_HEAP_Z = 1           --桌面筹码层级
GameConstants.SPECIAL_CARDTYPE_Z = 2    --特殊牌型层级
GameConstants.LOWER_USER_Z = 2          --比用户层级低的层级
GameConstants.USER_LIST_Z = 3           --用户层级
GameConstants.CARDTYPE_HELP_Z = 5       --牌型介绍层级
GameConstants.MOVEING_Z = 8             --运动时组件的层级
GameConstants.WAITZ = 9                 --等待游戏开始提示层级
GameConstants.DIALOG_Z = 10             --弹窗提示层级
GameConstants.DIALOG2_Z = 11             --弹窗提示层级
GameConstants.MENU_ZORDER = 12          --菜单/聊天框等层级



function GameConstants:ctor()
    self.winSize = cc.Director:getInstance():getWinSize()
    self:adjustByResolution()
end

--根据分辨率自适配
function GameConstants:adjustByResolution()
    --牌桌中线
    self.LAYOUT_COMMON.DESK_POS_X = self.winSize.width / 2 + self.LAYOUT_COMMON.DESK_OFFSET
    --底池文字x坐标
    self.LAYOUT_COMMON.TOTAL_CHIPS_TXT_POS.x = self.LAYOUT_COMMON.DESK_POS_X
    --公共牌x坐标
    self.LAYOUT_5.DESK_CARDS_POS.x = self.LAYOUT_COMMON.DESK_POS_X
    self.LAYOUT_9.DESK_CARDS_POS.x = self.LAYOUT_COMMON.DESK_POS_X
    --底池筹码x坐标
    self.LAYOUT_5.DESK_CHIPS_X = self.LAYOUT_COMMON.DESK_POS_X
    self.LAYOUT_9.DESK_CHIPS_X = self.LAYOUT_COMMON.DESK_POS_X
    --桌面文字
    self.LAYOUT_5.DESK_TXT_POS.x = self.LAYOUT_COMMON.DESK_POS_X
    self.LAYOUT_9.DESK_TXT_POS.x = self.LAYOUT_COMMON.DESK_POS_X
end

----------------UI校验类型-----------------
GameConstants.CHECKUI_USERS = 0         --校验牌桌上的用户
GameConstants.CHECKUI_SHARE_CARDS = 1   --校验公共牌
GameConstants.CHECKUI_HANDCARDS = 2     --校验玩家本人手牌
GameConstants.CHECKUI_CHIPS = 3         --校验底池筹码
GameConstants.CHECKUI_OTHER_HANDCARDS = 4   --检查所有人其他人的手牌UI，没有就加上
function GameConstants:getUICheckTypeDescription(check_type)
    if check_type == GameConstants.CHECKUI_USERS then
        return "牌桌用户"
    elseif check_type == GameConstants.CHECKUI_SHARE_CARDS then
        return "各公共牌"
    elseif check_type == GameConstants.CHECKUI_HANDCARDS then
        return "本人手牌"
    elseif check_type == GameConstants.CHECKUI_CHIPS then
        return "底池筹码"
    elseif check_type == GameConstants.CHECKUI_OTHER_HANDCARDS then
        return "他人手牌"
    else
        return "未知类型"
    end
end

GameConstants.BATTLE_TYPE_NORMAL  = 1; --1经典场 
GameConstants.BATTLE_TYPE_LAIZI = 2;--2.癞子玩法
GameConstants.BATTLE_TYPE_UNSHUFFLE = 3;--3.不洗牌玩法

GameConstants.ShareScene = {
    MAIN = 1,
    GAME = 2,
}
return GameConstants