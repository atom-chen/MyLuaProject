module("LinkLabel", package.seeall)
--创建一个有下划线的文本按钮
--modify by  
--改成内部方法 保证跟CCNode一样的生命周期
--去除gClassPool
--回调的注册 setFunc
--text文本内容(必填) color 颜色 fontname 字体 fontsize 字号
function new(text,color,fontname,fontsize)
	if fontname == nil then	
		fontname = FONT_NAME;
	end
	if fontsize == nil then	
		fontsize = FONT_SIZE_L;
	end
	
	if color == nil then
		color = ccc3(255,255,255)
	end
	
	local labelChange = CCLabelTTF:create(text, fontname, fontsize);
	labelChange:setColor(color);
	local ChangeMenuItem = CCMenuItemLabel:create(labelChange);
	ChangeMenuItem:setContentSize(SZ(labelChange:getContentSize().width,labelChange:getContentSize().height))
	ChangeMenuItem:setPosition(ccp(ChangeMenuItem:getContentSize().width/2,ChangeMenuItem:getContentSize().height/2))
	ChangeMenuItem:setAnchorPoint(ccp(0.5, 0.5))	
	
	color = ccc4(color.r, color.g, color.b,255)
	local lineNode = ScutCxControl.ScutLineNode:lineWithPoint(ccp(0,0), ccp(labelChange:getContentSize().width, 0), 1, color)
	ChangeMenuItem:addChild(lineNode, 0)
	local changeMenu = CCMenu:createWithItem(ChangeMenuItem)
	changeMenu:setContentSize(ChangeMenuItem:getContentSize())
	changeMenu:setAnchorPoint(ccp(0, 0))
	
	local userdata, userFunc
	
	local function lineLabelCallback(tag)
		if userFunc then
			userFunc(tag, userdata)
		end
	end
	ChangeMenuItem:registerScriptTapHandler(lineLabelCallback)
	-- setData getData 不推荐使用 
	--只接用changeMenu.xxxx = xx来代替
	function changeMenu:setData(data)
		userdata=data
	end

	function changeMenu:getData()
		return userdata
	end
	function changeMenu:setFunc(event)
		userFunc = event
	end

	function changeMenu:setMenuItemTag(tag)
		ChangeMenuItem:setTag(tonumber(tag))
	end

	function changeMenu:getMenuItemTag()
		return ChangeMenuItem:getTag()
	end

	--本可拿掉 兼容旧接口
	function changeMenu:addto(parent, param1, param2)
		if type(param1) == "userdata" then
			parent:addChildItem(self, param1)
		else
			if param2 then
				parent:addChild(self, param1, param2)
			elseif param1 then
				parent:addChild(self, param1)
			else
				parent:addChild(self, 0)
			end
		end
	end


	function changeMenu:setEnabled(enabled)
		ChangeMenuItem:setEnabled(enabled)
	end

	function changeMenu:getIsEnabled()
		return ChangeMenuItem:getIsEnabled()
	end

	return changeMenu
end
