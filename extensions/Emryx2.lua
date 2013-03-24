module("extensions.Emryx2", package.seeall)               --Written By Emryx
extension = sgs.Package("Emryx2")

eluoshen=sgs.General(extension, "eluoshen", "wei", 3, true,true)

eluoshui = sgs.CreateTriggerSkill{
  name = "eluoshui",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from~=nil and player and player:askForSkillInvoke(self:objectName()) then
			--room:broadcastSkillInvoke(self:objectName())
			if not room:askForCard(player,".|.|.|.|black","@eluoshui",data,sgs.Card_MethodDiscard) then return end
			damage.damage=damage.damage-1
			if damage.damage==0 then return true end
			data:setValue(damage)
		end
		return false
	end
}
eaizhen=sgs.CreateTriggerSkill{
	name = "eaizhen",
	frequency = sgs.Skill_NotFrequent,
	priority=2,
	events = {sgs.FinishJudge},
	can_trigger=function(self,target)
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		-- if event==sgs.CardDrawnDone then
			-- if player:hasSkill(self:objectName()) and player:getPhase()==sgs.Player_NotActive and player:askForSkillInvoke(self:objectName()) then
				--room:broadcastSkillInvoke(self:objectName())
				-- local target=room:askForPlayerChosen(player,room:getOtherPlayers(player),self:objectName())
				-- target:drawCards(1)
			-- end
			local judge = data:toJudge()
			local card = judge.card
			if card:isBlack() then
				local splayer=room:findPlayerBySkillName(self:objectName())
				if splayer:getPhase()==sgs.Player_NotActive and splayer:askForSkillInvoke(self:objectName()) then
					--room:broadcastSkillInvoke(self:objectName())
					splayer:drawCards(1)
				end
			end
			return false
	end
}

eluoshen:addSkill(eluoshui)
eluoshen:addSkill(eaizhen)

sgs.LoadTranslationTable{
	["Emryx2"]="双将群",
	["eluoshen"] = "洛神",["#eluoshen"] = "洛水之神",["designer:eluoshen"] = "洛神",
	["eluoshui"] = "洛水",["eaizhen"] = "爱甄",
    [":eluoshui"] = "当你受到一名其他角色造成的伤害时，你可弃置一张黑色牌，令此伤害-1。",
	[":eaizhen"] = "你的回合外，若场上的判定牌为黑色牌，你可摸一张牌。",
	["@eluoshui"]="请弃置一张黑色牌",
}
