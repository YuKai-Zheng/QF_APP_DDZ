local M = class("GameExit",CommonWidget.BasicWindow)

function M:ctor(paras)
    M.super.ctor(self, paras)
end

function M:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(DDZ_Res.gameExitViewJson)

    self.content = ccui.Helper:seekWidgetByName(self.gui,"content")
    self.btn_1 = ccui.Helper:seekWidgetByName(self.gui,"btn_1")
    self.btn_2 = ccui.Helper:seekWidgetByName(self.gui,"btn_2")

    self.content:setString(paras.content)
end

function M:initClick(paras)
    -- 离开
    addButtonEventMusic(self.btn_2,DDZ_Res.all_music["BtnClick"],function()
        if paras.confirmCb then
            paras.confirmCb()
        end
        self:close()
    end)

    -- 继续游戏
    addButtonEventMusic(self.btn_1,DDZ_Res.all_music["BtnClick"],function()
        if paras.cancelCb then
            paras.cancelCb()
        end
        self:close()
    end)
end

return M