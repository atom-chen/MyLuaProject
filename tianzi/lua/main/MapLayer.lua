module("MapLayer", package.seeall)

local mScene = nil
local mMapLayer = nil
local mBgSprite = nil
local mMapData = {}
local mTouchBeginItem = nil
local mTouchBeginPT = nil
local mbMoveEvent = false

---以后有增加变量，请在release()中将其置空
function release()
	mScene = nil
	mMapLayer = nil
	mBgSprite = nil
	mMapData = {}
	mTouchBeginItem = nil
	mTouchBeginPT = nil
	mbMoveEvent = false
	
end

function close()
	if mMapLayer then
		mMapLayer:getParent():removeChild(mMapLayer, true)
		mMapLayer = nil;
	end
end

function getMapLayer()
	return mMapLayer
end

--strName nor, sel, x y 在图片中的像素位置
function initMapData()
	local tData = {	}
	--如果开启等级openLevel修改了，要修改“config/MeiJuConfig”功能开启中的配置
	local Info = {nor = "chengmen", x = 215, y = 190, id = 1, yOffest = 0.2, openLevel = 1}
	table.push_back(tData, Info)
	
	return tData
end
		
function createUI()
	if mScene == nil then
		mScene = MainScene.getMainScene()
	end
	
	mMapLayer = CCLayer:create()
	mBgSprite = CCSprite:create(P("background/mainbg.jpg"))
	mMapLayer:addChild(mBgSprite, 0)
	mBgSprite:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))

	local uiLayer = CCLayer:create()
	uiLayer:setContentSize(mBgSprite:getContentSize())
	mMapLayer:addChild(uiLayer, 0)
	uiLayer:setPosition(ccp(WINSIZE.width/2 - uiLayer:getContentSize().width/2,
		WINSIZE.height/2 - uiLayer:getContentSize().height/2))

	local map = CCSprite:create(P("background/mainmap.png"))
	uiLayer:addChild(map, 0)
	map:setPosition(ccp(uiLayer:getContentSize().width/2, uiLayer:getContentSize().height/2))

	mMapData = initMapData()
	for k, v in pairs(mMapData) do
		local strSel = "mainmap/" .. v.nor .. "_sel.png"
		local strNor = "mainmap/" .. v.nor .. "_nor.png"
		local menuItem = CCMenuItemImage:create(P(strNor), P(strSel))
		menuItem:setAnchorPoint(ccp(0.5, 0))
		menuItem:registerScriptTapHandler(itemCallback)
		menuItem:setTag(v.id)
		menuItem:setPosition(ccp(map:getContentSize().width*(v.x/1280), map:getContentSize().height*(v.y/800)))--地图 1280*800
		map:addChild(menuItem, 0)
		
		v.menuItem = menuItem
		
		local str = P("text/" .. v.nor .. "_text.png")
		local text = CCSprite:create(str)
		text:setAnchorPoint(ccp(1, 0.5))
		menuItem:addChild(text, 0)
		
		local xPos = 0
		local yPos = menuItem:getContentSize().height/2
		if v.xOffect then
			xPos = xPos + menuItem:getContentSize().width * v.xOffect
		end
		if v.yOffest then
			yPos = yPos + menuItem:getContentSize().height * v.yOffest
		end
		text:setPosition(ccp(xPos, yPos))
	end
		
    mMapLayer:registerScriptTouchHandler(onTouch)
	mMapLayer:setTouchEnabled(true)
		
	mScene:addChild(mMapLayer, -1)
end

--根据不同的Tag　进不同的界面
function itemCallback(index)
	local level = PersonalInfo.getInfo().Level
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	
	for k, v in pairs(mMapData) do
		if v.id == index then
			if level >= v.openLevel then
				if index == 1 then
					--Text.initScene()
					ChatUI.create(MainScene.getMainUILayer())
				else
					Toast.show(runningScene, tostring(item:getTag()))
				end
			else
				Toast.show(runningScene, string.format(GameString.STR_XG_Need, v.openLevel))
			end
		end
	end
end

function onTouch(eventType, x, y)
    if type(x) == "table" then
		y = x[2]
		x = x[1]
	end
    if eventType == "began" then   
        return onTouchBegan(x, y)
    elseif eventType == "moved" then
        return onTouchMoved(x, y)
    else
        return onTouchEnded(x, y)
    end
end

function onTouchBegan(x, y)
	mTouchBeginPT = ccp(x, y)
	mTouchBeginItem = itemForTouch(x, y)
	if mTouchBeginItem then
		mTouchBeginItem:selected()
	end
	mbMoveEvent = false
	
	return true
end

function onTouchMoved(x, y)
	local touchLocation = ccp(x,y) 
	local nDis = ccpDistance(touchLocation, mTouchBeginPT)

	if nDis > 10 then  --说明是Move事件
		mbMoveEvent  = true
	end
	
	if mTouchBeginPT then
		local cx, cy = mMapLayer:getPosition()
		local mx = cx + x - mTouchBeginPT.x
		local my = cy + y - mTouchBeginPT.y
		local nWidth = (mBgSprite:getContentSize().width-WINSIZE.width)/2
		local nHeight = (mBgSprite:getContentSize().height-WINSIZE.height)/2

		if mx > nWidth then
			mx = nWidth
		elseif mx < -nWidth then
			mx = -nWidth
		end
		if my > nHeight then
			my = nHeight
		elseif my < -nHeight then
			my = -nHeight
		end
		mMapLayer:setPosition(ccp(mx, my))
		mTouchBeginPT = ccp(x,y)--{x = x, y = y}
	end
end

function onTouchEnded(x, y)
	local endItem = itemForTouch(x, y)
	if mTouchBeginItem and endItem == mTouchBeginItem and not mbMoveEvent then
		mTouchBeginItem:activate()
	end
	if mTouchBeginItem then
		mTouchBeginItem:unselected()
	end
	
	mTouchBeginPT = nil
end

function itemForTouch(x,y)
	local touchLocation = ccp(x, y)
	
	for k, v in pairs(mMapData) do
		if v.menuItem:isVisible() then -- and menuItem:getIsEnabled()
			local point = v.menuItem:getParent():convertToNodeSpace(touchLocation)
			local r = v.menuItem:rect()
			if r:containsPoint(point) then
				return v.menuItem
			end
		end
	end
	
	return nil
end

