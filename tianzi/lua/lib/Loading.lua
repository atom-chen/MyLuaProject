module("Loading", package.seeall)
mlstLoading = {}
local mCount = 0
local mLoadingSprite = nil
local mLoadingTag = 100001
local mZorder = 100

function getLoadingInfo(pScene)
	for k, v in pairs(mlstLoading) do
		if v.scene == pScene then
			return v
		end
	end
	return nil
end

function removeListData(lpScene)
	local key = nil
	for k, v in pairs(mlstLoading) do
		if v.scene == lpScene then
			key = k
			break
		end
	end
	if key ~= nil then
	    table.remove(mlstLoading,key)
	end
end

function getSceneInfoByTagId(nTagId)
	local ret = nil
	for k, v in pairs(mlstLoading) do
		if v.nTagId == nTagId  then
			ret = v
			break
		end
	end
	return ret
end

function getLoadingSprite()
	return mLoadingSprite
end

function show(pScene, nTagId, strTips)
    if strTips == "" or strTips == nil then
        strTips = "UnKnown Error!"
    end
    
	local itemInfo = getLoadingInfo(pScene)
	if itemInfo == nil then
		local loadingSpriet = createUI(pScene, nil, strTips, nTagId)
	
		local item = {scene = pScene, nCounter = 1, sprite = loadingSpriet, nTagId = nTagId, bActionFinish = false}
		
		if strTips then
			item.nCounter = 1
		else
			item.bActionFinish = true
			item.nCounter = 1
		end
		table.push_back(mlstLoading, item)
	else
		itemInfo.nCounter = itemInfo.nCounter + 1
	end

end

function hide(lpScene,nTag, bNetRequest)
	local itemInfo = getLoadingInfo(lpScene)
	if itemInfo ~= nil then
		itemInfo.nCounter = itemInfo.nCounter - 1
		if itemInfo.nCounter <= 0 then
			lpScene:removeChild(itemInfo.sprite, true)
			--
			removeListData(lpScene)
		end
	end
end

function createUI(pScene, pos, strTips, nTagId)
    if pScene == nil then return end
	--local item = CCNode:node()
	local item = CCLayer:create()
	local winSize = CCDirector:sharedDirector():getWinSize()
	item:setContentSize(winSize)
	--loading动画--
	-- local animFrames = CCMutableArray_CCSpriteFrame__:new(8)
	local animFrames = CCArray:createWithCapacity(8)
	local spriteloading = nil
	for i = 1, 8, 1 do
		local strPath = P(string.format("anime/bigloading/bigloading_%02d.png", i))
		local texture = CCTextureCache:sharedTextureCache():addImage(strPath)
		local txSize = texture:getContentSize()
		local frame0 = CCSpriteFrame:createWithTexture(texture, CCRectMake(0, 0, txSize.width, txSize.height))
		animFrames:addObject(frame0)
		if spriteloading == nil then
			spriteloading = CCSprite:createWithSpriteFrame(frame0)
		end
	end
	
	-- local animation = CCAnimation:animationWithName("wait", 0.3, animFrames)
	local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.3)
	animFrames = nil

	if pos ~= nil then
		spriteloading:setPosition(pos)
	else
		spriteloading:setPosition(ccp(winSize.width/2, winSize.height/2))
	end

	animate = CCAnimate:create(animation)
	spriteloading:runAction(CCRepeatForever:create(animate))

	item:addChild(spriteloading,0)
	
	--添加Loading下面的提示信息
	if false then
		local lbTips = CCLabelTTF:create(strTips, FONT_NAME, FONT_SIZE_L)
		
		local lbSz = lbTips:getContentSize()
		local tipsBg = ContentSize:create(P("mainui/loading_tips_bg.9.png"))
		
		lbSz.width = lbSz.width + SX(8) + SX(20)
		lbSz.height = lbSz.height + SY(8) + SY(10)
		tipsBg:setAnchorPoint(ccp(0.5, 0.5))
		tipsBg:setContentSize(lbSz)
		local pt = ccp(item:getContentSize().width/2,item:getContentSize().height/2)
		pt.y = pt.y - spriteloading:getContentSize().height/2 - SY(2) - lbSz.height/2
		item:addChild(tipsBg, 0)
		tipsBg:setPosition(pt)
		
		item:addChild(lbTips, 0)
		lbTips:setPosition(pt)
		tipsBg:setTag(nTagId)
		--local action1 = CCDelayTime:create(0.8)
		--local action = CCSequence:createWithTwoActions(action1,CCCallFuncN:actionWithScriptFuncName("Loading.actionFinish"))
		--tipsBg:runAction(action)
	end
	
	local menuItem = CCMenuItemSprite:create(item, nil)
	menuItem:setTag(nTagId)
	menuItem:registerScriptTapHandler(touchClick)
	mLoadingSprite = CCMenu:createWithItem(menuItem)
	-- mLoadingSprite:setTouchesDispatchPriority(-999)
	--mLoadingSprite = item
	pScene:addChild(mLoadingSprite, mZorder, mLoadingTag)
	return mLoadingSprite
end

function touchClick(item)
	if true then
		return
	end
	local nId = item:getTag()
	--
	local info = getSceneInfoByTagId(nId)
	if not info.bActionFinish  then
		info.bActionFinish = true
		Loading.hide(info.scene)
	end
end

function actionFinish(item)
	item:stopAllActions()
	touchClick(item)
end


