local M = class("HallItem")

function M:ctor(paras)
    self:initUI(paras)
end

function M:initUI(paras)
    local resJson = GameRes["gameHall_item_" .. paras.type]
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(resJson)
end

function M:getUI()
    return self.root
end

return M