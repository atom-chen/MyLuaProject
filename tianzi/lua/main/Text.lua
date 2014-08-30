module("Text", package.seeall)

local mScene = nil

--变量初始化 新增的变量需在此赋初值
function init()
	mScene = nil

end

function initScene(index)

	if mScene ~= nil then
		return nil
	end
	init()

	local tabs = {}
	tabs[1] = "aaa"
	tabs[2] = "bbb"

	local scene = TabScene.new(tabs, tabsFunc, close)
	mScene = scene.root
	scene:registerCallback(netCallBack)
	scene:registerScriptHandler(sceneEventHandler)

	if index == nil then
		index = 1
	end
	mScene:setSelectIndex(index)
end

function tabsFunc(scene, tag)
	local contentLayer = scene:getContentLayer()
	contentLayer:removeAllChildrenWithCleanup(true)
	
	
end

-------------------------------------------------------------
--local userData = GRequestParam:getParamData(lpExternalData)
function netCallBack(pScene, lpExternalData)
	if GReader:getActionID() == 1443 then
		
	end
end

function sceneEventHandler(eventType)
	if eventType ==  "enter" then
		onEnter()
	else
		onExit()
	end
end

function onEnter()

end

function onExit()

end

function close()
	if mScene then
		mScene = nil
	end
end
