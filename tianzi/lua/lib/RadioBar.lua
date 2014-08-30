module("RadioBar", package.seeall)
--[[
	local layer1 = RadioBar.new(5)
	mLayer:addChild(layer1, 0)
	layer1:setPosition(ccp(SX(10), SY(10)))
]]
function new(num, nEachSpace)
	local layer
	if num <= 0 then
		num = 1
	end
	local tItem = {	}
	local xPos = nil
	local nEachWith=0
	for i =1, num, 1 do
	    local spriteNor = CCSprite:create(P("button/dot_nor.png"))
		local spriteSel = CCSprite:create(P("button/dot_sel.png"))
		if layer == nil then
			layer = CCLayer:create()
			nEachWith = spriteNor:getContentSize().width + SX(4)
			if nEachSpace ~= nil then
				nEachWith = nEachSpace
			end
			xPos = 0
			layer:setContentSize(SZ(nEachWith * num, spriteNor:getContentSize().height))
		end
		
		local menuItem = CCMenuItemSprite:create(spriteNor,spriteSel, nil)
		layer:addChild(menuItem, 0)
		menuItem:setPosition(ccp(xPos + nEachWith/2, layer:getContentSize().height/2))
		xPos = xPos + nEachWith
		table.push_back(tItem, menuItem)
	end
	local _index = 0
	--index = 1 ... n
	function layer:setSelectIndex(index)
		if index >= 1 and index <= num then
			for k, v in pairs(tItem) do
				v:unselected()
			end
			_index = index
			tItem[index]:selected()
		end
	end
	function layer:getSelectIndex()
		return _index
	end
	layer:setSelectIndex(1)
	return layer
end