
local M = {}


M.dft_app_name = "我要斗地主"

M.string001 = "思考中"
M.string002 = "弃牌"

M.string003 = "底池 : "


M.string004 = "all in"
M.string005 = "跟注"
M.string006 = "加注"
M.string007 = "看牌"
M.string101 = "亮牌"

M.string008 = {"高牌","对子","两对","三条","顺子","同花","葫芦","四条(金刚)","同花顺","皇家同花顺"}

M.string009 = "%s:%s号桌  %s"
M.game_must_spend_str = "  前注:%s"

M.string011 = "万"
M.string012 = "亿"
M.string013 = "千万"

--rank start--
M.string501 = "周战绩榜"
M.string502 = "竞技分榜"
M.string503 = "竞技分周榜"
M.string504 = "财富榜"
M.string505 = "赢得%s个底池"
M.string506 = "竞技分:"
M.string507 = "%s分"
--rank end--

--0 年 1 月 ("年","月","周","天","时","分")
M.TimerUnitStr = {
    "年","个月","周","天","小时","分钟"
    };
--gameChat start--
M.string631 = {"ALL IN 他!","搏一搏，单车变摩托","快点下注吧，时间宝贵","各位爷，让看看牌再加钱吧",
    "莫偷鸡！偷鸡必被抓","你牌技这么好，地球人知道吗？","冲动是魔鬼，冷静！",
    "很高兴能和大家一起打牌","赢钱了别走，留下你的姓名","打诚信德州，不偷不抢",
    "有埋伏？不要轻举妄动","难道你看穿我的底牌了吗？",
    "冤家牌，没办法","你真是一个天生的演员。"
    }
M.game_chat_0 = {
    chatInfo_1 = "快点，我已经寂寞难耐了",
    chatInfo_2 = "想快点输你就全下吧",
    chatInfo_3 = "厉害啊，我一不小心就赢了好多",
    chatInfo_4 = "你是手滑了么？敢跟注我",
    chatInfo_5 = "打得不错，但下局没那么好运了",
    chatInfo_6 = "别怂！全部人都跟到底",
    chatInfo_7 = "这烂牌..根本停不下来",
    chatInfo_8 = "我全押，你敢跟吗？",
    chatInfo_9 = "牌小就不要跟我玩",
    chatInfo_10 = "不要走，决战到天亮",
    chatInfo_11 = "搏一搏，单车变摩托",
    chatInfo_12 = "请尊重Dealer"}
M.game_chat_1 = {
    chatInfo_1 = "你打牌怎么比女生还慢啊",
    chatInfo_2 = "太猴急了吧？人家想慢点打",
    chatInfo_3 = "敢跟注你姑姑，钱太多了吧",
    chatInfo_4 = "跟到底啦，人家喜欢真男人",
    chatInfo_5 = "怕了？真是胆小如鼠",
    chatInfo_6 = "烂牌天天有，今年特别多",
    chatInfo_7 = "我真不想说你，你个怂货",
    chatInfo_8 = "牌小就不要跟我玩",
    chatInfo_9 = "这都能赢？什么运气啊",
    chatInfo_10 = "不要走，决战到天亮",
    chatInfo_11 = "搏一搏，单车变摩托",
    chatInfo_12 = "请尊重Dealer"}
M.string632 = "请输入.."
M.string633 = {"/g", "/zz","/zy", "/cry","/cool",
        "/shit", "/naughty", "/speechless", "/angry","/sleep", 
        "/shy", "/crazy", "/happy", "/kiss", "/ama",
        "/knif", "/wow", "/ogle", "/gri","/h",
        "/ee", "/fist", "/love", "/pray", "/smile",
        "/hb","/yea","/whirr","/pitiful","/bye"}
M.string634 = {"/allin", "/help","/hi", "/feck","/check",
    "/aa", "/omg", "/you", "/no","/ha"}

M.string651 = "立即领取"
--gameChat end--
--gameShop start--
M.string671 = "购买金币"
M.string672 = "补充筹码"
M.string673 = "最小买入:%s"
M.string673_1 = "最小买入%s"
M.string674 = "最大买入:%s"
M.string674_1 = "最大买入%s"
M.string675 = "现有金币:%s"
M.string676 = "设置筹码成功,下局开始将自动更换.."
M.string677 = "设置筹码失败,请稍后再试.."
M.string678 = "¥%d"
--gameShop end--

--setting start
M.string701 = "账号"
M.string702 = "游戏选项"
M.string703 = "其他"
M.string704 = "版本"
M.string705 = "新手教程"
M.string706 = "关于"
M.string707 = "帮助"
M.string708 = "震动"
M.string709 = "音效"
M.string710 = "音乐"
M.string_help_panel_btn_1 = "玩法介绍"
M.string_help_panel_btn_2 = "操作介绍"
M.string_help_panel_btn_3 = "牌型介绍"
M.string_help_panel_btn_4 = "功能介绍"
M.string_help_panel_btn_5 = "常见问题"
M.string_help_scrollview4_btn_1 = "弃牌"
M.string_help_scrollview4_btn_2 = "跟注"
M.string_help_scrollview4_btn_3 = "加注"
M.string_help_scrollview4_btn_4 = "ALL in"
M.string_help_scrollview4_btn_5 = "看或弃"
M.string_help_scrollview4_btn_6 = "自动看牌"
M.string_help_scrollview4_btn_7 = "跟任何注"
M.string_help_scrollview4_txt_1 = "牌不好，就选择弃牌，放弃这次对局"
M.string_help_scrollview4_txt_2 = "如果觉得牌不错，就可以跟"
M.string_help_scrollview4_txt_3 = "如果觉得牌优势很大，就可以加注"
M.string_help_scrollview4_txt_4 = "对牌很有信心，就All in（全下）吧"
M.string_help_scrollview4_txt_5 = "首选看牌，如果需要下注则选择弃牌"
M.string_help_scrollview4_txt_6 = "自动看牌"
M.string_help_scrollview4_txt_7 = "自动选择跟任何注"
--setting end

M.string_shop_txt1 = "购买金币"
M.string_shop_txt3 = "道  具"
M.string_shop_txt2 = "兑换专区"
M.string_shop_item_txt1_1 = "1元=%s金币"
M.string_shop_item_txt1_2 = "金币"
M.string_shop_item_txt2 = "¥ 1"
M.string_shop_item_txt3 = "="
M.string_shop_item_txt4 = "%s金币"
M.string_shop_item_txt5 = "售价:%s元"
M.string_shop_item_txt6 = "(%s金币)"
M.string_yuan = "%s元"
M.string_shop_item_txt7 = "(%s张)"
M.string_rmb_to_diamond = "￥%d=%.1f钻石"
M.string_addmore_to_diamond = "1元=%q钻"
M.string_car_name_1 = "甲壳虫"
M.string_car_name_2 = "宝马5系"
M.string_car_name_3 = "特斯拉"
M.string_car_name_4 = "玛莎拉蒂总裁"
M.string_car_name_5 = "兰博基尼"
M.string_car_name_6 = "布加迪威航"

M.string_pay_method_wx = "微信支付"
M.string_pay_method_zfb = "支付宝支付"
M.string_pay_method_yl = "银联支付"
M.string_pay_method_as = "Apple支付"

M.login001 = "努力加载中..."
M.main001 = "请求信息中..."

M.main002 = "总局数 : %d"
M.main003 = "入局率 : %d%%"
M.main004 = "胜率 : %d%%"
M.main005 = "最大赢取 : %s"
M.main006 = "最大手牌"
M.main007 = "%s个"
M.main008 = "%s金币"

M.main002_hide = "总局数 :"
M.main003_hide = "入局率 :"
M.main004_hide = "胜率 :"
M.main005_hide = "最大赢取 :"
M.main006_hide = "最大手牌 :"

M.gameLoaddingTips001 = {
    "忍是为了下次all in",
    "你不能控制输赢,但能控制输赢的多少",
    "应该懂得什么时候放弃",
    "赌的不是运气,赢的是你的智慧",
    "冲动是魔鬼,心态好,运气自然来"
}

M.gameLoaddingTips002 = {
    "真正的绅士，不会谈论离别的女人和错过的底牌",
    "尊重对手就是尊重自己的钱包！",
    "软的怕硬的，硬的怕不要命的",
    "比赛8字口诀---先紧后松,先软后硬",
    "别指望狗屎运能给你带来胜利",
    "只要你活的比对手时间长你就赢了",
    "那个一直弃牌的傻瓜其实是才是能一口吞掉你的巨鲨",
    "装成保守的牌手，因为这样别人会把你的底牌想象的无限大",
    "打牌不偷鸡是不行的，老是偷鸡更是不行的",
    "不要只看到偷鸡成功的，还要看到有些为了鸡丧命的"
}
M.gameLoaddingTipTitle = "小贴士: "

--beauty start--
M.string801 = "我的认证"
M.string802 = "最新认证"
M.string803 = "上周排行"
M.string804 = "本周排行"
M.string805 = "认证特权"
M.string806 = "认证说明"
M.string807 = "申请认证"
M.string808 = "(未认证)"
M.string809 = "领取日奖"
M.string810 = "领排行奖"
M.string811 = "生活照头像,所有玩家可见"
M.string812 = "手机拍摄头像,仅客服可见"
M.string813 = "认证通过立即获得20,000金币哦~！"
M.string814 = "1.照片清晰,五官端正,无明显遮掩物\n2.上传的生活照为玩家均可见\n3.手机拍照(判断是否本人),仅客服可见\n4.如果两张照片均认证通过,且为同一人则认证通过\n5.认证通过即可享受美女特权"
M.string815 = "提交认证成功！"
M.string816 = "认证中"
M.string817 = "已通过"
M.string818 = "上周获得价值 %d金币的礼物"
M.string819 = "本周获得价值%d金币的礼物"
M.string818_s = "上周获得价值%s金币的礼物"
M.string819_s = "本周获得价值%s金币的礼物"
M.string820 = "(认证被拒)"
M.string821 = "(认证通过)"
M.string822 = "(认证中)"
M.string823 = "1.美女认证通过即可获得20000金币\n2.收获礼品时可获得礼品价值30%的金币\n3.每日登录额外领取2000金币\n4.在商城购买金币加成5%\n5.上周前三名美女获得排行奖励\n6.上周前三名美女上线全部播报\n7.拥有美女私人相册"
M.string824 = "上周获得价值%d金币的礼物"
M.string825 = "本周获得价值%d金币的礼物"
M.string826 = "本周获得价值%d金币的礼物"
M.string827 = "领取成功"
M.string828 = "提交认证成功！"
M.string829 = "已领取"
M.string830 = "未认证"
M.string831 = "可选拍照或本地照片为自定义头像"
M.string832 = "仅可选拍照照片为自定义头像"
M.string833 = "照片已提交,不可再次提交！"
M.string834 = "拍照"
M.string835 = "本地照片"
M.string836 = "取消"
M.string837 = "编辑"
M.string838 = "提交认证失败！"
--beauty end--

M.string_notice_change_sex = "您是认证美女，不允许修改性别哦!"
M.string_notice_change_head = "您是认证美女，不允许再上传头像哦!"
M.string_get_extra_gold = "美女收获礼品可获得礼品价值30%的金币哦!"
M.string_beauty_enter_word = "美女\"%s\"进入游戏，大家快关注她吧"

--broadcast start
M.broadcast1= "恭喜%s在%s赢得金币%d万"
M.broadcast2= "恭喜%s在%s赢得金币%d"
M.broadcast_level3_0 = "恭喜"
M.broadcast_level3_1 = "" --广播占位
M.broadcast_level3_2 = "在"
M.broadcast_level3_3 = "" --广播占位
M.broadcast_level3_4 =  "赢得金币"
M.broadcast_level3_5 = "" --广播占位
M.broadcast_level3_6 = "万"
--broadcast end

M.string856 = "请选择您要赠送的礼物"
M.string857 = "赠送礼物才能加好友哦~亲"
M.string858 = "确定赠送"
M.string859 = "取消赠送"
M.string860 = "取消关注成功"
M.string861 = "好友请求已发送"
M.string862 = "关注成功"
M.string863 = "赠送成功"


M.string901 = "日常奖励"
M.string902 = "成就奖励"
M.string903 = "ID："
M.string904 = "昵称："
M.string905 = "性别："
M.string906 = "修改成功"
M.string907 = "名字不能为空"

M.login001 = "努力加载中..."
M.net002 = "加载中..."
M.reConnect = "网络恢复中..."
M.net003 = "正在处理..."

M.game201 = "游戏尚未结束，现在离开将不退还已下注筹码，是否强行退出？"
M.game202 = "正在坐下..."
M.game203 = "等待游戏开始..."
M.game204 = "你确定要退出么？"
M.game205 = "确定"
M.game206 = "点错了"
M.game207 = "坐下失败，请稍后再试.."

M.login002 = "拉取服务器信息中"
M.login003 = "登录服务器中"
M.login004 = "拉取服务信息超时，请检查你的网络..."
M.login005 = "网络链接失败，请检查你的网络"
M.login006 = "登录失败，请尝试其他方式登录"
M.login007 = "        由于您的账号（ID:%d）存在异常，已被系统封停，如有疑问请联系客服QQ:2048260042"
M.login008 = "        由于您的账号存在异常，已被系统封停，如有疑问请联系客服QQ:2048260042"
M.net005 = "拉取内容中..."
M.net006 = "处理订单中..."
M.nettimeout = "网络请求超时,请稍后再试"

M.task001 = "任务完成"
M.task002 = "您的金币+%s"
M.task003 = "您成功获取了%s金币"
M.task003_1 = "您成功获取了%s奖券"
M.task005_1 = "您成功领取了%s金币"
M.task006_1 = "您成功获取了%s个记牌器（局）"
M.task005_0 = "您成功获取了%s金币+%d奖券"
M.task002_new = "您拥有的金币达到:%s"
M.task003_new = "获得奖励:"
M.task004 = "您成功获取了%s钻石"

--支付提示框 start--
M.global_string001 = "你确定要花"
M.global_string002 = "元购买"
M.global_string003 = "金币吗？"
M.global_string004 = "首次充值再送"
M.global_string005 = "金币哦！"
M.global_string006 = "客服电话:400-640-8016"
M.global_erroStr = "未知错误!"
M.global_exitStr = "您已退出了房间"
M.global_exit_desk_failed = "退桌失败. 错误码:%d"
M.global_request_timeout = "请求超时"
--支付提示框 end--

--破产界面提示 start--
M.global_string101 = "财神正在赶来"
M.global_string102 = "送%d金币"
M.global_string103 = "离财神上门时间："
M.global_string104 = "你今日的救济金已"
M.global_string105 = "%d元获取%s金币"
M.global_string106 = "1元=%s金币"
M.global_string107 = "亲，您还有钱可以去排位赛试试运气嘛!"
M.global_string108 = "成功领取救济金!"
M.global_string109 = "经领取完毕!"
M.global_string110 = "1元=%s金币"
M.global_string111 = "您今日还可以领取"
M.global_string112 = "次补助"
M.global_string113 = "金币"
M.global_string114 = "您今日已领取%d次免费金币，去看看其他优惠吧！"
M.global_string115 = "财神还需"
M.global_string116 = "分"
M.global_string117 = "秒赶到，稍后再来领取吧~"
--破产界面提示 end--

--新手礼包 start--
M.novice_string101 = "支付%d元可获得此礼包  客服热线 0755-26912820"
--新手礼包end--
--[[新手教程start]]
M.course_user2_nick = "夜下飞花"
M.course_user3_nick = "一手好牌"
M.course_status_add = "加注"
M.course_status_follow = "跟注"
M.course_status_all = "All In"
M.course_status_look = "看牌"
M.course_tip1 = "Hi~我是荷官%s,我们先来看一下牌桌内的基本元素吧"
M.course_tip1_ex = "先了解下牌桌内的主要元素。游戏每一局都会给每个玩家发两张牌-\"手牌\",\"手牌\"只有玩家自己能看见。桌上还会发五张\"公共牌\",\"公共牌\"所有玩家可见。"
M.course_tip2 = "牌型大小从大到小如左图所示。您的牌型组成就是\"手牌\"+\"公共牌\"的任意五张牌组合的最大牌型。您现在的牌型就是葫芦(三条带一对)"
M.course_tip3="您现在已经了解了德州扑克的基本规则,接下来实战一局吧"
M.course_tip3_ex = "现在轮到您操作了,这个牌跟注是一个不错的选择"
M.course_tip4 = ""
M.course_tip5 = "您现在的牌型是？\n请点击下方的三个选项。"
M.course_tip6 = "恭喜您答对了,您的牌型是对子(一对Q)"
M.course_tip7 = "这里请您选择操作,想想该怎么样。"
M.course_tip8 = ""
M.course_tip9 = "当您或其他玩家弃牌后,您已下注的筹码不会退回,您也退出了本轮牌局。"
M.course_tip10 = "第4张牌公共牌发了,您的牌型又发生了变化,您现在的牌型是？"
M.course_tip11 = "恭喜您答对了,您的牌型是两对(对A+对Q)"
M.course_tip12 = "现在轮到您操作了,您的牌力不错，可以加注也能跟注,这里我们先跟注看看吧。"
M.course_tip13 = ""
M.course_tip14 = "最后一张公共牌出来,您的最终牌型已经确定,您现在的牌型是？"
M.course_tip15 = "恭喜您答对了,您的牌型是葫芦(三条A+一对Q)"
M.course_tip16 = "轮到您操作了,葫芦已经是很大的牌型了,您应该可以取得胜利,Allin吧,赢光对手所有的筹码。"
M.course_tip17 = "最后一轮下注完,剩余玩家将亮牌比大小,这时可看见对方的手牌,他的成牌是同花,没有您的葫芦大,您赢了!"
M.course_tip18 = ""
M.course_tip19 = "最后来了解下牌局中的其它功能吧,筹码不够了可随时增加,聊天、互动让你的牌局不再寂寞!"
M.course_tip20 = "恭喜您完成了新手特训,对基本规则已经了解。德州扑克只有4个操作：看牌、跟注、加注和弃牌。"
M.course_tip_error1 = "同花顺是指️5张牌一个花色,您的牌不是哦"
M.course_tip_error2 = "顺子是指5张牌点数相连,比如56789"
M.course_tip_error3 = "您中了一对,没有必要现在就弃牌"
M.course_tip_error4 = "\n有人可能拿了两张黑头组成了通花牌型,比您现在的牌力强,保险点还是先选择看牌吧"
M.course_tip_error5 = "三条是指最大牌型里有三张同样点数的牌,且另外两张不是一对"
M.course_tip_error6 = "这么轻易就放弃么？"
M.course_tip_error7 = "亲，别急哦，要学会稳扎稳打"

M.course_continue_txt = "点击屏幕继续..."

M.coruse_card_name1 = "同花"
M.coruse_card_name2 = "顺子"
M.coruse_card_name3 = "对子"
M.coruse_card_name4 = "两对"
M.coruse_card_name5 = "三条"
M.coruse_card_name6 = "同花顺"
M.coruse_card_name7 = "葫芦"


M.course_pop1_tips1 = "底池"
M.course_pop1_tips2 = "庄家"
M.course_pop1_tips3 = "您携带的筹码"
M.course_pop1_tips4 = "公共牌"
M.course_pop1_tips5 = "您的手牌"
M.course_pop1_tips_ex_4 = "(所有玩家可见)"
M.course_pop1_tips_ex_5 = "(仅自己可见)"
M.course_pop1_tips6 = "牌型提示"

M.course_pop2_tips1 = "菜单"
M.course_pop2_tips2 = "点击查看信息"
M.course_pop2_tips3 = "聊天系统"
M.course_pop2_tips4 = "增加筹码"

M.course_end_title="新手教程"
M.course_end_tips = "您已经完成新手引导领取1000金币，对德州扑克已经有初步的了解，接下来让我们一起和玩家对战吧。"
M.course_end_btn1 = "领取"--进入游戏
M.course_end_btn2 = "退出教程"

M.course_input_txt1 = "Hi~欢迎来到"..GAME_NAME.."，这里有各种德州扑克的玩法，如果您还没有了解过德州扑克就让我们一起开始吧！"
M.course_input_txt1_tuhao = "Hi~欢迎来到土豪德州，这里有各种德州扑克的玩法，如果您还没有了解过德州扑克就让我们一起开始吧！"
M.course_input_txt2 = "跳过教程》"
M.course_input_txt3 = "进入新手特训"
--[[新手教程end]]


M.game_level_txt="亲，又赢了！！！您的资产已经达到了%s,这种小场已经不适合您这种赌神了，赶紧去高级场挑战德州高手赢取更多筹码吧！"
M.game_level_challenge="现在就去"
M.game_level_cancel="我不想去"

M.giftname = {"玫瑰花","雞蛋","跑車","別墅","游艇"}
M.giftbroadcast = "%1s送給%2s价值%3d的%4s"
M.exchange_tips1 = "兑换成功"
M.exchange_tips2 = "请输入兑换码"
M.exchange_tips3 = "无效兑换码"
M.exchange_tips4 = "请输入手机号码"
M.exchange_tips5 = "输入错误，请重新输入"
M.exchange_tips6 = "%s兑换了您的邀请码并成为您的好友"
M.exchange_tips7 = "兑换成功，并且添加对方为好友"
M.exchange_tips8 = "请输入正确的兑换码"
M.exchange_huafei_desc = "输入您需要充值的手机号码，兑换的%s元话费将会充值到该号码"

M.head_tip1 = "生活照头像设置成功"
M.head_tip2 = "美女头像设置成功"
M.head_tip3 = "头像设置成功"
M.head_tip4 = "请上传生活照片或自拍照片！"

M.upload_user_icon_status_f1 = "上传头像失败！！！"
M.upload_user_icon_status_0 = "正在上传头像！"

M.string010 = "您的大名:"
M.string_search_room="请输入桌子ID:"
M.string_password="房间密码"
M.string_password_error="房间密码错误"

M.login_txt1 = "请输入账号"
M.login_txt2 = "请输入密码"
M.login_txt3 = "账号或者密码错误"
M.login_txt4 = "登录错误"

M.eounce_txt="来，今天一定要连你的内裤都输掉"
M.user_notline="被挑战者不在线"
M.refuse_challenge="对方拒绝您的挑战,3秒后自动退出..."

M.get_gifts_number = "%s"
M.get_gifts_word = "收到礼物："

M.day_event_btn_word = "立即前往"
M.day_event_txt_word1 = "快乐翻翻翻"
M.day_event_txt_word2 = "充值6元即有机会获得iPhone 6 plus哦!"
M.day_event_txt_word3 = "游戏公告"

M.newResTile = "新的资源版本"
M.newRes = "大侠，我们发现了新的资源，点击确定按钮下载%s的资源包(wifi环境下下载更省流量)。"
M.newResDone = "新的资源下载完成，请点击确定重启游戏。"
M.newResError = "资源下载失败"
M.dingtips = "正在下载中"
M.dingtxt1 = "大侠，正在努力下载中,请稍等..."
M.dingtxt2 = "下载已完成%s%%"

M.promitTitle = "温馨提示"
M.newversion = "发现新版本"

M.game_jh_bet_word = "已下注"
M.game_jh_nomal_btn_word_1 = "比牌"
M.game_jh_nomal_btn_word_2 = "弃牌"
M.game_jh_nomal_btn_word_3 = "看牌"
M.game_jh_nomal_btn_word_4 = "加注"
M.game_jh_nomal_btn_word_5 = "全押"
M.game_jh_nomal_btn_word_6 = "跟注"
M.game_jh_nomal_btn_word_7 = "跟到底"

M.string1200 = "总注 ："
M.string1201 = "单注 ："
M.string1202 = "回合 ："


M.userinfo_name = "称号:"

M.qq_binding_txt = "QQ绑定失败,错误码%s"
M.wx_binding_txt = "微信绑定失败,错误码%s"


M.everyday_reward_string001 = "(剩余%d次)"
M.everyday_reward_string002 = "抽奖次数已用完，连续登录天数越多惊喜越多!"
M.everyday_reward_string003 = "去看看"
M.everyday_reward_string004 = "恭喜获得%s金币"

M.tunrtable_num_string = "剩余%d次"


M.firstpay = "需要¥6.0，客服QQ:1987994750"
M.firstget = "您还有一次抽取iPhone6的机会，请前往活动界面进行抽奖"

M.buy_word = "购买"

M.lobby_txt_1 = "房名/ID"
M.lobby_txt_3 = "最小/大携带"
M.lobby_txt_2 = "小/大盲"
M.lobby_txt_4 = "在玩人数"

M.lobby_person = "人"
M.LaBaSendTxt = "发  送"
M.LabaShopTxt = "个小喇叭"
M.GiftCardShopName = "礼物卡"
M.LabaShopName = "小喇叭 ×15"
M.WeekCardShopName = "银卡"
M.MonthCardShopName = "金卡"
M.WeekVipCardShopName = "周VIP"
M.MonthVipCardShopName = "月VIP"
M.weekcard_pop_desc = "获得当天银卡奖励  "
M.monthcard_pop_desc = "获得当天金卡奖励  "
M.weekcard_leftday_desc ="银卡奖励还剩%s天"
M.monthcard_leftday_desc ="金卡奖励还剩%s天"
M.monthcard_buy_desc ="，请及时购买"
M.weekcard_detail = "银卡详情"
M.monthcard_detail = "金卡详情"
M.common_detail = "点开详情"

M.gold_unit = "金币"
M.right_now_get = "立即获得"
M.every_day_get = "每日首次登录获得"
M.di_desc = "第"
M.day_desc = "天"
M.day_desc_1 = "(%d天)"
M.buySuccess = "成功购买"
M.setting_cancle_btn = "注  销"
M.cancellation_txt = "是否注销当前登录"
M.chat_send = "发送"
M.laba_desc = "可用于在全服发送广播，一次消耗一个。"
M.huafei_desc = "可用于在商城兑换页兑换话费"
M.card_desc_format = "每日首次登录自动获得%d万金币"
M.leftdays_desc = "还剩%s天"
M.giftcard_desc = "购买后获得%d万金币额度，使用礼物卡赠送礼物将不可获得额外赠送金币"

M.guashi = "暂未开放!"
M.coinGameEnable = "该场次暂未开放!"

M.loginRewardDesc = "您已经连续登录%d天,今日可领取"
M.loginReward_jinBiTxt = "金币: "
M.loginReward_huafeiTxt = "话费券"
M.loginReward_jifen = "积  分: "
M.loginReward_huafei_uti = "张"


M.loginReward_gold_fomat = "成功领取%d金币"
M.loginReward_jifen_fomat = "，%d积分"
M.loginReward_huafei_fomat = "，%d话费券"
M.huafei_buzhu_desc = "您的话费券不足"
M.send_laba_succuse = "喇叭发送成功!"
M.txt_meiri = "每日"
M.timeRewardDesc = "可领取奖励，过时清零"
M.txt_wucan = "丰盛午餐："
M.txt_wancan = "豪华晚餐："
M.txt_xiaoye = "奢华宵夜："
M.pocan_desc1 = "玩牌后金币不足"
M.pocan_desc2 = "时可以领取破产补助，每日可获得3次"
M.notice_title = "尊敬的《"..GAME_NAME.."》用户："
M.notice_content = "欢迎来到"..GAME_NAME.."~在这里您可以和高手竞技切磋，交流棋牌的心得技巧哦~"

M.jifen_add_word = "积分+"
M.deafult_wordmsg= "游戏币只限用户本人在游戏中使用，严禁在游戏中及线下进行互相叫卖，转让游戏币行为，一经查出永久封停，账号清零。"
M.deafult_wordmsg_tuhao= "单机德州扑克专业版提供竞技交友平台，严厉禁止并打击不法分子通过单机德州扑克专业版平台进行赌博.倒卖游戏币等行为。"
M.deafult_wordmsg_nick = "系统广播"

M.input_roomerror_tips = "进桌失败,错误码%s"

M.shop_uinit_price = "1元=10000金币"
M.shop_old_price = "原价：%s元"
M.shop_now_price = "售价:￥%s"
M.string_shop_buy_gold_use_diamond = "确认使用%d钻石兑换%s（赠送%s金币）吗？"
M.string_shop_buy_props_use_diamond = "确认使用%d钻石兑换%s吗？"
M.string_shop_buy_props_use_gold = "确认使用%s金币兑换%s吗？"

M.game_shop_getmax_chips = "筹码不足时自动补充到最大"

M.noMoney = "金币不足"

M.hasBinding = "已绑定手机"
M.BindingDesc1 = "绑定手机可以有效的保护您的账号安全，建议您尽可能绑定手机"
M.BindingDesc2 = "绑定成功之后即可获得畅玩礼包"
M.BindingFailedTip = "验证码错误"
M.get_verification_code_failed = "获取验证码失败"
M.get_verification_code_success = "验证码已发送至%s"
M.get_voice_verification_code_failed = "获取语音验证码失败"
M.get_voice_verification_code_success = "我们将致电到您的手机号，语音播报验证码"
M.giftTips = "礼物包空空如也！"
M.gift_day = "天"

M.daShang_failed_desc = "只有坐下才能打赏哦！"

M.friend_isFriend = "已是好友"
M.friend_addFriend_status_0 = "好友请求已发送"
M.friend_addFriend_status_1 = "添加好友成功"
M.friend_addFriend_status_2 = "拒绝添加您为好友"
M.friend_addFriend_status_2_1 =",礼物已放回背包"
M.friend_addFriend_txt_1 = "申请加您为好友并且赠送了礼物"
M.friend_addFriend_txt_2 = "申请添加您为好友，不过他什么也没送"
M.friend_recvInvite_txt_1 = "今天一定要连你的内裤都输掉。"
M.friend_recvRefuseInvite_txt = "%s绝了您的玩牌邀请"
M.friend_input_id_txt = "请输入好友ID:"
M.friend_createRoom_txt_1 = "请输入密码:"
M.friend_createRoom_txt_2 = "来，今天一定要连你的底裤都输掉"
M.friend_sended = "邀请已发送"
M.friend_invite_myself_error = "邀请人不能为自己！"
M.friend_invite_reward_txt_1 = "绑定好友邀请码，即可获得%s金币+%s张奖券奖励"
M.friend_invite_reward_txt_2 = "绑定好友邀请码，即可获得%s金币+%s张奖券+%s积分奖励"
M.friend_invite_count_txt = "邀请好友总人数：%s人"
M.friend_invite_ruler = "规则说明\n1，新用户在注册账号后72小时内可在活动界面绑定邀请人，注册账号超过72小时后则无法绑定。\n2，绑定好友邀请码，邀请人与被邀请人双方均可领取游戏奖励\n3，完成累积邀请任务，可在好友邀请界面领取对应游戏奖励。\n4，好友绑定成功后，好友后续游戏对局产生的活跃积分会以一定比例返还至邀请人账号。\n5，单个账号仅能绑定一次，绑定成功后不可解绑。"

M.share_txt_1 = "我刚刚在《"..GAME_NAME.."》赢取了%s筹码，渣渣们，赶紧前来《"..GAME_NAME.."》膜拜吧~~"
M.share_txt_2 = "我刚刚在《"..GAME_NAME.."》打出了%s牌型，渣渣们，赶紧前来《"..GAME_NAME.."》膜拜吧~~"
M.share_txt_3 = "我刚刚在《"..GAME_NAME.."》通过积分兑换了%s，快来《"..GAME_NAME.."》打牌赚话费啦~"
M.share_txt_4 = "我刚刚在《"..GAME_NAME.."》通过积分兑换了%s，快来《"..GAME_NAME.."》，带你装X带你飞~"
M.share_txt_5 = "快来围观！《"..GAME_NAME.."》%s榜，本赌神排名第%s位，来《"..GAME_NAME.."》超越我吧！"

M.share_labs = {
    "周战绩榜",
    "周盈利榜",
    "日单局榜",
    "财富榜",
    "世界周战绩榜",
    "世界周盈利榜",
    "世界日单局榜",
    "世界财富榜",
    "美女排行",
    "上周美女排行"
}

M.share_game_name_android = ""..GAME_NAME..""
M.share_game_name_ios = ""..GAME_NAME..""
M.share_url_android = HOST_PREFIX..HOST_CN_NAME.."/share_link/android?c="..GAME_CHANNEL_NAME
M.share_url_ios = HOST_PREFIX..HOST_CN_NAME.."/share_link/ios?c="..GAME_CHANNEL_NAME

M.invite_sns = "兑换码：%s，下载后登陆商城输入兑换码获得奖品！"..GAME_NAME.."，邀您来战！"
M.invite_sms = "玩地道双扣，就来搏牛游戏~海量免费金币，邀您来战~"

M.score_exchange_items = {
    {"3000积分","18888金币",2},
    {"20000积分","128888金币",6},
    {"50000积分","388888金币",8},
    {"500000积分","300元话费",10},
    {"2000000积分","20000000金币",13},
    {"3800000积分","iPad Air2",14},
    {"5000000积分","iwatch 运动 42mm",15},
    {"6000000积分","iPhone 6s",16}
}

M.shop_coin_price = "售价:%s万金币"
M.pokerface_desc = "购买后可立即使用Poker Face表情，本表情包仅适用于德州扑克玩法"
M.pokerface_desc_format = "有效期(%d天)"
M.pokerface_daoju_num_desc_format = "Poker Face表情\n包剩余(%d天)"
M.pokerface_daoju_desc_format = "可在牌桌内使用Poker Face表情"
M.PokerFaceShopName = "Poker Face表情包"
M.buygooddialog_title ="确认购买？"
M.buygooddialog_content_format ="Poker Face陪你一起玩牌，仅需%d万金币"
M.buygooddialog_nomoney ="金币不足"
M.game_chat_no_poker_face ="抱歉，您暂未购买Poker Face表情，无法使用"
M.string_shop_tip_1 = "钻石不足，请先补充钻石！"
M.string_shop_tip_2 = "金币不足，请先补充金币！"
M.string_shop_tip_3 = "您的钻石不足，是否补充钻石？"
M.string_shop_tip_4 = "金币不足，请补足再来哦！"
M.string_shop_tip_5 = "为您跳转至道具商场！"
M.string_shop_tip_6 = "钻石不足，为您跳转至钻石商场！"
M.string_shop_tip_7 = "金币不足，为您跳转至金币商场！"

M.setting_txt_open = "开"
M.setting_txt_close = "关"
M.game_reconnect_text = "您的账号已在其他设备上登录，请确保账号安全，是否要重新登录？"
M.game_login_status_change_txt = "您的账号登录状态发生变化，请重新登录！"

M.hot_update_string_1 = "正在加载游戏"
M.hot_update_string_2 = "即将进入游戏"
M.hot_update_string_3 = "请稍后"
M.hot_update_string_4 = "正在进入游戏"
M.hot_update_string_5 = "游戏资源加载失败，请点击屏幕重试！"
M.hot_update_string_6 = "游戏资源加载失败，请点击屏幕重试！"
M.hot_update_string_7 = "优先体验新功能？"
M.hot_update_string_8 = "网络连接超时，请检查您的网络！"
M.hot_update_string_9 = "服务器没有响应，请稍后重试！"
M.hot_update_string_10 = "游戏出现了某些问题，请联系开发人员进行反馈！"
M.hot_update_string_11 = "请求超时，请点击屏幕重试！"

-----------------------------回赠礼物
M.gift_receive_record_format ="%s给您赠送礼物“%s”，返现%d金币"
M.gift_receive_record_name_format ="【%s】"
M.gift_receive_record_mes_format ="%s"
M.gift_receive_record_time_format ="%d-%d-%d"
M.gift_no_record ="还没有人送礼给你哦"
M.gift_rebated ="已回赠"
M.gift_rebate ="回赠礼物"
M.gift_rebate_message_1="送你玫瑰花，愿你的生活充满爱~"
M.gift_rebate_message_2="谢谢你，你是一个好人~！"
M.gift_rebate_message_3="搏一搏，单车变摩托，祝你天天好运"
M.gift_rebate_message_4="来杯啤酒放松一下吧~"
M.gift_rebate_message_5="送你一辆特斯拉，做自己，乐不宜迟。"
M.gift_rebate_message_6="还记得给我送礼，表现很好嘛~赏你大钻戒，继续努力哦！"
M.gift_rebate_message_7="财神常来到，大牌天天爆"
M.gift_rebate_message_8="哼，这礼物群发的吧，回头送个真的来！"




M.customize_roomname_placeholder = "的房间"
M.customize_password_placeholder = "点击设置房间密码"
M.customize_pre_bet = "前注: "
M.customize_blinds = "盲注: "
M.customize_desk_id = "牌桌: "
M.customize_service_fee = "服务费: "
M.customize_game_over = "牌局结束"
M.customize_game_over_tip = "该牌局已结束"
M.customize_share_failed = "分享失败"
M.customize_leak_chips = "您桌上筹码不足，无法开始游戏，系统帮您站起"
M.customize_exchange_chips_tip = "以实际补充筹码数量的%d%%收取服务费"

-------------------------- 性美女-------------------------

M.beauty_three_reward = "奖励:%s金币"
M.beauty_gallery_net = "获取相册中"
M.beauty_share_reward_format = "%d金币"
M.beauty_share_content_format="快来围观，本女神排名第%d，还获得了%s金币奖励，欢迎前来%s膜拜~"


M.vipcard_daoju_desc = "可使用专属标示，隐身功能、入场动画、免费使用贵族表情、好友备注等"
M.vipcard_daoju_num_desc_format = "VIP卡\n(剩余%d天)"
M.vipcard_shop_desc = "购买后立即获得%d万金币、专属\n标示，隐身功能、入场动画、免费\n使用贵族表情、好友备注等"
M.vip_enter_broadcast = "VIP用户\"%s\"进场啦，快来挑战！"
M.vip_hide_function_tip = "隐身功能仅限VIP用户使用!"
M.vip_hide_open_failed = "隐身开启失败"
M.vip_hide_close_failed = "隐身关闭失败"
M.vip_hide_effective_open_tip = "隐身功能在游戏开启"
M.vip_hide_effective_close_tip = "隐身功能在游戏关闭"
M.vip_hide_effective_in_game = "隐身设置将在游戏内生效"
M.vip_hiding_name = "神秘人"
M.vip_hiding_status_desc = "(隐身中)"
M.vip_hiding_userinfo_string_2 = "??"
M.vip_hiding_userinfo_string_3 = "???"
M.vip_detail = "VIP详情"

M.galleryUploadSuc="图片上传成功"
M.galleryUploading="图片上传中"
M.galleryUploadFail="图片上传失败"
M.gameCheckChipToSetTxt = "系统自动帮您按照离桌时的筹码量进行补充"


M.gallery_no_photo = "该用户未上传照片"
M.gallery_photo_caoshi ="超时"

M.remark_no_remark_name = "无备注"
M.remark_not_remark_name ="VIP用户才能修改备注"
M.remark_not_all_space ="备注名不能全是空格"

M.levelup_desc_1 = "您已赢取"
M.levelup_desc_2 = "，是否升入大场赢取更多筹码？"
M.customize_buyin_no_limit = "无限制"
M.customize_buyin_description = "Buy-in上限: %s"
M.customize_buyin_limit_tip_1 = "因为牌局总buyin金额限制，只能补充到%d筹码"
M.customize_buyin_limit_tip_2 = "已达到牌局总buyin金额上限，无法继续补充筹码"
M.customize_buyin_losing_all = "您输完了，请下次继续努力！"

M.games_record_list_index = "第%d手牌"
M.games_record_desk_player_num = "%d人"
M.games_record_details_deskinfo = "%s: %d/%d"
M.games_record_details_classic_mustspend= "必下: %d"
M.games_record_details_customize_mustspend= "前注: %d"
M.games_record_details_deskid = "%d号桌"
M.games_record_details_hiding_status = "(隐身)"
M.games_record_no_record = "当前没有牌局记录!"

M.customize_desk_lock_tip = "只有房主可以给牌局上锁"
M.customize_desk_unlock_tip = "只有房主可以给牌局解锁"
M.customize_desk_lock_success = "设置密码成功"
M.customize_desk_lock_placehold = "设置房间密码"
M.customize_desk_lock_invalidate = "请输入密码"
M.customize_desk_locked_notify = "本牌局成为私密牌局，需要密码进入"
M.customize_desk_unlock_success = "解锁成功"
M.customize_desk_unlocked_broadcast = "本牌局成为开放牌局，无需密码进入"
M.customize_desk_owner_changed_broadcast = "玩家 %s 成为房主"

M.shop_promit_tip_1 = "进入房间金币不足，请补充金币！"
M.shop_promit_tip_2 = "坐下金币不足，请补充金币！"
M.shop_promit_tip_3 = "自动坐下金币不足，请补充金币！"
M.shop_promit_tip_4 = "上庄金币不足，请补充金币！"
M.shop_promit_tip_5 = "创建房间金币不足，请补充金币！"
M.shop_promit_tip_6 = "请选择充值面额"
M.shop_promit_tip_7 = "请选择兑换面额"
M.shop_promit_tip_8 = "充值过程中如有任何疑问请加%s咨询：%s"

M.lobby_must_name = "必下桌"

M.stt_not_support = "语音转换文字功能正在开发中, 敬请期待"
M.stt_convert_error = "语音转换文字失败"
M.stt_microphone_error = "请去“设置”内打开“麦克风”权限"
M.stt_network_error = "网络连接出现问题, 语音转换文字失败"

M.heguan_name_1 = "Ross"
M.heguan_name_2 = "Ross(圣诞装)"
M.heguan_name_3 = "Nancy"
M.heguan_name_4 = "Julie"
M.heguan_name_5 = "Henry"
M.heguan_name_6 = "Mary"
M.heguan_not_change = "坐下后才可以替换您喜欢的荷官"
M.nan_heguan_dashang_content = {"不经意间的打赏确是那么醉人", "打赏越多得到越多", "再来一次打赏，再来一次好牌",
 "据说打赏越多，allin越容易获胜", "赢了别忘了打赏我"}

M.send_gift_tip = "您正在进行送礼操作，确定继续吗？"
M.send_report_ok = "发送成功！"
M.report_no_type = "请选择一个举报理由！"

M.gift_card_daoju_desc_1 = "当前剩余"
M.gift_card_daoju_desc_2 = "金币额度，使用礼物卡赠送礼物将不可获得额外赠送金币"
M.gift_card_tips_content_1 = "您的礼物卡额度还剩余"
M.gift_card_tips_content_2 = "金币，是否优先使用礼物卡赠送？"
M.gift_gold_expend = "消耗："
M.gift_card_rest = "剩余："

M.mit_not_open= "暂未开放，敬请期待"


M.challenge_declaration_txt_1 = "来，今天一定要连你的底裤都输掉"
M.challenge_declaration_txt_2 = "只要你敢来，我一跟到底！"
M.challenge_declaration_txt_3 = "上桌吧，让我看看你的手段。"
M.challenge_declaration_txt_4 = "别瞎晃悠了，来跟我比比牌。"
M.challenge_declaration_txt_5 = "说其他都是假的，有种牌桌上见真章！"
M.challenge_declaration_txt_6 = "快进场，我已经饥渴难耐了！"

M.not_send_gift_to_all = "该场景不支持送给所有人"


M.customize_takein_txt = "带入"
M.customize_takein_max_txt = "最大带入"
M.customize_takein_min_txt = "最小带入"
M.customize_vip_permission_tip = "只有VIP用户才有此权限"
M.input_friend_uin = "请输入好友ID"

------------- 选场大厅------------------
M.chosehall_shengfen_rank = "胜分榜排名:"
M.chosehall_fufen_rank = "负分榜排名:"
M.chosehall_numfen = "%d分"


---私人厂限制
M.private_limit_txt = "限制买入房间"
M.private_nolimit_txt = "无限制买入房间"

M.chosehall_no_rank = "当前并无排名"

M.exchange_product_success_tip = "您已成功购买 %s"
M.exchange_product_failed_tip = "购买 %s 失败"
M.exchange_gift_not_me = "本礼物只支持钻石兑换送自己,不支持赠送他人"

M.shop_currency_diamond = "钻石"
M.shop_currency_gold = "金币"
M.shop_currency_tenthousand_gold = "万金币"

M.waiting_queue_countdown_txt = "(%d秒后自动前往)"
M.waiting_queue_countdown_btn = "进入新桌(%d)"

M.break_hide_card_desc="对隐身的玩家使用破隐卡,可查看他的信息,持续5分钟,只在牌桌内有效"
M.break_hide_card_not_enough = "您的破隐卡不足，请到商城购买"

M.common_detail = "点开详情"

M.enter_ticket_name = "%s门票"
M.enter_ticket_desc_1 = "可用于参加"
M.enter_ticket_desc_2 = "一次消耗一张。有效期至%s"

M.OREADY_GAME = "您的账号正在游戏中,请稍后再试"


M.Daily_login = {
    [1] = '第一天',
    [2] = '第二天',
    [3] = '第三天',
    [4] = '第四天',
    [5] = '第五天',
    [6] = '第六天',
    [7] = '第七天',
}

M.Daily_login_desc = {
    [1] = '金币X',
    [2] = '钻石X',
    [3] = '超级加倍卡X',
    [4] = '记牌器1天X'
}

M.GAMENOTOPEN = "疯狂研发中，敬请期待！"

M.invite_wingame1 = "他们都说我是蒙的"
M.invite_wingame2 = "我仿佛听到背后有人说我帅"
M.invite_wingame3 = "恕我直言，在座的都不会打牌"

M.phizStrings = {[2] = "zhadan"
    , [4] = "qinwen"
    , [1] = "niubei"
    , [3] = "bingtong"
    , [5] = "dianzan"
    , [6] = "meigui"
}
M.MainTips={
    "好习惯就是每天清任务",
    "有充就有送",
    "送人玫瑰，手有余香",
    "今天的奖励都领了吗？",
    "打满50场，决战到天亮！",
    "传头像也是有奖励的",
    "豹子、同花顺、牛牛都想要！",
    "连续登陆7天，每天领7K金币",
    "给荷官打赏是绅士的礼貌",
    "设置里可以调整立即开始的玩法",
    "您有奖励可以立即领取哟"
}
M.INSTALLGAME = "已有下载进行中，请稍后再试"

--奖券start
M.focas_exchange_tips = "您将消耗%d奖券兑换%s"
M.focas_rule = "奖券夺宝：\n选择期待中奖的物品，投入一定数量的奖券进行夺宝。每次投入都会获得一个”夺宝码”。\n只要最终开奖时产生的“幸运码“与自己拥有的”夺宝码”一致（在“夺宝记录“中查看）\n即可获得奖品，投入越多，中奖机会越大！\n每期夺宝只会产生一个“幸运码”。\n夺宝开奖方式分为两种：\n1）【满人次开奖】每期达到指定次数即可开奖；\n2）【定时开奖】达到指定的开奖时间即可开奖；\n若本期未达到最低夺宝次数，则本期奖品流拍，已投入的奖券自动返还至您的账户。\n游戏物品可直接领取获得；话费等实物奖励领奖人需要绑定个人信息及货物寄送信息。\n中奖后请尽快确认个人领奖信息，避免奖励过期\n\n奖券兑换：\n选择你想兑换的奖品，消耗相应数量的奖券即可进行兑换。部分奖品数量有限，先到先得"
M.focas_getfocas={
    {id =1,title="福利任务",info="完成福利任务，可以前往【福利任务】领取"},
    {id =2,title="每日充值 ",info="每日充值满%d钻，可领取%d奖券,每日限领一次"},
    {id =3,title="积分兑换",info="消耗活跃积分兑换奖券"}
}
M.mineDuobaoId = "每次夺宝都会获得一个夺宝码，您参加了%d次"
M.focas_indiana_record_status = {"待开奖","未中奖","领奖","已领奖","已失效"}
M.focas_name_nil = "名字不能为空"
M.focas_phone_nil = "手机号不能为空"
M.focas_phone_len = "手机号不正确"
M.focas_you_bain = "邮编不能为空"
M.focas_di_zhi = "地址不能为空"
M.noFocasTips = "您的奖券不足，无法兑换此物品"
M.noFocasForExchangTips = "您的奖券不足，无法兑换此物品"
M.tooMoreFocasTips = "超过单次最大投注次数，请调整投注次数"
M.duobaoScess = "恭喜您，成功参与本期夺宝！幸运之神即将降临"
M.canotExchangeGoods = "您今日的可兑换数目已达上限，请明日再兑换"
--奖券end

M.activity_invite = "邀请有礼"
M.invite_bind_award_1 = "绑定好友邀请码，即可获得%s金币+%s奖券奖励"
M.invite_bind_award_2 = "绑定好友邀请码，即可获得%s金币+%s奖券+%s活跃积分奖励"

M.invite_bind_error = "好友邀请码不能为空！"
M.invite_award_type = {
    [1] = "金币",
    [2] = "奖券",
    [3] = "积分"
}

M.Matching_rule="　1：每个等级打%d副；初始每个用户0积分，以积分的多少判定输赢，每局只有一个人胜出晋级；\n　2：分数相同且并列第一的，以出牌时间最短的获胜晋级，另外两个用户降级；\n　3：晋级获得的奖励存放在牌桌内，退赛后奖券才会发放到用户的奖券余额中；用户可以在福利中心使用奖券进行实物以及金币兑换；"

M.rankResult = {
    [1] = "晋级",
    [2] = "降级",
    [3] = "--"
}

M.promote_ruler = {
    [1] = "和好友一起玩游戏，轻松赚零花钱",
    [2] = "%d元获取推广员的资格",
    [3] = "进行推广，获取奖励",
    [4] = "奖励规则——我的奖励来源",
    [5] = "每成功推荐一个一级推广员，立奖%d元",
    [6] = "每一级推广员成功推荐一个二级推广员，立奖%d元",
    [7] = "一级用户每次付费，返利%d%%",
    [8] = "二级用户每次付费，返利%d%%"
}

M.band_success = "绑定成功！"
M.band_txt_error = "推荐人ID不能为空！"

M.introduceTxt = "你还不是推广员，购买推广员商品成为并获取返利吧！"
M.rewardIntroduceTxt = "每成功推荐一个一级推广员，立奖%d元喔"

M.shopExtraTxt = "赠送%s"
M.quit_error = "牌局正在进行中，打完这局再走啦~"
--绑定微信
M.bind_wechat_success = "您已成功绑定微信，成为推广员即可享高额推广返利"
M.bind_wechat_ispromoter = "叫上好友玩游戏获取返利，绑定微信即可提现！"
M.bind_wechat_notpromoter = "购买推广员商品成为推广员获取返利，绑定微信即可提现！"

M.bind_wechat_success = "您已成功绑定微信，成为推广员即可享高额推广返利"

M.user_login_status_disabled = "用户登录状态失效，请重新登录！"
M.turntable_duration_time = "活动时间：%s~%s"
M.ckeck_userid_success = "提交成功，系统将在1个工作日后完成审核"
M.turn_table_count_txt = "转盘夺宝，每日首次免费"
M.no_gold_tips = "您的金币不足，是否前往获取金币！"
M.more_game_to_turn_table = "再玩金币场%d局，可获得1次转盘机会"

M.realname_name = "请输入真实姓名"
M.realname_card = "请输入身份证号"

M.Daily_login_info = "每天签到可领取签到奖励"
M.redPackageTip = "打完本局，立得红包"

M.gameTask_rewad_tip = "玩%d局可领"
M.gameTask_is_reward = "已领取"
M.gameTask_reward_txt = {
    "%d金币","%d奖券"
}

M.gameTask_tips = {
    {"还需完成 ", " 局即可领取奖励"},
    {"切换到本场次玩 ", " 局可领奖"},
    "领取全部奖励，刷新任务",
    "本场次今日任务已完成"
}

M.bankrupt_count_tip = "今天第%s次，还剩%s次"

M.need_update_version = "当前版本过低，无法使用该功能，请升级到最新版本后重试"

M.match_hall_fee = "报名费：%d金币"
M.match_next_reward = "每局获胜可得:   x%d"
M.match_next_level = "下段位(%s)"
M.match_next_level_left = "晋级%s奖励"
M.match_current_reward = "每局获胜可得:        x%d"
M.match_next_reward_highest_1 = "最强王者尊享"
M.match_next_reward_highest_2 = "每胜得全服最高奖励！"
M.match_next_level_hightest_1 = "您是全服第%d位"
M.match_next_level_hightest_2 = "荣登王者的玩家！"
M.match_reward_status_1 = "已领取"
M.match_reward_status_2 = "未领取"
M.match_honor_title_1 = "恭喜您在S%d赛季获得%s段位"
M.match_honor_title_2 = "欢迎进入 S%d 赛季"
M.match_honor_beat = "您一共击败了%d名玩家"
M.match_honor_max_level = "您在本赛季获得最高段位是%s"
M.match_honor_reset = "新赛季所有玩家的段位已重置至 %s"
M.match_honor_share = "S%d赛季时间：%s"
M.match_level_desc = {
    [0] = "青铜",
    [10] = "青铜",
    [20] = "白银",
    [30] = "黄金",
    [40] = "铂金",
    [50] = "钻石",
    [60] = "宗师",
    [70] = "王者"
}
M.match_sub_level_desc = {
    [1] = "I",
    [2] = "II",
    [3] = "III",
    [4] = "IV",
    [5] = "V",
    [6] = "VI",
    [7] = "VII",
    [8] = "VIII"
}
M.exchangeMall_offer = "%d折优惠"
M.exchangeMall_diff_phonenumber = "两次输入的号码不一致"
M.exchangeMall_storage = "库存%d件"
M.exchangeMall_remain = "今日已兑 %d/%d 件"

M.no_gold_buy_tips = "您的金币不足，请前往获取金币\n（购买道具后金币不能小于房间准入）"
M.obtainDailyRewardSuccess = "领取奖励成功"

M.matchingTitleWithPoint = "•排位赛"

M.string_redpack = "%s元红包"
M.redpack_success = "已发放"
M.redpack_fail = "无效"

M.tuiguangActivity_desc = {
    "邀请2名好友，即可领取10元红包哦~",
    "叫更多好友一起斗地主，每天领取更多红包"
}

M.redpack_tip = "奖券可以兑换话费, 微信红包,生活用品"

M.tuiguangRule = "\n【活动周期】\n\n本次活动周期%s\n\n【邀请奖励】\n\n1、每邀请一个玩家下载注册游戏，即可获得%s元红包。\n\n2、邀请的玩家完成任务，即可获得对应的任务奖励。\n\n【注意事项】\n\n1、未通过你分享出去的链接下载并登录游戏的则不算你邀请的用户。\n\n2、同一设备码的多个账号视为同一个账号。\n\n3、通过作弊手段的则官方有权进行封号处理。\n\n【奖励领取】\n\n1、本活动页面奖励领取后，关注【我要斗地主公众号】，在公众号里进行提现\n\n"
M.gameExit_normal = "再玩%d局即可领奖，\n您确定离开牌桌吗？"
M.gameExit_normal_1 = "您确定离开牌桌吗？"
M.gameExit_event = "下局胜利即可获得%d奖券，\n您确定离开牌桌吗？"
GameTxt = M
