M  = {}
--牌型 0-单牌 1-对子 2-三张 3-三带一 4-三带二 5-四带二 6-顺子 7-连对 9-飞机带单 10-飞机 11-飞机带对 12-四带两对 19 -炸弹 20-王炸
M.cardType_DanZhang = 0
M.cardType_DuiZi = 1
M.cardType_SanZhang = 2
M.cardType_SanDaiYi = 3
M.cardType_SanDaiDui = 4
M.cardType_SiDaiEr = 5
M.cardType_ShunZi = 6
M.cardType_LianDui = 7
M.cardType_FeiJiDaiDan = 9
M.cardType_Feiji = 10
M.cardType_FeiJiDaiDui = 11
M.cardType_SiDaiDui = 12
M.cardType_ZhaDan = 19
M.cardType_WangZha = 20
M.cardType_Error = -1
--M.cardType_8 = 8
M.cardTypeName = {
 [0]  = "单张",
 [1]  = '对子',
 [2]  = '三张', 
 [3]  = '三带一',  
 [4]  = '三带一对', 
 [5]  = '四带二', 
 [6]  = '顺子',  
 [7]  = '连对',  
 [9]  = '飞机带单', 
 [10]  = '飞机', 
 [11]  = '飞机带对', 
 [12]  = '四带对', 
 [19]  = '炸弹', 
 [20]  = '王炸', 
 [-1] = "问题牌型"
}

DDZ_CardType = M