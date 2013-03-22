module("extensions.hegemonyExtensions", package.seeall)
extension = sgs.Package("hegemonyExtensions")

hegZhuLianBiHe = {		--珠联璧合
	["liubei"] = "guanyu|zhangfei|ganfuren",
	["zhugeliang"] = "huangyueying",
	["wolong"] = "huangyueying|pangtong",
	["zhaoyun"] = "liushan",
	["huangzhong"] = "weiyan",
	["menghuo"] = "zhurong",
	["caocao"] = "dianwei|xuchu",
	["caopi"] = "zhenji",
	["sunquan"] = "zhoutai",
	["zhouyu"] = "huanggai|xiaoqiao",
	["daqiao"] = "xiaoqiao",
	["lvbu"] = "diaochan",
	["yuanshao"] = "yanliangwenchou",
}

hegSkillCard = {
	["QiangxiCard"] = "heg_dianwei",
	["QuhuCard"] = "heg_xunyu",
	["FanjianCard"] = "heg_zhouyu",
	["KurouCard"] = "heg_huanggai",
	["FenxunCard"] = "heg_dingfeng",
	["HaoshiCard"] = "heg_lusu",
	["ZhijianCard"] = "heg_erzhang",
	["TianyiCard"] = "heg_taishici",
	["LuanwuCard"] = "heg_jiaxu",
	["QingnangCard"] = "heg_huatuo",
	["LiuliCard"] = "heg_daqiao",
	["TianxiangCard"] = "heg_xiaoqiao",
	["TuxiCard"] = "heg_zhangliao",
	["QiaobianCard"] = "heg_zhanghe",
	["LeijiCard"] = "heg_zhangjiao",
	["GuidaoCard"] = "heg_zhangjiao",
}

hegMarks = {
	["heg_pangtong"] = "@nirvana",
	["heg_mateng"] = "@arise",
	["heg_jiaxu"] = "@chaos",
}

function enableHegemony(player)
	if not string.find(sgs.Sanguosha:getSetupString():split(":")[5], "H") then return false end
	if not player:getGeneral2() then return false end
	if table.contains(sgs.Sanguosha:getBanPackages(), "hegemonyExtensions") then return false end
	return true
end

function setMaxHp(player)
	local room = player:getRoom()
	room:setPlayerProperty(player, "maxhp", sgs.QVariant(getGeneralMaxHp(player)))	
end

function getGeneralMaxHp(player)
	local room = player:getRoom()
	local generals = getGenerals(player)
	if not generals then return player:getMaxHp() end
	local maxhp = 0
	for _,str in ipairs(generals) do
		maxhp = maxhp+sgs.Sanguosha:getGeneral(str):getMaxHp()
	end
	if getFaceDownNum(player)==1 then
		if player:getGeneralName()=="anjiang" then
			maxhp = maxhp+player:getGeneral2():getMaxHp()
		else
			maxhp = maxhp+player:getGeneral():getMaxHp()
		end
	end
	maxhp = maxhp/2
	return maxhp
end	

function getFaceDownNum(player)
	local n=0
	if player:getGeneralName()=="anjiang" then n=n+1 end
	if player:getGeneral2Name() == "anjiang" then n=n+1 end
	return n
end

function isSkillShown(player, skill)
	if player:getGeneral():hasSkill(skill) then return true end
	if player:getGeneral2():hasSkill(skill) then return true end
	return false
end

function getHideSkills(player)
	local room = player:getRoom()
	if player:getFaceDownNum()==0 then return nil end
	local skills = {}
	for _,p in pairs(getGenerals(player)) do
		for _,sk in sgs.qlist(sgs.Sanguosha:getGeneral(p):getVisibleSkillList()) do
			table.insert(skills, sk)
		end
	end
	if #skills==0 then return nil end
	return skills
end

function isPairs(a, b)
	if type(hegZhuLianBiHe[a])=="string" then
		local gens = hegZhuLianBiHe[a]:split("|")
		for _,g in pairs(gens) do
			if string.find(b, g) then return true end
		end
	end
	if type(hegZhuLianBiHe[b])=="string" then
		local gens = hegZhuLianBiHe[b]:split("|")
		for _,g in pairs(gens) do
			if string.find(a, g) then return true end
		end
	end
end

function gainLimitedMarks(player, gname)
	if type(hegMarks[gname])=="string" then
		player:gainMark(hegMarks[gname])
	end
end

function isSameKingdom(a, b)
	return a:getKingdom()==b:getKingdom() and a:getKingdom()~="god" and a:getKingdom()~="yxj"
end

function doZhuLianBiHe(player)
	local room = player:getRoom()
	if not player:isWounded() or room:askForChoice(player, "#Hegemony", "heg_recover+heg_draw")=="heg_draw" then
		player:drawCards(2)
	else
		local recover = sgs.RecoverStruct()
		recover.who = player
		room:recover(player, recover)
	end
end

function getGenerals(player)	
	local room = player:getRoom()
	local gstr = room:getTag("heg_"..player:objectName()):toString()
	if not gstr or gstr=="" then return nil end
	local generals = gstr:split("+")
	return generals
end

function getSkillCardOwner(card)
	if type(hegSkillCard[card:getClassName()])=="string" then
		return hegSkillCard[card:getClassName()]
	end
	return nil
end

function ShowGeneral(player, general)
	local room = player:getRoom()
	if not string.find(room:getTag("heg_"..player:objectName()):toString(), general) then return end
	local isSecondaryHero
	if getFaceDownNum(player)==2 then isSecondaryHero = getGenerals(player)[1]~=general
	elseif getFaceDownNum(player)==1 then isSecondaryHero = player:getGeneralName()~="anjiang"
	else return false end
	if player:getMark("@DCgeneral")>0 and not isSecondaryHero then
		room:setPlayerProperty(player, "general", sgs.QVariant(general))
	elseif player:getMark("@DCgeneral2")>0 and isSecondaryHero then
		room:setPlayerProperty(player, "general2", sgs.QVariant(general))
	else
		room:changeHero(player, general, false, false, isSecondaryHero, false)
	end
	local newg = sgs.Sanguosha:getGeneral(general)
	room:setPlayerProperty(player, "kingdom", sgs.QVariant(newg:getKingdom()))
	
	local log = sgs.LogMessage()
	log.type = "#HegemonyShow"
	log.from = player
	log.arg = isSecondaryHero and "HegGeneral2" or "HegGeneral"
	log.arg2 = general
	room:sendLog(log)
	
	if player:getKingdom()=="god" then
		local new_kingdom = room:askForKingdom(player)
		room:setPlayerProperty(player, "kingdom", sgs.QVariant(new_kingdom))
		
		local log = sgs.LogMessage()
		log.type = "#ChooseKingdom"
		log.from = player
		log.arg = new_kingdom
		room:sendLog(log)
	end
	
	room:getThread():trigger(sgs.GameOverJudge, room, player, sgs.QVariant())
	
	if general=="heg_zhouyu" and player:getMark("ChangeAsked")==0 then
		player:addMark("ChangeAsked")
		if room:askForSkillInvoke(player, "", sgs.QVariant("@askForConvertSp")) then
			room:changeHero(player, "sp_heg_zhouyu", false, true, isSecondaryHero, false)
		end
	end
	
	local kingdom = player:getKingdom()
	local sameNum = 0
	for _,p in sgs.qlist(room:getPlayers()) do
		if p:getKingdom()==kingdom then
			sameNum = sameNum+1
		end
	end
	if sameNum>room:getPlayers():length()/2 then
		room:setPlayerProperty(player, "kingdom", sgs.QVariant("yxj"))
	end
	
	local generals = getGenerals(player)
	if not generals then generals = {} end
	for i=1, #generals, 1 do
		if generals[i]==general then
			table.remove(generals, i)
			break
		end
	end
	room:setTag("heg_"..player:objectName(), sgs.QVariant(table.concat(generals, "+")))
	
	setMaxHp(player)
	
	if getFaceDownNum(player)==0 and player:getMark("ShowAlready")==0 then
		player:addMark("ShowAlready")
		local a, b = player:getGeneralName(), player:getGeneral2Name()
		if isPairs(a, b) then
			doZhuLianBiHe(player)
		end
		if getGeneralMaxHp(player)%1==0.5 then
			player:drawCards(1)
		end
		gainLimitedMarks(player, general)
	end
	
end

function askForShowGeneral(player)
	local room = player:getRoom()
	while getGenerals(player) and room:askForSkillInvoke(player, "", sgs.QVariant("@askForShowGeneral")) do
		local general = room:askForGeneral(player, table.concat(getGenerals(player), "+"))
		if not general then return end
		ShowGeneral(player, general)
	end
end

function askForShowTrigger(player, skill)
	local room = player:getRoom()
	if isSkillShown(player, skill) then return true end
	if getFaceDownNum(player)>0 then
		for _,g in ipairs(getGenerals(player)) do
			if sgs.Sanguosha:getGeneral(g):hasSkill(skill) then
				if room:askForSkillInvoke(player, skname) then return false end
				ShowGeneral(player, g)
			end
		end
	end
	return true
end

Hegemony = sgs.CreateTriggerSkill{
	name = "#Hegemony",
	events = {sgs.EventPhaseStart, sgs.GameStart, sgs.ChoiceMade, sgs.CardUsed, sgs.CardResponded},
	priority = 3,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if not enableHegemony(player) then return false end
		if event == sgs.GameStart then
			local names = room:getTag(player:objectName()):toStringList()
			room:setTag("heg_"..player:objectName(), sgs.QVariant(table.concat(names, "+")))
			room:removeTag(player:objectName())
			for _,sk in sgs.qlist(sgs.Sanguosha:getGeneral(names[1]):getSkillList()) do
				if sk:objectName()~="hongyan" then
					room:acquireSkill(player,sk:objectName())
				end
			end
			for _,sk in sgs.qlist(sgs.Sanguosha:getGeneral(names[2]):getSkillList()) do
				if sk:objectName()~="hongyan" then
					room:acquireSkill(player,sk:objectName())
				end
			end
			setMaxHp(player)
			room:setPlayerProperty(player, "hp", sgs.QVariant(player:getMaxHp()))
			return true
		elseif event == sgs.EventPhaseStart and player:getPhase()==sgs.Player_RoundStart then
			askForShowGeneral(player)
		elseif event == sgs.ChoiceMade then
			local strs = data:toString():split(":")
			if strs[1]=="skillInvoke" and strs[3]=="yes" and getFaceDownNum(player)>0 then
				for _,g in ipairs(getGenerals(player)) do
					if sgs.Sanguosha:getGeneral(g):hasSkill(strs[2]) then
						ShowGeneral(player, g)
					end
				end
			end
			if strs[1]=="cardResponded" and strs[3]=="@beige" and strs[4]~="_nil_" then
				if getHideSkills(player) and table.contains(getHideSkills(player), "beige") then
					ShowGeneral(player, "heg_caiwenji")
				end
			end
			if strs[1]=="cardResponded" and strs[3]=="@xiaoguo" and strs[4]~="_nil_" then
				if getHideSkills(player) and table.contains(getHideSkills(player), "xiaoguo") then
					ShowGeneral(player, "heg_yuejin")
				end
			end
		elseif event == sgs.CardUsed then
			local card = data:toCardUse().card
			if card:getSkillName() and card:getSkillName()~="" then
				for _,g in ipairs(getGenerals(player)) do
					if sgs.Sanguosha:getGeneral(g):hasSkill(card:getSkillName()) then
						ShowGeneral(player, g)
					end
				end
			end
			if card:isKindOf("SkillCard") then
				if getSkillCardOwner(card) then
					ShowGeneral(player, getSkillCardOwner(card))
				end
			end
			if card:isKindOf("Slash") and player:getSlashCount()>1 and not player:hasFlag("tianyi_success") then
				if not player:getWeapon() or player:getWeapon():objectName()~="Crossbow" then
					if not isSkillShown(player, "paoxiao") and table.contains(getHideSkills(player), "paoxiao") then
						ShowGeneral(player, "heg_zhangfei")
					end
				end
			end
			if card:isKindOf("Snatch") or card:isKindOf("SupplyShortage") and player:distanceTo(use.to:at(0))>1 then
				if player:hasSkill("qicai") and not isSkillShown(player, "qicai") then
					ShowGeneral(player, "heg_huangyueying")
				end
			end
			if card:isKindOf("SupplyShortage") and player:distanceTo(use.to:at(0))>1 then
				if player:hasSkill("duanliang") and not isSkillShown(player, "duanliang") then
					ShowGeneral(player, "heg_xuhuang")
				end
			end
		elseif event == sgs.CardResponded then
			local card = data:toResponsed().card
			if card:getSkillName() then
				for _,g in ipairs(getGenerals(player)) do
					if sgs.Sanguosha:getGeneral(g):hasSkill(card:getSkillName()) then
						ShowGeneral(player, g)
					end
				end
			end
			if card:isKindOf("SkillCard") then
				if getSkillCardOwner(card) then
					ShowGeneral(player, getSkillCardOwner(card))
				end
			end
		end
	end,
}

HegemonyGameOver = sgs.CreateTriggerSkill{
	name = "#HegemonyGameOver",
	events = {sgs.BuryVictim, sgs.GameOverJudge, sgs.BeforeGameOverJudge},
	priority = 20,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName())
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if not enableHegemony(player) then return false end
		if event == sgs.GameOverJudge then
			local winKingdom
			local kingdoms = {}
			local kingdomsNum = 0
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if getFaceDownNum(p)==2 then return true end
				if kingdoms[p:getKingdom()] then
					kingdoms[p:getKingdom()] = kingdoms[p:getKingdom()]+1
				else
					kingdoms[p:getKingdom()] = 1
					kingdomsNum = kingdomsNum+1
				end
			end
			if kingdomsNum>1 then return true end
			if kingdomsNum==1 then
				for kd,num in pairs(kingdoms) do
					if kd=="yxj" and num>1 then return true end
					winKingdom = kd
				end
			end
			if winKingdom then
				local winners = {}
				for _,p in sgs.qlist(room:getAllPlayers()) do
					if p:getKingdom()==winKingdom then
						table.insert(p:objectName())
					end
				end
				room:gameOver(table.concat(winner,"+"))
			end
			return true
		elseif event == sgs.BeforeGameOverJudge then return true
		elseif event == sgs.BuryVictim then
			local death = data:toDeath()
			death.who:bury()
			if getGenerals(death.who) then
				for _,g in ipairs(getGenerals(death.who)) do
					ShowGeneral(death.who, g)
				end
			end
			if death.damage and death.damage.from and death.damage.from:objectName()~=death.who:objectName()
					and getFaceDownNum(death.damage.from)<2 then
				if death.who:getKingdom()=="yxj" then
					death.damage.from:drawCards(1)
				else
					if death.damage.from:getKingdom()~=death.who:getKingdom() then
						local n = room:getLieges(death.who:getKingdom(), death.damage.from):length()
						death.damage.from:drawCards(n)
					else
						death.damage.from:throwAllHandCardsAndEquips()
					end
				end
			end
			return true
		end
	end,
}

local sklist = sgs.SkillList()
if not sgs.Sanguosha:getSkill("#Hegemony") then
	sklist:append(Hegemony)
end
if not sgs.Sanguosha:getSkill("#HegemonyGameOver") then
	sklist:append(HegemonyGameOver)
end
if not sklist:isEmpty() then
	sgs.Sanguosha:addSkills(sklist)
end

local generalnames=sgs.Sanguosha:getLimitedGeneralNames()
local hidden={"sp_diaochan","sp_sunshangxiang","sp_pangde","sp_caiwenji","sp_machao","sp_jiaxu","anjiang","shenlvbu1","shenlvbu2"}
table.insertTable(generalnames,hidden)
for _, generalname in ipairs(generalnames) do
	local general = sgs.Sanguosha:getGeneral(generalname)
	if general then
		general:addSkill("#Hegemony")
		general:addSkill("#HegemonyGameOver")
	end
end

sgs.LoadTranslationTable{
	["yxj"] = "野心家",
	
	["hegemonyExtensions"] = "国战扩展",
	
	["#Hegemony"] = "国战",
	["heg_recover"] = "回复一点体力",
	["heg_draw"] = "摸两张牌",
	[":@askForShowGeneral"] = "你想明置你的武将牌吗？",
	["#HegemonyShow"] = " %from 展示了他的 %arg %arg2",
	["HegGeneral"] = "主将",
	["HegGeneral2"] = "副将",
}

--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
function sgs.CreateCancelSkill(skname, pattern)
	local HegCancelSkill = sgs.CreateTriggerSkill{
		name = skname,
		priority = 2,
		frequency = sgs.Skill_Compulsory,
		events = {sgs.TargetConfirming},
		on_trigger = function(self, event, player, data)
			local room = player:getRoom()
			local use = data:toCardUse()
			local card = use.card
			local can_invoke = false
			for _,p in ipairs(pattern:split("|")) do
				if card:isKindOf(p) then
					can_invoke = true
				end
			end
			if skname == "HegKongcheng" and not player:isKongcheng() then return false end
			if skname == "HegWeimu" and not card:isBlack() then return false end
			if not can_invoke then return false end
			if not askForShowTrigger(player, skname) then return false end
			use.to:removeOne(player)
			data:setValue(use)
		end
	}
	return HegCancelSkill
end

HegLuoshen_cdids = {}
HegLuoshen = sgs.CreateTriggerSkill{
	name = "HegLuoshen",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.FinishJudge},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase()==sgs.Player_Start then
			local n = 0
			while room:askForSkillInvoke(player, self:objectName()) do
				if n==0 then
					room:broadcastSkillInvoke("luoshen")
				end
				n = n+1
				local judge = sgs.JudgeStruct()
				judge.pattern = sgs.QRegExp("(.*):(spade|club):(.*)")
				judge.good = true
				judge.who = player
				judge.reason = self:objectName()
				room:judge(judge)
				if judge:isBad() then break end
			end
		elseif event == sgs.FinishJudge then
			local judge = data:toJudge()
			if judge.reason == self:objectName() then
				if judge.card:isBlack() then
					table.insert(HegLuoshen_cdids, judge.card:getEffectiveId())
					return true
				else
					local move = sgs.CardsMoveStruct()
					move.to = player
					move.to_place = sgs.Player_PlaceHand
					for i=1, #HegLuoshen_cdids, 1 do
						move.card_ids:append(HegLuoshen_cdids[i])
					end
					room:moveCardsAtomic(move, true)
				end
			end
		end
		return false
	end
}

HegRendeCard = sgs.CreateSkillCard{
	name = "HegRende",
	will_throw = false,
	target_fixed = false,
	filter = function(self, targets, to_select, player)
		return #targets<1 and to_select:objectName()~=player:objectName()
	end,
	on_use = function(self, room, source, targets)
		ShowGeneral(source, "heg_liubei")
		room:broadcastSkillInvoke("rende")
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName())
		reason.m_playerId = targets[1]:objectName()
		room:moveCardTo(self, targets[1], sgs.Player_PlaceHand, reason, false)
		local old_num = source:getMark("HegRende_count")
		local new_num = old_mark+self:subcardsLength()
		room:setPlayerMark(source, "HegRende_count", new_num)
		if old_num<3 and new_num>=3 then
			local recover = sgs.RecoverStruct()
			recover.who = source
			room:recover(source, recover)
		end
	end
}
HegRendeVs = sgs.CreateViewAsSkill{
	name = "HegRende",
	n = 998,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards==0 then return nil end
		local vscard = HegRendeCard:clone()
		for _,cd in ipairs(cards) do
			vscard:addSubcard(cd)
		end
		return vscard
	end,
}
HegRende = sgs.CreateTriggerSkill{
	name = "HegRende",
	view_as_skill = HegRendeVs,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if data:toPhaseChange().from == sgs.Player_Play then
			room:setPlayerMark(player, "HegRende_count", 0)
		end
		return false
	end
}

HegJizhi = sgs.CreateTriggerSkill{
	name = "HegJizhi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.CardResponsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card
		if event == sgs.CardUsed then
			card = data:toCardUse().card
		elseif event == sgs.Cardresponsed then
			card = data:toResponsed().m_card
		end
		if card:isKindOf("NDTrick") and not card:isVirtualCard() 
			and sgs.Sanguosha:getCard(card:getSubcards():first()):objectName()~=self:objectName() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
                room:broadcastSkillInvoke("jizhi")
                player:drawCards(1)
            end
        end
        return false
    end,
}

HegKongcheng = sgs.CreateCancelSkill("HegKongcheng", "Slash|Duel")

HegZhihengCard = sgs.CreateSkillCard{
	name = "HegZhiheng",
	will_throw = true,
	target_fixed = true,
	once = true,
	on_use = function(self, room, source, targets)
		ShowGeneral(player, "heg_sunquan")
		room:throwCard(self)
		source:drawCards(self:subcardsLength())
	end,
}
HegZhiheng = sgs.CreateViewAsSkill{
	name = "HegZhiheng",
	n = 998,
	view_filter = function(self, selected, to_select)
		return #selected<sgs.Self:getMaxHp()
	end,
	view_as = function(self, cards)
		if #cards==0 then return nil end
		local vscard = HegZhihengCard:clone()
		for _,cd in ipairs(cards) do
			vscard:addSubcard(cd)
		end
		return vscard
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#HegZhiheng")
	end,
}

HegQianxun = sgs.CreateCancelSkill("HegQianxun", "Snatch|Indulgence")

HegXiaoji = sgs.CreateTriggerSkill{
	name = "HegXiaoji",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.from and move.from:objectName()==player:objectName() and move.from_places:contains(sgs.Player_PlaceEquip) then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke("xiaoji")
				player:drawCards(2)
			end
		end
	end
}

HegWeimu = sgs.CreateCancelSkill("HegWeimu", "TrickCard")

HegShushen = sgs.CreateTriggerSkill{
	name = "HegShushen", 
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.HpRecover},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local splist = sgs.SPlayerList()
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:getKingdom()==player:getKingdom() then
				splist:append(p)
			end
		end
		if splist:isEmpty() then return false end
		for i=1, data:toRecover().recover, 1 do
			if not room:askForSkillInvoke(player, self:objectName()) then break end
			local target = room:askForPlayerChosen(player, splist, self:objectName())
			room:broadcastSkillInvoke("shushen", string.find(target:getGeneralName(), "liubei") and 2 or 1)
			target:drawCards(1)
		end
		return false
	end
}

HegXiongyiCard = sgs.CreateSkillCard{
	name = "HegXiongyi",
	will_throw = false,
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local kingdoms = {}
		local quns = sgs.SPlayerList()
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if getFaceDownNum(p)<2 then
				if not kingdoms[p:getKingdom()] then
					kingdoms = 0
				end
				kingdoms[p:getKingdom()] = kingdoms[p:getKingdom()]+1
				if p:getKingdom()=="qun" then
					quns:append(p)
				end
			end
		end
		for _,p in sgs.qlist(quns) do
			p:drawCards(3)
		end
		for _,kg in ipairs(kingdoms) do
			if kg<kingdoms[source:getKingdom()] then return end
		end
		local recover = sgs.RecoverStruct()
		recover.who = source
		room:recover(source, recover)
	end
}
HegXiongyiVs = sgs.CreateViewAsSkill{
	name = "HegXiongyi",
	n = 0,
	view_as = function(self, cards)
		return HegXiongyiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@arise")>0
	end,
}
HegXiongyi = sgs.CreateTriggerSkill{
	name = "HegXiongyi",
	view_as_skill = HegXiongyiVs,
	frequency = sgs.Skill_Limited,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
	end,
}

HegMingshi = sgs.CreateTriggerSkill{
	name = "HegMingshi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if not damage.from or getFaceDownNum(damage.from) == 0  then return false end
		if not askForShowTrigger(player, self:objectName()) then return false end
		room:broadcastSkillInvoke(self:objectName())
		
		local log = sgs.LogMessage()
		log.type = "#Mingshi"
		log.from = player
		log.arg = damage.damage
		log.arg2 = damage.damage-1
		room:sendLog(log)
		
		damage.damage = damage-1
		data:setValue(damage)
	end
}

HegSuishi = sgs.CreateTriggerSkill{
	name = "HegSuishi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Dying, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Dying then
			local damage = data:toDying().damage
			if not damage or not damage.from then return false end
			if isSameKingdom(damage.from, player) then
				if not askForShowTrigger(player, self:objectName()) then return false end
				room:broadcastSkillInvoke(self:objectName(), 1)
				player:drawCards(1)
			end
		elseif event == sgs.Death then
			local who = data:toDeath().who
			if isSameKingdom(who, player) then
				if not askForShowTrigger(player, self:objectName()) then return false end
				room:broadcastSkillInvoke(self:objectName(), 2)
				room:loseHp(player)
			end
		end
	end,
}

HegShuangrenCard = sgs.CreateSkillCard{
	name = "HegShuangren", 
	target_fixed = false, 
	will_throw = false, 
	handling_method = sgs.Card_MethodPindian,
	filter = function(self, targets, to_select) 
		return #targets == 0 and not to_select:isKongcheng() and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect) 
		local room = effect.from:getRoom()
		local success = effect.from:pindian(effect.to, "HegShuangren", self)
		if success then
			local targets = sgs.SPlayerList()
			local others = room:getOtherPlayers(effect.from)
			for _,target in sgs.qlist(others) do
				if effect.from:canSlash(target, nil, false) and isSameKingdom(effect.to, target) then
					targets:append(target)
				end
			end
			if effect.from:canSlash(effect.to, nil, false) and not targets:contains(effect.to) then
				targets:append(effect.to)
			end
			if not targets:isEmpty() then
				local target = room:askForPlayerChosen(effect.from, targets, "shuangren-slash")
				local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				slash:setSkillName("HegShuangren")
				local card_use = sgs.CardUseStruct()
				card_use.card = slash
				card_use.from = effect.from
				card_use.to:append(target)
				room:useCard(card_use, false)
			end
		else
			room:broadcastSkillInvoke("shuangren", 2)
			room:setPlayerFlag(effect.from, "SkipPlay")
		end
	end
}
HegShuangrenVS = sgs.CreateViewAsSkill{
	name = "HegShuangren", 
	n = 1, 
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end, 
	view_as = function(self, cards) 
		if #cards == 1 then
			local card = HegShuangrenCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end, 
	enabled_at_play = function(self, player)
		return false
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@HegShuangren"
	end
}
HegShuangren = sgs.CreateTriggerSkill{
	name = "HegShuangren",  
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.EventPhaseStart},  
	view_as_skill = HegShuangrenVS, 
	on_trigger = function(self, event, player, data) 
		if player:getPhase() == sgs.Player_Play then
			local room = player:getRoom()
			local can_invoke = false
			local other_players = room:getOtherPlayers(player)
			for _,p in sgs.qlist(other_players) do
				if not player:isKongcheng() then
					can_invoke = true
					break
				end
			end
			if can_invoke then
				if not askForShowTrigger(player, self:objectName()) then return false end
				room:askForUseCard(player, "@@HegShuangren", "@shuangren-card", -1, sgs.Card_MethodPindian)
			end
			if player:hasFlag("SkipPlay") then
				return true
			end
		end
		return false
	end
}

HegKuanggu = sgs.CreateTriggerSkill{
	name = "HegKuanggu",
	frequency = sgs.Skill_Compulsory, 
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		local damage = data:toDamage()
		if player:isWounded() and player:distanceTo(damage.to)==1 then
			if not askForShowTrigger(player, self:objectName()) then return false end
			local recover = sgs.RecoverStruct()
			recover.who = player
			recover.recover = damage.damage
			room:recover(player, recover)
		end
		return false
	end,
}

function HegAvoidSA(name)
	HegAvoidSavageAssault = sgs.CreateTriggerSkill{
		name = "#heg_sa_avoid_"..name,
		frequency = sgs.Skill_Compulsory,
		events = {sgs.CardEffected},
		on_trigger = function(self, event, player, data)
			local room = player:getRoom()
			local effect = data:toCardEffect()
			if effect.card:isKindOf("SavageAssault") then
				local oname
				if name == "huoshou" then oname = "HegHuoshou"
				else oname = "HegJuxiang" end
				if not askForShowTrigger(player, oname) then return false end
				room:broadcastSkillInvoke(name)
				return true
			end
		end
	}
	return HegAvoidSavageAssault
end

HegHuoshouAvoid = HegAvoidSA("huoshou")
HegJuxiangAvoid = HegAvoidSA("juxiang")

HegJieyinCard = sgs.CreateSkillCard{
	name = "HegJieyin",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select, player)
		return #targets == 0 and to_select:isWounded() and to_select:isMale() and to_select:objectName()~=player:objectName()
	end,
	on_use = function(self, room, player, targets)
		local recover = sgs.RecoverStruct()
		recover.card = self
		recover.who = player
		room:recover(player, recover, true)
		room:recover(targets[1], recover, true)
	end
}
HegJieyin = sgs.CreateViewAsSkill{
	name = "HegJieyin",
	n = 2,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 2 then
			local card = HegJieyinCard:clone()
			card:addSubcard(cards[1])
			card:addSubcard(cards[2])
			return card
		end
	end,
	enabled_at_play = function(self, target)
		return not target:hasUsed("#HegJieyin")
	end
}

function sgs.CreateMaShu(gname)
	HegMashu = sgs.CreateDistanceSkill{
		name = "HegMashu"..gname,
		correct_func = function(self, from, to)
			if from:hasSkill(self:objectName()) and isSkillShown(from, self:objectName()) then
				return -1
			end
			return 0
		end,
	}
	sgs.LoadTranslationTable{
		["HegMashu"..gname] = "马术",
		[":HegMashu"..gname] = "<b>锁定技</b>，当你计算与其他角色的距离时，始终-1。",
	}
	return HegMashu
end

HegMashuMC = sgs.CreateMaShu("MC")
HegMashuMT = sgs.CreateMaShu("MT")
HegMashuPD = sgs.CreateMaShu("PD")

HegXiangle = sgs.CreateTriggerSkill{
	name = "HegXiangle", 
	frequency = sgs.Skill_Compulsory, 
	events = {sgs.SlashEffected, sgs.TargetConfirming},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirming then
			local use = data:toCardUse()
			local slash = use.card
			if slash and slash:isKindOf("Slash") then
				if not askForShowTrigger(player, "HegXiangle") then return false end
				local ai_data = sgs.QVariant()
				ai_data:setValue(player)
				if not room:askForCard(use.from, ".Basic", "@xiangle-discard", ai_data, sgs.CardDiscarded) then
					player:addMark("heg_xiangle")
				end
			end
		else
			if not isSkillShown(player, "HegXiangle") then return false end
			local count = player:getMark("heg_xiangle")
			if count > 0 then
				player:setMark("heg_xiangle", count - 1)
				return true
			end
		end
		return false
	end
}

HegWushuang = sgs.CreateTriggerSkill{
	name = "HegWushuang", 
	frequency = sgs.Skill_Compulsory, 
	events = {sgs.TargetConfirmed, sgs.SlashProceed},
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if use.from and use.from:objectName()~=player:objectName() then return false end
			if not askForShowTrigger(player, "HegWushuang") then return false end
			local card = use.card
			if card:isKindOf("Slash") then
				if use.from:objectName() == player:objectName() then
					room:setCardFlag(card, "WushuangInvke")
				end
			elseif card:isKindOf("Duel") then
				room:setCardFlag(card, "WushuangInvke")
			end
		elseif event == sgs.SlashProceed then
			local effect = data:toSlashEffect()
			local dest = effect.to
			if effect.slash:hasFlag("WushuangInvke") then
				local slasher = player:objectName()
				local hint = string.format("@wushuang-jink-1:%s", slasher)
				local first_jink = room:askForCard(dest, "jink", hint, sgs.QVariant(), sgs.CardUsed, player)
				local second_jink = nil
				if first_jink then
					hint = string.format("@wushuang-jink-2:%s", slasher)
					second_jink = room:askForCard(dest, "jink", hint, sgs.QVariant(), sgs.CardUsed, player)
				end
				local jink = nil
				if first_jink and second_jink then
					jink = sgs.Sanguosha:cloneCard("Jink", sgs.Card_NoSuit, 0)
					jink:addSubcard(first_jink)
					jink:addSubcard(second_jink)
				end
				room:slashResult(effect, jink)
			end
			return true
		end
		return false
	end,
}

HegWansha = sgs.CreateTriggerSkill{
	name = "HegWansha",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.AskForPeaches, sgs.Dying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Dying and player:hasSkill("HegWansha") then
			if player:getPhase()~=sgs.Player_NotActive then
				if not askForShowTrigger(player, "HegWansha") then return false end
			end
		elseif event == sgs.AskForPeaches then
			local current = room:getCurrent()
			if current:isAlive() and current:hasSkill(self:objectName()) then
				if isSkillShown(player, "HegWansha") then
					local dying = data:toDying()
					local victim = dying.who
					local seat = player:getSeat()
					if current:getSeat() ~= seat then return victim:getSeat() ~= seat end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}

HegHuoshou = sgs.CreateTriggerSkill{
	name = "HegHuoshou",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local card = damage.card
		local source = room:findPlayerBySkillName(self:objectName())
		if source and damage.from and source:objectName()~=damage.from:objectName() and card and card:isKindOf("SavageAssault") then
			if not askForShowTrigger(player, "HegHuoshou") then return false end
			if source:isAlive() then
				damage.from = source
			else
				damage.from = nil
			end
			data:setValue(damage)
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}

HegJuxiang = sgs.CreateTriggerSkill{
	name = "HegJuxiang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoving,sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isVirtualCard() and use.card:isKindOf("SavageAssault") then
				if use.card:subcardsLength() == 1 and sgs.Sanguosha:getCard(use.card:getSubcards():first()):isKindOf("SavageAssault") then
					room:setCardFlag(use.card:getSubcards():first(), "real_SA")
				end
			end
		elseif event == sgs.CardsMoving then
			local move = data:toMoveOneTime()
			if move.card_ids:length() == 1 and move.from_places:contains(sgs.Player_PlaceTable) and move.to_place == sgs.Player_DiscardPile then
				if move.reason.m_reason ~= sgs.CardMoveReason_S_REASON_USE then return false end
				local card = sgs.Sanguosha:getCard(move.card_ids:first())
				if card:hasFlag("real_SA") then
					for _,p in sgs.qlist(room:getAllPlayers()) do
						if p:hasSkill(self:objectName()) and p:objectName() ~= move.from:objectName() then
							if not askForShowTrigger(player, "HegJuxiang") then return false end
							p:obtainCard(card)
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}

HegQiaobianCard = sgs.CreateSkillCard{
	name = "HegQiaobianCard", 
	target_fixed = false, 
	will_throw = false, 
	filter = function(self, targets, to_select)
		local phase = sgs.Self:getMark("qiaobianPhase")
		if phase == sgs.Player_Draw then
			return #targets < 2 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng()
		elseif phase == sgs.Player_Play then
			if #targets >0 then return false end
			return to_select:getJudgingArea():length() >0 or to_select:getEquips():length() > 0
		end
		return false
	end,
	feasible = function(self, targets)
		local phase = sgs.Self:getMark("qiaobianPhase")
		if phase == sgs.Player_Draw then return #targets <= 2
		elseif phase == sgs.Player_Play then return #targets == 1
		end
		return false
	end,
	on_use = function(self, room, source, targets) 
		local phase = source:getMark("qiaobianPhase")
		if phase == sgs.Player_Draw then
			if #targets > 0 then
				local move1 = sgs.CardsMoveStruct()
				local id1 = room:askForCardChosen(source, targets[1], "h", self:objectName())
				move1.card_ids:append(id1)
				move1.to = source
				move1.to_place = sgs.Player_PlaceHand
				if #targets == 2 then
					local move2 = sgs.CardsMoveStruct()
					local id2 = room:askForCardChosen(source, targets[2], "h", self:objectName())
					move2.card_ids:append() 
					move2.to = source
					move2.to_place = Player_PlaceHand
					room:moveCardsAtomic(move2, false)
				end
				room:moveCardsAtomic(move1, false)
			end
		elseif phase == sgs.Player_Play then
			if #targets > 0 then
				local from = targets[1]
				if from:hasEquip() or from:getJudgingArea():length() > 0 then
					local card_id = room:askForCardChosen(source, from, "ej", self:objectName())
					local card = sgs.Sanguosha:getCard(card_id)
					local place = room:getCardPlace(card_id)
					local equip_index = -1
					if place == sgs.Player_PlaceEquip then
						local equip = card:getRealCard()
						equip_index = equip:location()
					end
					local tos = sgs.SPlayerList()
					local list = room:getAlivePlayers()
					for _,p in sgs.qlist(list) do
						if equip_index ~= -1 then
							if p:getEquip(equip_index) then
								tos:append(p)
							end
						else
							if not source:isProhibited(p, card) and not p:containsTrick(card:objectName()) then
								tos:append(p)
							end
						end
					end
					local tag = sgs.QVariant()
					tag.setValue(from)
					room:setTag("QiaobianTarget", tag)
					local to = room:askForPlayerChosen(source, tos, "qiaobian")
					if to then
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, source:objectName(), self:objectName(), "")
						room:moveCardTo(card, from, to, place, reason)
					end
					room:removeTag("QiaobianTarget")
				end
			end
		end
	end
}
HegQiaobianVS = sgs.CreateViewAsSkill{
	name = "HegQiaobianVS", 
	n = 0, 
	view_as = function(self, cards) 
		return HegQiaobianCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return false
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "@qiaobian"
	end
}
HegQiaobian = sgs.CreateTriggerSkill{
	name = "HegQiaobian", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.EventPhaseChanging}, 
	view_as_skill = HegQiaobianVS, 
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		local nextphase = data:toPhaseChange().to
		room:setPlayerMark(player, "qiaobianPhase", nextphase)
		if player:isKongcheng() then return false end
		local index = 0
		if nextphase == sgs.Player_Judge then
			index = 1
		elseif nextphase == sgs.Player_Draw then
			index = 2
		elseif nextphase == sgs.Player_Play then
			index = 3
		elseif nextphase == sgs.Player_Discard then
			index = 4
		end
		local discard_prompt = string.format("#qiaobian-%d", index)
		local use_prompt = string.format("@qiaobian-%d", index)
		if index > 0 then
			if room:askForDiscard(player, self:objectName(), 1, 1, true, false, discard_prompt) then
				ShowGeneral(player, "heg_zhanghe")
				if not player:isSkipped(nextphase) then
					if index == 2 or index == 3 then
						room:askForUseCard(player, "@qiaobian", use_prompt, index)
					end
				end
				player:skip(nextphase)
			end
		end
		return false
	end, 
}

HegQingchengCard = sgs.CreateSkillCard{
	name = "HegQingcheng",
	will_throw = true,
	target_fixed = false,
	filter = function(self, targets, to_select, player)
		return #targets<1 and getFaceDownNum(to_select)==0 and to_select:objectName()~=player:objectName()
	end,
	on_use = function(self, room, source, targets)
		room:throwCard(self, source)
		local general = targets[1]:getGeneralName().."+"..targets[1]:getGeneral2Name()
		local TOG = room:askForGeneral(source, general)
		if not TOG then return end
		local isG2 = TOG~=targets[1]:getGeneralName()
		room:setPlayerProperty(targets[1], isG2 and "general2" or "general", sgs.QVariant("anjiang"))
		local TOGeneral = sgs.Sanguosha:getGeneral(TOG)
		for _,sk in sgs.qlist(TOGeneral:getSkillList()) do
			room:getThread():trigger(sgs.EventLoseSkill, room, targets[1], sgs.QVariant(sk:objectName()))
		end
		if TOGeneral:hasSkill("hongyan") then room:detachSkillFromPlayer(targets[1], "hongyan") end
		room:setTag("heg_"..targets[1]:objectName(), sgs.QVariant(TOG))
		if source:hasSkill("HegHuoshui") and isSkillShown(source, "HegHuoshui") then
			local SkTb = {}
			for _,sk in sgs.qlist(TOGeneral:getSkillList()) do
				if targets[1]:hasSkill(sk:objectName()) then
					table.insert(SkTb, sk:objectName())
					room:setPlayerMark(p, "Qingcheng"..sk:objectName(), 1)
				end
			end
			room:setTag("HegHuoshui_"..p:objectName(), sgs.QVariant(table.concat(SkTb, "+")))
		end
	end,
}
HegQingcheng = sgs.CreateViewAsSkill{
	name = "HegQingcheng",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isKindOf("EquipCard")
	end,
	view_as = function(self, cards)
		if #cards~=1 then return nil end
		local vscard = HegQingchengCard:clone()
		vscard:addSubcard(cards[1])
		return vscard
	end,
}

HegHuoshuiCard = sgs.CreateSkillCard{
	name = "HegHuoshui",
	will_throw = false,
	target_fixed = true,
	on_use = function(self, room, source, targets)
		ShowGeneral(source, "heg_zoushi")
	end,
}
HegHuoshuiVs = sgs.CreateViewAsSkill{
	name = "HegHuoshui",
	n = 0,
	view_as = function(self, cards)
		return HegHuoshuiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not isSkillShown(player, "HegHuoshui")
	end,
}
HegHuoshui = sgs.CreateTriggerSkill{
	name = "HegHuoshui",
	view_as_skill = HegHuoShuiVs,
	events = {sgs.EventPhaseStart, sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if not isSkillShown(player, "HegHuoshui") then return false end
			if player:getPhase()==sgs.Player_RoundStart then
				for _,p in sgs.qlist(room:getOtherPlayers(player)) do
					if getFaceDownNum(p)>0 then
						local SkTb = {}
						for _,g in ipairs(getGenerals(p)) do
							for _,sk in sgs.qlist(g:getSkillList()) do
								if p:hasSkill(sk:objectName()) then
									table.insert(SkTb, sk:objectName())
									room:setPlayerMark(p, "Qingcheng"..sk:objectName(), 1)
								end
							end
						end
						if #SkTb>0 then
							room:setTag("HegHuoshui_"..p:objectName(), sgs.QVariant(table.concat(SkTb, "+")))
						end
					end
				end				
			elseif player:getPhase()==sgs.Player_NotActive then
				for _,p in sgs.qlist(room:getOtherPlayers(player)) do
					local sks = room:getTag("HegHuoshui_"..p:objectName()):toString()
					if sks and sks~="" then
						for _,sk in ipairs(sks:split("+")) do
							room:setPlayerMark(p, "Qingcheng"..sk:objectName(), 0)
						end
					end
				end
			end
		elseif event == sgs.EventLoseSkill then
			local skill = data:toString()
			if skill and skill==self:objectName() then
				for _,p in sgs.qlist(room:getOtherPlayers(player)) do
					local sks = room:getTag("HegHuoshui_"..p:objectName()):toString()
					if sks and sks~="" then
						for _,sk in ipairs(sks:split("+")) do
							room:setPlayerMark(p, "Qingcheng"..sk:objectName(), 0)
						end
					end
				end
			end
		end
	end,
}

HegDuanchang = sgs.CreateTriggerSkill{
	name = "HegDuanchang",
	events = {sgs.Death},
	can_trigger = function(self, player)
		return player:hasSkill("HegDuanchang")
	end,
	on_trigger =  function(self, event, player, data)
		local death = data:toDeath()
		if death.who:objectName()~=player:objectName() then return false end
		if not death.damage or not death.damage.from then return end
		local killer = death.damage.from
		local choice = room:askForChoice(player, self:objectName(), "DCgeneral+DCgeneral2")
		local isG2 = choice=="DCgeneral2"
		local general = isG2 and killer:getGeneral2() or killer:getGeneral()
		killer:gainMark("@duanchang")
		killer:gainMark("@"..choice)
		local lsg
		if general:objectName()~="anjiang" then
			lsg = general
		else
			if getFaceDownNum(killer)==2 then
				lsg = isG2 and getGenerals(killer)[2] or getGenerals(killer)[1]
			else
				lsg = getGenerals(killer)[1]
			end
		end
		if lsg then
			for _,sk in sgs.qlist(lsg:getSkillList()) do
				room:detachSkillFromPlayer(killer, sk:objectName())
			end
		end
	end,
}

HegLijian_card = sgs.CreateSkillCard{
	name = "HegLijian",
	target_fixed = false,
	will_throw = true,
	feasible = function(self, targets)
		return #targets == 2
	end,
	filter = function(self, targets, to_select,player)
		if not to_select:getGeneral():isMale() or player:isProhibited(to_select, duel) 
				or to_select:objectName()==player:objectName() then return false end
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		if #targets == 1 then
			player:setTag("HegLijianTarget", sgs.QVariant(targets[1]:objectName()))
			return true
		elseif #targets == 0 then return true end
		return false
	end,
	on_use = function(self, room, source, targets)
		ShowGeneral(source, "heg_diaochan")
		local toN = source:getTag("HegLijianTarget"):toString()
		if not toN or toN == "" then return end
		local to = toN == targets[1]:objectName() and targets[2] or targets[1]
		local from = to == targets[1] and targets[2] or targets[1]
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		duel:toTrick():setCancelable(false)
		duel:setSkillName("HegLijian")
		room:removeTag("HegLijianTarget")
		local use = sgs.CardUseStruct()
		use.from = from
		use.to:append(to)
		use.card = duel
		room:useCard(use)
	end,
}
HegLijian = sgs.CreateViewAsSkill{
	name = "HegLijian",
	n = 1,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards ~= 1  then return nil end
		local card = HegLijianCard:clone()
		card:addSubcard(cards[1])
		card:setSkillName(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#HegLijian")
	end
}

function translate(gnametb)
	for gname,tname in pairs(gnametb) do
		sgs.LoadTranslationTable{["heg_"..gname] = tname}
	end
end

sgs.LoadTranslationTable{
	["HegLuoshen"] = "洛神",
	[":HegLuoshen"] = "回合开始阶段开始时，你可以进行一次判定，若结果为黑色，你可以再次进行判定，直到出现红色的判定结果为止。然后你获得所有黑色的判定牌。",
	["HegRende"] = "仁德",
	[":HegRende"] = "出牌阶段，你可以将任意数量的手牌交给其他角色，若此阶段你给出的牌张数达到三张或更多时，你回复1点体力。",
	["HegJizhi"] = "集智",
	[":HegJizhi"] = "每当你使用一张非转化的非延时类锦囊牌时，你可以摸一张牌。",
	["HegKongcheng"] = "空城",
	[":HegKongcheng"] = "<b>锁定技</b>，当你成为【杀】或【决斗】的目标时，若你没有手牌，取消之。",
	["HegZhiheng"] = "制衡",
	[":HegZhiheng"] = "出牌阶段，你可以弃置至多X张牌（X为你的体力上限），然后摸等量的牌。每阶段限一次。",
	["HegQianxun"] = "谦逊",
	[":HegQianxun"] = "<b>锁定技</b>，当你成为【顺手牵羊】或【乐不思蜀】的目标时，取消之。",
	["HegXiaoji"] = "枭姬",
	[":HegXiaoji"] = "当你失去一次装备区里的装备牌时，你可以摸两张牌。",
	["HegWeimu"] = "帷幕",
	[":HegWeimu"] = "<b>锁定技</b>，当你成为黑色锦囊牌的目标时，取消之。",
	["HegShushen"] = "淑慎",
	[":HegShushen"] = "当你回复1点体力时，你可以令一名与你势力相同的其他角色摸一张牌。",
	["HegXiongyi"] = "雄异",
	[":HegXiongyi"] = "<b>限定技</b>，出牌阶段，你可令所有与你势力相同的角色摸三张牌，然后若你所属势力的角色数是全场最少的（或之一），你回复1点体力。",
	["HegMingshi"] = "名士",
	[":HegMingshi"] = "每当你受到伤害时，若伤害来源有暗置的武将牌，此伤害-1。",
	["HegSuishi"] = "随势",
	[":HegSuishi"] = "<b>锁定技</b>，当一名其他角色进入濒死状态时，若伤害来源与你势力相同，你摸一张牌；其他与你势力相同的角色死亡时，你失去1点体力。",
	["HegShuangren"] = "双刃",
	[":HegShuangren"] = "出牌阶段开始时，你可以与一名角色拼点，若你赢，视为你对其或一名与其势力相同的其他角色使用一张【杀】（此【杀】不计入出牌阶段使用次数的限制）。若你没赢，你结束出牌阶段。",
	["HegKuanggu"] = "狂骨",
	[":HegKuanggu"] = "<b>锁定技</b>，每当你对距离1以内的一名角色造成1点伤害后，你回复1点体力。",
	["HegJieyin"] = "结姻",
	[":HegJieyin"] = "出牌阶段，你可以弃置两张手牌并选择一名已受伤的其他男性角色，你与其各回复1点体力。每阶段限一次。",
	["HegXiangle"] = "享乐",
	[":HegXiangle"] = "<b>锁定技</b>，当其他角色使用【杀】指定你为目标时，需额外弃置一张基本牌，否则该【杀】对你无效。",
	["HegWushuang"] = "无双",
	[":HegWushuang"] = "<b>锁定技</b>，当你使用【杀】时指定一名角色为目标后，该角色需连续使用两张【闪】才能抵消；与你进行【决斗】角色每次需连续打出两张【杀】。",
	["HegWansha"] = "完杀",
	[":HegWansha"] = "<b>锁定技</b>，在你的回合，除你以外，只有处于濒死状态的角色才能使用【桃】。",
	["HegHuoshou"] = "祸首",
	[":HegHuoshou"] = "<b>锁定技</b>，【南蛮入侵】对你无效；你是任何【南蛮入侵】造成伤害的来源。",
	["HegJuxiang"] = "巨象",
	[":HegJuxiang"] = "<b>锁定技</b>，【南蛮入侵】对你无效；若其他角色使用的【南蛮入侵】在结算后置入弃牌堆，你获得之。",
	["HegQiaobian"] = "巧变",
	[":HegQiaobian"] = "你可以弃置一张手牌跳过你的一个阶段（回合开始阶段和回合结束阶段除外）；若以此法跳过摸牌阶段，你获得其他至多两名角色各一张手牌；若以此法跳过出牌阶段，你可以将场上的一张牌移动到另一名角色区域里的相应位置。",
	["HegQingcheng"] = "倾城",
	[":HegQingcheng"] = "出牌阶段，你可以弃置一张装备牌并选择一名两张武将牌均明置的其他角色，你暗置其一张武将牌。",
	["HegHuoshui"] = "祸水",
	[":HegHuoshui"] = "出牌阶段，你可以明置此武将牌，你的回合内，若此武将牌处于明置状态，其他角色不能明置其武将牌。",
	["HegDuanchang"] = "断肠",
	[":HegDuanchang"] = "<b>锁定技</b>，你死亡时，你令杀死你的角色选择失去一张武将牌的技能。",
	["HegLijian"] = "离间",
	[":HegLijian"] = "出牌阶段，你可以弃置一张牌并选择两名其他男性角色，然后视为其中一名男性角色对另一名男性角色使用一张【决斗】。此【决斗】不能被【无懈可击】响应。每阶段限一次。",
}

--wei
HegCaocao = sgs.General(extension, "heg_caocao", "wei", 4)
HegCaopi = sgs.General(extension, "heg_caopi", "wei", 3)
HegZhenji = sgs.General(extension, "heg_zhenji", "wei", 3)
HegYuejin = sgs.General(extension, "heg_yuejin", "wei", 4)
HegGuojia = sgs.General(extension, "heg_guojia", "wei", 3)
HegSimayi = sgs.General(extension, "heg_simayi", "wei", 3)
HegXunyu = sgs.General(extension, "heg_xunyu", "wei", 3)
HegZhanghe = sgs.General(extension, "heg_zhanghe", "wei", 4)
HegZhangliao = sgs.General(extension, "heg_zhangliao", "wei", 4)
HegXuHuang = sgs.General(extension, "heg_xuhuang", "wei", 4)
HegXiahoudun = sgs.General(extension, "heg_xiahoudun", "wei", 4)
HegXiahouyuan = sgs.General(extension, "heg_xiahouyuan", "wei", 4)
HegXuchu = sgs.General(extension, "heg_xuchu", "wei", 4)
HegDianwei = sgs.General(extension, "heg_dianwei", "wei", 4)
HegCaoren = sgs.General(extension, "heg_caoren", "wei", 4)

--shu
HegLiubei = sgs.General(extension, "heg_liubei", "shu", 4)
HegGanfuren = sgs.General(extension, "heg_ganfuren", "shu", 4)
HegZhugeliang = sgs.General(extension, "heg_zhugeliang", "shu", 3)
HegHuangyueying = sgs.General(extension, "heg_huangyueying", "shu", 3)
HegWolong = sgs.General(extension, "heg_wolong", "shu", 3)
HegPangtong = sgs.General(extension, "heg_pangtong", "shu", 3)
HegGuanyu = sgs.General(extension, "heg_guanyu", "shu", 5)
HegZhangfei = sgs.General(extension, "heg_zhangfei", "shu", 4)
HegZhaoyun = sgs.General(extension, "heg_zhaoyun", "shu", 4)
HegHuangzhong = sgs.General(extension, "heg_huangzhong", "shu", 4)
HegMachao = sgs.General(extension, "heg_machao", "shu", 4)
HegWeiyan = sgs.General(extension, "heg_weiyan", "shu", 4)
HegLiushan = sgs.General(extension, "heg_liushan", "shu", 3)
HegMenghuo = sgs.General(extension, "heg_menghuo", "shu", 4)
HegZhurong = sgs.General(extension, "heg_zhurong", "shu", 4)

--wu
HegSunquan = sgs.General(extension, "heg_sunquan", "wu", 4)
HegLuxun = sgs.General(extension, "heg_luxun", "wu", 3)
HegSunshangxiang = sgs.General(extension, "heg_sunshangxiang", "wu", 3)
HegZhouyu = sgs.General(extension, "heg_zhouyu", "wu", 3)
HegXiaoqiao = sgs.General(extension, "heg_xiaoqiao", "wu", 3)
HegDingfeng = sgs.General(extension, "heg_dingfeng", "wu", 4)
HegDaqiao = sgs.General(extension, "heg_daqiao", "wu", 3)
HegLusu = sgs.General(extension, "heg_lusu", "wu", 3)
HegErzhang = sgs.General(extension, "heg_erzhang", "wu", 3)
HegSunjian = sgs.General(extension, "heg_sunjian", "wu", 4)
HegTaishici = sgs.General(extension, "heg_taishici", "wu", 4)
HegGanning = sgs.General(extension, "heg_ganning", "wu", 4)
HegHuanggai = sgs.General(extension, "heg_huanggai", "wu", 4)
HegLvmeng = sgs.General(extension, "heg_lvmeng", "wu", 4)
HegZhoutai = sgs.General(extension, "heg_zhoutai", "wu", 4)

--qun
HegMateng = sgs.General(extension, "heg_mateng", "qun", 4)
HegZoushi = sgs.General(extension, "heg_zoushi", "qun", 3)
HegTianfeng = sgs.General(extension, "heg_tianfeng", "qun", 3)
HegKongrong = sgs.General(extension, "heg_kongrong", "qun", 3)
HegPanfeng = sgs.General(extension, "heg_panfeng", "qun", 4)
HegJiling = sgs.General(extension, "heg_jiling", "qun", 4)
HegLvbu = sgs.General(extension, "heg_lvbu", "qun", 5)
HegDiaochan = sgs.General(extension, "heg_diaochan", "qun", 3)
HegYuanshao = sgs.General(extension, "heg_yuanshao", "qun", 4)
HegYanliangwenchou = sgs.General(extension, "heg_yanliangwenchou", "qun", 4)
HegZhangjiao = sgs.General(extension, "heg_zhangjiao", "qun", 3)
HegJiaxu = sgs.General(extension, "heg_jiaxu", "qun", 3)
HegCaiwenji = sgs.General(extension, "heg_caiwenji", "qun", 3)
HegHuatuo = sgs.General(extension, "heg_huatuo", "qun", 3)
HegPangde = sgs.General(extension, "heg_pangde", "qun", 4)

translate{caocao="曹操", caopi="曹丕", zhenji="甄姬", yuejin="乐进", guojia="郭嘉", simayi="司马懿", xunyu="荀彧",
	zhanghe="张郃", zhangliao="张辽", xuhuang="徐晃", xiahoudun="夏侯惇", xiahouyuan="夏侯淵", xuchu="许褚",
	dianwei="典韦", caoren="曹仁", liubei="刘备", ganfuren="甘夫人", zhugeliang="诸葛亮", huangyueying="黃月英",
	wolong="臥龙", pangtong="庞统", guanyu="关羽", zhangfei="张飞", zhaoyun="赵云", huangzhong="黃忠", machao="马超",
	weiyan="魏延", liushan="刘禅", menghuo="孟获", zhurong="祝融", sunquan="孙权", luxun="陸逊", sunshangxiang="孙尚香",
	zhouyu="周瑜", xiaoqiao="小乔", dingfeng="丁奉", daqiao="大乔", lusu="鲁肃", erzhang="张昭&张纮", sunjian="孙堅",
	taishici="太史慈", ganning="甘宁", huanggai="黃盖", lvmeng="吕蒙", zhoutai="周泰", mateng="马腾", zoushi="邹氏",
	tianfeng="田丰", kongrong="孔融", panfeng="潘凤", jiling="纪灵", lvbu="吕布", diaochan="貂蝉", yuanshao="袁绍",
	yanliangwenchou="颜良&文丑", zhangjiao="张角", jiaxu="贾诩", caiwenji="蔡文姬", huatuo="华佗", pangde="庞德"}

--wei
HegCaocao:addSkill("jianxiong")
HegCaopi:addSkill("fangzhu")
HegCaopi:addSkill("xingshang")
HegZhenji:addSkill("qingguo")
HegZhenji:addSkill(HegLuoshen)
HegYuejin:addSkill("xiaoguo")
HegGuojia:addSkill("tiandu")
HegGuojia:addSkill("yiji")
HegSimayi:addSkill("fankui")
HegSimayi:addSkill("guidao")
HegXunyu:addSkill("jieming")
HegXunyu:addSkill("quhu")
HegXiahoudun:addSkill("ganglie")
HegXiahouyuan:addSkill("shensu")
HegXuchu:addSkill("luoyi")
HegDianwei:addSkill("qiangxi")
HegCaoren:addSkill("jushou")
HegZhangliao:addSkill("tuxi")
HegXuHuang:addSkill("duanliang")
HegXuHuang:addSkill("#duanliang-target")
HegZhanghe:addSkill(HegQiaobian)

--shu
HegLiubei:addSkill(HegRende)
HegGanfuren:addSkill("shenzhi")
HegGanfuren:addSkill(HegShushen)
HegZhugeliang:addSkill("guanxing")
HegZhugeliang:addSkill(HegKongcheng)
HegHuangyueying:addSkill("qicai")
HegHuangyueying:addSkill(HegJizhi)
HegWolong:addSkill("huoji")
HegWolong:addSkill("kanpo")
HegWolong:addSkill("bazhen")
HegPangtong:addSkill("niepan")
HegPangtong:addSkill("lianhuan")
HegGuanyu:addSkill("wusheng")
HegZhangfei:addSkill("paoxiao")
HegZhaoyun:addSkill("longdan")
HegHuangzhong:addSkill("liegong")
HegMachao:addSkill(HegMashuMC)
HegMachao:addSkill("tieji")
HegWeiyan:addSkill(HegKuanggu)
HegLiushan:addSkill(HegXiangle)
HegLiushan:addSkill("fangquan")
HegLiushan:addSkill("#fangquan-give")
HegMenghuo:addSkill(HegHuoshouAvoid)
HegMenghuo:addSkill(HegHuoshou)
HegMenghuo:addSkill("zaiqi")
HegZhurong:addSkill(HegJuxiangAvoid)
HegZhurong:addSkill(HegJuxiang)
HegZhurong:addSkill("lieren")

--wu
HegSunquan:addSkill(HegZhiheng)
HegLuxun:addSkill(HegQianxun)
HegSunshangxiang:addSkill(HegJieyin)
HegSunshangxiang:addSkill(HegXiaoji)
HegZhouyu:addSkill("yingzhi")
HegZhouyu:addSkill("fanjian")
HegXiaoqiao:addSkill("hongyan")
HegXiaoqiao:addSkill("tianxiang")
HegDingfeng:addSkill("duanbing")
HegDingfeng:addSkill("fenxun")
HegDaqiao:addSkill("liuli")
HegDaqiao:addSkill("guose")
HegLusu:addSkill("dimeng")
HegLusu:addSkill("haoshi")
HegLusu:addSkill("#haoshi-give")
HegErzhang:addSkill("zhijian")
HegErzhang:addSkill("guzheng")
HegErzhang:addSkill("#guzheng-get")
HegSunjian:addSkill("yinghun")
HegTaishici:addSkill("tianyi")
HegGanning:addSkill("qixi")
HegHuanggai:addSkill("kurou")
HegLvmeng:addSkill("keji")
HegZhoutai:addSkill("buqu")

--qun
HegMateng:addSkill(HegMashuMT)
HegMateng:addSkill(HegXiongyi)
HegTianfeng:addSkill(HegSuishi)
HegTianfeng:addSkill("sijian")
HegZoushi:addSkill(HegQingcheng)
HegZoushi:addSkill(HegHuoshui)
HegKongrong:addSkill(HegMingshi)
HegKongrong:addSkill("lirang")
HegPanfeng:addSkill("kuangfu")
HegJiling:addSkill(HegShuangren)
HegDiaochan:addSkill("biyue")
HegDiaochan:addSkill(HegLijian)
HegYuanshao:addSkill("luanji")
HegYanliangwenchou:addSkill("shuangxiong")
HegJiaxu:addSkill(HegWansha)
HegJiaxu:addSkill(HegWeimu)
HegJiaxu:addSkill("luanwu")
HegHuatuo:addSkill("qingnang")
HegHuatuo:addSkill("jijiu")
HegPangde:addSkill(HegMashuPD)
HegPangde:addSkill("mengjin")
HegZhangjiao:addSkill("guidao")
HegZhangjiao:addSkill("leiji")
HegCaiwenji:addSkill(HegDuanchang)
HegCaiwenji:addSkill("beige")
HegLvbu:addSkill(HegWushuang)
