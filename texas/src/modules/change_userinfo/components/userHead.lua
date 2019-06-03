local M = class("userHead")

function M:ctor(paras)
    self:initUI(paras)
end

function M:initUI(paras)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.userHeadJson)
    self.headInfo = ccui.Helper:seekWidgetByName(self.root,"headInfo")
    self.playerIcon =  ccui.Helper:seekWidgetByName(self.headInfo,"head")
    self.playerIcon_box = ccui.Helper:seekWidgetByName(self.headInfo,"head_box")
end

function M:getUI()
    return self.root
end

function M:loadHeadImage(portrait,sex,icon_frame,icon_frame_id)
    self.playerIcon:removeAllChildren()
    Util:updateUserHead(self.playerIcon, portrait, sex, {add = true, sq = true, url = true})
    self:loadHeadBoxImage(icon_frame,icon_frame_id)
end


function M:loadHeadBoxImage(icon_frame,icon_frame_id)
    --加载头像框
    -- self.playerIcon_box:removeAllChildren()
    self.playerIcon_box:setVisible(true)
    -- if icon_frame then
    --     self:setHeadByUrl(self.playerIcon_box,icon_frame)  
    -- end
    if icon_frame_id then
        local level,season = Util:getLevelHeadBoxTxt(icon_frame_id)
        local seasonFont = ccui.Helper:seekWidgetByName(self.playerIcon_box,"seasonFont")
        if string.len(level) > 1 then
            if seasonFont then
                seasonFont:setVisible(true)
                seasonFont:setString("S"..season)
            end
        else
            if seasonFont then
                seasonFont:setVisible(false)
            end
        end
        self.playerIcon_box:loadTexture(string.format(GameRes.headLevelBox, Util:getLevelHeadBoxTxt(icon_frame_id)))
    end
end

function M:loadHeadLordImage(res)
    --加载头像框
    self.playerIcon:removeAllChildren()
    self.playerIcon:loadTexture(res,ccui.TextureResType.plistType)
    -- self.playerIcon:loadTexture(DDZ_Res.DiZhuHead, ccui.TextureResType.plistType)
end

--[[下载图片]]
function M:setHeadByUrl(view,url)
    if view == nil or url == nil then return end
    local kImgUrl = url
    local taskID = qf.downloader:execute(kImgUrl, 10,
        function(path)
            if not tolua.isnull(view) then
                view:loadTexture(path)
                view:setVisible(true)
            end
        end,
        function()
        end,
        function()
        end
    )
end

return M