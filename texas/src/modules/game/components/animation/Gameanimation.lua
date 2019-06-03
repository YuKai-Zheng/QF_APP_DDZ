--牌桌动画
local GameAnimationConfig = import("src.modules.game.components.animation.AnimationConfig")
local Gameanimation       = class("Gameanimation")
local User                = import("src.modules.game.components.user.User")

local winSize = cc.Director:getInstance():getOpenGLView():getFrameSize()

function Gameanimation:ctor(paras)


	-- if not paras then return end
	
	if paras then
		self._parent_view = paras.view
	end


	if paras.node then
		self.node  = paras.node
	end
	-- self:init()
end


--加载plist
function Gameanimation:init(ptype,cb)
	self.loaded = 0
	-- if qf.device.platform == "windows" then --为了调试方便，windows统一使用苹果支付的配置
 --        for k,v in pairs(GameAnimationConfig) do
	-- 		for kk,vv in pairs(v.list) do
	-- 			cc.SpriteFrameCache:getInstance():addSpriteFrames(vv)
	-- 		end
	-- 	end
	-- 	qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
	-- 	if cb then cb() end
	-- else
		for k,v in pairs(GameAnimationConfig) do
			if v.preload == ptype then
				ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(v.res,function ( ... )
					self.loaded = self.loaded + 1
					if self.Mount[ptype] then
						if self.loaded >= self.Mount[ptype] then
							if cb then cb() end
						end
						
					end
				end)
			end
		end

		-- if cb then cb() end
    -- end
	
	
end


--获得pk炸弹方向
function  Gameanimation:getSide()
	local win_index  = User:getIndex(Cache.niuniudesk.win_uin)

	local lost_index = User:getIndex(Cache.niuniudesk.lost_uin)
	local side       = lost_index<win_index and 1 or 0
	if lost_index == 0 then
		side = win_index/2 > 1 and 1 or 0
	elseif win_index == 0 then
		side = lost_index/2 > 1 and 0 or 1
	end

	return side
end


--播放动画
function Gameanimation:play(paras)
	local armatureDataManager = ccs.ArmatureDataManager:getInstance()
	armatureDataManager:addArmatureFileInfo(paras.anim.res)
	local   face = ccs.Armature:create(paras.anim.name)

	local   node = nil
	if paras.node ~=nil then
		node = paras.node
	else
		node = self.node
	end

	if paras.create then
		node = cc.Layer:create()
		node:setLocalZOrder(paras.layerOrder)
		self._parent_view:addChild(node)
	end
	if paras.flipx then
		node:setScaleX(-1)
	end

	if tolua.isnull(node)  then return  end 


	local visibleSize = cc.Director:getInstance():getWinSize()



	node:addChild(face)

	--name
	if paras.name ~= nil then
		face:setName(paras.name)
	end

	--层级
	if paras.order ~= nil then
		face:setZOrder(paras.order)
	end

	

	--动画的序号
	local index = 0
	if paras.index ~= nil then
		index = paras.index
	end
	--位置
	if paras.position ~= nil then
		face:setPosition(paras.position.x,paras.position.y)
	else
		if not FULLSCREENADAPTIVE then
			face:setPosition(Display.cx/2,Display.cy/2)
		else
			local winSize = cc.Director:getInstance():getWinSize()
			face:setPosition(Display.cx/2 - (winSize.width/2-1920/2),winSize.height/2)
		end
	end


	--设置锚点
	if paras.anchor then
		face:setAnchorPoint(paras.anchor)
	end

	face:getAnimation():playWithIndex(index)

	if paras.forever == nil then
		face:getAnimation():setMovementEventCallFunc(function ()
			-- body
			face:removeFromParent()
			if paras.callback then
				paras.callback()				
			end

			if paras.create then
				node:removeFromParent()
			end

		end)
	end

	if paras.scale ~= nil then
		face:setScale(paras.scale)
	end
	return face
end
--
function Gameanimation:playvipemoji( paras)

	-- body
	self:play({node=paras.node,position=paras.position,anim=GameAnimationConfig["VIP_EMOJI_"..paras.index],order=paras.order})
end



return Gameanimation