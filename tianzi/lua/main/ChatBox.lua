module("ChatBox", package.seeall)

function new(tabs, tabsFunc, closeFunc)
	local tabLayer --整个标题区
	local contentLayer --用于显示聊天内容的区域
	local tabContentLayer --标题区剩余可以编辑的区域
	local btnClose
	local tmenuIten = {	}
	local curSelectIndex = 0
	
	local layer = CCLayer:create()
	local norDown = CCLayer:create()
	local menuItem = CCMenuItemSprite:create(norDown, nil)
	norDown:setAnchorPoint(ccp(0, 0))
	norDown:setPosition(ccp(0, 0))

	local menu = CCMenu:createWithItem(menuItem)
	menuItem:setAnchorPoint(ccp(0, 0))
	menuItem:setPosition(ccp(0, 0))
	layer:addChild(menu, 0)
	menu:setPosition(ccp(0, 0))
	
	local function setSelectTab(index)
		if index > 0 and index <= #tmenuIten then
			tmenuIten[index]:selected()
		end
		if curSelectIndex ~= index then
			layer:setSelectIndex(index)
			curSelectIndex = index
		end
	end
	
	local function close(tag)
		BackKeyManager.removeChildWin(layer)
		layer:getParent():removeChild(layer, true)
		closeFunc()
		layer = nil
	end
	
	--获取有效的布局Layer　必须用
	function layer:getContentLayer()
		return contentLayer
	end
	
	--获取可以编辑的那个标题区
	function layer:getTabContentLayer()
		return tabContentLayer
	end
	
	--设置当前展示的tab
	function layer:setSelectIndex(index)
		if index > 0 and index <= #tmenuIten then
			if menu then
				for k, v in pairs(tmenuIten) do 
					if k == index then
						tmenuIten[k]:selected()
					else
						tmenuIten[k]:unselected()
					end
				end
				
				tabsFunc(index, layer)
			end
		end
	end

	--添加到parent
	function layer:show(parent)
		parent:addChild(self, 0)
		self:setPosition(ccp(0, 0))
		BackKeyManager.addChildWin(self, close)
	end
	
	-- 背景图片
	local spBg = CCSprite:create(P("background/tab_bg.png"))
	layer:addChild(spBg, 0)
	spBg:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))	
	-- 背景框
	local contentForm = CCSprite:create(P("form/tabform.png"))
	layer:addChild(contentForm, 0)
	contentForm:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))

	--tabLayer = CCLayerColor:create(ccc4(255, 28, 28, 128))
	tabLayer = CCLayer:create()
	local tex = CCTextureCache:sharedTextureCache():addImage(P("button/tabtop_nor.png"))
	tabLayer:setContentSize(SZ(contentForm:getContentSize().width*0.935, tex:getContentSize().height))
	layer:addChild(tabLayer, 0)

	local contentSize = SZ(contentForm:getContentSize().width*0.935, contentForm:getContentSize().height*0.83)
	local contentPos = ccp(contentForm:getPosition())
	contentPos.x = contentPos.x - contentForm:getContentSize().width/2 + contentForm:getContentSize().width*0.033
	contentPos.y = contentPos.y - contentForm:getContentSize().height/2 + contentForm:getContentSize().width*0.025
	
	local tabPos = ccp(0, 0)
	tabPos.x = contentPos.x
	tabPos.y = contentPos.y + contentSize.height + tabLayer:getContentSize().height*0.38
	tabLayer:setPosition(tabPos)

	local xPos = 0
	local menu = nil
	for k, v in pairs(tabs) do
		local nor = CCSprite:create(P("button/tabtop_nor.png"))
		local sel = CCSprite:create(P("button/tabtop_sel.png"))
		local dis = CCSprite:create(P("button/tabtop_nor.png"))
		menuItem = CCMenuItemSprite:create(nor, sel, dis)
		menuItem:registerScriptTapHandler(setSelectTab)
		menuItem:setPosition(ccp(xPos, 0))
		menuItem:setAnchorPoint(ccp(0, 0))
		
		table.push_back(tmenuIten, menuItem)
		
		local lb = CCLabelTTF:create(v, FONT_NAME, FONT_SIZE_M)
		menuItem:addChild(lb, 0)
		lb:setPosition(ccp(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2))
		lb:setColor(ccYELLOW_L)

		if menu == nil then
			menu = CCMenu:createWithItem(menuItem)
			tabLayer:addChild(menu, 0)
			menu:setContentSize(SZ(menuItem:getContentSize().width * #tabs, menuItem:getContentSize().height))
			menu:setPosition(ccp(0, 0))
		else
			menu:addChild(menuItem, 0)
		end

		menuItem:setTag(k)
		xPos = xPos + menuItem:getContentSize().width
	end

	tabContentLayer = CCLayer:create()
	tabLayer:addChild(tabContentLayer, 0)
	if menu then
		tabContentLayer:setContentSize(SZ(tabLayer:getContentSize().width - menu:getContentSize().width,
			tabLayer:getContentSize().height))
		tabContentLayer:setPosition(ccp(menu:getPositionX() + menu:getContentSize().width, 0))
	else
		tabContentLayer:setContentSize(SZ(tabLayer:getContentSize().width, tabLayer:getContentSize().height))
		tabContentLayer:setPosition(ccp(0, 0))
	end

	--contentLayer = CCLayerColor:create(ccc4(28, 28, 255, 128))
	contentLayer = CCLayer:create()
	contentLayer:setContentSize(contentSize)
	layer:addChild(contentLayer, 0)
	contentLayer:setPosition(contentPos)
	
	-- 关闭按钮
	local norSprite = CCSprite:create(P("button/tabclose_nor.png"))
	local downSprite = CCSprite:create(P("button/tabclose_sel.png"))
	
	btnClose = Button.newFromSprite(norSprite, downSprite, nil, close)
	layer:addChild(btnClose, 0)
	
	local closePos = ccp(0,0)
	closePos.x = tabPos.x + tabLayer:getContentSize().width - btnClose:getContentSize().width*0.8
	closePos.y = tabPos.y - btnClose:getContentSize().height/2 + tabLayer:getContentSize().height/2
	btnClose:setPosition(closePos)
	
	return layer
end


