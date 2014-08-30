-------------------------------------------
-- 英雄
-- author:wenqs
-- date:2014-8
-------------------------------------------
module("Hero", package.seeall)
local K_SIZE = 40

-- 作战状态
EBattleStatus = {
	Idle = 0,			-- 空闲
	-- Stand = 1,		-- 站立
	Move = 2,			-- 移动
	Attack = 3,			-- 攻击
	Win = 4,			-- 胜利
	Dead = 9			-- 死亡
	
}

function create(tHero, nDirection)
	local hero = {
		Id = tHero.Id,					-- 标识
		Status = 0,						-- 状态 ESoldierStatus
		Type = tHero.Type,				-- 武将类型
		Corps = tHero.Corps,			-- 兵种
		--UI
		Direction = nDirection,			-- 方向
		Node = nil,						-- ui
		Hero = nil,						-- 英雄
		Mount = nil,					-- 坐骑
		Soldiers = {}					-- 士兵
		
	}
	local heroSize = SZ(K_SIZE*4, K_SIZE*2)
	--hero.Node = CCLayerColor:create(ccc4(128,128,0,255))
	hero.Node = CCLayer:create()
	hero.Node:setContentSize(heroSize)
	if hero.Direction == LEFT then
		hero.Node:ignoreAnchorPointForPosition(true)
		hero.Node:setAnchorPoint(ccp(0, 0))
		hero.Node:setScaleX(-1)
	end
	
	local soldier1 = Soldier.create(nID, hero.Corps)
	soldier1.Node:setPosition(ccp(K_SIZE*1.8, heroSize.height/4*3))
    hero.Node:addChild(soldier1.Node, 1)
	table.push_back(hero.Soldiers, soldier1)
	
	local soldier2 = Soldier.create(nID, hero.Corps)
	soldier2.Node:setPosition(ccp(K_SIZE*2.6, heroSize.height/4*3))
    hero.Node:addChild(soldier2.Node, 1)
	table.push_back(hero.Soldiers, soldier2)
	
	local soldier3 = Soldier.create(nID, hero.Corps)
	soldier3.Node:setPosition(ccp(K_SIZE*3.4, heroSize.height/4*3))
    hero.Node:addChild(soldier3.Node, 1)
	table.push_back(hero.Soldiers, soldier3)
	
	local soldier4 = Soldier.create(nID, hero.Corps)
	soldier4.Node:setPosition(ccp(K_SIZE*2, heroSize.height/4*2))
    hero.Node:addChild(soldier4.Node, 2)
	table.push_back(hero.Soldiers, soldier4)
	
	local soldier5 = Soldier.create(nID, hero.Corps)
	soldier5.Node:setPosition(ccp(K_SIZE*2.8, heroSize.height/4*2))
    hero.Node:addChild(soldier5.Node, 2)
	table.push_back(hero.Soldiers, soldier5)
	
	local soldier6 = Soldier.create(nID, hero.Corps)
	soldier6.Node:setPosition(ccp(K_SIZE*3.6, heroSize.height/4*2))
    hero.Node:addChild(soldier6.Node, 2)
	table.push_back(hero.Soldiers, soldier6)
	
	local soldier7 = Soldier.create(nID, hero.Corps)
	soldier7.Node:setPosition(ccp(K_SIZE*1.8, heroSize.height/4*1))
    hero.Node:addChild(soldier7.Node, 3)
	table.push_back(hero.Soldiers, soldier7)
	
	local soldier8 = Soldier.create(nID, hero.Corps)
	soldier8.Node:setPosition(ccp(K_SIZE*2.6, heroSize.height/4*1))
    hero.Node:addChild(soldier8.Node, 3)
	table.push_back(hero.Soldiers, soldier8)
	
	local soldier9 = Soldier.create(nID, hero.Corps)
	soldier9.Node:setPosition(ccp(K_SIZE*3.4, heroSize.height/4*1))
    hero.Node:addChild(soldier9.Node, 3)
	table.push_back(hero.Soldiers, soldier9)
	
	local mount = CCArmature:create(tHero.Mount)
	mount:getAnimation():play("stand")
	local bone = mount:getBone("heromid")
	--local heromid = CCArmature:create(getHeroArmatureName(hero.Type))
    local heromid = require("battle.MyHero").new(getHeroArmatureName(hero.Type))

	heromid:getAnimation():play("stand")
	bone:addDisplay(heromid, 0)
	bone:changeDisplayByIndex(0, true)
	mount:setPosition(ccp(K_SIZE*1, heroSize.height/3))
    hero.Node:addChild(mount, 2)
	hero.Hero = heromid
	hero.Mount = mount
	
	
	function hero:test()
		local fn1 = CCCallFunc:create(hero.attack)
		local fn2 = CCCallFunc:create(hero.skill)
		local fn3 = CCCallFunc:create(hero.ult)
		local fn4 = CCCallFunc:create(hero.stand)
		local delay = CCDelayTime:create(3)
		local seq1 = CCSequence:createWithTwoActions(fn1, delay)
		local seq2 = CCSequence:createWithTwoActions(seq1, fn2)
		local seq3 = CCSequence:createWithTwoActions(seq2, delay)
		local seq4 = CCSequence:createWithTwoActions(seq3, fn3)
		local seq5 = CCSequence:createWithTwoActions(seq4, delay)
		local seq6 = CCSequence:createWithTwoActions(seq5, fn4)
		
		-- local action = CCSequence:createWithTwoActions(fn1, fn2)
		hero.Node:runAction(seq6)
	end
	
	-- 站立
	function hero:stand()
		hero.Hero:getAnimation():play("stand", -1, -1, 1)
		hero.Mount:getAnimation():play("stand", -1, -1, 1)
		for k,v in pairs(hero.Soldiers) do
			v.Node:getAnimation():play("stand", -1, -1, 1)
		end
	end
	
	-- 普通攻击
	function hero:attack()
		hero.Hero:getAnimation():play("attack", -1, -1, 0)
		hero.Mount:getAnimation():play("attack", -1, -1, 0)
		for k,v in pairs(hero.Soldiers) do
			v.Node:getAnimation():play("attack1", -1, -1, 0)
		end
	end
	
	-- 小技能
	function hero:skill()
		hero.Hero:getAnimation():play("skill1", -1, -1, 0)
	end
	
	-- 大招
	function hero:ult()
		hero.Hero:getAnimation():play("ult", -1, -1, 0)
	end
	
	
	
	
	
	
	return hero
end

function getHeroArmatureName(nType)
	return string.format("hero%03d", nType)
end



