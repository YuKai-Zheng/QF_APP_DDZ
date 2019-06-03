local M = {}

local prefix = "game_ddz/"
M.gameViewJson = prefix.."ui/game_ddz.json"--游戏主界面
M.gameEndViewJson = prefix.."ui/game_ddz_result.json"--游戏结算界面
M.gamePlist= prefix.."ui/sk_game/ShuangKou0.plist"
M.gamePng= prefix.."ui/sk_game/ShuangKou0.png"
M.chatViewJson   = prefix.."ui/chat.json"         
M.userInfoJson = prefix.."ui/userinfo.json"         
M.newUserInfoJson = prefix.."ui/new_userinfo.json"	--690新版游戏内个人信息界面
M.matchingEndViewJson = prefix.."ui/game_ddz_begin.json"
M.gameDetailViewJson = prefix.."ui/game_ddz_detail.json"
M.gameMatchingViewJson = prefix.."ui/game_ddz_matching.json"
M.gameEndNormalViewJson = prefix.."ui/game_ddz_classic_result.json"--游戏结算界面
-- M.gameEndNormalViewJson = prefix.."ui/game_ddz_normal_result.json"--游戏结算界面
--牌型
M.gameRuleJson = prefix .. "ui/game_ddz_rule.json"--游戏规则界面
M.poker_bg = prefix .. "card/poker_bg.png"
M.poker_back_bg = prefix .. "card/poker_bg1.png"
M.poker_point = prefix .. "card/poker_%s_%s.png" --点数
M.poker_color_small = prefix .. "card/poker_color_%s_small.png" --花色
M.poker_color_large = prefix .. "card/poker_color_%s_large.png"
M.poker_king = prefix .. "card/poker_color_%s_%s.png" --大小王
M.poker_ming = prefix .. "card/card_show_tag.png"--明牌的图片
M.poker_di_zhu = prefix .. "card/lord_tag.png"--牌的地主图片

--斗地主地主额外扑克倍数
M.cardBetImg = "img_bei_%d.png"
--头像倒计时
M.progresstimer = prefix.."game/game_user_timer.png"

M.game_chatBg =  prefix.."game/game_chat3.png"--聊天显示背景
M.game_chatBg_left =  prefix.."game/game_chat_left.png"--聊天显示背景
M.game_chatBg_right =  prefix.."game/game_chat_right.png"--聊天显示背景
--游戏开始时间
M.gameStartTimebg = prefix.."game/starttimebg.png"
M.gameStartTimeTxt = prefix.."game/starttimetxt.png"
M.gameStartTimeNum = prefix.."game/starttime.png"

--wifi信号强度
M.signalImg = "wifi_%d.png"
--扑克动画
M.ANI_FEIJI = prefix.."armature_anim/airplane/airplane.ExportJson"--飞机
M.ANI_WANGZHA =prefix.."armature_anim/wangzha/wangzha.ExportJson" --王炸
M.ANI_DIZHUWANGGUAN =prefix.."armature_anim/dizhuwangguan/dizhuwangguan.ExportJson" --王冠
M.ANI_XIAODIZHUWANGGUAN =prefix.."armature_anim/xiaodizhuwangguan/xiaodizhuwangguan.ExportJson" --小的王冠
M.ANI_CHANGEHEAD =prefix.."armature_anim/changehead/changehead.ExportJson" --从头像变成斗地主转用icon
M.ANI_SPRINGANIMATION =prefix.."armature_anim/Spring_Animation/Spring_Animation.ExportJson" --王炸
M.ANI_LIANDUI = prefix.."armature_anim/liansanzhang/NewAnimation.ExportJson"--连三张、连对
M.ANI_SHUNZI = prefix.."armature_anim/shunzi/NewAnimation.ExportJson"--顺子
M.shunzi_img1 = prefix .. "armature_anim/shunzi/A2double_shunzi0.png" --顺子
M.shunzi_img2 = prefix .. "armature_anim/shunzi/A2double_shunzitwo0.png" --顺子
M.ANI_ZHADAN = prefix.."armature_anim/zhadan/NewAnimation.ExportJson"--炸弹
M.ZhaDanImg = prefix.."armature_anim/zhadan/A3-bomb.png"
--游戏动画
M.Ani_GameWin = prefix.."armature_anim/winGame/NewAnimation.ExportJson"--赢
M.Ani_GameFail = prefix.."armature_anim/failGame/NewAnimation.ExportJson"--输
M.Ani_endGame = prefix.."armature_anim/endGame/NewAnimation.ExportJson"--游戏结束
M.Ani_PiPei = prefix.."armature_anim/pipei/NewAnimation.ExportJson"--匹配
--切换地主头像
M.DiZhuHead = "img_head_charector_1_0.png"
M.NongMingHead = "img_head_charector_0_%d.png"
--美女入场比心
M.game_big_heart_img = prefix .. "game/game_big_heart.png"
M.game_small_heart_img = prefix .. "game/game_small_heart.png"

--菜单栏
M.menu_Quit = "sk_quit.png"
M.menu_Detail ="sk_rule_img.png"

--结束界面
M.winImg = prefix .. "ui/ddz_game/ddz_result/wintitle2.png"
M.failImg = prefix .. "ui/ddz_game/ddz_result/failtitle2.png"
M.winTitleImg = prefix .. "ui/ddz_game/ddz_result/wintitle1.png"
M.failTitleImg = prefix .. "ui/ddz_game/ddz_result/failtitle1.png"
M.winBgImg = prefix .. "ui/ddz_game/ddz_result/winbg.png"
M.failBgImg = prefix .. "ui/ddz_game/ddz_result/failbg.png"
M.failguangImg = prefix.."ui/ddz_game/ddz_result/failguang.png"
M.classicFailBg = prefix .. "ui/ddz_game/ddz_result/game_classic_result_0.png"
M.classicWinBg = prefix .. "ui/ddz_game/ddz_result/game_classic_result_1.png"

M.failImg1 = prefix .. "ui/ddz_game/ddz_result/fail1.png"
M.winNormalImg = prefix .. "ui/ddz_game/ddz_result/result_normal_win.png"
M.failNormalImg = prefix .. "ui/ddz_game/ddz_result/result_normal_fail.png"
M.resultHead = "ddz_resulthead%d_%d_%d.png"
M.winLevelBg = prefix.."ui/ddz_game/ddz_result/levelbg.png"
M.failLevelBg = prefix.."ui/ddz_game/ddz_result/levelbg1.png"
M.rank_type = {
	"sk_shang_you.png",
	"sk_er_you.png",
	"sk_san_you.png",
	"sk_xia_you.png"
}

--music  0男 1 女--
M.all_music ={
	CHAT_0   = prefix.."sound/chat/chat%d_man.mp3",
	CHAT_1   = prefix.."sound/chat/chat%d_wom.mp3",
	DanPai_0 = prefix.."sound/Man/Card/1_%d.mp3",   --单张
	DanPai_1 = prefix.."sound/Women/Card/1_%d.mp3",
	DuiZi_0 = prefix.."sound/Man/Card/2_%d.mp3",	--对子
	DuiZi_1 = prefix.."sound/Women/Card/2_%d.mp3",
	SanDai_0 = prefix.."sound/Man/Card/px_sange_%d.mp3", --三带（从零开始）
	SanDai_1 = prefix.."sound/Women/Card/px_sange_%d.mp3",
	Sidai_0 = prefix.."sound/Man/Card/px_sidai_2.mp3",	--四带二
	Sidai_1 = prefix.."sound/Women/Card/px_sidai_2.mp3",	
	LianDui_0 = prefix.."sound/Man/Card/px_3_jiemeidui.mp3",	--连对
	LianDui_1 = prefix.."sound/Women/Card/px_3_jiemeidui.mp3",
	Feiji= prefix.."sound/Common/plane.mp3",	--飞机音效
	Feiji_0 = prefix.."sound/Man/Card/px_2_feiji.mp3",-- 飞机
	Feiji_1 = prefix.."sound/Women/Card/px_2_feiji.mp3",
	ShunZi_0 = prefix.."sound/Man/Card/px_4_shunzi.mp3",	--顺子
	ShunZi_1 = prefix.."sound/Women/Card/px_4_shunzi.mp3",
	Guo_0 = prefix.."sound/Man/Card/guo_%d.mp3",	--要不起(为玩家要不起上家牌时，选择过牌时，随机选取一个语音播放语音)
	Guo_1 = prefix.."sound/Women/Card/guo_%d.mp3",
	Ya_0 = prefix.."sound/Man/Card/ya_%d.mp3",	--压死
	Ya_1 = prefix.."sound/Women/Card/ya_%d.mp3",
	Zha_0 = prefix.."sound/Man/Card/zha_%d.mp3",	--炸弹（回合中第几次出现炸弹则显示第几次语音，最高为三）
	Zha_1 = prefix.."sound/Women/Card/zha_%d.mp3",
	Zha= prefix.."sound/Common/boom.mp3",	--炸弹音效
	WangZha= prefix.."sound/Common/rocket.mp3",	--王炸
	--加倍
	Jia_0 = prefix.."sound/Man/Lord/jiabei%d.mp3",
	Jia_1 = prefix.."sound/Women/Lord/jiabei%d.mp3",
	--叫分
	Jiao_0 = prefix.."sound/Man/Lord/jiaofen%d.mp3",
	Jiao_1 = prefix.."sound/Women/Lord/jiaofen%d.mp3",
	--变身
	changeHeadType = prefix.."sound/Common/multiple.mp3",

	MingPai_0 = prefix .. "sound/Man/Lord/mingpai.mp3",
	MingPai_1 = prefix .. "sound/Women/Lord/mingpai.mp3",

	--只剩几张牌了
	CardLeft_0 = prefix.."sound/Man/Card/left_%d.mp3",
	CardLeft_1 = prefix.."sound/Women/Card/left_%d.mp3",

	Zha_Dur =  prefix.."sound/boom.mp3", --播放炸弹动画时需要播放的
	Plane_Dur =  prefix.."sound/boom.mp3", --播放飞机动画时需要播放的
	Rocket_Dur =  prefix.."sound/boom.mp3", --播放火箭动画时需要播放的

	--抢地主 (1.不叫 2.叫地主 3.不抢 4.抢地主)
	ToBeLord_0 = {
		[1] = prefix.."sound/Man/Lord/jiaofen0.mp3",  --不叫
		[2] = prefix.."sound/Man/Lord/call_dizhu.mp3",  --叫地主
		[3] = prefix.."sound/Man/Lord/not_rob.mp3", --不抢
		[4] = prefix.."sound/Man/Lord/rob_dizhu.mp3", --抢地主
	},
	ToBeLord_1 = {
		[1] = prefix.."sound/Women/Lord/jiaofen0.mp3",  --不叫
		[2] = prefix.."sound/Women/Lord/call_dizhu.mp3",  --叫地主
		[3] = prefix.."sound/Women/Lord/not_rob.mp3", --不抢
		[4] = prefix.."sound/Women/Lord/rob_dizhu.mp3", --抢地主
	},

	gameMusic = prefix.."sound/bgm_game_%d.mp3", --bgm （3.出现报单、报双 2.出现炸弹后30s 1.正常情况）
	BtnClick = prefix .. "sound/Common/btnClick.mp3", --按钮点击
	GetHandCard = prefix .. "sound/Common/getHandCard.mp3", --玩家获得手牌
	OutCardToDesk = prefix .. "sound/Common/outCardToDesk.mp3", --玩家出牌到桌子
	Overtime = prefix .. "sound/Common/overtime.mp3", --出牌超时，倒计时3s
	ShuffleCard = prefix .. "sound/Common/shuffleCard.mp3", --洗牌
	gameOver = prefix .. "sound/Result/game_result_%d.mp3", --游戏结束
    gameStart = prefix .. "sound/Common/start.mp3", --游戏开始
    fapai = prefix .. "sound/Common/fapai.mp3", --发牌
}

M.changci_1 = "gamehall__0005_01.png"  --新手场
M.changci_2 = "gamehall__0004_02.png"  --初级场
M.changci_3 = "gamehall__0003_03.png"  --中级场
M.changci_4 = "gamehall__0002_04.png"  --高级场
M.changci_5 = "gamehall__0001_05.png"  --伯爵场
M.changci_6 = "gamehall__0000_06.png"  --尊爵场
--加倍自定义字体
M.doubleFont1 = prefix .."ui/ddz_game/fnt-export3.fnt"
M.doubleFont2 = prefix .."ui/ddz_game/fnt-export2.fnt"
M.superMutilAni = prefix .. "armature_anim/superMutil/NewAnimation.ExportJson"

--简单的匹配动画
M.simpleMathgingSuccess = prefix .. "armature_anim/matchSuccess/wenzi.ExportJson"
M.matchingAnimation = prefix .. "armature_anim/headmathing/guiangquan.ExportJson"
--匹配界面头像
M.mathingHeadImg0 = prefix.."ui/matching/matching_head_default.png"
M.mathingHeadImg1 = prefix.."ui/matching/math_head_%d.png"
--结算奖励
M.resultReward_0 = prefix.."ui/ddz_game/ddz_result/norewared.png"
M.resultReward_1 = prefix.."ui/userinfo/jinbi.png"
M.resultReward_2 = prefix.."ui/ddz_game/ddz_result/kf_icon.png"

M.rewardTitle_1 = prefix.."ui/ddz_game/ddz_result/currentAward.png"
M.rewardTitle_2 = prefix.."ui/ddz_game/ddz_result/exitGame_fuli.png"

M.matchingHallViewJson = "ui/matchingHallView_1.json"

M.deskNameImg1 = "bisaichang.png"
M.goldImg = "Front-hall_0019_14.png"

M.resultScoreFont1 = prefix.."ui/ddz_game/ddz_result/result-export1.fnt"
M.resultScoreFont2 = prefix.."ui/ddz_game/ddz_result/result-export2.fnt"

--比赛结束等级动画
M.jiangXingAni = prefix.."armature_anim/jiangxing/NewAnimation.ExportJson"--降星动画
M.jiaXingAni = prefix.."armature_anim/jiaxing/NewAnimation.ExportJson"--加星动画
M.jiangJiTxtAni = prefix.."armature_anim/jiangjitxt/NewAnimation.ExportJson"--降级文字动画
M.jinJiTxtAni = prefix.."armature_anim/jinjitxt/NewAnimation.ExportJson"--晋级文字动画
M.levelOutAni = prefix.."armature_anim/levelout/NewAnimation.ExportJson"--弹出动画
M.levelNormalAni = prefix.."armature_anim/levelnormal/NewAnimation.ExportJson"--流光动画
M.jinJiAni = prefix.."armature_anim/jinji/NewAnimation.ExportJson"--晋级动画
--彩带
M.caiDai = prefix.."ui/ddz_game/ddz_result/panel_ljdjl_sd%d.png"
M.menuP_large = prefix .. "ui/ddz_game/menuP_large.png"

M.chat_emojiImg = prefix.."ui/chat/lookon/emoji.png"
M.chat_emoji1Img = prefix.."ui/chat/lookon/emoji1.png"
M.chat_chatImg = prefix.."ui/chat/lookon/chat.png"
M.chat_chat1Img = prefix.."ui/chat/lookon/chat1.png"
M.chat_historyImg = prefix.."ui/chat/lookon/history.png"
M.chat_history1Img = prefix.."ui/chat/lookon/history1.png"
M.chat_othersImg = prefix.."ui/chat/lookon/others.png"
M.chat_others1Img = prefix.."ui/chat/lookon/others1.png"
M.chatPointImg = prefix.."ui/chat/lookon/tips.png"

M.matchingGameResult_tag = prefix.."ui/ddz_game/matchingGameResult_tag%d.png"
M.matchingGameResult_last = prefix.."ui/ddz_game/matchingGameResult_last.png"
M.matchingGameResult_tagTotal = prefix.."ui/ddz_game/matchingGameResult_tagTotal.png"

M.matchingGameResult_itembg1 = prefix.."ui/ddz_game/matchingGameResult_itembg1.png"
M.matchingGameResult_itembg2 = prefix.."ui/ddz_game/matchingGameResult_itembg2.png"

--剩余牌预警
M.cardOverWarning = prefix.."armature_anim/cardoverwarning/deng.ExportJson"

M.PoChan = prefix.."ui/ddz_game/ddz_result/PoChan.png"
M.fengDing = prefix.."ui/ddz_game/ddz_result/fengDing.png"

M.poker_send_bg = prefix .. "ui/ddz_game/poker_send_bg.png"

M.doudizhu_Plist = prefix .. "ui/ddz_game/doudizhu.plist"
M.doudizhu_Png = prefix .. "ui/ddz_game/doudizhu.png"

M.ddz_game_bg = prefix .. "ui/ddz_game/ddz_game_bg.png"

M.preloadImg = {
    prefix .. "ui/ddz_game/fnt-export1.png",
    prefix .. "ui/ddz_game/action_font_5.png",
    prefix .. "ui/ddz_game/fnt-export3.png",
    prefix .. "ui/ddz_game/qw-export.png",
    prefix .. "ui/ddz_game/action_font4.png",
    prefix .. "ui/ddz_game/poker_send_bg.png",
    prefix .. "ui/ddz_game/fnt-export4.png",
    prefix .. "ui/ddz_game/action_font3.png",
    prefix .. "ui/ddz_game/fnt-export2.png",
    prefix .. "ui/ddz_game/gameNumexport.png",
    prefix .. "ui/ddz_game/lan_se_num.png",
    prefix .. "ui/ddz_game/huang_se_num.png",
    prefix .. "ui/ddz_game/chat_btn.png",
    prefix .. "ui/ddz_game/action_font2.png",
    prefix .. "ui/ddz_game/gameinfo.png",
    prefix .. "ui/ddz_game/matchingGameResult_tagTotal.png",
    prefix .. "ui/ddz_game/fan_font.png",
    prefix .. "ui/ddz_game/ddz_num_font.png",
    prefix .. "ui/ddz_game/timer_font.png",
    prefix .. "ui/ddz_game/menuP_large.png",
    prefix .. "ui/ddz_game/action_font_6.png",
    prefix .. "ui/ddz_game/matchingGameResult_itembg2.png",
    prefix .. "ui/ddz_game/bai_se_num.png",
}

M.global_TouMing_Png = prefix .. "ui/global/global_touming_bg.png"

M.gameover_score_fnt1 = prefix .. "ui/ddz_game/font_gameover1.fnt"
M.gameover_score_fnt2 = prefix .. "ui/ddz_game/font_gameover2.fnt"

M.global_card_record_tip = prefix .. "ui/global/card_record_tip.png"
M.global_card_multi_tip = prefix .. "ui/global/card_multi_tip.png"
M.global_coin_icon = prefix .. "ui/global/coin_icon.png"
M.global_kf_icon = prefix .. "ui/global/kf_icon.png"

M.gameTask_txt = {
    "txt_gameTask_1.png","txt_gameTask_2.png"
}

M.img_jiabei = {
    [1] = "doudizhu_img_double.png",
    [2] = "doudizhu_img_superdouble.png"
}

M.poker_point_color_large = prefix .. "card/poker_%s_cokor_%s.png"

M.match_level_animation_json = prefix .. "armature_anim/matchLevelAnimation/NewAnimationAPP190117duanwei1.ExportJson"
M.match_wangzhe_animation_json = prefix .. "armature_anim/matchLevelAnimation/NewAnimation190118wangzhe.ExportJson"

M.matchLevelAnimation_icon = "match_level_icon_%s.png"
M.matchLevelAnimation_wing = "match_level_%s_%s.png"
M.matchLevelAnimation_bottom = "match_level_bottom_%s.png"

M.matchLevelAnimation_PLIST= prefix .. "ui/matchLevelAnimation/matchLevelAnimation.plist"
M.matchLevelAnimation_PNG= prefix .. "ui/matchLevelAnimation/matchLevelAnimation.png"

M.matchLevel_bottom_fnt = prefix .. "ui/matchLevelAnimation/matchLevel_bottom_fnt_%s.fnt"
M.wangzheStarNum = prefix .. "ui/matchLevelAnimation/wangzheStar_num_fnt.fnt"

M.eventGameEndViewJson = prefix .. "ui/game_ddz_new_match_result.json"

M.match_result_win = {
    BG = prefix .. "ui/ddz_game/ddz_match_result/result_win_bg.png",
    TIP = "ui/ddz_game/ddz_match_result/result_txt_win.png",
    HEAD_BG = prefix .. "ui/ddz_game/ddz_match_result/result_win_head_bg.png",
    FNT = prefix .. "ui/ddz_game/ddz_match_result/result_win_reward_title_fnt.fnt",
}

M.match_result_fail = {
    BG = prefix .. "ui/ddz_game/ddz_match_result/result_fail_bg.png",
    TIP = "ui/ddz_game/ddz_match_result/result_txt_fail.png",
    HEAD_BG = prefix .. "ui/ddz_game/ddz_match_result/result_fail_head_bg.png",
    FNT = prefix .. "ui/ddz_game/ddz_match_result/result_fail_reward_title_fnt.fnt",
}

M.match_result_btn = {
    prefix .. "ui/ddz_game/ddz_match_result/result_txt_confirm.png",
    prefix .. "ui/ddz_game/ddz_match_result/result_txt_giveup.png",
    prefix .. "ui/ddz_game/ddz_match_result/result_txt_share.png",
    prefix .. "ui/ddz_game/ddz_match_result/result_txt_savestar.png"
}

M.matchBoxViewJson = prefix .. "ui/game_ddz_box.json"
M.boxAnimationJson = prefix .. "armature_anim/boxanimation/NewAnimation190124baoxiang.ExportJson"

M.match_xingxing = prefix .. "ui/matchLevelAnimation/match_xingxing.png"
M.match_xingxing_bg = prefix .. "ui/matchLevelAnimation/match_xingxing_bg.png"

M.img_tuoguanBtn = {"btn_auto.png", "btn_auto_ing.png"}

M.end_win_lord = prefix .. "ui/ddz_game/ddz_result/lord_win.png"
M.end_lose_lord = prefix .. "ui/ddz_game/ddz_result/lord_lose.png"
M.end_win_farmer = prefix .. "ui/ddz_game/ddz_result/farmer_win.png"
M.end_lose_farmer = prefix .. "ui/ddz_game/ddz_result/farmer_lose.png"

M.gameExitViewJson = prefix .. "ui/game_ddz_exit.json"

M.InteractivePressive = {
	prefix .. "ui/InteractiveExpression/hdbq_0005_01.png",
	prefix .. "ui/InteractiveExpression/hdbq_0004_03.png",
	prefix .. "ui/InteractiveExpression/hdbq_0000_06.png",
	prefix .. "ui/InteractiveExpression/hdbq_0006_03.png",
	prefix .. "ui/InteractiveExpression/hdbq_0003_03.png",
	prefix .. "ui/InteractiveExpression/hdbq_0001_05.png",
}

M.beishu_fnt = prefix .. "ui/ddz_game/game_beishu_num_fnt.fnt"


DDZ_Res = {}
DDZ_Res = M