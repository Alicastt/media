function OnInject_ExperimentalSyringe(food, player, percent)
	local bodyDamage = player:getBodyDamage();
	bodyDamage:setInfected(false);
	bodyDamage:setInfectionMortalityDuration(-1);
	bodyDamage:setInfectionTime(-1);
	bodyDamage:setInfectionLevel(0);
	local bodyParts = bodyDamage:getBodyParts();
	for i=bodyParts:size()-1, 0, -1  do
		local bodyPart = bodyParts:get(i);
		bodyPart:SetInfected(false);
	end
end