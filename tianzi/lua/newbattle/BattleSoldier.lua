BattleSoldier = class("BattleSoldier",function(name)
	return CCArmature:create(name)
end)

function BattleSoldier:ctor()
    self.name = nil
    self.arrow = nil
    self:getAnimation():registerMovementHandler(handler(self, self.SoldierMovementEventCallFun))
    self:getAnimation():regisetrFrameHandler(handler(self, self.SoldierFrameEventCallFun))
end

function BattleSoldier:create(name)
	local p = BattleSoldier.new(name)
    p.name = name
	return p
end

--士兵帧回调
function BattleSoldier:SoldierFrameEventCallFun(bone,eventname,cid,oid)
    
   if self.name == "soldat3" and eventname == "attack1"  then
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
    local bone = self:getBone("s3arrow") 
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
         ref:removeFromParentAndCleanup(false)
      end

      if self:getTarget() then
         local arrowarm = self:getShootArm()
         self:getWorldLayer():addChild(arrowarm,1000)
         local beginpos = self:getBeginPos()
         local shootpos = self:getShootPos()
         local endpos   = self:getTarget():GetSoldierShootPoint()
         local action   = CCSequence:createWithTwoActions(CCParabolyTo:create(1.0,beginpos,shootpos,endpos)
                                                        , CCCallFuncN:create(playend))
                        
         arrowarm:getAnimation():play("bullet",-1,-1,1)
         arrowarm:runAction(action)
      end

end

--获得射击骨骼
function BattleSoldier:getShootArm()
    if not self.arrow then
       self.arrow = CCArmature:create(self.name)
       self.arrow:getAnimation():play("bullet",-1,-1,1)
       self.arrow:setScaleX(-1)
    end
    if self.arrow:getParent() then
       self.arrow:removeFromParentAndCleanup(false)
    end
    return self.arrow
end






