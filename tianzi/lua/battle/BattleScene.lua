-------------------------------------------
-- ×÷Õ½³¡¾°
-- author:wenqs
-- date:2012-12
-------------------------------------------
module("BattleScene", package.seeall)
local K_SIZE = 32
local K_WIDTH = 40
local K_HEIGHT = 40

local mScene = nil

local tHeroL = nil
local tHeroR = nil

local tHeroConfigL = {}
tHeroConfigL[1] = {Id = 1, Type = 1, Corps = 1, Mount = "mount88001"}
tHeroConfigL[2] = {Id = 2, Type = 2, Corps = 2, Mount = "mount88002"}
tHeroConfigL[3] = {Id = 3, Type = 151, Corps = 3, Mount = "mount88004"}
tHeroConfigL[4] = {Id = 4, Type = 153, Corps = 4, Mount = "mount88005"}
tHeroConfigL[5] = {Id = 5, Type = 155, Corps = 5, Mount = "mount88006"}
tHeroConfigL[6] = {Id = 6, Type = 177, Corps = 6, Mount = "mount88007"}
local tHeroConfigR = {}
tHeroConfigR[1] = {Id = 1, Type = 1, Corps = 1, Mount = "mount88001"}
tHeroConfigR[2] = {Id = 2, Type = 2, Corps = 2, Mount = "mount88002"}
tHeroConfigR[3] = {Id = 3, Type = 151, Corps = 3, Mount = "mount88004"}
tHeroConfigR[4] = {Id = 4, Type = 153, Corps = 4, Mount = "mount88005"}
tHeroConfigR[5] = {Id = 5, Type = 155, Corps = 5, Mount = "mount88006"}
tHeroConfigR[6] = {Id = 6, Type = 177, Corps = 6, Mount = "mount88007"}


function init()
	mScene = nil
	tHeroL = {}
	tHeroR = {}
end

function initScene()
	if mScene ~= nil then
		return nil
	end
	init()
	
    local scutScene = ScutScene:new(close, true)
	scutScene:registerCallback(netCallBack)
    mScene = scutScene.root
	-- ScutScene:pushScene(mScene)
	initArmature()
	createUI()
	
	return mScene
end

function initArmature()
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
	
end

function createUI()
	local spBg = CCSprite:create(P("background/battlebg.jpg"))
	spBg:setAnchorPoint(ccp(0.5, 0.5))
	spBg:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))
	mScene:addChild(spBg, 0)
	
	
	
	local battleSize = SZ(WINSIZE.width, K_HEIGHT*6)
	local battleLayer = CCLayerColor:create(ccc4(128,28,28,0))
	battleLayer:setContentSize(battleSize)
	battleLayer:setPosition(ccp(0, WINSIZE.height/5))
	spBg:addChild(battleLayer, 0)
	
	local col = battleSize.width / K_WIDTH
	local row = battleSize.height / K_HEIGHT
	-- »­Íø¸ñ
	for i = 0 , col do
		local shu = CCLayerColor:create(ccc4(100,100,100,200))
		shu:setContentSize(SZ(1, battleSize.height))
		shu:setPosition(ccp(i * K_WIDTH, 0))
		battleLayer:addChild(shu , 0)
	end
	for j = 0 , row do
		local heng = CCLayerColor:create(ccc4(100,100,100,200))
		heng:setContentSize(SZ(battleSize.width, 1))
		heng:setPosition(ccp(0, j * K_HEIGHT))
		battleLayer:addChild(heng , 0)
	end
	
	local shu = CCLayerColor:create(ccc4(0,100,100,200))
	shu:setContentSize(SZ(1, battleSize.height))
	shu:setPosition(ccp(battleSize.width/2, 0))
	battleLayer:addChild(shu , 0)
	local heng = CCLayerColor:create(ccc4(100,0,100,200))
	heng:setContentSize(SZ(battleSize.width, 1))
	heng:setPosition(ccp(0, battleSize.height/2))
	battleLayer:addChild(heng , 0)
		
	-- ×ó±ß
	-- [[
	local heroL1 = Hero.create(tHeroConfigL[1], LEFT)
	heroL1.Node:setPosition(ccp(K_WIDTH*12, K_HEIGHT*3))
    battleLayer:addChild(heroL1.Node, 0)
	table.push_back(tHeroL, heroL1)
	
	local heroL2 = Hero.create(tHeroConfigL[2], LEFT)
	heroL2.Node:setPosition(ccp(K_WIDTH*12, K_HEIGHT*1))
    battleLayer:addChild(heroL2.Node, 0)
	table.push_back(tHeroL, heroL2)
	
	local heroL3 = Hero.create(tHeroConfigL[3], LEFT)
	heroL3.Node:setPosition(ccp(K_WIDTH*8, K_HEIGHT*3))
    battleLayer:addChild(heroL3.Node, 0)
	table.push_back(tHeroL, heroL3)

	local heroL4 = Hero.create(tHeroConfigL[4], LEFT)
	heroL4.Node:setPosition(ccp(K_WIDTH*8, K_HEIGHT*1))
    battleLayer:addChild(heroL4.Node, 0)
	table.push_back(tHeroL, heroL4)
	
	local heroL5 = Hero.create(tHeroConfigL[5], LEFT)
	heroL5.Node:setPosition(ccp(K_WIDTH*4, K_HEIGHT*3))
    battleLayer:addChild(heroL5.Node, 0)
	table.push_back(tHeroL, heroL5)
	
	local heroL6 = Hero.create(tHeroConfigL[6], LEFT)
	heroL6.Node:setPosition(ccp(K_WIDTH*4, K_HEIGHT*1))
    battleLayer:addChild(heroL6.Node, 0)
	table.push_back(tHeroL, heroL6)
	--]]
	
	--[[
	local heroL1 = Hero.create(1, 1, LEFT)
	heroL1.Node:setPosition(ccp(K_WIDTH*15, K_HEIGHT*2))
    battleLayer:addChild(heroL1.Node, 6-2)
	
	local heroL2 = Hero.create(2, 2, LEFT)
	heroL2.Node:setPosition(ccp(K_WIDTH*14, K_HEIGHT*1))
    battleLayer:addChild(heroL2.Node, 6-1)
	
	local heroL3 = Hero.create(3, 3, LEFT)
	heroL3.Node:setPosition(ccp(K_WIDTH*14, K_HEIGHT*3))
    battleLayer:addChild(heroL3.Node, 6-3)
	
	local heroL4 = Hero.create(4, 4, LEFT)
	heroL4.Node:setPosition(ccp(K_WIDTH*15, K_HEIGHT*0))
    battleLayer:addChild(heroL4.Node, 6-0)
	
	local heroL5 = Hero.create(5, 5, LEFT)
	heroL5.Node:setPosition(ccp(K_WIDTH*15, K_HEIGHT*4))
    battleLayer:addChild(heroL5.Node, 6-4)
	
	local heroL6 = Hero.create(6, 6, LEFT)
	heroL6.Node:setPosition(ccp(K_WIDTH*14, K_HEIGHT*5))
    battleLayer:addChild(heroL6.Node, 6-5)
	--]]
	
	-- ÓÒ±ß
	
	local heroR1 = Hero.create(tHeroConfigR[1], RIGHT)
	heroR1.Node:setPosition(ccp(K_WIDTH*12, K_HEIGHT*3))
    battleLayer:addChild(heroR1.Node, 0)
	
	local heroR2 = Hero.create(tHeroConfigR[2], RIGHT)
	heroR2.Node:setPosition(ccp(K_WIDTH*12, K_HEIGHT*1))
    battleLayer:addChild(heroR2.Node, 0)
	
	local heroR3 = Hero.create(tHeroConfigR[3], RIGHT)
	heroR3.Node:setPosition(ccp(K_WIDTH*16, K_HEIGHT*3))
    battleLayer:addChild(heroR3.Node, 0)
	
	local heroR4 = Hero.create(tHeroConfigR[4], RIGHT)
	heroR4.Node:setPosition(ccp(K_WIDTH*16, K_HEIGHT*1))
    battleLayer:addChild(heroR4.Node, 0)
	
	local heroR5 = Hero.create(tHeroConfigR[5], RIGHT)
	heroR5.Node:setPosition(ccp(K_WIDTH*20, K_HEIGHT*3))
    battleLayer:addChild(heroR5.Node, 0)
	
	local heroR6 = Hero.create(tHeroConfigR[6], RIGHT)
	heroR6.Node:setPosition(ccp(K_WIDTH*20, K_HEIGHT*1))
    battleLayer:addChild(heroR6.Node, 0)
	
	createBottomUI()
end

function createBottomUI()
	-- local battleSize = SZ(WINSIZE.width, K_HEIGHT*6)
	-- local bottom = CCLayerColor:create(ccc4(128,280,28,0))
	-- bottom:setContentSize(battleSize)
	-- battleLayer:setPosition(ccp(0, WINSIZE.height/5))
	-- spBg:addChild(battleLayer, 0)
	
	local spBar = CCSprite:create(P("form/form108840.png"))
	spBar:setAnchorPoint(ccp(0.5, 0))
	spBar:setPosition(ccp(WINSIZE.width/2, spBar:getContentSize().height))
	mScene:addChild(spBar, 0)
	
	
	for k,v in pairs(tHeroL) do
		local btnHero = Button.new(P("head/1.png"), P("head/1.png"), nil, testSkill)
		btnHero:getMenuItem():setTag(k)
		btnHero:setPosition(ccp(WINSIZE.width*0.8/6*k+btnHero:getContentSize().width/2, -btnHero:getContentSize().height/3))
		spBar:addChild(btnHero)
	end 
	
end

function testSkill(tag)
	tHeroL[tag].test()
end

function converCoordToPosition(x, y)
	
	
	
end

function close()
	if mScene then
		mScene = nil
	end
end

-- ÍøÂç»Øµ÷
function netCallBack(pScene, lpExternalData)
	if GReader:getActionID() == 1000 then--µÇÂ¼
		_1000Callback(pScene, close)
	elseif GReader:getActionID() == 1011 then--È¡ÕËºÅ
		_1011Callback()
	elseif GReader:getActionID() == 1012 then
		ChoiceSrvScene.Callback_1012(mScene, lpExternalData)
	end
end







