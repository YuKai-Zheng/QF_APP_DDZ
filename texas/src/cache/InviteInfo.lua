local InviteInfo = class("InviteInfo")


function InviteInfo:ctor( ... )
	-- body
	self:initData()
end

function InviteInfo:initData( ... )
	self.isCanBindvite = false
	self.inviteCnt = 0
end

-- 是否有奖励可领取
function InviteInfo:hasRewardToTake()
	if self.inviteAwardList == nil then return false end
	for _,reward in pairs(self.inviteAwardList) do
		if reward.bRePick == 1 then
			return true
		end
	end
	return false 
end

-- 获取可领取奖励数量
function InviteInfo:getRewardNum()
	local cnt = 0
	if self.inviteAwardList == nil then return cnt end
	for _,reward in pairs(self.inviteAwardList) do
		if reward.bRePick == 1 then
			cnt = cnt + 1
		end
	end
	return cnt
end

-- 是否所有内容已经做完
function InviteInfo:hasFinishTask()
	if self.inviteAwardList == nil then return false end
	for _,reward in pairs(self.inviteAwardList) do
		if reward.isFinish == false then
			return false
		end
	end
	return true
end

-- 更新奖励信息
function InviteInfo:updateInviteInfo(model)
	if model == nil then return end

	--是否可以绑定邀请人
	self.isCanBindvite = false
	if model.invite_uin == 0 then
		self.isCanBindvite = true
	end

	loga ("是否可以绑定邀请人" .. model.invite_uin)

	--邀请的总人数
	self.inviteCnt = model.invite_count

	loga ("邀请总人数" .. self.inviteCnt)

	loga(self.inviteCnt)

	self.inviteAwardList = {}
	for index = 1, model.award_list:len() do
		local awardInfo = {}
		awardInfo.type = model.award_list:get(index).type  --奖励类型
		awardInfo.goldNum = model.award_list:get(index).money -- 奖励的金币
		awardInfo.focasNum = model.award_list:get(index).fu_card -- 奖励的奖券
		awardInfo.activity = model.award_list:get(index).activity -- 奖励的积分
		awardInfo.desc = model.award_list:get(index).desc --奖励描述
		awardInfo.awardNum = model.award_list:get(index).award_count -- 总共奖励的次数
		awardInfo.completeAwardCount = model.award_list:get(index).complete_award_count --已经完成的奖励次数
		awardInfo.bRePick = model.award_list:get(index).can_repick --是否可以领取
		awardInfo.needInviteNum = model.award_list:get(index).invite_count --这个类型需要要请的好友

		-- 是否已经完成
		awardInfo.isFinish = false
		if awardInfo.awardNum and awardInfo.completeAwardCount and awardInfo.completeAwardCount == awardInfo.awardNum then
			loga ("______________________________已经完成所有奖励了")
			awardInfo.isFinish = true
		end
		table.insert(self.inviteAwardList, awardInfo)
	end

	dump(self.inviteAwardList)

	--邀请信息
	self.inviteAwardInfo = {}
	if model.invite_award_info then
		self.inviteAwardInfo.money = model.invite_award_info.money
		self.inviteAwardInfo.focasNum = model.invite_award_info.fu_card
		self.inviteAwardInfo.activityNum = model.invite_award_info.activity
	end

	dump(self.inviteAwardInfo)
end

-- 更新奖励记录
function InviteInfo:updateInviteRecord(model)
	self.inviterecord = {}
	if model == nil then return end
	for index=1, model.record_list:len() do
		local record = {}
		record.inviteUin = model.record_list:get(index).invite_uin
		record.nick = model.record_list:get(index).nick
		record.date = model.record_list:get(index).date

		table.insert(self.inviterecord, record)
	end
	dump(self.inviterecord)
end

return InviteInfo