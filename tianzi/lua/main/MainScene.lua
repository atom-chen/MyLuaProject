module("MainScene", package.seeall)

--默认为不用设置此方法setisEnableMultiTouches
local mScene = nil
local mMainUILayer = nil

--变量初始化 新增的变量需在此赋初值
function init()
	mScene = nil
	mMainUILayer = nil
end

function release()
	if mScene then
		--SceneHelper.pomScene(mScene)
		mScene = nil
	end
	
	mMainUILayer = nil
end

function getMainScene()
	return mScene
end

function getMainUILayer()
	return mMainUILayer
end

function initScene()
	if mScene ~= nil then
		return nil
	end
	
	init()
	
    local scutScene = ScutScene:new(close)
	
	scutScene:registerCallback(netCallBack)
	
	scutScene:registerScriptHandler(sceneEventHandler)
	
    mScene = scutScene.root
	
	MapLayer.createUI()
	
	createUI()
	
	playBgMusic(P("music/mainui.mp3"), true, true)
	
	return mScene
end

function createUI()

	mMainUILayer = CCLayer:create()

	mMainUILayer:setPosition(ccp(0, 0))
	
	mScene:addChild(mMainUILayer, 0)
	
	MainTop.createUI()
	
	ChatUI.initTimer() -- 放最后
end

function sceneEventHandler(eventType)
	if eventType == "enter" then
		onEnter()
	else
		onExit()
	end
end

-- 	TODO 
function onEnter()
	if not g_IsMainMusic  then
		playBgMusic(P("music/mainui.mp3"), true, true)
	end
end

function onExit()
	
end

function close(bDirect)
	local function closeMsg(tag)
		if tag == 0 then
			CCDirector:sharedDirector():endToLua();
		end
	end
	
	if bDirect then
		release()
	else
		local box = MessageBox.new(GameString.STR_MAIN_EXIT, 2, GameString.STR_OK, GameString.STR_CANCEL, closeMsg)
		box:show(mScene)
	end
	
	return false
end

------------------------------------------
--local userData = GRequestParam:getParamData(lpExternalData)
function netCallBack(pScene, lpExternalData)
	--不是MainScene这个lua的Callback采用下面这个方式
	local actionID = GReader:getActionID()
	if actionID == 1201 or actionID == 1200 then
		ChatUI.netCallBack(pScene, lpExternalData, actionID)
	

	end
end

-- 跳转Scene
function enterScene(scene)
	if scene then
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		if runningScene == nil then
			CCDirector:sharedDirector():runWithScene(scene)
		else
			CCDirector:sharedDirector():replaceScene(scene)
		end
		
		-- close()
	end
end