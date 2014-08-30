module("EngineInit", package.seeall)

CCDirector:sharedDirector():RegisterPauseHandler("EngineInit.onPause")
CCDirector:sharedDirector():RegisterResumeHandler("EngineInit.onResume")
CCLuaLog("=== ====RegisterBackHandler ")
CCDirector:sharedDirector():RegisterBackHandler("EngineInit.backKeyCallback")

--pause
function onPause()
	if false then
		local nMin = TiledMapCity.getMinBuildTime()
		local runnigScene =  CCDirector:sharedDirector():getRunningScene()
		if nMin > 0 then
			local str = GameString.STR_OK
			ScutUtility.GUtils:scheduleLocalNotification(nil, str, nil, nil, os.time() + nMin, 0, true)
		end
		--24 hour tips
		--ScutUtility.GUtils:scheduleLocalNotification(nil, str, nil, nil, os.time() + 60*60*24, 0, true)
	end
end

--resume
function onResume()
	ScutUtility.GUtils:cancelLocalNotifications()
	if funcResume ~= nil then
		funcResume()
	end
end

function backKeyCallback()
    CCLuaLog("=== ====backKeyCallback ")
	BackKeyManager.popTopWin()
end

