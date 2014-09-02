

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
    ACTION = 2,
    --死亡
    DEAD = 3
}

--英雄类
BattleHero = class("BattleHero",function()
   --return CCLayerColor:create(ccc4(100,0,0,100))
   return CCLayer:create()
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
  --按钮
  self.btn = nil

  self.hpbg = nil
  self.hpbar = nil
     
  self.heroSize = SZ(K_SIZE*4, K_SIZE*2)
  self:setContentSize(self.heroSize)
end

--创建函数
function BattleHero:create(herocfg,isattack,index,pos,battleScene)
    local myhero = BattleHero.new()
    myhero.index = index
    myhero:initState(herocfg)
    myhero.battleScene = battleScene
    myhero:setIsAttack(isattack)
    myhero:createSoldier(getSoldierArmatureName(herocfg.SoldierId))
    myhero:createHeroAndMount(getHeroArmatureNameFromId(herocfg.HeroId),herocfg.Mount)
    myhero:initPos(pos)
    myhero:createHpbar()
    return myhero
end


--初始化英雄状态
function BattleHero:initState(herocfg)
    
    --英雄配置
    self.herocfg = herocfg
      --气势值
    self.qishi = 0
    --攻击序号
    self.attindex = 1
    --血量
    self.hp = herocfg.hp
    --英雄状态
    self.state = HeroState.FREE
    -- 攻击目标
    self.target = nil
    --当前位置
    self.gridindex = 0

    self.isInBigSkill = false
    
    self.isBeginToDie = false

    
end

--初始化位置
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
        if self.isattack then
           self.gridindex = 6 - self.index + 1
        else
           self.gridindex = 6 + self.index
        end 
        self.battleScene.gridlist[self.gridindex] = self
        self:action("stand",1)
    end

    local walkac = CCSequence:createWithTwoActions(CCMoveTo:create(12 * 200/1000, pos),
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
            soldier:getAnimation():registerMovementHandler(handler(self, self.SoldierMovementEventCallFun))
        end
    end
end

--持续行动 walk stand win dead
function BattleHero:action(movestate,isloop)

    self.mount:getAnimation():play(movestate,-1,-1,isloop)
    self.body:getAnimation():play(movestate,-1,-1,isloop)
     table.foreach(self.soldiers,function(i,soldier)
                  soldier:getAnimation():play(movestate,-1,-1,isloop)
                  end)      
end

--普通攻击1.2
function BattleHero:attack(num)
    self.mount:getAnimation():play("attack",self.herocfg.attackspeed/1000,-1,0)
    self.body:getAnimation():play("attack",self.herocfg.attackspeed/1000,-1,0)
    table.foreach(self.soldiers,function(i,soldier)
          soldier:getAnimation():play("attack"..num,self.herocfg.attackspeed/1000,-1,0)
                                end)
end

--小技能
function BattleHero:skill()
    self.mount:getAnimation():play("attack",-1,-1,0)
    self.body:getAnimation():play("skill1",-1,-1,0)
    table.foreach(self.soldiers,function(i,soldier)
           soldier:getAnimation():play("attack1",-1,-1,0)
           end)     
end

--大招
function BattleHero:bigskill()
    
    if not self:isCanAttack() then
        return false
    end 

    local function func()
       self.mount:getAnimation():play("attack",-1,-1,0)
       self.body:getAnimation():play("ult",-1,-1,0)
       table.foreach(self.soldiers,function(i,soldier)
           soldier:getAnimation():play("attack1",-1,-1,0)  
           end)
    end

    self.isInBigSkill = true
    self.battleScene:bigSkillEffect(self.herocfg.HeroId,func)
    return true    
end

--攻击队列
function BattleHero:normalAttack()
   
   --自动大招
   if not self:isCanAttack() then
      return
   end

   if (not self.isattack) and self.qishi >= 2300 then
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

--添加气势
function BattleHero:addQishi(qishiadd)
   self.qishi = self.qishi + qishiadd
  
   if self.btn then
      self.btn:setQishi(self.qishi / MaxQishi * 100)
      if self.qishi >= MaxQishi then
         self.btn:setActive(true)
      end
   end
end

--死亡
function BattleHero:dead()
   self:setVisible(false)
   if self.btn  then
      self.btn:setVisible(false)
   end
end

--扣除士兵
function BattleHero:subSoldier(num)
     for i=1,num do
         local soldier = self.soldiers[i]
         if soldier and soldier:isVisible() then
            soldier:getAnimation():play("dead",-1,-1,0)
            self.soldiers[i] = nil
         end
     end 

end

function BattleHero:SoldierMovementEventCallFun(armature,moveevnettype,movementid)
    
    if moveevnettype == 1 or moveevnettype == 2 then
        if movementid == "dead" then
           local arm = tolua.cast(armature, "CCArmature")
           arm:setVisible(false)
        end
    end
end

--扣血
function BattleHero:subHp(attackvalue)
     
     --大招中无敌 
     if self.isInBigSkill  then
        return false
     end

     if self.state == HeroState.DEAD then
        return true
     end

     local isDead = false
     self.hp = self.hp - attackvalue
     if self.btn then
        self.btn:setHp(self.hp / self.herocfg.hp * 100)
     end
     self:setHpBarValue(self.hp / self.herocfg.hp * 100)
     self:createBeAttackLable(-attackvalue)
     
     local num = math.modf((self.herocfg.hp- self.hp) / self.herocfg.hp * 10)
     self:subSoldier(num) 

     self:addQishi(BeAttackQishiAdd)
     if self.hp <= 0 then
        isDead = true
        if self.status ~=  HeroState.DEAD then
           self.state = HeroState.DEAD
           self.isBeginToDie = true
        end
        
     end
     return isDead
end

function BattleHero:attackTarget(attackvalue)
    if self.target then
      if self.target then
         if self.target:subHp(attackvalue) then
            self.target = nil
            self.state = HeroState.FREE
         end
       end
    end
end

--动作回调
function BattleHero:MovementEventCallFun(armature,moveevnettype,movementid)
   
   --动作完成 
   if moveevnettype == 1 or moveevnettype == 2 then
       if movementid == "attack" or movementid == "skill1" then
           --攻击增加气势
           self:addQishi(AttackQishiAdd)
           self:attackTarget(self.herocfg.ad)
           self:normalAttack()
       elseif movementid == "ult" then
           self.isInBigSkill = false 
           self:attackTarget(self.herocfg.ad * 10)
           self:normalAttack()
       elseif movementid == "dead" then
           self:dead()
       end

   end
end

--初始化计时器
function BattleHero:initTimer()
    self:scheduleUpdateWithPriorityLua(handler(self, self.update),10)
end

--计时器
function BattleHero:update(dt)
    
    if self.isBeginToDie then
        self:action("dead",0)
        self.battleScene.gridlist[self.gridindex] = nil
        if self.isattack then
            self.battleScene.attacklist[self.index] = nil
            self.battleScene.attackalreadyCount = self.battleScene.attackalreadyCount - 1
        else
            self.battleScene.defendlist[self.index] = nil
            self.battleScene.defendalreadyCount = self.battleScene.defendalreadyCount - 1
        end
       self.isBeginToDie = false
       self.state = HeroState.DEAD
       self:unscheduleUpdate()
       return
    end

    if self.state == HeroState.FREE then
        self:findTarget()    
    end
end

--寻找目标
function BattleHero:findTarget()
  
   if self.state == HeroState.DEAD then
      return
   end

  if self.battleScene.attackalreadyCount == 0 or self.battleScene.defendalreadyCount == 0 then
     list = self.battleScene.attacklist
     self.battleScene:endGame(self.battleScene.attackalreadyCount  - self.battleScene.defendalreadyCount >0)
     return
  end


  if not self.target then
     local findindexs = self:getFindIndexs()
     for i,v in ipairs(findindexs) do
       local target =  self.battleScene.gridlist[v]
       if target and target.state ~= HeroState.DEAD and target.isattack ~= self.isattack then
          self.target = target
          self.state = HeroState.ACTION
          self:normalAttack()
          break
       end
     end
     --没有找到目标 
     if not self.target then
         local de = 1
         if not self.isattack then
           de = -1
         end
         if not self.battleScene.gridlist[self.gridindex + de*2] then
            self:movetoNextGrid()
         end
     end     
  end
end

--获得寻找列表
function BattleHero:getFindIndexs()
   
   local findindexs = {}  
   local findtmp    = math.modf(self.herocfg.Siteid /100)
   if self.isattack then
      if self.gridindex % 2 == 1 then
        for i=self.gridindex + 1,self.gridindex + 2 * findtmp + 1 do
          table.insert(findindexs,i)
        end
      else
        table.insert(findindexs,self.gridindex  - 1)
        for i=self.gridindex + 1,self.gridindex + 2 * findtmp do
          table.insert(findindexs,i)
        end

      end
   else
      if self.gridindex % 2 == 1 then
         table.insert(findindexs,self.gridindex + 1)
         for i=self.gridindex - 1,self.gridindex - 2 * findtmp ,-1 do
            table.insert(findindexs,i)
         end
      else
        for i=self.gridindex - 1,self.gridindex - 2 * findtmp -1 ,-1 do
            table.insert(findindexs,i)
        end
      end
   end 
   return findindexs 
end

--移动到下个位置
function BattleHero:movetoNextGrid()
    
    local de = 1
    if not self.isattack then
       de = -1
    end
    local function movecallback()
       self.state = HeroState.FREE
       --self.gridindex = self.gridindex + de * 2
       --self.battleScene.gridlist[self.gridindex] = self
    end
    
    self.battleScene.gridlist[self.gridindex] = nil
    self.gridindex = self.gridindex + de * 2
    self.battleScene.gridlist[self.gridindex] = self

    self:action("walk",1)

    local pos = ccp( de * K_WIDTH * 4, 0)
    self.state = HeroState.ACTION
    local walkac = CCSequence:createWithTwoActions(CCMoveBy:create(4 *  self.herocfg.movespeed /1000 , pos),
                                                   CCCallFunc:create(movecallback))
    self:runAction(walkac)   

end

--是否能攻击
function BattleHero:isCanAttack()
    
    if self.state == HeroState.DEAD or self.isBeginToDie or self.hp <= 0 then
       return false
    end
    local result = true
    if not self.target or self.target.state == HeroState.DEAD then
       result = false
       self.target = nil
       self.state = HeroState.FREE
       self:action("stand",1)
    end
    return result
end 

--按钮回调
function BattleHero:onBtnClick(tag,herobtn)
     if self:bigskill() then
        self.qishi = 0
        herobtn:setActive(false)
        herobtn:setQishi(0)
     end
    
end


--添加血条
function BattleHero:createHpbar()
     local bgpic  = P("herobattle/bg_small.png")
     local barpic = P("herobattle/hp1_small.png")
     if not self.isattack then
        barpic =  P("herobattle/hp2_small.png")
     end

     local hpbg = CCSprite:create(bgpic)
     self:addChild(hpbg,10)
     
     local hpbarsp = CCSprite:create(barpic)
     local hpbar   = CCProgressTimer:create(hpbarsp)
     hpbar:setType(1)
     hpbar:setMidpoint(ccp(0, 0))
     hpbar:setBarChangeRate(ccp(1, 0))
     hpbar:setPercentage(100)
     hpbar:setAnchorPoint(ccp(0.5, 0.5))
     self:addChild(hpbar,11)
     
     local pos = ccp(K_SIZE*1, self.heroSize.height + 70)

     hpbg:setPosition(pos)
     hpbar:setPosition(pos)

     hpbg:setVisible(false)
     hpbar:setVisible(false)

     self.hpbg = hpbg
     self.hpbar = hpbar

end

--设置人物血量
function BattleHero:setHpBarValue(value)
     self.hpbg:setVisible(true)
     self.hpbar:setVisible(true)
     if value < 0 then
        value = 0
     end
     self.hpbar:setPercentage(value)
end

--设置人物扣血
function BattleHero:createBeAttackLable(value)

     local label = nil
     if value >= 0 then
        label = CCLabelBMFont:create(string.format("%+d",value),"fonts/greenfont.fnt")
      else
        print(P("fonts/redfont.fnt"))
        print(CCFileUtils:sharedFileUtils():fullPathForFilename("fonts/redfont.fnt"))
        label = CCLabelBMFont:create(string.format("%+d",value),"fonts/redfont.fnt")
     end   
     self:addChild(label,100)
     if self.isattack then
        label:setScaleX(-1)
     end
     label:setPosition(ccp(K_SIZE*1, self.heroSize.height + 90))

     local function callback(item)
         self:removeChild(item, true)
     end
     

     local arr = CCArray:create()
     arr:addObject(CCFadeIn:create(0.2))
     arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.6, ccp(0,50)),
                                                CCFadeOut:create(0.6)
                   ))
     arr:addObject(CCCallFuncN:create(callback))
     local seq = CCSequence:create(arr)
     label:runAction(seq)
end

--暂停动作
function BattleHero:actionPause()
    self.mount:getAnimation():pause()
    self.body:getAnimation():pause()
    table.foreach(self.soldiers,function(i,soldier)
           soldier:getAnimation():pause()
           end)
    CCDirector:sharedDirector():getActionManager():pauseTarget(self) 
end

--继续动作
function BattleHero:actionResume()
    self.mount:getAnimation():resume()
    self.body:getAnimation():resume()
    table.foreach(self.soldiers,function(i,soldier)
           soldier:getAnimation():resume()
           end) 
    CCDirector:sharedDirector():getActionManager():resumeTarget(self) 
end