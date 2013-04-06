sgs.ai_skill_invoke["HegLuoshen"] = sgs.ai_skill_invoke.luoshen

sgs.ai_skill_invoke["HegJizhi"] = function(self, data)
	return true
end
function sgs.ai_cardneed.jizhi(to, card)
	return card:isNDTrick()
end

sgs.ai_skill_invoke["HegXiaoji"] = function(self, data)
	return true
end
