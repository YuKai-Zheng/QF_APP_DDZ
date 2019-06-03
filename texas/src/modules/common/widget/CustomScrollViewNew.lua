local CustomScrollViewNew = class("CustomScrollViewNew",import(".CustomScrollView"))
CustomScrollViewNew.TAG = "CustomScrollViewNew"

local CustomScrollViewItem = import(".CustomScrollViewItem")
function CustomScrollViewNew:ctor(paras)
	CustomScrollViewNew.super.ctor(self,paras)
	self.itemClass = paras.itemClass
end

--创建Item
function CustomScrollViewNew:getDefaultItem()
	if self.defaultNode then
		return self.itemClass.new({node = self.defaultNode:clone(), parent = self})
	else
		return self.itemClass.new({parent = self})
	end
end

--设置ItemClass
function CustomScrollViewNew:setItemClass(itemClass)
	self.itemClass = itemClass
end

return CustomScrollViewNew

