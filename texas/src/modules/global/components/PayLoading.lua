local PayLoading = class("PayLoading", function ( paras )
    return cc.Scale9Sprite:create(GameRes.payloadingbg)
end)
PayLoading.TAG = "PayLoading"

function PayLoading:ctor()
    self.winSize = cc.Director:getInstance():getWinSize()
    self:init()
end

function PayLoading:init()
    self:setCapInsets(cc.rect(10,10,1,1))
    self:setContentSize(cc.size(1189,256))
    self:setPosition(self.winSize.width/2,self.winSize.height/2)

    self.txt = cc.Sprite:create(GameRes.payloadingtxt)
    self.txt:setPosition(self:getContentSize().width/2,self:getContentSize().height/2 -84)
    self:addChild(self.txt,2)
    local armatureDataManager = ccs.ArmatureDataManager:getInstance()
    armatureDataManager:addArmatureFileInfo(GameRes.ShopLoadingAni)
    local loadingAni = ccs.Armature:create("shoploading")
    loadingAni:setPosition(self:getContentSize().width/2,self:getContentSize().height/2+30)
    loadingAni:getAnimation():playWithIndex(0)
    self:addChild(loadingAni,2)
end
return PayLoading
