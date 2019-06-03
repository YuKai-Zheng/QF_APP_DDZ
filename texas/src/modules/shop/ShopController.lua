
local ShopController = class("ShopController",qf.controller)

ShopController.TAG = "ShopController"
local shopView = import(".ShopView")

function ShopController:ctor(parameters)
    ShopController.super.ctor(self)
    
end


function ShopController:initModuleEvent()
    
end

function ShopController:removeModuleEvent()

end

-- 这里注册与服务器相关的的事件，不销毁
function ShopController:initGlobalEvent()
    qf.event:addEvent(ET.INVITE_CODE_BE_EXCHANGED,handler(self,self.inviteCodeBeExchanged))
    qf.event:addEvent(ET.NET_APPLY_REWARD_CODE_REQ,handler(self,self.requestExchange))

    -- 金币购买
    qf.event:addEvent(ET.NET_STORE_BUYING_USING_GOLD_REQ, function(args)
        local cmd=CMD.STORE_BUYING_USING_GOLD
        GameNet:send({cmd=cmd, body={item_id=args.item_id}, callback = function (rsp)
            logd("金币购买")
            if rsp.ret == 0 then
                logd("购买成功")
                local model=rsp.model
                if rsp.model.amount then
                    Cache.user.pokerface = rsp.model.amount
                    logd("mypokerface..".. Cache.user.pokerface)
                end
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt ="购买成功"})
                qf.event:dispatchEvent(ET.GET_DAOJU_LIST,{})
            else
                logd("购买失败")
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            end
        end})
    end)

    qf.event:addEvent(ET.OPEN_SHOP_VIEW, function ( args )
        self.shopView = PopupManager:push({class = shopView, init_data = args})
        PopupManager:pop()
    end)

    qf.event:addEvent(ET.EVENT_SHOP_JUMP_TO_BOOKMARK, handler(self, self.handlerJumpToBookmark))
    qf.event:addEvent(ET.NET_DIAMOND_CHANGE_SHOP_EVT, handler(self, self.handlerChangeDiamond)) -- 钻石数变动
    qf.event:addEvent(ET.REFRESH_SHOP_GOLD, handler(self, self.handlerChangeGold)) -- 金币数变动
    qf.event:addEvent(ET.EVENT_SHOP_AD_DOWN_FINISH, handler(self, self.handlerDownAdFinish)) -- 广告下载完成
    qf.event:addEvent(ET.FIRSTRECHARGE_PAYSUCCESS_REFRESH_SHOP, handler(self, self.refreshShopList)) -- 首充成功后刷新商品列表
end

function ShopController:inviteCodeBeExchanged(paras)
    logd("兌換邀請碼，或者被兌換邀請碼")
    if paras == nil or paras.model == nil then return end
    local name = paras.model.friend_nick
    local tips = paras.model.uin == Cache.user.uin and GameTxt.exchange_tips7 or string.format(GameTxt.exchange_tips6,name) 
    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = tips})
end

function ShopController:requestExchange(paras)
    if paras == nil or paras.txt == nil then return end
    GameNet:send({cmd = CMD.APPLY_REWARD_CODE,txt=GameTxt.net002,body = {reward_code = paras.txt},callback = function(rsp) 
        if rsp.ret == 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.exchange_tips1})
        elseif rsp.ret == 1 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.exchange_tips3})
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
        end
    end})
end


function ShopController:initGame()
	
end

function ShopController:initView(parameters)
end

-- 标签页跳转
function ShopController:handlerJumpToBookmark( args )
    local shopView = PopupManager:getPopupWindowByUid(self.shopView)
    if not isValid(shopView) then return end
    shopView:jumpToBookmark(args.bookmark)
end

-- 钻石数变动
function ShopController:handlerChangeDiamond( args )
    local shopView = PopupManager:getPopupWindowByUid(self.shopView)
    if not isValid(shopView) then return end
    shopView:updateMoneyNumber(2)
    qf.event:dispatchEvent(ET.HALL_UPDATE_INFO)
end

-- 金币数变动
function ShopController:handlerChangeGold( args )
    local shopView = PopupManager:getPopupWindowByUid(self.shopView)
    if not isValid(shopView) then return end
    shopView:updateMoneyNumber(1)
    qf.event:dispatchEvent(ET.HALL_UPDATE_INFO)
end

-- 广告下载完成
function ShopController:handlerDownAdFinish( args )
    local shopView = PopupManager:getPopupWindowByUid(self.shopView)
    if not isValid(shopView) then return end
    shopView:adjustCommonView(2)
end

-- 首充支付完成
function ShopController:refreshShopList( args )
    local shopView = PopupManager:getPopupWindowByUid(self.shopView)
    if not isValid(shopView) then return end
    shopView:refreshShopList()
end



function ShopController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"shop")
    local FreeGoldShortCut = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.freegoldshortcut)
    if FreeGoldShortCut == nil then
        PopupManager:removeAllPopup()
    end
    ShopController.super.remove(self)
end

return ShopController