require "extern"
require "newbattle.HeroDataConfig"
require "newbattle.BattleHero"
require "newbattle.HeroButton"
require "newbattle.BattleSoldier"
require "newbattle.BattleHero2"

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
	self.gridlist = {
    	[1] = {},
    	[2] = {},
    	[3] = {},
    	[4] = {},
    	[5] = {},
    	[6] = {}
    }
	self.isEnd = false
    self:initBackground()
    self:registerScriptHandler(handler(self, self.execScript))
end

--设置Bg
function NewBattleScene:initBackground()
    local spBg = CCSprite:create(P("background/battlebg.png"))
	spBg:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))
	self:addChild(spBg, -1)
	self.spBg = spBg
end

--加载动画
function NewBattleScene:loadArmature()

    local adm = CCArmatureDataManager:sharedArmatureDataManager()
	adm:addArmatureFileInfo(P("soldier/soldat1/soldat1.ExportJson"))
	adm:addArmatureFileInfo(P("soldier/soldat2/soldat2.ExportJson"))
	adm:addArmatureFileInfo(P("soldier/soldat3/soldat3.ExportJson"))
	adm:addArmatureFileInfo(P("soldier/soldat4/soldat4.ExportJson"))
	adm:addArmatureFileInfo(P("soldier/soldat5/soldat5.ExportJson"))
	adm:addArmatureFileInfo(P("soldier/soldat6/soldat6.ExportJson"))
	
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

    local spBar = CCLayer:create()
    spBar:setContentSize(CCSize(WINSIZE.width, WINSIZE.height / 5))
    self:addChild(spBar,0)
    
    local hvalue = 20
    local headwidth = 80
    local totalwidth = headwidth *  #self.attacklist + hvalue * (#self.attacklist - 1)
    local leftX = (WINSIZE.width - totalwidth) / 2    

    local i = 1
    for j=#self.attacklist ,1,-1 do
    	local hero = self.attacklist[j]
    	local picName = P(string.format("head/herohead_%03d.png",hero.herocfg.HeroId))
    	local btnHero = HeroButton:Create(AttackList[j].HeroId, handler(hero, hero.onBtnClick))
    	hero.btn = btnHero
    	btnHero:setPosition(ccp(leftX + (i-1) * (hvalue + headwidth), spBar:getContentSize().height - btnHero:getContentSize().height))
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
    
    local atttable = {
      [1] = {},
      [2] = {},
      [3] = {}
    }
    
    local deftable = {
      [1] = {},
      [2] = {},
      [3] = {}
    }

    table.foreach(AttackList,function(index,config)
         local biggrid  = math.modf(config.Siteid /100)
         table.insert(atttable[biggrid],config) 
    end)
    table.foreach(DefendList,function(index,config)
         local biggrid  = math.modf(config.Siteid /100)
         table.insert(deftable[biggrid],config) 
    end)
     
    local index = 1 
    for biggrid,herolist in ipairs(atttable) do
    	local count = #herolist
        table.foreach(herolist,function(smallgrid,config)
             local pos = getSmallGrid(4 - biggrid,count,smallgrid)
             local hero = BattleHero:create(config,true,index,pos,self)
             hero.gridindex = 4 - biggrid
             self.battlelayer:addChild(hero,240 - pos.y)
             self.attacklist[index] = hero
             index = index + 1
        end)	
    end
   

    index = 1
    for biggrid,herolist in ipairs(deftable) do
    	local count = #herolist
        table.foreach(herolist,function(smallgrid,config)
        	 local pos = getSmallGrid(3 + biggrid,count,smallgrid)
             local hero = BattleHero:create(config,false,index,pos,self)
             hero.gridindex = 3 + biggrid
             self.battlelayer:addChild(hero,240 - pos.y)
             self.defendlist[index] = hero
             index = index + 1
        end)
    end  

end

--准备完成
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
	         hero:stopAllActions()
	         hero.state = HeroState.WIN
	    	end)
	    self.isEnd = true
        self:createReplayBtn()
	end 
     
end

--游戏暂停
function NewBattleScene:pause()
    
    local function pausehero(i,hero)
    	hero:actionPause()
    end
    table.foreach(self.attacklist,pausehero)
    table.foreach(self.defendlist,pausehero)
end

--游戏继续
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
    bg:setPosition(ccp(WINSIZE.width/2, WINSIZE.height*0.2))

    local animFrames = CCArray:create()
	for i = 1, 2, 1 do
		local texture = CCTextureCache:sharedTextureCache():addImage(P(string.format("skill/bg%d.png", i)))
		local txSize = texture:getContentSize()
		local frame = CCSpriteFrame:createWithTexture(texture, CCRectMake(0, 0, txSize.width, txSize.height))
		animFrames:addObject(frame)
	end

    local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.15)
	bg:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
	local heropic = P(string.format("skill/hero%03d.png",heroid))
    local heroCard = CCSprite:create(heropic)
    layer:addChild(heroCard)
    heroCard:setAnchorPoint(ccp(0, 0))
	heroCard:setPosition(ccp(-heroCard:getContentSize().width, bg:getPositionY() - bg:getContentSize().height/2))

	local name = CCSprite:create(P(string.format("skill/skill1_%03d.png",heroid))) 
    layer:addChild(name)
    name:setAnchorPoint(ccp(1, 0.5))
	name:setPosition(ccp(WINSIZE.width, bg:getPositionY()))
	name:setVisible(false)
	name:setScale(10)

    local action = CCMoveTo:create(0.3, ccp(-SX(5), heroCard:getPositionY()))

    local function cleanAndPlayBigSkill()
		self:removeChild(layer, true)
		self:resume()
		func()
	end
  
    local function nameAction()
		local spawn = CCSpawn:createWithTwoActions(CCFadeIn:create(0.6), CCScaleTo:create(0.4, 1))
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(0.2))
        arr:addObject(CCShow:create())
        arr:addObject(spawn)
        arr:addObject(CCDelayTime:create(0.3))
        arr:addObject(CCCallFunc:create(cleanAndPlayBigSkill))
        local seq = CCSequence:create(arr)
		name:runAction(seq)
	end

    heroCard:runAction(CCSequence:createWithTwoActions(action, CCCallFunc:create(nameAction)))
end

--添加到网格
function NewBattleScene:addToGrid(bigGrid,hero)
	if bigGrid <=0 or bigGrid > 6 then
		return
	end
    table.insert(self.gridlist[bigGrid],hero)
end

--移除网格
function NewBattleScene:removeFromGrid(bigGrid,hero)
    
    if bigGrid <=0 or bigGrid > 6 then
		return
	end
    table.foreach(self.gridlist[bigGrid],function(i,targethero)
	    	if targethero == hero then
	    	   self.gridlist[bigGrid][i] = nil
	    	end
    	end)
end

--获得敌人
function NewBattleScene:getAnenmyFromGrid(bigGrid,isattack)
	
	if bigGrid <=0 or bigGrid > 6 then
		return
	end
    local result = -1

    function findtarget(i,targethero)
	     if targethero.isattack ~= isattack and targethero.state ~= HeroState.DEAD then
		   result = i
		end
    end
    table.foreach(self.gridlist[bigGrid],findtarget)
	if result ~= -1 then
	    return self.gridlist[bigGrid][result]
	end
end

function NewBattleScene:createReplayBtn()
     
    local function replay()
        CCDirector:sharedDirector():replaceScene(NewBattleScene.new())
    end
    local btn = Button.new("herobattle/replay.png",nil,nil,replay)
    self:addChild(btn)
    btn:setPosition(ccp(WINSIZE.width - btn:getContentSize().width, btn:getContentSize().height))

end