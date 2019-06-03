local BeautyInfo = class("BeautyInfo")

BeautyInfo.TAG = "BeautyInfo"

function BeautyInfo:clearInfo()
    for i = 1, 3 do
        self[i] = nil
    end
end

function BeautyInfo:copyFiled(p,s,d)
    for k,v in pairs(p) do
        if type(v) == "table" then
            d[k] = {}
            self:copyFiled(v,s[k],d[k])
        else
            d[v] = s[v]
        end    
    end
end

return BeautyInfo