
local M = {}

local prefix = ""

--[[json文件路径start]]

-- M.gameShopJson = prefix.."ui/game_shop_layout.json"--  游戏内商城json文件
M.gameShop180Json = prefix .. "ui/game_shop_of_180.json" -- 游戏内商城Json
M.mohubg = prefix .. "share/common/mohuBg.png" -- 模糊背景

M.userInfoJson = prefix .. "ui/userinfo.json"--  个人信息界面json文件
M.broadcastJson = prefix .. "ui/broadcast.json"--  广播json文件
M.bankruptcyJson = prefix .. "ui/bankruptcy_1.json"--  领取救济金界面json文件
M.globalPromit = prefix .. "ui/globalPromit.json"-- 公共提示框
M.shopPromitJson = prefix .. "ui/shop_promit_layout.json"--  确认购买界面json文件
M.shopPromit1Json = prefix .. "ui/LackGold.json"--  快充界面json文件
M.taskFinishJson = prefix .. "ui/task_finish.json"--  完成任务界面json文件


-- M.mainViewJson = prefix.."ui/main_1.json"--  主界面json文件
M.mainViewJson = prefix .. "ui/hall_1.json"--  主界面json文件
M.mainViewReviewJson = prefix .. "ui/hallreview_1.json"--  主界面json文件
M.dayRewardJson = prefix .. "ui/dayreward.json"--  签到界面json文件
M.rewardViewJson = prefix .. "ui/reward.json"--  奖励界面json文件
M.focaTaskViewJson = prefix .. "ui/focaTask.json"--  奖券任务界面json文件
M.settingViewJson = prefix .. "ui/setting_1.json"--  设置界面json文件
M.aboutViewJson = prefix .. "ui/about.json"--  关于界面json文件
M.agreementViewJson = prefix .. "ui/agreement.json"--  用户协议界面json文件
M.privacyViewJson = prefix .. "ui/privacy.json"--  隐私策略界面json文件
M.shopOfBestDesignJson = prefix .. "ui/shop_of_best_design.json"--  商城界面json文件
--商城loading动画
M.ShopLoadingAni = prefix .. "share/animation/shopLoadingTips/shoploading.ExportJson"--  商城界面json文件

M.shopGoodDetailJson = prefix .. "ui/shop_good_detail.json" -- 商城物品描述
M.shopVipDetailJson = prefix .. "ui/shop_vip_detail.json" -- 商城VIP描述
M.shopBuyPopupTipJson = prefix .. "ui/shop_buy_popup_tip.json" -- 购买弹出框
M.shopPayMethodJson = prefix .. "ui/shop_pay_method.json" -- 支付方式框
M.shopExchangePhoneJson = prefix .. "ui/shop_exchange_phone.json" -- 兑换话费框
M.shopGoldCard = prefix .. "ui/shop/jinka.png"--金卡
M.shopSilverCard = prefix .. "ui/shop/yingkaimg.png"--银卡

M.pcLoginJson = prefix .. "ui/pcLogin_1.json" -- pc登录
M.loginLayoutJson = prefix .. "ui/loginLayout.json"--login界面
M.versionUpdate = prefix .. "ui/versionUpdate.json"--版本更新界面

M.DaojuJson = prefix .. "ui/Daoju_1.json"--  道具界面json文件
M.Daoju_detailJson = prefix .. "ui/Daoju_detail.json"--  道具界面json文件

M.gift = prefix .. "ui/gift.json"--  礼物界面json文件
M.WordMsgJson = prefix .. "ui/world_msg.json"--  世界广播json文件
M.cancellationJson = prefix .. "ui/cancellation.json"--注销确认界面

M.scoreExchangeJson = prefix .. "ui/exchange.json"--积分兑换窗口

M.ActiveNoticeJson = prefix .. "ui/active_notice.json"--活动公告
M.CommonTipJson = prefix .. "ui/common_tips.json"--二次确认
M.hotUpdateJson = prefix .. "ui/hot_update.json" --热更新
M.bueatyAnimate = prefix .. "share/animation/loding_dh01/loding_dh01.ExportJson"

M.photoNodeJson = prefix .. "ui/photo_node.json"--相册节点
M.galleryJson = prefix .. "ui/Gallery_1.json"--相册节点
M.photoBigNodeJson = prefix .. "ui/photo_big_node.json"--相册节点
M.galleryPageViewJson = prefix .. "ui/gallery_pageview_layout.json"--美女相册pageview 节点
--实名认证页面
M.realNameJson = prefix .. "ui/realName.json"
M.shareGameResultJson = prefix .. "ui/share_game_result.json" --游戏结果分享
M.shareGoodExchangeJson = prefix .. "ui/share_match_exchange_result.json" --兑换结果分享


--[[json文件路径end]]

--[[提前加载图片 start]]
M.preLoadingImg = {
    prefix .. "ui/global/global_dialog_bg.png", 
    prefix .. "share/animation/reward_coin/reward_gold_01.png", 
    prefix .. "share/animation/reward_coin/reward_gold_02.png", 
    prefix .. "share/animation/reward_coin/reward_gold_03.png", 
    prefix .. "share/animation/reward_coin/reward_gold_04.png", 
    prefix .. "share/animation/reward_coin/reward_gold_05.png", 
    prefix .. "share/animation/reward_coin/reward_gold_06.png", 
    prefix .. "share/animation/reward_coin/reward_gold_07.png", 
    prefix .. "ui/global/global_dialog_close.png", 
}
--[[提前加载图片end]]

--破产补助小汽车
M.bankruptcyCar = prefix .. "ui/bankruptcy/pcbz_01_1%d.png"

--[[动画文件路径]]
M.gameChatPlist = prefix .. "ui/game_chat/gameChat.plist" --表情动画plist文件
M.gameChatNoblePlist = prefix .. "ui/game_chat/gameChatNoble.plist" --贵族表情动画plist文件
--[[动画文件路径]]

M.res001 = prefix .. "ui/playgame/game_user_timer.png"

M.res002 = prefix .. "share/animation/fanpai01.png"
M.res003 = prefix .. "share/animation/fanpai02.png"
M.res004 = prefix .. "share/animation/fanpai03.png"
M.res005 = prefix .. "share/animation/fanpai04.png"
M.res006 = prefix .. "share/animation/fanpai05.png"
M.res007 = prefix .. "share/animation/fanpai06.png"

M.res020 = prefix .. "ui/playgame/game_num_font.png"
M.res021 = prefix .. "ui/playgame/game_num_unit1.png"
M.res022 = prefix .. "ui/playgame/game_three_mutil_blind_font.png"
M.res023 = prefix .. "ui/playgame/game_small_fllow_font.png"
M.res024 = prefix .. "ui/playgame/game_num_unit2.png"




M.chips_shadow_yellow_img = prefix .. "share/chips/chips_shadow_yellow_img.png"
M.chips_yellow_img = prefix .. "share/chips/chips_yellow_img.png"
M.chips_shadow_orange_img = prefix .. "share/chips/chips_shadow_orange_img.png"
M.chips_orange_img = prefix .. "share/chips/chips_orange_img.png"
M.chips_shadow_black_img = prefix .. "share/chips/chips_shadow_black_img.png"
M.chips_black_img = prefix .. "share/chips/chips_black_img.png"
M.chips_shadow_purple_img = prefix .. "share/chips/chips_shadow_purple_img.png"
M.chips_purple_img = prefix .. "share/chips/chips_purple_img.png"
M.chips_shadow_red_img = prefix .. "share/chips/chips_shadow_red_img.png"
M.chips_red_img = prefix .. "share/chips/chips_red_img.png"
M.chips_shadow_green_img = prefix .. "share/chips/chips_shadow_green_img.png"
M.chips_green_img = prefix .. "share/chips/chips_green_img.png"
M.chips_shadow_blue_img = prefix .. "share/chips/chips_shadow_blue_img.png"
M.chips_blue_img = prefix .. "share/chips/chips_blue_img.png"

M.chip_03 = prefix .. "share/chips/chip_03.png"
M.chip_04 = prefix .. "share/chips/chip_04.png"
M.chip_05 = prefix .. "share/chips/chip_05.png"


M.poker_f01 = prefix .. "share/poker/poker_f01.png"
M.poker_f02 = prefix .. "share/poker/poker_f02.png"
M.poker_f03 = prefix .. "share/poker/poker_f03.png"
M.poker_f04 = prefix .. "share/poker/poker_f04.png"
M.poker_f05 = prefix .. "share/poker/poker_f05.png"
M.poker_f06 = prefix .. "share/poker/poker_f06.png"
M.poker_f07 = prefix .. "share/poker/poker_f07.png"
M.poker_f08 = prefix .. "share/poker/poker_f08.png"
M.poker_f09 = prefix .. "share/poker/poker_f09.png"
M.poker_f10 = prefix .. "share/poker/poker_f10.png"
M.poker_f11 = prefix .. "share/poker/poker_f11.png"
M.poker_f12 = prefix .. "share/poker/poker_f12.png"
M.poker_f13 = prefix .. "share/poker/poker_f13.png"
M.poker_h01 = prefix .. "share/poker/poker_h01.png"
M.poker_h02 = prefix .. "share/poker/poker_h02.png"
M.poker_h03 = prefix .. "share/poker/poker_h03.png"
M.poker_h04 = prefix .. "share/poker/poker_h04.png"
M.poker_h05 = prefix .. "share/poker/poker_h05.png"
M.poker_h06 = prefix .. "share/poker/poker_h06.png"
M.poker_h07 = prefix .. "share/poker/poker_h07.png"
M.poker_h08 = prefix .. "share/poker/poker_h08.png"
M.poker_h09 = prefix .. "share/poker/poker_h09.png"
M.poker_h10 = prefix .. "share/poker/poker_h10.png"
M.poker_h11 = prefix .. "share/poker/poker_h11.png"
M.poker_h12 = prefix .. "share/poker/poker_h12.png"
M.poker_h13 = prefix .. "share/poker/poker_h13.png"
M.poker_m01 = prefix .. "share/poker/poker_m01.png"
M.poker_m02 = prefix .. "share/poker/poker_m02.png"
M.poker_m03 = prefix .. "share/poker/poker_m03.png"
M.poker_m04 = prefix .. "share/poker/poker_m04.png"
M.poker_m05 = prefix .. "share/poker/poker_m05.png"
M.poker_m06 = prefix .. "share/poker/poker_m06.png"
M.poker_m07 = prefix .. "share/poker/poker_m07.png"
M.poker_m08 = prefix .. "share/poker/poker_m08.png"
M.poker_m09 = prefix .. "share/poker/poker_m09.png"
M.poker_m10 = prefix .. "share/poker/poker_m10.png"
M.poker_m11 = prefix .. "share/poker/poker_m11.png"
M.poker_m12 = prefix .. "share/poker/poker_m12.png"
M.poker_m13 = prefix .. "share/poker/poker_m13.png"
M.poker_r01 = prefix .. "share/poker/poker_r01.png"
M.poker_r02 = prefix .. "share/poker/poker_r02.png"
M.poker_r03 = prefix .. "share/poker/poker_r03.png"
M.poker_r04 = prefix .. "share/poker/poker_r04.png"
M.poker_r05 = prefix .. "share/poker/poker_r05.png"
M.poker_r06 = prefix .. "share/poker/poker_r06.png"
M.poker_r07 = prefix .. "share/poker/poker_r07.png"
M.poker_r08 = prefix .. "share/poker/poker_r08.png"
M.poker_r09 = prefix .. "share/poker/poker_r09.png"
M.poker_r10 = prefix .. "share/poker/poker_r10.png"
M.poker_r11 = prefix .. "share/poker/poker_r11.png"
M.poker_r12 = prefix .. "share/poker/poker_r12.png"
M.poker_r13 = prefix .. "share/poker/poker_r13.png"

M.font1 = "Arial"

--youxi/ chat chat--
M.game_chat1 = prefix .. "ui/game_chat/game_chat1.png"
M.game_chat2 = prefix .. "ui/game_chat/game_chat2.png"
M.game_chat1_big = prefix .. "ui/game_chat/game_chat1_big.png"
M.game_chat2_big = prefix .. "ui/game_chat/game_chat2_big.png"
--youxi/ chat end--
--global start--
M.default_man_icon = prefix .. "ui/global/global_default_icon01.png"
M.default_girl_icon = prefix .. "ui/global/global_default_icon02.png"
M.default_man_large_icon = prefix .. "ui/global/global_default_large_icon01.png"
M.default_girl_large_icon = prefix .. "ui/global/global_default_large_icon02.png"
M.default_sq_man_icon = prefix .. "ui/hall/default_icon_60_1.png"
M.default_sq_girl_icon = prefix .. "ui/hall/default_icon_60_2.png"
M.rank_money_img = prefix .. "ui/global/global_money_img.png"
M.shop_item_2 = prefix .. "ui/global/shop_item_bg01.png"
M.shop_item_6 = prefix .. "ui/global/shop_item_bg02.png"
M.shop_item_10 = prefix .. "ui/global/shop_item_bg03.png"
M.shop_item_20 = prefix .. "ui/global/shop_item_bg04.png"
M.shop_item_50 = prefix .. "ui/global/shop_item_bg05.png"
M.shop_item_100 = prefix .. "ui/global/shop_item_bg06.png"
M.shop_item_200 = prefix .. "ui/global/shop_item_bg07.png"
M.shop_item_400 = prefix .. "ui/global/shop_item_bg08.png"
M.shop_car = prefix .. "ui/shop/img_car_icon_%d.png"
M.shop_gold = prefix .. "ui/shop/gold_%d.png"
M.shop_diamond = prefix .. "ui/shop/img_buy_diamond_%d.png"
M.shop_gold_suffix = prefix .. "ui/shop/img_suffix_2.png"
M.shop_white_gold_word = prefix .. "ui/shop/img_txt_white_gold.png"
M.shop_white_rmb_unit = prefix .. "ui/shop/img_icon.png"
M.shop_bookmark_gold = prefix .. "ui/shop/img_bookmark_gold.png"
M.shop_bookmark_gold_sel = prefix .. "ui/shop/img_bookmark_gold_sel.png"
M.shop_bookmark_diamond = prefix .. "ui/shop/img_bookmark_diamond.png"
M.shop_bookmark_diamond_sel = prefix .. "ui/shop/img_bookmark_diamond_sel.png"
M.shop_bookmark_props = prefix .. "ui/shop/img_bookmark_props.png"
M.shop_bookmark_props_sel = prefix .. "ui/shop/img_bookmark_props_sel.png"
M.shop_bookmark_exchange = prefix .. "ui/shop/img_bookmark_exchange.png"
M.shop_bookmark_exchange_sel = prefix .. "ui/shop/img_bookmark_exchange_sel.png"
M.shop_title_gift_card = prefix .. "ui/shop/img_title_gift_card.png" -- 礼物卡
M.shop_title_week_card = prefix .. "ui/shop/img_title_week_card.png" -- 周卡
M.shop_title_month_card = prefix .. "ui/shop/img_title_month_card.png" -- 月卡
M.shop_title_poker_face = prefix .. "ui/shop/img_title_poker_face.png" -- pokerface
M.shop_title_week_vip = prefix .. "ui/shop/img_title_month_card.png" -- 周VIP
M.shop_title_month_vip = prefix .. "ui/shop/img_title_month_card.png" -- 月VIP
M.shop_title_pay_method = prefix .. "ui/shop/img_title_pay_method.png" -- 支付方式
M.shop_title_buy_gold = prefix .. "ui/shop/img_title_buy_gold.png" -- 购买金币
M.shop_title_buy_props = prefix .. "ui/shop/img_title_buy_props.png" -- 购买道具
M.shop_title_tip = prefix .. "ui/shop/img_title_tip.png" -- 温馨提示

M.game_shop_item_6 = prefix .. "ui/gameShop/game_shop_item_coin_1.png"
M.game_shop_item_10 = prefix .. "ui/gameShop/game_shop_item_coin_2.png"
M.game_shop_item_20 = prefix .. "ui/gameShop/game_shop_item_coin_3.png"

M.global_forbid_btn = prefix .. "ui/global/global_btn_gray.png"
M.global_allow_btn = prefix .. "ui/global/global_btn.png"
M.global_purple_btn = prefix .. "ui/global/btn_normal_351x113_n.png"
--global end--

--setting start
M.setabout_head_img = prefix .. "ui/setting/setabout_head_img.png" --关于
--setting end

--activity start
M.activity_head = prefix .. "ui/activity/promotion_word_img.png" --活动
M.activity_status1 = prefix .. "ui/activity/xtk__0005_006.png" --活动火爆
M.activity_status2 = prefix .. "ui/activity/xtk__0004_007.png" --活动最新
M.activity_status3 = prefix .. "ui/activity/xtk__0003_008.png" --活动限时
--activity end

M.global_wait_bg = prefix .. "ui/global/global_wait_bg.png"
M.login_chips_1 = prefix .. "share/chips/login_chips1.png"
M.login_chips_2 = prefix .. "share/chips/login_chips2.png"
M.login_chips_3 = prefix .. "share/chips/login_chips3.png"
M.login_golds_1 = prefix .. "share/chips/login_golds1.png"
M.login_golds_2 = prefix .. "share/chips/login_golds2.png"
M.login_golds_3 = prefix .. "share/chips/login_golds3.png"
M.login_golds_4 = prefix .. "share/chips/login_golds4.png"
M.bankruptcy_btn_tag = prefix .. "ui/bankruptcy/bankruptcy_btn_tag.png"
M.login_chip_shadow = prefix .. "share/chips/chip_shadow.png"

M.manicon = prefix .. "ui/global/userinfo_man_sign.png"
M.womenicon = prefix .. "ui/global/userinfo_woman_sign.png"

M.user_default0 = prefix .. "ui/global/default_icon_60_1.png"
M.user_default1 = prefix .. "ui/global/default_icon_60_2.png"
M.user_round_default0 = prefix .. "ui/global/global_default_icon01.png"
M.user_round_default1 = prefix .. "ui/global/global_default_icon02.png"

M.game_waite_bg = prefix .. "ui/global/bg_login.png"

M.reward_goon_btn = prefix .. "ui/reward/reward_goon_btn.png"
M.reward_have_btn = prefix .. "ui/reward/reward_have_finish.png"
M.reward_get_btn = prefix .. "ui/reward/reward_get_btn.png"
M.reward_type_1 = prefix .. "ui/newUserDailyReward/reward_coin.png"
M.reward_type_2 = prefix .. "ui/newUserDailyReward/reward_foca_less.png"
M.reward_type_3 = prefix .. "ui/newUserDailyReward/card_record_tip.png"
M.reward_get_type_1 = prefix .. "ui/reward/_0008_Gold.png"
M.reward_get_type_2 = prefix .. "ui/Focas/kf_icon.png"
--changeuserinfo start
M.ok_word_img = prefix .. "ui/global/ok_word_img.png"
M.local_upload_word_img = prefix .. "ui/change_userinfo/local_upload_word_img.png"
M.photograph_word_img = prefix .. "ui/change_userinfo/photograph_word_img.png"
--changeuserinfo en


M.gift_0_0 = prefix .. "share/animation/giftAnimation/gift_flower_1.png"
M.gift_0_1 = prefix .. "share/animation/giftAnimation/gift_flower_2.png"
M.gift_0_2 = prefix .. "share/animation/giftAnimation/gift_flower_3.png"
M.gift_0_3 = prefix .. "share/animation/giftAnimation/gift_flower_4.png"
M.gift_0_4 = prefix .. "share/animation/giftAnimation/gift_flower_5.png"
M.gift_0_5 = prefix .. "share/animation/giftAnimation/gift_flower_6.png"
M.gift_0_6 = prefix .. "share/animation/giftAnimation/gift_flower_7.png"
M.gift_0_7 = prefix .. "share/animation/giftAnimation/gift_flower_8.png"
M.gift_0_8 = prefix .. "share/animation/giftAnimation/gift_flower_9.png"

M.gift_2_0 = prefix .. "share/animation/giftAnimation/gift_car_1.png"
M.gift_2_1 = prefix .. "share/animation/giftAnimation/gift_car_2.png"
M.gift_2_2 = prefix .. "share/animation/giftAnimation/gift_car_3.png"
M.gift_2_3 = prefix .. "share/animation/giftAnimation/gift_car_4.png"
M.gift_2_4 = prefix .. "share/animation/giftAnimation/gift_car_5.png"
M.gift_2_5 = prefix .. "share/animation/giftAnimation/gift_car_6.png"
M.gift_2_6 = prefix .. "share/animation/giftAnimation/gift_car_7.png"
M.gift_2_7 = prefix .. "share/animation/giftAnimation/gift_car_8.png"
M.gift_2_8 = prefix .. "share/animation/giftAnimation/gift_car_9.png"
M.gift_2_9 = prefix .. "share/animation/giftAnimation/gift_car_10.png"
M.gift_2_10 = prefix .. "share/animation/giftAnimation/gift_car_11.png"

M.gift_1_0 = prefix .. "share/animation/giftAnimation/gift_egg_1.png"
M.gift_1_1 = prefix .. "share/animation/giftAnimation/gift_egg_2.png"
M.gift_1_2 = prefix .. "share/animation/giftAnimation/gift_egg_3.png"
M.gift_1_3 = prefix .. "share/animation/giftAnimation/gift_egg_4.png"
M.gift_1_4 = prefix .. "share/animation/giftAnimation/gift_egg_5.png"
M.gift_1_5 = prefix .. "share/animation/giftAnimation/gift_egg_6.png"
M.gift_1_6 = prefix .. "share/animation/giftAnimation/gift_egg_7.png"
M.gift_1_7 = prefix .. "share/animation/giftAnimation/gift_egg_8.png"
M.gift_1_8 = prefix .. "share/animation/giftAnimation/gift_egg_9.png"
M.gift_1_9 = prefix .. "share/animation/giftAnimation/gift_egg_10.png"
M.gift_1_10 = prefix .. "share/animation/giftAnimation/gift_egg_11.png"

M.gift_0 = prefix .. "ui/global/gift01.png"
M.gift_1 = prefix .. "ui/global/gift02.png"
M.gift_2 = prefix .. "ui/global/gift03.png"
M.gift_3 = prefix .. "ui/global/gift04.png"
M.gift_4 = prefix .. "ui/global/gift05.png"
M.gift_5 = prefix .. "ui/global/gift06.png"

-- gift end



M.reward_gold_01 = prefix .. "share/animation/reward_coin/reward_gold_01.png"
M.reward_gold_02 = prefix .. "share/animation/reward_coin/reward_gold_02.png"
M.reward_gold_03 = prefix .. "share/animation/reward_coin/reward_gold_03.png"
M.reward_gold_04 = prefix .. "share/animation/reward_coin/reward_gold_04.png"
M.reward_gold_05 = prefix .. "share/animation/reward_coin/reward_gold_05.png"
M.reward_gold_06 = prefix .. "share/animation/reward_coin/reward_gold_06.png"
M.reward_gold_07 = prefix .. "share/animation/reward_coin/reward_gold_07.png"
M.reward_gold_08 = prefix .. "share/animation/reward_coin/reward_gold_08.png"
M.reward_gold_09 = prefix .. "share/animation/reward_coin/reward_gold_09.png"


M.shop_title = prefix .. "ui/shop/shop_word.png"
M.shop_ok = prefix .. "ui/shop/exchange_ok.png"
M.shop_send = prefix .. "ui/shop/shop_send.png"
M.shop_txt = prefix .. "ui/shop/shop_buy_txt2.png"
M.shop_number = prefix .. "ui/shop/shop_number.png"
M.shop_sell_img1 = prefix .. "ui/shop/img_label_recommend.png"
M.shop_sell_img2 = prefix .. "ui/shop/img_label_best_sell.png"
M.shop_sell_img3 = prefix .. "ui/shop/top_shop.png"

M.toast_bg = prefix .. "ui/global/game_broadcast_tv_bg.png"

--[[音效start]]
M.all_music = {
    BIGYING = prefix .. "music/bigying.mp3", 
    BTN = prefix .. "music/menu_click_06.wav", 
    CHIP = prefix .. "music/chip.mp3", 
    CHIP_FLY = prefix .. "music/chipfly.mp3", 
    FAPAI = prefix .. "music/fapai.mp3", 
    GAME_WIN = prefix .. "music/game_win.mp3", 
    G_ALARM = prefix .. "music/g_alarm.mp3", 
    G_RECVGIFT = prefix .. "music/g_recvgift.mp3", 
    LOB_BG = prefix .. "music/lob_bg.mp3", 
    LOSE = prefix .. "music/lose.mp3", 
    POPUP = prefix .. "music/popup.mp3",  
    TASK_FINISH = prefix .. "music/task_finish.mp3", 
    TASK_GOLD = prefix .. "music/task_gold.mp3", 
    KISS = prefix .. "music/kiss.mp3", 
    PENG = prefix .. "music/peng.mp3", 
    phiz_py_daoshui = prefix .. "music/py_daoshui.mp3", 
    phiz_py_dianzan = prefix .. "music/py_dianzan.mp3", 
    phiz_py_ganbei = prefix .. "music/py_ganbei.mp3", 
    phiz_py_meigui = prefix .. "music/py_meigui.mp3",
    phiz_py_qinwen = prefix .. "music/py_qinwen.mp3",
    phiz_py_zhadan = prefix .. "music/py_zhadan.mp3",
    DIAMOND_POPUP = prefix .. "music/diamond_popup.mp3", 
    phiz_py_xihongshi = prefix .. "music/py_xihongshi.mp3",
    giftCar = prefix .. "music/gift_car5.mp3",
    giftCar1 = prefix .. "music/gift_car4.mp3"
}
--[[音效end]]

M.setting_btn_open = prefix .. "ui/setting/setting_btn_open.png"
M.setting_btn_openclose = prefix .. "ui/setting/setting_btn_openclose.png"

M.global_ranking_gold_img = prefix .. "ui/global/global_ranking_gold_img.png"
M.global_ranking_silver_img = prefix .. "ui/global/global_ranking_silver_img.png"
M.global_ranking_copper_img = prefix .. "ui/global/global_ranking_copper_img.png"

M.beauty_rank_hat_1 = prefix .. "ui/global/global_ranking_gold_img.png"
M.beauty_rank_hat_2 = prefix .. "ui/global/global_ranking_silver_img.png"
M.beauty_rank_hat_3 = prefix .. "ui/global/global_ranking_copper_img.png"
M.beauty_rank_hat_4 = prefix .. "ui/global/global_is_sex_img.png"

M.gameChat = prefix .. "ui/game_chat/gameChat.png"
M.gameChatNoble = prefix .. "ui/game_chat/gameChatNoble.png"

M.default_icon_60_2 = prefix .. "ui/global/default_icon_60_2.png"




--[[新手教程end]]

M.sendgift_word_img = prefix .. "ui/global/send_gift_word.png"
M.bnt_number_bg = prefix .. "ui/global/bnt_number_bg.png"

M.main_rank_1 = prefix .. "ui/hall/Front-hall_0007_26.png"
M.main_rank_2 = prefix .. "ui/hall/Front-hall_0006_27.png"
M.main_rank_3 = prefix .. "ui/hall/Front-hall_0005_28.png"
M.fuli_black = prefix .. "ui/hall/fuli_black.png"

M.popularize_titleItemImage_normal_1 = prefix .. "ui/popularize/popularize_titleItemImage_normal_1.png"
M.popularize_titleItemImage_normal_2 = prefix .. "ui/popularize/popularize_titleItemImage_normal_2.png"
M.popularize_titleItemImage_normal_3 = prefix .. "ui/popularize/popularize_titleItemImage_normal_3.png"
M.popularize_titleItemImage_normal_4 = prefix .. "ui/popularize/popularize_titleItemImage_normal_4.png"
M.popularize_titleItemImage_normal_5 = prefix .. "ui/popularize/popularize_titleItemImage_normal_5.png"
M.popularize_titleItemImage_selected_1 = prefix .. "ui/popularize/popularize_titleItemImage_selected_1.png"
M.popularize_titleItemImage_selected_2 = prefix .. "ui/popularize/popularize_titleItemImage_selected_2.png"
M.popularize_titleItemImage_selected_3 = prefix .. "ui/popularize/popularize_titleItemImage_selected_3.png"
M.popularize_titleItemImage_selected_4 = prefix .. "ui/popularize/popularize_titleItemImage_selected_4.png"
M.popularize_titleItemImage_selected_5 = prefix .. "ui/popularize/popularize_titleItemImage_selected_5.png"


M.userstatus_buttom_img = prefix .. "ui/playgame/userstatus_buttom_img.png"
M.userstatus_showcards_animation = prefix .. "share/animation/user_status/show_cards/%d.png"
M.userstatus_allin_animation = prefix .. "share/animation/user_status/all_in/100%02d.png"


M.game_beauty_sign = prefix .. "ui/playgame/game_beauty_sign.png"
M.game_user_bg_1 = prefix .. "ui/playgame/game_player_bg.png"
M.game_user_bg_2 = prefix .. "ui/playgame/game_player_bg2.png"



M.game_chip_wan = prefix .. "share/chips/game_chip_wan.png"
M.game_chip_num = prefix .. "share/chips/game_chip_num.png"

M.login_bnt_bg = prefix .. "ui/global/login_bnt_bg.png"
M.logo_img_1 = prefix .. "ui/main/logo_1.png"
M.logo_img_oppo = prefix .. "ui/main/logo_oppo.png"
M.loadding_png = prefix .. "ui/global/loading.png"
M.binding_qq_bnt = prefix .. "ui/global/binding_qq_bnt.png"
M.binding_qq_tips = prefix .. "ui/global/binding_qq_tips.png"
M.binding_wx_bnt = prefix .. "ui/global/binding_wx_bnt.png"
M.binding_wx_tips = prefix .. "ui/global/binding_wx_tips.png"

M.br_result_snow1 = prefix .. "ui/brgame/br_result_snow1.png"
M.br_result_snow2 = prefix .. "ui/brgame/br_result_snow2.png"
M.br_result_start = prefix .. "ui/brgame/br_result_start.png"

M.game_card_type_bg = prefix .. "ui/playgame/game_cardtype_bg.png"

M.game_chat_btn_img = prefix .. "ui/game_chat/bg_icon_1.png"

M.activityViewNewJson = prefix .. "ui/NewActivity.json" -- 新活动界面json
M.popularizeViewJson = prefix .. "ui/PopularizeHall.json" -- 推广界面json
M.getPicture1Json = prefix .. "ui/getpicture1.json"--拍照json1文件
M.getPicture2Json = prefix .. "ui/getpicture2.json"--拍照json2文件
M.changeUserinfoJson = prefix .. "ui/change_userinfo.json"--修改个人信息json文件
M.myHeadBoxJson = prefix .. "ui/myHeadBox.json"--我的头像json文件
M.headBoxItemJson = prefix .. "ui/headBoxItem.json"--我的头像Item 的 json文件
M.userHeadJson = prefix .. "ui/userHead.json"--我的头像组件的 json文件


M.share_rank = prefix .. "ui/share_rank.json"--特殊牌型分享json文件
M.inviteView_1 = prefix .. "ui/invite.json"--邀请json文件

M.invite_receive_btn = prefix .. "ui/activity/btn_yellow.png"
M.invite_toInvite_btn = prefix .. "ui/activity/btn_blue.png"
M.invite_finish_task_btn = prefix .. "ui/activity/btn_finish.png"
M.invite_txt_toInvite = prefix .. "ui/activity/txt_invite.png"
M.invite_txt_receive = prefix .. "ui/activity/txt_recevie.png"
M.invite_pop = prefix .. "ui/InvitePop.json" --邀请弹框
M.invite_detail_pop = prefix .. "ui/InviteDetail.json" --邀请明细
M.invite_bind_pop = prefix .. "ui/InviteBind.json" --邀请绑定
M.invite_ruler_pop = prefix .. "ui/InviteRuler.json" --邀请规则
M.gameChatJson = prefix .. "ui/gameChat_1.json"--  聊天信息界面json文件
M.exitDialogJson = prefix .. "ui/exitDialog.json"--  退出游戏界面json文件

M.daoju_gift_card_icon = prefix .. "ui/daoju/daoju_gift_card_icon.png"
M.laba_icon = prefix .. "ui/daoju/icon_laba.png"
M.huafei_icon = prefix .. "ui/daoju/dayreward_bill.png"
M.weekcard_icon = prefix .. "ui/daoju/icon_weekcard.png"
M.monthcard_icon = prefix .. "ui/daoju/icon_monthcard.png"
M.vipcard_daoju_icon = prefix .. "ui/daoju/vip_icon.png"
M.enter_ticket = prefix .. "ui/daoju/icon_entry_ticket.png"

M.shop_giftcard_icon = prefix .. "ui/shop/shop_giftcard.png"
M.shop_laba_icon = prefix .. "ui/shop/shop_laba.png"
M.shop_weekcard_icon = prefix .. "ui/shop/shop_weekcard.png"
M.shop_monthcard_icon = prefix .. "ui/shop/shop_monthcard.png"
M.shop_vip_week_icon = prefix .. "ui/shop/shop_vip_weekcard.png"
M.shop_vip_month_icon = prefix .. "ui/shop/shop_vip_monthcard.png"

M.chat_bg_icon1 = prefix .. "ui/game_chat/bg_icon_1.png"
M.chat_bg_icon2 = prefix .. "ui/game_chat/bg_icon_2.png"
M.chat_bg_icon3 = prefix .. "ui/game_chat/bg_icon_3.png"
M.chat_bg_icon4 = prefix .. "ui/game_chat/bg_icon_4.png"
M.chat_bg_icon5 = prefix .. "ui/game_chat/bg_icon_5.png"




--[[设置界面开关资源]]
M.setting_switch_plist = prefix .. "ui/setting/switch.plist"
M.setting_switch_png = prefix .. "ui/setting/switch.png"
M.setting_switch_plist1 = prefix .. "ui/setting/switch1.plist"
M.setting_switch_png1 = prefix .. "ui/setting/switch1.png"

M.msg_line = prefix .. "ui/laba/line.png"

M.shop_coins_icon_1 = prefix .. "ui/shop/icon_coins1.png"
M.shop_coins_icon_2 = prefix .. "ui/shop/icon_coins2.png"
M.shop_coins_icon_3 = prefix .. "ui/shop/icon_coins3.png"
M.shop_coins_icon_4 = prefix .. "ui/shop/icon_coins4.png"
M.shop_coins_icon_5 = prefix .. "ui/shop/icon_coins5.png"
M.shop_coins_icon_6 = prefix .. "ui/shop/icon_coins6.png"
M.shop_coins_icon_7 = prefix .. "ui/shop/icon_coins7.png"
M.shop_coins_icon_8 = prefix .. "ui/shop/icon_coins8.png"

M.shop_channel_huafei = prefix .. "ui/shop/channel_duanxin.png"

M.gift_icon_0 = prefix .. "ui/global/gift01.png"
M.gift_icon_1 = prefix .. "ui/global/gift02.png"
M.gift_icon_2 = prefix .. "ui/global/gift03.png"
M.gift_icon_3 = prefix .. "ui/global/gift04.png"
M.gift_icon_4 = prefix .. "ui/global/gift05.png"
M.gift_icon_5 = prefix .. "ui/global/gift06.png"
-- M.gift_icon_7 = prefix.."ui/global/gift07.png"
-- M.gift_icon_8 = prefix.."ui/global/gift08.png"
-- M.gift_icon_9 = prefix.."ui/global/gift09.png"
-- M.gift_icon_10 = prefix.."ui/global/gift10.png"
-- M.gift_icon_11 = prefix.."ui/global/gift11.png"
-- M.gift_icon_12 = prefix.."ui/global/gift12.png"

M.gift_icon_1005 = prefix .. "share/gift/1005.png"
M.gift_icon_1006 = prefix .. "share/gift/1006.png"
M.gift_icon_1007 = prefix .. "share/gift/1007.png"
M.gift_icon_1008 = prefix .. "share/gift/1008.png"
M.gift_icon_1009 = prefix .. "share/gift/1009.png"
M.gift_icon_1010 = prefix .. "share/gift/1010.png"
M.gift_icon_1011 = prefix .. "share/gift/1011.png"
M.gift_icon_1012 = prefix .. "share/gift/1012.png"
M.gift_icon_1013 = prefix .. "share/gift/1013.png"
M.gift_icon_1014 = prefix .. "share/gift/1014.png"
M.gift_icon_1015 = prefix .. "share/gift/1015.png"
M.gift_icon_1016 = prefix .. "share/gift/1016.png"
M.gift_icon_1017 = prefix .. "share/gift/1017.png"
M.gift_icon_1018 = prefix .. "share/gift/1018.png"
M.gift_icon_1019 = prefix .. "share/gift/1019.png"
M.gift_icon_1020 = prefix .. "share/gift/1020.png"
M.gift_icon_1021 = prefix .. "share/gift/1021.png"
M.gift_icon_1022 = prefix .. "share/gift/1022.png"
M.gift_icon_1023 = prefix .. "share/gift/1023.png"
M.gift_icon_1024 = prefix .. "share/gift/1024.png"
M.gift_icon_1025 = prefix .. "share/gift/1025.png"
M.gift_icon_1026 = prefix .. "share/gift/1026.png"
M.gift_icon_1027 = prefix .. "share/gift/1027.png"
M.gift_icon_1028 = prefix .. "share/gift/1028.png"
M.gift_icon_1029 = prefix .. "share/gift/1029.png"
M.gift_icon_1030 = prefix .. "share/gift/1030.png"
M.gift_icon_1031 = prefix .. "share/gift/1031.png"
M.gift_icon_1032 = prefix .. "share/gift/1032.png"
M.gift_icon_1033 = prefix .. "share/gift/1033.png"
M.gift_icon_1034 = prefix .. "share/gift/1034.png"
M.gift_icon_1035 = prefix .. "share/gift/1035.png"
M.gift_icon_1036 = prefix .. "share/gift/1036.png"
M.gift_icon_1037 = prefix .. "share/gift/1037.png"
M.gift_icon_1038 = prefix .. "share/gift/1038.png"
M.gift_icon_1039 = prefix .. "share/gift/1039.png"
M.gift_icon_1040 = prefix .. "share/gift/1040.png"
M.gift_icon_1041 = prefix .. "share/gift/1041.png"
M.gift_icon_1042 = prefix .. "share/gift/1042.png"
M.gift_icon_1043 = prefix .. "share/gift/1043.png"
M.gift_icon_1044 = prefix .. "share/gift/1044.png"
M.gift_icon_1045 = prefix .. "share/gift/1045.png"

M.gift_icon_2000 = prefix .. "share/gift/2000.png"
M.gift_icon_2001 = prefix .. "share/gift/2001.png"
M.gift_icon_2002 = prefix .. "share/gift/2002.png"
M.gift_icon_2003 = prefix .. "share/gift/2003.png"
M.gift_icon_2004 = prefix .. "share/gift/2004.png"
M.gift_icon_2005 = prefix .. "share/gift/2005.png"

M["gift_icon_s_-1"] = prefix .. "ui/global/userinfo_img_gift.png"
M.gift_icon_s_0 = prefix .. "share/gift/0_s.png"
M.gift_icon_s_1 = prefix .. "share/gift/1_s.png"
M.gift_icon_s_2 = prefix .. "share/gift/2_s.png"
M.gift_icon_s_3 = prefix .. "share/gift/3_s.png"
M.gift_icon_s_4 = prefix .. "share/gift/4_s.png"
-- M.gift_icon_s_7 = prefix.."share/gift/7_s.png"
-- M.gift_icon_s_8 = prefix.."share/gift/8_s.png"
-- M.gift_icon_s_9 = prefix.."share/gift/9_s.png"
-- M.gift_icon_s_10 = prefix.."share/gift/10_s.png"
-- M.gift_icon_s_11 = prefix.."share/gift/11_s.png"
-- M.gift_icon_s_12 = prefix.."share/gift/12_s.png"
M.gift_icon_s_1005 = prefix .. "share/gift/1005_s.png"
M.gift_icon_s_1006 = prefix .. "share/gift/1006_s.png"
M.gift_icon_s_1007 = prefix .. "share/gift/1007_s.png"
M.gift_icon_s_1008 = prefix .. "share/gift/1008_s.png"
M.gift_icon_s_1009 = prefix .. "share/gift/1009_s.png"
M.gift_icon_s_1010 = prefix .. "share/gift/1010_s.png"
M.gift_icon_s_1011 = prefix .. "share/gift/1011_s.png"
M.gift_icon_s_1012 = prefix .. "share/gift/1012_s.png"
M.gift_icon_s_1013 = prefix .. "share/gift/1013_s.png"
M.gift_icon_s_1014 = prefix .. "share/gift/1014_s.png"
M.gift_icon_s_1015 = prefix .. "share/gift/1015_s.png"
M.gift_icon_s_1016 = prefix .. "share/gift/1016_s.png"
M.gift_icon_s_1017 = prefix .. "share/gift/1017_s.png"
M.gift_icon_s_1018 = prefix .. "share/gift/1018_s.png"
M.gift_icon_s_1019 = prefix .. "share/gift/1019_s.png"
M.gift_icon_s_1020 = prefix .. "share/gift/1020_s.png"
M.gift_icon_s_1021 = prefix .. "share/gift/1021_s.png"
M.gift_icon_s_1022 = prefix .. "share/gift/1022_s.png"
M.gift_icon_s_1023 = prefix .. "share/gift/1023_s.png"
M.gift_icon_s_1024 = prefix .. "share/gift/1024_s.png"
M.gift_icon_s_1025 = prefix .. "share/gift/1025_s.png"
M.gift_icon_s_1026 = prefix .. "share/gift/1026_s.png"
M.gift_icon_s_1027 = prefix .. "share/gift/1027_s.png"
M.gift_icon_s_1028 = prefix .. "share/gift/1028_s.png"
M.gift_icon_s_1029 = prefix .. "share/gift/1029_s.png"
M.gift_icon_s_1030 = prefix .. "share/gift/1030_s.png"
M.gift_icon_s_1031 = prefix .. "share/gift/1031_s.png"
M.gift_icon_s_1032 = prefix .. "share/gift/1032_s.png"
M.gift_icon_s_1033 = prefix .. "share/gift/1033_s.png"
M.gift_icon_s_1034 = prefix .. "share/gift/1034_s.png"
M.gift_icon_s_1035 = prefix .. "share/gift/1035_s.png"
M.gift_icon_s_1036 = prefix .. "share/gift/1036_s.png"
M.gift_icon_s_1037 = prefix .. "share/gift/1037_s.png"
M.gift_icon_s_1038 = prefix .. "share/gift/1038_s.png"
M.gift_icon_s_1039 = prefix .. "share/gift/1039_s.png"
M.gift_icon_s_1040 = prefix .. "share/gift/1040_s.png"
M.gift_icon_s_1041 = prefix .. "share/gift/1041_s.png"
M.gift_icon_s_1042 = prefix .. "share/gift/1042_s.png"
M.gift_icon_s_1043 = prefix .. "share/gift/1043_s.png"
M.gift_icon_s_1044 = prefix .. "share/gift/1044_s.png"
M.gift_icon_s_1045 = prefix .. "share/gift/1045_s.png"

M.gift_icon_s_2000 = prefix .. "share/gift/2000_s.png"
M.gift_icon_s_2001 = prefix .. "share/gift/2001_s.png"
M.gift_icon_s_2002 = prefix .. "share/gift/2002_s.png"
M.gift_icon_s_2003 = prefix .. "share/gift/2003_s.png"
M.gift_icon_s_2004 = prefix .. "share/gift/2004_s.png"
M.gift_icon_s_2005 = prefix .. "share/gift/2005_s.png"

M.img_kiss = prefix .. "ui/playgame/dashang/img_kiss2.png"
M.img_kiss_hart = prefix .. "ui/playgame/dashang/img_kiss1.png"


M.particle_win = prefix .. "share/animation/particle_win9.plist"
M.effect_win = prefix .. "share/animation/effect_win%02d.png"


M.icon_number = prefix .. "ui/global/img_icon_num.png"

--主界面商城按钮特效
M.img_main_shop_shape = prefix .. "ui/hall/main_shop_shape.png"
M.img_main_shop_particle = prefix .. "share/animation/main_shop_partical.plist"
M.img_main_shop_particle_texture = prefix .. "share/animation/main_shop_partical_texture.png"

-- 主界面商城按钮特效 v460
M.main_new_shop = prefix .. "ui/armature_anim/main_shop_btn/NewAnimation.ExportJson"
M.quickStart = prefix .. "ui/armature_anim/quickStart/quickStart.ExportJson" --主界面快速开始的动效

M.img_user_red_bg = prefix .. "ui/playgame/img_user_red_bg.png" -- 结算-赢-底图


----聊天优化
M.game_chat_face_select_bt_selected = prefix .. "ui/game_chat/face_select_bt_selected.png" -- 
M.game_chat_face_select_bt_normal = prefix .. "ui/game_chat/face_select_bt_normal.png" -- 
M.global_trans_bt = prefix .. "ui/global/global_trans_bt.png" --
--



--分享图片
M.invite_img_1 = prefix .. "ui/invite/invite_icon.png" --我要斗地主

M.chat_shop_icon = prefix .. "ui/game_chat/chat_shop_icon.png"--
M.chat_prop_icon = prefix .. "ui/game_chat/chat_prop_icon.png"--

M.game_text_reconnect = prefix .. "ui/game//text_reconnect.png"
M.hot_update_par_plist = prefix .. "ui/loading/par_hot_star.plist"

M.shop_channel_app = prefix .. "ui/shop/channel_apple.png"
M.shop_channel_duanxin = prefix .. "ui/shop/channel_duanxin.png"
M.shop_channel_zhifubao = prefix .. "ui/shop/channel_zhifubao.png"
M.shop_channel_weixin = prefix .. "ui/shop/channel_weixin.png"
M.shop_channel_bank = prefix .. "ui/shop/channel_bank.png"
M.shop_channel_qq = prefix .. "ui/shop/channel_qq.png"


M.pay_item_wx = prefix .. "ui/global/pay_item_wx.png"
M.pay_item_zfb = prefix .. "ui/global/pay_item_zfb.png"
M.pay_item_yl = prefix .. "ui/global/pay_item_yl.png"
M.pay_item_as = prefix .. "ui/global/pay_item_as.png"

M.pay_item_wx_0 = prefix .. "ui/global/pay_item_wx_0.png"
M.pay_item_zfb_0 = prefix .. "ui/global/pay_item_zfb_0.png"
M.pay_item_yl_0 = prefix .. "ui/global/pay_item_yl_0.png"
M.pay_item_as_0 = prefix .. "ui/global/pay_item_as_0.png"

M.pay_item_img_wx = prefix .. "ui/global/pay_img_wx.png"
M.pay_item_img_zfb = prefix .. "ui/global/pay_img_zfb.png"
M.pay_item_img_yl = prefix .. "ui/global/pay_img_yl.png"
M.pay_item_img_as = prefix .. "ui/global/pay_img_as.png"

M.radio_btn_selected = prefix .. "ui/global/radio_btn_selected.png"
M.radio_btn_unselected = prefix .. "ui/global/radio_btn_unselected.png"

M.shoppromit_item_selected_frame = prefix .. "ui/global/item_selected.png"


M.customize_coin_test = prefix .. "ui/shop/shop_coin.png"
M.customize_entry_animation = prefix .. "share/animation/customize/sirendonghua.ExportJson"
M.customize_entry_animation_texture = prefix .. "share/animation/customize/sirendonghua0.plist"


M.vip_ani_sitdown_bg = prefix .. "share/animation/vip/sitdown_frame.png"
M.vip_ani_sitdown_frame = prefix .. "share/animation/vip/sitdown_%02d.png"
M.vip_ani_standup_json = prefix .. "share/animation/vip/standup.ExportJson"
M.vip_hide_default_head = prefix .. "ui/global/vip_hide_head_%d.png"
M.vip_hide_default_small_head = prefix .. "ui/global/vip_hide_shead_%d.png"
M.vip_shop_desc_close_btn = prefix .. "ui/global/global_dialog_close.png"
M.vip_shop_desc_popup = prefix .. "ui/shop/vip_desc_pop.png"
M.vip_player_animation_head_bg = prefix .. "ui/playgame/vip_head_ani_bg.png"

M.text_addfriend = prefix .. "ui/global/text_addfriend.png"
M.text_deletfriend = prefix .. "ui/global/text_deletfriend.png"
M.text_tiaozhan = prefix .. "ui/global/text_tiaozhan.png"

M.share_logo_danji = prefix .. "ui/customize_gameresult/share_logo_danji.png"
M.share_logo_tiantian = prefix .. "ui/customize_gameresult/share_logo_tiantian.png"

M.gift_wing_envelop = prefix .. "share/animation/giftAnimation/gift_wing_envelop.png"
M.gift_wing_left = prefix .. "share/animation/giftAnimation/gift_wing_left.png"
M.gift_wing_right = prefix .. "share/animation/giftAnimation/gift_wing_right.png"

M.device_wifi_strength = prefix .. "ui/device/wifi_strength_%d.png"--wifi信号强度
M.device_gprs_strength = prefix .. "ui/device/gprs_strength_%d.png"--gprs信号强度
M.device_battery_frame = prefix .. "ui/device/battery_frame.png"--电池图标
M.device_battery_level = prefix .. "ui/device/battery_level.png"--电池电量
M.device_battery_low_power = prefix .. "ui/device/battery_low_power.png"--电池低电
M.device_info_bg = prefix .. "ui/device/device_info_bg.png"--设备信息底图

M.levelup_animations = prefix .. "ui/levelup/arrow_animation_%d.png"

M.img_user_info_my_sex = prefix .. "ui/change_userinfo/img_sex_%d.png"
M.btn_user_info_edit_sure = prefix .. "ui/change_userinfo/btn_edit_sure.png"
M.btn_user_info_edit = prefix .. "ui/userinfo/gameinfo/eid.png"
M.userinfo_cardBg  = prefix .. "ui/userinfo/gameinfo/img_max_card_frame.png"
M.userinfo_cardBg1 = prefix .. "ui/userinfo/gameinfo/img_max_card_frame1.png"


M.playgame_chips_num_altas = prefix .. "ui/playgame/chip_num/number.png"
M.playgame_chips_num_dot = prefix .. "ui/playgame/chip_num/dot.png"
M.playgame_chips_unit_k_altas = prefix .. "ui/playgame/chip_num/k.png"
M.playgame_chips_unit_m_altas = prefix .. "ui/playgame/chip_num/m.png"



--特效控件
M.common_widget_beam = prefix .. "ui/common/beam.png"
M.common_widget_meteor_particle = prefix .. "ui/common/par_hot_star.plist"
M.common_widget_dark_bg = prefix .. "ui/common/temp_blur.png" --临时用的弹框背景，用于windows调试
M.common_widget_back_btn = prefix .. "ui/global/global_back_up_btn.png"

--积分兑换默认图片
M.score_exchange_default_img = prefix .. "ui/exchange/img/16.png"


M.global_confirm_button_351x113 = prefix .. "ui/global/btn_normal_351x113_y.png"
M.global_cancel_button_351x113 = prefix .. "ui/global/btn_normal_351x113_n.png"



--手机绑定弹框
M.global_btn_gray = prefix .. "ui/global/btn_gray.png"


--获取钻石弹窗
M.global_got_diamond_ani_json = prefix .. "share/animation/diamond/NewAnimation123.ExportJson"
M.global_got_diamond_ani_buygoldbg = prefix .. "share/animation/diamond/buygoldbg.png"
M.global_got_diamond_title_shape = prefix .. "share/animation/diamond/title_clipping.png"
M.global_got_diamond_title_beam = prefix .. "share/animation/diamond/beam.png"
M.global_got_diamond_plus_symbol = prefix .. "ui/global/diamond_plus.png"
M.global_diamond_text = prefix .. "ui/shop/img_txt_diamond.png"
M.global_diamond_num_atlas = prefix .. "ui/shop/img_diamond_word.png"
M.global_gold_text = prefix .. "ui/shop/img_txt_diamond2.png"
M.global_gold_num_atlas = prefix .. "ui/shop/img_diamond_word21.png"
M.global_focas_text = prefix.."ui/Focas/kf_focasTips.png"
M.change_userinfo_right_btn = prefix .. "ui/change_userinfo/change_userinfo_right_btn.png"

M.global_got_reward_ani_json = "share/animation/diamond/rewardAnimation/NewAnimation1234.ExportJson"
M.global_got_point_ani_buygoldBg = "share/animation/diamond/points.png"

M.break_hide_card_icon = prefix .. "ui/userinfo/break_hide/break_hide_card.png"
M.shop_break_hide_card = prefix .. "ui/shop/shop_break_hide_card.png"
M.shop_break_hide_card_title = prefix .. "ui/shop/img_title_break_hide.png"
M.break_hide_card_using_icon = prefix .. "ui/userinfo/break_hide/break_hide_icon.png"
M.break_hide_card_using_icon_ingame = prefix .. "ui/userinfo/break_hide/break_hide_icon_ingame.png"
M.break_hide_bg = prefix .. "ui/userinfo/break_hide/break_hide_bg.png"
M.break_hide_btn_title = prefix .. "ui/userinfo/break_hide/break_hide_btn_title.png"
M.break_hide_page_light = prefix .. "ui/change_userinfo/change_userinfo_sng_light.png"

M.btn_normal_175_72 = prefix .. "ui/global/btn_normal_175_72.png"

M.login_bg = prefix .. "ui/pc_login/blur_bg.png"
M.login_bg_txt1 = prefix.."ui/pc_login/login_bg_txt1.png"

M.health_advice = prefix.."ui/global/health_advice.png"
M.login_bg_txt2 = prefix.."ui/pc_login/login_bg_txt2.png"

M.login_1 = prefix .. "share/animation/login/login_1.png"
M.login_2 = prefix .. "share/animation/login/login_2.png"
M.login_3 = prefix .. "share/animation/login/login_3.png"
M.login_4 = prefix .. "share/animation/login/login_4.png"


M.mask_png = prefix .. "share/game/game_mask_a.png"
M.sq_mask_png = prefix .. "share/game/game_mask_a_square.png"
M.blank_content = prefix .. "share/game/blank_content.png"

M.BANNER_POP = prefix .. "ui/BannerPop.json"--  bannerPop界面json文件
M.DAILY_LOGIN_POP = prefix .. "ui/dailylogin.json" -- 每日登陆奖励 
M.DAILY_LOGIN_Get = prefix .. "ui/daily/mrdl_01_01.png" -- 每日登陆奖励 
M.DAILY_LOGIN_Today = prefix .. "ui/daily/mrdl_01_02.png" -- 每日登陆奖励 
M.Gold_pis = prefix .. "share/coin/%d.png"
M.Gold_plist = prefix .. "share/coin/gold.plist"
M.Gold_plist_png = prefix .. "share/coin/gold.png"
M.DAILY_REWARD_LIGHT = prefix .. "ui/armature_anim/Login-to-reward/Login-to-reward.ExportJson" --领奖星星
M.DAILY_REWARD = prefix .. "ui/armature_anim/Login-to-reward01/Login-to-reward01.ExportJson" --领奖动画
M.DAILY_REWARD_2 = prefix .. "ui/armature_anim/Login-to-reward02/Login-to-reward02.ExportJson" --领奖动画
M.DAILY_REWARD_LIGHT_2 = prefix .. "ui/armature_anim/NewAnimation0102dlgx/NewAnimation0102dlgx.ExportJson" --登陆奖励光效
M.DAILY_REWARD_LIGHT_1 = prefix .. "ui/armature_anim/newUserAni1/newUserAni1.ExportJson" --登陆奖励光效

M.login_plist = prefix .. "share/animation/login/login.plist"
M.login_png = prefix .. "share/animation/login/login.png"

M.loadingFly = prefix .. "ui/armature_anim/loadingFly/NewAnimation.ExportJson"
M.loadingImg = prefix .. "ui/loading/xiegan.png"


M.install_games = prefix .. "ui/install_game_pop.json" -- 安装游戏
M.Peng_gold_sound = prefix .. "music/peng.mp3" -- 喷金币声音sss

M.EMOJI01 = prefix .. "share/animation/emoji/smiley8/smiley8.ExportJson"
M.EMOJI_LIST_01 = prefix .. "share/animation/emoji/smiley8/smiley80.plist"
M.EMOJI02 = prefix .. "share/animation/emoji/smiley9/smiley9.ExportJson"
M.EMOJI_LIST_02 = prefix .. "share/animation/emoji/smiley9/smiley90.plist"
M.EMOJI03 = prefix .. "share/animation/emoji/smiley10/smiley10.ExportJson"
M.EMOJI_LIST_03 = prefix .. "share/animation/emoji/smiley10/smiley100.plist"
M.EMOJI04 = prefix .. "share/animation/emoji/smiley11/smiley11.ExportJson"
M.EMOJI_LIST_04 = prefix .. "share/animation/emoji/smiley11/smiley110.plist"
M.EMOJI05 = prefix .. "share/animation/emoji/smiley12/smiley12.ExportJson"
M.EMOJI_LIST_05 = prefix .. "share/animation/emoji/smiley12/smiley120.plist"
M.EMOJI06 = prefix .. "share/animation/emoji/smiley13/smiley13.ExportJson"
M.EMOJI_LIST_06 = prefix .. "share/animation/emoji/smiley13/smiley130.plist"


M.VIP_EMOJI_01 = prefix .. "share/animation/vipemoji/vipemoticon-1/vipemoticon-1.ExportJson"
M.VIP_EMOJI_LIST_01 = prefix .. "share/animation/vipemoji/vipemoticon-1/vipemoticon-10.plist"
M.VIP_EMOJI_02 = prefix .. "share/animation/vipemoji/vipemoticon-2/vipemoticon-2.ExportJson"
M.VIP_EMOJI_LIST_02 = prefix .. "share/animation/vipemoji/vipemoticon-2/vipemoticon-20.plist"
M.VIP_EMOJI_03 = prefix .. "share/animation/vipemoji/vipemoticon-3/vipemoticon-3.ExportJson"
M.VIP_EMOJI_LIST_03 = prefix .. "share/animation/vipemoji/vipemoticon-3/vipemoticon-30.plist"
M.VIP_EMOJI_04 = prefix .. "share/animation/vipemoji/vipemoticon-4/vipemoticon-4.ExportJson"
M.VIP_EMOJI_LIST_04 = prefix .. "share/animation/vipemoji/vipemoticon-4/vipemoticon-40.plist"
M.VIP_EMOJI_05 = prefix .. "share/animation/vipemoji/vipemoticon-5/vipemoticon-5.ExportJson"
M.VIP_EMOJI_LIST_05 = prefix .. "share/animation/vipemoji/vipemoticon-5/vipemoticon-50.plist"
M.VIP_EMOJI_06 = prefix .. "share/animation/vipemoji/vipemoticon-6/vipemoticon-6.ExportJson"
M.VIP_EMOJI_LIST_06 = prefix .. "share/animation/vipemoji/vipemoticon-6/vipemoticon-60.plist"
M.VIP_EMOJI_07 = prefix .. "share/animation/vipemoji/vipemoticon-7/vipemoticon-7.ExportJson"
M.VIP_EMOJI_LIST_07 = prefix .. "share/animation/vipemoji/vipemoticon-7/vipemoticon-70.plist"
M.VIP_EMOJI_08 = prefix .. "share/animation/vipemoji/vipemoticon-8/vipemoticon-8.ExportJson"
M.VIP_EMOJI_LIST_08 = prefix .. "share/animation/vipemoji/vipemoticon-8/vipemoticon-80.plist"
M.VIP_EMOJI_09 = prefix .. "share/animation/vipemoji/vipemoticon-9/vipemoticon-9.ExportJson"
M.VIP_EMOJI_LIST_09 = prefix .. "share/animation/vipemoji/vipemoticon-9/vipemoticon-90.plist"
M.VIP_EMOJI_10 = prefix .. "share/animation/vipemoji/vipemoticon-10/vipemoticon-10.ExportJson"
M.VIP_EMOJI_LIST_10 = prefix .. "share/animation/vipemoji/vipemoticon-10/vipemoticon-100.plist"
M.VIP_EMOJI_11 = prefix .. "share/animation/vipemoji/vipemoticon-11/vipemoticon-11.ExportJson"
M.VIP_EMOJI_LIST_11 = prefix .. "share/animation/vipemoji/vipemoticon-11/vipemoticon-110.plist"
M.VIP_EMOJI_12 = prefix .. "share/animation/vipemoji/vipemoticon-12/vipemoticon-12.ExportJson"
M.VIP_EMOJI_LIST_12 = prefix .. "share/animation/vipemoji/vipemoticon-12/vipemoticon-120.plist"
M.VIP_EMOJI_13 = prefix .. "share/animation/vipemoji/vipemoticon-13/vipemoticon-13.ExportJson"
M.VIP_EMOJI_LIST_13 = prefix .. "share/animation/vipemoji/vipemoticon-13/vipemoticon-130.plist"
M.VIP_EMOJI_14 = prefix .. "share/animation/vipemoji/vipemoticon-14/vipemoticon-14.ExportJson"
M.VIP_EMOJI_LIST_14 = prefix .. "share/animation/vipemoji/vipemoticon-14/vipemoticon-140.plist"
M.VIP_EMOJI_15 = prefix .. "share/animation/vipemoji/vipemoticon-15/vipemoticon-15.ExportJson"
M.VIP_EMOJI_LIST_15 = prefix .. "share/animation/vipemoji/vipemoticon-15/vipemoticon-150.plist"
M.VIP_EMOJI_16 = prefix .. "share/animation/vipemoji/vipemoticon-16/vipemoticon-16.ExportJson"
M.VIP_EMOJI_LIST_16 = prefix .. "share/animation/vipemoji/vipemoticon-16/vipemoticon-160.plist"
M.VIP_EMOJI_17 = prefix .. "share/animation/vipemoji/vipemoticon-17/vipemoticon-17.ExportJson"
M.VIP_EMOJI_LIST_17 = prefix .. "share/animation/vipemoji/vipemoticon-17/vipemoticon-170.plist"
M.VIP_EMOJI_18 = prefix .. "share/animation/vipemoji/vipemoticon-18/vipemoticon-18.ExportJson"
M.VIP_EMOJI_LIST_18 = prefix .. "share/animation/vipemoji/vipemoticon-18/vipemoticon-180.plist"


M.HOTGAMEICON = prefix .. "ui/hall/Front_hal_006_11.png"

M.LackGold = prefix .. "ui/LackGold.json" --没钱进游戏弹框

M.chat_animation_bingtong = prefix .. "ui/game_chat/animation/bingtong.ExportJson" -- bingtong动画
M.chat_animation_dayu = prefix .. "ui/game_chat/animation/dayu.ExportJson" -- dayu动画
M.chat_animation_niubei = prefix .. "ui/game_chat/animation/niubei.ExportJson" -- niubei动画
M.chat_animation_zhuaji = prefix .. "ui/game_chat/animation/zhuaji.ExportJson" -- zhuaji动画
M.chat_animation_xihongshi = prefix .. "ui/game_chat/animation/xihongshi.ExportJson" -- xihongshi动画
M.chat_animation_dianzan = prefix .. "ui/game_chat/animation/dianzan.ExportJson" -- 点赞动画
M.chat_animation_meigui = prefix .. "ui/game_chat/animation/meigui.ExportJson" -- 玫瑰动画
M.chat_animation_zhadan = prefix .. "ui/game_chat/animation/zhadan.ExportJson" -- 炸弹
M.chat_animation_qinwen = prefix .. "ui/game_chat/animation/qinwen.ExportJson" -- 亲吻

M.interactPhizSmall = prefix .. "ui/game_chat/interact_phiz_%s.png" -- 小互动表情
M.interactPhizReady001 = prefix .. "ui/game_chat/phiz_ready/phiz_001.png"
M.interactPhizReady002 = prefix .. "ui/game_chat/phiz_ready/phiz_002.png"
M.interactPhizReady003 = prefix .. "ui/game_chat/phiz_ready/phiz_003.png"
M.interactPhizReady004 = prefix .. "ui/game_chat/phiz_ready/phiz_004.png" --炸弹
M.interactPhizReady005 = prefix .. "ui/game_chat/phiz_ready/phiz_005.png" --吻
M.interactPhizReady006 = prefix .. "ui/game_chat/phiz_ready/phiz_006.png"
M.interactPhizReady007 = prefix .. "ui/game_chat/phiz_ready/phiz_007.png"
M.interactPhizReady008 = prefix .. "ui/game_chat/phiz_ready/phiz_008.png"

M.phiz_py_daoshui = prefix .. "ui/game_chat/phiz_ready/phiz_006.mp3"


M.downChooseImg = prefix .. "ui/lackgold/pcbz_0008_03.png"--向下的三角形（用于选择支付方式显示和隐藏）
M.upChooseImg = prefix .. "ui/lackgold/pcbz_0008_04.png"--向上的三角形（用于选择支付方式显示和隐藏）

M.NewBankruptcyJson = prefix .. "ui/newbankruptcy.json"--新破产补助

--大转盘
M.TURNTABLE = prefix .. "share/animation/zp_icon/zp_icon.ExportJson"
M.TURNTABLEIcon0 = prefix .. "ui/TurnTable/dtzp__0009_02.png"
M.TURNTABLEIcon1 = prefix .. "ui/TurnTable/dtzp__0009_03.png"
M.TurnTableJson = prefix .. "ui/TurnTable.json"
M.img_TurnTable_shape = prefix .. "ui/TurnTable/zp__0005_07.png"--欢乐转盘特效
M.TURNTABLELight0 = prefix .. "ui/TurnTable/zp_light01.png"
M.TURNTABLELight1 = prefix .. "ui/TurnTable/zp_light02.png"
M.TURNTABLEOVER = prefix .. "share/animation/Get-the-success02/Get-the-success01.ExportJson"
M.shop_diamond2 = prefix .. "ui/shop/img_buy_diamond_2.png"--2个钻是
M.shop_diamond5 = prefix .. "ui/shop/img_buy_diamond_3.png"--5个钻石
M.shop_diamond20 = prefix .. "ui/shop/img_buy_diamond_6.png"--一箱钻石
M.TurnTableGoldCard = prefix .. "ui/TurnTable/shop_monthcard.png"--金卡
M.TurnTableSliverCard = prefix .. "ui/TurnTable/shop_weekcard.png"--银卡
M.TurnTableGold0 = prefix .. "ui/TurnTable/zp_lq_12.png"--金币
M.TurnTableGold1 = prefix .. "ui/TurnTable/zp_lq_11.png"--金币
M.TurnTableGold2 = prefix .. "ui/TurnTable/zp_lq_13.png"--金币
M.TurnTableGold3 = prefix .. "ui/TurnTable/zp_lq_10.png"--金币
M.TurnTableBgLight = prefix .. "ui/TurnTable/zp_lq_02.png"--背景光

M.FirstGameJson = prefix .. "ui/FirstGame.json"
M.newFirstGameJson = prefix .. "ui/newFirstGame.json"
M.NewsLeadJson = prefix .. "ui/NewsLead.json"


--累计登陆
M.NewTotalLoginJson = prefix .. "ui/NewTotalLogin.json"
M.NewTotalLoginAniPlist = prefix .. "ui/newtotallogin/newtotallogin.plist"
M.NewTotalLoginAniPng = prefix .. "ui/newtotallogin/newtotallogin.png"
M.ljdl_gift_icon = prefix .. "ui/newtotallogin/ljdl_gift%d_%d.png"--图标
M.ljdl_gift_prize = prefix .. "ui/newtotallogin/ljdl_prize%d_%d.png"--礼物
M.ljdl_gift_day = prefix .. "ui/newtotallogin/ljdl_day%d_%d.png"--天数
M.ljdl_main_icon1 = prefix .. "ui/newtotallogin/box1.png"--大厅icon
M.ljdl_main_icon2 = prefix .. "ui/newtotallogin/box2.png"--大厅icon
M.ljdl_dia_gold = prefix .. "ui/newtotallogin/img_buy_diamond_2.png"--钻石加金币
M.NEWTOTALLOGINOVER = prefix .. "share/animation/Get-the-success03/Get-the-success.ExportJson"
M.NEWTOTALLOGINOVERImg = prefix .. "ui/newtotallogin/zp_lq_15.png"--鸿运当头
M.ljdl_main_dian = prefix .. "ui/NewsLead/yddhk_006.png"--大厅点
M.hall_fuliCenter_item_icon = prefix .. "ui/hall/welfare_item.png" -- 大厅的福利中心

--广播
M.BroadcastSystemImg = prefix .. "ui/laba/yddhk_009.png"--系统广播图片
M.BroadcastLabaImg = prefix .. "ui/laba/yddhk_010.png"--系统广播图片
M.BroadcastHuaImg = prefix .. "ui/laba/yddhk_012.png"--系统广播图片
M.BroadcastLineImg = prefix .. "ui/laba/line.png"--系统广播图片
M.BroadcastGuangBoImg = prefix .. "ui/laba/gg_laba01.png"--系统广播图片


M.Review_hall_shop = prefix .. "ui/hall/Front-hall_0015_18.png"
M.Review_hall_quickStart = prefix .. "ui/hall/ksks_01.png"

--新用户随机头像
M.DefaultHead = prefix .. "share/defaultUserHead/ourhead%d_%d.png"--系统广播图片

--免费金币快捷领取
M.FreeGoldShortCutJson = prefix .. "ui/FreeGoldShortCut.json"

--大厅单包上面游戏入口
M.MainSigleGame = prefix .. "ui/hall/sigleGames%d_%d.png"
--大厅单包房间入口
M.MainSigleRoom = prefix .. "ui/hall/zjh_syanniu0%d.png"

--提示弹窗
M.toolTipsJson = prefix .. "ui/toolTips.json"
M.game_win_font = prefix .. "game_texas/game/win_word_number.png"

M.game_win_anim_bk_all = prefix .. "game_texas/game/game_win_anim_bk_all.png"
M.game_win_anim_wz_01 = prefix .. "game_texas/game/game_win_anim_wz_01.png"
M.game_result_star = prefix .. "game_texas/game/game_result_star.png"

M.pop_win = prefix .. "game_texas/game/victory_pop.png"

--游戏公告弹窗
M.game_quit_pop         = prefix.."ui/gameQuit/game_quit.json"    -- 被踢弹框
--游戏公告弹窗
M.gameHallJSON         = prefix.."ui/gameHall.json"    -- 被踢弹框
M.gameHallPlist         = prefix.."ui/gameHall/zjh_hall/gameHall.plist"
M.gameHallPng         = prefix.."ui/gameHall/zjh_hall/gameHall.png"
M.gameHallTitle_ZJH     = "gamehall_Titile_zhajinhua.png"--游戏大厅标题
M.gameHallTitle_DN     = "gamehall_Titile_douniu.png"--游戏大厅标题
M.gameHallTitle_ZJN     = "gamehall_Titile_zhajinniu.png"--游戏大厅标题
M.gameHallTitle_SK      = "img_shuangQ.png" --游戏大厅标题（双扣）
M.gameHallTitle_DDZ      = "img_DDZ.png" --游戏大厅标题（斗地主）
M.changci_1 = "gamehall__0005_01.png"  --新手场
M.changci_2 = "gamehall__0004_02.png"  --初级场
M.changci_3 = "gamehall__0003_03.png"  --中级场
M.changci_4 = "gamehall__0002_04.png"  --高级场
M.changci_5 = "gamehall__0001_05.png"  --伯爵场
M.changci_6 = "gamehall__0000_06.png"  --尊爵场
M.payloadingbg = "ui/shop/load_bgtwo.png"
M.payloadingtxt = "ui/shop/new loading.png"

M.gameHall_item_1 = prefix .. "ui/changci_item.json"
M.gameHall_item_2 = prefix .. "ui/changci_item_vertical.json"

M.AppreciateExchangeJson = prefix.."ui/appreciate_exchange.json"
--奖券start
M.FocasViewJson = prefix.."ui/Focas.json"
M.FocasInfoJson = prefix.."ui/Focas_2.json"
M.FocasRuleJson = prefix.."ui/Focas_3.json"
M.FocasRecordJson = prefix.."ui/Focas_4.json"
M.GetFocasJson = prefix.."ui/Focas_5.json"
M.MineRecordJson = prefix.."ui/Focas_6.json"
M.GetGoodsJson = prefix.."ui/Focas_7.json"
M.GetGuaGuaCardSuccessJson = prefix.."ui/Focas_8.json" --刮刮卡兑换成功的界面
M.GuaguaCardInfoJson = prefix.."ui/GuaguaCardInfo.json" --刮刮卡详情的界面
M.GuaguaCardSiteInfoJson = prefix.."ui/GuaguaCardSiteInfo.json" --刮刮卡投注站信息
M.getFocasImg = prefix.."ui/Focas/getfocasIcon%d.png"
M.GoodsStatus1 = prefix.."ui/Focas/fk_ms.png"
M.GoodsStatus2 = prefix.."ui/Focas/fk_xs.png"
M.focas_indiana_record_status = prefix.."ui/Focas/focas_indiana_record_status.png"
M.fkDuiHuanTools = prefix.."ui/Focas/fk_cardTools_%d.png"

--奖券end

M.hall_bg2 = prefix .. "ui/hall/hall_bg2.png" --主页背景图普通
M.hall_bg1 = prefix .. "ui/hall/hall_bg.png" --主页背景图iphoneX
M.nogamebg = prefix .. "ui/hall/nogame_item.png"

M.waitLoadingAni = prefix .. "share/animation/waitLoading/waitLoading.ExportJson"--进游戏等待界面动画
M.gamewaitLoadingAni = prefix .. "share/animation/gamewaitLoading/gamewaitLoading.ExportJson"--进游戏等待界面动画


--赛事大厅
M.matchingHallViewJson = prefix.."ui/matchingHallView_1.json"
M.MatchingRuleJson = prefix.."ui/matchingRule.json"
M.MatchingFocasImg = prefix.."ui/matchingHall/focas.png"
M.matching_rank_img = prefix.."ui/matchingHall/matchingrank/rankbg4.png"
M.nextrewardImg0 = prefix.."ui/matchingHall/nextreward.png"
M.nextrewardImg1 = prefix.."ui/matchingHall/nextreward1.png"
M.nextrewardImg2 = prefix.."ui/matchingHall/nextreward2.png"
M.levelImgLeft = prefix.."ui/matchingHall/levelTexture/levelleft%d.png"
M.levelImgRight = prefix.."ui/matchingHall/levelTexture/levelright%d.png"
M.levelImgTitleBg = prefix.."ui/matchingHall/levelTexture/leveltitlebg%d.png"
M.levelImgBg = prefix.."ui/matchingHall/levelTexture/levelbg%d.png"
M.levelImgStar = prefix.."ui/matchingHall/levelTexture/levelxing.png"
M.levelCardImg = prefix.."ui/matchingHall/levelcard/levelcard%d.png"
M.rememberCardImg = prefix.."ui/daoju/card_record_package.png"
M.super_multi_card = prefix.."ui/daoju/super_multi_card.png"
M.baoxingka = prefix.."ui/daoju/baoxingka.png"
M.baoxiang = prefix.."ui/daoju/baoxiang.png"

M.matchingDetail = prefix.."ui/matchingDetail.json"
M.matchingReportJson = prefix.."ui/matchingReport.json"
M.matchingRankJson = prefix.."ui/matchingRank.json"
M.matchingHonor = prefix.."ui/matchingHonor.json"
M.matchingReportAnimation = prefix.."ui/armature_anim/matchingReport/MatchReportAnimation.ExportJson"
M.matchingGuideAnimation = prefix.."ui/armature_anim/matchingGuide/MatchGuideAnimation.ExportJson"
M.matchingStartBtnAnimation = prefix.."ui/armature_anim/MatchingStartBtn/MatchingStartBtn.ExportJson"
M.matching_btn_effect = prefix.."ui/newMatchingHall/matching_btn_effect.png"
M.matching_btn_streak = prefix.."ui/newMatchingHall/matching_btn_streak.png"
M.matchingSImg = prefix.."ui/newMatchingHall/matching_s%d.png"
M.matchingTitle = prefix .. "ui/newMatchingHall/matching_title.png"

M.matching_rank = prefix.."ui/hallrank/matching_rank_%d.png"
M.matching_rank_bg1 = prefix.."ui/hallrank/matching_rank_bg1.png"
M.matching_rank_bg2 = prefix.."ui/hallrank/matching_rank_bg2.png"
M.matchingHoner_item_1 = prefix.."ui/matchingHonor/matchingHoner_item_1.png"

M.chanceCardImg = prefix.."ui/GuaguaCard/guaguaCard_money_%d.png"
M.levelBg = prefix.."ui/matchingHall/levelbg.png"
M.levelFailBg = prefix.."ui/matchingHall/levelbg1.png"
M.levelGuang1 = prefix.."ui/matchingHall/guang01.png"
M.levelGuang2 = prefix.."ui/matchingHall/guang02.png"
M.level_guangAni = prefix .. "share/animation/level_guangAni/level_G0%d.png"
M.levelFont = prefix.."ui/matchingHall/ddz_level.fnt"
M.ddz_level_new = prefix .."ui/matchingHall/ddz_level_new.fnt"
--提示界面按钮图片
M.img_gaoci = prefix.."ui/global/img_gaoci.png"--告辞
M.img_chongzhi = prefix.."ui/global/img_chongzhi.png"--充值
M.img_consure = prefix.."ui/global/btn_normal_351x113_y01.png"--确定
M.img_cancel = prefix.."ui/global/btn_normal_351x113_n01.png"--取消
M.commonTipWindowJson = prefix.."ui/common_tip_window.json"
--开始动画
M.startGameAni = prefix.."ui/armature_anim/kaishi/NewAnimation.ExportJson"
--等级动画
M.levelEndAni = prefix.."ui/armature_anim/levelEndAni/NewAnimation.ExportJson"--普通动画
M.startGameBtnAni = prefix.."ui/armature_anim/startGameBtn/NewAnimation.ExportJson"
--训练场提示
M.startViewJson = prefix.."ui/normalGame.json"

M.weixingongzonghao = prefix .. "ui/popularize/popularize_code.jpg"


--获得物品弹窗
M.DIAMOND_POPUP = prefix.."ui/DiamondPopup.json"
M.default_user_img = prefix .. "ui/common/user_default_123.png"
--大厅推广
M.tuiguangAni = prefix.."share/animation/tuiguang/tuiguangAnimate.ExportJson"
M.tobePromoterTxt = prefix .. "ui/popularize/tobePromoter.png"
M.toSharePromoter = prefix .. "ui/popularize/goToPopularize.png"

--大厅首充礼包
M.firstPayAni = prefix.."ui/armature_anim/firstPay/firstPay.ExportJson"


--恭喜获得特效
M.congratulationAni = prefix.."ui/armature_anim/congratulation/NewAnimation.ExportJson"
M.congratulationPlist = prefix .. "ui/common/congratulation.plist"
M.congratulationTexture = prefix .. "ui/common/congratulation_Particle.png"
--恭喜获得特效旋转BG
M.xuanzhuanRes = prefix.."ui/DiamondPopup/xuanzhuanguang.png"
M.guang2Res = prefix.."ui/DiamondPopup/guang2.png"


--金币场按钮特效
M.matching_game_button = prefix.."ui/armature_anim/matching_game_button/matching_game_button.ExportJson"

--排位赛按钮特效
M.coin_game_button = prefix.."ui/armature_anim/coin_game_button/NewAnimation.ExportJson"
M.wanyuan_Game_Plist = prefix .. "ui/common/lizi.plist"
M.wanyuan_Game_Texture = prefix .. "ui/common/particle_texture.png"

-- 分享相关东西
M.game_result_plist = prefix .. "ui/share/levelnormal/NewAnimation.plist"
M.game_result_texture = prefix .. "ui/share/levelnormal/NewAnimation.png"

-- 恭喜获得弹框
M.get_reward_pop_title = prefix .. "ui/DiamondPopup/title_%d.png"
M.exchangeToUser = prefix .. "ui/DiamondPopup/to_user_txt.png"
M.exchange_get_pop_bg = prefix .. "ui/DiamondPopup/exhcnage_bg.png"

--确认按钮文字
M.confirmBtn_txt = prefix .. "ui/global/btn_normal_351x113_y01.png"


--匹配邀请页面
M.inviteGameJson = prefix .. "ui/invate_game_tips.json"
M.rechargeTipsJson = prefix .. "ui/recharge_tips.json"


-- 用户等级图标
M.userLevelImg = prefix .. "ui/hall/userLevel/user_gameLever_%d.png"

M.qucanjiaImg = prefix .. "ui/global/qucanjia.png"

--登录界面动画
M.Login_loading = prefix.."ui/armature_anim/Login_loading/loading.ExportJson"
M.sunAnimate = prefix.."ui/armature_anim/sunAnimate/loading.ExportJson"

--新手礼包
M.newUserDailyRewardJson = prefix .. "ui/newUserDailyReward.json"
M.newUserRewardType1 = prefix .. "ui/newUserDailyReward/reward_coin.png"
M.newUserRewardType2 = prefix .. "ui/newUserDailyReward/reward_foca_less.png"
M.newUserRewardType3 = prefix .. "ui/newUserDailyReward/card_record_tip.png"
M.newUserRewardType4 = prefix .. "ui/newUserDailyReward/reward_foca.png"

M.obtainRewardBtnImg = prefix .. "ui/newUserDailyReward/newUserDailyReward_obtainRewardBtn.png"
M.obtainedBtnImg = prefix .. "ui/newUserDailyReward/newUserDailyReward_obtainedBtn.png"

M.goAndFinish = prefix .. "ui/global/goAndFinish.png"
M.hongBao = prefix .. "ui/reward/hongBao.png"
M.rewardCup = prefix .. "ui/reward/rewardCup.png"
M.rewardCoinGame = prefix .. "ui/reward/gold_game.png"
M.join = prefix .. "ui/global/join.png"

--首充礼包
M.firstRechargeJson = prefix .. "ui/firstRecharge_1.json"
--新加载动画界面
M.loadingJson = prefix .. "ui/loading.json"
--新加载动画
M.newLoadingAnimate = prefix.."ui/armature_anim/newLoadingAnimate/newLoadingAnimate.ExportJson"

M.btn_red = prefix .. "ui/global/btn_style/btn_red.png"
M.btn_blue = prefix .. "ui/global/btn_style/btn_blue.png"

--破产补助弹窗
M.bankrupt_tipsJson = prefix .. "ui/bankrupt_tips.json"

M.newDDZCoinGame_plist = prefix .. "ui/ddz_hall/newDDZCoinGame.plist"
M.newDDZCoinGame_png = prefix .. "ui/ddz_hall/newDDZCoinGame.png"

M.game_item = prefix .. "game_item_%d.png"
M.poker_icon = prefix .. "poker_icon.png"
M.game_hall_difen = prefix .. "game_hall_difen%d.png"
M.num_icon = prefix .. "num_icon%d.png"

M.game_item_normal = prefix .. "game_item_normal.png"
M.poker_icon_normal = prefix .. "poker_icon_normal.png"
M.game_hall_difen_normal = prefix .. "game_hall_difen_normal.png"
M.num_icon_normal = prefix .. "num_icon_normal.png"

M.game_item_noRander = prefix .. "game_item_noRander.png"
M.poker_icon_noRander = prefix .. "poker_icon_noRander.png"
M.game_hall_difen_noRander = prefix .. "game_hall_difen_noRander.png"
M.num_icon_noRander = prefix .. "num_icon_noRander.png"

M.game_hall_font = prefix .."ui/ddz_hall/newDDZCoinGame_title/game_hall_font%d.fnt"
M.game_hall_font_normal = prefix .."ui/ddz_hall/newDDZCoinGame_title/game_hall_font_normal.fnt"
M.game_hall_font_noRander = prefix .."ui/ddz_hall/newDDZCoinGame_title/game_hall_font_noRander.fnt"

M.usebtn_uable = prefix .."ui/matchingHall/usebtn_uable.png"
M.usebtn = prefix .."ui/matchingHall/usebtn.png"

M.redPackageAnimation = prefix .. "ui/armature_anim/redPackageAnimate/NewAnimationdonghua02.ExportJson"
M.nextrewardbgPng = prefix .. "ui/hall/nextrewardbg.png"
M.redPackageOpenAnimation = prefix .. "ui/armature_anim/redPackageAnimate/NewAnimationdonghua03.ExportJson"

M.newFirstGame_item1 = prefix .. "ui/newFirstGame/newFirstGame_item1.png"
M.newFirstGame_item2 = prefix .. "ui/newFirstGame/newFirstGame_item2.png"
M.newFirstGame_item3 = prefix .. "ui/newFirstGame/newFirstGame_item3.png"
M.newFirstGame_item4 = prefix .. "ui/newFirstGame/newFirstGame_item4.png"

M.horizonItemSelected = prefix .. "ui/armature_anim/gameHallSelected/horizonItemSelected/NewAnimation.ExportJson"
M.verticalItemSelected = prefix .. "ui/armature_anim/gameHallSelected/verticalItemSelected/NewAnimation.ExportJson"

M.flash_bg = prefix .. "ui/global/flash_bg.png";
M.flash_logo = prefix .. "ui/global/flash_logo.png"

M.gameTaskViewJson = prefix .. "ui/gameTaskView.json"
M.gameTask_btn_txt = prefix .. "ui/gameTaskView/gameTask_img_btn_title_%d_%d.png"
M.gameTask_img_gold = prefix .. "ui/gameTaskView/gameTask_img_gold_%d.png"
M.gameTask_img_ticket = prefix .. "ui/gameTaskView/gameTask_img_ticket_%d.png"
M.gameTask_img_panel = prefix .. "ui/gameTaskView/gameTask_img_panel_%d.png"
M.gameTask_img_panel_choose = prefix .. "ui/gameTaskView/gameTask_img_panel_choose_%d.png"
M.gameTask_img_redpack = prefix .. "ui/gameTaskView/gameTask_img_redpack_1.png"

M.TurnTable_tip_1 = prefix .. "ui/TurnTable/zp__0005_01.png"
M.TurnTable_tip_2 = prefix .. "ui/TurnTable/turntable_img_tip.png"

M.playMethod_title_normal = prefix .. "ui/matchingRule/playMethod_title_normal.png"
M.playMethod_title_selected = prefix .. "ui/matchingRule/playMethod_title_selected.png"
M.reward_title_normal = prefix .. "ui/matchingRule/reward_title_normal.png"
M.reward_title_selected = prefix .. "ui/matchingRule/reward_title_selected.png"

M.tool_title_fnt = prefix .. "ui/global/font/tools_title.fnt"
M.gold_title_fnt = prefix .. "ui/shop/goldFont.fnt"
M.tool_icon_loadding = prefix .. "ui/Focas/fk_loading.png"

M.shopToolDetailJson = prefix .. "ui/shop_tool_detail.json"

M.headLevelBox = prefix .. "ui/userinfo/headInfo/headLevelBox_%d.png"

M.hall_menuJson = prefix .. "ui/hall_menu.json"

M.img_active_loading = prefix .. "ui/activity/img_active.png"

M.redPack_btn_exchange = prefix .. "ui/redpack/btn_exchange.png"
M.redPack_fnt = prefix .. "ui/redpack/redpack_numfnt.fnt"

--推广
M.tuiguangViewJson = prefix .. "ui/tuiguangView.json"
M.tuiguangBtnTxt_go = prefix .. "ui/tuiguangView/tuiguangView_txt_go.png"
M.tuiguangBtnTxt_get = prefix .. "ui/tuiguangView/tuiguangView_txt_get.png"

M.tuiguangRuleViewJson = prefix .. "ui/tuiguangRuleView.json"
M.tuiguangOfficalViewJson = prefix .. "ui/tuiguangOfficalView.json"
M.tuiguangFriendInfoViewJson = prefix .. "ui/tuiguangFriendInfoView.json"
M.tuiguangRedPack_numFnt = prefix .. "ui/tuiguangView/tuiguangView_redpackitem_fnt.fnt"

M.redpack_img = prefix .. "ui/tuiguangView/redpack_img.png"

M.share_icon = prefix .. "ui/share/ic_launcher.png"
M.exchangeMallJson = prefix .. "ui/exchangeMall.json"
M.exchangeDetailJson = prefix .. "ui/exchangeDetail.json"
M.exchangePhoneNumberJson = prefix .. "ui/exchangePhoneNumber.json"
M.exchangeShortageJson = prefix .. "ui/exchangeShortage.json"
M.exchangeMallTitle = prefix .. "ui/exchangeMall/exchangeMall_title.png"

M.exchangeMallMenuBtn = prefix .. "ui/exchangeMall/exchangeMall_btn_%d.png"
M.exchangeMallMenuBtnSelected = prefix .. "ui/exchangeMall/exchangeMall_btn_bg_%d.png"
M.exchangeMallFont_btn_1 = prefix .. "ui/exchangeMall/font_btn_1.fnt"
M.exchangeMallFont_btn_2 = prefix .. "ui/exchangeMall/font_btn_2.fnt"

M.tuiguangQipao = prefix .. "ui/hall/qipao.png"

GameRes = M

