require "extern"
require "newbattle.HeroDataConfig"
require "newbattle.BattleHero"
require "newbattle.HeroButton"

function handler(target, method)
    return function(...)
        return method(target, ...)
    end
end 

NewBattleScene = class("NewBattleScene",function()
    return CCScene:create()	
end) 

--初始化
function NewBattleScene:ctor()
	self.spBg = nil
	self.battlelayer = nil
	self.attacklist ={}
	self.defendlist ={}
	self.attackalreadyCount = 0
	self.defendalreadyCount = 0
    --列表
	self.gridlist = {}
	self.isEnd = false
    self:initBackground()
    self:registerScriptHandler(handler(self, self.execScript))
end

--设置Bg
function NewBattleScene:initBackground()
    local spBg = CCSprite:create(P("background/battlebg.jpg"))
	spBg:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))
	self:addChild(spBg, -1)
	self.spBg = spBg
end

--加载动画
function NewBattleScene:loadArmature()

    local adm = CCArmatureDataManager:sharedArmatureDataManager()
	adm:addArmatureFileInfo(P("soldier/soldat1_1/soldat1.ExportJson"))
	adm:addArmatureFileInfo(P("soldier/soldat2_1/soldat2.ExportJson"))
	adm:addArmatureFileInfo(P("soldier/soldat3_1/soldat3.ExportJson"))
	adm:addArmatureFileInfo(P("soldier/soldat4_1/soldat4.ExportJson"))
	adm:addArmatureFileInfo(P("soldier/soldat5_1/soldat5.ExportJson"))
	adm:addArmatureFileInfo(P("soldier/soldat6_1/soldat6.ExportJson"))
	
	adm:addArmatureFileInfo(P("hero/hero001/hero001.ExportJson"))
	adm:addArmatureFileInfo(P("hero/hero002/hero002.ExportJson"))
	adm:addArmatureFileInfo(P("hero/hero151/hero151.ExportJson"))
	adm:addArmatureFileInfo(P("hero/hero153/hero153.ExportJson"))
	adm:addArmatureFileInfo(P("hero/hero155/hero155.ExportJson"))
	adm:addArmatureFileInfo(P("hero/hero177/hero177.ExportJson"))
	
	adm:addArmatureFileInfo(P("mount/mount88001_1/mount88001.ExportJson"))
	adm:addArmatureFileInfo(P("mount/mount88002_1/mount88002.ExportJson"))
	adm:addArmatureFileInfo(P("mount/mount88004_1/mount88004.ExportJson"))
	adm:addArmatureFileInfo(P("mount/mount88005_1/mount88005.ExportJson"))
	adm:addArmatureFileInfo(P("mount/mount88006_1/mount88006.ExportJson"))
	adm:addArmatureFileInfo(P("mount/mount88007_1/mount88007.ExportJson"))

	self:createLayer()
	self:createHero()
    self:createButtonLayer()
end

--进入主场景
function NewBattleScene:execScript(actionstr)
    if actionstr == "enter" then
       self:loadArmature()	
    end
end

--对齐横线
function NewBattleScene:createLayer()

	local battleSize = SZ(WINSIZE.width, K_HEIGHT*6)
	local battleLayer = CCLayerColor:create(ccc4(128,28,28,0))
	battleLayer:setContentSize(battleSize)
	battleLayer:setPosition(ccp(0, WINSIZE.height/5))
	self.spBg:addChild(battleLayer, 0)
	
	local col = battleSize.width / K_WIDTH
	local row = battleSize.height / K_HEIGHT

	for i = 0 , col do
		local shu = CCLayerColor:create(ccc4(100,100,100,200))
		shu:setContentSize(SZ(1, battleSize.height))
		shu:setPosition(ccp(i * K_WIDTH, 0))
		battleLayer:addChild(shu , 0)
		if i % 2 ==0 then
			shu:setColor(ccc3(100,0,0))
		end
	end
	for j = 0 , row do
		local heng = CCLayerColor:create(ccc4(100,100,100,200))
		heng:setContentSize(SZ(battleSize.width, 1))
		heng:setPosition(ccp(0, j * K_HEIGHT))
		battleLayer:addChild(heng , 0)
		if j % 2 ==0 then
			heng:setColor(ccc3(100,0,0))
		end
	end
	
	self.battlelayer = battleLayer;
end

--创建按钮层
function NewBattleScene:createButtonLayer()

	local spBar = CCSprite:create(P("form/form108840.png"))
	spBar:setAnchorPoint(ccp(0.5, 0))
	spBar:setPosition(ccp(WINSIZE.width/2, spBar:getContentSize().height))
	self:addChild(spBar, 0)
    
    local i = 1
    for j=#self.attacklist ,1,-1 do
    	local hero = self.attacklist[j]
    	local picName = P(string.format("head/herohead_%03d.png",hero.herocfg.HeroId))
    	local btnHero = HeroButton:Create(AttackList[j].HeroId, handler(hero, hero.onBtnClick))
    	hero.btn = btnHero
    	btnHero:setPosition(ccp(WINSIZE.width*0.8/6*i+btnHero:getContentSize().width/2, -btnHero:getContentSize().height/3))
    	spBar:addChild(btnHero)
    	i = i + 1
     end 

end

--按钮回调
function NewBattleScene:onButtonClick(tag)
    local hero = self.attacklist[tag]
    if hero and hero.state ~= HeroState.DEAD and hero.qishi >= MaxQishi then
       hero:bigskill()
       hero.qishi = 0 
       self.btnlist[tag]:setEnabled(false)
    end

end

--创建英雄
function NewBattleScene:createHero()
	
    
    --按照占值排序
    local function sortfunc(a,b)
    	return a.Siteid < b.Siteid
    end 

    table.sort(AttackList,sortfunc)
    table.sort(DefendList,sortfunc)
    
    local function createAttakHero(index,config)
       local hero = BattleHero:create(config,true,index,SmallGrid[6-index+1],self)
	   self.battlelayer:addChild(hero)
	   self.attacklist[index] = hero
    end
    
    local function createDefendHero(index,config)
       local hero = BattleHero:create(config,false,index,SmallGrid[6+index],self)
	   self.battlelayer:addChild(hero)
	   self.defendlist[index] = hero
    end 
    
    table.foreach(AttackList,createAttakHero)
    table.foreach(DefendList,createDefendHero)  

end

function NewBattleScene:alreadyCallback(isAttack)
     
     if isAttack then
     	self.attackalreadyCount = self.attackalreadyCount + 1
     else
     	self.defendalreadyCount = self.defendalreadyCount + 1
     end
     
     local function initTimer(index,hero)
          hero:initTimer()
     end

     if self.attackalreadyCount == table.getn(self.attacklist)  and  self.defendalreadyCount ==  table.getn(self.defendlist) then
         table.foreach(self.attacklist,initTimer)
         table.foreach(self.defendlist,initTimer)
     end

end

--结束游戏
function NewBattleScene:endGame(isattack)
   
   if not self.isEnd then
	    local list = nil
	    if isattack then
	       list = self.attacklist
	    else
	       list = self.defendlist
	    end
	    
	    table.foreach(list,function(i,hero)
	         hero:unscheduleUpdate()
	         hero:stopAllActions()
	         hero:action("win",1)
	    	end)
	    self.isEnd = true
	end 
     
end

function NewBattleScene:pause()
    
    local function pausehero(i,hero)
    	hero:actionPause()
    end
    table.foreach(self.attacklist,pausehero)
    table.foreach(self.defendlist,pausehero)
end

function NewBattleScene:resume()
	local function resumehero(i,hero)
    	hero:actionResume()
    end
    table.foreach(self.attacklist,resumehero)
    table.foreach(self.defendlist,resumehero)
end

--大招特效
function NewBattleScene:bigSkillEffect(heroid,func)
    
    self:pause()
    local layer = CCLayer:create()
    self:addChild(layer,100)

    local bg = CCSprite:create(P("skill/bg1.png"))
    layer:addChild(bg)
    bg:setPosition(ccp(WINSIZE.width/2, WINSIZE.height*0.4))

    local animFrames = CCArray:create()
	for i = 1, 2, 1 do
		local texture = CCTextureCache:sharedTextureCache():addImage(P(string.format("skill/bg%d.png", i)))
		local txSize = texture:getContentSize()
		local frame = CCSpriteFrame:createWithTexture(texture, CCRectMake(0, 0, txSize.width, txSize.height))
		animFrames:addObject(frame)
	end

    local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.15)
	bg:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
	local heropic = nil
	if heroid % 2 == 0 then
		heropic = P("skill/hero2.png")
	else
		heropic = P("skill/hero1.png")
	end
    
    local heroCard = CCSprite:create(heropic)
    layer:addChild(heroCard)
    heroCard:setAnchorPoint(ccp(0, 0))
	heroCard:setPosition(ccp(-heroCard:getContentSize().width, bg:getPositionY() - bg:getContentSize().height/2))

	local name = nil
	if heroid % 2 == 0 then
		name = CCSprite:create(P("skill/yjdq.png")) 
	else
		name = CCSprite:create(P("skill/jsmr.png"))
	end
    layer:addChild(name)
    name:setAnchorPoint(ccp(0, 0))
	name:setPosition(ccp(WINSIZE.width*0.42, bg:getPositionY() + bg:getContentSize().height/2))
	name:setVisible(false)
	name:setScale(10)

    local action = CCMoveTo:create(0.3, ccp(-SX(5), heroCard:getPositionY()))

    local function cleanAndPlayBigSkill()
		self:removeChild(layer, true)
		self:resume()
		func()
	end
  
    local function nameAction()
		local spawn = CCSpawn:createWithTwoActions(CCFadeIn:create(0.3), CCScaleTo:create(0.2, 1))
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(0.1))
        arr:addObject(CCShow:create())
        arr:addObject(spawn)
        arr:addObject(CCCallFunc:create(cleanAndPlayBigSkill))
        local seq = CCSequence:create(arr)
		name:runAction(seq)
	end

    heroCard:runAction(CCSequence:createWithTwoActions(action, CCCallFunc:create(nameAction)))
end




