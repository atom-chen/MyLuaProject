------------------------------------------------------------------
-- UserConfig.lua
-- Author     : wenqs
-- Version    : 1.0
-- Date       : 2013-12
-- Description: 读写用户配置文件config.ini，可更改
------------------------------------------------------------------
-- module("UserConfig", package.seeall)

UserConfig = {
	isPlayMusic = 0,
	isPlayEffectMusic = 0,	
}

function readUserConfigFile()
	local pIni = ScutDataLogic.CLuaIni:new();
	local bLoad = pIni:Load(P("config/config.ini"));
	if bLoad == false then 
		assert("config.ini error")
	else
		UserConfig.isPlayMusic = pIni:GetInt("system", "isPlayMusic", "1")
		UserConfig.isPlayEffectMusic = pIni:GetInt("system", "isPlayEffectMusic", "1")
	end
	pIni:delete()
end
readUserConfigFile()

function saveUserConfigFile()
	--写入INI
	local pIni = ScutDataLogic.CLuaIni:new();
	local bIsRead = pIni:Load(P("config/config.ini"));
	if bIsRead == false then 
		assert("config.ini error")
	else
		pIni:SetInt("system", "isPlayMusic", UserConfig.isPlayMusic)
		pIni:SetInt("system", "isPlayEffectMusic", UserConfig.isPlayEffectMusic)
		local bAcc = pIni:Save("config/config.ini");
	end
	pIni:delete()
end

AccountsInfo = {}
function readAccountsFile()
	local pIni = ScutDataLogic.CLuaIni:new();
	local bLoad = pIni:Load(P("config/accounts.ini"));
	if bLoad == false then 
		assert("accounts.ini error")
	else
		AccountsInfo.serverID = pIni:Get("info0", "serverID", "0")
		AccountsInfo.account = pIni:Get("info0", "account", "error")
		AccountsInfo.pw = pIni:Get("info0", "pw", "error")
		AccountsInfo.nickName = pIni:Get("info0", "nickName", "error")
		AccountsInfo.pwLength = pIni:Get("info0", "pwLength", "error")
	end
	pIni:delete()
end

readAccountsFile()
























