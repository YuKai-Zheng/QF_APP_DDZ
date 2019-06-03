local CustomScrollViewItem = class("CustomScrollViewItem", function(paras)
    return paras.node
end)
CustomScrollViewItem.TAG = "CustomScrollViewItem"

function CustomScrollViewItem:ctor(paras)
	self.updata = paras.updata
end

function CustomScrollViewItem:updataCell(data)
	self.updata(data,self)
end

return CustomScrollViewItem