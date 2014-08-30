require("lib.Common")
module("Edit", package.seeall)
EDIT_HEIGHT = SY(20)
--edit = Edit.new 创建Edit
--删除用edit:remove()
--rcRect 此坐标要通过CCNode的坐标转换进行计算
--而且相对的Node, 注意Node的所有Parent必须已经加到Scene上面
--相对参照物的node
--相对于node的坐标系
--size 为Edit的宽高　单行高默认为Edit.EDIT_HEIGHT
--Edit　AnchorPoint(0,0.5)
--retEdit setInputNumber()
function newFromNode(parent, pt, size, funTimer, bMultileline, bPwd, bgColor4, textColor4, bgImage)
	local point = parent:convertToWorldSpace(pt)
	local edPoint = ccp(point.x, WINSIZE.height - point.y - size.height/2)
	local rect = CCRectMake(edPoint.x, edPoint.y, size.width, size.height)
	local edit = new(rect, funTimer, bMultileline, bPwd, bgColor4, textColor4)
	function edit:setBgImg(bgImage)
		local strimage = bgImage
		if strimage == nil then
			strimage = P("dian9/inputbox40180.9.png")
		end
		local sp = CCScale9Sprite:create(strimage)
		sp:setAnchorPoint(ccp(0,0.5))
		parent:addChild(sp, 0)
		-- local scale = CCDirector:sharedDirector():getDisplaySizeInPixels().height/CCDirector:sharedDirector():getWinSize().height
		-- pt.x = pt.x * scale
		-- pt.y = pt.y * scale
		sp:setPosition(pt)
		sp:setContentSize(size)
	end
	if bgImage then
		edit:setBgImg()
	end
	return edit
end

--此方法将不在使用，用newFromNode
function new(rcRect,funTimer, bMultileline, bPwd,  bgColor4, textColor4)
	local nType = GetPlatformType()
	if nType == ScutUtility.ptANDROID or nType == ScutUtility.ptWin32 then
		-- TODO local scale = UI.UIScene:getContentScaleFactor()
		local scale = 1
		rcRect.origin.x = rcRect.origin.x * scale
		rcRect.origin.y = rcRect.origin.y * scale
		--added by pengmr
		rcRect.size.width = rcRect.size.width * scale
		rcRect.size.height = rcRect.size.height * scale
	end

	local mRect = rcRect
	local retEdit = ScutCxControl.UIEdit:new()
	local bMulti = false
	local bPwdMode = false
	if bMultileline ~= nil
	then
		bMulti = bMultileline
	end

	if bPwd ~= nil
	then
		bPwdMode = bPwd
	end
	local textColor =  ccc4(0, 0, 0, 255)
	if textColor4  then
		textColor = textColor4
	end
	local bgColor = ccc4(255, 255, 255, 255)
	if bgColor4 then
		bgColor = bgColor4
	end
	
	retEdit:init(bMulti, bPwdMode, bgColor, textColor)
	retEdit:SetTextSize(GEditSize())
	retEdit:setRect(rcRect)
	function tick(dt)
		CCLuaLog("===========tick============")
		if funTimer then
			local text = retEdit:getText()
			funTimer(text)
		end
	end
	--local nTimerID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0.5, false)

	--清除Edit　Romove后请将对应的Edit变量赋为０
	function retEdit:remove()
		mRect = nil
		
		self:hiddenTextPanel()
		self:release()
		self:delete()
		if nTimerID then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(nTimerID)
		end
	end
	
	return retEdit
end

function GEditSize()
	local nSize = SY(12)
	local nType = GetPlatformType()
	if nType == ScutUtility.ptANDROID  or nType == ScutUtility.ptwindowsPhone7 then
		-- nSize = SY(11)
		if WINSIZE.width > 960 or WINSIZE.height > 640 then
			local x = 960/WINSIZE.width
			local y = 640/WINSIZE.height
			local scale = x
			if y < x then
				scale = x
			end
			
			nSize = SY(11*scale)
		else
			-- TODO local scale = UI.UIScene:getContentScaleFactor()
			local scale = 1
			nSize = SY(11*scale)
		end
	end
	return nSize
end

local function newScale9Sprite(filename, x, y, size)
    local t = type(filename)
    if t ~= "string" then
        return
    end

    local sprite = CCScale9Sprite:create(filename)

    if x and y then sprite:setPosition(x, y) end
    if size then sprite:setContentSize(size) end
   
    return sprite
end

--[[
setText
getText
setMaxLength
]]
function create( x, y, size, bPwd, textColor3, img, priority)
	local retEdit = CCEditBox:create(size, newScale9Sprite(img, x, y, size))
	textColor3 = textColor3 or ccc3(0, 0, 0)
	retEdit:setFontColor(textColor3)
	retEdit:setPosition(CCPoint(x, y))
	retEdit:setMaxLength(150)
	retEdit:setTouchPriority(priority or -999999999)
	if bPwd == true then
		retEdit:setInputFlag(0)--设置为密码
	end
	
	function retEdit:getEditText()
		if retEdit:getText() == "" then
			return ""
		end
		
		if retEdit:getMaxLength() < string.len(retEdit:getText()) then
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			Toast.show(runningScene, GameString.STR_TOOLONG)
		end
	end
	
	-- 提高优先级为最高
	-- local pTouchDispatcher=CCDirector:sharedDirector():getTouchDispatcher()
	-- pTouchDispatcher:removeDelegate(retEdit)
	-- pTouchDispatcher:addTargetedDelegate(retEdit,-130,true)
	return retEdit
end


