STAT_KEY = {}

STAT_KEY.PYWXDDZ_EVENT_SHARE_POP = 100                                 --分享弹窗弹出次数/人数（实际弹出）
STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_SHARE_BTN = 101                     --分享按钮点击次数/人数(好友房邀请或其他非记牌器分享)
STAT_KEY.PYWXDDZ_EVENT_SHARE_SUCCESS = 102                             --成功分享次数/人数
STAT_KEY.PYWXDDZ_EVENT_SHARE_SHARED_CLICK = 103                        --分享链接被点击次数，传type: 1:立即分享，2:立即邀请，3:邀请有礼 0:其他
STAT_KEY.PYWXDDZ_EVENT_SHARE_GET_NEW_USER = 104                        --点击链接新注册用户数
STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_CARD_COUNTER_ICON = 105             --点击记牌器icon, 传scene: 1:大厅，2:牌桌
STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_CARD_COUNTER_SHARE_BTN = 106        --点击记牌器分享（立即分享和立即邀请），传scene: 1:大厅，2:牌桌 via: 1:分享，2:邀请 img_id:分享图片id
STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_CONTINUE_PLAY_BIN = 107             --点击赛事结算继续挑战次数(人数)
STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_RETURN_BTN = 108                    --点击赛事结算返回次数(人数)
STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_GIVEUP_BTN = 109                    --点击赛事结算含泪放弃次数(人数)
STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_TIMEOUT_BTN = 110                   --点击赛事结算分享保级超时次数(人数)
STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_FOUCS_GIFT_BTN = 111                --点击关注有礼按钮
STAT_KEY.PYWXDDZ_EVENT_SHARE_CLICK_INVITATION_ICON = 112               --点击邀请有礼icon, 传scene: 1:大厅，2:牌桌

STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_CLICK_INTO_GAME = 200                --用户点击进入
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_AUTH_SUCCESS = 201                   --用户授权成功
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_CLICK_INTO_HALL = 202                --用户进入大厅
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_ENTER_DESK = 203                     --用户进入房间（包括匹配、好友房）
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_PLAY = 204                           --用户玩牌
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_CLICK_STORE = 205                    --用户点击商场按钮
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_TRY_PAY = 206                        --用户尝试付费
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_PAY_SUCCESS = 207                    --用户付费成功
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_CLICK_VEDIOAD = 208                  --大厅点击激励视频广告 (总点击)
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_PLAY_VEDIOAD = 209                   --大厅点击激励视频广告 (可看状态时点击)
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_VEDIOAD_SUCCESS = 210                --看完激励视频广告
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_VEDIOAD_ERROR = 211                  --激励视频广告拉取失败
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_BANKRUPT_CLICK_VEDIOAD = 212         --破产补助点击看广告次数
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_BANKRUPT_WATCH_VEDIOAD = 213         --破产补助看完广告次数
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_RECORD_SAVE_PHOTO_CLICK = 214        --战绩保存图片点击
STAT_KEY.PYWXDDZ_EVENT_REG_FUNNEL_RECORD_SAVE_PHOTO_SUCCESS = 215      --战绩保存图片保存成功

STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_INTO_HALL = 300                     --登录进入大厅
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_RECONNECT_INOT_HALL = 301           --断线重连进入大厅
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_BACK_INTO_HALL = 302                --游戏内返回大厅
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_INTO_AUTH = 303                     --点击进入到授权
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_AUTH_TO_HALL = 304                  --授权成功到进入大厅
-- STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_CLASSIC = 305                 --大厅点击经典玩法
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_QUICK_START = 306             --大厅点击经典玩法--点击快速开始
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_ROOM = 307                    --大厅点击经典玩法--点击进入各个场次
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_WAIT_SUCC_TIME = 308                --各场次匹配成功时长
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_WAIT_FAIL_TIME = 309                --各场次匹配失败时长
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CHANGE_DESK = 310                   --牌桌内换桌
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_DESK_SETTING = 312            --牌桌内点击设置
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_DESK_SETTING_TAB = 313        --牌桌内点击设置-切换页签
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CREATE_DESK_POPUP = 314             --大厅点击创建房间-弹窗
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CREATE_DESK_ENTER = 315             --大厅点击创建房间-进入房间
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_ENTER_CUSTOM_DESK = 316             --外部被邀请进入好友房-成功进入
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CUSTOM_DESK_INVITE = 317            --好友房点击邀请-切换到邀请页面
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_STAND_UP_OR_SIT_DOWN = 318          --好友房切换站起/坐下

STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_STAND_UP = 318                      --好友房切换站起
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_SIT_DOWN = 319                      --好友房切换坐下
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_TASK = 320                    --大厅点击任务
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_ACTIVITY = 321                --大厅点击各活动
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_STORE = 322                   --大厅点击商场
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_SETTING = 323                 --大厅点击设置
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_RECORD = 324                  --大厅点击战绩
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_EMAIL = 325                   --大厅点击邮件
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_RECONNECT = 326                     --断线重连次数

STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_MATCH_WAIT_SUCC_TIME = 327          --赛事点击匹配→进桌。各段位平均匹配耗时
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_MATCH_CLICK_HALL_ENTER = 328        --赛事.点击大厅赛事入口
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_MATCH_CLICK_WAIT = 329              --赛事点击匹配按钮
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_MATCH_WAIT_SUCC = 330               --赛事成功进桌

STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_LOADING_WAIT = 331                  --loading 0-100 界面耗时
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_MAIN_HALL_TO_ALL_PLAY_WAIT = 332    --从主界面点击所有玩法，页面加载时间
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_ALL_PLAY_TO_DESK = 333              --从所有玩法中选择一个牌局进入，页面加载时间
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_DESK_TO_MATCH = 334                 --从牌局中点击匹配到匹配界面，页面加载时间
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_MATCH_SUCC_WAIT = 335               --匹配成功到打牌界面，页面加载时间
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_MATCH_RETUREN_HALL = 336            --从大厅点击比赛场到赛事主页，页面加载时间
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_ENDGAME_INTER_WAIT = 337            --点击残局闯关到进入残局大厅，页面加载时间

--区分首次加载
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_EMAIL_FIRST_LOAD = 338          --大厅点击邮件（首次加载）
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_RECORD_FIRST_LOAD = 339         --大厅点击战绩（首次加载）
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_SETTING_FIRST_LOAD = 340        --大厅点击设置（首次加载）
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_WELFARE_FIRST_LOAD = 341        --大厅点击登录礼包（首次加载）
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_FOCUS_FIRST_LOAD = 342          --大厅点击关注有礼（首次加载）
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_SHOP_FIRST_LOAD = 343           --点击商城（首次加载）
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_CARD_COUNTER_FIRST_LOAD = 344   --大厅点击记牌器（首次加载）
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_ENDGAME_FIRST_LOAD = 345        --大厅点击进入残局（首次加载）
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_CREATE_ROOM_FIRST_LOAD = 346    --点击限免开启进到好友房（首次加载）
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_MATCH_HALL_FIRST_LOAD = 347     --大厅点击比赛场到赛事主页（首次加载）
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_COIN_HALL_FIRST_LOAD = 348      --大厅点击金币场到金币场大厅（首次加载）

--大厅点击各活动
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_ACTIVITY_CARD_COUNTER = 349     --大厅点击记牌器
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_ACTIVITY_FOCUS = 350            --大厅点击关注有礼
STAT_KEY.PYWXDDZ_EVENT_PERFORMANCE_CLICK_ACTIVITY_WELFARE = 351          --大厅点击登录礼包

-- 每日任务
STAT_KEY.PYWXDDZ_EVENT_DAILY_TASK_POP = 352                               --每日任务页面打开次数
STAT_KEY.PYWXDDZ_EVENT_DAILY_TASK_BTN_GO = 353                            --每日任务前往按钮点击次数

STAT_KEY.PYWXDDZ_EVENT_APP_TO_WX_GAME = 354                               --从APP端进入