------------------------------------------------------------------
-- Author     : 
-- Version    : 1.15
-- Date       :   
-- Description: ,
------------------------------------------------------------------
GRequestParam = {param = {}}
GRequestCounter = 1
GReader = ScutDataLogic.CNetReader:getInstance()
GWriter = ScutDataLogic.CNetWriter:getInstance()
ZyM = 1
--默认跟网络交互处理成功的标记
--eScutNetSuccess = 0;
--eScutNetError = 10000;
eGNetSuccess = 10000

function GRequestParam:getParamData(nTag)
	return GRequestParam.param[nTag]
end

function GReader.readString()
	local nLen = GReader:getInt()
	local strRet = ""
	if nLen ~= 0
	then
        local str = ScutDataLogic.CLuaString:new("")
        GReader:getString(str, nLen)
        strRet = string.format("%s", str:getCString())
        str:delete()
	end
	return strRet
end

function GReader:readInt64()
	return ScutDataLogic.CInt64:new_local(GReader:getCInt64())
end

function GReader.readErrorMsg()
	return string.format("%s", GReader:getErrMsg():getCString())
end

function ExecRequest(pScutScene, ActionId, lpData, bShowLoading)
	ZyM = ZyM+1
	GWriter:writeInt32("m", ZyM)
	GWriter:writeInt32("OpCode", ActionId)
	GWriter:writeInt32("c", 0)
	if bShowLoading == true then
		Loading.show(pScutScene, GRequestCounter)
	end
	--如果为True 显示Loading图标--
	GRequestCounter = GRequestCounter + 1
	if lpData then
	    table.insert(GRequestParam.param, GRequestCounter, lpData)
	end
	ScutDataLogic.CDataRequest:Instance():AsyncExecRequest(pScutScene, GWriter:generatePostData(), GRequestCounter, nil);	
	
	ScutDataLogic.CNetWriter:resetData()
end

-- 网络请求成功，解析每个协议公共的协议体部分
function netSucceedFunc()
   --强制停服10006
	local bRet = true
	if GReader:getResult() == 10004 or GReader:getResult() == 10005 then
		return bRet
	end
	local nPlayNum = GReader:getInt()
	index = 0
	local info = PersonalInfo.getInfo()
	while index < nPlayNum do
		GReader:recordBegin()
		info.Level = GReader:getInt()
		info.Exp   = GReader:getInt()
		info.Money = GReader:getInt()
		info.Coin  = GReader:readInt64()
		info.NextExp = GReader:getInt()
		info.Coin = info.Coin:getValue()
        GReader:recordEnd()
		index = index + 1;
	end

	if nPlayNum > 0 then
		--update data or ui
		--[[MainUI.updateHeadData()
		if MainUI.getDropMenuLayer() then
			MainUI.getDropMenuLayer():updateData()
		end
		--]]
		Toast.show(scene, "NetHelper.lua netSucceedFunc")
	end
	
	if GReader:getResult() == 10003 then
		bRet = false
		GReLoginForSessionID()
	end

	return bRet 
end

--example:
--local netErrorInfo = {Module = "CopyScene", DataInfo = {JieKou = 12012, ....}}
--ExecRequest(mScene, 12012, netErrorInfo, true, true)
function netConnectError(pScene, nNetState, nTag)
	local userData = GRequestParam:getParamData(nTag)
	
	if userData ~= nil then
		if type(userData) == "table" and userData.Module then
			if userData.Module == "ChoiceServerScene" then
				ChoiceServerScene.netConnectError(userData.DataInfo)
			end
		else
		    netErrorToast(pScene, nNetState)
		end
	else
		netErrorToast(pScene, nNetState)
	end
end

function netErrorToast(pScene, nNetState)
	if 3 == nNetState then -- TimeOut
		netTimeOutFunc(pScene)
	else -- Failed
		netFailedFunc(pScene)
    end
end

-- 网络请求超时
function netTimeOutFunc(pScene)
	if pScene then
		Toast.show(pScene, GameString.STR_NETTIMEOUT)
	end
end

-- 网络请求失败
function netFailedFunc(pScene)
	if pScene then
		Toast.show(pScene, GameString.STR_NETFAILED)
	end
end

function initUrl()
	local pIni = ScutDataLogic.CLuaIni:new();
	CCLuaLog("====pIni:Load config/system.ini = " .. P("config/system.ini"))
	local bIsRead = pIni:Load(P("config/system.ini"));
	if bIsRead == false then 
		assert("system.ini error")
	else
		local url = pIni:Get("systemInfo", "url", "error")
		CCLuaLog("url = " .. url)
		if url ~= "error" then
		    CCLuaLog("setUrl url = " .. url)
			ScutDataLogic.CNetWriter:setUrl(url)
		else
		end
		
	end
end
initUrl()

-- 重新登录
function GReLoginForSessionID()
	local scene = MainScene.getMainScene()
	Toast.show(scene, "NetHelper.lua GReLoginForSessionID")
	--[[
	local info = PersonalInfo.getInfo()
	GWriter:writeInt32("s", info.ServerID)
	GWriter:writeString("username", info.UserName)
	GWriter:writeString("pwd", info.Psw)
	GWriter:writeInt32("v1", SystemConfig.version)
	GWriter:writeInt32("v2", SystemConfig.codeVersion)
	GWriter:writeString("channelid", SystemConfig.cid)
	GWriter:writeString("uniqueid", "tempudid")
	GWriter:writeInt32("mobiletype", GetPlatformType())
	
	-- ExecRequest(scene, 1000)
	-- 2012-12-20 by wqs
	-- 用于区分重新登录和注销91帐号
	ExecRequest(scene, 1000, 1)
	--]]
end
