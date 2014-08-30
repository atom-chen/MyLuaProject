--字体大小相关的函数或者字符串相关的库
-- Created by  on 8/2/2011.
-- Copyright 2008 , Inc. All rights reserved.
--

module("Font", package.seeall)

-- 记忆池
mWideWordWidth = {}
mUnwideWordWidth = {}
mUnwideWordWidth2 = {}
mSpaceWidth = {}
mLineHeight = {}
mCharSize={};

-- 生成key
function generateKey(fontName, fontSize)
	return string.format("%s%d", fontName, fontSize)
end
-- 获取字体行高
function lineHeightOfFont(fontName, fontSize)
	if fontName == nil then
		fontName=FONT_NAME
	end
	if fontSize == nil then
		fontSize=FONT_SIZE_L
	end
	local key = generateKey(fontName, fontSize)
	if mLineHeight[key] == nil then
		local label = CCLabelTTF:create(GameString.STR_OK, fontName, fontSize)
		mLineHeight[key] = label:getContentSize().height
	end
	return mLineHeight[key]
end
--
function stringLength(str)
	local nLen = string.len(str)
	local nPos = 0
	local nRet = 0
	for i = 1, nLen do
		if i > nPos then
			if Bit:_and(string.byte(str, i), 0x80) ~= 0 then
				nPos = i + 2
			else
				nPos = i
			end

			nRet = nRet + 1
		end
	end
	return nRet
end

--获取某个汉字的宽度
function getChineseWidth(fontName, fontSize)
	if fontName == nil then
		fontName=FONT_NAME
	end
	if fontSize == nil then
		fontSize=FONT_SIZE_L
	end
	local key = generateKey(fontName, fontSize)
	if mWideWordWidth[key] == nil then
		local label = CCLabelTTF:create(GameString.STR_OK, fontName, fontSize)
		mWideWordWidth[key] = label:getContentSize().height
	end
	return mWideWordWidth[key]
end
--获得单个字符的宽度
function charSize(char,fontName, fontSize)
	if fontName == nil then
		fontName = FONT_NAME;
	end
	
	if fontSize == nil then
		fontSize=FONT_SIZE_L;
	end
	
	local key = generateKey(fontName, fontSize)	
	local ancii=string.byte(char)
	--中文等字符
	if  ancii > 128 then
		return getCharSize(key,"chinese",char, fontName, fontSize)
	--大写
	elseif ancii >= 65 and ancii <= 90 then
		if char == "I" then
			return getCharSize(key,"I","I", fontName, fontSize)
		elseif char == "M" then
			return getCharSize(key,"M","M", fontName, fontSize)
		elseif char == "W" then
			return getCharSize(key,"W","W", fontName, fontSize)
		else
			return getCharSize(key,"A","A", fontName, fontSize)
		end
	--其他
	else
		if char == "i" then
			return getCharSize(key,"i","i", fontName, fontSize)
		elseif char == "m" then
			return getCharSize(key,"m","m", fontName, fontSize)
		elseif char == "w" then
			return getCharSize(key,"w","w", fontName, fontSize)
		elseif char == "l" then
			return getCharSize(key,"l","l", fontName, fontSize)
		elseif char == "1" then
			return getCharSize(key,"1","1", fontName, fontSize)	
		else
			return getCharSize(key,"a","a", fontName, fontSize)
		end
	end
end
--获得长度
function getCharSize(key,word,char, fontName, fontSize)
	if mCharSize[key] and mCharSize[key][word] then
		return mCharSize[key][word];
	else
	    if mCharSize[key] == nil then
	        mCharSize[key]={}
	    end
		local label = CCLabelTTF:create(char, fontName, fontSize)
		local size=label:getContentSize()
		mCharSize[key][word]=size;
		return size;			
	end
end
--将str分解成 width宽的字符串 和  剩余的字符串
function subString(str , width , fontName, fontSize)
	if str == "" or str	== nil then
		return nil;
	end
	local nWidth=0;
	local nLine="";
	local j = 0
	for i = 1, string.len(str) do
	    if j < i then
            local ancii=string.byte(str,i)
            local strChar="";
            if ancii > 128 and Bit:_and(ancii, 0x40) ~= 0 then
                local l = Bit:_and(ancii, 0xF0) / 16
                if l == 0xF then
                    strChar=string.sub(str,i,i+3);
                    j=i+3
                elseif l == 0xE then
                    strChar=string.sub(str,i,i+2);
                    j=i+2
                elseif l == 0xC then
                    strChar=string.sub(str,i,i+1);
                    j=i+1
                else--xx
                    strChar=string.sub(str,i,i);
                end
            else
                strChar=string.sub(str,i,i);
            end
            local charWidth=charSize(strChar,fontName, fontSize).width;
            if nWidth + charWidth > width then			
                return nLine,string.sub(str,i,string.len(str))
            else
                nLine=nLine..strChar
                nWidth=nWidth+charWidth
            end
        end
	end
 	return nLine
end

--字符串分割
function Split(szFullString, szSeparator)
	local nFindStartIndex = 1
	local nSplitIndex = 1
	local nSplitArray = {}
	while true do
	   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
	   if not nFindLastIndex then
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
		break
	   end
	   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
	   nFindStartIndex = nFindLastIndex + string.len(szSeparator)
	   nSplitIndex = nSplitIndex + 1
	end
	return nSplitArray
end

--去除头尾空格
function stringTrim(s)
	local from = s:match"^%s*()"
	return from > #s and "" or s:match(".*%S", from)
end