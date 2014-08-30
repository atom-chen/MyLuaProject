require "extern"
require "newbattle.HeroDataConfig"
require "newbattle.BattleHero"

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
	self:createButtonLayer()
	self:createHero()

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
    
    for i=1,6 do
     	local btnHero = Button.new(P("head/1.png"), P("head/1.png"), nil, handler(self, self.onButtonClick))
		btnHero:getMenuItem():setTag(i)
		btnHero:setPosition(ccp(WINSIZE.width*0.8/6*i+btnHero:getContentSize().width/2, -btnHero:getContentSize().height/3))
		spBar:addChild(btnHero)
     end 

end

--按钮回调
function NewBattleScene:onButtonClick(tag)
    print("Button:"..tag.." pressed!")
end

--创建英雄
function NewBattleScene:createHero()
	
    --攻击列表
    local AttackList = {HeroConfigs[1],HeroConfigs[2],HeroConfigs[151],HeroConfigs[153],HeroConfigs[155],HeroConfigs[177]}
    --防守列表
    local DefendList = {HeroConfigs[1],HeroConfigs[2],HeroConfigs[151],HeroConfigs[153],HeroConfigs[155],HeroConfigs[177]}
    
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

--todo 获得英雄位置
--在屏幕外走到位置
--全部走到位置开始
--英雄寻找目标
  --找到目标?
    --是
      --是否在攻击范围内
        --是
          --开始攻击直到目标死去消失
        --否
          --走到攻击范围 
    --否
      --寻找方获得胜利
