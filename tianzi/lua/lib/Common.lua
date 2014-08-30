------------------------------------------------------------------
-- common.lua
-- Author     : wenqs
-- Version    : 1.0
-- Date       : 2013-12
-- Description: 通用类，包含字体，颜色，适配位置等
------------------------------------------------------------------
WINSIZE=CCDirector:sharedDirector():getWinSize()
local spForm = CCSprite:create(ScutDataLogic.CFileHelper:getPath("form/blankform.png"))
FORMSIZE = spForm:getContentSize()
LEFT = 1
RIGHT = 2

function GetPlatformType()
	local nType = ScutUtility.ScutUtils:GetPlatformType()
	return nType
end

function GGetFontSize(x)
	local ret = (SX(x) + SY(x)) /2
	--CCLuaLog("(SX(x) + SY(x)) /2 "..ret)
	--ptWindowsPhone7
	local nType = GetPlatformType()
	if nType == ScutUtility.ptANDROID or nType == ScutUtility.ptwindowsPhone7 then
		if WINSIZE.width == 480 and WINSIZE.height == 320 then
		elseif WINSIZE.width >=1280 and WINSIZE.height >= 720 then
			ret = ((960 / 480) * x + (540 / 320) * x) /2
		else
			ret = ((800 / 480) * x + (480 / 320) * x) /2
		end
	elseif nType == ScutUtility.ptWin32 then
		if WINSIZE.width == 1024 and WINSIZE.height == 768 then --iphone
			ret = x*2
		elseif WINSIZE.width == 480 and WINSIZE.height == 320 then
			--ret = (SX(x) + SY(x)) /2
			ret = x
		elseif 	WINSIZE.width == 960 and WINSIZE.height == 640 then
		    ret = x * 2
		elseif WINSIZE.width >=1280 and WINSIZE.height >= 720 then --android pad
			ret = ((960 / 480) * x + (540 / 320) * x) /2
		else --android 
			ret = ((800 / 480) * x + (480 / 320) * x) /2
		end
	elseif nType == ScutUtility.ptiPad then
		ret = x * 2
	end
	CCLuaLog("GGetFontSize "..x.." to "..ret)
	return ret
end

function SCALEX(x)

    return CCDirector:sharedDirector():getWinSize().width/480*x
end

function SCALEY(y)
    return CCDirector:sharedDirector():getWinSize().height /320*y
end

function SZ(width, height)
    return CCSize(width, height)
end 

function SX(x)
    return SCALEX(x)
end 

function SY(y)
    return SCALEY(y)
end

--以480,320作为基准。
local useHDResource = true
function PX(x)
	local nMargin = nil
	if WINSIZE.width == 480 and WINSIZE.height == 320 then
		nMargin = x
    elseif WINSIZE.width == 568 and WINSIZE.height == 320 then--iPhone 5
        nMargin = x*1.18
	else
		local nType = GetPlatformType()
		if nType == ScutUtility.ptANDROID or nType == ScutUtility.ptwindowsPhone7 then
			if useHDResource then
				nMargin = x*2
			else
				nMargin = x*2 * 0.75
			end
		elseif nType == ScutUtility.ptWin32 then
			if WINSIZE.width == 1024 and WINSIZE.height == 768 then --iphone
				nMargin = x*2
			elseif useHDResource then --android 
				nMargin = x*2
			else
				nMargin = x*2 * 0.75
			end
		else
			nMargin = x*2
		end
	end
	--CCLuaLog("PX "..x.." to "..nMargin)
	return nMargin
end

--以480,320作为基准。
function PY(y)
	local nMargin = nil
	if WINSIZE.width == 480 and WINSIZE.height == 320 then
		nMargin = y
    elseif WINSIZE.width == 568 and WINSIZE.height == 320 then-- iPhone 5
        nMargin = y
	else
		local nType = GetPlatformType()
		if nType == ScutUtility.ptANDROID or nType == ScutUtility.ptwindowsPhone7 then
			if useHDResource then
				nMargin = y*2
			else
				nMargin = y*2 * 0.75
			end
		elseif nType == ScutUtility.ptWin32 then
			if WINSIZE.width == 1024 and WINSIZE.height == 768 then --iphone
				nMargin = y*2
			elseif useHDResource then --android 
				nMargin = y*2
			else
				nMargin = y*2 * 0.75
			end
		else
			nMargin = y*2
		end
	end
	--CCLuaLog("PY "..y.." to "..nMargin)
	return nMargin
end

------------------------------------------------------------------
--字体定义
------------------------------------------------------------------
--FONT_NAME     		= "黑体"
CCLuaLog("WINSIZE"..WINSIZE.width.." "..WINSIZE.height )
FONT_NAME     	    = "微软雅黑"
FONT_SIZE_XXXL  	= GGetFontSize(48)
FONT_SIZE_XXL 		= GGetFontSize(20)
FONT_SIZE_XL  		= GGetFontSize(15)
FONT_SIZE_L  		= GGetFontSize(12)
FONT_SIZE_M  		= GGetFontSize(11)
FONT_SIZE_S  		= GGetFontSize(9)
FONT_SIZE_XS  		= GGetFontSize(8)



 --小分辨率字体修正
-- [[
local nType = GetPlatformType()
if nType == ScutUtility.ptANDROID then
	local scale = ScutUtility.ScutUtils:getScale()
	if scale < 1 then
		 FONT_SIZE_XXXL  	= GGetFontSize(50)
		 FONT_SIZE_XXL 		= GGetFontSize(22)
		 FONT_SIZE_XL  		= GGetFontSize(17)
		 FONT_SIZE_L  		= GGetFontSize(14)
		 FONT_SIZE_M  		= GGetFontSize(13)
		 FONT_SIZE_S  		= GGetFontSize(11)
		 FONT_SIZE_XS  		= GGetFontSize(10)
	 end
end
--]]

------------------------------------------------------------------
--颜色定义
------------------------------------------------------------------
ccBLACK = 			ccc3(0,0,0);
ccWHITE = 			ccc3(255,255,255);
ccYELLOW = 			ccc3(255,255,0);
ccBLUE = 			ccc3(0,0,255);
ccGREEN = 			ccc3(0,255,0);
ccRED = 			ccc3(255,0,0);
ccMAGENTA = 		ccc3(255,0,255);
ccORANGE = 			ccc3(255,127,0);
ccGRAY = 			ccc3(166,166,166);
ccPINK = 			ccc3(255, 192, 203);
ccPURPLE = 			ccc3(128, 0, 128);
ccGREEN_S = 		ccc3(150,250,50);--草绿色（亮一些）
ccGREEN_L = 		ccc3(83,196,0);--浅绿色
ccBLUE_L = 			ccc3(16,222,217);--浅蓝色
ccYELLOW_L = 		ccc3(255,255,204);--浅黄色(文字)
FONT_DEF_COLOR =	ccc3(0x55,0x44,0x44)
ccGRAY_128 = 		ccc3(128,128,128)
ccYELLOW_H = 		ccc3(255,255,200)--米黄色
ccYELLOW_DEFULT = 	ccc3(224,167,34)--橙色
ccPURPLE_RED = 		ccc3(224, 42, 189);--紫红色

--获取资源的路径
function P(fileName)
	if fileName then
		return ScutDataLogic.CFileHelper:getPath(fileName)
	else
		return nil
	end
	-- return fileName
end

function Int64(number)
	return ScutDataLogic.CInt64:new_local(number)
end

function int64toNumber(int64)
    if int64 == nil then
        return nil
    else
	    return tonumber(int64:str())
	end
end

-- 格式化时间戳，默认返回时间hh:mm:ss---
function formatTime(timestamp, format)
	if format == nil then
		format = "%02d:%02d:%02d"
	end
	local h, m, s = 0, 0, 0
	h=math.floor(timestamp / 3600)
	m=math.floor((timestamp % 3600) / 60)
	s=timestamp % 60
	
	return string.format(format, h, m, s)
end

function GatMac()
	return "tempmac"
end

-- 
function RandomseedOpen()
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
end