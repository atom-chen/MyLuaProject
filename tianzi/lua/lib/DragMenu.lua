--
--

DragMenu = {
	_layer = nil,			-- 
	_items = nil,			-- 所有的按钮集合
	_selectedItem = nil,-- 第一个选中的按钮
	_changeItem = nil,	-- 要被交换的按钮
	_state = nil,			-- 状态：0、1
	_parent = nil,			-- layer的父节点
	_posStart = nil,		-- 第一个被选中的item的起始位置
	_callBack = nil,		-- 交换时回调
	_isHold = nil,			-- 是否在交换按钮的时候停住，不做交换的action
	stateEnum = {kCCMenuStateWaiting =0, kCCMenuStateTrackingTouch =1},
	_action = nil,			-- 点击时所触发的事件
	_startPos	= nil,		-- 第一次鼠标按下在layer中的位置，用于处理点击时间
	mousePos	= nil,		-- 第一次鼠标按下在menuitem中的位置，用于控制鼠标在按钮中的位置
	_touchEndCallback = nil,-- 放开后回调，优先级低于交换时回调
}

-------------------------------------------------------------公用-------------------------------------------------------------

-- 创建实例
-- bIsPriority 是否最优先触发 在弹窗上拖动时使用
function DragMenu:new(onTouch, bIsPriority)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	-- local touchBegin, touchMoved, touchEnd, onExit, onEnter, actionCallback = DragMenu.generatEventString(module, point)

	local layer = CCLayer:create()
	layer:setTouchEnabled(true)
	layer:setContentSize(WINSIZE)
	if bIsPriority then
		layer:registerScriptTouchHandler(onTouch,false,-999999999,true)
	else
		layer:registerScriptTouchHandler(onTouch)
	end
	layer:setTouchEnabled(true)
	
	instance._layer = layer
	instance._items = {}
	instance._actionCallback = DragMenu.actionCallback
	instance._state = DragMenu.stateEnum.kCCMenuStateWaiting
	return  instance
end

function DragMenu:menuWithItem(menuItem)
	self:menuWithItems(menuItem)
end

function DragMenu:menuWithItems(menuItem, ... )
	local arg = {...} 
	self:addChild(menuItem, 0)
	if #arg > 0 then
		for i,item in pairs(arg) do
			if type(item) == "userdata" then		-- menuItem
				self:addChild(item, 0)
			end
		end
	end
	self._selectedItem = nil
	self._state = DragMenu.stateEnum.kCCMenuStateWaiting
end

-- 交换时回调
function DragMenu:setCallback(callback)
	self._callBack = callback
end

-- 放开后回调，优先级低于交换时回调
function DragMenu:setTouchEndCallback(callback)
	self._touchEndCallback = callback
end

-- 是否接收触摸事件
function DragMenu:setIsTouchEnabled(param)
	self._layer:setIsTouchEnabled(param)
end

function DragMenu:addChild(child, z, tag)
	assert(child, "child is nil")
	self._items[#self._items + 1] = child
	
	if z and tag then
		self._layer:addChild(child, z, tag)
	elseif z then
		self._layer:addChild(child, z)
	else
		self._layer:addChild(child, 0)
	end
	if self.drag then			-- 修改BUG：将魂自己删除、添加item时状态未清
		self.drag = nil
	end
end

function DragMenu:addto(parent, param1, param2)
	if type(param1) == "userdata" then
		parent:addChildItem(self._layer, param1)
	else
		if param2 then
			parent:addChild(self._layer, param1, param2)
		elseif param1 then
			parent:addChild(self._layer, param1)
		else
			parent:addChild(self._layer, 0)
		end
	end
	self._parent = parent
end

function DragMenu:setContentSize(size)
	self._layer:setContentSize(size)
end

function DragMenu:getParent()
	return self._parent
end

function DragMenu:setPosition(point)
	self._layer:setPosition(point)
end

function DragMenu:getPosition()
	return ccp(self._layer:getPosition())
end

function DragMenu:getContentSize()
	return self._layer:getContentSize()
end

function DragMenu:setAnchorPoint(point)
	self._layer:setAnchorPoint(point)
end

function DragMenu:setVisible(bIsVisible)
	self._layer:setVisible(bIsVisible)
end

function DragMenu:isVisible()
	return self._layer:isVisible()
end

function DragMenu:getStartPos()
	return self._posStart
end

function DragMenu:setHold(param)
	self._isHold = param
end

function DragMenu:clear()
	self._layer:removeAllChildrenWithCleanup (true)
	self._items = {}
	self._selectedItem = nil
	self._changeItem = nil
	self._state = DragMenu.stateEnum.kCCMenuStateWaiting
	self._posStart = nil
	self.drag = nil
end

function DragMenu:removeChild(item, ... )
	local bFalg = false
	for i,v in pairs(self._items) do
		if v == item then
			table.remove(self._items, i)
			bFalg = true
			break
		end
	end
	if bFalg then
		self._layer:removeChild(item,  ... )
		self._state = DragMenu.stateEnum.kCCMenuStateWaiting
		if self._selectedItem == item then
			self._selectedItem = nil
		elseif self._changeItem == item then
			self._changeItem = nil
		end
	end	
end

-- 设置不能拖动
function DragMenu:setSilence(...)
	local arg = {...} 
	for i,item in pairs(arg) do
		if type(item) == "userdata" then		-- menuItem
			item._silence = true
		end
	end
end

-- 设置可拖动
function DragMenu:setUnSilence(...)
	for i,item in pairs(arg) do
		if type(item) == "userdata" then		-- menuItem
			item._silence = false
		end
	end
end

-- 做返回动画 hold类型的才能调用此方法
function DragMenu:itemGoBack()
	if self._selectedItem == nil or self._selectedItem._silence then
		return
	end
	-- assert(self._isHold and self._state == DragMenu.stateEnum.kCCMenuStateTrackingTouch)
	local action = DragMenu.getMoveTo(self._posStart, self._actionCallback)
	self._selectedItem:runAction(action)
	self._selectedItem:unselected()
	self._selectedItem = nil
	self.drag = nil
end

-- 做交换动画 hold类型的才能调用此方法
function DragMenu:itemExchange(item1, item2)
	if item1 == nil or item1._silence then
		return
	end
	-- assert(self._isHold and self._state == DragMenu.stateEnum.kCCMenuStateTrackingTouch)
	
	local newPos = ccp(item2:getPosition())
	local action1 = DragMenu.getMoveTo(newPos)
	local action2 = DragMenu.getMoveTo(self._posStart)
	item1:runAction(action1)
	item2:runAction(action2)

	if self._changeItem then
		self._changeItem:unselected()
		self._changeItem = nil
	end
	self.drag = nil
end

-- 获取所有项目
function DragMenu:getAllItems()
	return self._items
end


function DragMenu:setClickEvent(action)
	self._action = action
end

-- 原来的onExit()显示调用
function DragMenu:release()
	self._selectedItem = nil
	self._changeItem = nil
	self._state = nil
	self._posStart = nil
end

-------------------------------------------------------------私有-------------------------------------------------------------

--function DragMenu:TouchBegan(touch)
function DragMenu:TouchBegan(x, y)
	if self._state ~= DragMenu.stateEnum.kCCMenuStateWaiting or not self:isVisible() then
		return false
	end
	local node = self._layer
	while node do
		if node:isVisible() == false then
			return false
		end
		node = node:getParent()
	end
	
	-- self._selectedItem = self:itemForTouch(touch)
	self._selectedItem = self:itemForTouch(x, y)
	if self._selectedItem then
		self._layer:reorderChild(self._selectedItem, 0)
		self._state = DragMenu.stateEnum.kCCMenuStateTrackingTouch
		self._selectedItem:selected()
		self._posStart = ccp(self._selectedItem:getPosition())
		return true
	end
	return false
end

-- function DragMenu:itemForTouch(touch, bHasSelected)
function DragMenu:itemForTouch(x, y, bHasSelected)
	local touchLocation = ccp(x, y)
	for i,menuItem in pairs(self._items) do
		if menuItem:isVisible() then
			local point = menuItem:getParent():convertToNodeSpace(touchLocation)
			local r = menuItem:rect()
			if bHasSelected then
				if menuItem ~= self._selectedItem and self:isBump(menuItem) then
					return menuItem
				end
			-- elseif not menuItem._silence and CCRect:CCRectContainsPoint(r, point) then
			-- elseif CCRect:CCRectContainsPoint(r, point) then
			elseif r:containsPoint(point) then
				self._startPos = point
				return menuItem
			end
		end
	end
	return nil
end

-- 当前按钮是否和所传按钮碰撞
function DragMenu:isBump(item)
	-- self.mousePos
	if self._selectedItem == nil then
	    return;
	end
	local pos = ccp(self._selectedItem:getPosition())
	local anchor = self._selectedItem:getAnchorPoint()
	local size = self._selectedItem:getContentSize()
	local t = {
		ccp(pos.x - anchor.x*size.width,  pos.y -  anchor.y*size.height),
		ccp(pos.x + (1- anchor.x)*size.width,  pos.y -  anchor.y*size.height),
		ccp(pos.x - anchor.x*size.width,  pos.y +  (1 - anchor.y)*size.height),
		ccp(pos.x + (1 - anchor.x)*size.width,  pos.y + (1- anchor.y)*size.height),
	}
	for i,point in pairs(t) do
		-- if CCRect:CCRectContainsPoint(item:rect(), point) then
		if item:rect():containsPoint(point) then
			return true
		end
	end
	return false
end

-- function DragMenu:TouchMoved(v)
function DragMenu:TouchMoved(x, y)
	-- local item2 = self:itemForTouch(v, true)
	local item2 = self:itemForTouch(x, y, true)
	if item2 then		-- 有新的menuItem
		if self._changeItem then
			if  self._changeItem ~= item2 then
				self._changeItem:unselected()
				self._changeItem = nil
				item2:selected()
				self._changeItem = item2
			end
		else
			item2:selected()
			self._changeItem = item2
		end
	elseif self._changeItem then
		self._changeItem:unselected()
		self._changeItem = nil
	elseif not self.drag then		-- 在原按钮上托
		-- local touchLocation =  v:locationInView(v:view() )
		local touchLocation = ccp(x, y)
		--touchLocation = CCDirector:sharedDirector():convertToGL(touchLocation)
		local curPos = self._layer:convertToNodeSpace(touchLocation)
		local distance = ccpDistance(self._startPos, curPos)
		if distance < 10 then
			self.drag = false
			return
		else
			self.drag = true
		end
	end

	if self._selectedItem._silence then
		return
	end
	
	assert(self._state == DragMenu.stateEnum.kCCMenuStateTrackingTouch, "[Menu ccTouchMoved] -- invalid state")

	local touchLocation = ccp(x, y)
	if self.mousePos == nil then
		self.mousePos = self._selectedItem:convertToNodeSpace(touchLocation)
	end

	local anchor = self._selectedItem:getAnchorPoint()
	local size = self._selectedItem:getContentSize()

	touchLocation.x = touchLocation.x - self.mousePos.x + anchor.x* size.width
	touchLocation.y = touchLocation.y - self.mousePos.y +anchor.y* size.height

	touchLocation = self._layer:convertToNodeSpace(touchLocation)
	self._selectedItem:setPosition(touchLocation)
	
end

-- function DragMenu:TouchEnd(touch)
function DragMenu:TouchEnd(x, y)
	self.mousePos = nil
	local item2 = self:itemForTouch(x, y, true)
	if item2 then
		if self._isHold then				-- 可静止
			if self._selectedItem then
				if  not self._changeItem then
					self._changeItem = item2
					item2:selected()
				end
				if self._callBack then
					self._callBack(self._selectedItem, item2)
					self:actionCallback()
					self._startPos = nil
				end
				
				return
			end
		end
		
		-- 交换
		local newPos = ccp(item2:getPosition())
		local action1 = DragMenu.getMoveTo(newPos, self._actionCallback)
		local action2 = DragMenu.getMoveTo(self._posStart)
		self._selectedItem:runAction(action1)
		item2:runAction(action2)
		if self._callBack then
			self._callBack(self._selectedItem, item2)
		end
		if  self._changeItem then
			self._changeItem:unselected()
			self._changeItem = nil
		end
		
	elseif self.drag then
		if self._touchEndCallback ~= nil then
			-- local touchLocation =  touch:locationInView(touch:view() )
			local touchLocation = ccp(x, y)
			--touchLocation = CCDirector:sharedDirector():convertToGL(touchLocation)
			local curPos = self._layer:convertToNodeSpace(touchLocation)
			self._touchEndCallback(self._selectedItem, curPos)
			
			return
		else
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			--Toast.show(runningScene, "1111")
			local action = DragMenu.getMoveTo(self._posStart, self._actionCallback)
			self._selectedItem:runAction(action)
		end
		
		self:actionCallback()
		self._startPos = nil
	else
		-- local touchLocation =  touch:locationInView(touch:view() )
		local touchLocation = ccp(x, y)
		--touchLocation = CCDirector:sharedDirector():convertToGL(touchLocation)
		local curPos = self._layer:convertToNodeSpace(touchLocation)
		local distance = ccpDistance(self._startPos, curPos)
		if distance < 10 then
		    if self._action then
			    self._action(self._selectedItem)
			end
		end
		self:actionCallback()
		self._startPos = nil
	end
	if self._selectedItem then
	    self._selectedItem:unselected()
	    self._selectedItem = nil
	end
	self.drag = nil
end

function DragMenu:actionCallback()
	self._state = DragMenu.stateEnum.kCCMenuStateWaiting
end

function DragMenu.generatEventString(module, point)

	local beginString = module .. ".TouchBegan"..point..  ' = function(v)\n return ' .. module.."."..point ..  ':TouchBegan(v)\n end\n'

	local moveString = module .. ".TouchMoved"..point..  ' = function(e)\n  ' .. module.."."..point ..  ':TouchMoved(e)\n end\n'

	local endString = module .. ".TouchEnd"..point..  ' = function(e)\n  ' .. module.."."..point ..  ':TouchEnd(e)\n end\n'
	
	local onExitString = module .. ".onExit"..point..  ' = function(e)\n  ' .. module.."."..point ..  ':onExit(e)\n end\n'
	
	local onEnterString = module .. ".onEnter"..point..  ' = function(e)\n  ' .. module.."."..point ..  ':onEnter(e)\n end\n'
	
	local onActionCallBack = module .. ".ActionCallBack"..point..  ' = function(e)\n  ' .. module.."."..point ..  ':actionCallback(e)\n end\n'
	
	local loadstr = beginString .. moveString .. endString .. onExitString .. onEnterString .. onActionCallBack
	local f = loadstring(loadstr)
	f()
	return  module .. ".TouchBegan"..point, module .. ".TouchMoved"..point, module .. ".TouchEnd"..point, 
		module .. ".onExit"..point, module .. ".onEnter"..point, module .. ".ActionCallBack"..point
end

function DragMenu.getMoveTo(pos, isCallback)
	local action = CCMoveTo:create(0.5 , pos)
	-- action = CCEaseOut:actionWithAction(action, 0)
	if isCallback then
		local function callback()
			DragMenu:actionCallback()
		end
		local fn = CCCallFunc:create(callback)
		action = CCSequence:createWithTwoActions( action , fn)
	end
	return action
end

