BattleSoldier = class("BattleSoldier",function(name)
	return CCArmature:create(name)
end)

function BattleSoldier:ctor()
    self.index = 0
    self.name = nil
    self.arrowlist = {}
    self:getAnimation():registerMovementHandler(handler(self, self.SoldierMovementEventCallFun))
    self:getAnimation():regisetrFrameHandler(handler(self, self.SoldierFrameEventCallFun))
end

--构造函数
function BattleSoldier:create(name)
	local p = BattleSoldier.new(name)
    p.name = name
	return p
end

--士兵帧回调
function BattleSoldier:SoldierFrameEventCallFun(bone,eventname,cid,oid)
    
   if eventname == "attack1"  then
      if self:getBattleHero().curAttackIndex == 0 then
         self:getBattleHero().curAttackIndex = self.index
      end
      self:shootArrow()
   end
   
  if eventname == "attack2" then
     self:shootArrow()
  end
   
  if eventname == "attack3" then
     self:shootArrow()
  end
end

--士兵回调
function BattleSoldier:SoldierMovementEventCallFun(armature,moveevnettype,movementid)
    
    if moveevnettype == 1 or moveevnettype == 2 then
        if movementid == "dead" then
           local arm = tolua.cast(armature, "CCArmature")
           arm:setVisible(false)
        end

        if movementid == "attack1" and ( self:getSoldierId() == "1"or self:getSoldierId() == "2" or self:getSoldierId() == "4") then
           if  self:getBattleHero().curAttackIndex == 0 then
               self:getBattleHero():addQishi(AttackQishiAdd)
               self:getBattleHero():attackTarget(self:getBattleHero().herocfg.ad)
               self:getBattleHero().curAttackIndex = self.index
           end 
        end
    end
end

--获得父对象
function BattleSoldier:getBattleHero()
	return self:getParent()
end

--获得目标
function BattleSoldier:getTarget()
	return self:getBattleHero().target
end

--获得放置层
function BattleSoldier:getWorldLayer()
	return self:getBattleHero().battleScene
end

--获得发射点
function BattleSoldier:getShootPos()
    local x,y = self:getPosition()
    local bonename = "s"..self:getSoldierId().."arrow"
    local bone = self:getBone(bonename) 
    local pos  = ccp(x + bone:getWorldInfo():getX() , y + bone:getWorldInfo():getY() ) 
	  return self:getBattleHero():convertToWorldSpace(pos)
end

--获得开始点
function BattleSoldier:getBeginPos()
	local x,y = self:getPosition()
    local bone = self:getBone("peak") 
    local pos  = ccp(x + bone:getWorldInfo():getX() , y + bone:getWorldInfo():getY() ) 
	return self:getBattleHero():convertToWorldSpace(pos)
end

--射箭
function BattleSoldier:shootArrow()
      
      local function playend(ref)  
         if self:getBattleHero().curAttackIndex == self.index then
            self:getBattleHero():addQishi(AttackQishiAdd)
            self:getBattleHero():attackTarget(self:getBattleHero().herocfg.ad)
         end 
         ref:removeFromParentAndCleanup(false)
      end
      

      if self:getTarget() then
         local arrowarm = self:getShootArm()
         self:getWorldLayer():addChild(arrowarm,1000)
         local beginpos = self:getBeginPos()
         local shootpos = self:getShootPos()
         local endpos   = self:getTarget():GetSoldierShootPoint()
         local action   = CCSequence:createWithTwoActions(CCParabolyTo:create(ccpDistance(shootpos, endpos) / K_WIDTH * SoldierShootTime[self.name],beginpos,shootpos,endpos)
                                                        , CCCallFuncN:create(playend))
                        
         arrowarm:getAnimation():play("bullet",-1,-1,1)
         arrowarm:runAction(action)
      end

end

--获得射击骨骼
function BattleSoldier:getShootArm()
    
    local tmparray = nil
    for i=1,#self.arrowlist do
        local tmp = self.arrowlist[i]
        if not tmp:getParent() then
           tmparray = tmp
           break
        end 
    end 
    if not tmparray  then
       tmparray = CCArmature:create(self.name)
       tmparray:getAnimation():play("bullet",-1,-1,1)
       tmparray:setScaleX(-1)
       table.insert(self.arrowlist,tmparray)
    end
    return tmparray
end

--获得士兵ID
function BattleSoldier:getSoldierId()
    return string.sub(self.name, string.len(self.name),string.len(self.name))
end

--暂停动作
function BattleSoldier:pauseAction()
    self:getAnimation():pause()
    for i=1,#self.arrowlist do
       local arrow = self.arrowlist[i]
       arrow:getAnimation():pause()
       CCDirector:sharedDirector():getActionManager():pauseTarget(arrow) 
    end
end

--恢复动作
function BattleSoldier:resumeAction()
    self:getAnimation():resume()
    for i=1,#self.arrowlist do
       local arrow = self.arrowlist[i]
       arrow:getAnimation():pause()
       CCDirector:sharedDirector():getActionManager():resumeTarget(arrow) 
    end
end





