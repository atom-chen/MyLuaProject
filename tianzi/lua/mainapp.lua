math.randomseed(os.time())

--初始化　Lua的搜索路径 
function initPackagePath()
	local m_package_path = package.path
	local tInfo = {}
	local p1 = ScutDataLogic.CFileHelper:getPath("lua")
	table.insert(tInfo, string.format("%s/?.lua;", p1))
	table.insert(tInfo, string.format("%s/common/?.lua;", p1))
	table.insert(tInfo, string.format("%s/config/?.lua;", p1))
	table.insert(tInfo, string.format("%s/lib/?.lua;", p1))
	table.insert(tInfo, string.format("%s/login/?.lua;", p1))
	table.insert(tInfo, string.format("%s/main/?.lua;", p1))
	table.insert(tInfo, string.format("%s/datapool/?.lua;", p1))
	table.insert(tInfo, string.format("%s/battle/?.lua;", p1))

	local p2 = CCFileUtils:sharedFileUtils():fullPathForFilename("lua")
	table.insert(tInfo, string.format("%s/?.lua;", p2))
	table.insert(tInfo, string.format("%s/common/?.lua;", p2))
	table.insert(tInfo, string.format("%s/config/?.lua;", p2))
	table.insert(tInfo, string.format("%s/lib/?.lua;", p2))
	table.insert(tInfo, string.format("%s/login/?.lua;", p2))
	table.insert(tInfo, string.format("%s/main/?.lua;", p2))
	table.insert(tInfo, string.format("%s/datapool/?.lua;", p2))
	table.insert(tInfo, string.format("%s/battle/?.lua;", p2))

	
	--需要加目录的请按前面的格式添加。
	table.insert(tInfo, string.format("%s", m_package_path))
	local strPath = nil
	for k, v in pairs(tInfo) do
		if strPath == nil then
			strPath = v
		else
			strPath = strPath .. v
		end
	end
	package.path = strPath
end
initPackagePath()
-------------这几个有加载先后顺序----------------------
require("lib.lib")
require("config.config")
require("common.common")

------------------------------
require("login.login")
require("main.main")
require("datapool.datapool")
--require("battle.battle")

function OnHandleData(pScene, nTag, nNetRet, pData, lpExternal)
	pScene = tolua.cast(pScene, "CCScene")
	g_scenes[pScene]:execCallback(nTag, nNetRet, pData)
end

function PushReceiverCallback(pScene, lpExternalData)

end



-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

-- 设定垃圾回收参数

function main() 
	
	collectgarbage("setpause", 150)
    collectgarbage("setstepmul", 1000)
	CCDirector:sharedDirector():RegisterSocketPushHandler("PushReceiverCallback")
	ScutDataLogic.CNetWriter:setUrl(SystemConfig.url)

	require "newbattle.NewBattleScene"
	local sceneGame = NewBattleScene.new()
	runningScene = CCDirector:sharedDirector():getRunningScene()
   
	if runningScene == nil then
		CCDirector:sharedDirector():runWithScene(sceneGame)
	else
		CCDirector:sharedDirector():replaceScene(sceneGame)
	end
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end