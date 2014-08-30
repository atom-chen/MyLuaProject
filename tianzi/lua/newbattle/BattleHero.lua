

function getHeroArmatureNameFromId(nType)
    return string.format("hero%03d", nType)
end

function getSoldierArmatureName(nCorps)
    return "soldat"..nCorps
end

HeroState = {
    --空闲
    FREE = 1,
    --动作
    ACTION = 2
}

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
    --英雄配置
    self.herocfg = nil
    --战斗场景
    self.battleScene = nil
    --序号用来标记位置
    self.index = 1
    --攻击序号
    self.attindex = 1
    
    --气势值
    self.qishi = 0
     
    self.heroSize = SZ(K_SIZE*4, K_SIZE*2)
    self:setContentSize(self.heroSize)
end

--创建函数
function BattleHero:create(herocfg,isattack,index,pos,battleScene)
    local myhero = BattleHero.new()
    myhero.index = index
    myhero.herocfg = herocfg
    myhero.battleScene = battleScene
    myhero:setIsAttack(isattack)
    myhero:createSoldier(getSoldierArmatureName(herocfg.SoldierId))
    myhero:createHeroAndMount(getHeroArmatureNameFromId(herocfg.HeroId),herocfg.Mount)
    myhero:initPos(pos)
    return myhero
end

function BattleHero:initPos(pos)
    local orginPos = ccp(0, 0)
    if self.isattack then
       orginPos = ccp(pos.x - 480, pos.y)
    else
       orginPos = ccp(pos.x + 480, pos.y)
    end
    self:setPosition(orginPos)
    self:action("walk",1)
    

    local function walktopos()
        --通知作战页面zb好了
        self.battleScene:alreadyCallback(self.isattack)
        self:action("stand",1)
    end

    local walkac = CCSequence:createWithTwoActions(CCMoveTo:create(12 * 1000 / self.herocfg.movespeed, pos),
                                                   CCCallFunc:create(walktopos))
    self:runAction(walkac)

   
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

    self.body:getAnimation():registerMovementHandler(handler(self, self.MovementEventCallFun))
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
    self.mount:getAnimation():play("attack",1000/self.herocfg.attackspeed,-1,0)
    self.body:getAnimation():play("attack",1000/self.herocfg.attackspeed,-1,0)
    for i,soldier in ipairs(self.soldiers) do
        soldier:getAnimation():play("attack"..num,1000/self.herocfg.attackspeed,-1,0)    
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

--攻击队列
function BattleHero:normalAttack()
   
   --自动大招
   if not self.isattack and self.qishi > MaxQishi then
       self:bigskill()
       self.qishi = 0
       return
   end

   local cur = string.sub(self.herocfg.attackmode,self.attindex,self.attindex)
   if cur == "1" then
       self:attack(1)
   elseif cur == "2" then
       self:skill()
   end
   
   self.attindex = self.attindex + 1
   if self.attindex > string.len(self.herocfg.attackmode) then
       self.attindex = 1
   end

end

--动作回调
function BattleHero:MovementEventCallFun(armature,moveevnettype,movementid)
   
   --动作完成 
   if moveevnettype == 1 or moveevnettype == 2 then
       if movementid == "attack" or movementid == "skill1" then
           --攻击增加气势
           self.qishi = self.qishi + AttackQishiAdd
           self:normalAttack()
       elseif movementid == "ult" then
           self:normalAttack()
       end

   end
end

--初始化计时器
function BattleHero:initTimer()
    self:scheduleUpdateWithPriorityLua(handler(self, self.update),10)
end

--计时器
function BattleHero:update(dt)
    print(self.index)
end