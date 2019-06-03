local DDZDesk = import('.DDZDesk.lua')
local NormalDDZDesk = class("NormalDDZDesk", DDZDesk)

function NormalDDZDesk:ctor ()
    self.enterRef = GAME_DDZ_CLASSIC
end

--比赛结束
function NormalDDZDesk:updateCacheByGameover( model )
    loga("比赛结束:\n"..pb.tostring(model))

    self:updateCacheByOneGameover(model)
    --备份数据用于结算
    self.backUpOveroInfo = clone(self._player_info)
    Cache.user:updateNewUserPlayTask(model.app_new_user_play_task)
end

return NormalDDZDesk