require("lib.ScutScene")
--所有的子窗口需要通过本模块创建
module("MSGBOX", package.seeall)
--根据标题创建一个对话框
--必需调用show/hide显示和隐藏
--[[
function _Layer:setCallBack(func)
function _Layer:setData(data)
function _Layer:getData()
function _Layer:getContentLayer()
]]
function new(strTitle, size)
	local _Layer = nil
	local titleHeight = Font.lineHeightOfFont(FONT_NAME, FONT_SIZE_M)*2
	local _Size = SZ(size.width + PX(5), size.height + titleHeight)
	local _lbTitle 	= nil
	local _CloseBtn = nil
	local _FunCallback 	= nil
	local _userData = nil
	local layer =  CCLayer:create()
	local norDown =  CCLayer:create()
	_Layer = layer
	
	local menuItem =  CCMenuItemSprite:create(norDown, nil)
	norDown:setAnchorPoint(ccp(0, 0))
	norDown:setPosition(ccp(0, 0))

	local menu =  CCMenu:createWithItem(menuItem)
	menuItem:setAnchorPoint(ccp(0, 0))
	menuItem:setPosition(ccp(0, 0))
	layer:addChild(menu, 0)
	menu:setPosition(ccp(0, 0))
	
	local bgLayer =  CCLayer:create()
	bgLayer:setContentSize(_Size)
	layer:addChild(bgLayer, 0)
	bgLayer:setPosition(ccp(layer:getContentSize().width/2 - _Size.width/2,
		layer:getContentSize().height/2 - _Size.height/2))
	local spriteBg =  CCScale9Sprite:create(P("dian9/showform2.9.png"))
	spriteBg:setContentSize(_Size)
	bgLayer:addChild(spriteBg, 0)
	spriteBg:setAnchorPoint(ccp(0, 0))
	spriteBg:setPosition(ccp(0, 0))
	
	local contentLayer =  CCLayer:create()
	--local contentLayer =  CCLayerColor:create( ccc4(200,0,0,200))
	contentLayer:setContentSize(SZ(_Size.width - PX(5), _Size.height - titleHeight))
	bgLayer:addChild(contentLayer, 0)
	contentLayer:setPosition(ccp(PX(5/2), PY(5/2)))
	
	if strTitle ~= nil then
		local lbTitle =  CCLabelTTF:create(strTitle, FONT_NAME, FONT_SIZE_M)
		lbTitle:setPosition(ccp(_Size.width/2, _Size.height - titleHeight/2))
		bgLayer:addChild(lbTitle, 0)
		_lbTitle = lbTitle
		
		local line =  CCSprite:create(P("form/linebox.png"))
		line:setScaleX((_Size.width - PX(10)) / line:getContentSize().width)
		bgLayer:addChild(line, 0)
		line:setPosition(ccp(_Size.width/2, contentLayer:getPositionX() + size.height))
	end
	
	function _Layer:getBgLayer()
		return bgLayer
	end
	
	function _Layer:hide()
		BackKeyManager.removeChildWin(_Layer)
		
		if _Layer ~= nil then
			_Layer:getParent():removeChild(_Layer, true)
			_Layer 	= nil
			_CloseBtn 	= nil
			-- 释放内存
			 CCTextureCache:sharedTextureCache():removeUnusedTextures()
		end
		
		if _FunCallback ~= nil then
			_FunCallback(tag, _userData)
			_FunCallback = nil
		end
		
	end
	
	local function close()
		_Layer:hide()
	end
	
	--关闭按钮
	local norSprite =  CCSprite:create(P("button/boxclose_nor.png"))
	local norLayer =  CCLayer:create()
	norLayer:addChild(norSprite, 0)
	norLayer:setContentSize(norSprite:getContentSize())
	norSprite:setPosition(ccp(norLayer:getContentSize().width/2,
		norLayer:getContentSize().height/2))
	
	local downSprite =  CCSprite:create(P("button/boxclose_sel.png"))
	local downLayer =  CCLayer:create()
	downLayer:addChild(downSprite, 0)
	downLayer:setContentSize(downSprite:getContentSize())
	downSprite:setPosition(ccp(downLayer:getContentSize().width/2,
		downLayer:getContentSize().height/2))
	downLayer:setScale(1.1)
	
	btnClose = Button.newFromSprite(norLayer, downLayer, nil, close)
	bgLayer:addChild(btnClose, 0)
	btnClose:setPosition(ccp(_Size.width - btnClose:getContentSize().width*0.6, 
		_Size.height - btnClose:getContentSize().height*0.7))

	function _Layer:setTitle(str)
		if _lbTitle then
			_lbTitle:setString(str);
		end
	end

	function _Layer:setCallBack(func)
		_FunCallback = func
	end
	
	function _Layer:setData(data)
		_userData = data
	end

	function _Layer:getData()
		return _userData
	end
	
	function _Layer:getContentLayer()
		return contentLayer
	end

	function _Layer:show(parent,z)
		if z then
			parent:addChild(_Layer, z)
		else
			parent:addChild(_Layer, 0)
		end
		_Layer:setPosition(ccp(0, 0))
	end

	function _Layer:removeChild(child, clearUp)
		if clearUp == nil then
			clearUp = true
		end
		self:removeChild(child, clearUp)
	end
	
	-- 增加一个隐藏关闭按钮
	function _Layer:hideCloseButton()
		if btnClose then
			btnClose:setVisible(false)
			btnClose:setEnabled(false)
		end
	end

	BackKeyManager.addChildWin(layer, close)

	return _Layer
end

-- 新增 可设置背景 关闭按钮
-- 标题, 大小, 背景地址, 关闭按钮正常, 关闭按钮选中, 关闭回调函数
function newBg(strTitle, size, strBoxBg, strCloseNor, strCloseSel, closeFunc)
	local _Layer 	= nil	
	local _Size 	= SZ(size.width + PX(10), size.height + PY(26))
	if strTitle == nil then
		--_Size = SZ(size.width + PX(5), size.height + PY(5))
	end
	local _lbTitle 	= nil
	local _CloseBtn = nil
	local _FunCallback 	= nil
	local _userData = nil
	local layer =  CCLayer:create() --
	local norDown =  CCLayer:create()
	_Layer = layer
	
	local menuItem =  CCMenuItemSprite:create(norDown, nil)
	norDown:setAnchorPoint(ccp(0, 0))
	norDown:setPosition(ccp(0, 0))

	local menu =  CCMenu:createWithItem(menuItem)
	menuItem:setAnchorPoint(ccp(0, 0))
	menuItem:setPosition(ccp(0, 0))
	layer:addChild(menu, 0)
	menu:setPosition(ccp(0, 0))
	
	local bgLayer =  CCLayer:create()
	bgLayer:setContentSize(_Size)
	layer:addChild(bgLayer,0)
	bgLayer:setPosition(ccp(layer:getContentSize().width/2- _Size.width/2,
		layer:getContentSize().height/2 - _Size.height/2))
	local spriteBg  =  CCScale9Sprite:create(P(strBoxBg or "dian9/showform2.9.png"))
	spriteBg:setContentSize(_Size)
	bgLayer:addChild(spriteBg, 0)
	spriteBg:setAnchorPoint(ccp(0, 0))
	spriteBg:setPosition(ccp(0,0))

	local contentLayer =  CCLayer:create()
	contentLayer:setContentSize(SZ(_Size.width - PX(10), _Size.height - PY(26)))
	bgLayer:addChild(contentLayer, 0)
	contentLayer:setPosition(ccp(SX(5), SY(4)))
	
	if strTitle ~= nil then
		local lbTitle =  CCLabelTTF:create(strTitle, FONT_NAME, FONT_SIZE_M)
		lbTitle:setPosition(ccp(bgLayer:getContentSize().width/2, 
			bgLayer:getContentSize().height - PY(10)))
		bgLayer:addChild(lbTitle, 0)
		_lbTitle = lbTitle
	end
	function _Layer:getBgLayer()
		return bgLayer
	end
	function _Layer:hide()
		if closeFunc ~= nil then
			closeFunc()	-- 关闭回调函数
		end
		
		BackKeyManager.removeChildWin(_Layer)
		if _Layer ~= nil then
			_Layer:getParent():removeChild(_Layer, true)
			_Layer 	= nil
			_CloseBtn 	= nil
		end
		if _FunCallback ~= nil then
			_FunCallback(tag, _userData)
			_FunCallback = nil
		end
	end
	
	local function close()
		_Layer:hide()
	end
	
	--关闭按钮
	local norSprite =  CCSprite:create(P(strCloseNor or "button/boxclose_nor.png"))
	local norLayer =  CCLayer:create()
	norLayer:addChild(norSprite, 0)
	norLayer:setContentSize(SZ(PX(66/2), PY(66/2)))
	norSprite:setAnchorPoint(ccp(1,1))
	norSprite:setPosition(ccp(norLayer:getContentSize().width, norLayer:getContentSize().height - PY(2)))
	local downSprite =  CCSprite:create(P(strCloseSel or "button/boxclose_sel.png"))
	downSprite:setAnchorPoint(ccp(1,1))
	local downLayer =  CCLayer:create()
	downLayer:addChild(downSprite, 0)
	downLayer:setContentSize(SZ(PX(66/2), PY(66/2)))
	downSprite:setPosition(ccp(downLayer:getContentSize().width, downLayer:getContentSize().height - PY(2)))
	downLayer:setScale(1.1)
	btnClose = Button.newFromSprite(norLayer, downLayer, nil, close)
	bgLayer:addChild(btnClose, 0)
	if strCloseNor then
		btnClose:setPosition(ccp(_Size.width - btnClose:getContentSize().width - PX(2), 
		_Size.height - btnClose:getContentSize().height))
	else
		btnClose:setPosition(ccp(_Size.width - btnClose:getContentSize().width*0.6, 
		_Size.height - btnClose:getContentSize().height*0.7))
	end
		


	function _Layer:setTitle(str)
		if _lbTitle then
			_lbTitle:setString(str);
		end
	end

	---
	function _Layer:setCallBack(func)
		_FunCallback = func
	end
	function _Layer:setData(data)
		_userData = data
	end

	function _Layer:getData()
		return _userData
	end
	function _Layer:getContentLayer()
		return contentLayer
	end

	function _Layer:show(parent,z)
		if z then
			parent:addChild(_Layer, z)
		else
			parent:addChild(_Layer, 0)
		end
		_Layer:setPosition(ccp(0, 0))
	end

	function _Layer:removeChild(child,clearUp)
		if clearUp== nil then
			clearUp=true
		end
		self:removeChild(child, clearUp)
	end
	
	-- 增加一个隐藏关闭按钮
	function _Layer:hideCloseButton()
		btnClose:setVisible(false)
		btnClose:setEnabled(false)
	end
	
	BackKeyManager.addChildWin(layer, close)

	return _Layer
end