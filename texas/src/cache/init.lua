
local Config = import(".Config")
local DeskAssemble = import(".desk.Assemble")
local Desk = import(".desk.Desk")
local ActivityTaskInfo = import(".ActivityTaskInfo")
local FriendInfo = import(".FriendInfo")
local RankInfo = import(".RankInfo")
local BeautyInfo = import(".BeautyInfo")
local DaojuInfo = import(".DaojuInfo")
local WordMsg = import(".WordMsg")
local GiftInfo = import(".GiftInfo")
local GlobalInfo = import(".GlobalInfo")
local GamesRecord = import(".GamesRecord")
local FocasInfo = import(".FocasInfo")
local ExchangeMallInfo = import(".ExchangeMallInfo")

local PayManager = import(".pay.PayManager")
local QuickPay = import(".pay.QuickPay")
local InviteInfo = import(".InviteInfo")
local DDZDesk         = import(".desk.DDZDesk")
local DDZconfig   		= import(".DDZConfig")
Cache = Cache or {}

Cache.user = import(".User").new()
Cache.game = {}


Cache.Config = Config.new()
Cache.ActivityTaskInfo = ActivityTaskInfo.new()
Cache.FriendInfo = FriendInfo.new()
Cache.BeautyInfo = BeautyInfo.new()
Cache.focasInfo = FocasInfo.new()
Cache.ExchangeMallInfo = ExchangeMallInfo.new()

Cache.DeskAssemble = DeskAssemble.new()
Cache.desk = Desk.new()
Cache.rank = RankInfo.new()
Cache.daojuInfo = DaojuInfo.new()
Cache.giftInfo = GiftInfo.new()
Cache.wordMsg = WordMsg.new()
Cache.gamesRecord = GamesRecord.new()
Cache.globalInfo = GlobalInfo.new()

Cache.friend = {}
Cache.chat = {}

--商城支付
Cache.PayManager = PayManager.new()
--快捷支付
Cache.QuickPay = QuickPay.new()
Cache.InviteInfo = InviteInfo.new()
--主页有无操作
Cache.MainHaveEvent = false

Cache.DDZconfig   = DDZconfig.new()
Cache.DDZDesk = DDZDesk.new()