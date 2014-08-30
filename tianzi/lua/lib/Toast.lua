--提示的Toast 自动消息
require("lib.Common")
module("Toast", package.seeall)

--设置默认的值
local mDefApperTimeSec  = 1.2
local mDefHideTimeSec  = 1.6
mToasstID = 99999
local mZorder = 1000

function getZorder()
	return mZorder
end
function getDefApperTime()
    return mDefApperTimeSec
end

function getDefHideTime()
    return mDefHideTimeSec
end

function show(parent, strText, apperTimeSec, hideTimeSec, callback, yPosOffset, color)

	local showSec = mDefApperTimeSec
	if apperTimeSec ~= nil then
        showSec = apperTimeSec
    end
    local hideTime = mDefHideTimeSec
    if hideTimeSec ~= nil then
        hideTime = hideTimeSec
    end
	

	createToast(parent, showSec, hideTime, strText, yPosOffset, callback, color)
end

function createToast(parent, apperTime, delayTime, strText, yPosOffset, callback, color)
    if parent == nil then
        return
    end
	local toast = parent:getChildByTag(mToasstID)
	if toast then
		apperTime= apperTime/2
		parent:removeChild(toast, true)
		toast = nil
	end
	if toast then
		--return
	else
		
		local mLayer = CCLayerRGBA :create()
		parent:addChild(mLayer,mZorder, mToasstID)
		mLayer:setCascadeOpacityEnabled(true)
		local sprite = CCSprite:create(P("form/toastbg.png"))
		mLayer:setContentSize(sprite:getContentSize())
		sprite:setAnchorPoint(ccp(0.5,0.5))
		mLayer:addChild(sprite, 0)
		sprite:setScaleX(SX(256)/ sprite:getContentSize().width)
		sprite:setScaleY(SY(64) /sprite:getContentSize().height)
		
		sprite:setPosition(ccp(mLayer:getContentSize().width/2, mLayer:getContentSize().height/2))

		local lbSize 	= SZ(SX(256), SY(64))
		lbSize.width 	= lbSize.width - SX(30)
		lbSize.height 	= lbSize.height - SY(8)
		local lb = CCLabelTTF:create(strText, FONT_NAME, FONT_SIZE_L, lbSize, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
		lb:setAnchorPoint(ccp(0.5, 0.5))
		mLayer:addChild(lb, 0, 1)
		lb:setPosition(ccp(mLayer:getContentSize().width/2, mLayer:getContentSize().height/2))
		if color then
			lb:setColor(color)
		end
		--居中显示
		local szParent = parent:getContentSize()
		local yOffset = 0
		if yPosOffset then
			yOffset = yPosOffset
		end
		mLayer:setPosition(ccp(szParent.width/2 - mLayer:getContentSize().width/2,
			szParent.height/2 - mLayer:getContentSize().height/2 + yOffset))

		secondAction3 = CCSequence:createWithTwoActions(CCFadeOut:create(delayTime),
				CCCallFuncN:create(Toast.hide))
		action = CCSequence:createWithTwoActions(
			CCDelayTime:create(apperTime),secondAction3
		  )

		mLayer:runAction(action)
		
		mLayer.callback = callback
		

		--mLayer:registerOnExit("Toast.onExit")
		
	end
	--static CCDelayTime* create(ccTime d);
	--static CCCallFuncN* actionWithScriptFuncName(const char* pszFuncName);
	
end


function hide(node)
	if node.callback then
		node.callback()
		node.callback = nil
	end
	node:getParent():removeChild(node, true)
end


function onExit()
	--mLayer = nil 
	--hide()
end

