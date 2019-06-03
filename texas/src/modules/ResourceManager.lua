local M = class("ResourceManager")

M.preAnimateRes = {
}

M.prePngRes = {
    DDZ_Res.ddz_game_bg
}

M.prePlistRes = {
    {plist = GameRes.newDDZCoinGame_plist, png = GameRes.newDDZCoinGame_png},
    {plist = DDZ_Res.doudizhu_Plist, png = DDZ_Res.doudizhu_Png},
    {plist = DDZ_Res.matchLevelAnimation_PLIST, png = DDZ_Res.matchLevelAnimation_PNG}
}

function M:ctor()
    self.loadModule = {}
end

function M:preLoad(  )
    local resList = {}

    for i = 1, #M.preAnimateRes do
        local res = {type = "Animate", file = M.preAnimateRes[i]}
        table.insert( resList,res )
    end

    for i = 1, #M.prePlistRes do
        local res = {type = "Plist", file = M.prePlistRes[i]}
        table.insert( resList,res )
    end

    for i = 1, #M.prePngRes do
        local res = {type = "Png", file = M.prePngRes[i]}
        table.insert( resList,res )
    end

    for k, v in pairs(GameRes.preLoadingImg)do
        local res = {type = "Png", file = v}
        table.insert( resList,res )
    end

    for k,v in pairs(DDZ_Res.preloadImg) do
        local res = {type = "Png", file = v}
        table.insert( resList,res )
    end

    self:load({resList = resList})
end

function M:loadPng( img, cb )
    cc.Director:getInstance():getTextureCache():addImageAsync(img, function ( texture )
        if cb then cb(texture) end
    end)
end

function M:loadPlist( plist, img, cb )
    self:loadPng(img, function ( texture )
        --使用texture2D时引擎会误报错  argument #3 is ‘cc.Texture2D'; ‘string’ expected 未发现影响
        cc.SpriteFrameCache:getInstance():addSpriteFramesWithFile(plist, texture)
        if cb then cb() end
    end)
end

function M:loadAnimate( json, cb )
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()

    armatureDataManager:addArmatureFileInfoAsync(json, function (  )
        if cb then cb() end
    end)
end

function M:load(paras)
    if self:checkIsLoad(paras.name) then 
        if paras.cb then paras.cb() end
        return
    end
    local resList = paras.resList
    local cb = paras.cb

    local loadRes
    loadRes = function(index)
        if not resList[index] then
            if paras.name then
                self.loadModule[paras.name] = true
            end
            if cb then cb() end
            return
        else
            local res = resList[index]
            if res.type == "Png" then
                self:loadPng(res.file, function (  )
                    loadRes(index + 1)
                end)
            elseif res.type == "Plist" then
                self:loadPlist(res.file.plist, res.file.png, function (  )
                    loadRes(index + 1)
                end)
            elseif res.type == "Animate" then
                self:loadAnimate(res.file, function (  )
                    loadRes(index + 1)
                end)
            else
                loadRes(index + 1)
            end
        end
    end

    loadRes(1)
end

function M:checkIsLoad(name)
    if name and self.loadModule[name] then return true end
    return false
end

ResourceManager = M.new()

return ResourceManager

