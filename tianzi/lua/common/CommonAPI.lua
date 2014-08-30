function getTexture(strPath)
	return CCTextureCache:sharedTextureCache():addImage(strPath)
end
----- 数字转换成中文 -----
-- 中文数字表
local mNumText = {}
table.push_back(mNumText,GameString.STR_NUM_1)
table.push_back(mNumText,GameString.STR_NUM_2)
table.push_back(mNumText,GameString.STR_NUM_3)
table.push_back(mNumText,GameString.STR_NUM_4)
table.push_back(mNumText,GameString.STR_NUM_5)
table.push_back(mNumText,GameString.STR_NUM_6)
table.push_back(mNumText,GameString.STR_NUM_7)
table.push_back(mNumText,GameString.STR_NUM_8)
table.push_back(mNumText,GameString.STR_NUM_9)
table.push_back(mNumText,GameString.STR_NUM_10)
table.push_back(mNumText,GameString.STR_NUM_ZERO)
table.push_back(mNumText,GameString.STR_NUM_HUNDRED)
table.push_back(mNumText,GameString.STR_NUM_THOUSAND)
table.push_back(mNumText,GameString.STR_NUM_WAN)

-- 阿拉伯数字转换为中文(新) 0~999
function getNumText(num)
    local numText = GameString.STR_NUM_ZERO
    
    local nTemp = num
    local nCount = 0
    local nBits = math.fmod(num,10)
    while nTemp ~= 0 do
        nTemp = math.modf(nTemp/10)
        nCount = nCount + 1
    end
    
    if nCount == 1 then    -- 1位数
        numText = mNumText[nBits]
    elseif nCount == 2 then    -- 2位数
        if num < 20 then    -- 20以下特殊情况
            numText = GameString.STR_NUM_10
            if mNumText[nBits] ~= nil then
                numText = numText .. mNumText[nBits]
            end
        else
            local nHigh = math.modf(num/10^(nCount-1))
            numText = mNumText[nHigh] ..  mNumText[10]
            if mNumText[nBits] ~= nil then
                numText = numText .. mNumText[nBits]
            end
        end
    elseif nCount == 3 then    -- 3位数
        local nHigh = math.modf(num/10^(nCount-1))
        numText = mNumText[nHigh] .. mNumText[12]
        local nMiddle = math.fmod(num,10^(nCount-1))
        nMiddle = math.modf(nMiddle/10^(nCount-2))
        
        if mNumText[nMiddle] == nil and mNumText[nBits] == nil then
            numText = numText
        else
            if mNumText[nMiddle] == nil then
                numText = numText .. mNumText[11]
            else
                numText = numText .. mNumText[nMiddle] .. mNumText[10]
            end
            
            if mNumText[nBits] ~= nil then
                numText = numText .. mNumText[nBits]
            end
        end
    end
    
    return numText
end

g_IsMainMusic = true --正在播放的背景音乐是否是主音乐
-- 播放背景音乐
function playBgMusic(src, bLoop, bMainScene)
    if UserConfig.isPlayMusic > 0 then
        if bMainScene ~= nil and bMainScene then 
            g_IsMainMusic = true
        else
            g_IsMainMusic = false
        end
        SimpleAudioEngine:sharedEngine():playBackgroundMusic(src, bLoop);
    end
end

-- 停止背景音乐
function stopBgMusic()
    SimpleAudioEngine:sharedEngine():stopBackgroundMusic()
end

--播放背景音效
function playEffectMusic(path)
    if getIsOpenMusic().isPlayEffectMusic ~= 0 then
        return SimpleAudioEngine:sharedEngine():playEffect(path)
    end
end

--停止音效
function stopEffectMusic(effectId)
    SimpleAudioEngine:sharedEngine():stopEffect(effectId)
end

-- 判断是否播放音乐与音效
function getIsOpenMusic()
    local IsOpen = {}
    IsOpen.isPlayMusic = UserConfig.isPlayMusic
    IsOpen.isPlayEffectMusic = UserConfig.isPlayEffectMusic
    
    return IsOpen
end

--返回时间hh:mm:ss---		nType =1"d天hh时" nType=2 "d天hh时mm分ss" nType=3 "hh:mm:ss"
function GFormatTime(timeNum,nType)
	local h,m,s = GCalculateTime(timeNum)
	local d = 0
	if not nType then  nType = 1 end 
	if nType == 1 then 
		if h >= 24 then 
			d = math.floor(h/24)
			h = h%24
			if h > 0 then 
				return d..GameString.STR_LV_TIME_DAY..h..GameString.STR_LV_TIME_HOURS
			end 
			return d..GameString.STR_LV_TIME_DAY
		elseif h > 0 then --显示 hh小时MM分钟
			if m >0 then 
				return string.format("%d"..GameString.STR_LV_TIME_HOURS.."%02d"..GameString.STR_LV_TIME_MINUTE,h,m)
			end 
			return string.format("%d"..GameString.STR_LV_TIME_HOURS,h)
		else
			if m > 0 then 
				return string.format("%d"..GameString.STR_LV_TIME_MINUTE.."%02d"..GameString.STR_LV_TIME_SECONDS,m,s)
			else
				return string.format("%d"..GameString.STR_LV_TIME_SECONDS,s)
			end 
		end 
	elseif nType == 2 then --全部显示
		if h > 24 then 
			d = math.floor(h/24)
			h = h%24
			return string.format("%d"..GameString.STR_LV_TIME_DAY.."%02d"..GameString.STR_LV_TIME_HOURS.."%02d"..GameString.STR_LV_TIME_MINUTE.."%02d"..GameString.STR_LV_TIME_SECONDS,d,h,m,s)
		else 
			return string.format("%02d"..GameString.STR_LV_TIME_HOURS.."%02d"..GameString.STR_LV_TIME_MINUTE.."%02d"..GameString.STR_LV_TIME_SECONDS,h,m,s)
		end 
	elseif nType == 3 then --全部显示 00:00:00
		return string.format("%02d:%02d:%02d",h,m,s)
	elseif nType == 4 then --全部显示不显示秒数
		if h > 24 then 
			d = math.floor(h/24)
			h = h%24
			return string.format("%d"..GameString.STR_LV_TIME_DAY.."%02d"..GameString.STR_LV_TIME_HOURS.."%02d"..GameString.STR_LV_TIME_MINUTE,d,h,m)
		else 
			return string.format("%02d"..GameString.STR_LV_TIME_HOURS.."%02d"..GameString.STR_LV_TIME_MINUTE,h,m)
		end 
	end 
end

-- 返回时间mm:ss
function GFormatMinutes(timeNum)
    local h,m,s = GCalculateTime(timeNum)
    return string.format("%02d:%02d", m, s)
end

--返回时间hh时mm分ss秒---
--bHideSecond:是否隐藏秒,默认显示
function GFormatTime2(timeNum, bHideSecond)
    if timeNum == nil or timeNum <= 0 then
        return WarString.IDS_NO_PROPS
    end
    local sRet = ""
    local h,m,s = GCalculateTime(timeNum)
    if h > 24 then--大于1天
        local nDay = math.floor(h/24)
        h = h - nDay * 24
        sRet = nDay  .. GameString.IDS_DAY.. h .. GameString.IDS_HOUR
    elseif h > 0 then
        sRet = h .. GameString.IDS_HOUR
    end
    if s > 0 and ( bHideSecond==nil or bHideSecond==false) then
        if h > 0 or m > 0 then
            sRet = sRet .. m .. GameString.IDS_MINUTE_2 .. s .. GameString.IDS_SECOND
        else
            sRet = sRet .. s .. GameString.IDS_SECOND
        end
    elseif m > 0 then
        sRet = sRet .. m .. GameString.IDS_MINUTE_2
    end
    return sRet
end

function GCalculateTime(timeNum)
    local nSec=timeNum
    local h=0
    local m=0
    local s=0
    if timeNum > 0 then
        h=math.floor(nSec/ 3600)
        m=math.floor((nSec%3600) /60)
        s=nSec%60
    end

    return h,m,s
end

function GCompareFloat(float1, float2)
    local float21 = float2 - 0.000001
    local float22 = float2 + 0.000001
    if float1 >= float21 and float1 <= float22  then
        return 0
    elseif float1 < float21 then
        return -1
    elseif float1 > float22 then
        return 1
    end
end

function GSectionToDate(sec)
    local nDate=os.date("*t", sec)
    local nCurrent =os.date("*t")
    local dateA = os.time({year = nDate.year, month = nDate.month, day = nDate.day})
    local dateB = os.time({year = nCurrent.year, month = nCurrent.month, day = nCurrent.day})
    local dis = math.floor((dateB - dateA) / 86400)
    local str
    if dis == 0 then
        str = string.format("%s %02d:%02d", GameString.STR_FARMDYNAMIC_TODAY, nDate.hour, nDate.min)
    elseif dis == 1 then
        str = string.format("%s %02d:%02d", GameString.STR_FARMDYNAMIC_YESTERDAY, nDate.hour, nDate.min)
    elseif dis == 2 then
        str = string.format("%s %02d:%02d", GameString.STR_FARMDYNAMIC_OTHERDAY, nDate.hour, nDate.min)
    else
        str = string.format("%04d-%02d-%02d %02d:%02d", nDate.year,nDate.month,nDate.day, nDate.hour, nDate.min)
    end
    return str
end

--xxx天xxx小时xxx分钟
function GSectionToDateExt(sec, bHideSecond)
    local nDate=os.date("*t", sec)
    local nCurrent =os.date("*t")
    local dateA = {day = nDate.yday, hour=nDate.hour, min=nDate.min}
    local dateB = {day = nCurrent.yday, hour=nCurrent.hour, min=nCurrent.min}
    local sRet = ""
    local h = dateB.day*24 + dateB.hour - dateA.day*24 - dateA.hour
    local m = dateB.min - dateA.min
    if m < 0 then
        h = h - 1
        m = m + 60
    end
    if h > 24 then--大于1天
        local nDay = math.floor(h/24)
        h = h - nDay * 24
        sRet = nDay  .. GameString.IDS_DAY.. h .. GameString.IDS_HOUR
    elseif h > 0 then
        sRet = h .. GameString.IDS_HOUR
    end

    --最少1分钟
    if sRet=="" and  m < 1 then
        m = 1
    end
    
    if m > 0 then
        sRet = sRet .. m .. GameString.IDS_MINUTE_2
    end
    return sRet
end

--判断数字 添加万 亿 
function getStrNum(Num)
	local strNum = nil 
	if Num > 10000 and Num < 100000000 then 
		strNum = math.floor(Num/10000)..GameString.STR_NUM_WAN
	elseif Num >= 100000000 then 
		strNum = math.floor(Num/100000000)..GameString.STR_NUM_YI
	else
		strNum = Num
	end
	
	return strNum
end 

