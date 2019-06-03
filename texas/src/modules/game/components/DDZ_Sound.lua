--声效播放
DDZ_Sound ={}
local uid = 1
local getUID = function( ... )
  uid = uid + 1
  return uid 
end
DDZ_Sound.YaoBuQi = getUID()
DDZ_Sound.YaSi = getUID()
DDZ_Sound.JiaoFen = getUID()
DDZ_Sound.ToBeLord = getUID()
DDZ_Sound.CardOver = getUID()
DDZ_Sound.JiaBei =getUID()
DDZ_Sound.ClickBtn = getUID()
DDZ_Sound.GetCard = getUID()
DDZ_Sound.OutCard = getUID()
DDZ_Sound.TimeOver = getUID()
DDZ_Sound.ShuffleCard = getUID()
DDZ_Sound.GameOver = getUID()
DDZ_Sound.changeHeadType = getUID()
DDZ_Sound.GameStart = getUID()
DDZ_Sound.MINGPAI = getUID()
DDZ_Sound.FAPAI = getUID()
function DDZ_Sound:playSoundChuPai(cardstype,cardvalue,sex)
    local cardSound = {
        [DDZ_CardType.cardType_DanZhang] = function(cardvalue,sex)--单张
        return string.format(DDZ_Res.all_music[string.format("DanPai_%d",sex)],cardvalue)
        end,
        [DDZ_CardType.cardType_DuiZi] = function(cardvalue,sex)--对子
        return string.format(DDZ_Res.all_music[string.format("DuiZi_%d",sex)],cardvalue)
        end,
        [DDZ_CardType.cardType_SanZhang] = function(cardvalue,sex)--三张
          return string.format(DDZ_Res.all_music[string.format("SanDai_%d",sex)],0)
        end,
        [DDZ_CardType.cardType_SanDaiYi] = function(cardvalue,sex)--三带1个
          return string.format(DDZ_Res.all_music[string.format("SanDai_%d",sex)],1)
        end,
        [DDZ_CardType.cardType_SanDaiDui] = function(cardvalue,sex)--三带对子
          return string.format(DDZ_Res.all_music[string.format("SanDai_%d",sex)],2)
        end,
        [DDZ_CardType.cardType_SiDaiEr] = function(cardvalue,sex)--四带二
          return DDZ_Res.all_music[string.format("Sidai_%d",sex)]
        end,
        [DDZ_CardType.cardType_ShunZi] = function(cardvalue,sex)--顺子
          return DDZ_Res.all_music[string.format("ShunZi_%d",sex)]
        end,
        [DDZ_CardType.cardType_LianDui] = function(cardvalue,sex)--连对
          return DDZ_Res.all_music[string.format("LianDui_%d",sex)]
        end,
        [DDZ_CardType.cardType_FeiJiDaiDan] = function(cardvalue,sex)--飞机带单
          return DDZ_Res.all_music[string.format("Feiji_%d",sex)]
        end,
        [DDZ_CardType.cardType_Feiji] = function(cardvalue,sex)--飞机
          return DDZ_Res.all_music[string.format("Feiji_%d",sex)]
        end,
        [DDZ_CardType.cardType_FeiJiDaiDui] = function(cardvalue,sex)--飞机带二
          return DDZ_Res.all_music[string.format("Feiji_%d",sex)]
        end,
        [DDZ_CardType.cardType_SiDaiDui] = function(num,sex)--四带对
          return DDZ_Res.all_music[string.format("Sidai_%d",sex)]
        end,
        [DDZ_CardType.cardType_ZhaDan] = function(num,sex)--炸弹
          return string.format(DDZ_Res.all_music[string.format("Zha_%d",sex)],math.random(0,1))
        end,
        [DDZ_CardType.cardType_WangZha] = function(num,sex)--王炸
          return DDZ_Res.all_music["WangZha"]
        end
    }
    if cardSound[cardstype] then     --出牌
        MusicPlayer:playEffectFile(cardSound[cardstype](cardvalue,sex))
        if cardstype == DDZ_CardType.cardType_FeiJiDaiDan or
          cardstype == DDZ_CardType.cardType_Feiji or
          cardstype == DDZ_CardType.cardType_FeiJiDaiDui then
          MusicPlayer:playEffectFile(DDZ_Res.all_music["Feiji"])
        elseif cardstype == DDZ_CardType.cardType_FeiJiDaiDan then
          MusicPlayer:playEffectFile(DDZ_Res.all_music["Zha"])
        elseif cardstype == DDZ_CardType.cardType_WangZha then
          MusicPlayer:playEffectFile(cardSound[DDZ_CardType.cardType_ZhaDan](cardvalue,sex))
        end
    end
end

--聊天的声音
function DDZ_Sound:playSoundChat(soundtype,sex)
    local cardSound = function(num,sex)--聊天
    loga(string.format(DDZ_Res.all_music[string.format("CHAT_%d",sex)],num))
        return string.format(DDZ_Res.all_music[string.format("CHAT_%d",sex)],num)
      end
    MusicPlayer:playEffectFile(cardSound(soundtype,sex))
end

--要不起,压死,明牌,就剩几张牌了
function DDZ_Sound:playSoundGame(soundtype,sex,soundid)
    local cardSound = {
        [DDZ_Sound.YaoBuQi] = function(num,sex)--要不起
          return string.format(DDZ_Res.all_music[string.format("Guo_%d",sex)],math.random(1,2))
        end,
        [DDZ_Sound.YaSi] = function(num,sex)--压死
          return string.format(DDZ_Res.all_music[string.format("Ya_%d",sex)],math.random(1,2))
        end,
        [DDZ_Sound.JiaBei] = function(num,sex)--加倍
          return string.format(DDZ_Res.all_music[string.format("Jia_%d",sex)],num)
        end,
        [DDZ_Sound.JiaoFen] = function(num,sex)--叫分
          return string.format(DDZ_Res.all_music[string.format("Jiao_%d",sex)],num)
        end,

        [DDZ_Sound.ToBeLord] = function(num,sex)--叫/抢地主
          return DDZ_Res.all_music[string.format("ToBeLord_%d",sex)][num]
        end,

        [DDZ_Sound.CardOver] = function(num,sex)--剩几张牌了
          return string.format(DDZ_Res.all_music[string.format("CardLeft_%d",sex)],num)
        end,
        [DDZ_Sound.changeHeadType] = function(num,sex)--变身
          return DDZ_Res.all_music["changeHeadType"]
        end,
        [DDZ_Sound.ClickBtn] = function(...)--按钮点击
          return DDZ_Res.all_music["BtnClick"]
        end,
        [DDZ_Sound.GetCard] = function(...)--玩家获得手牌
          return DDZ_Res.all_music["GetHandCard"]
        end,
        [DDZ_Sound.OutCard] = function(...)--玩家出牌到桌子
          return DDZ_Res.all_music["OutCardToDesk"]
        end,
        [DDZ_Sound.TimeOver] = function(...)--出牌超时，倒计时3s
          return DDZ_Res.all_music["Overtime"]
        end,
        [DDZ_Sound.ShuffleCard] = function(...)--洗牌
          return DDZ_Res.all_music["ShuffleCard"]
        end,
        [DDZ_Sound.GameOver] = function(num)--游戏结束
          return string.format(DDZ_Res.all_music["gameOver"],num)
        end,
        [DDZ_Sound.GameStart] = function(num)--游戏结束
          return DDZ_Res.all_music["gameStart"]
        end,
        [DDZ_Sound.MINGPAI] = function (num,sex)
          return DDZ_Res.all_music[string.format("MingPai_%d",sex)]
        end,
        [DDZ_Sound.FAPAI] = function(...)--洗牌
            return DDZ_Res.all_music["fapai"]
        end,
    }
    return MusicPlayer:playEffectFile(cardSound[soundtype](soundid,sex))
end
