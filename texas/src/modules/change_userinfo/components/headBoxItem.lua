local M = class("headBoxItem")

function M:ctor(paras)
    self:initUI(paras)
end

function M:initUI(paras)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.headBoxItemJson)
end

function M:getUI()
    return self.root
end

return M