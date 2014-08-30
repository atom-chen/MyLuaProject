-------------------------------------------
-- Soldier
-- author:wenqs
-- date:2014-8
-------------------------------------------
module("Soldier", package.seeall)


function create(nID, nCorps)
	local soldier = {
		Id = 0,							-- ±êÊ¶
		Status = -1,					-- ×´Ì¬ ESoldierStatus
		Corps = nCorps,					-- ±øÖÖ
		Node = nil,						-- 
		
	}
	
	soldier.Node = CCArmature:create(getSoldierArmatureName(soldier.Corps))
	soldier.Node:getAnimation():play("stand")

	
	return soldier
end

function getSoldierArmatureName(nCorps)
	return "soldat"..nCorps
end






