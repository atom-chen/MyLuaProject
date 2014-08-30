module("MainTop", package.seeall)

local mMainTopLayer = nil
local mHeadLayer = nil
---以后有增加变量，请在release()中将其置空
--把所有变量置空
function release()
	mMainTopLayer = nil
	mHeadLayer = nil

end

function getHeadLayer()
	return mHeadLayer
end

function createUI()
	if mMainTopLayer == nil then
		mMainTopLayer = MainScene.getMainUILayer()
	end
	
	createHeadLayer(mMainTopLayer)
	
	updateHeadData()
end

--左上角头像区域UI
function createHeadLayer(parent)
	local textColor = ccc3(0xff, 0xff, 0xff)
	local perInfo = PersonalInfo:getInfo()
	
	local headlayer = CCLayer:create()--CCLayerColor:create(ccc4(255,0,0,255))
	local bgSprite = CCSprite:create(P("form/playerform.png"))
	headlayer:setContentSize(bgSprite:getContentSize())
	parent:addChild(headlayer, 0)
	headlayer:setPosition(ccp(0, WINSIZE.height - headlayer:getContentSize().height))
	mHeadLayer = headlayer
	
	headlayer:addChild(bgSprite, 1)
	bgSprite:setAnchorPoint(ccp(0, 0))
	bgSprite:setPosition(ccp(0, 0))

	local spHead = CCSprite:create(P("playerhead/001.png"))
	headlayer:addChild(spHead, 2)
	spHead:setAnchorPoint(ccp(0.5, 1))
	spHead:setPosition(ccp(spHead:getContentSize().width/2, headlayer:getContentSize().height))
	
	local empty = CCSprite:create(P("icon/exp_empty.png"))
	headlayer:addChild(empty, 1)
	empty:setAnchorPoint(ccp(0, 0.5))
    empty:setPosition(ccp(spHead:getPositionX() + spHead:getContentSize().width/2 + PX(2),
		spHead:getPositionY() - spHead:getContentSize().height/2))
	
	local spProgress = CCProgressTimer:create(CCSprite:create(P("icon/exp_full.png")))
	empty:addChild(spProgress, 0)
	spProgress:setAnchorPoint(ccp(0.5, 0.5))
	spProgress:setPosition(ccp(empty:getContentSize().width/2, empty:getContentSize().height/2))
	spProgress:setType(kCCProgressTimerTypeBar)
	spProgress:setMidpoint(ccp(0, 0))
	spProgress:setBarChangeRate(ccp(1, 0))
	spProgress:setPercentage(10)
	
	local lbExp = CCLabelTTF:create("1000/4111", FONT_NAME, FONT_SIZE_S)
	empty:addChild(lbExp, 0)
	lbExp:setPosition(ccp(empty:getContentSize().width/2 + SX(3), empty:getContentSize().height/2))
	--lbExp:setVisible(false)
	
	local lb = CCLabelTTF:create("Lv.", FONT_NAME, FONT_SIZE_S)
	headlayer:addChild(lb, 1)
	lb:setAnchorPoint(ccp(0, 0))
	lb:setPosition(ccp(empty:getPositionX() + PX(2), empty:getPositionY() + empty:getContentSize().height/2 + PY(1)))
	
	local lbLev = CCLabelTTF:create(perInfo.Level, FONT_NAME, FONT_SIZE_S)
	headlayer:addChild(lbLev, 1)
	lbLev:setColor(textColor)
	lbLev:setAnchorPoint(ccp(0, 0))
	lbLev:setPosition(ccp(lb:getPositionX() + lb:getContentSize().width, lb:getPositionY()))
	
	local lbName = CCLabelTTF:create(perInfo.NickName, FONT_NAME, FONT_SIZE_S)
	lbName:setAnchorPoint(ccp(0, 0))
	lbName:setPosition(ccp(lbLev:getPositionX() + lbLev:getContentSize().width + PX(10), lbLev:getPositionY()))
	headlayer:addChild(lbName, 1)
	lbName:setColor(textColor)

	function updateHeadValue()
		local info = PersonalInfo:getInfo()
		lbLev:setString(tostring(info.Level or 0))
		lbName:setString(tostring(info.NickName))
		lbExp:setString(formatExp(info.Exp or 0, info.NextExp or 0))
		spProgress:setPercentage(math.floor((info.Exp/info.NextExp)*100))
		spHead:setTexture(getTexture(ImagePool.getPlayerHead(info.HeadId)))
	end
end

function updateHeadData()
	if mHeadLayer then
		updateHeadValue()
	end
end

-------------------一些封装回调-------------------------------------------------
--格式化经验
function formatExp(curexp, nextexp)
	local exp1, exp2
	if curexp > 100000 then
		exp1 = string.format("%d%s", math.floor(curexp / 10000), GameString.STR_UINI_RES_WANG)
	else
		exp1 = tostring(curexp)
	end
	--[[
	if nextexp > 1000000 then
		exp2 = string.format("%d%s", math.floor(nextexp / 10000), GameString.STR_UINI_RES_WANG)
	else
		exp2 = tostring(nextexp)
	end--]]
	exp2 = tostring(nextexp)
	
	return string.format("%s/%s", exp1, exp2)
end

--打开指定URL的页面
function gotoWebWithURL(url)
	if GetPlatformType() == ScutUtility.ptANDROID then
		CCLuaLog("======android========")
		Payment.CThirdPayment:getInstance():openUrlJNI(url, 0)
	else
		WebScene.initScene(url)
	end
end

--格式化数值 xxx万
function formatNumber(num)
	if num > 10000 then
		num = string.format("%d%s", math.floor(num/10000), GameString.STR_UINI_RES_WANG)
	else
		num = tostring(num)
	end
	
	return num
end
