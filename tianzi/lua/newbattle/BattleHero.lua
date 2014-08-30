
--英雄类
BattleHero = class("BattleHero",function()
   return CCLayerColor:create(ccc4(100,0,0,100))
end)

--构造函数
function BattleHero:ctor()
    --身体
	self.body = nil
    --坐骑
	self.mount = nil
    --士兵
    self.soldiers = {}
    --是否是进攻方 
    self.isattack = false
     
    self.heroSize = SZ(K_SIZE*4, K_SIZE*2)
    self:setContentSize(self.heroSize)
end

--创建函数
function BattleHero:create(heroid,mountid,soldierid,isattack)
    local myhero = BattleHero.new()
    myhero:setIsAttack(isattack)
    myhero:createSoldier(soldierid)
    myhero:createHeroAndMount(heroid,mountid)
    myhero:action("stand", 1)
    return myhero
end

--设置是否进攻方
function BattleHero:setIsAttack( isattack )
    self.isattack = isattack
    self:ignoreAnchorPointForPosition(false)
    self:setAnchorPoint(ccp(0.25, 0.5))
    if self.isattack then
        self:setScaleX(-1)
    end
end

--设置英雄与坐骑
function BattleHero:createHeroAndMount(heroid,mountid)
    
    local mount = CCArmature:create(mountid)
    mount:getAnimation():play("stand",-1,-1,1)
    local heromid = CCArmature:create(heroid)
    heromid:getAnimation():play("stand",-1,-1,1)
    local bone = mount:getBone("heromid")
    bone:addDisplay(heromid, 0)
    bone:changeDisplayByIndex(0, true)    
    mount:setPosition(ccp(K_SIZE*1, self.heroSize.height/3))
    
    self.body = heromid
    self.mount = mount

    self:addChild(self.mount,2)
end

--设置士兵
function BattleHero:createSoldier(soldierid)
    
    local soldierPosX = { [3] = K_SIZE*2.6,[2] = K_SIZE*3.4 ,[1]= K_SIZE*4.2}
    local soldierPoxY = { [3] = self.heroSize.height/4*1,[2]= self.heroSize.height/4*2,[1] = self.heroSize.height/4*3}   
     
    for j=1,3 do
        for i=1,3 do
            local soldier = CCArmature:create(soldierid)
            soldier:setPosition(ccp(soldierPosX[i],soldierPoxY[j]))
            self:addChild(soldier,j)
            self.soldiers[(j-1) * 3 + (i - 1) + 1 ] = soldier
        end
    end
end

--持续行动 walk stand win dead
function BattleHero:action(movestate,isloop)

    self.mount:getAnimation():play(movestate,-1,-1,isloop)
    self.body:getAnimation():play(movestate,-1,-1,isloop)
    for i,soldier in ipairs(self.soldiers) do
        soldier:getAnimation():play(movestate,-1,-1,isloop)    
    end
end

--普通攻击1.2
function BattleHero:attack(num)
    self.mount:getAnimation():play("attack",-1,-1,0)
    self.body:getAnimation():play("attack",-1,-1,0)
    for i,soldier in ipairs(self.soldiers) do
        soldier:getAnimation():play("attack"..num,-1,-1,0)    
    end
end

--小技能
function BattleHero:skill()
    self.mount:getAnimation():play("attack",-1,-1,0)
    self.body:getAnimation():play("skill1",-1,-1,0)
    for i,soldier in ipairs(self.soldiers) do
        soldier:getAnimation():play("attack1",-1,-1,0)    
    end
end

--大招
function BattleHero:bigskill()
    self.mount:getAnimation():play("attack",-1,-1,0)
    self.body:getAnimation():play("ult",-1,-1,0)
    for i,soldier in ipairs(self.soldiers) do
        soldier:getAnimation():play("attack1",-1,-1,0)    
    end
end

