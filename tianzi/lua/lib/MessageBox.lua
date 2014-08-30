require("lib.BackKeyManager")
module("MessageBox", package.seeall)
--[[
function _Layer:setData(data)
function _Layer:getData()
function _Layer:show(parent,z)
]]
--callBack 0Ϊȷ������Ϊȡ��
--���ݱ��ⴴ��һ���Ի���
function new(strContent,nType, strOk, strCancel, callBack)
	local _Layer 			= nil
    local _lbContent      = nil	
	local _buttonOK 		= nil
	local _buttonCanel    = nil
	local _UserData	 	= nil
	local _FunCallback = callBack
	--��ť����
	local _MB_OK 		   = 1
	local _MB_OK_CANCEL   = 2

	local layer = nil
	local contentLayer = nil
	layer =  CCLayer:create() --
	_Layer = layer
	
	
	--����
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
    --����
	local spriteBg  =  CCScale9Sprite:create(P("form/msgbox.9.png"))
	contentLayer:addChild(spriteBg, 0)
	spriteBg:setAnchorPoint(ccp(0, 0))
	spriteBg:setContentSize(size)

    --����
	if strContent ~= nil then
		_lbContent =  CCLabelTTF:create(strContent, FONT_NAME, FONT_SIZE_M, SZ(size.width - SX(20), 0), kCCTextAlignmentCenter)
		_lbContent:setPosition(ccp(size.width/2, size.height - SY(35)))
		_lbContent:setAnchorPoint(ccp(0.5, 1))
		contentLayer:addChild(_lbContent,0)
	end
	
	local yPos = SY(15)
    --ֻ����ȷ����ť
	if nType == _MB_OK then
        _buttonOK = Button.new(P("button/button8045_nor.png"), 
			P("button/button8045_sel.png"),nil,hide)
        local xPos = contentLayer:getContentSize().width/2-_buttonOK:getContentSize().width/2
        _buttonOK:setPosition( CCPoint(xPos, yPos))
        contentLayer:addChild(_buttonOK,0)
        _buttonOK:getMenuItem():setTag(0)
        _buttonOK:setText(strOk, FONT_NAME, FONT_SM_SIZE)--����
	end
	
	--ȷ�� ȡ����ť
	if nType == _MB_OK_CANCEL then
        _buttonOK = Button.new(P("button/button8045_nor.png"), 
			P("button/button8045_sel.png"),nil,hide)
        
		local xPos = size.width - _buttonOK:getContentSize().width - SX(20)
        _buttonOK:setPosition( CCPoint(xPos, yPos))
        contentLayer:addChild(_buttonOK,0)
        _buttonOK:getMenuItem():setTag(0)
        _buttonOK:setText(strOk, FONT_NAME, FONT_SM_SIZE)--����

        
        _buttonCanel = Button.new(P("button/button8045_nor.png"), 
			P("button/button8045_sel.png"),nil, hide)
        local xPos = SX(20)
        _buttonCanel:setPosition( CCPoint(xPos, yPos))
        contentLayer:addChild(_buttonCanel,0)
        _buttonCanel:getMenuItem():setTag(1)
        _buttonCanel:setText(strCancel, FONT_NAME, FONT_SM_SIZE)--����
	end

	return _Layer
end

--callBack, tag: 0Ϊȷ�� ��Ϊȡ��
--���ݲ�������һ���Ի���
--���ݣ����⣬���ڴ�С���Ƿ�Ҫ���ֲ㣬���ͣ���ť��С������ͼƬ���ص�����
--���ݣ��������ַ�����Ҳ������Layer��������ַ�������Ҫ��֤��ʾ������height���ܳ������Ӵ��ڵ�height�����������Layer�����Զ����ù���Ч����
--���⣺����д�������ı�����ʹ�ô��б���������ۣ��������nil��ʹ���ޱ���������ۣ�ͨ��setTitle�������ñ�����Ϣ��
--���ͣ�������̬ 0-�ް�ť��Ĭ�ϣ� 1-ֻ��һ����ť��ȷ������2-��������ť��ȷ����ȡ����
--��ť��С���ж��ִ�С�ɹ�ѡ��1-8��
function newEx(strContent, strTitle, viewSize, bMark, nType, nButton, pImgBg, callBack)
	local _Layer 			= nil
	local _lbTitle			= nil
	local _lbContent	    = nil	
	local _buttonOK 		= nil
	local _buttonCancel  	= nil
	local _UserData	 		= nil
	local _FunCallback 		= callBack
	local _isLayer			= nil --�����Ƿ�ΪLayer��Ĭ�����ַ���
	local _ScaleInOut		= nil --��ʾ���˳��Ƿ�Ҫ�Ŵ���С
	local _Tag				= nil
	--��ť����
	local _MB_OK 		   	= 1
	local _MB_OK_CANCEL   	= 2

	local contentLayer = nil
	local marginL = SX(5)	-- ���ڵ���߾�
	local marginR = SX(5)	-- ���ڵ��ұ߾�
	local marginT = SY(22)	-- ���ڵ��ϱ߾ࣨ������λ�ã�
	local marginB = SY(40)  -- ���ڵ��±߾ࣨ��ťλ�ã�
	--������ʾLayer
	if bMark then
		_Layer =  CCLayerColor:create( ccc4(0,0,0,208))
	else
		_Layer =  CCLayer:create()
	end
	
	--��ʼ��Ĭ��ֵ
	strContent = strContent or ""
	nType = nType or 0 --Ĭ��û�а�ť
	if nType ~= _MB_OK and nType ~= _MB_OK_CANCEL then
		nType = 0
	end
	strOk = strOk or GameString.STR_OK
	strCancel = strCancel or GameString.STR_CANCEL
	nButton = nButton or 1  --��ť��С��Ĭ����80*38��С�İ�ť
	--���㴰�ڴ�СviewSize
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
		if nType == 0 then	--û�а�ť
			marginB = SY(2)
		end
		viewSize = viewSize or SZ(strContent:getContentSize().width+marginL+marginR, strContent:getContentSize().height+marginT+marginB) --�������ұ߾࣬���±߾�
		if viewSize.width < 1 then
			viewSize.width = strContent:getContentSize().width + marginL+marginR
		end
		if viewSize.height < 1 then
			viewSize.height = SY(150) + marginT+marginB
		end
	end
	--���Ӵ��ڴ�С���ܳ�����Ļ�Ĵ�С
	if viewSize.width > WINSIZE.width-SX(20) then
		viewSize.width = WINSIZE.width-SX(20)
	end
	if viewSize.height > WINSIZE.height-SY(10) then
		viewSize.height = WINSIZE.height-SY(10)
	end
	
	--������˳�
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
	
	--����
	local function hide(tag)
		_Tag = tag
		if _ScaleInOut then
			--����С
			local scaleZero =  CCScaleTo:create(0.1, 0.3)
			local hideExit =  CCCallFunc:create(cleanUp)
			local action =  CCSequence:createWithTwoActions(scaleZero, hideExit)	
			_Layer:runAction(action)
		else
			cleanUp()
		end
	end
	
	--------------------------------------------------------------------------------------------------
	--���ñ��⣨�������֣����壬��С����ɫ��
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
	
	--�����ı����ݵ����ԣ���ɫ�����¾��У����Ҷ��룬���壬��С��
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
		--������ɫ
		if fntColor then
			_lbContent:setColor(fntColor)
		end
		--�������¾��У�ֻ���ڲ���Layerʱ��Ч��
		if vCenter and _isLayer ~= true then
			local parent = _lbContent:getParent()
			local position = ccp(_lbContent:getPosition())
			position.y = position.y - (parent:getContentSize().height-marginT-marginB-_lbContent:getContentSize().height)*0.5
			_lbContent:setAnchorPoint(ccp(0.5, 1))
			_lbContent:setPosition(position)
		end
	end
	
	--����ȷ����ť�ģ��ı�����ɫ�����壬��С��
	function _Layer:setOkButtonText(strBtnOk, txtColor, fntName, fntSize)
		if _buttonOK then
			if strBtnOk then
				fntName = fntName or FONT_NAME
				fntSize = fntSize or FONT_SM_SIZE
				_buttonOK:setText(strBtnOk, fntName, fntSize)--����
			end
			if txtColor then
				_buttonOK:setColor(txtColor)
			end
		end
	end

	--����ȡ����ť���ı�����ɫ
	function _Layer:setCancelButtonText(strBtnCancel, txtColor, fntName, fntSize)
		if _buttonCancel then
			if strBtnCancel then
				fntName = fntName or FONT_NAME
				fntSize = fntSize or FONT_SM_SIZE
				_buttonCancel:setText(strBtnCancel, fntName, fntSize)--����
			end
			if txtColor then
				_buttonCancel:setColor(txtColor)
			end
		end
	end
	
	--���ûص�����
	function _Layer:setData(data)
		_UserData = data
	end

	--��ȡ�ص�����
	function _Layer:getData()
		return _UserData
	end
	
	--��ʾ����
	function _Layer:show(parent, z)
		if z then
			parent:addChild(_Layer, z)
		else
			parent:addChild(_Layer, 0)
		end
		_Layer:setPosition(ccp(0, 0))

		if _ScaleInOut then
			--�𽥱��
			_Layer:setScale(0.5)
			local scaleFull =  CCScaleTo:create(0.1, 1)
			_Layer:runAction(scaleFull)
		end
		
		BackKeyManager.addChildWin(_Layer, hide)
	end
	
	--���ûص�����
	function _Layer:setCallback(callFunc)
		_FunCallback = callFunc
	end
	
	--��ȡ����Layer
	function _Layer:getContentLayer()
		return contentLayer
	end
	
	--�����Ƿ�Ҫ�Ŵ���С
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
		
		
    --�������
	local boxImage = P("form/msgbox.9.png")
	local closeImage = P("button/close_nor.png")
	local closePos = 1
	if strTitle then
		--���б����������
	else
		--û�б����������
		boxImage = P("form/form5050.9.png")
		closeImage = P("button/cha_nor.png")
		closePos = 2
	end
	local spriteBg  =  CCScale9Sprite:create(boxImage)
	contentLayer:addChild(spriteBg, 0)
	spriteBg:setAnchorPoint(ccp(0, 0))
	spriteBg:setContentSize(viewSize)

	--�رհ�ť
	local norSprite =  CCSprite:create(closeImage)
	local norLayer =  CCLayer:create()
	norLayer:addChild(norSprite, 0)
	--����ķ�Χ�Ŵ�ť��1.5����������
	--norLayer:setContentSize(SZ(PX(66/2), PY(66/2)))
	norLayer:setContentSize(SZ(norSprite:getContentSize().width*1.5, norSprite:getContentSize().height*1.5))
	norSprite:setAnchorPoint(ccp(1,1))
	norSprite:setPosition(ccp(norLayer:getContentSize().width, norLayer:getContentSize().height - SY(2)))
	local downSprite =  CCSprite:create(closeImage)
	downSprite:setAnchorPoint(ccp(1,1))
	local downLayer =  CCLayer:create()
	downLayer:addChild(downSprite, 0)
	--����ķ�Χ�Ŵ�ť��1.5����������
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
	
	--����ͼƬ
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

	--����
	if strTitle then
		_lbTitle =  CCLabelTTF:create(strTitle, FONT_NAME, FONT_SIZE_M)
		spriteBg:addChild(_lbTitle, 10)
		_lbTitle:setAnchorPoint(ccp(0.5, 1))
		_lbTitle:setPosition(ccp(spriteBg:getContentSize().width*0.5, spriteBg:getContentSize().height-SY(2)))
	end
	
    --����
	local lSize = nil
	if _isLayer then
		--strContentΪLayer
		lSize = strContent:getContentSize()
		if lSize.width > viewSize.width - marginL - marginR then
			--����layer��width
			lSize.width = viewSize.width - marginL - marginR
			strContent:setContentSize(lSize)
		end
	else
		--strContentΪ�ı�
		_lbContent =  CCLabelTTF:create(strContent, FONT_NAME, FONT_SIZE_M, 
				SZ(viewSize.width - marginL - marginR, 0),  kCCTextAlignmentCenter)
		lSize = _lbContent:getContentSize()
		if lSize.height > viewSize.height - marginT - marginB then
			--����ı����ݳ������Ӵ��ڵ�height����ת��ΪLayer����������Ч��
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
	
	--���height�������Ӵ��ڵ�height�������ù���Ч��
	if lSize.height > viewSize.height - marginT - marginB then
		lSize.height = viewSize.height- marginT - marginB
		local list = ScutCxControl.ScutCxList:node(lSize.height,  ccc4(24, 24, 24, 0), lSize)
		list:setSelectedItemColor( ccc3(24, 24, 24),  ccc3(24, 24, 24)) --����ѡ��ɫ �����ǹ��ɶ�
		list:setLineColor( ccc3(24, 24, 24))
		list:setHorizontal(false) --�����Ǻ���������List
		list:setRowHeight(lSize.height)
		list:setRowWidth(lSize.width)
		list:setPageTurnEffect(false)
		list:setRecodeNumPerPage(1) -- ����ÿҳ����
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
		
		--���滹����Ϣ��ʾ
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

	--��ť
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
		--ֻ����ȷ����ť
        _buttonOK = Button.new(P(btnFile_nor), P(btnFile_sel), nil, hide)
        local xPos = contentLayer:getContentSize().width/2-_buttonOK:getContentSize().width/2
        _buttonOK:setPosition( CCPoint(xPos, (marginB - _buttonOK:getContentSize().height)/2))
        contentLayer:addChild(_buttonOK, 10)
        _buttonOK:getMenuItem():setTag(0)
        _buttonOK:setText(strOk, FONT_NAME, FONT_SM_SIZE)--����
	elseif nType == _MB_OK_CANCEL then
		--ȷ�� ȡ����ť
        _buttonOK = Button.new(P(btnFile_nor), P(btnFile_sel), nil, hide)
        local xPos = SX(25)
        _buttonOK:setPosition( CCPoint(xPos, (marginB-_buttonOK:getContentSize().height)/2))
        contentLayer:addChild(_buttonOK, 10)
        _buttonOK:getMenuItem():setTag(0)
        _buttonOK:setText(strOk, FONT_NAME, FONT_SM_SIZE)--����
        
        _buttonCancel = Button.new(P(btnFile_nor), P(btnFile_sel), nil, hide)
		local xPos = viewSize.width - _buttonCancel:getContentSize().width - SX(25)
        _buttonCancel:setPosition( CCPoint(xPos, (marginB-_buttonCancel:getContentSize().height)/2))
        contentLayer:addChild(_buttonCancel, 10)
        _buttonCancel:getMenuItem():setTag(1)
        _buttonCancel:setText(strCancel, FONT_NAME, FONT_SM_SIZE)--����
	end

	return _Layer
end
