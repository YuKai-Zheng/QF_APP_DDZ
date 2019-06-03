--[[
	CustomScrollView使用说明
	paras.defaultNode   默认ItemModule
	paras.datalist      listItem数据表
	paras.updata        item更新方法
	paras.direction     scroll滑动方向
	paras.delay         item初始化间隔时间
	paras.limitMaxNum   第一次初始化item个数

	以下为对象方法
	setItemModel()		--设置默认ItemModule
	getItemModel()    	--获取ItemModule
	refreshScrollView(totop,startIndex) --刷新ScrollViewList: totop 是否跳转到顶部,startIndex从第几个Item开始刷新
	refreshData(datalist,totop)         --用新数据刷新刷新ScrollViewList：datalist新数据列表 totop是否跳转到顶部
	setItemContentSize(index,item)		--设置Item大小 index为item对应key item为需要改变大小的对象
	updateItemPos(index)				--更新item坐标(目前为更新所有item坐标)
	setTopRefresh(enable,refreshItem)  --设置下拉刷新 enable是否隐藏 refreshItem下拉刷新对象
	getSelectItem()		--获取选中的Item对象
	updateItemByKey(key,data)			--根据key更新某个item的数据 key为当前item在datalist中的索引
	hideAllItems()		--隐藏所有的Item
	showAllItems()		--显示所有的Item
	setShowActionEnabled(enable)		--设置Item是否有刷新动画
	setItemsMargin(margin)				--设置Item间距 margin间距大小
	removeAllItems()	--清空ScrollViewList
	setUpdateFunc(func)	--设置Item更新方法
	pushBackItemByData(data)			--从底部插入一条数据并更新， data为Item数据
	pushBackItemsByData(data)			--从底部插入一段数据并更新， data为多个Item数据表
	updateData(index, data, refresh)    --更新某个item的数据并刷新， index为datalist索引， data为item数据，refresh是否刷新
	getItemByKey(key)	--通过datalist索引获取item,如Item不在显示区域则返回nill
	setPrePage(enable,item)				--设置上一页 enable是否展示 item上一页可点击对象
	setNextPage(enable,item)			--设置下一页 enable是否展示 item下一页可点击对象
	getItemKey(item)					--获取item在datalist中的索引
	getListCount()		--获取当前ScrollViewList大小
	removeItemByIndex(index) 			--根据index删除item index为datalist索引
	jumpToPercentVertical(percent)		--Vertical方向跳转到percent百分比位置
	jumpToPercentHorizontal(percent)	--Horizontal方向跳转到percent百分比位置
	jumpToIndex(index)					--跳转到第index个Item的位置
	jumpToTop()			--跳转到顶部
	jumpToBottom()		--跳转到底部
	jumpToLeft()		--跳转到最左边
	jumpToRight()		--跳转到最右边
--]]
local CustomScrollView = class("CustomScrollView",function(paras)
	return ccui.ScrollView:create()
end)
CustomScrollView.TAG = "CustomScrollView"

local CustomScrollViewItem = import(".CustomScrollViewItem")
CustomScrollView.REFRESH = "REFRESH" --下拉或右拉刷新触发
function CustomScrollView:ctor(paras)
	-- qf(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.inner = self:getInnerContainer()
	self.itemList = {}						--item对象表
	self.itemsHeight = {}					--item高度记录表
	self.itemsWidth = {}					--item宽度记录表
	self.defaultItem = nil					--itemModule对象
	self.itemsMargin = 0					--item之间的间距
	self.freshScroll = false				--滑动更新inner容器期间不在接受滑动数据
	self.noActionRefresh = false			--无动作一次性刷新
	self.freshInnerSize = false				--标记是否要更新滑动容器的高度，避免没必要的运算		
	self.showAction = false					--item刷新时是否展示动画
	self.topRefresh = false					--下拉是否要刷新
	self.selectItem = nil					--当前被选中的item对象
	self.preItem = nil						--上一页对象
	self.nextItem = nil						--下一页对象
	self.cur_inner_refresh_posX = 0			--上一帧inner容器的X坐标:处理下拉刷新
	self.cur_inner_refresh_posY = 0			--上一帧inner容器的Y坐标:处理下拉刷新
	self.cur_inner_posX = 0					--上一帧inner容器的X坐标:处理滑动item更新
	self.cur_inner_posY = 0					--上一帧inner容器的Y坐标:处理滑动item更新
	if paras then
		--datalist必须有序
		self.datalist = paras.datalist == nil and {} or paras.datalist
		self.limitMaxNum = paras.limitMaxNum == nil and 6 or paras.limitMaxNum
		self.defaultNode = paras.defaultNode
		self.updata = paras.updata
		self.direction = paras.direction == nil and ccui.ScrollViewDir.vertical or paras.direction
		self.delay = paras.delay == nil and 0 or paras.delay
		self.itemsMargin = paras.margin == nil and 0 or paras.margin
	end
	self:initView()
end

--创建Item
function CustomScrollView:getDefaultItem()
	local node = self.defaultNode:clone()
	self.defaultItem = CustomScrollViewItem.new({
	        node = node,
	        updata = self.updata
	    })
	return self.defaultItem
end

--初始化scrollList
function CustomScrollView:initView()
	self:setBounceEnabled(true)
	self:setDirection(self.direction)
	self:addEventListener(handler(self, self.scrollListViewEvent))
	if #self.datalist <= 0 then return end
	self:initScrollViewSize()
	self:refreshScrollView(true)
end

--初始化滑动容器的Size
function CustomScrollView:initScrollViewSize()
	self.freshInnerSize = true
	local defaultItem = self:getDefaultItem()
	--初始化容器Size
	for i,v in pairs(self.datalist) do
		self:setItemContentSize(i, defaultItem)
	end
	self:updateInnerContentSize()
	self.cur_inner_posY = self.inner:getPositionY()
	self.cur_inner_posX = self.inner:getPositionX()
end

--刷新ScrollList
function CustomScrollView:refreshScrollView(totop,startIndex)
	if totop then
		self:hideAllItems()
	end
	self.freshInnerSize = true
	local startIndex = startIndex or 1
	self:stopAllActions()
	self:stopAutoScrollChildren() --停止惯性滚动
	--跳转到顶部，并重置当前Item序号
	if totop then
		if self.direction == ccui.ScrollViewDir.vertical then
			self.inner:setPositionY(self:getContentSize().height - self:_getInnerSizeDir())
		elseif self.direction == ccui.ScrollViewDir.horizontal then
			self.inner:setPositionX(0)
		end

		--更新item的数据索引
		self:_updateItemsListKey(1)
	end

	--当datalist最大索引小于已有Item的个数时,删除多余的item
	if #self.datalist < #self.itemList then
		for i = #self.itemList,#self.datalist + 1,-1  do
			self:removeChild(self.itemList[i],true)
			table.remove(self.itemList, i)
		end
	end

	--itemList的最大listkey大于datalist最大索引时,更新itemList所有item的listkey
	if #self.itemList > 0 and #self.datalist < self.itemList[#self.itemList].listkey then
		self:_updateItemsListKey(#self.datalist - #self.itemList + 1)
	end

	--刷新数据
	local delay = self.delay
	local showAction = self.showAction

	--如果是无动作一次性刷新，则不展示刷新效果，刷新间隔时间为0
	if self.noActionRefresh then
		delay = 0
		showAction = false
		self.noActionRefresh = false
	end

	--更新item
	for i = startIndex, #self.datalist do
		local delay = self.itemList[1] and (i - self.itemList[1].listkey + 1)*delay or (i - startIndex + 1)*delay
		self:runAction(
	        cc.Sequence:create(cc.DelayTime:create(delay),
		        cc.CallFunc:create(function()
		        	self:_updateItem(i,showAction)
		        	--所有item更新完毕后才显示下一页
		        	if i == #self.datalist then
		        		if self.nextItem then self.nextItem:setVisible(true) end
		        	end
		        end)
		    )
	    )
	end
end

--更新Item的数据索引
function CustomScrollView:_updateItemsListKey(startKey)
	local item
	local curKey
	for i=1,#self.itemList do
		item = self.itemList[i]
		curKey = startKey + i - 1
		if curKey <= #self.datalist then
			item.listkey = curKey
		end
	end
end

--更新Item
function CustomScrollView:_updateItem(index,showAction)
	local j = 0
	local k = 0
	local item
	if #self.itemList == 0 or index > self.itemList[#self.itemList].listkey then
		if #self.itemList >= self.limitMaxNum then
			--如果大于item最大限制数则不再新增
			return
		end
		--如果当前显示的item还没有达到限制则补齐item
		item = self:getDefaultItem()
		item.listkey = index
		addButtonEvent(item, handler(self, self.itemTouchCallback))
		self:addChild(item)
		table.insert(self.itemList, item)
		k = k + 1
		--loge("新增:"..k)
	elseif index >= self.itemList[1].listkey then
		--刷新现有item
		item = self.itemList[index - self.itemList[1].listkey + 1]
		item.updata = self.updata
		j = j + 1
		--loge("刷新:"..j)
	end
	if item then
		item:updataCell(self.datalist[item.listkey])
		self:setItemContentSize(item.listkey, item)
		--更新inner大小
		self:updateItemPos(index)
		item:setVisible(false)

		if showAction then
			--item刷新效果
			self:_showItemAciton(item)
		else
			--直接显示item
			item:setVisible(true)
		end
	end
end

--Item刷新效果
function CustomScrollView:_showItemAciton(item)
	--item中心点坐标
	local centerX = item:getPositionX() - self:getItemLocalPosX(item)
	local centerY = item:getPositionY() - self:getItemLocalPosY(item)
	local anchor = item:getAnchorPoint()
	item:setVisible(true)
	item:setAnchorPoint(0.5,0.5)
	item:setPosition(cc.p(centerX, centerY))
	Display:showScalePop({view = item,time = 0.2,cb=function(item)
		--重新获取中心点坐标，防止在做动作过程中数据被改变
		centerX = item:getPositionX() - self:getItemLocalPosX(item)
		centerY = item:getPositionY() - self:getItemLocalPosY(item)
        item:stopAllActions()
        item:setAnchorPoint(anchor)
        item:setPosition(cc.p(centerX + self:getItemLocalPosX(item), centerY + self:getItemLocalPosY(item)))
    end})
end

--下拉或右拉刷新
function CustomScrollView:scrollTopRefresh(sender,eventType)
	if eventType == ccui.ScrollviewEventType.bounceTop then
		if self.topRefresh then
			--下拉刷新回调
			if self.cur_inner_refresh_posY + self.inner:getChildByName("topText"):getPositionY() + 100 < self:getContentSize().height then
				-- self:dispatchEvent({name=self.REFRESH})
			end
		end
	elseif eventType == ccui.ScrollviewEventType.bounceLeft then
		if self.topRefresh then
			--右拉刷新
			if self.cur_inner_refresh_posX + self.inner:getChildByName("topText"):getPositionX() > 100 then
				-- self:dispatchEvent({name=self.REFRESH})
			end
		end
	else
		self.cur_inner_refresh_posY = self.inner:getPositionY()
		self.cur_inner_refresh_posX = self.inner:getPositionX()
	end
end

--回收使用item:index当前回收的item对象索引,newIndex要被刷新的item对象索引,listkey要被刷新的item数据索引
function CustomScrollView:recycleUseItem(index,newIndex,listkey)
	local cur_item = self.itemList[index]
	table.remove(self.itemList,index)
    cur_item.listkey = listkey
    cur_item:updataCell(self.datalist[cur_item.listkey])
    table.insert(self.itemList,newIndex,cur_item)
    self:setItemContentSize(cur_item.listkey, cur_item)

    --刷新Item坐标
    if self.direction == ccui.ScrollViewDir.vertical then
    	self:updateItemPosY(newIndex)
    elseif self.direction == ccui.ScrollViewDir.horizontal then
    	self:updateItemPosX(newIndex)
    end
end

--滑动处理
function CustomScrollView:scrollListViewEvent(sender,eventType)
	--下拉或右拉刷新
	self:scrollTopRefresh(sender, eventType)

	--滑动Item更新
	if eventType ~= ccui.ScrollviewEventType.scrolling or self.freshScroll or #self.itemList < self.limitMaxNum then return end
	local cur_item
	if self.direction == ccui.ScrollViewDir.vertical then
		if self.inner:getPositionY() - self.cur_inner_posY > 0 then
        	--向上滑动，并且当前最下面的item key值小于datalist的数量
	        while self.itemList[#self.itemList].listkey < #self.datalist 
	        	and self.inner:getPositionY() + self.itemList[#self.itemList]:getPositionY() + self.itemList[#self.itemList]:getContentSize().height > 0 do
	        	--最下面的item进入视线时刷新下一个
                cur_item = self.itemList[1]  
                if self.inner:getPositionY() + cur_item:getPositionY() > self:getContentSize().height then
                	--可以回收第一个item，回收并使用第一个Item
	                self:recycleUseItem(1, #self.itemList, self.itemList[#self.itemList].listkey + 1)
	            else
	            	--不可以回收第一个item，新增item
	            	self:addItemBottom()
	            end
	        end
		else
			--向下滑动，并且当前最上面的item key值大于datalist的第一个key
        	while self.itemList[1].listkey > 1 
        		and self.inner:getPositionY() + self.itemList[1]:getPositionY() < self:getContentSize().height do
	            --最上面的item进入视线时刷新下一个item
	            cur_item = self.itemList[#self.itemList]
	            local height = self:getItemHeightByIndex(self.itemList[1].listkey - 1)
	            if self.inner:getPositionY() < -cur_item:getContentSize().height then
	            	--可以回收最后一个item，回收并使用最后一个item
	                self:recycleUseItem(#self.itemList, 1, self.itemList[1].listkey - 1)
		        else
		        	--不可以回收最后一个item，新增item
		        	self:addItemTop()
		        end
		        if math.abs(height - cur_item:getContentSize().height) > 0.1 then
		        	--视野上方的item大小发生变化，为了防止item跳动，移动inner的坐标使原来的item在视野中位置不变
                	self.inner:setPositionY(self.inner:getPositionY() + (cur_item:getContentSize().height - height))
                end
	        end
        end
  		self.cur_inner_posY = self.inner:getPositionY()
    elseif self.direction == ccui.ScrollViewDir.horizontal then
    	if self.inner:getPositionX() - self.cur_inner_posX < 0 then
        	--向左滑动，并且当前最右边的item key值小于datalist的数量
	        while self.itemList[#self.itemList].listkey < #self.datalist 
	        	and self.inner:getPositionX() + self.itemList[#self.itemList]:getPositionX() < self:getContentSize().width do
                --最右边的item进入视线时刷新下一个
                cur_item = self.itemList[1]
                if self.inner:getPositionX() + cur_item:getPositionX() + cur_item:getContentSize().width < 0 then
	                --可以回收第一个item，回收并使用第一个Item
	                self:recycleUseItem(1, #self.itemList, self.itemList[#self.itemList].listkey + 1)
	            else
	            	--不可以回收第一个item，新增item
	            	self:addItemBottom()
	            end
	        end
		elseif self.itemList[1].listkey > 1 then
			--向右滑动，并且当前最左边的item key值大于datalist的第一个key
        	while self.inner:getPositionX() + self.itemList[1]:getPositionX() + self.itemList[1]:getContentSize().width > 0 do
	            --最左边的item进入视线时刷新下一个
	            cur_item = self.itemList[#self.itemList]
	            local width = self:getItemWidthByIndex(self.itemList[1].listkey - 1)
	            if self.inner:getPositionX() + cur_item:getPositionX() > self:getContentSize().width then
		            --可以回收最后一个item，回收并使用最后一个item
	                self:recycleUseItem(#self.itemList, 1, self.itemList[1].listkey - 1)
		        else
		        	--不可以回收最后一个item，新增item
		        	self:addItemTop()
		        end
		        if math.abs(width - cur_item:getContentSize().width) > 0.1 then
		        	--视野左方的item大小发生变化，为了防止item跳动，移动inner的坐标使原来的item在视野中位置不变
                	self.inner:setPositionX(self.inner:getPositionX() - (cur_item:getContentSize().width - width))
                end
	        end
        end
        self.cur_inner_posX = self.inner:getPositionX()
    end
end

--新数据刷新列表,datalist:数据table, totop:是否跳到顶部
function CustomScrollView:refreshData(datalist,totop)
	self.datalist = clone(datalist)
	self:initScrollViewSize()
	self:refreshScrollView(totop,1)
end

--更新滑动容器的Size
function CustomScrollView:updateInnerContentSize()
	if self.direction == ccui.ScrollViewDir.vertical then
		self:updateInnerHeight()
	elseif self.direction == ccui.ScrollViewDir.horizontal then
		self:updateInnerWidth()
	end
end

--更新Item坐标
function CustomScrollView:updateItemPos(index)
	self.freshInnerSize = true
	if self.direction == ccui.ScrollViewDir.vertical then
		self:updateItemPosY(index)
	elseif self.direction == ccui.ScrollViewDir.horizontal then
		self:updateItemPosX(index)
	end
end

--设置滑动容器对应Item的size
function CustomScrollView:setItemContentSize(index,item)
	if self.direction == ccui.ScrollViewDir.vertical then
		if not self.itemsHeight[index] or math.abs(self.itemsHeight[index] - item:getContentSize().height) > 0.1 then
			self.itemsHeight[index] = item:getContentSize().height
			self.freshInnerSize = true
		end
	elseif self.direction == ccui.ScrollViewDir.horizontal then
		if not self.itemsWidth[index] or math.abs(self.itemsWidth[index] - item:getContentSize().width) > 0.1 then
			self.itemsWidth[index] = item:getContentSize().width
			self.freshInnerSize = true
		end
	end
end

--获取滑动容器对应Item的height
function CustomScrollView:getItemHeightByIndex(index)
	return self.itemsHeight[index]
end

--获取滑动容器对应Item的width
function CustomScrollView:getItemWidthByIndex(index)
	return self.itemsWidth[index]
end

--更新滑动容器的高度
function CustomScrollView:updateInnerHeight()
	--inner的size没有发生变化则返回
	if not self.freshInnerSize then return end
	self.freshInnerSize = false
	self.freshScroll = true
	local height= 0
	if self.preItem then
		height = height + self.preItem:getContentSize().height
	end
	if self.nextItem then
		height = height + self.nextItem:getContentSize().height
	end
	for i,v in pairs(self.itemsHeight) do
		if i > #self.datalist then break end
		if i == 1 then
			height = height + v
		else
			height = height + v + self.itemsMargin
		end
	end
	if height ~= self:getInnerContainerSize().height then
		self:setInnerContainerSize(cc.size(self:getContentSize().width, height))
	end

	if self.inner:getChildByName("topText") then
		self.inner:getChildByName("topText"):setPositionY(self:getInnerContainerSize().height + 100)
	end
	self.freshScroll = false
end

--更新滑动容器的宽度
function CustomScrollView:updateInnerWidth()
	--inner的size没有发生变化则返回
	if not self.freshInnerSize then return end
	self.freshInnerSize = false
	self.freshScroll = true
	local width= 0
	--上一页
	if self.preItem then
		width = width + self.preItem:getContentSize().width
	end
	--下一页
	if self.nextItem then
		width = width + self.nextItem:getContentSize().width
	end
	--Item宽度
	for i,v in pairs(self.itemsWidth) do
		if i > #self.datalist then break end
		if i == 1 then
			width = width + v
		else
			width = width + v + self.itemsMargin
		end
	end
	if width ~= self:getInnerContainerSize().width then
		self:setInnerContainerSize(cc.size(width, self:getContentSize().height))
	end

	if self.inner:getChildByName("topText") then
		self.inner:getChildByName("topText"):setPositionX(-100)
	end
	self.freshScroll = false
end

--更新Item的Y坐标
function CustomScrollView:updateItemPosY(index)
	self:updateInnerHeight()
	if #self.itemsHeight == 0 then return end
	local width  = self:getInnerContainerSize().width
	local height = self:getInnerContainerSize().height
	local item = nil --self.itemList[index]暂时没有使用，目前每次都更新所有item的坐标
	--上一页坐标
	if self.preItem then
		height = height - self.preItem:getContentSize().height
		self.preItem:setPosition(cc.p(width/2 + self:getItemLocalPosX(self.preItem), height + self:getItemAnchorPosY(self.preItem)))
	end
	--item坐标
	for i,v in pairs(self.itemsHeight) do
		if i == 1 then
			height = height - v
		else
			height = height - v - self.itemsMargin
		end

		if self.itemList[1] and i >= self.itemList[1].listkey and i <= self.itemList[#self.itemList].listkey then
			item = self.itemList[i - self.itemList[1].listkey + 1]
			item:setPosition(cc.p(width/2 + self:getItemLocalPosX(item), height + self:getItemAnchorPosY(item)))
			if i == self.itemList[#self.itemList].listkey then
				break
			end
		end
	end
	--下一页坐标
	if self.nextItem then
		height = height - self.nextItem:getContentSize().height
		self.nextItem:setPosition(cc.p(width/2 + self:getItemLocalPosX(self.nextItem), height + self:getItemAnchorPosY(self.nextItem)))
	end
end

--更新Item的X坐标
function CustomScrollView:updateItemPosX(index)
	self:updateInnerWidth()
	if #self.itemsWidth == 0 then return end
	local width  = 0
	local height = self:getInnerContainerSize().height
	local item = nil --self.itemList[index]暂时没有使用，目前每次都更新所有item的坐标
	--上一页坐标
	if self.preItem then
		self.preItem:setPosition(cc.p(width + self:getItemAnchorPosX(self.preItem), height/2 + self:getItemLocalPosY(self.preItem)))
		width = width + self.preItem:getContentSize().width
	end
	--item坐标
	local width_old = 0
	for i,v in pairs(self.itemsWidth) do
		width_old = width --先计算item坐标再加
		if i == 1 then
			-- width = width + v
			width = width
		else
			width = width + v + self.itemsMargin
		end
		if self.itemList[1] and i >= self.itemList[1].listkey and i <= self.itemList[#self.itemList].listkey then
			item = self.itemList[i - self.itemList[1].listkey + 1]
			-- item:setPosition(cc.p(width_old + self:getItemAnchorPosX(item), height/2 + self:getItemLocalPosY(item)))
			item:setPosition(cc.p(width + self:getItemAnchorPosX(item), height/2 + self:getItemLocalPosY(item)))
			if i == self.itemList[#self.itemList].listkey then
				break
			end
		end
	end
	--下一页坐标
	if self.nextItem then
		self.nextItem:setPosition(cc.p(width + self:getItemAnchorPosX(self.nextItem), height/2 + self:getItemLocalPosY(self.nextItem)))
	end
end

--从顶部增加Item
function CustomScrollView:addItemTop()
	if self.itemList[1].listkey <= 1 then return end
	local cur_item = self:getDefaultItem()
	cur_item.listkey = self.itemList[1].listkey - 1
	cur_item:updataCell(self.datalist[cur_item.listkey])
	cur_item:setVisible(true)
	self:addChild(cur_item)
	table.insert(self.itemList,1, cur_item)
    self:setItemContentSize(cur_item.listkey, cur_item)
	self:updateItemPos(1)
	if #self.itemList > self.limitMaxNum then
		self.limitMaxNum = #self.itemList
	end
end

--从底部增加Item
function CustomScrollView:addItemBottom()
	if #self.datalist <= self.itemList[#self.itemList].listkey then return end
	local cur_item = self:getDefaultItem()
	cur_item.listkey = self.itemList[#self.itemList].listkey + 1
	cur_item:updataCell(self.datalist[cur_item.listkey])
	cur_item:setVisible(true)
	self:addChild(cur_item)
	table.insert(self.itemList, cur_item)
    self:setItemContentSize(cur_item.listkey, cur_item)
	self:updateItemPos(#self.itemList)
	if #self.itemList > self.limitMaxNum then
		self.limitMaxNum = #self.itemList
	end
end

--设置下拉刷新
function CustomScrollView:setTopRefresh(enable,refreshItem)
	local top_ttf = self.inner:getChildByName("topText")
	if tolua.isnull(top_ttf) and not refreshItem then return end
	self.topRefresh = enable
	if tolua.isnull(top_ttf) then
		refreshItem:setName("topText")
		refreshItem:setAnchorPoint(cc.p(0.5,0.5))
		if self.direction == ccui.ScrollViewDir.vertical then
			refreshItem:setPosition(cc.p(self:getInnerContainerSize().width/2, self:getInnerContainerSize().height + 100))
		elseif self.direction == ccui.ScrollViewDir.horizontal then
			refreshItem:setPosition(cc.p(-100, self:getContentSize().height/2))
		end
		self.inner:addChild(refreshItem)
		top_ttf = refreshItem
	end
    top_ttf:setVisible(enable)
end

--item点击回调
function CustomScrollView:itemTouchCallback(sender)
	self.selectItem = sender
end

--获取选中的Item
function CustomScrollView:getSelectItem()
	if tolua.isnull(self.selectItem) then return nil end
	return self.selectItem
end

--根据序号更新Item
function CustomScrollView:updateItemByKey(key,data)
	if self.datalist[key] and data then
		self.datalist[key] = clone(data)
	end
	local item = self:getItemByKey(key)
	if item then
		item:updataCell(self.datalist[item.listkey])
	end
end

--隐藏所有的Item
function CustomScrollView:hideAllItems()
	for i,v in pairs(self.itemList) do
		v:setVisible(false)
	end
end

--显示所有的Item
function CustomScrollView:showAllItems()
	for i,v in pairs(self.itemList) do
		v:setVisible(true)
	end
end

--设置Item是否展示初始化动画
function CustomScrollView:setShowActionEnabled(enable)
	self.showAction = enable
end

--设置item间距
function CustomScrollView:setItemsMargin(margin)
	self.itemsMargin = margin
end

--清空列表
function CustomScrollView:removeAllItems()
	self:stopAllActions()
	for i,v in pairs(self.itemList) do
		self:removeChild(v,true)
	end
	self.freshInnerSize = true
	self.itemList = {}
	self.itemsHeight = {}
	self.itemsWidth = {}
	self.datalist = {}
	self:updateInnerContentSize()
end

--删除某条记录
function CustomScrollView:removeItemByIndex(index)
	if not self.datalist[index] then return end
	table.remove(self.datalist,index)
	if self.direction == ccui.ScrollViewDir.vertical then
		table.remove(self.itemsHeight,index)
	elseif self.direction == ccui.ScrollViewDir.horizontal then
		table.remove(self.itemsWidth,index)
	end
	--当要显示的item数小于已有的Item数时，删除当前item(可以解决item闪烁的问题，未详细测试慎用)
	-- if #self.datalist < #self.itemList then
	-- 	local i = 1
	-- 	while self.itemList[i] do
	-- 		if self.itemList[i].listkey == index then
	-- 			self:removeChild(self.itemList[i])
	-- 			table.remove(self.itemList,i)
	-- 			for j = i, #self.itemList do
	-- 				self.itemList[j].listkey = self.itemList[j].listkey - 1
	-- 			end
	-- 			break
	-- 		else
	-- 			i = i + 1
	-- 		end
	-- 	end
	-- end
	self.noActionRefresh = true
	self:refreshScrollView(false)
end

--设置ItemModel
function CustomScrollView:setItemModel(node)
	self.defaultNode = node
end

--获取ItemModel
function CustomScrollView:getItemModel()
	return self.defaultNode
end

--设置更新方法
function CustomScrollView:setUpdateFunc(func)
	self.updata = func
end

--底部插入一条数据，并刷新
function CustomScrollView:pushBackItemByData(data)
	self.datalist[#self.datalist + 1] = clone(data)
	self:refreshScrollView(false,#self.datalist)
end

--底部插入一段数据，并刷新
function CustomScrollView:pushBackItemsByData(data)
	local refresh_index = #self.datalist
	for i,v in pairs(data) do
		self.datalist[#self.datalist + 1] = clone(v)
	end
	self:refreshScrollView(false, refresh_index)
end

--更新某条数据
function CustomScrollView:updateData(index, data, refresh)
	if index <= #self.datalist then
		self.datalist[index] = clone(data)
	end
	if refresh then
		self:refreshScrollView()
	end
end

--序号获取Item
function CustomScrollView:getItemByKey(key)
	for i,v in pairs(self.itemList) do
		if key == v.listkey then
			return v
		end
	end
	return nil
end

--设置上一页
function CustomScrollView:setPrePage(enable,item)
	if not enable then
		if self.preItem and not tolua.isnull(self.preItem) then
			self:removeChild(self.preItem,true)
			self.preItem = nil
		end
	else
		if self.preItem ~= item then
			self:removeChild(self.preItem,true)
			self.preItem = item
			self:addChild(self.preItem)
		end
	end
	--刷新所有Item坐标
	self:updateItemPos()
end

--设置下一页
function CustomScrollView:setNextPage(enable,item)
	if not enable then
		if self.nextItem and not tolua.isnull(self.nextItem) then
			self:removeChild(self.nextItem,true)
			self.nextItem = nil
		end
	else
		if self.nextItem ~= item then
			self:removeChild(self.nextItem,true)
			self.nextItem = item
			self:addChild(self.nextItem)
		end
		self.nextItem:setVisible(false)
	end
	--刷新所有Item坐标
	self:updateItemPos()
end

--跳转到纵向百分比
function CustomScrollView:jumpToPercentVertical(percent)
	local posY = -self:_getInnerSizeDir()*(100-percent)/100 + self:getContentSize().height
	if posY >= 0 then posY = 0 end
	self.cur_inner_posY = self.inner:getPositionY()
	self.inner:setPositionY(posY)
	self:_jumpToPercentItem(percent)
end

--跳转到横向百分比
function CustomScrollView:jumpToPercentHorizontal(percent)
	local posX = -self:_getInnerSizeDir()*percent/100
	if posX <= -self:_getInnerSizeDir() + self:getContentSize().width then
		posX = -self:_getInnerSizeDir() + self:getContentSize().width
	end
	self.cur_inner_posX = self.inner:getPositionX()
	self.inner:setPositionX(posX)
	self:_jumpToPercentItem(percent)
end

--跳转到顶部
function CustomScrollView:jumpToTop()
	self:jumpToPercentVertical(0)
end

--跳转到底部
function CustomScrollView:jumpToBottom()
	self:jumpToPercentVertical(100)
end

--跳转到最左边
function CustomScrollView:jumpToLeft()
	self:jumpToPercentHorizontal(0)
end

--跳转到最右边
function CustomScrollView:jumpToRight()
	self:jumpToPercentHorizontal(100)
end

--跳转到第几个item
function CustomScrollView:jumpToIndex(index)
	local itemsSizeTab = self:_getItemsSizeDir()
	local innerSize = self:_getInnerSizeDir()
	local distance = 0
	for i,v in pairs(itemsSizeTab) do
		if i == index then break end
		distance = distance + v + self.itemsMargin
	end
	local percent = distance/innerSize*100
	if percent > 100 then percent = 100 end
	if self.direction == ccui.ScrollViewDir.vertical then
		self:jumpToPercentVertical(percent)
	elseif self.direction == ccui.ScrollViewDir.horizontal then
		self:jumpToPercentHorizontal(percent)
	end
end

--按百分比刷新item
function CustomScrollView:_jumpToPercentItem(percent)
	local itemsSizeTab = self:_getItemsSizeDir()
	local distance = self:_getInnerSizeDir() * percent/100.0
	local index = 1
	for i,v in pairs(itemsSizeTab) do
		distance = distance - v - self.itemsMargin
		if distance <= 0 then
			index = i
			break
		end
	end

	--保证最少刷新limitMaxNum个item
	if index > #self.datalist - self.limitMaxNum + 1 then
		index = #self.datalist - self.limitMaxNum + 1
	end
	if index < 1 then index = 1 end

	--item已经创建，静态刷新
	if #self.itemList >= self.limitMaxNum then
		self:_updateItemsListKey(index)
	else
		--item没有创建完，动态刷新
		for i,v in pairs(self.itemList) do
			self:removeChild(v,true)
		end
		self.itemList = {}
	end
	self:refreshScrollView(false, index)
end

--获取当前方向inner大小
function CustomScrollView:_getInnerSizeDir()
	if self.direction == ccui.ScrollViewDir.vertical then
		return self.inner:getContentSize().height
	elseif self.direction == ccui.ScrollViewDir.horizontal then
		return self.inner:getContentSize().width
	end
end

--获取当前方向items大小
function CustomScrollView:_getItemsSizeDir()
	if self.direction == ccui.ScrollViewDir.vertical then
		return self.itemsHeight
	elseif self.direction == ccui.ScrollViewDir.horizontal then
		return self.itemsWidth
	end
end

--获取Item序号
function CustomScrollView:getItemKey(item)
	return item.listkey
end

--获取当前ScrollList的大小
function CustomScrollView:getListCount()
	return #self.datalist
end

--获取item锚点Y坐标
function CustomScrollView:getItemAnchorPosY(item)
	return item:getContentSize().height*item:getAnchorPoint().y
end

--获取item锚点相对中心点Y坐标
function CustomScrollView:getItemLocalPosY(item)
	return self:getItemAnchorPosY(item) - item:getContentSize().height/2
end

--获取item锚点X坐标
function CustomScrollView:getItemAnchorPosX(item)
	return item:getContentSize().width*item:getAnchorPoint().x
end

--获取item锚点相对中心点X坐标
function CustomScrollView:getItemLocalPosX(item)
	return self:getItemAnchorPosX(item) - item:getContentSize().width/2
end

return CustomScrollView

