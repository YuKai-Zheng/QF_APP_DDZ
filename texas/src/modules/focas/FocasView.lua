local FocasView = class("FocasView", CommonWidget.BasicWindow)
require("socket")  

FocasView.TAG = "FocasView"

local  FocasRule = import(".components.FocasRule")
local  GuaGuaCardSuccessTip = import(".components.GuaGuaCardSuccessTip")

local HallMenuComponent = import("src.modules.global.components.HallMenuComponent")

local btnType = {
    "guaguaCard",
    "gold",
    "rechargeCard",
    "phone",
    "lifeGood"
}

FocasView.ALWAYS_SHOW = true

function FocasView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    FocasView.super.ctor(self,parameters)
    self:initHallView()
end

function FocasView:init(  )
    qf.event:dispatchEvent(ET.GUAGUACARD_SITE_LIST)
    qf.event:dispatchEvent(ET.GET_WELFARD_INDIANA_LIST)
end

function FocasView:initUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.FocasViewJson)
	self.closeBtn = ccui.Helper:seekWidgetByName(self.gui, "closebtn")--关闭按钮
	self.guizeBtn = ccui.Helper:seekWidgetByName(self.gui, "guizebtn")--规则按钮
	self.guizeBtn:setVisible(false)
	self.jinuBtn = ccui.Helper:seekWidgetByName(self.gui, "jinubtn")--记录按钮

	self.fkBtn = ccui.Helper:seekWidgetByName(self.gui, "fk_bg")--奖券购买按钮
	self.addFkImg = ccui.Helper:seekWidgetByName(self.gui, "fk_buy_mark_img") -- 添加图片
	self.goldBtn = ccui.Helper:seekWidgetByName(self.gui, "gold_bg")--金币购买按钮
	self.diaBtn = ccui.Helper:seekWidgetByName(self.gui, "zuanbg")--钻石购买按钮

    self.duihuanP = ccui.Helper:seekWidgetByName(self.gui,"duihuanlist")--兑换层
    self.duihuanItemP = ccui.Helper:seekWidgetByName(self.gui,"exchangeP")--兑换模板
    self.duihuanItem = ccui.Helper:seekWidgetByName(self.gui,"duihuanitemP")
    self.duobaoP = ccui.Helper:seekWidgetByName(self.gui,"duobaolist")--夺宝层
    self.duobaoItem = ccui.Helper:seekWidgetByName(self.gui,"treasureP")--兑换模板
	self.duobaoP:removeAllChildren()
	self.duobaoP:setItemModel(self.duobaoItem)
	self.diaBtn:setVisible(false)
	self.duobaoP:setVisible(false)
    self.duihuanP:setVisible(true)
    self.duihuanP:setItemModel(self.duihuanItemP)

    self.checkToolsP = ccui.Helper:seekWidgetByName(self.gui,"checkToolsP")--兑换选择栏
    self.checkToolsP:setVisible(false)
    self.checkToolsP:setAnchorPoint(cc.p(0.5, 0))
    self.checkToolsP:setTouchEnabled(false)
    self.checkToolsPOrginSize = self.checkToolsP:getContentSize()
    self.checkItem = ccui.Helper:seekWidgetByName(self.gui,"checkItem")--选择栏item
    self.checkListbg = ccui.Helper:seekWidgetByName(self.gui,"checkListbg")--选择栏背景
    self.checkListbgOrginSize = self.checkListbg:getContentSize()
    self.checkListbg:setVisible(false)
    self.checkToolsP:setPositionX(self.checkListbg:getPositionX())
    self.checkArrow = ccui.Helper:seekWidgetByName(self.gui,"checkArrow")--选择栏背景
    self.checkArrow_left = ccui.Helper:seekWidgetByName(self.gui,"checkArrow_left")--选择栏背景
	
	self:extendBnt(self.jinuBtn)
	self.jinuBtn.updateNumber(Cache.focasInfo.redPoint)
    if FULLSCREENADAPTIVE then
        self.gui:setPositionX((self.winSize.width - 1980)/2)
        self.jinuBtn:setPositionX(self.jinuBtn:getPositionX() + (self.winSize.width - 1980)/2)
        self.menu_panel:setPositionX(self.menu_panel:getPositionX() - (self.winSize.width - 1980)/2)
    end
end

--初始化点击事件
function FocasView:initClick( ... )
	addButtonEvent(self.jinuBtn, function( ... )
		Cache.focasInfo.redPoint = 0
        self.jinuBtn.updateNumber(Cache.focasInfo.redPoint)
        qf.event:dispatchEvent(ET.SHOW_FOCASRECORD_VIEW)
     	qf.event:dispatchEvent(ET.WELFARE_INDIANNA_RECORD)
	end)
	addButtonEvent(self.guizeBtn, function( ... )
		qf.event:dispatchEvent(ET.SHOW_FOCASRULE_VIEW)
	end)
	addButtonEvent(self.fkBtn, function( ... )
		qf.event:dispatchEvent(ET.FOCAS_TASK_VIEW_SHOW_AND_CLOSE_FACAS_VIEW)    
	end)
	addButtonEvent(self.goldBtn, function( ... )
		qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.GOLD})
	end)
	addButtonEvent(self.diaBtn, function( ... )
		qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK, {name = "shop",bookmark = PAY_CONST.BOOKMARK.DIAMOND})
	end)
	addButtonEvent(self.closeBtn, function( ... )
        self:close()
	end)

	addButtonEvent(self.checkArrow_left, function( ... )
		self.checkToolsP:jumpToLeft()
	end)

	addButtonEvent(self.checkArrow, function( ... )
		self.checkToolsP:jumpToRight()
	end)
end

function FocasView:changeBtn(type)
    for i = 0, #self.checkToolsP:getItems() - 1 do
        local item = self.checkToolsP:getItem(i)
        dump(item.type)
        if item.type == type then
            ccui.Helper:seekWidgetByName(item, "itemBg"):setOpacity(255)
        else
            ccui.Helper:seekWidgetByName(item, "itemBg"):setOpacity(0)
        end
    end

    self:initExchangeList(type)
end

--初始化选择界面按钮
function FocasView:initCheckClick( ... )
    self.checkToolsP:setItemModel(self.checkItem)
    self.checkToolsP:removeAllItems()
    local index = 0
    local type = nil
    for i = 1, #btnType do
        if Cache.focasInfo.welfareDetailTypes and Cache.focasInfo.welfareDetailTypes[btnType[i]] then
            self.checkToolsP:pushBackDefaultItem()
            local item = self.checkToolsP:getItem(index)
            item.type = btnType[i]
            item:setVisible(true)
			local title = ccui.Helper:seekWidgetByName(item,"title")
			title:loadTexture(string.format(GameRes.fkDuiHuanTools,i))
            item:setTouchEnabled(false)
            if not type then type = btnType[i] end
            local itemBtn = ccui.Helper:seekWidgetByName(item,"itemBtn")
            itemBtn.type = btnType[i]
            addButtonEvent(itemBtn, function ( sender )
                self:changeBtn(sender.type)
            end)

            index = index + 1
        else

        end
    end

    if type then self:changeBtn(type) end

    if Cache.user.show_chance_card_or_not == 1 then
        self.checkArrow:setVisible(true)
        self.checkArrow_left:setVisible(true)
    else
        self.checkArrow:setVisible(false)
        self.checkArrow_left:setVisible(false)
    end

    if index <= 1 then
        self.checkListbg:setVisible(false)
        self.checkToolsP:setVisible(false)
    else
        self.checkListbg:setVisible(true)
        self.checkToolsP:setVisible(true)

        if index < 4 then
            local bgSize = self.checkListbg:getContentSize()
            local allWidth = index * self.checkItem:getContentSize().width

            self.checkListbg:setContentSize(cc.size(allWidth + 50, bgSize.height))
            self.checkToolsP:setContentSize(cc.size(allWidth, self.checkToolsP:getContentSize().height))
        else
            self.checkListbg:setContentSize(self.checkListbgOrginSize)
            self.checkToolsP:setContentSize(self.checkToolsPOrginSize)
        end
    end
end

function FocasView:initHallView()
    ccui.Helper:seekWidgetByName(self.diaBtn,"zan_num"):setString(Cache.user.diamond)
    if isValid(self.menu) then
        self.menu:updateData()
    end
end

function FocasView:extendBnt(bnt)
    bnt.updateNumber = function (number)
        if number == 0 then bnt.removeNumber() return end
        if number >= 100 then number = 99 end
        local cs = bnt:getContentSize()
        
        local bg = bnt:getChildByName("btnbg")
        if bg == nil then 
            bg = cc.Sprite:create(GameRes.bnt_number_bg)
            bg:setName("btnbg")
            bg:setPosition(cs.width * 0.9, cs.height * 0.9 )
            bnt:addChild(bg)
        end
        
        if number < 0 then return end
        
        local nl = bnt:getChildByName("btnnum")
        if nl == nil then 
            nl = cc.LabelTTF:create(number .. "", GameRes.font1, 30)
            nl:setPosition(cs.width * (number >= 10 and 0.89 or 0.9), cs.height * 0.9)
            nl:setName("btnnum")
            bnt:addChild(nl)
        else
            nl:setString(number .. "")
        end 
    end
    
    bnt.removeNumber = function ()
        bnt:removeChildByName("btnbg")
        bnt:removeChildByName("btnnum")
    end
end

--初始化兑换列表
function FocasView:initExchangeList(type)
    qf.event:dispatchEvent(ET.UPDATE_EXCHANGEINFO_VIEW)

    local index = 0
	
    if not Cache.focasInfo.welfareDetail or #Cache.focasInfo.welfareDetail == 0 then
        self.duihuanP:removeAllChildren()
        return
    end
    
    local data = Cache.focasInfo.welfareDetailTypes[type .. "Item"]

	for k,v in pairs(data) do
        --if v.item_type == self.item_type or (self.item_type == 1 and v.item_type == 9) then
            local item = self.duihuanP:getItem(index/4)
            if not item then
                self.duihuanP:pushBackDefaultItem()
                item = self.duihuanP:getItem(index/4)
            end
            if index%4 == 0 then
                for i = 0, 3 do
                    local goods = item:getChildByName("item_" .. i)
                    if isValid(goods) then
                        goods:setVisible(false)
                    end
                end
			end
            local exchangeGoods = item:getChildByName("item_" .. (index % 4))--self.duihuanItem:clone()
            if not isValid(exchangeGoods) then
                exchangeGoods = self.duihuanItem:clone()
                exchangeGoods:setPosition(index%4*exchangeGoods:getContentSize().width,0)
                item:addChild(exchangeGoods)
                exchangeGoods:setName("item_" .. (index % 4))
            end

            exchangeGoods:setVisible(true)
			
			local taskID = qf.downloader:execute(v.pic, 10,
	        	function(path)
		            if not tolua.isnull( exchangeGoods ) then
		                ccui.Helper:seekWidgetByName(exchangeGoods,"img"):loadTexture(path)
		            end
		        end,
		        function()
		        end,
		        function()
		        end
		    )
			--Util:updateUserHead(ccui.Helper:seekWidgetByName(exchangeGoods,"img"),v.pic, 0, {nojpg = true, url=true})--物品图片
			ccui.Helper:seekWidgetByName(exchangeGoods,"name"):setString(v.name)
			ccui.Helper:seekWidgetByName(exchangeGoods,"num"):setString(Util:getFormatString(v.bet_min))
            addButtonEvent(exchangeGoods,function( ... )
                qf.event:dispatchEvent(ET.SHOW_EXCHANGEINFO_VIEW, {item_id=v.item_id})
			end)
			index = index + 1
		--end
    end

    local maxRow = math.modf( index / 4) 
    if index % 4 > 0 then maxRow = maxRow + 1 end

    local itemNum = #self.duihuanP:getItems()

    if itemNum > maxRow then
        for i = 1, itemNum - maxRow do
            self.duihuanP:removeLastItem()
        end
    end

	self.duihuanP:refreshView()
	self.duihuanP:jumpToTop()
end

--初始化夺宝列表
function FocasView:initTreasureList()
    --需要更新focasInfo界面
    qf.event:dispatchEvent(ET.UPDATE_FOCASINFO_VIEW)
	local timeConvert = function( time )--时间转换（数字转成分，秒，毫秒）例1000 = 00,10,00
		local ms = time % 100 /10                         --秒钟
        local sec = ((time - ms) / 100) % 60          --分钟
        local min = ((time - ms) / 100 - sec) / 60   --小时
        local str_ms = string.format("%01d", ms)
        local str_sec = string.format("%02d", sec)
        local str_min = string.format("%02d", min)
        return str_min,str_sec,str_ms
	end
	--删除不要的商品
	for k,v in pairs(self.duobaoP:getChildren())do
		local isneedRemove = true
		for m,n in pairs(Cache.focasInfo.indianaDetail) do
			if v.nameNum == n.item_id then
				isneedRemove = false
				break
			end
		end
		if isneedRemove then
			self.duobaoP:removeItem(self.duobaoP:getIndex(v))
		end
	end
	local index = 0
	for k,v in pairs(Cache.focasInfo.indianaDetail) do
		local goods
		if not self.duobaoP:getChildByName("goods"..v.item_id) then
			self.duobaoP:insertDefaultItem(index)
			goods= self.duobaoP:getItem(index)
			goods:setName("goods"..v.item_id)
			goods.goodsname = v.name
			goods.indexNum = index
			goods.nameNum = v.item_id
		else
			goods = self.duobaoP:getChildByName("goods"..v.item_id)
		end
		 
		if v.flag == 1 or v.flag == 2 then
			ccui.Helper:seekWidgetByName(goods,"tips"):loadTexture(GameRes["GoodsStatus"..v.flag])
		else
			ccui.Helper:seekWidgetByName(goods,"tips"):setVisible(false)
		end
		ccui.Helper:seekWidgetByName(goods,"name"):setString(v.name)
		ccui.Helper:seekWidgetByName(goods,"num"):setString(v.bet_min)
		local taskID = qf.downloader:execute(v.pic, 10,
			function(path)
				if not tolua.isnull( self ) then
					ccui.Helper:seekWidgetByName(goods,"img"):loadTexture(path)
				end
			end,
			function()
			end,
			function()
			end
		)
		local treasureprogressP = ccui.Helper:seekWidgetByName(goods,"treasureprogressP")
		local progresstxt = ccui.Helper:seekWidgetByName(treasureprogressP,"progresstxt")
		local progresstxt1 = ccui.Helper:seekWidgetByName(treasureprogressP,"progresstxt1")
		local progresstxt2 = ccui.Helper:seekWidgetByName(treasureprogressP,"progresstxt2")
		local progresstxt3 = ccui.Helper:seekWidgetByName(treasureprogressP,"progresstxt3")
		local prizewinnerP = ccui.Helper:seekWidgetByName(goods,"prizewinnerP")
		local remaintimeP = ccui.Helper:seekWidgetByName(goods,"remaintimeP")
		local endtimeP = ccui.Helper:seekWidgetByName(goods,"endtimeP")
		if v.status == 1 then --正在进行
			treasureprogressP:setVisible(true)
			progresstxt:setVisible(false)
			endtimeP:setVisible(false)
			prizewinnerP:setVisible(false)
			if v.type == 1 then--秒杀满人次开奖
				--由于数据的即时改变，没有富文本只能根据模板设置改变数据后的文本位置
				progresstxt:setString("已抢"..v.bet_times_now.."/"..v.bet_max.."次")
				progresstxt1:setString("已抢")
				progresstxt2:setString(v.bet_times_now)
				progresstxt3:setString("/"..v.bet_max.."次")
				Util:setTxtPositionByItem(progresstxt,{progresstxt1,progresstxt2,progresstxt3})
				if v.bet_times_now == v.bet_max then
					progresstxt:setString("等待开奖中")
					progresstxt:setVisible(true)
					progresstxt1:setString("")
					progresstxt2:setString("")
					progresstxt3:setString("")
				end
			else--定时开奖
				--由于数据的即时改变，没有富文本只能根据模板设置改变数据后的文本位置
				progresstxt:setString("已抢"..v.bet_times_now.."次")
				progresstxt1:setString("已抢")
				progresstxt2:setString(v.bet_times_now)
				progresstxt3:setString("次")
				Util:setTxtPositionByItem(progresstxt,{progresstxt1,progresstxt2,progresstxt3})
				local time = tonumber(v.open_time*100)-(math.ceil(socket.gettime()*100)-v.open_time_with_ms)
				if time <=0 and goods.time == 0 then 
					progresstxt:setString("等待开奖中")
					progresstxt:setVisible(true)
					progresstxt1:setString("")
					progresstxt2:setString("")
					progresstxt3:setString("")
				end
				if not (goods.time and math.abs(goods.time - time)<2) then
					goods.time = time
				end
				if not remaintimeP.isrun then
					remaintimeP:setVisible(true)
					remaintimeP.isrun = true
					remaintimeP:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function( ... )
						if goods.time>0 then
							goods.time = tonumber(v.open_time*100)-(math.ceil(socket.gettime()*100)-v.open_time_with_ms)
						else 
							goods.time = 0
							progresstxt:setString("等待开奖中")
							progresstxt:setVisible(true)
							progresstxt1:setString("")
							progresstxt2:setString("")
							progresstxt3:setString("")
							remaintimeP.isrun = false
							remaintimeP:stopAllActions()
						end
						local min,sec,ms = timeConvert(goods.time)
						ccui.Helper:seekWidgetByName(remaintimeP,"min"):setString(min)
						ccui.Helper:seekWidgetByName(remaintimeP,"sec"):setString(sec)
						ccui.Helper:seekWidgetByName(remaintimeP,"ms"):setString(ms)
					end),cc.DelayTime:create(0.01))))
				end
			end
		elseif v.status == 0 and v.type == 2 then --正在进行
			progresstxt:setString("已抢"..v.bet_times_now.."次")
			progresstxt1:setString("已抢")
			progresstxt2:setString(v.bet_times_now)
			progresstxt3:setString("次")
			Util:setTxtPositionByItem(progresstxt,{progresstxt1,progresstxt2,progresstxt3})
			progresstxt:setString("等待开奖中")
			progresstxt:setVisible(true)
			progresstxt1:setString("")
			progresstxt2:setString("")
			progresstxt3:setString("")
		else --已经结束
			treasureprogressP:setVisible(false)
			remaintimeP:setVisible(false)
			endtimeP:setVisible(true)
			if v.winner_bet_times ~= 0 then 
                prizewinnerP:setVisible(true)
            end
			
			ccui.Helper:seekWidgetByName(endtimeP,"endtime"):setString(v.end_time)
			Util:updateUserHead(ccui.Helper:seekWidgetByName(prizewinnerP,"icon"),v.winner_pic, v.winner_sex, {url=true})
			ccui.Helper:seekWidgetByName(prizewinnerP,"nick"):setString(v.winner_nick)
			ccui.Helper:seekWidgetByName(prizewinnerP,"number"):setString("幸运号  "..v.winner_lucky_num)
		end
        addButtonEvent(goods,function( ... )
            qf.event:dispatchEvent(ET.SHOW_FOCASINFO_VIEW, {time = goods.time,index = v.item_id})
		end)
		index = index + 1
	end
end

function FocasView:guaGuaCardExchangeSuccess( params )
    print("---------------------GUAGUACARD_EXCHANGE_SUCCESS-----------------2--------")
    PopupManager:push({class = GuaGuaCardSuccessTip})
    PopupManager:pop()
end

function FocasView:initMenu(  )
    self.menu = HallMenuComponent.new({return_cb = function (  )
        self:exitModel()
    end})
    self.menu_panel:addChild(self.menu)
    self.menu:setPositionY(-self.menu:getContentSize().height)
end

return FocasView