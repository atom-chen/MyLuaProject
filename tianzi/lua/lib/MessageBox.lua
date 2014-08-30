require("lib.BackKeyManager")
module("MessageBox", package.seeall)
--[[
function _Layer:setData(data)
function _Layer:getData()
function _Layer:show(parent,z)
]]
--callBack 0为确定　１为取消
--根据标题创建一个对话框
function new(strContent,nType, strOk, strCancel, callBack)
	local _Layer 			= nil
    local _lbContent      = nil	
	local _buttonOK 		= nil
	local _buttonCanel    = nil
	local _UserData	 	= nil
	local _FunCallback = callBack
	--按钮类型
	local _MB_OK 		   = 1
	local _MB_OK_CANCEL   = 2

	local layer = nil
	local contentLayer = nil
	layer =  CCLayer:create() --
	_Layer = layer
	
	
	--隐藏
	local function hide(tag)
		BackKeyManager.removeChildWin(_Layer)
		if _Layer ~= nil then
			_Layer:getParent():removeChild(_Layer, true)
			_Layer = nil
		end
		if _FunCallback ~= nil then
			_FunCallback(tag, _UserData)
			_FunCallback = nil
		end
	end
	
	function _Layer:setData(data)
		_UserData = data
	end
    
	function _Layer:getData()
		return _UserData
	end
	
	function _Layer:show(parent,z)
		if z then
			parent:addChild(_Layer, z)
		else
			parent:addChild(_Layer, 0)
		end
		_Layer:setPosition(ccp(0, 0))
		BackKeyManager.addChildWin(layer, hide)
	end

	function _Layer:getContentLayer()
		return contentLayer
	end
	
	local norDown =  CCLayer:create()
	
	local menuItem =  CCMenuItemSprite:create(norDown, nil)
	norDown:setAnchorPoint(ccp(0, 0))
	norDown:setPosition(ccp(0, 0))

	local menu =  CCMenu:createWithItem(menuItem)
	menuItem:setAnchorPoint(ccp(0, 0))
	menuItem:setPosition(ccp(0, 0))
	layer:addChild(menu, 0)
	menu:setPosition(ccp(0, 0))
	


	local size = SZ(SX(190), SY(120))
	contentLayer =  CCLayer:create()
	contentLayer:setContentSize(size)
	_Layer:addChild(contentLayer,0)
	contentLayer:setPosition(ccp(WINSIZE.width/2 - size.width/2,
		WINSIZE.height/2 - size.height/2))
    --背景
	local spriteBg  =  CCScale9Sprite:create(P("form/msgbox.9.png"))
	contentLayer:addChild(spriteBg, 0)
	spriteBg:setAnchorPoint(ccp(0, 0))
	spriteBg:setContentSize(size)

    --内容
	if strContent ~= nil then
		_lbContent =  CCLabelTTF:create(strContent, FONT_NAME, FONT_SIZE_M, SZ(size.width - SX(20), 0), kCCTextAlignmentCenter)
		_lbContent:setPosition(ccp(size.width/2, size.height - SY(35)))
		_lbContent:setAnchorPoint(ccp(0.5, 1))
		contentLayer:addChild(_lbContent,0)
	end
	
	local yPos = SY(15)
    --只包含确定按钮
	if nType == _MB_OK then
        _buttonOK = Button.new(P("button/button8045_nor.png"), 
			P("button/button8045_sel.png"),nil,hide)
        local xPos = contentLayer:getContentSize().width/2-_buttonOK:getContentSize().width/2
        _buttonOK:setPosition( CCPoint(xPos, yPos))
        contentLayer:addChild(_buttonOK,0)
        _buttonOK:getMenuItem():setTag(0)
        _buttonOK:setText(strOk, FONT_NAME, FONT_SM_SIZE)--文字
	end
	
	--确定 取消按钮
	if nType == _MB_OK_CANCEL then
        _buttonOK = Button.new(P("button/button8045_nor.png"), 
			P("button/button8045_sel.png"),nil,hide)
        
		local xPos = size.width - _buttonOK:getContentSize().width - SX(20)
        _buttonOK:setPosition( CCPoint(xPos, yPos))
        contentLayer:addChild(_buttonOK,0)
        _buttonOK:getMenuItem():setTag(0)
        _buttonOK:setText(strOk, FONT_NAME, FONT_SM_SIZE)--文字

        
        _buttonCanel = Button.new(P("button/button8045_nor.png"), 
			P("button/button8045_sel.png"),nil, hide)
        local xPos = SX(20)
        _buttonCanel:setPosition( CCPoint(xPos, yPos))
        contentLayer:addChild(_buttonCanel,0)
        _buttonCanel:getMenuItem():setTag(1)
        _buttonCanel:setText(strCancel, FONT_NAME, FONT_SM_SIZE)--文字
	end

	return _Layer
end

--callBack, tag: 0为确定 １为取消
--根据参数创建一个对话框
--内容，标题，窗口大小，是否要遮罩层，类型，按钮大小，背景图片，回调函数
--内容：可以是字符串，也可以是Layer。如果是字符串，则要保证显示出来的height不能超过可视窗口的height；如果内容是Layer，会自动启用滚屏效果。
--标题：如果有传入标题文本，则使用带有标题栏的外观，如果传入nil则使用无标题栏的外观（通过setTitle函数设置标题信息）
--类型：窗口形态 0-无按钮（默认） 1-只有一个按钮（确定），2-有两个按钮（确定，取消）
--按钮大小：有多种大小可供选择（1-8）
function newEx(strContent, strTitle, viewSize, bMark, nType, nButton, pImgBg, callBack)
	local _Layer 			= nil
	local _lbTitle			= nil
	local _lbContent	    = nil	
	local _buttonOK 		= nil
	local _buttonCancel  	= nil
	local _UserData	 		= nil
	local _FunCallback 		= callBack
	local _isLayer			= nil --内容是否为Layer，默认是字符串
	local _ScaleInOut		= nil --显示和退出是否要放大缩小
	local _Tag				= nil
	--按钮类型
	local _MB_OK 		   	= 1
	local _MB_OK_CANCEL   	= 2

	local contentLayer = nil
	local marginL = SX(5)	-- 窗口的左边距
	local marginR = SX(5)	-- 窗口的右边距
	local marginT = SY(22)	-- 窗口的上边距（标题栏位置）
	local marginB = SY(40)  -- 窗口的下边距（按钮位置）
	--创建显示Layer
	if bMark then
		_Layer =  CCLayerColor:create( ccc4(0,0,0,208))
	else
		_Layer =  CCLayer:create()
	end
	
	--初始化默认值
	strContent = strContent or ""
	nType = nType or 0 --默认没有按钮
	if nType ~= _MB_OK and nType ~= _MB_OK_CANCEL then
		nType = 0
	end
	strOk = strOk or GameString.STR_OK
	strCancel = strCancel or GameString.STR_CANCEL
	nButton = nButton or 1  --按钮大小，默认是80*38大小的按钮
	--计算窗口大小viewSize
	if type(strContent) == "string" or type(strContent) == "number" then
		viewSize = viewSize or SZ(SX(190), SY(120))
		if viewSize.width < 1 then
			viewSize.width = SX(190)
		end
		if viewSize.height < 1 then
			viewSize.height = SY(120)
		end
	else
		_isLayer = true
		if nType == 0 then	--没有按钮
			marginB = SY(2)
		end
		viewSize = viewSize or SZ(strContent:getContentSize().width+marginL+marginR, strContent:getContentSize().height+marginT+marginB) --增加左右边距，上下边距
		if viewSize.width < 1 then
			viewSize.width = strContent:getContentSize().width + marginL+marginR
		end
		if viewSize.height < 1 then
			viewSize.height = SY(150) + marginT+marginB
		end
	end
	--可视窗口大小不能超过屏幕的大小
	if viewSize.width > WINSIZE.width-SX(20) then
		viewSize.width = WINSIZE.width-SX(20)
	end
	if viewSize.height > WINSIZE.height-SY(10) then
		viewSize.height = WINSIZE.height-SY(10)
	end
	
	--清除并退出
	local function cleanUp()
		_Layer:removeAllChildrenWithCleanup(true)
		BackKeyManager.removeChildWin(_Layer)
		if _Layer ~= nil then
			_Layer:getParent():removeChild(_Layer, true)
			_Layer = nil
		end
		if _FunCallback ~= nil then
			_FunCallback(_Tag, _UserData)
			_FunCallback = nil
		end	
	end
	
	--隐藏
	local function hide(tag)
		_Tag = tag
		if _ScaleInOut then
			--逐渐缩小
			local scaleZero =  CCScaleTo:create(0.1, 0.3)
			local hideExit =  CCCallFunc:create(cleanUp)
			local action =  CCSequence:createWithTwoActions(scaleZero, hideExit)	
			_Layer:runAction(action)
		else
			cleanUp()
		end
	end
	
	--------------------------------------------------------------------------------------------------
	--设置标题（标题文字，字体，大小，颜色）
	function _Layer:setTitle(strInfo, fntName, fntSize, fntColor)
		fntName = fntName or FONT_NAME
		fntSize = fntSize or FONT_SIZE_M
		if _lbTitle then
			_lbTitle:getParent():removeChild(_lbTitle, true)
			_lbTitle = nil
		end
		_lbTitle =  CCLabelTTF:create(strInfo, fntName, fntSize)
		if fntColor then
			_lbTitle:setColor(fntColor)
		end
		_Layer:getContentLayer():addChild(_lbTitle, 10)
		_lbTitle:setAnchorPoint(ccp(0.5, 1))
		_lbTitle:setPosition(ccp(_Layer:getContentLayer():getContentSize().width*0.5, _Layer:getContentLayer():getContentSize().height-SY(2)))
	end
	
	--设置文本内容的属性（颜色，上下居中，左右对齐，字体，大小）
	function _Layer:setContentAttribute(fntColor, vCenter, alignment, fntName, fntSize)
		if _lbContent == nil then
			return
		end
		if alignment or fntName or fntSize then
			alignment = alignment or  kCCTextAlignmentCenter
			fntName = fntName or FONT_NAME
			fntSize = fntSize or FONT_SIZE_M
			local strData = _lbContent:getString()
			local parent = _lbContent:getParent()
			local position = ccp(_lbContent:getPosition())
			local size = _lbContent:getContentSize()
			parent:removeChild(_lbContent, true)
			_lbContent = nil
			_lbContent =  CCLabelTTF:create(strData, fntName, fntSize, SZ(size.width, 0), alignment)
			if _isLayer then
				size = _lbContent:getContentSize()
				parent:setContentSize(size)
			end
			parent:addChild(_lbContent, 10)
			_lbContent:setAnchorPoint(ccp(0.5, 1))
			_lbContent:setPosition(position)
		end
		--设置颜色
		if fntColor then
			_lbContent:setColor(fntColor)
		end
		--内容上下居中，只有在不是Layer时有效，
		if vCenter and _isLayer ~= true then
			local parent = _lbContent:getParent()
			local position = ccp(_lbContent:getPosition())
			position.y = position.y - (parent:getContentSize().height-marginT-marginB-_lbContent:getContentSize().height)*0.5
			_lbContent:setAnchorPoint(ccp(0.5, 1))
			_lbContent:setPosition(position)
		end
	end
	
	--设置确定按钮的（文本，颜色，字体，大小）
	function _Layer:setOkButtonText(strBtnOk, txtColor, fntName, fntSize)
		if _buttonOK then
			if strBtnOk then
				fntName = fntName or FONT_NAME
				fntSize = fntSize or FONT_SM_SIZE
				_buttonOK:setText(strBtnOk, fntName, fntSize)--文字
			end
			if txtColor then
				_buttonOK:setColor(txtColor)
			end
		end
	end

	--设置取消按钮的文本和颜色
	function _Layer:setCancelButtonText(strBtnCancel, txtColor, fntName, fntSize)
		if _buttonCancel then
			if strBtnCancel then
				fntName = fntName or FONT_NAME
				fntSize = fntSize or FONT_SM_SIZE
				_buttonCancel:setText(strBtnCancel, fntName, fntSize)--文字
			end
			if txtColor then
				_buttonCancel:setColor(txtColor)
			end
		end
	end
	
	--设置回调数据
	function _Layer:setData(data)
		_UserData = data
	end

	--获取回调数据
	function _Layer:getData()
		return _UserData
	end
	
	--显示窗口
	function _Layer:show(parent, z)
		if z then
			parent:addChild(_Layer, z)
		else
			parent:addChild(_Layer, 0)
		end
		_Layer:setPosition(ccp(0, 0))

		if _ScaleInOut then
			--逐渐变大
			_Layer:setScale(0.5)
			local scaleFull =  CCScaleTo:create(0.1, 1)
			_Layer:runAction(scaleFull)
		end
		
		BackKeyManager.addChildWin(_Layer, hide)
	end
	
	--设置回调函数
	function _Layer:setCallback(callFunc)
		_FunCallback = callFunc
	end
	
	--获取内容Layer
	function _Layer:getContentLayer()
		return contentLayer
	end
	
	--设置是否要放大缩小
	function _Layer:setScaleInOut(bScale)
		_ScaleInOut = bScale
	end
	--------------------------------------------------------------------------------------------------
	
	local norDown =  CCLayer:create()
	local menuItem =  CCMenuItemSprite:create(norDown, nil)
	norDown:setAnchorPoint(ccp(0, 0))
	norDown:setPosition(ccp(0, 0))

	local menu =  CCMenu:createWithItem(menuItem)
	menuItem:setAnchorPoint(ccp(0, 0))
	menuItem:setPosition(ccp(0, 0))
	_Layer:addChild(menu, 0)
	menu:setPosition(ccp(0, 0))
	
	--local contentSize = SZ(viewSize.width-marginL-marginR, viewSize.height-marginT-marginB)
	contentLayer =  CCLayer:create()
	contentLayer:setContentSize(viewSize)
	_Layer:addChild(contentLayer,0)
	contentLayer:setPosition(ccp(WINSIZE.width/2 - viewSize.width/2,
		WINSIZE.height/2 - viewSize.height/2))
		
		
    --窗口外观
	local boxImage = P("form/msgbox.9.png")
	local closeImage = P("button/close_nor.png")
	local closePos = 1
	if strTitle then
		--带有标题栏的外观
	else
		--没有标题栏的外观
		boxImage = P("form/form5050.9.png")
		closeImage = P("button/cha_nor.png")
		closePos = 2
	end
	local spriteBg  =  CCScale9Sprite:create(boxImage)
	contentLayer:addChild(spriteBg, 0)
	spriteBg:setAnchorPoint(ccp(0, 0))
	spriteBg:setContentSize(viewSize)

	--关闭按钮
	local norSprite =  CCSprite:create(closeImage)
	local norLayer =  CCLayer:create()
	norLayer:addChild(norSprite, 0)
	--点击的范围放大按钮的1.5倍，方便点击
	--norLayer:setContentSize(SZ(PX(66/2), PY(66/2)))
	norLayer:setContentSize(SZ(norSprite:getContentSize().width*1.5, norSprite:getContentSize().height*1.5))
	norSprite:setAnchorPoint(ccp(1,1))
	norSprite:setPosition(ccp(norLayer:getContentSize().width, norLayer:getContentSize().height - SY(2)))
	local downSprite =  CCSprite:create(closeImage)
	downSprite:setAnchorPoint(ccp(1,1))
	local downLayer =  CCLayer:create()
	downLayer:addChild(downSprite, 0)
	--点击的范围放大按钮的1.5倍，方便点击
	--downLayer:setContentSize(SZ(PX(66/2), PY(66/2)))
	downLayer:setContentSize(SZ(downSprite:getContentSize().width*1.5, downSprite:getContentSize().height*1.5))
	downSprite:setPosition(ccp(downLayer:getContentSize().width, downLayer:getContentSize().height - SY(2)))
	downLayer:setScale(1.1)
	local btnClose = Button.newFromSprite(norLayer, downLayer, nil, hide)
	btnClose:getMenuItem():setTag(1)
	spriteBg:addChild(btnClose, 0)
	if closePos == 1 then
		btnClose:setPosition(ccp(spriteBg:getContentSize().width - btnClose:getContentSize().width - SX(2), spriteBg:getContentSize().height - btnClose:getContentSize().height))
	else
		btnClose:setPosition(ccp(spriteBg:getContentSize().width - btnClose:getContentSize().width*0.75, spriteBg:getContentSize().height - btnClose:getContentSize().height*0.7))	
	end
	
	--背景图片
	if pImgBg then
		local imgBg =  CCSprite:create(pImgBg)
		spriteBg:addChild(imgBg, 0)
		local nSX = viewSize.width / imgBg.getContentSize().width
		local nSY = viewSize.height / imgBg.getContentSize().height
		local nScale = ((nSX < nSY) and nSX) or nSY
		if nScale < 1 then
			imgBg:setScale(nScale)
		end
		imgBg:setPosition(ccp(spriteBg:getContentSize().width*0.5, spriteBg:getContentSize().height*0.5))
	end

	--标题
	if strTitle then
		_lbTitle =  CCLabelTTF:create(strTitle, FONT_NAME, FONT_SIZE_M)
		spriteBg:addChild(_lbTitle, 10)
		_lbTitle:setAnchorPoint(ccp(0.5, 1))
		_lbTitle:setPosition(ccp(spriteBg:getContentSize().width*0.5, spriteBg:getContentSize().height-SY(2)))
	end
	
    --内容
	local lSize = nil
	if _isLayer then
		--strContent为Layer
		lSize = strContent:getContentSize()
		if lSize.width > viewSize.width - marginL - marginR then
			--调整layer的width
			lSize.width = viewSize.width - marginL - marginR
			strContent:setContentSize(lSize)
		end
	else
		--strContent为文本
		_lbContent =  CCLabelTTF:create(strContent, FONT_NAME, FONT_SIZE_M, 
				SZ(viewSize.width - marginL - marginR, 0),  kCCTextAlignmentCenter)
		lSize = _lbContent:getContentSize()
		if lSize.height > viewSize.height - marginT - marginB then
			--如果文本内容超出可视窗口的height，则转换为Layer，启动滚屏效果
			_isLayer = true
			strContent = nil
			strContent =  CCLayer:create()
			strContent:setContentSize(lSize)
			strContent:addChild(_lbContent, 0)
			_lbContent:setAnchorPoint(ccp(0.5, 1))
			_lbContent:setPosition(ccp(strContent:getContentSize().width/2, strContent:getContentSize().height))
		else
			contentLayer:addChild(_lbContent, 10)
			_lbContent:setAnchorPoint(ccp(0.5, 1))
			_lbContent:setPosition(ccp(viewSize.width/2, viewSize.height - marginT))
		end
	end
	
	--如果height超过可视窗口的height，则启用滚屏效果
	if lSize.height > viewSize.height - marginT - marginB then
		lSize.height = viewSize.height- marginT - marginB
		local list = ScutCxControl.ScutCxList:node(lSize.height,  ccc4(24, 24, 24, 0), lSize)
		list:setSelectedItemColor( ccc3(24, 24, 24),  ccc3(24, 24, 24)) --设置选中色 可以是过渡度
		list:setLineColor( ccc3(24, 24, 24))
		list:setHorizontal(false) --设置是横向还是竖向List
		list:setRowHeight(lSize.height)
		list:setRowWidth(lSize.width)
		list:setPageTurnEffect(false)
		list:setRecodeNumPerPage(1) -- 设置每页几项
		--list:registerLoadEvent("XXX.callbackListview")
		contentLayer:addChild(list, 0, 0)
		list:setPosition(ccp((contentLayer:getContentSize().width-strContent:getContentSize().width)*0.5, marginB))

		local listItem = ScutCxControl.ScutCxListItem:itemWithColor( ccc3(24,24,24))
		listItem:setOpacity(0) 
		listItem:setDrawTopLine(false)
		listItem:setDrawBottomLine(false)
		listItem:addChild(strContent, 0)
		
		list:addListItem(listItem, false)
		listItem:setPosition(ccp(0, lSize.height-strContent:getContentSize().height))
		list:disableAllCtrlEvent()
		--list:turnToPage(0)
		
		--下面还有信息提示
		local downTip =  CCSprite:create(P("icon/downarrow4040.png"))
		contentLayer:addChild(downTip, 0)
		downTip:setPosition(ccp(contentLayer:getContentSize().width-SX(4)-downTip:getContentSize().width*0.5, marginB+SY(5)+downTip:getContentSize().height*0.5))
		local function afterAction()
			if downTip then
				downTip:getParent():removeChild(downTip, true)
				downTip = nil
			end
		end
		local action1 =  CCMoveTo:create(0.5, ccp(downTip:getPositionX(), downTip:getPositionY() + SY(5)))
		local action2 =  CCMoveTo:create(0.5, ccp(downTip:getPositionX(), downTip:getPositionY() - SY(5)))
		local action3 =  CCSequence:createWithTwoActions(action1, action2)
		local act3times =  CCRepeat:create(action3, 3)
		local runact =  CCSequence:createWithTwoActions(act3times,  CCCallFunc:create(afterAction))
		downTip:runAction(runact)
	elseif _isLayer then
		contentLayer:addChild(strContent, 0)
		strContent:setPosition(ccp((contentLayer:getContentSize().width-strContent:getContentSize().width)*0.5, viewSize.height-marginT-strContent:getContentSize().height))
	end

	--按钮
	local btnFile_nor = "button/button8045_nor.png"
	local btnFile_sel = "button/button8045_sel.png"
	if nButton == 2 then
		btnFile_nor = "button/button10050_nor.png"
		btnFile_sel = "button/button10050_sel.png"
	elseif nButton == 3 then
		btnFile_nor = "button/button12045_nor.png"
		btnFile_sel = "button/button12045_sel.png"
	elseif nButton == 4 then
		btnFile_nor = "button/button13050_nor.png"
		btnFile_sel = "button/button13050_sel.png"	
	elseif nButton == 5 then
		btnFile_nor = "button/button15060_nor.png"
		btnFile_sel = "button/button15060_sel.png"
	elseif nButton == 6 then
		btnFile_nor = "button/button16050_nor.png"
		btnFile_sel = "button/button16050_sel.png"
	elseif nButton == 7 then
		btnFile_nor = "button/button17050_nor.png"
		btnFile_sel = "button/button17050_sel.png"
	elseif nButton >= 8 then
		btnFile_nor = "button/button18070_nor.png"
		btnFile_sel = "button/button18070_sel.png"
	end
	
	if nType == _MB_OK then
		--只包含确定按钮
        _buttonOK = Button.new(P(btnFile_nor), P(btnFile_sel), nil, hide)
        local xPos = contentLayer:getContentSize().width/2-_buttonOK:getContentSize().width/2
        _buttonOK:setPosition( CCPoint(xPos, (marginB - _buttonOK:getContentSize().height)/2))
        contentLayer:addChild(_buttonOK, 10)
        _buttonOK:getMenuItem():setTag(0)
        _buttonOK:setText(strOk, FONT_NAME, FONT_SM_SIZE)--文字
	elseif nType == _MB_OK_CANCEL then
		--确定 取消按钮
        _buttonOK = Button.new(P(btnFile_nor), P(btnFile_sel), nil, hide)
        local xPos = SX(25)
        _buttonOK:setPosition( CCPoint(xPos, (marginB-_buttonOK:getContentSize().height)/2))
        contentLayer:addChild(_buttonOK, 10)
        _buttonOK:getMenuItem():setTag(0)
        _buttonOK:setText(strOk, FONT_NAME, FONT_SM_SIZE)--文字
        
        _buttonCancel = Button.new(P(btnFile_nor), P(btnFile_sel), nil, hide)
		local xPos = viewSize.width - _buttonCancel:getContentSize().width - SX(25)
        _buttonCancel:setPosition( CCPoint(xPos, (marginB-_buttonCancel:getContentSize().height)/2))
        contentLayer:addChild(_buttonCancel, 10)
        _buttonCancel:getMenuItem():setTag(1)
        _buttonCancel:setText(strCancel, FONT_NAME, FONT_SM_SIZE)--文字
	end

	return _Layer
end
