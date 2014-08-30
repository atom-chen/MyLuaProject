module("Button", package.seeall)
--function func(tag)
function new(strNor, strDown, strDisable, func)
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

	menuItem = CCMenuItemSprite:create(norSprite, selSprite, disSprite)

	local userData = nil
	local userfunc = func
	local labText
	local function callback(tag)
		userfunc(tag, userData)
	end
	
	menuItem:registerScriptTapHandler(callback)
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
			size = FONT_SIZE_L
		end
		if labText then
			menuItem:removeChild(labText, true)
			labText = nil
		end
		labText = CCLabelTTF:create(strText, font, size)
		menuItem:addChild(labText, 0)
		if textpt ~= nil then
			labText:setPosition(textpt)
		else
			labText:setPosition(ccp(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2))
		end
	end

	function menu:addSubChild(node)
		node:setAnchorPoint(ccp(0, 0))
		menuItem:addChild(node, 0)
		node:setPosition(ccp(menuItem:getContentSize().width/2 - node:getContentSize().width/2,
			menuItem:getContentSize().height/2 - node:getContentSize().height/2))
	end
	
	function menu:setTextColor(color)
		labText:setColor(color)
	end
	--设置按钮文字(图片)
	function menu:setImgText(strImgUrl)
		local spImg = CCSprite:create(strImgUrl)
		menuItem:addChild(spImg, 0)
		spImg:setPosition(ccp(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2))
	end

	return menu
end

--另一构造
function newFromSprite(norSprite, downSprite, disSprite, func)
	local menuItem = nil
	assert(norSprite ~= nil)
	local userData = nil
	local userfunc = func
	local function callback(tag)
		if userfunc ~= nil then
			userfunc(tag, userData)
		end
	end

	menuItem = CCMenuItemSprite:create(norSprite,downSprite, disSprite)
	menuItem:registerScriptTapHandler(callback)
	local menu = CCMenu:createWithItem(menuItem)
	menuItem:setAnchorPoint(ccp(0, 0))
	menuItem:setPosition(ccp(0, 0))
	menu:setContentSize(menuItem:getContentSize())

	function menu:setData(data)
		userData = data
	end
	
	function menu:getData()
		return userData
	end
	
	function menu:selected()
		menuItem:selected()
	end
	
	function menu:unselected()
		menuItem:unselected()
	end
	
	--获取当前的MenuItem
	function menu:getMenuItem()
		return menuItem
	end
	
	function menu:setTag(tag)
		menuItem:setTag(tag)
	end
	
	function menu:setEnabled(bEnable)
		menuItem:setEnabled(bEnable)
	end
	
	return menu
end

function newToggle(norItem, downItem, func)
	local toggleMenuItem = CCMenuItemToggle:create(norItem)
	toggleMenuItem:addSubItem(downItem)

	local userData = nil
	local userfunc = func
	local function callback(tag)
		userfunc(tag, userData)
	end
	toggleMenuItem:registerScriptTapHandler(callback)
	local menu = CCMenu:createWithItem(toggleMenuItem)
	menu:setContentSize(norItem:getContentSize())
	menuItem:setAnchorPoint(ccp(0, 0))
	menuItem:setPosition(ccp(0, 0))

	function menu:setData(data)
		userData = data
	end
	function menu:getData()
		return userData
	end
	function menu:getMenuItem()
		return menuItem
	end
	function menu:getSelectedIndex()
		return toggleMenuItem:getSelectedIndex()
	end
end

--放大按钮
function newZoomOut(strNor, func, scaleValue)
	local spriteNor = CCSprite:create(P(strNor))
	local spriteDown = CCSprite:create(P(strNor))
	local nScale = 1.1
	if scaleValue ~= nil then
		nScale = scaleValue
	end
	spriteDown:setScale(nScale)
	return newFromSprite(spriteNor, spriteDown, nil, func)
end

function newZoomOutSprite(norItem, downItem, disSprite, func, scaleValue)
	local nScale = 1.1
	if scaleValue ~= nil then
		nScale = scaleValue
	end
	downItem:setScale(nScale)
	return newFromSprite(spriteNor, spriteDown, disSprite, func)
end