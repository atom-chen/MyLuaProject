module("PressButton", package.seeall)

-- 新建一个长按按钮
-- func后的参数都可不填
-- reactionTime 长按反应时间 
-- setEffect 设置长按效果函数 (startEffect, endEffect)	含开始与结束
-- :setPressCallBack 设置长按中的回调函数
local mReactionTimer
local mLimitTime = 180			-- 超过这个时间强制结束
local mPressingTime = 0
function new(strNor, strDown, strDisable, func, reactionTime)
	local menuItem = nil
	local norSprite, selSprite, disSprite
	if strNor ~= nil then
		norSprite = CCSprite:create(P(strNor))
	end
	
	if strDown ~= nil then
		selSprite = CCSprite:create(P(strDown))
	end
	
	if strDisable ~= nil then
		disSprite = CCSprite:create(P(strDisable))
	end
	
	menuItem = MyMenuItemSprite:create(norSprite,selSprite, disSprite)
	local pushDownReactionTime = reactionTime or 0.5
	local pushDownTime = 0
	local pressLongerFunc
	local effect, effectRecover
	local nPressingTime = 0
	-- 长按回调
	function pressCallBack(item)
		local tag = item:getTag()
		-- 增加数量回调
		local function addCountCallBack()
			item:getIsOutTime()
			--item:runPressCallBack()
		end
	
		-- 反应时间回调
		local function reactionCallBack()
			pushDownTime = pushDownTime + 0.1
			if pushDownTime > pushDownReactionTime then
				if mReactionTimer then 
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(mReactionTimer)
					mReactionTimer = nil
					pushDownTime = 0
					
					mReactionTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(addCountCallBack, 0.05, false)
					item:runStartEffect()
					
				end
			end
			
		end
		
		-- 设置反应计时器
		if mReactionTimer == nil then
			mReactionTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(reactionCallBack, 0.1, false)
		end
		
		
	end
	
	-- 长按后弹起
	local function pressOver()
		if mReactionTimer then 
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(mReactionTimer)
			mReactionTimer = nil
			pushDownTime = 0
			mPressingTime = 0
			
			if effectRecover and type(effectRecover) == "function" then
				effectRecover()
			end
		end
		mPressingTime = 0
	end

	local userData = nil
	local userfunc = func
	local labText
	local function callback(tag)
		pressOver()
		CCLuaLog("PressOver")
		userfunc(tag, userData)
	end
	
	menuItem:registerScriptTapHandler(callback)
	menuItem:registerScriptHandlerForTouchBegin(PressButton.pressCallBack)
	local menu = CCMenu:createWithItem(menuItem)
	menu:setContentSize(menuItem:getContentSize())
	menuItem:setAnchorPoint(ccp(0, 0))
	menuItem:setPosition(ccp(0, 0))
	
	function menu:setData(data)
		userData = data
	end
	
	function menu:getData()
		return userData
	end
	
	--获取当前的MenuItem
	function menu:getMenuItem()
		return menuItem
	end
	
	function menu:setEnabled(bEnable)
		menuItem:setEnabled(bEnable)
	end

	--nor 0  sel=1 dis=2
	function menu:getSprite(nType)
		local ret = nil
		if nType == 0 then
			ret = norSprite
		elseif nType == 1 then
			ret = selSprite
		else
			ret = disSprite
		end
		return ret
	end

	function menu:selected()
		menuItem:selected()
	end

	function menu:unselected()
		menuItem:unselected()
	end

	--set tag
	function menu:setTag(tag)
		menuItem:setTag(tag)
	end
	
	--设置按钮文字
	function menu:setText(strText, font_name, font_size, textpt)
		local font = font_name
		local size = font_size
		if font == nil then
			font = FONT_NAME
		end
		if size == nil then
			size = FONT_SM_SIZE
		end
		if labText then
			menuItem:removeChild(labText, true)
			labText = nil
		end
		labText = CCLabelTTF:create(strText, font, size)
		menuItem:addChild(labText,0)
		if textpt ~= nil then
			labText:setPosition(textpt)
		else
			labText:setPosition(ccp(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2))
		end
	end

	function menu:addSubChild(node)
		node:setAnchorPoint(ccp(0,0))
		menuItem:addChild(node,0)
		node:setPosition(ccp(menuItem:getContentSize().width/2 - node:getContentSize().width/2,
			menuItem:getContentSize().height/2 - node:getContentSize().height/2))
	end
	
	function menu:setTextColor(color)
		labText:setColor(color)
	end
	--设置按钮文字(图片)
	function menu:setImgText(strImgUrl)
		local spImg = CCSprite:create(strImgUrl)
		menuItem:addChild(spImg,0)
		spImg:setPosition(ccp(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2))
	end
	
	function menuItem:runPressCallBack(tag, userData)
		
	end
	-- 设置长按中的回调函数
	function menu:setPressCallBack(callback)
		pressLongerFunc = callback
		
		function menuItem:runPressCallBack()
			if pressLongerFunc and type(pressLongerFunc) == "function" then
				pressLongerFunc(menuItem:getTag(), menu:getData())
			end
		end
		--tPressLongerFunc[menuItem:getTag()] = pressLongerFunc		-- 保存 下策！
	end
	
	function menuItem:runStartEffect()
		
	end
	-- 设置长按中的效果函数
	function menu:setEffect(startEffect, endEffect)
		effect = startEffect
		effectRecover = endEffect
		
		function menuItem:runStartEffect()
			if startEffect and type(startEffect) == "function" then
				startEffect()
			end
		end
	end
	
	-- 防止超时
	function menuItem:getIsOutTime()
		mPressingTime = mPressingTime + 0.5
		if mPressingTime > mLimitTime then
			mPressingTime = 0
			--pressOver()
			callback(menuItem:getTag(), userData)
		else
			menuItem:runPressCallBack(menuItem:getTag(), userData)
		end
	end
	
	-- 强制停止计时器
	function menu:pressOver()
		if mReactionTimer then
			callback(menuItem:getTag(), userData)
		end
	end
	
	-- 强制停止计时器
	function menu:stopTimer()
		if mReactionTimer then
			pressOver()
		end
	end
	
	return menu
end

-- 直接传控件 功能如上
function newFromSprite(norSprite, downSprite, disSprite, func, reactionTime)
	local menuItem = nil
	assert(norSprite ~= nil)


	menuItem = MyMenuItemSprite:create(norSprite,downSprite, disSprite)
	local pushDownReactionTime = reactionTime or 0.5
	local pushDownTime = 0
	local pressLongerFunc
	local effect, effectRecover
	local nPressingTime = 0
	-- 长按回调
	function pressCallBackSprite(item)
		local tag = item:getTag()
		-- 增加数量回调
		local function addCountCallBack()
			item:getIsOutTime()
			--item:runPressCallBack()
		end
	
		-- 反应时间回调
		local function reactionCallBack()
			pushDownTime = pushDownTime + 0.1
			if pushDownTime > pushDownReactionTime then
				if mReactionTimer then 
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(mReactionTimer)
					mReactionTimer = nil
					pushDownTime = 0
					
					mReactionTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(addCountCallBack, 0.05, false)
					item:runStartEffect()
					
				end
			end
			
		end
		
		-- 设置反应计时器
		if mReactionTimer == nil then
			mReactionTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(reactionCallBack, 0.1, false)
		end
		
		
	end
	
	-- 长按后弹起
	local function pressOver()
		if mReactionTimer then 
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(mReactionTimer)
			mReactionTimer = nil
			pushDownTime = 0
			mPressingTime = 0
			
			if effectRecover and type(effectRecover) == "function" then
				effectRecover()
			end
		end
		mPressingTime = 0
	end

	local userData = nil
	local userfunc = func
	local labText
	local function callback(tag)
		pressOver()
		CCLuaLog("PressOver")
		userfunc(tag, userData)
	end
	
	menuItem:registerScriptTapHandler(callback)
	menuItem:registerScriptHandlerForTouchBegin(PressButton.pressCallBackSprite)
	local menu = CCMenu:createWithItem(menuItem)
	menu:setContentSize(menuItem:getContentSize())
	menuItem:setAnchorPoint(ccp(0, 0))
	menuItem:setPosition(ccp(0, 0))
	
	function menu:setData(data)
		userData = data
	end
	
	function menu:getData()
		return userData
	end
	
	--获取当前的MenuItem
	function menu:getMenuItem()
		return menuItem
	end
	
	function menu:setEnabled(bEnable)
		menuItem:setEnabled(bEnable)
	end

	--nor 0  sel=1 dis=2
	function menu:getSprite(nType)
		local ret = nil
		if nType == 0 then
			ret = norSprite
		elseif nType == 1 then
			ret = selSprite
		else
			ret = disSprite
		end
		return ret
	end

	function menu:selected()
		menuItem:selected()
	end

	function menu:unselected()
		menuItem:unselected()
	end

	--set tag
	function menu:setTag(tag)
		menuItem:setTag(tag)
	end
	
	--设置按钮文字
	function menu:setText(strText, font_name, font_size, textpt)
		local font = font_name
		local size = font_size
		if font == nil then
			font = FONT_NAME
		end
		if size == nil then
			size = FONT_SM_SIZE
		end
		if labText then
			menuItem:removeChild(labText, true)
			labText = nil
		end
		labText = CCLabelTTF:create(strText, font, size)
		menuItem:addChild(labText,0)
		if textpt ~= nil then
			labText:setPosition(textpt)
		else
			labText:setPosition(ccp(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2))
		end
	end

	function menu:addSubChild(node)
		node:setAnchorPoint(ccp(0,0))
		menuItem:addChild(node,0)
		node:setPosition(ccp(menuItem:getContentSize().width/2 - node:getContentSize().width/2,
			menuItem:getContentSize().height/2 - node:getContentSize().height/2))
	end
	
	function menu:setTextColor(color)
		labText:setColor(color)
	end
	--设置按钮文字(图片)
	function menu:setImgText(strImgUrl)
		local spImg = CCSprite:create(strImgUrl)
		menuItem:addChild(spImg,0)
		spImg:setPosition(ccp(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2))
	end
	
	function menuItem:runPressCallBack(tag, userData)
		
	end
	-- 设置长按中的回调函数
	function menu:setPressCallBack(callback)
		pressLongerFunc = callback
		
		function menuItem:runPressCallBack()
			if pressLongerFunc and type(pressLongerFunc) == "function" then
				pressLongerFunc(menuItem:getTag(), menu:getData())
			end
		end
		--tPressLongerFunc[menuItem:getTag()] = pressLongerFunc		-- 保存 下策！
	end
	
	function menuItem:runStartEffect()
		
	end
	-- 设置长按中的效果函数
	function menu:setEffect(startEffect, endEffect)
		effect = startEffect
		effectRecover = endEffect
		
		function menuItem:runStartEffect()
			if startEffect and type(startEffect) == "function" then
				startEffect()
			end
		end
	end
	
	-- 防止超时
	function menuItem:getIsOutTime()
		mPressingTime = mPressingTime + 0.5
		if mPressingTime > mLimitTime then
			mPressingTime = 0
			--pressOver()
			callback(menuItem:getTag(), userData)
		else
			menuItem:runPressCallBack(menuItem:getTag(), userData)
		end
	end
	
	-- 强制弹起
	function menu:pressOver()
		if mReactionTimer then
			callback(menuItem:getTag(), userData)
		end
	end
	
	-- 强制停止计时器
	function menu:stopTimer()
		if mReactionTimer then
			pressOver()
		end
	end
	
	return menu
end

-- 特殊处理 用表保存item
local tMenu = {}
function newFromSpriteSpecial(norSprite, downSprite, disSprite, func, reactionTime)
	local menuItem = nil
	assert(norSprite ~= nil)


	menuItem = MyMenuItemSprite:create(norSprite,downSprite, disSprite)
	local pushDownReactionTime = reactionTime or 0.5
	local pushDownTime = 0
	local pressLongerFunc
	local effect, effectRecover
	local nPressingTime = 0
	-- 长按回调
	function pressCallBackSpriteSpecial(p1, p2)

		local tag = p2:getTag()
		--local tag = 1
		-- 增加数量回调
		local function addCountCallBack()
			tMenu[tag]:getMenuItem():getIsOutTime()
			--tMenu[tag]:getMenuItem():runPressCallBack()
		end
	
		-- 反应时间回调
		local function reactionCallBack()
			pushDownTime = pushDownTime + 0.1
			if pushDownTime > pushDownReactionTime then
				if mReactionTimer then 
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(mReactionTimer)
					mReactionTimer = nil
					pushDownTime = 0
					
					mReactionTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(addCountCallBack, 0.05, false)
					
					tMenu[tag]:getMenuItem():runStartEffect()
					
				end
			end
			
		end
		
		-- 设置反应计时器
		if mReactionTimer == nil then
			mReactionTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(reactionCallBack, 0.1, false)
		end
		
		
	end
	
	-- 长按后弹起
	local function pressOver()
		if mReactionTimer then 
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(mReactionTimer)
			mReactionTimer = nil
			pushDownTime = 0
			
			if effectRecover and type(effectRecover) == "function" then
				effectRecover()
			end
		end
		mPressingTime = 0
	end

	local userData = nil
	local userfunc = func
	local labText
	local function callback(tag)
		pressOver()
		CCLuaLog("pressOver")
		userfunc(tag, userData)
	end
	
	menuItem:registerScriptTapHandler(callback)
	menuItem:registerScriptHandlerForTouchBegin(PressButton.pressCallBackSpriteSpecial)
	local menu = CCMenu:createWithItem(menuItem)
	menu:setContentSize(menuItem:getContentSize())
	menuItem:setAnchorPoint(ccp(0, 0))
	menuItem:setPosition(ccp(0, 0))
	
	function menu:setData(data)
		userData = data
	end
	
	function menu:getData()
		return userData
	end
	
	--获取当前的MenuItem
	function menu:getMenuItem()
		return menuItem
	end
	
	function menu:setEnabled(bEnable)
		menuItem:setEnabled(bEnable)
	end

	--nor 0  sel=1 dis=2
	function menu:getSprite(nType)
		local ret = nil
		if nType == 0 then
			ret = norSprite
		elseif nType == 1 then
			ret = selSprite
		else
			ret = disSprite
		end
		return ret
	end

	function menu:selected()
		menuItem:selected()
	end

	function menu:unselected()
		menuItem:unselected()
	end

	--set tag
	function menu:setTag(tag)
		tMenu[tag] = tMenu[menuItem:getTag()]
		menuItem:setTag(tag)
	end
	
	--设置按钮文字
	function menu:setText(strText, font_name, font_size, textpt)
		local font = font_name
		local size = font_size
		if font == nil then
			font = FONT_NAME
		end
		if size == nil then
			size = FONT_SM_SIZE
		end
		if labText then
			menuItem:removeChild(labText, true)
			labText = nil
		end
		labText = CCLabelTTF:create(strText, font, size)
		menuItem:addChild(labText,0)
		if textpt ~= nil then
			labText:setPosition(textpt)
		else
			labText:setPosition(ccp(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2))
		end
	end

	function menu:addSubChild(node)
		node:setAnchorPoint(ccp(0,0))
		menuItem:addChild(node,0)
		node:setPosition(ccp(menuItem:getContentSize().width/2 - node:getContentSize().width/2,
			menuItem:getContentSize().height/2 - node:getContentSize().height/2))
	end
	
	function menu:setTextColor(color)
		labText:setColor(color)
	end
	--设置按钮文字(图片)
	function menu:setImgText(strImgUrl)
		local spImg = CCSprite:create(strImgUrl)
		menuItem:addChild(spImg,0)
		spImg:setPosition(ccp(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2))
	end
	
	function menuItem:runPressCallBack()
		
	end
	-- 设置长按中的回调函数
	function menu:setPressCallBack(callback)
		pressLongerFunc = callback
		
		function menuItem:runPressCallBack()
			if pressLongerFunc and type(pressLongerFunc) == "function" then
				pressLongerFunc(menuItem:getTag(), menu:getData())
			end
		end
		tMenu[menuItem:getTag()] = menu		-- 保存 下策！
	end
	
	function menuItem:runStartEffect()
		
	end
	-- 设置长按中的效果函数
	function menu:setEffect(startEffect, endEffect)
		effect = startEffect
		effectRecover = endEffect
		
		function menuItem:runStartEffect()
			if startEffect and type(startEffect) == "function" then
				startEffect()
			end
		end
		tMenu[menuItem:getTag()] = menu		-- 保存 下策！
	end
	
	-- 防止超时
	function menuItem:getIsOutTime()
		mPressingTime = mPressingTime + 0.5
		if mPressingTime > mLimitTime then
			mPressingTime = 0
			--pressOver()
			callback(menuItem:getTag(), userData)
		else
			menuItem:runPressCallBack()
		end
	end
	
	-- 强制弹起
	function menu:pressOver()
		if mReactionTimer then
			callback(menuItem:getTag(), userData)
		end
	end
	
	-- 强制停止计时器
	function menu:stopTimer()
		if mReactionTimer then
			pressOver()
		end
	end
	
	
	return menu
end

-- 强制停止计时器
function stopTimer()
	if mReactionTimer then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(mReactionTimer)
		mReactionTimer = nil
	end
end