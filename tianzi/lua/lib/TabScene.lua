module("TabScene", package.seeall)
--获取TabMenu那个标题区
--function scene:getTabContentLayer()

--获取有效的布局Layer　必须用
--function scene:getContentLayer()
--scene:setTitle(strText)	 设置标题
--scene:setNum(index, Num) --index为第index个Tab，Num为红点上显示的数值
--tabs 
--info strText
function new(tabs, tabsFunc, closeFunc)
	local scene, tabLayer, btnClose, layerContent,layerTabContent, scutScene
	
	local tItem = {}
	local preSelectIndex = 0
	local function setSelectTab(index)
		if index > 0 and index <= #tItem then
			tItem[index]:selected()
		end
		if preSelectIndex ~= index then
			-- tabsFunc(scene, index)
			scene:setSelectIndex(index)
			preSelectIndex = index
		end
	end
		
	local function close(tag)
		if scene then
			ScutScene:popScene(scene)
		end
		closeFunc()
	end
	-- scene  = SceneHelper.scene(close)
	-- SceneHelper.pushScene(scene)
    scutScene = ScutScene:new(close)
    scene = scutScene.root
	ScutScene:pushScene(scene)

	function scene:popScene()
		close()
	end
	
	--获取TabMenu那个标题区
	function scene:getTabLayer()
		return tabLayer
	end
	--获取有效的布局Layer　必须用
	function scene:getContentLayer()
		return layerContent
	end
	
	function scene:getTabContentLayer()
		return layerTabContent
	end
	local layer = CCLayer:create()
	scene:addChild(layer, 0)

	-- 背景图片
	local spBg = CCSprite:create(P("background/tab_bg.png"))
	layer:addChild(spBg, 0)
	spBg:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))	
	-- 背景框
	local bg = CCSprite:create(P("form/tabform.png"))
	layer:addChild(bg, 0)
	bg:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))

	local menu = nil
	local xPos = 0
	local xMargin = PX(7)
	--tabLayer = CCLayerColor:create(ccc4(255, 28, 28, 128))
	tabLayer = CCLayer:create()
	local tex = CCTextureCache:sharedTextureCache():addImage(P("button/tabtop_nor.png"))
	tabLayer:setContentSize(CCSize(bg:getContentSize().width*0.935, tex:getContentSize().height))
	
	for k, v in pairs(tabs) do
		local nor = CCSprite:create(P("button/tabtop_nor.png"))
		local sel = CCSprite:create(P("button/tabtop_sel.png"))
		local dis = CCSprite:create(P("button/tabtop_nor.png"))
		menuItem = CCMenuItemSprite:create(nor, sel, dis)
		menuItem:registerScriptTapHandler(setSelectTab)
		menuItem:setPosition(ccp(xPos, 0))
		menuItem:setAnchorPoint(ccp(0, 0))
		
		local lb = CCLabelTTF:create(v, FONT_NAME, FONT_SIZE_M)
		nor:addChild(lb,0)
		lb:setPosition(ccp(nor:getContentSize().width/2, nor:getContentSize().height/2))
		lb:setColor(ccYELLOW_L)
		
		local lb = CCLabelTTF:create(v, FONT_NAME, FONT_SIZE_M)
		sel:addChild(lb,0)
		lb:setPosition(ccp(sel:getContentSize().width/2, sel:getContentSize().height/2))
		lb:setColor(ccYELLOW_L)
		
		local lb = CCLabelTTF:create(v, FONT_NAME, FONT_SIZE_M)
		dis:addChild(lb,0)
		lb:setColor(ccc3(128, 128, 128))
		lb:setPosition(ccp(dis:getContentSize().width/2, dis:getContentSize().height/2))
		
		if menu == nil then
			menu = CCMenu:createWithItem(menuItem)
			tabLayer:addChild(menu, 0)
			menu:setContentSize(CCSize(menuItem:getContentSize().width * #tabs, menuItem:getContentSize().height))
			menu:setPosition(ccp(0, 0))
		else
			menu:addChild(menuItem, 0)
		end
		
		local node = CCSprite:create(P("icon/bighongdian.png"))
		node:setAnchorPoint(ccp(0.3,1))
		node:setPosition(ccp(0,menuItem:getContentSize().height))
		menuItem:addChild(node, 0)
		node:setVisible(false)
		menuItem.node = node
		
		local lbNum = CCLabelTTF:create(tostring(0), FONT_NAME, FONT_SIZE_M)
		lbNum:setPosition(ccp(node:getContentSize().width/2, node:getContentSize().height/2))
		lbNum:setScale(0.8)
		node:addChild(lbNum, 0)
		lbNum:setVisible(false)
		menuItem.num = lbNum
		
		menuItem:setTag(k)
		xPos = xPos + menuItem:getContentSize().width
	
		table.push_back(tItem, menuItem)
	end
	

	layerTabContent = CCLayer:create()
	if menu then
		layerTabContent:setContentSize(CCSize(tabLayer:getContentSize().width - menu:getContentSize().width,
			tabLayer:getContentSize().height))
		layerTabContent:setPosition(ccp(menu:getPositionX() + menu:getContentSize().width, 0))
	else
		layerTabContent:setContentSize(CCSize(tabLayer:getContentSize().width,
			tabLayer:getContentSize().height))
		layerTabContent:setPosition(ccp(0, 0))
	end
	tabLayer:addChild(layerTabContent, 0)

	layer:addChild(tabLayer, 0)
	local contentSize = bg:getContentSize()
	contentSize.width = contentSize.width*0.935
	contentSize.height = contentSize.height*0.83
	
	local contentPosX, contentPosY = bg:getPosition()
	contentPosX = contentPosX - bg:getContentSize().width/2 + bg:getContentSize().width*0.033
	contentPosY = contentPosY - bg:getContentSize().height/2 + bg:getContentSize().width*0.025
	
	local tabPos = ccp(0,0)
	tabPos.x = contentPosX
	tabPos.y = contentPosY + contentSize.height + tabLayer:getContentSize().height*0.38
	--------------------------------------------------------------
	tabLayer:setPosition(tabPos)
	
	local yMargin = PY(8)
	--layerContent = CCLayerColor:create(ccc4(28, 28, 255, 128))
	layerContent = CCLayer:create()
	layerContent:setContentSize(contentSize)
	layer:addChild(layerContent, 0)
	layerContent:setPosition(contentPosX, contentPosY)

	-- 关闭按钮
	local norSprite = CCSprite:create(P("button/tabclose_nor.png"))
	local downSprite = CCSprite:create(P("button/tabclose_sel.png"))
	
	btnClose = Button.newFromSprite(norSprite, downSprite, nil, close)
	layer:addChild(btnClose, 0)
	local closePos = ccp(0,0)
	closePos.x = tabPos.x + tabLayer:getContentSize().width - btnClose:getContentSize().width*0.8
	closePos.y = tabPos.y - btnClose:getContentSize().height/2 + tabLayer:getContentSize().height/2
	btnClose:setPosition(closePos)
	
	local _Title = nil
	--
	function scene:setSelectIndex(index)
		if index > 0 and index <= #tItem then
			if menu then
				-- menu:setSelectItem(tItem[index])
				for k,v in pairs(tItem) do
					if index == k then
						tItem[k]:selected()
					else
						tItem[k]:unselected()
					end
				end
				-- setSelectTab(index)
				tabsFunc(scene, index)
			end
		end
	end
	
	function scene:setNum(index, Num)
	    if not index or not Num then return end
		if index > 0 and index <= #tItem then
			if tItem[index] then
				if Num > 0 then
					tItem[index].node:setVisible(true)
					tItem[index].num:setVisible(true)
					tItem[index].num:setString(tostring(Num))
				else
					tItem[index].node:setVisible(false)
					tItem[index].num:setVisible(false)
				end
			end
		end
	end

	function scene:getNum(index)
	    if not index then return end
		local nNum = 0
		if index > 0 and index <= #tItem then
			if tItem[index] then
				nNum = tonumber(tItem[index].num:getString())
			end
		end
		return nNum
	end
	
	function scene:setTitle(strText)
		if _Title then
			_Title:setString(strText)
		else
			_Title = CCLabelTTF:create(strText, FONT_NAME, FONT_SIZE_M)
			layerTabContent:addChild(_Title, 0)
			_Title:setPosition(ccp(layerTabContent:getContentSize().width/2,
				layerTabContent:getContentSize().height/2))
		end
	end
	
	function scene:getCloseBtn()
		return btnClose 
	end
	
	-- return scene
	return scutScene
end
