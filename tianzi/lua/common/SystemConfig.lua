------------------------------------------------------------------
-- SystemConfig.lua
-- Author     : wenqs
-- Version    : 1.0
-- Date       : 2013-12
-- Description: ��ȡϵͳ�����ļ�system.ini�����ɸ���
------------------------------------------------------------------
-- module("SystemConfig", package.seeall)

SystemConfig = {
	version = 0,	-- ϵͳ�����ļ��汾�ţ����ǳ���汾��
	url = nil,	
	cid = 0,		-- ����id
	pid = 0,		-- ��Ʒid
	iap = 0,
	codeVersion = 1 --ÿ�θ��½ű���Ҫ�����ð汾��??
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




