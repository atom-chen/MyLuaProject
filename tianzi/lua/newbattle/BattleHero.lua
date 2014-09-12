

function getHeroArmatureNameFromId(nType)
    return string.format("hero%03d", nType)
end

function getSoldierArmatureName(nCorps)
    return "soldat"..nCorps
end
--站立状态为基本状态,平常没有动作的时候都是站立状态
HeroState = {
    --无
    NONE = 0,
    --寻找目标
    FINDTARGET = 1,
    --行走
    WALK = 3,
    --行走中
    WALKING = 7,
    --攻击
    ATTACK = 4,
    --大招
    BIGSKILL = 8,
    --死亡
    DEAD = 5,
    --胜利
    WIN = 6,
    --中断
    BREAK = 9
}

local WalkActionTag = 9999

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
  
  --当前攻击士兵
  self.curAttackIndex = 0

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

  self.skillarm = nil
  self.bigskillarm = nil
  
  --是否播放技能中
  self.isinskill = false
     
  self.heroSize = SZ(K_HEIGHT *4, K_WIDTH *2)
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
    
    --法术伤害
    self.ap = herocfg.ap
    --物理伤害
    self.ad = herocfg.ad

    --英雄状态
    self.state = HeroState.FINDTARGET
    -- 攻击目标
    self.target = nil
    --当前位置
    self.gridindex = 0
    
    self.ispaused = false
    
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
        self.battleScene:addToGrid(self.gridindex, self)
        self:action("stand",1)
    end

    local walkac = CCSequence:createWithTwoActions(CCMoveTo:create(12 * 400/1000, pos),
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
    mount:setPosition(ccp(K_WIDTH *1, self.heroSize.height/3))
    
    self.body = heromid
    self.mount = mount

    self:addChild(self.mount,2)

    self.body:getAnimation():registerMovementHandler(handler(self, self.MovementEventCallFun))
    self.body:getAnimation():regisetrFrameHandler(handler(self, self.FrameEventCallFun))

end

--获得技能骨骼
function BattleHero:getSkillarm()
    if not self.skillarm then
       self.skillarm = CCArmature:create(getHeroArmatureNameFromId(self.herocfg.HeroId))
       if self.isattack then
         self.skillarm:setScaleX(-1)
       end
       self.skillarm:getAnimation():registerMovementHandler(handler(self, self.SkillMovementCallFun))
    end
    if self.skillarm:getParent() then
       self.skillarm:removeFromParentAndCleanup(false)
    end
    return self.skillarm
end

--获得大招骨骼
function BattleHero:getBigskillarm()
   if not self.bigskillarm then
       self.bigskillarm = CCArmature:create(getHeroArmatureNameFromId(self.herocfg.HeroId))
       if self.isattack then
          self.bigskillarm:setScaleX(-1)
       end
       self.bigskillarm:getAnimation():registerMovementHandler(handler(self, self.SkillMovementCallFun)) 
   end
    if self.bigskillarm:getParent() then
       self.bigskillarm:removeFromParentAndCleanup(false)
    end
   return self.bigskillarm
end




function BattleHero:FrameEventCallFun(bone,eventname,cid,oid)
    
   if not self.target then
      return
   end 

   if eventname == "skill1"  then
       self.isinskill = false
       local skillarm = self:getSkillarm()
       self.battleScene:addChild(skillarm,1000)
       local pos = self.target:convertToWorldSpace(ccp(self.target.mount:getPosition()))
       skillarm:setPosition(pos)
       skillarm:getAnimation():play("skill1",-1,-1,0)
   end 
  
   if eventname == "ult" then

       self.isinskill = false
       local bigskillarm = self:getBigskillarm()
       self.battleScene:addChild(bigskillarm,1000)
       local pos = self.target:convertToWorldSpace(ccp(self.target.mount:getPosition()))
       bigskillarm:setPosition(pos)
       bigskillarm:getAnimation():play("ult",-1,-1,0)
   end 
   
   if eventname == "skill1buff" then
      
      local effectarm = CCArmature:create("common")
      self:addChild(effectarm,10)
      effectarm:setPosition(ccp(K_SIZE*1, self.heroSize.height + 90))
     
      local skill = SkillConfigs[self.herocfg.skill1id]
      if skill.bufftype == 1 then
         
         self.ad = self.ad + self.herocfg.ad * skill.buffvalue
         effectarm:getAnimation():play(skill.buffname,-1,-1,1)
         

         local function skillbuffend()
              self.ad = self.ad - self.herocfg.ad * skill.buffvalue
              effectarm:removeFromParentAndCleanup(true)
         end 
        
         local seq = CCSequence:createWithTwoActions(CCDelayTime:create(skill.time / 1000), 
                                                     CCCallFuncN:create(skillbuffend)
                                                     )
         effectarm:runAction(seq)

      end



   end  
  

end

function BattleHero:SkillMovementCallFun(armature,moveevnettype,movementid)
    
    if moveevnettype == 1 or moveevnettype == 2 then
       if movementid == "skill1"  then
           self:addQishi(AttackQishiAdd)
           self:attackTarget(self:getSkillAttackValue(self.herocfg.skill1id))
       end
       
       if movementid == "ult" then
           print("ult sub")
           self:attackTarget(self:getSkillAttackValue(self.herocfg.ultid))
       end

    end     
end


--设置士兵
function BattleHero:createSoldier(soldierid)
    
    --local soldierPosX = { [3] = K_SIZE*2.6,[2] = K_SIZE*3.4 ,[1]= K_SIZE*4.2}
    --local soldierPoxY = { [3] = self.heroSize.height/6*1,[2]= self.heroSize.height/6*3,[1] = self.heroSize.height/6*5}   
    
    local soldierPosX = { [2] = K_WIDTH * 2.5 ,[1]= K_WIDTH *3.5}
    local soldierPoxY = { [2] = K_HEIGHT* 0.5, [1] = K_HEIGHT * 1.5}   

    for j=1,2 do
        for i=1,2 do
            local soldier = BattleSoldier:create(soldierid)
            soldier:setPosition(ccp(soldierPosX[i],soldierPoxY[j]))
            self:addChild(soldier,j)
            local index = (j-1) * 2 + (i - 1) + 1
            soldier.index = index
            self.soldiers[index] = soldier
            
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
    self.mount:getAnimation():play("attack",-1,-1,0)
    self.body:getAnimation():play("attack",-1,-1,0)
    table.foreach(self.soldiers,function(i,soldier)
          soldier:getAnimation():play("attack"..num,-1,-1,0)
                                end)
end

--小技能
function BattleHero:skill()

    self.isinskill = true
    self.mount:getAnimation():play("attack",-1,-1,0)
    self.body:getAnimation():play("heroskill1",-1,-1,0)
    table.foreach(self.soldiers,function(i,soldier)
           soldier:getAnimation():play("attack2",-1,-1,1)
           end)
end

--发大招
function BattleHero:playBigskill()
     
     self.isinskill = true
     print("play utl:"..self.herocfg.HeroId,self.isattack,"beg")
     self:pauseWalkAction(true)
     self.mount:getAnimation():play("attack",-1,-1,0)
     self.body:getAnimation():play("heroult",-1,-1,0)
     table.foreach(self.soldiers,function(i,soldier)
         soldier:getAnimation():play("attack2",-1,-1,1)  
         end)

end

--大招
function BattleHero:bigskill()
    
    if not self:isCanAttack() then
       return false
    end 

    local function func()
       self.state = HeroState.BIGSKILL
    end

    if self.isattack then
       self.battleScene:bigSkillEffect(self.herocfg.HeroId,func)
    else
       func()
    end
   
    return true    
end

--攻击队列
function BattleHero:normalAttack()
   
   --不能攻击的话原地站立
   if not self:isCanAttack() then
      self:action("stand",1)
      self.state = HeroState.FINDTARGET
      return
   end
   
   --被攻击方自动大招
   if (not self.isattack) and self.qishi >= 3 * MaxQishi then
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


function BattleHero:breakAction()

   self.mount:getAnimation():play("stand",-1,-1,1)
   self.body:getAnimation():play("break",-1,-1,0)
   table.foreach(self.soldiers,function(i,soldier)
         soldier:getAnimation():play("stand",-1,-1,1)  
         end)

end


--添加气势
function BattleHero:addQishi(qishiadd)
   self.qishi = self.qishi + qishiadd
  
   if self.btn and self.state ~= HeroState.DEAD then
      self.btn:setQishi(self.qishi / MaxQishi * 100)
      if self.qishi >= MaxQishi then
         self.btn:setActive(true)
      end
   end
end

--死亡
function BattleHero:dead()
   self:setVisible(false)
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


--获得弓箭手世界坐标攻击坐标
function BattleHero:GetSoldierShootPoint()
   return self:convertToWorldSpace(ccp(K_WIDTH * 2,K_HEIGHT * 1))
end


--返回是否死亡
function BattleHero:subHp(attackvalue)
     
     
     --死亡
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
     
     local num = math.modf((self.herocfg.hp- self.hp) / self.herocfg.hp * 10 / 2.5)
     self:subSoldier(num) 

     self:addQishi(BeAttackQishiAdd)
     if self.hp <= 0 then
        isDead = true
        if self.status ~=  HeroState.DEAD then
           self.state = HeroState.DEAD
        end
        
     end

     if self.hp >0  and attackvalue >= self.herocfg.hp * 0.1 and self.isinskill then
        self.isinskill = false 
        print("break skill")
        self.state = HeroState.BREAK
     end

     return isDead
end

--攻击目标
function BattleHero:attackTarget(attackvalue)
    if self.target then
      if self.target then
         if self.target:subHp(attackvalue) then
            self.target = nil
         end
       end
    end
end

--武将动作回调
function BattleHero:MovementEventCallFun(armature,moveevnettype,movementid)
   
   --动作完成 
   if moveevnettype == 1 or moveevnettype == 2 then
       if movementid == "attack"  then
          
           self:action("stand",1)
           self:doNextAttack(function()
               self.state = HeroState.FINDTARGET
                --当前士兵攻击id
               self.curAttackIndex = 0
           end)
       elseif movementid == "heroskill1" then
           --攻击增加气势
          
           self:action("stand",1)
           self:doNextAttack(function()
               self.state = HeroState.FINDTARGET
           end)
       elseif movementid == "heroult" then
           
           self.isinskill = false

           print("play utl:"..self.herocfg.HeroId,self.isattack,"end")
           self:action("stand",1)

           if not self:pauseWalkAction(false) then
              self:doNextAttack(function()
                 self.state = HeroState.FINDTARGET
              end)
           end
           
       elseif movementid == "dead" then
           self:dead()

       elseif movementid == "skill1" then
           armature:removeFromParentAndCleanup(false)
       
       --中断
       elseif movementid == "break" then
           self:action("stand",1)
           self:doNextAttack(function()
                 self.state = HeroState.FINDTARGET
            end)
       end

   end
end

--初始化计时器
function BattleHero:initTimer()
    self:scheduleUpdateWithPriorityLua(handler(self, self.update),10)
end

--计时器
function BattleHero:update(dt)
    
    --判断是否暂停
    if  self.ispaused  then
        return
    end
    
    --判断是否结束
    if not self.battleScene.isEnd then
       if self.battleScene.attackalreadyCount == 0 or self.battleScene.defendalreadyCount == 0 then
          list = self.battleScene.attacklist
          self.battleScene:endGame(self.battleScene.attackalreadyCount  - self.battleScene.defendalreadyCount >0)
          return
       end
    end 
 


    --死亡
    if self.state ==  HeroState.DEAD then
       self:stopAllActions()       
       self:action("dead",0)
       self.battleScene:removeFromGrid(self.gridindex,self)
       if self.isattack then
            self.battleScene.attacklist[self.index] = nil
            self.battleScene.attackalreadyCount = self.battleScene.attackalreadyCount - 1
       else
            self.battleScene.defendlist[self.index] = nil
            self.battleScene.defendalreadyCount = self.battleScene.defendalreadyCount - 1
       end
       self:unscheduleUpdate()
       if self.btn  then
         self.btn:setActive(false)
         self.btn:setQishi(0)
       end
       return
    end
    
    --胜利
    if self.state == HeroState.WIN then
       self:action("win",1)
       self:unscheduleUpdate()
        if self.btn  then
           self.btn:setActive(false)
           self.btn:setQishi(0)
        end
       return  
    end 
    
    --前进
    if self.state == HeroState.WALK then
       self:action("walk",1)
       self:movetoNextGrid()
       self.state = HeroState.WALKING
       return
    end
    
    --攻击
    if self.state == HeroState.ATTACK then
       self.state = HeroState.NONE  
       self:normalAttack() 
       return 
    end
    
    --寻找目标
    if self.state == HeroState.FINDTARGET then
        self.state = HeroState.NONE  
        self:action("stand",1)
        self:findTarget()
        return    
    end
    
    --防止快死的时候按大招,后不死了
    if self.state ~= HeroState.DEAD and self.hp <= 0 then
       self.state = HeroState.DEAD
       return 
    end
    
    --大招
    if self.state == HeroState.BIGSKILL then
       self.state = HeroState.NONE
       self:playBigskill()
       return
    end
    
    --中断
    if self.state == HeroState.BREAK then
       self.state = HeroState.NONE
       self:breakAction()
       self:createBreakLabel()
    end

end

--寻找目标
function BattleHero:findTarget()
  
   if self.state == HeroState.DEAD then
      return
   end

  if not self.target  or self.state == HeroState.DEAD or self.hp <= 0 then
     local findindexs = self:getFindIndexs()
     for i,v in ipairs(findindexs) do
       local target = self.battleScene:getAnenmyFromGrid(v,self.isattack)
       if target and target.state ~= HeroState.DEAD and target.isattack ~= self.isattack then
          self.target = target
          self.state = HeroState.ATTACK
          break
       end
     end
  else
     self.state = HeroState.ATTACK
     return
  end

   --没有找到目标 
   if not self.target then
       self.state = HeroState.WALK
   end     

end

--获得寻找列表
function BattleHero:getFindIndexs()
   
   local findindexs = {}  
   local findtmp    = math.modf(self.herocfg.Siteid /100)
   if self.isattack then
     for i = self.gridindex + 1,self.gridindex + findtmp do
       table.insert(findindexs,i)
     end 
   else
     for i = self.gridindex - 1,self.gridindex - findtmp,-1 do
         table.insert(findindexs,i)
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
       self.state = HeroState.FINDTARGET
    end
    
    self.battleScene:removeFromGrid(self.gridindex,self)
    if self.isattack then
       self.gridindex = self.gridindex + 1
    else
       self.gridindex = self.gridindex - 1
    end
    self.battleScene:addToGrid(self.gridindex,self)

    local pos = ccp( de * K_WIDTH * 4, 0)
    local walkac = CCSequence:createWithTwoActions(CCMoveBy:create(4 *  self.herocfg.movespeed /1000 , pos),
                                                   CCCallFunc:create(movecallback))
    walkac:setTag(WalkActionTag)
    self:runAction(walkac)   

end

--是否能攻击
function BattleHero:isCanAttack()
    
    if self.state == HeroState.DEAD  or self.hp <= 0  or self.state == HeroState.WIN then
       return false
    end
    local result = true
    if not self.target or self.target.state == HeroState.DEAD  or self.hp <= 0 then
       result = false
       self.target = nil
    end
    return result
end 

--按钮回调
function BattleHero:onBtnClick(tag,herobtn)
     if self:bigskill() or self.state == HeroState.DEAD then
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
        label = CCLabelBMFont:create(string.format("%+d",value),P("fonts/greenfont.fnt"))
      else
        label = CCLabelBMFont:create(string.format("%+d",value),P("fonts/redfont.fnt"),16)
     end   
     self:addChild(label,100)

     label:setScale(0.5)

     if self.isattack then
        local scale = label:getScaleX()
        label:setScaleX(-1 * scale)
     end
     label:setPosition(ccp(K_SIZE*1, self.heroSize.height + 90))

     local function callback(item)
         self:removeChild(item, true)
     end
     

     local arr = CCArray:create()
     arr:addObject(CCFadeIn:create(0.2))
     arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.8, ccp(0,80)),
                                                CCFadeOut:create(0.8)
                   ))
     arr:addObject(CCCallFuncN:create(callback))
     local seq = CCSequence:create(arr)
     label:runAction(seq)
end

--打断标签
function BattleHero:createBreakLabel()


     local label = CCLabelBMFont:create("打断!",P("fonts/break.fnt"))
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
     arr:addObject(CCFadeOut:create(0.8))
     arr:addObject(CCCallFuncN:create(callback))
     local seq = CCSequence:create(arr)
     label:runAction(seq)
end

--暂停动作
function BattleHero:actionPause()
    self.mount:getAnimation():pause()
    self.body:getAnimation():pause()
    table.foreach(self.soldiers,function(i,soldier)
           soldier:pauseAction()
           end)
    CCDirector:sharedDirector():getActionManager():pauseTarget(self) 
    if self.skillarm then
       self.skillarm:getAnimation():pause()
    end
    if self.bigskillarm then
       self.bigskillarm:getAnimation():pause()
    end

    self.ispaused = true
end

--继续动作
function BattleHero:actionResume()
    self.mount:getAnimation():resume()
    self.body:getAnimation():resume()
    table.foreach(self.soldiers,function(i,soldier)
           soldier:resumeAction()
           end) 
    CCDirector:sharedDirector():getActionManager():resumeTarget(self) 
    if self.skillarm then
       self.skillarm:getAnimation():pause()
    end
    if self.bigskillarm then
       self.bigskillarm:getAnimation():pause()
    end
     self.ispaused = false
end

--继续下一个动作的间隔
function BattleHero:doNextAttack(func)
    local id = 0
    local function tick(dt)
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(id)
        id = 0
        func()
    end
    if id == 0 then
       id = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, self.herocfg.attackspeed / 1000, false)
    end
    
end

--暂停行走动作 返回当前是否有动作
function BattleHero:pauseWalkAction(isPause)
    if self:getActionByTag(WalkActionTag) ~= nil  then
       if isPause then
          CCDirector:sharedDirector():getActionManager():pauseTarget(self) 
       else
          self:action("walk",1)
          CCDirector:sharedDirector():getActionManager():resumeTarget(self) 
       end
       return true
    end 
    return false
end

--获得普通攻击值
function BattleHero:getNormalAttackValue()
   return self.ap + self.ad
end


--获得技能攻击值
function BattleHero:getSkillAttackValue(skillid)
   local skill = SkillConfigs[skillid]
   if skill.type == 1 or skill.type == 2 then
      return skill.damage + self.ap*skill.apadd + self.ad*skill.apadd
   end
   return 0
end