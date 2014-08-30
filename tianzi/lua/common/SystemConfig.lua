------------------------------------------------------------------
-- SystemConfig.lua
-- Author     : wenqs
-- Version    : 1.0
-- Date       : 2013-12
-- Description: 读取系统配置文件system.ini，不可更改
------------------------------------------------------------------
-- module("SystemConfig", package.seeall)

SystemConfig = {
	version = 0,	-- 系统配置文件版本号，不是程序版本号
	url = nil,	
	cid = 0,		-- 渠道id
	pid = 0,		-- 产品id
	iap = 0,
	codeVersion = 1 --每次更新脚本需要提升该版本号??
}

function readSystemConfigFile()
	local pIni = ScutDataLogic.CLuaIni:new()
	local bLoad = pIni:Load(P("config/system.ini"))
	if bLoad == false then 
		CCLuaLog("load system.ini error")
	else
		SystemConfig.version = pIni:Get("systemInfo", "version")
		SystemConfig.url = pIni:Get("systemInfo", "url")
		SystemConfig.cid = pIni:GetInt("systemInfo", "cid")
		SystemConfig.pid = pIni:GetInt("systemInfo", "pid")
		SystemConfig.iap = pIni:GetInt("systemInfo", "iap")
	end
	
	pIni:delete()
end

readSystemConfigFile()




