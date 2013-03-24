module("extensions.Emryx", package.seeall)        --Written By Emryx
extension = sgs.Package("Emryx")

tf=sgs.General(extension, "tf", "qun", 5, true,true,true)
ecaocao=sgs.General(extension, "ecaocao$", "wei", 4, true,true)
eDunXH=sgs.General(extension, "eDunXH", "wei", 4, true,true)
eLiaoZ=sgs.General(extension, "eLiaoZ", "wei", 4, true,true)
eChuX=sgs.General(extension, "eChuX", "wei", 4, true,true)
eYuG=sgs.General(extension, "eYuG", "shu", 4, true,true)
espYuG=sgs.General(extension, "espYuG", "wei", 4, true,true)
eFeiZ=sgs.General(extension, "eFeiZ", "shu", 4, true,true)
eYunZ=sgs.General(extension, "eYunZ", "shu", 4, true,true)
eChaoM=sgs.General(extension, "eChaoM", "shu", 4, true,true)
eYuZ=sgs.General(extension, "eYuZ", "wu", 3, true,true)
eYanW=sgs.General(extension, "eYanW", "shu", 4, true,true)
eBuL=sgs.General(extension, "eBuL", "qun", 4, true,true)
eTongP = sgs.General(extension, "eTongP", "shu", 3, true,true)
eJinY = sgs.General(extension, "eJinY", "wei", 4, true,true)
eXiongH=sgs.General(extension, "eXiongH", "qun", 6, true,true)

eHuaL=sgs.General(extension, "eHuaL", "shu", 4, true)
eTaiZ = sgs.General(extension, "eTaiZ", "wu", 4, true)
eZhuoD = sgs.General(extension, "eZhuoD$", "qun", 5, true)
xuanwu=sgs.General(extension, "xuanwu", "qun", 3, false)
yuanwu=sgs.General(extension, "yuanwu", "god", 2, false, true, true)


--001caocao
eXiongJ = sgs.CreateTriggerSkill{
  name = "eXiongJ",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event==sgs.Damaged then
			local damage = data:toDamage()
			if damage.card and room:getCardPlace(damage.card:getEffectiveId())==sgs.Player_PlaceTable then
				if not player:askForSkillInvoke(self:objectName()) then return false end
				room:broadcastSkillInvoke("jianxiong")
				local targets = room:getOtherPlayers(damage.from)
				local target = room:askForPlayerChosen(player, targets, self:objectName())
				room:obtainCard(target, damage.card)
			end
		end
	end
}
YJMark = sgs.CreateTriggerSkill{
	name = "#YJMark",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.HpChanged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark("@ying")<1 and player:getHp()<=2 then
			player:gainMark("@ying")
		elseif player:getMark("@ying")>0 and player:getHp()>2 then
			player:loseMark("@ying")
		end
	end
}
YingJ = sgs.CreateDistanceSkill{
	name = "YingJ",
	correct_func=function(self,from,to)
		if to:hasSkill("YingJ") and to:getHp()<=2 then
			return 1
		end
	end,
}
DeM=sgs.CreateGameStartSkill{
	name = "#DeM",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke("#DeM") then return false end
		if string.find(player:getGeneralName(), "caocao") then
			room:changeHero(player,"ecaocao",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "caocao") then
			room:changeHero(player,"ecaocao",false,false,true,true)
		end
		room:broadcastSkillInvoke("jianxiong",1)
		return false
	end,
}
-----003xiahoudun
xganglie = sgs.CreateTriggerSkill{
	name = "xganglie",
	events = {sgs.Damaged},
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local from = data:toDamage().from
		local damage=data:toDamage().damage
	for i=1, damage, 1 do
		if (from and from:isAlive() and player:askForSkillInvoke("xganglie")) then
			room:broadcastSkillInvoke("ganglie")
			local judge = sgs.JudgeStruct()
			judge.pattern = sgs.QRegExp("(.*):(heart):(.*)")
			judge.good = false
			judge.reason = "xganglie"
			judge.who = player
			judge.play_animation=true
			room:judge(judge)
			if (judge:isGood()) then
				room:setEmotion(from, "Bad")
				local choice = room:askForChoice(player, "xganglie", "xganglie_discard+xganglie_damage")
				if choice == "xganglie_discard" then
					if from:isKongcheng() then return end
					local n=from:getHandcardNum()
					room:askForDiscard(from, "xganglie", math.min(2,n), math.min(2,n))
				else
					local damage1 = sgs.DamageStruct()
					damage1.damage = 1
					damage1.from = player
					damage1.to = from
					room:damage(damage1)
				end
			end
		end
	end
	return false
end
}
YuanR=sgs.CreateGameStartSkill{
	name = "#YuanR",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		local gname= room:askForGeneral(player,"eDunXH+bgm_xiahoudun")
		local tmp={"bgm_xiahoudun","eDunXH"}
		local skl={"xuehen","ganglie"}
		for i=1,2,1 do
			if gname==tmp[i] then
				if string.find(player:getGeneralName(), "xiahoudun") then
					room:changeHero(player,tmp[i],false,false,false,true)
				elseif string.find(player:getGeneral2Name(), "xiahoudun") then
					room:changeHero(player,tmp[i],false,false,true,true)
				end
				room:broadcastSkillInvoke(skl[i])
				break
			end
		end
		return false
	end,
}
--004zhangliao
GangScard = sgs.CreateSkillCard{
	name = "GangScard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets,to_select,player)
		return #targets==0 and (not to_select:isKongcheng()) and (to_select:objectName() ~= player:objectName())
	end,
	on_use = function(self, room, source, targets)
		local win = source:pindian(targets[1], "GangS", sgs.Sanguosha:getCard(self:getEffectiveId()))
		room:broadcastSkillInvoke("tuxi")
		if win then
			room:setEmotion(source, "Good")
			if targets[1]:hasEquip() then
				local cd = room:askForCardChosen(source, targets[1], "e", "GangS")
				local reason=sgs.CardMoveReason(0x43,source:objectName(),targets[1]:objectName(),"GangS",nil)
				room:throwCard(sgs.Sanguosha:getCard(cd),reason, targets[1])
			end
		else
			room:setEmotion(source, "Bad")
			if not source:isKongcheng() then
				room:askForDiscard(source, "GangS", 1,1)
			end
		end
		return false
	end
}
GangS = sgs.CreateViewAsSkill{
	name = "GangS",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return end
		local card = GangScard:clone()
		card:addSubcard(cards[1])
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#GangScard") and not player:isKongcheng()
	end,
}
YuanWen= sgs.CreateGameStartSkill{
	name = "#YuanWen",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke("#YuanWen") then return false end
		if string.find(player:getGeneralName(), "zhangliao") then
			room:changeHero(player,"eLiaoZ",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "zhangliao") then
			room:changeHero(player,"eLiaoZ",false,false,true,true)
		end
		room:broadcastSkillInvoke("tuxi")
		return false
	end,
}
-----005xuchu
eYiL_card=sgs.CreateSkillCard{
	name="eYiL_card",
	target_fixed=true,
	will_throw=true,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("luoyi")
		room:setPlayerFlag(source, "yl")
	end,
}
eYiL_VAS=sgs.CreateViewAsSkill{
	name="eYiL",
	n=1,
	view_filter = function(self, selected, to_select)
		return to_select:isKindOf("EquipCard")
	end,
	view_as = function(self, cards)
		if #cards~=1 then return end
		local card=eYiL_card:clone()
		card:addSubcard(cards[1])
		return card
	end,
	enabled_at_play=function(self, player)
		return not player:hasFlag("yl") and (not player:isNude())
	end,
}
eYiL = sgs.CreateTriggerSkill{
	name = "eYiL",
	view_as_skill=eYiL_VAS,
	events = {sgs.DrawNCards,sgs.ConfirmDamage, sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event==sgs.DrawNCards then
			local draw_num = data:toInt()
			if not player:askForSkillInvoke(self:objectName()) then return false end
			room:broadcastSkillInvoke("luoyi")
			data:setValue(draw_num-1)
			room:setPlayerFlag(player, "yl")
		end
		if event==sgs.TargetConfirmed then
			local use=data:toCardUse()
			local tos=data:toCardUse().to
			if use.card and player:hasFlag("yl") and (use.card:isKindOf("Slash") or use.card:isKindOf("Duel")) then
				for _, to in sgs.qlist(tos) do
					room:broadcastSkillInvoke("luoyi")
					to:setMark("qinggang", 1)
				end
			end
		elseif event==sgs.ConfirmDamage then
			local damage = data:toDamage()
			if (not damage.card) then return false end
			if player~=nil and player:hasFlag("yl") and (damage.card:isKindOf("Slash") or damage.card:isKindOf("Duel")) then
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		end
		return false
	end
}
KangZ=sgs.CreateGameStartSkill{
	name = "#KangZ",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "xuchu") then
			room:changeHero(player,"eChuX",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "xuchu") then
			room:changeHero(player,"eChuX",false,false,true,true)
		end
		room:broadcastSkillInvoke("luoyi",2)
		return false
	end,
}
------008liubei
DeX=sgs.CreateGameStartSkill{
	name = "#DeX",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "liubei") then
			room:changeHero(player,"bgm_liubei",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "liubei") then
			room:changeHero(player,"bgm_liubei",false,false,true,true)
		end
		room:broadcastSkillInvoke("zhaolie",1)
		return false
	end,
}
------009guanyu
ShengW = sgs.CreateViewAsSkill{
	name = "ShengW",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isRed()
	end,
	view_as = function(self, cards)
		if #cards==1 then
			local card=sgs.Sanguosha:cloneCard("slash", cards[1]:getSuit(), cards[1]:getNumber())
			card:addSubcard(cards[1])
			card:setSkillName("ShengW")
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response=function(self, player, pattern)
		return pattern=="slash"
	end
}
ShengW_dis = sgs.CreateTargetModSkill{
	name = "#ShenW_dis",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("ShengW") and card:getSkillName()=="ShengW" and card:getSuit()==sgs.Card_Heart then
			return 1000
		end
		return 0
	end
}
QiD=sgs.CreateTriggerSkill{
name="QiD",
frequency = sgs.Skill_NotFrequent,
events={sgs.CardResponsed,sgs.TargetConfirmed},
on_trigger=function(self,event,player,data)
	local room=player:getRoom()
	if event==sgs.CardResponsed then
		local resp = data:toResponsed()
		if resp.m_card:isKindOf("Slash") and resp.m_who~=nil
		and not resp.m_who:isNude() and player:askForSkillInvoke("QiD") then
			room:broadcastSkillInvoke("QiD")
			room:showCard(player,room:getDrawPile():at(0))
			local scard=sgs.Sanguosha:getCard(room:getDrawPile():at(0))
			if scard:isNDTrick() then room:throwCard(scard,player) return end
			local card_id = room:askForCardChosen(player, resp.m_who, "he", "QiD")
			local reason=sgs.CardMoveReason(0x43,player:objectName(),resp.m_who:objectName(),"QiD",nil)
			room:throwCard(sgs.Sanguosha:getCard(card_id),reason,resp.m_who)
		end
	else
		local use=data:toCardUse()
		if use.from:hasSkill("QiD") and use.card:isKindOf("Slash") then
			for _,p in sgs.qlist(use.to) do
				if not p:isNude() and player:askForSkillInvoke("QiD") then
					room:broadcastSkillInvoke("QiD")
					room:showCard(player,room:getDrawPile():at(0))
					local scard=sgs.Sanguosha:getCard(room:getDrawPile():at(0))
					if scard:isNDTrick() then room:throwCard(scard,player) return end
					local card_id = room:askForCardChosen(player, p, "he", "QiD")
					local reason=sgs.CardMoveReason(0x43,player:objectName(),p:objectName(),"QiD",nil)
					room:throwCard(sgs.Sanguosha:getCard(card_id), reason ,p)
				end
			end
		end
	end
	return false
end
}
spQiD = sgs.CreateDistanceSkill{
	name = "spQiD",
	correct_func=function(self,from,to)
		if from:hasSkill("spQiD") and from:getWeapon() then
			return -1
		elseif to:hasSkill("spQiD") and to:getArmor() then
			return 1
		end
	end,
}
ChangY=sgs.CreateGameStartSkill{
	name = "#ChangY",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		local glist="eYuG+espYuG"
		if player:hasSkill("#ChangY") and player:hasSkill("paoxiao") then
			local log=sgs.LogMessage()
			log.type ="#ban_gy"
			room:sendLog(log)
			glist="espYuG"
		end
		if not player:askForSkillInvoke("#ChangY") then return false end
		local gname= room:askForGeneral(player,glist)
		local kd={"shu","wei"}
		local cytmp={"eYuG","espYuG"}
		local skiv={"wusheng","danji"}
		for i=1,2,1 do
			if cytmp[i]==gname then
				if string.find(player:getGeneralName(), "guanyu") then
					room:changeHero(player,cytmp[i],false,false,false,true)
					room:setPlayerProperty(player,"kingdom",sgs.QVariant(kd[i]))
				elseif string.find(player:getGeneral2Name(), "guanyu") then
					room:changeHero(player,cytmp[i],false,false,true,true)
				end
				room:broadcastSkillInvoke(skiv[i])
				break
			end
		end
		return false
	end,
}
-----010zhangfei
XiaoP = sgs.CreateTargetModSkill{
	name = "XiaoP",
	pattern = "Analeptic,Slash",
	residue_func = function(self, player)
		if player:hasSkill(self:objectName()) then
			return 999
		end
	end,
}

DeY=sgs.CreateGameStartSkill{
	name = "#DeY",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		local glist="eFeiZ+bgm_zhangfei"
		if player:hasSkill("#DeY") and player:hasSkill("wusheng") then
			local log=sgs.LogMessage()
			log.type ="#ban_zf"
			room:sendLog(log)
			glist="eFeiZ"
		end
		if not player:askForSkillInvoke(self:objectName()) then return false end
		local gname= room:askForGeneral(player,glist)
		local dytmp={"bgm_zhangfei","eFeiZ"}
		for i=1,2,1 do
			if dytmp[i]==gname then
				if string.find(player:getGeneralName(), "zhangfei") then
					room:changeHero(player,dytmp[i],false,false,false,true)
				elseif string.find(player:getGeneral2Name(), "zhangfei") then
					room:changeHero(player,dytmp[i],false,false,true,true)
				end
				room:broadcastSkillInvoke("paoxiao")
				break
			end
		end
		return false
	end,
}
-------012zhaoyun
hltmp={}
DanL = sgs.CreateViewAsSkill{
	name = "DanL",
	n = 1,
	view_filter = function(self, selected, to_select)
		if hltmp[1]=="slash" then return to_select:isKindOf("Jink") or to_select:getSuit()==sgs.Card_Diamond
		else return to_select:isKindOf("Slash") or to_select:getSuit()==sgs.Card_Club end
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return end
		if hltmp[1]=="slash" then hltmp[1]="FireSlash" end
		local cd=sgs.Sanguosha:cloneCard(hltmp[1],cards[1]:getSuit(),cards[1]:getNumber())
		cd:addSubcard(cards[1])
		cd:setSkillName("DanL")
		return cd
	end,
	enabled_at_play=function(self, player, pattern)
		hltmp[1]="slash"
		return sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response=function(self, player, pattern)
		if pattern=="slash" or pattern=="jink" then
			hltmp[1]=pattern
			return true
		end
	end
}
ZhenC = sgs.CreateTriggerSkill{
  name = "ZhenC",
  events = {sgs.TargetConfirmed, sgs.CardResponsed},
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
	if event == sgs.CardResponsed then
		local resp=data:toResponsed()
		if resp.m_card:getSkillName() == "DanL" and resp.m_who~=nil and (not resp.m_who:isKongcheng()) and player:askForSkillInvoke("ZhenC") then
			room:broadcastSkillInvoke("chongzhen")
			local card_id = room:askForCardChosen(player, resp.m_who, "h", "ZhenC")
			local reason=sgs.CardMoveReason(0x43,player:objectName(),resp.m_who:objectName(),"ZhenC",nil)
			room:throwCard(sgs.Sanguosha:getCard(card_id),reason,resp.m_who)
		end
	else
		local use = data:toCardUse()
		if use.from:objectName()==player:objectName() and use.card:getSkillName() == "DanL" then
			for _,p in sgs.qlist(use.to) do
				if p:isKongcheng() or not player:askForSkillInvoke("ZhenC") then return end
				room:broadcastSkillInvoke("chongzhen")
				local card_id = room:askForCardChosen(player, p, "h", "ZhenC")
				local reason=sgs.CardMoveReason(0x43,player:objectName(),p:objectName(),"ZhenC",nil)
				room:throwCard(sgs.Sanguosha:getCard(card_id),reason,p)
			end
		end
	end
	return false
 end
}
LongZ=sgs.CreateGameStartSkill{
	name = "#LongZ",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		local gname= room:askForGeneral(player,"eYunZ+bgm_zhaoyun")
		local dytmp={"bgm_zhaoyun","eYunZ"}
		local kd={"qun","shu"}
		for i=1,2,1 do
			if dytmp[i]==gname then
				if string.find(player:getGeneralName(), "zhaoyun") then
					room:changeHero(player,dytmp[i],false,false,false,true)
					room:setPlayerProperty(player,"kingdom",sgs.QVariant(kd[i]))
				elseif string.find(player:getGeneral2Name(), "zhaoyun") then
					room:changeHero(player,dytmp[i],false,false,true,true)
				end
				room:broadcastSkillInvoke("longdan")
				break
			end
		end
		return false
	end,
}
-------013machao
QiT = sgs.CreateTriggerSkill{
name = "QiT",
frequency = sgs.Skill_Frequency,
events = {sgs.SlashMissed},
on_trigger = function(self, event, player, data)
	local room = player:getRoom()
    if player:askForSkillInvoke(self:objectName()) then
		room:broadcastSkillInvoke("tieji")
		local judge = sgs.JudgeStruct()
		judge.pattern = sgs.QRegExp("(.*):(spade):(.*)")
		judge.good = false
		judge.reason = "QiT"
		judge.who = player
		judge.play_animation=true
		room:judge(judge)
		if (judge:isGood()) then
			local effect = data:toSlashEffect()
			room:slashResult(effect, nil)
			return true
		end
	end
	return false
end
}
QiM=sgs.CreateGameStartSkill{
	name = "#QiM",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "machao") then
			room:changeHero(player,"eChaoM",false,false,false,false)
			room:setPlayerProperty(player,"kingdom",sgs.QVariant("shu"))
        elseif string.find(player:getGeneral2Name(), "machao") then
			room:changeHero(player,"eChaoM",false,false,true,false)
		end
		room:broadcastSkillInvoke("tieji")
		return false
	end,
}
-----016ganning
BaX=sgs.CreateGameStartSkill{
	name = "#BaX",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "ganning") then
			room:changeHero(player,"bgm_ganning",false,false,false,true)
			room:setPlayerProperty(player,"kingdom",sgs.QVariant("qun"))
		elseif string.find(player:getGeneral2Name(), "ganning") then
			room:changeHero(player,"bgm_ganning",false,false,true,true)
		end
		room:broadcastSkillInvoke("yinling",2)
		return false
	end,
}
------017lvmeng
MingZ=sgs.CreateGameStartSkill{
	name = "#MingZ",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		local log=sgs.LogMessage()
		if player:hasSkill("#MingZ") and player:hasSkill("shuangxiong") then
			log.type ="#ban_mz"
			room:sendLog(log)
			return false
		end
		if not player:askForSkillInvoke(self:objectName()) then return false end
		room:broadcastSkillInvoke("tanhu",1)
		if string.find(player:getGeneralName(), "lvmeng") then
			room:changeHero(player,"bgm_lvmeng",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "lvmeng") then
			room:changeHero(player,"bgm_lvmeng",false,false,true,true)
		end
		return false
	end,
}
------019zhouyu
JianFcard=sgs.CreateSkillCard{
name="JianFcard",
target_fixed=false,
will_throw=false,
filter=function(self,targets,to_select)
	if #targets>0 then return false end
	return not to_select:hasSkill("JianF")
end,
on_effect=function(self,effect)
	local from=effect.from
	local to=effect.to
	local room=from:getRoom()

	room:broadcastSkillInvoke("fanjian")
	if not from:hasSkill("JianF") then return false end
	local card_id=self:getEffectiveId()
	local card=sgs.Sanguosha:getCard(card_id)
	local suit=room:askForSuit(to, "JianFcard")

	local log=sgs.LogMessage()
    log.type = "#ChooseSuit"
    log.from = to
    log.arg = sgs.Card_Suit2String(suit)
    room:sendLog(log)

	if card:getSuit() ~= suit then
		local damage=sgs.DamageStruct()
		damage.card = nil
		damage.from = from
		damage.to = to
        room:damage(damage)
	end
	room:getThread():delay()
	to:obtainCard(card)
	room:showCard(to, card_id)
end
}
JianF = sgs.CreateViewAsSkill{
	name = "JianF",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards~=1 then return end
		local card=JianFcard:clone()
		card:addSubcard(cards[1])
		card:setSkillName(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#JianFcard") and not player:isKongcheng()
	end,
}
YYMark=sgs.CreateGameStartSkill{
name = "#YYMark",
on_gamestart = function(self, player)
	local room=player:getRoom()
	if player:hasSkill("YanY") and player:getMark("@flame")<1 then
		player:gainMark("@flame",3)
	end
end,
}
YanYcd=sgs.CreateSkillCard{
name="YanYcd",
target_fixed=false,
will_throw=true,
filter=function(self,targets,to_select)
	return not to_select:hasSkill("JianF") and #targets==0
end,
on_effect=function(self,effect)
	local room=effect.from:getRoom()
	room:broadcastSkillInvoke("yeyan")
	effect.from:loseMark("@flame",1)
	local damage=sgs.DamageStruct()
	damage.card = nil
	damage.from = effect.from
	damage.to = effect.to
	damage.nature = sgs.DamageStruct_Fire
    room:damage(damage)
	room:loseHp(effect.from,1)
end
}
YanY = sgs.CreateViewAsSkill{
	name = "YanY",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped() and to_select:isRed() and to_select:isKindOf("TrickCard")
	end,
	view_as = function(self, cards)
		if #cards~=1 then return end
		local card=YanYcd:clone()
		card:addSubcard(cards[1])
		card:setSkillName("YanY")
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng() and player:getMark("@flame")>0
	end,
}
JinG=sgs.CreateGameStartSkill{
	name = "#JinG",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "zhouyu") then
			room:changeHero(player,"eYuZ",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "zhouyu") then
			room:changeHero(player,"eYuZ",false,false,true,true)
		end
		room:broadcastSkillInvoke("yingzi",1)
		return false
	end,
}
-----------020daqiao
MiJ=sgs.CreateGameStartSkill{
	name = "#MiJ",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "daqiao") then
			room:changeHero(player,"bgm_daqiao",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "daqiao") then
			room:changeHero(player,"bgm_daqiao",false,false,true,true)
		end
		room:broadcastSkillInvoke("anxian",1)
		return false
	end,
}
------021 luxun
YiL=sgs.CreateGameStartSkill{
	name = "#YiL",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "luxun") then
			room:changeHero(player,"heg_luxun",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "luxun") then
			room:changeHero(player,"heg_luxun",false,false,true,true)
		end
		room:broadcastSkillInvoke("lianying")
		return false
	end,
}
----024 lvbu
BaoK = sgs.CreateTriggerSkill{
  name = "#BaoK",
  frequency = sgs.Skill_Compulsory;
  events = {sgs.Damage,sgs.Damaged},
  on_trigger = function(self, event, player, data)
		local damage=data:toDamage()
		player:gainMark("@wrath",damage.damage)
		player:getRoom():broadcastSkillInvoke("kuangbao")
		return false
	end,
}
QianWcd=sgs.CreateSkillCard{
name="QianWcd",
target_fixed=false,
will_throw=false,
filter=function(self,targets,to_select,player)
	return #targets==0 and to_select:objectName()~=player:objectName() and not(to_select:hasSkill("Kongcheng") and to_select:isKongcheng())
end,
on_effect=function(self,effect)
	local from=effect.from
	local to=effect.to
	local room=from:getRoom()
	from:loseMark("@wrath",2)
	local duel=sgs.Sanguosha:cloneCard("duel",sgs.Card_NoSuit,0)
	duel:setSkillName("QianW")
	local use=sgs.CardUseStruct()
	use.card=duel
	use.from=from
	use.to:append(to)
	room:useCard(use,false)
end
}
QianW = sgs.CreateViewAsSkill{
	name = "QianW",
	n = 0,
	view_as = function(self, cards)
		if #cards==0 then
			local card=QianWcd:clone()
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#QianWcd") and player:getMark("@wrath")>=2
	end,
}
XianF=sgs.CreateGameStartSkill{
	name = "#XianF",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "lvbu") then
			room:changeHero(player,"eBuL",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "lvbu") then
			room:changeHero(player,"eBuL",false,false,true,true)
		end
		room:broadcastSkillInvoke("wushuang")
	end,
}
------025diaochan
MoonS=sgs.CreateGameStartSkill{
	name = "#MoonS",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		local log=sgs.LogMessage()
		local ban={"jiushi", "luanwu", "dangxian","jushou","ShouJ","luanji","fuhun"}
		for _,s in ipairs(ban) do
			if player:hasSkill("#MoonS") and player:hasSkill(s) then
				log.type ="#WZhiC"
				room:sendLog(log)
				return false
			end
		end
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "diaochan") then
			room:changeHero(player,"bgm_diaochan",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "diaochan") then
			room:changeHero(player,"bgm_diaochan",false,false,true,true)
		end
		room:broadcastSkillInvoke("biyue",1)
		return false
	end,
}
-----027 caoren
XiaoZ=sgs.CreateGameStartSkill{
	name = "#XiaoZ",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		room:broadcastSkillInvoke("kuiwei")
		if string.find(player:getGeneralName(), "caoren") then
			room:changeHero(player,"bgm_caoren",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "caoren") then
			room:changeHero(player,"bgm_caoren",false,false,true,true)
		end
		return false
	end,
}
---029 weiyan
XKMark=sgs.CreateGameStartSkill{
	name = "#XKMark",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if player:hasSkill("#XKMark") and player:getMark("@eKuang")<1 then
			player:gainMark("@eKuang",1)
		end
		return false
	end,
}
XinKuang = sgs.CreateTriggerSkill{
	name = "XinKuang",
	frequency = sgs.Skill_Limited,
	events = {sgs.Dying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying=data:toDying()
		if dying.who:hasSkill("XinKuang") and dying.who:getMark("@eKuang")>0 then
			local targets=sgs.SPlayerList()
			for _,p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getKingdom()==player:getKingdom() then
					targets:append(p)
				end
			end
			if not targets:isEmpty() and player:askForSkillInvoke(self:objectName()) then
				local target=room:askForPlayerChosen(player,targets,"XinKuang")
				local damage = data:toDamage()
				damage.from=player
				damage.to=target
				room:setFixedDistance(player,target,1)
				room:damage(damage)
				room:setFixedDistance(player,target,-1)
				player:loseMark("@eKuang")
			end
		end
		return false
	end
}
ChangW=sgs.CreateGameStartSkill{
	name = "#ChangW",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		room:broadcastSkillInvoke("kuanggu")
		if string.find(player:getGeneralName(), "weiyan") then
			room:changeHero(player,"eYanW",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "weiyan") then
			room:changeHero(player,"eYanW",false,false,true,true)
		end
		return false
	end,
}
-------031zhoutai
ShiX = sgs.CreateTriggerSkill{
	name = "ShiX",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getHp()<0 and player:hasSkill(self:objectName()) then
			room:loseHp(player,1)
			room:broadcastSkillInvoke("buqu")
		end
		return false
	end
}
----36pangtong
JiM = sgs.CreateTriggerSkill{
	name = "JiM",
	frequency = sgs.Skill_Compulsory,
	events = sgs.CardsMoveOneTime,
	on_trigger = function(self, event, player, data)
		local room=player:getRoom()
		local move=data:toMoveOneTime()
		local reason=move.reason.m_reason
		if move.from:objectName() ~= player:objectName() then return false end
		for i=0, move.card_ids:length()-1, 1 do
			if  move.from_places:at(i) == sgs.Player_PlaceHand
			or move.from_places:at(i) == sgs.Player_PlaceSpecial then
				if reason~=sgs.CardMoveReason_S_REASON_USE then return false end
				local cd_t=sgs.Sanguosha:getCard(move.card_ids:at(i))
				if not (cd_t:isKindOf("TrickCard") and cd_t:isBlack()) then return false end
				player:drawCards(1)
			end
		end
	end
}
PNMark=sgs.CreateGameStartSkill{
	name = "#PNMark",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if player:hasSkill("#PNMark") and player:getMark("@nirvana")<1 then
			player:gainMark("@nirvana",1)
		end
		return false
	end,
}
YuanSHI=sgs.CreateGameStartSkill{
	name = "#YuanSHI",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "pangtong") then
			room:changeHero(player,"eTongP",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "pangtong") then
			room:changeHero(player,"eTongP",false,false,true,true)
		end
		room:broadcastSkillInvoke("niepan")
		return false
	end,
}
--048dongzhuo
HuaiB = sgs.CreateTriggerSkill{
	name = "HuaiB",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local room = player:getRoom()
			local x = player:getHp()
			local m = {}
			for _,p in sgs.qlist(room:getOtherPlayers(player)) do
				table.insert(m,p:getHp())
			end
			if x < math.max(unpack(m)) then m = nil return false end
			local choice = room:askForChoice(player, self:objectName(), "losehp+losemaxhp")
			if choice == "losemaxhp" then
				room:loseMaxHp(player)
				room:broadcastSkillInvoke("benghuai")
			else
				room:loseHp(player)
				room:broadcastSkillInvoke("benghuai")
			end
			return false
		end
	end
}
------068 gongsunzan
GuiB=sgs.CreateGameStartSkill{
	name = "#GuiB",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		room:broadcastSkillInvoke("yicong")
		if string.find(player:getGeneralName(), "gongsunzan") then
			room:changeHero(player,"neo_gongsunzan",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "gongsunzan") then
			room:changeHero(player,"neo_gongsunzan",false,false,true,true)
		end
		return false
	end,
}
---089yujin
eYishoucd = sgs.CreateSkillCard{
	name = "eYishoucd",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets,to_select,player)
		return #targets==0 and to_select:objectName()~=player:objectName() and to_select:getMark("@eyi")==0
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("yizhong")
		targets[1]:gainMark("@eyi",1)
	end
}
eYishouvs = sgs.CreateViewAsSkill{
	name = "eYishou",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return end
		local card = eYishoucd:clone()
		card:addSubcard(cards[1])
		card:setSkillName("eYishou")
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#eYishoucd")
	end,
}
eYishou=sgs.CreateTriggerSkill{
	name = "eYishou",
	events = {sgs.Death,sgs.EventLoseSkill,sgs.EventPhaseStart, sgs.TargetConfirming},
	view_as_skill=eYishouvs,
	can_trigger=function(self,target)
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event==sgs.EventLoseSkill and player:hasSkill("eYishou") 
		or event==sgs.Death and data:toDeath().who:hasSkill(self:objectName()) then
			for _,p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getMark("@eyi")>0 then
					p:loseAllMarks("@eyi")
				end
			end
		elseif event==sgs.EventPhaseStart then
			if player:hasSkill("eYishou") and player:getPhase()==sgs.Player_Start then
				for _,p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:getMark("@eyi")>0 then
						p:loseMark("@eyi")
					end
				end
			end
		end
		if event==sgs.TargetConfirming then
			local splayer=room:findPlayerBySkillName("eYishou")
			local use=data:toCardUse()
			if use.card and use.card:isKindOf("Slash") and splayer:objectName()~=player:objectName() then
				for _,p in sgs.qlist(room:getOtherPlayers(splayer)) do
					if p:getMark("@eyi")>0 and use.to:contains(p) then
						local log= sgs.LogMessage()
						log.type = "#TriggerSkill"
						log.from = player
						log.arg  = self:objectName()
						room:sendLog(log)
						if not sgs.Sanguosha:isProhibited(use.from,splayer,use.card) then
							use.to:append(splayer)
						else
							local log= sgs.LogMessage()
							log.type = "#phb"
							log.from = splayer
							room:sendLog(log)
						end
						use.to:removeOne(p)
						data:setValue(use)
						return true
					end
				end
			end
		end
		return false
	end
}
eWenze=sgs.CreateGameStartSkill{
	name = "#eWenze",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "yujin") then
			room:changeHero(player,"eJinY",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "yujin") then
			room:changeHero(player,"eJinY",false,false,true,true)
		end
		room:broadcastSkillInvoke("yizhong")
		return false
	end,
}
--095 huaxiong
YongA=sgs.CreateTriggerSkill{
	name = "YongA",
	events = {sgs.Damaged},
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged and player:hasSkill("YongA") then
			local damage=data:toDamage()
			if not damage.from or damage.from:isNude() then return end
			if not player:askForSkillInvoke(self:objectName()) then return end

			local cd=room:askForCard(damage.from,"BasicCard","@eYongA:"..player:objectName(),data,sgs.Card_MethodNone)
			if not cd then
				local card_id=room:askForCardChosen(player, damage.from, "he", "YongA")
				local reason=sgs.CardMoveReason(0x43,player:objectName(),damage.from:objectName(),"YongA",nil)
				room:throwCard(sgs.Sanguosha:getCard(card_id), reason ,damage.from)
			else
				room:showCard(damage.from, cd:getEffectiveId())
			end
		end
	end
}
XiongY=sgs.CreateGameStartSkill{
	name = "#XiongY",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "huaxiong") then
			room:changeHero(player,"eXiongH",false,false,false,true)
		elseif string.find(player:getGeneral2Name(), "huaxiong") then
			room:changeHero(player,"eXiongH",false,false,true,true)
		end
		room:broadcastSkillInvoke("shiyong")
		return false
	end,
}
--096liaohua
LFMark=sgs.CreateGameStartSkill{
name = "#LFMark",
on_gamestart = function(self, player)
	local room=player:getRoom()
	if player:hasSkill("#LFMark") and player:getMark("@laoji")<1 then
		player:gainMark("@laoji",1)
	end
end,
}
SangC = sgs.CreateTriggerSkill{
name = "SangC",
frequency=sgs.Skill_Compulsory,
events={sgs.EventPhaseStart},
on_trigger=function(self,event,player,data)
	local room=player:getRoom()
	if player:getPhase() == sgs.Player_Play then
		if player:getHandcardNum()>4 then
			room:askForDiscard(player,"SangC", 1,1)
		end
	end
end
}
--xuanwu
DeW=sgs.CreateTriggerSkill{
name="DeW",
frequency=sgs.Skill_Frequent,
priority=2,
events={sgs.SlashMissed},
on_trigger=function(self,event,xuanwu,data)
	local room=xuanwu:getRoom()
	if event==sgs.SlashMissed then
		if not xuanwu:askForSkillInvoke(self:objectName()) then return false end
		room:broadcastSkillInvoke("DeW")
		local choice = room:askForChoice(xuanwu,self:objectName(),"mp+qz")
		if choice == "qz" then
			local targets=sgs.SPlayerList()
			for _,p in sgs.qlist(room:getOtherPlayers(xuanwu)) do
				if not p:isAllNude() then
					targets:append(p)
				end
			end
			if targets:isEmpty() then return end
			local target=room:askForPlayerChosen(xuanwu,targets,self:objectName())
			local card_id=room:askForCardChosen(xuanwu, target, "hej", "DeW")
			local reason=sgs.CardMoveReason(0x43,xuanwu:objectName(),target:objectName(),"DeW",nil)
			room:throwCard(sgs.Sanguosha:getCard(card_id), reason ,target)
		elseif  choice == "mp" then
			xuanwu:drawCards(1)
		end
	end
	return false
end
}
stophit=sgs.CreateTriggerSkill{
	name="stophit",
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function()
		return true
	end,
	events={sgs.TargetConfirming, sgs.CardEffected, sgs.CardFinished},
	on_trigger=function(self,event,player,data)
		local room=player:getRoom()
		if player:hasSkill(self:objectName()) and event~=sgs.CardFinished then
			if event==sgs.TargetConfirming then
				local use=data:toCardUse()
				if use.from~=nil and use.from:objectName()~=player:objectName() and player:canSlash(use.from)
				and (use.card:isKindOf("Slash") or use.card:isKindOf("Duel")) then
					local slash=room:askForUseSlashTo(player, use.from, "#stophit_effect")
					if slash then
						room:broadcastSkillInvoke("stophit")
						room:setPlayerFlag(player, "tsh")
					end
				end
			elseif event==sgs.CardEffected then
				local effect=data:toCardEffect()
				if (effect.card:isKindOf("Slash") or effect.card:isKindOf("Duel")) and player:hasFlag("tsh") then
					room:setPlayerFlag(player, "-tsh")
					return true
				end
			end
		elseif event==sgs.CardFinished then
			local use = data:toCardUse()
			if (use.card:isKindOf("Slash") or use.card:isKindOf("Duel")) and player:hasFlag("tsh") then
				room:setPlayerFlag(player, "-tsh")
			end
		end
		return false
	end
}
YuanS=sgs.CreateTriggerSkill{
name="#YuanS",
frequency = sgs.Skill_Compulsory,
events={sgs.TurnStart},
priority=2,
on_trigger=function(self,event,xuanwu,data)
	local room=xuanwu:getRoom()
	if xuanwu:getHp()==1 then
		local judge = sgs.JudgeStruct()
		judge.pattern = sgs.QRegExp("(Slash):(spade|club):(.*)")
		judge.good = true
		judge.reason = self:objectName()
		judge.who = xuanwu
		room:judge(judge)
		if(judge:isBad()) then
			room:setEmotion(xuanwu,"Bad")
			room:detachSkillFromPlayer(xuanwu,self:objectName())
		elseif judge:isGood() then
			room:broadcastInvoke("animate", "lightbox:$YuanS:3000")
			if string.find(player:getGeneralName(), "xuanwu") then
				room:changeHero(xuanwu,"yuanwu",false,false,false,true)
			elseif string.find(player:getGeneral2Name(), "xuanwu") then
				room:changeHero(xuanwu,"yuanwu",false,false,true,true)
			end
		end
		return false
	end
end,
}
ehuashen=sgs.CreateGameStartSkill{
	name = "#ehuashen",
	on_gamestart = function(self, player)
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName()) then return false end
		if string.find(player:getGeneralName(), "xuanwu") then
			room:changeHero(player,"eluoshen",false,false,false,true)
			room:setPlayerProperty(player,"kingdom",sgs.QVariant("wei"))
		elseif string.find(player:getGeneral2Name(), "xuanwu") then
			room:changeHero(player,"eluoshen",false,false,true,true)
		end
		return false
	end,
}
----yuanwu
XinY=sgs.CreateTriggerSkill{
	name="XinY",
	priority=2,
	frequency=sgs.Skill_Compulsory,
	events={sgs.CardUsed, sgs.CardResponsed, sgs.SlashMissed},
	on_trigger=function(self,event,yuanwu,data)
		local room=yuanwu:getRoom()
		if event==sgs.SlashMissed then
			local target=data:toSlashEffect().to
			if target:isAllNude() then return false end
			room:broadcastSkillInvoke("DeW")
			local card_id = room:askForCardChosen(yuanwu, target, "jhe", "XinY")
			if(room:getCardPlace(card_id) == sgs.Player_PlaceHand) then
				room:moveCardTo(sgs.Sanguosha:getCard(card_id), yuanwu, sgs.Player_PlaceHand, false)
			else
				room:obtainCard(yuanwu, card_id)
			end
		end
		if event==sgs.CardUsed then
			local card=data:toCardUse().card
			if card:isKindOf("BasicCard") or card:isKindOf("duel") then
				yuanwu:drawCards(1)
			end
		elseif event==sgs.CardResponsed then
			local card=data:toResponsed().m_card
			if card:isKindOf("BasicCard") then
				yuanwu:drawCards(1)
			end
		end
		return false
	end
}
XinYKeep=sgs.CreateMaxCardsSkill{
name = "#XinYKeep",
extra_func=function(self,target)
	if target:hasSkill("#XinYKeep") then
		return 2
	else
		return 0
	end
end
}
ShaY=sgs.CreateTriggerSkill{
name="ShaY",
frequency = sgs.Skill_Frequent,
events={sgs.TargetConfirming, sgs.CardEffected, sgs.PostCardEffected},
on_trigger=function(self,event,player,data)
	local room=player:getRoom()
	local card={"Slash", "Duel","FireAttack","ArcheryAttack","SavageAssault"}
	if event==sgs.TargetConfirming then
		local use=data:toCardUse()
		for _,cd in ipairs(card) do
			if use.card:isKindOf(cd) and not (use.from:hasSkill("Kongcheng") and use.from:isKongcheng()) then
				room:setFixedDistance(player, use.from, 1)
				local slash=room:askForUseSlashTo(player, use.from, "#ShaY_effect")
				if slash then
					room:broadcastSkillInvoke("stophit")
					room:setPlayerFlag(player, "tsh")
				end
				room:setFixedDistance(player, use.from, -1)
			end
		end
	elseif event==sgs.CardEffected then
		local effect=data:toCardEffect()
		for _,cd in ipairs(card) do
			if effect.card:isKindOf(cd) and player:hasFlag("tsh") then
				room:setPlayerFlag(player, "-tsh")
				return true
			end
		end
	elseif event==sgs.PostCardEffected then
		local effect=data:toCardEffect()
		for _,cd in ipairs(card) do
			if effect.card:isKindOf(cd) and player:hasFlag("tsh") then
				room:setPlayerFlag(player, "-tsh")
			end
		end
	end
	return false
end
}
Nonstyle=sgs.CreateViewAsSkill{
	name="Nonstyle",
	n=1,
	view_filter=function(self, selected, to_select)
		return to_select:isKindOf("BasicCard")
	end,
	view_as = function(self, cards)
		if #cards==1 then
			local card = sgs.Sanguosha:cloneCard("slash", cards[1]:getSuit(), cards[1]:getNumber())
			card:addSubcard(cards[1])
			card:setSkillName("Nonstyle")
			return card
		end
	end,
	enabled_at_play=function(self, player, pattern)
		return sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response=function(self, player, pattern)
		return pattern=="slash"
	end
}

tfskill={DeM,YuanR,YuanWen,KangZ,XiaoZ,eWenze,
		DeX,ChangY,DeY,LongZ,QiM,YuanSHI,ChangW,
		BaX,MingZ,JinG,MiJ,YiL,
		XianF,MoonS,XiongY,GuiB}
for _,skl in ipairs(tfskill) do
	tf:addSkill(skl)
end

GenList={"caocao","xiahoudun","zhangliao","xuchu","caoren","yujin",
		"liubei","guanyu","zhangfei","zhaoyun","machao","pangtong","weiyan",
		"ganning","lvmeng","zhouyu","daqiao","luxun",
		"lvbu","diaochan","huaxiong","gongsunzan"}
Gtfskill={"#DeM","#YuanR","#YuanWen","#KangZ","#XiaoZ","#eWenze",
		"#DeX","#ChangY","#DeY","#LongZ","#QiM","#YuanSHI","#ChangW",
		"#BaX","#MingZ","#JinG","#MiJ","#YiL",
		"#XianF","#MoonS","#XiongY","#GuiB"}
for i=1, #GenList, 1 do
	general=sgs.Sanguosha:getGeneral(GenList[i])
	if general~=nil then general:addSkill(Gtfskill[i]) end
end

ecaocao:addSkill(eXiongJ) ecaocao:addSkill("hujia") ecaocao:addSkill(YingJ) ecaocao:addSkill(YJMark)
eDunXH:addSkill(xganglie)
eLiaoZ:addSkill("tuxi") eLiaoZ:addSkill(GangS)
eChuX:addSkill(eYiL)
eYuG:addSkill(ShengW) eYuG:addSkill(ShengW_dis) eYuG:addSkill(QiD) espYuG:addSkill("ShengW") espYuG:addSkill(spQiD)
eFeiZ:addSkill(XiaoP)
eYunZ:addSkill(DanL) eYunZ:addSkill(ZhenC)
eChaoM:addSkill(QiT) eChaoM:addSkill("mashu")
eYuZ:addSkill("yingzi") eYuZ:addSkill(JianF) eYuZ:addSkill(YYMark)  eYuZ:addSkill(YanY)
eYanW:addSkill("kuanggu") eYanW:addSkill(XKMark) eYanW:addSkill(XinKuang)
eBuL:addSkill(BaoK) eBuL:addSkill(QianW) eBuL:addSkill("wushuang")
eTaiZ:addSkill("buqu") eTaiZ:addSkill("#buqu-remove") eTaiZ:addSkill(ShiX)
eTongP:addSkill("lianhuan") eTongP:addSkill(PNMark) eTongP:addSkill("niepan") eTongP:addSkill(JiM)
eZhuoD:addSkill("jiuchi") eZhuoD:addSkill("roulin") eZhuoD:addSkill("baonue") eZhuoD:addSkill(HuaiB)
eJinY:addSkill(eYishou) eJinY:addSkill("yizhong")
eXiongH:addSkill(YongA) eXiongH:addSkill("shiyong")
eHuaL:addSkill("dangxian") eHuaL:addSkill("fuli") eHuaL:addSkill(LFMark) eHuaL:addSkill(SangC)
xuanwu:addSkill(DeW) xuanwu:addSkill(stophit) xuanwu:addSkill(YuanS) xuanwu:addSkill(ehuashen)
yuanwu:addSkill(XinY) yuanwu:addSkill(XinYKeep) yuanwu:addSkill(ShaY) yuanwu:addSkill(Nonstyle)

sgs.LoadTranslationTable{
--caocao
	["ecaocao"] = "E·曹操",["#ecaocao"] = "魏武帝",["designer:ecaocao"] = "Emryx",["~ecaocao"] = "霸业未成，未成啊......",
	["eXiongJ"] = "奸雄",["YingJ"] = "绝影",["#DeM"]="曹孟德",
    [":eXiongJ"] = "每当你受到一次伤害后，你可以令一名角色（伤害来源除外）获得对你造成伤害的牌",
    [":YingJ"] = "<b>锁定技，</b>当你的体力值小于等于2时，其他角色计算与你的距离+1。",
	["@ying"]="影",
--xiahoudun
	["eDunXH"]="E·夏侯惇", ["#eDunXH"] = "独眼的罗刹", ["designer:eDunXH"] = "Emryx", ["~eDunXH"]="两…两边都看不见啦……",
	["xganglie"]="刚烈", ["#YuanR"]="夏侯元让",
	[":xganglie"]="每当你受到1点伤害后，你可判定，若不为<font color='red'>♥</font>，你须选择：1.令伤害来源弃置2张手牌（不足则全弃）；2.伤害来源受到你对其造成的1点伤害。",
	["xganglie_discard"]="弃置其2张牌", ["xganglie_damage"]="对其造成1点伤害",
--zhangliao
	["eLiaoZ"]="E·张辽", ["#eLiaoZ"] = "前将军", ["designer:eLiaoZ"] = "Emryx",	["~eLiaoZ"]="真没想到",	["GangS"]="谥刚",
	["GangScard"]="谥刚", ["#YuanWen"]="张文远",
	[":GangS"]="出牌阶段，你可与一名其他角色拼点，若赢，你可弃置该角色装备区的一张牌；若没赢，你弃置一张手牌。每阶段一次。",
--xuchu
	["eChuX"]="E·许褚", ["#eChuX"] = "虎痴", ["designer:eChuX"] = "Emryx", ["~eChuX"]="冷，好冷啊。",
	["eYiL"] = "裸衣", ["eYiL_card"] = "裸衣", ["#KangZ"]="许仲康",
    [":eYiL"] = "摸牌阶段，你可以少摸一张牌，或出牌阶段，你可以弃置一张装备牌，若如此做，你使用的【杀】或【决斗】（你为伤害来源时）无视对方防具且造成的伤害+1，直至回合结束。",
--liubei
	["#DeX"]="刘玄德",
--guanyu
	["eYuG"]="E·关羽", ["#eYuG"]="美髯公", ["~eYuG"]="什么？此地名叫麦城？", ["designer:eYuG"] = "Emryx",
	["ShengW"]="武圣", ["QiD"]="单骑", ["#ChangY"]="关云长",
	[":ShengW"]="你可以将一张红色牌当【杀】使用或打出。若如此做，你使用的<font color='red'>♥</font>【杀】无距离限制。",
	["$ShengW1"]="关羽在此，尔等受死！", ["$ShengW2"]="看尔乃插标卖首！", ["WushenSlash"]="武圣杀",
	[":QiD"]="每当你使用或打出一张【杀】时，你可展示牌堆顶的一张牌，若不为非延迟锦囊牌，你弃置对方一张牌；若为非延迟锦囊牌，你弃置之。",
	["$QiD"] = "还不速速领死！",

	["espYuG"]="E·SP关羽", ["#espYuG"]="汗寿亭侯", ["~espYuG"]="什么？此地名叫麦城？", ["designer:espYuG"] = "洛神&Emryx", ["spQiD"]="单骑",
	[":spQiD"]="<b>锁定技，</b>当你装备武器时，你计算与其他角色的距离-1；当你装备防具时，其他角色计算与你的距离+1",
	["#ban_gy"]="<b><font color='yellow'>【E关羽禁组，变身禁止】</font>",
--zhangfei
	["eFeiZ"]="E·张飞", ["#eFeiZ"]="万夫不当", ["~eFeiZ"]="实在是杀不动啦……", ["designer:eFeiZ"] = "Emryx",
	["XiaoP"]="咆哮", ["#DeY"]="张益德",
	[":XiaoP"]="<b>锁定技，</b>你在出牌阶段内使用【杀】或【酒】时无次数限制。",
	["#ban_zf"]="<b><font color='yellow'>【☆SP张飞禁组，变身禁止】</font>",
--zhaoyun
	["eYunZ"]="E·赵云", ["#eYunZ"]="少年将军",["~eYunZ"]="这…就是失败的滋味吗？",["designer:eYunZ"] = "Emryx",
	["ZhenC"]="冲阵", ["DanL"]="龙胆",["#LongZ"]="赵子龙",
	[":ZhenC"] = "每当你发动“龙胆”使用或打出一张手牌时，你可弃置对方一张手牌。",
	[":DanL"]="你可以将一张【杀】或♣当【闪】，一张【闪】或<font color='red'>♦</font>牌当【火杀】使用或打出。",
	["$DanL1"]="能进能退，乃真正法器！", ["$DanL2"]="吾乃常山赵子龙也！",
--machao
	["#QiM"]="孟起→变身 E·马超",["eChaoM"]="E·马超",["#eChaoM"]="一骑当千",["~eChaoM"]="（马蹄声......）",["designer:eChaoM"] = "Emryx",
	["QiT"]="铁骑",
	[":QiT"]="每当你的【杀】被【闪】抵消时，你可进行一次判定，若结果不为黑桃，该【杀】仍造成伤害",
--ganning
	["#BaX"]="甘兴霸",
--lvmeng
	["#MingZ"]="吕子明",
	["#ban_mz"]="<b><font color='yellow'>【☆SP吕蒙禁组，变身禁止】</font>",
--zhouyu
	["eYuZ"]="E·周瑜", ["#eYuZ"]="大都督", ["~eYuZ"]="既生瑜，何生……", ["designer:eYuZ"] = "Emryx",
	["JianF"]="反间", ["JianFcard"]="反间", ["YanY"]="业炎", ["YanYcd"]="业炎", ["#JinG"]="周公瑾",
	[":JianF"]="出牌阶段，你可选择一张手牌，令一名其他角色说出一种花色，若猜错则其受到你对其造成的1点伤害,此后其获得该牌。每阶段限一次。",
	[":YanY"]="<b>限定技，</b>游戏开始时，你获得3枚“业炎”标记；出牌阶段，你可失去1枚“业炎”标记并弃置一张红色锦囊，对一名其他角色造成1点火焰伤害，此后，你失去1点体力。",
--daqiao
	["#MiJ"]="大乔替换",
	["#bandq"]="<b><font color='yellow'>【☆SP大乔禁组，变身禁止】</font>",
--luxun
	["#YiL"]="陆议",
--weiyan
	["eYanW"]="E·魏延",["#eYanW"] = "嗜血的独狼",["designer:eYanW"] = "Emryx",["~eYanW"] = "谁敢杀我！啊……",
	["XinKuang"] = "狂心",["#ChangW"]="魏文长",
	[":XinKuang"]="<b>限定技，</b>当你处于濒死状态时，你可选择一名与你同势力的其他角色，你与其距离为1且对其造成1点伤害。",
--lvbu
	["eBuL"] = "E·吕布",["#eBuL"] = "武的化身",["designer:eBuL"] = "Emryx",["~eBuL"] = "不可能！",
	["QianW"] = "无前",["#XianF"]="吕奉先",["QianWcd"] = "无前",
    [":QianW"] = "每当你造成或受到1点伤害后，你获得1枚“暴怒”标记。出牌阶段，你可弃2枚“暴怒”标记，视为对其他一名角色使用一张【决斗】，每阶段一次。",
--diaochan
	["#MoonS"]="月魂",
	["#WZhiC"]="<b><font color='yellow'>【☆SP貂蝉禁组，变身禁止】</font>",
--caoren
	["#XiaoZ"]="曹子孝",
--zhoutai
	["eTaiZ"]="E·周泰",["#eTaiZ"]="历战之躯",	["designer:eTaiZ"] = "Emryx",["~eTaiZ"] = "已经尽力了……",
	["ShiX"] = "弥留",
	[":ShiX"] = "每当你受到伤害时，若你的当前体力值小于0，你失去1点体力。" ,
--pangtong
	["eTongP"]="E·庞统",["#eTongP"]="凤雏",	["designer:eTongP"] = "Emryx",["~eTongP"] = "落凤坡？此地不利于吾。",
	["JiM"] = "密计",
	[":JiM"] = "<b>锁定技，</b>每当你因使用而失去一张黑色锦囊时，你摸一张牌。",
	["#YuanSHI"]="庞士元",
--yujin
	["eJinY"]="E·于禁",["#eJinY"]="魏武之刚",["designer:eJinY"] = "Emryx",["~eJinY"] = "我……无颜面对丞相了……",
	["eYishouvs"] = "毅守",["eYishoucd"] = "毅守",["eYishou"] = "毅守",
	[":eYishou"] = "出牌阶段，你可弃置一张手牌并指定一名其他角色，每当该角色成为【杀】的目标时，该目标视为你，直到你的下一回合的开始阶段。每阶段一次。",
	["#eWenze"]="于文则",
	["#phb"]="【杀】被%from无效",
	["@eyi"]="毅",
--dongzhuo
	["eZhuoD"]="E·董卓",["#eZhuoD"]="魔王",	["designer:eZhuoD"] = "Emryx",["~eZhuoD"] = "汉室衰落…非我一人之罪……",
	["HuaiB"] = "崩坏",
	[":HuaiB"] = "<b>锁定技，</b>回合结束阶段，若你的体力值是全场最多的（或之一），你须减1点体力或体力上限。" ,
	["losehp"] = "减1点体力",["losemaxhp"] = "减1点体力上限",
--gongsunzan
	["#GuiB"]="公孙伯珪",
--huaxiong
	["#eXiongH"] = "魔将",["eXiongH"] = "E·华雄",["~eXiongH"] = "太自负了么……",["designer:eXiongH"] = "Emryx",
	["YongA"] = "恃傲",
	[":YongA"] = "每当你受到一次伤害后，伤害来源须展示一张基本牌，否则你弃置其一张牌.",
	["#XiongY"]="叶雄",
	["@eYongA"] = "请展示一张 %arg 手牌，否则 %src 弃置你的一张牌",
--liaohua
	["#eHuaL"] = "历尽沧桑",["eHuaL"] = "E·廖化",["~eHuaL"] = "阅尽兴亡，此生无憾矣.",["designer:eHuaL"] = "Emryx",
	["SangC"] = "沧桑",
	[":SangC"] = "<b>锁定技,</b>每当你的出牌阶段开始时,若你的手牌数大于等于5,你须弃置一张手牌.",
--xuan
	["xuanwu"] = "炫武",["#xuanwu"] = "鳳舞九天",["designer:xuanwu"] = "Emryx",
	["DeW"]="武德",
	[":DeW"]="每当你的【杀】被【闪】抵消时，你可选择一项：1.你摸一张牌. 2.你选择一名其他角色，弃置其一张牌（任意区域）.",
	["qz"]="弃置一张牌（任意区域）",
	["mp"]="摸一张牌",
	["stophit"] = "反殺",
	[":stophit"] = "每当你成为【杀】或【决斗】的目标时，你可以向使用该【杀】或【决斗】的角色使用一张【杀】，若如此做，该角色的【杀】或【决斗】对你无效",
	["#stophit_effect"] = "是否发动技能【反殺】？",
	["#YuanS"]="释源",
	["$DeW2"]="哼~",
	["$DeW1"]="哼哼~",
	["$stophit"]="破绽百出！",
	["#ehuashen"]="化身",

	["yuanwu"] = "源武",["#yuanwu"] = "鳳源釋天",["designer:yuanwu"] = "Emryx",
	["$YuanS"] = "鳳炫槃涅 武源釋天",
	["XinY"]="源心",
	[":XinY"]="每当你的【杀】被一名角色的【闪】抵消时，你可获得其一张牌（任意区域）。每当你使用或打出一张基本牌，或使用一张【决斗】时，你摸一张牌。你的手牌上限+2。 ",
	["ShaY"] = "源殺",
	[":ShaY"] = "每当你成为【杀】或伤害锦囊的目标时，你可以向使用该【杀】或伤害锦囊的角色使用一张【杀】（无视距离），若如此做，该角色的【杀】或伤害锦囊对你无效",
	["#ShaY_effect"] = "是否发动技能【源殺】？",
	["Nonstyle"]="无形",
	[":Nonstyle"]="你可以将任意一张基本牌当【杀】使用或打出",
}
