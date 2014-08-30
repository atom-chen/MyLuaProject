module("ChatUI", package.seeall)
--0:世界1:私聊2:系统3:国家4:联盟5:阵营
--聊天的类型
local eAll = 100--all为客户端自己加的
local eWrold = 0
local eSys = 2
local eCountry=3
local eUnion = 4
local eCamp = 5

local mMargin = PX(4)
local mChatLayer = nil
local mList = nil
local mListSize = nil
local mButtomLayer = nil
local mBoxFaceLayer = nil
local mLastMsgLayer = nil
local mShowType = 0
local mSendType = 0
local mBtnChangeChatType = nil --更改聊天类型
local mEdit = nil

local mTimerID = nil
local mStayTotalTime = 1200 --聊天信息停留20分钟
local mCurStayTime = 1--当前信息停留剩余时间
local mIntervalTime = 15--发送请求的间隔时间
local mIntervalTimeLeft = 5
local mSendMsgInterval = 3--发送信息的间隔时间
local mLastSendTime = 0--上一次发送信息的时间

function release()
	mChatLayer = nil
	mList = nil
	mListSize = nil
	mButtomLayer = nil
	mBoxFaceLayer = nil
	mLastMsgLayer = nil
	mShowType = 0
	mSendType = 0
	mBtnChangeChatType = nil
	mEdit = nil

	mStayTotalTime = 1200
	mCurStayTime = 1
	mIntervalTime = 15
	mIntervalTimeLeft = 5
	mSendMsgInterval = 3
	mLastSendTime = 0
	
	initMtData()
end

function releaseChat()
	stopTimer()
	
	release()
end

--初始化信息
local mtData = nil
local mChatTpyes = nil
local mFaceCfg={}
function initFaceCfg()
	mFaceCfg[#mFaceCfg+1] = 4
	mFaceCfg[#mFaceCfg+1] = 3
	mFaceCfg[#mFaceCfg+1] = 4
	mFaceCfg[#mFaceCfg+1] = 6
	mFaceCfg[#mFaceCfg+1] = 6
	mFaceCfg[#mFaceCfg+1] = 6
	mFaceCfg[#mFaceCfg+1] = 6
	mFaceCfg[#mFaceCfg+1] = 2
	mFaceCfg[#mFaceCfg+1] = 6
	mFaceCfg[#mFaceCfg+1] = 2
	mFaceCfg[#mFaceCfg+1] = 6
	mFaceCfg[#mFaceCfg+1] = 6
	mFaceCfg[#mFaceCfg+1] = 4
	
	return mFaceCfg
end

-- 获取表情顺序 方便其他地方调用
function getFaceCfg()
	return mFaceCfg
end

function initMtData()
	mtData = {}
	mtData[eAll] = {}
	mtData[eWrold] = {}
	mtData[eSys] = {}
	mtData[eCountry] = {}
	mtData[eUnion] = {}
	mtData[eCamp] = {}
end

--聊天的类型
function initChatType()
	mChatTpyes = {}
	mChatTpyes[eAll] = GameString.STR_CHAT_ALL
	mChatTpyes[eWrold] = GameString.STR_CHAT_SHIJIE
	mChatTpyes[eSys] = GameString.STR_CHAT_XITONG
	mChatTpyes[eCountry] = GameString.STR_CHAT_GUOJIA
	mChatTpyes[eUnion] = GameString.STR_CHAT_LIANMENG
	mChatTpyes[eCamp] = GameString.STR_CHAT_ZHENYING
end

initFaceCfg()
initMtData()
initChatType()

function closeFunc()
	mChatLayer = nil
	mList = nil
	if mEdit then
		--mEdit:remove()
		mEdit = nil
	end
end

--isCDTime
function isInCDTime()
	local nowTime = os.time();
	local isCd = (nowTime - mLastSendTime) > mSendMsgInterval
	if not isCd then
		Toast.show(CCDirector:sharedDirector():getRunningScene(), GameString.STR_CHAT_TOO_QUICK, nil, nil, nil, SY(40))
		return true
	else
		mLastSendTime = nowTime;
		return false;
	end
end

--发送消息
function sendMsg(msg, nType)
	if msg == nil or string.len(msg) == 0 then
		Toast.show(CCDirector:sharedDirector():getRunningScene(), GameString.STR_CHAT_TEXT_EMPTY, nil, nil, nil, SY(40))
	    return 
    end
	if isInCDTime() then
		return 
	end
	GWriter:writeInt32("ChatType", nType);
	GWriter:writeString("Msg", msg);
	GWriter:writeInt32("ReceiverId", 0);
	local data = {ChatType = nType, Msg = msg}
	ExecRequest(MainScene.getMainScene(), 1200, data)
end

function create(parent)
	mLastSendTime= 0
	mShowType = 0
	mBtnChangeChatType = nil
	mBoxFaceLayer = nil
	
	if mtData == nil then
		initMtData()
	end
	
	if mChatTpyes == nil then
		initChatType()
	end

	local tTabData = {}
	tTabData[#tTabData+1] = GameString.STR_CHAT_ALL
	tTabData[#tTabData+1] = GameString.STR_CHAT_XITONG
	tTabData[#tTabData+1] = GameString.STR_CHAT_SHIJIE
	tTabData[#tTabData+1] = GameString.STR_CHAT_GUOJIA
	tTabData[#tTabData+1] = GameString.STR_CHAT_LIANMENG
	tTabData[#tTabData+1] = GameString.STR_CHAT_ZHENYING

	mChatLayer = ChatBox.new(tTabData, tabsFunc, closeFunc)
	mChatLayer:show(parent, 0)
	
	local nButtomLayerHeight = PY(30)
	local size = mChatLayer:getContentLayer():getContentSize()
	mListSize = SZ(size.width, size.height - nButtomLayerHeight*1.5)
	local list = ScutCxControl.ScutCxList:node(mListSize.height, ccc4(24, 24, 24, 0), mListSize)
	list:setSelectedItemColor(ccc3(24, 24, 24), ccc3(24, 24, 24)) --设置选中色 可以是过渡度
	list:setLineColor(ccc3(24, 24, 24))
	list:setHorizontal(false) --
	list:setRowHeight(mListSize.height/10) 
	list:setRowWidth(mListSize.width)
	mList = list
	mChatLayer:getContentLayer():addChild(mList, 0)
	mChatLayer:setSelectIndex(1)
	mList:setPosition(ccp(0, nButtomLayerHeight))
	
	local layer = CCLayer:create()
	layer:setContentSize(SZ(mListSize.width, nButtomLayerHeight))
	mChatLayer:getContentLayer():addChild(layer, 0)
	mButtomLayer = layer
	
	local function btnCallback(tag)
		if tag == 1 then-- 主公要6级以上才能发聊天信息
			if PersonalInfo.getInfo().Level < 6 then
				Toast.show(MainScene.getMainUILayer(), GameString.STR_CHAT_LEVEL_LIMIT)
				return
			end
			
			sendMsg(mEdit:getText(), mSendType)
		elseif tag == 2 then
			initMtData()
			mList:clear()
		elseif tag == 3 then
			if mBoxFaceLayer then
				closeFaceBox()
			else
				showFaceBox()
			end
		elseif tag == 4 then
			if mSendType == eWrold then
				mSendType = eCountry
				mBtnChangeChatType:setText(GameString.STR_CHAT_GUOJIA)
				mChatLayer:setSelectIndex(4)
			elseif mSendType == eCountry then
				mSendType = eUnion
				mBtnChangeChatType:setText(GameString.STR_CHAT_LIANMENG)
				mChatLayer:setSelectIndex(5)
			elseif mSendType == eUnion then
				mSendType = eCamp
				mBtnChangeChatType:setText(GameString.STR_CHAT_ZHENYING)
				mChatLayer:setSelectIndex(6)
			elseif mSendType == eCamp then
				mSendType = eWrold
				mBtnChangeChatType:setText(GameString.STR_CHAT_SHIJIE)
				mChatLayer:setSelectIndex(3)
			end
		end
	end
	local xPos = layer:getContentSize().width
	local yPos = layer:getContentSize().height/2
	local btnSend = Button.new(P("button/sendmsg_nor.png"), P("button/sendmsg_sel.png"), nil, btnCallback)
	btnSend:getMenuItem():setTag(1)
	layer:addChild(btnSend, 0)
	btnSend:setPosition(ccp(xPos - btnSend:getContentSize().width, yPos - btnSend:getContentSize().height/2))
	xPos = xPos - btnSend:getContentSize().width - SX(10)
	
	local btnClear = Button.new(P("button/qingping.png"), P("button/qingping_sel.png"), nil, btnCallback)
	btnClear:getMenuItem():setTag(2)
	layer:addChild(btnClear, 0)
	btnClear:setPosition(ccp(xPos - btnClear:getContentSize().width, yPos - btnClear:getContentSize().height/2))
	xPos = xPos - btnClear:getContentSize().width - SX(10)
	
	local btnFace = Button.new(P("button/biaoqing.png"), P("button/biaoqing_sel.png"), nil, btnCallback)
	btnFace:getMenuItem():setTag(3)
	layer:addChild(btnFace, 0)
	btnFace:setPosition(ccp(xPos - btnFace:getContentSize().width, yPos - btnFace:getContentSize().height/2))
	xPos = xPos - btnFace:getContentSize().width - SX(10)
	
	mBtnChangeChatType = Button.new(P("button/chatbuttonchange_nor.png"), P("button/chatbuttonchange_sel.png"), nil, btnCallback)
	mBtnChangeChatType:getMenuItem():setTag(4)
	layer:addChild(mBtnChangeChatType, 0)
	mBtnChangeChatType:setPosition(ccp(SX(4), yPos - mBtnChangeChatType:getContentSize().height/2))
	xPos = xPos - mBtnChangeChatType:getContentSize().width - SX(10)
	mBtnChangeChatType:setText(GameString.STR_CHAT_SHIJIE)
	mSendType = eWrold
	
	local bgEdit = CCSprite:create(P("form/form59945.png"))
	layer:addChild(bgEdit, 0)
	bgEdit:setAnchorPoint(ccp(0, 0.5))
	bgEdit:setPosition(ccp(mBtnChangeChatType:getPositionX() + mBtnChangeChatType:getContentSize().width + SX(2), layer:getContentSize().height/2))
	bgEdit:setScaleX(xPos / bgEdit:getContentSize().width)

	mEdit = Edit.create(bgEdit:getPositionX() + PX(2), layer:getContentSize().height/2 - PY(1/2), SZ(xPos - PX(4), bgEdit:getContentSize().height - PY(5/2)), false, nil, P("dian9/editbox.png"))
	mEdit:setAnchorPoint(ccp(0, 0.5))
	--mEdit:setMaxLength(100)
	layer:addChild(mEdit, 1)
end

function tabsFunc(index)
	if mShowType == getShowType(index) then
		return
	end
	mShowType = getShowType(index)
	
	clear()
	for k, v in pairs(mtData[mShowType]) do
		appendMsg(v)
	end
	if mBtnChangeChatType ~= nil then
		if mShowType == eWrold then
			mSendType = eWrold
			mBtnChangeChatType:setText(GameString.STR_CHAT_SHIJIE)
		elseif mShowType == eCountry then
			mSendType = eCountry
			mBtnChangeChatType:setText(GameString.STR_CHAT_GUOJIA)
		elseif mShowType == eUnion then
			mSendType = eUnion
			mBtnChangeChatType:setText(GameString.STR_CHAT_LIANMENG)
		elseif mShowType == eCamp then
			mSendType = eCamp
			mBtnChangeChatType:setText(GameString.STR_CHAT_ZHENYING)
		end
	end
	
	if index == 1 and mBtnChangeChatType then
		mSendType = eWrold
		mBtnChangeChatType:setText(GameString.STR_CHAT_SHIJIE)
	end
end

--添加聊天消息(创建添加到list)
function appendMsg(Info)
	if mShowType ~= Info.ChatType and mShowType ~= eAll then
		return 
	end
	local layout = ScutCxControl.CxLayout()
	layout.val_x.t = ScutCxControl.ABS_WITH_PIXEL
	layout.val_y.t = ScutCxControl.ABS_WITH_PIXEL
	layout.wrap = false
	
	local itemWidth = mListSize.width		
	local listItem = ScutCxControl.ScutCxListItem:itemWithColor(ccc3(128,128,128))
	listItem:setOpacity(0)
	listItem:setDrawTopLine(false)
	listItem:setDrawBottomLine(false)

	local label = ChatUI.createMsgLabel(Info, itemWidth)	
	
	mList:setRowHeight(label:getContentSize().height + PY(5))
	layout.val_x.val.pixel_val = mMargin
	layout.val_y.val.pixel_val = 0
	listItem:addChildItem(label, layout)

	if mList:getChildCount() > 30 then			
		mList:DeleteChild(0)
	end
	
	mList:addListItem(listItem, true)
	mList:disableAllCtrlEvent()
end

function getShowType(index)
	local ret = 0
	if index == 1 then
		ret = eAll
	elseif index == 2 then
		ret = eSys
	elseif index == 3 then
		ret = eWrold
	elseif index == 4 then
		ret = eCountry
	elseif index == 5 then
		ret = eUnion
	elseif index == 6 then
		ret = eCamp
	else
		ret = eCamp
	end
	
	return ret
end

function clear()
	if mList then
		mList:clear()
	end
end

--关闭表情layer
function closeFaceBox()
	if mBoxFaceLayer then
		mBoxFaceLayer:getParent():removeChild(mBoxFaceLayer, true)
		mBoxFaceLayer = nil
	end
end

--展现表情layer
function showFaceBox()
	local _Layer = nil	
	local _Size = nil
	local layer = CCLayer:create()--CCLayerColor:create(ccc4(255,0,0,255))--
	_Layer = layer
	_Layer:setContentSize(SZ(mButtomLayer:getContentSize().width - SX(8), PY(12) + SY(10)))
	_Size = _Layer:getContentSize()
	
	local bg = CCScale9Sprite:create(P("dian9/hint.9.png"))
	_Layer:addChild(bg, 0)
	bg:setContentSize(_Layer:getContentSize())
	bg:setAnchorPoint(ccp(0, 0))
	bg:setPosition(ccp(0, 0))
	mBoxFaceLayer = _Layer	
	
	local function itemClick(tag)
		local str = mEdit:getText()
		if str == nil then
			str = ""
		end
		str = str .. "#" .. tonumber(tag)
		mEdit:setText(str)
	end
	
	local nEachWith = _Size.width / #mFaceCfg
	local nHeight = _Size.height
	local menu = nil
	for index = 1, #mFaceCfg, 1 do
		local face = getFaceAnimate(index)
		local nor = CCLayer:create()
		nor:setContentSize(SZ(nEachWith, nHeight))
		nor:addChild(face, 0)
		face:setAnchorPoint(ccp(0.5,0.5))
		face:setPosition(ccp(nEachWith/2, nHeight/2))
		local menuItem = CCMenuItemSprite:create(nor, nil, nil)
		if menu == nil then
			menu = CCMenu:createWithItem(menuItem)
			menu:setContentSize(_Size)
		else
			menu:addChild(menuItem, 0)
		end
		menuItem:setAnchorPoint(ccp(0, 0))
		menuItem:setTag(index)
		menuItem:setPosition(ccp((index - 1)* nEachWith, 0))
		menuItem:registerScriptTapHandler(itemClick)
	end
	_Layer:addChild(menu, 0)
	menu:setPosition(ccp(0, 0))
	mButtomLayer:addChild(_Layer, 0)
	_Layer:setPosition(ccp(SX(4), mButtomLayer:getContentSize().height))
end

--创建表情
function getFaceAnimate(Id)
	Id = tonumber(Id)
	local num = mFaceCfg[Id]
	if num == nil then
		return 
	end
	
	local animFrames = CCArray:createWithCapacity(num)
	local spriteloading = nil
	for i = 1, num, 1 do
		local strPath = P(string.format("icon/chatface/%01d/%03d.png", Id, i))
		local texture = CCTextureCache:sharedTextureCache():addImage(strPath)
		local txSize = texture:getContentSize()
		local frame0 = CCSpriteFrame:createWithTexture(texture, CCRectMake(0, 0, txSize.width, txSize.height))
		animFrames:addObject(frame0)
		if spriteloading == nil then
			spriteloading = CCSprite:createWithSpriteFrame(frame0)
		end
	end

	local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.3)
	animFrames = nil
	animate = CCAnimate:create(animation);
	spriteloading:runAction(CCRepeatForever:create(animate))

	return spriteloading
end

function getFaceIcon(Id)
	return  P(string.format("icon/chatface/%01d/%03d.png", Id, 1))
end

--开始聊天的计时器
function initTimer()
	CCLuaLog("====== initTimer ChatUI =======")
	local function tick(dt)
		mIntervalTimeLeft = mIntervalTimeLeft - dt
		mCurStayTime = mCurStayTime - dt
		
		if mCurStayTime <= 0 then
			mCurStayTime = 0
		end
		
		if mIntervalTimeLeft <= 0 then
			mIntervalTimeLeft = mIntervalTime
			if PersonalInfo.getInfo().Level >= 2 then
				requestMsg()
			end
		end
	end

	if mTimerID == nil then
		mTimerID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1, false)
	end
end

function requestMsg()
	----GWriter:writeInt32("Type", GetPlatformType())
	ExecRequest(MainScene.getMainScene(), 1201, nil, false)
end

function stopTimer()
	if mTimerID then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(mTimerID)
		mTimerID = nil
	end
end

--添加信息到mtData中
function addMsgToData(data)
	if mtData == nil then
		initMtData()
	end
	
	appendMsgInfo(mtData[eAll], data)
	if data.ChatType == eSys then
		appendMsgInfo(mtData[eSys], data)
	end
	if data.ChatType == eWrold then
		appendMsgInfo(mtData[eWrold], data)
	end
	if data.ChatType == eCountry then
		appendMsgInfo(mtData[eCountry], data)
	end
	if data.ChatType == eUnion then
		appendMsgInfo(mtData[eUnion], data)
	end
	if data.ChatType == eCamp then
		appendMsgInfo(mtData[eCamp], data)
	end
end

--增加一条消息
function appendMsgInfo(tData, info)
	table.push_back(tData, info)
	--超过30 删掉第一条
	if #tData > 30 then
		table.remove(tData, 1)
	end
end

--判断是否在聊天窗口，
function isShow()
	if mChatLayer then
		return true
	end
	
	return false
end

--显示最后一条消息
function showLastMsg(info)
	if mLastMsgLayer then
		mLastMsgLayer:getParent():removeChild(mLastMsgLayer, true)
		mLastMsgLayer = nil
	end
	local nWidth = SX(420)
	local lb = createMsgLabel(info, nWidth)
	local layer = CCLayer:create()
	local size = SZ(nWidth + SX(6), lb:getContentSize().height + SY(4))

	local bg = CCSprite:create(P("form/chatlayer.png"))
	layer:addChild(bg, 0)
	bg:setScaleX( (WINSIZE.width - PX(60)) / bg:getContentSize().width)
	bg:setScaleY(size.height / bg:getContentSize().height)
	bg:setAnchorPoint(ccp(0, 0))
	bg:setPosition(cpp(0, 0))
	layer:setContentSize(SZ(WINSIZE.width - PX(60), size.height))
	layer:addChild(lb, 0)
	lb:setPosition(ccp(SX(3), layer:getContentSize().height/2 - lb:getContentSize().height/2))
	
	local function btnCallback()
		mLastMsgLayer:getParent():removeChild(mLastMsgLayer, true)
		mLastMsgLayer = nil
		ChatUI.create(MainScene.getMainUILayer())
	end
	
	local btn = Button.newFromSprite(layer, nil, nil, btnCallback)
	layer:setPosition(ccp(0, 0))
	MainScene.getMainUILayer():addChild(btn, 0)
	--local yPos = MainUI.getButtomLayer():getPositionY() + MainUI.getButtomLayer():getContentSize().height
	local yPos = PY(10) --TODO
	btn:setPosition(ccp(-btn:getContentSize().width, yPos + SY(4)))
	mLastMsgLayer = btn
end

function moveLastMsgLayer(pt, bVisible)
	if mLastMsgLayer then
		pt.y = mLastMsgLayer:getPositionY()
		
		if bVisible then
			pt.x = SY(4)
		else
			pt.x = -1*mLastMsgLayer:getContentSize().width
		end
		local action = CCMoveTo:create(0.5 , pt)
		mLastMsgLayer:runAction(action)
	end	
end

function netCallBack(pScene, lpExternalData, actionId)
	if actionId == 1201 then
		Callback_1201(pScene, lpExternalData)
	elseif actionId == 1200 then
		Callback_1200(pScene, lpExternalData)
	end
end

--发送即时聊天
function Callback_1200(pScene, lpExternalData)
	if GReader:getResult() == eGNetSuccess then
		
		Callback_1201(pScene, 1) --1明确现在是在聊天界面
		
		if mEdit then
			mEdit:setText("")
		end
	else
		Toast.show(pScene, GReader:readErrorMsg())
	end
end

--//获取聊天消息 1201
function Callback_1201(pScene, lpExternalData)
    if GReader:getResult() == eGNetSuccess then
        local GetChatResponse = nil
        if GReader:getInt() ~= 0 then
            GetChatResponse = {}
            GReader:recordBegin()
            local m_Items = {}
            GetChatResponse.Items = m_Items
            local nNum1 = GReader:getInt()
            for idx0 = 1, nNum1 do
                local v_item0 = {}
                GReader:recordBegin()
                v_item0.SenderId = GReader:getInt()
                v_item0.SenderName = GReader:readString()
                v_item0.Vip = GReader:getInt()
                v_item0.Msg = GReader:readString()
                v_item0.SendTime = GReader:getInt()
                v_item0.ChatType = GReader:getInt()
                v_item0.ReputeTitle = GReader:readString()
                v_item0.CharmTitle = GReader:readString()
                GReader:recordEnd()
                table.push_back(m_Items,v_item0)
			   
				addMsgToData(v_item0)
				if isShow() then --如果可见　直接Add　到List上
					if mShowType == eAll or mShowType == v_item0.ChatType then
						appendMsg(v_item0)
					end
				else--在主界面只显示最后一条
					if idx0 == nNum1 then
						mCurStayTime = mStayTotalTime
						showLastMsg(v_item0)
						moveLastMsgLayer(ccp(SX(4), mLastMsgLayer:getPositionY()), true)
					end
				end
            end
			
			if(nNum1 == 0) and mLastMsgLayer ~= nil and mCurStayTime == 0 then--移除主界面最后一条信息
				moveLastMsgLayer(ccp(SX(4), mLastMsgLayer:getPositionY()), false)
			end
			
            GetChatResponse.HasNewWar = GReader:getBYTE() == 1
            GetChatResponse.NewMailNumber = GReader:getInt()
            GetChatResponse.LaveBuyCoinNum = GReader:getInt()
            GReader:recordEnd()
        end
    else
        Toast.show(pScene, GReader:readErrorMsg())
    end
end

function getData(sec)
	local nDate = os.date("*t", sec)
	local nCurrent = os.date("*t")
	local dateA = os.time({year = nDate.year, month = nDate.month, day = nDate.day})
	local dateB = os.time({year = nCurrent.year, month = nCurrent.month, day = nCurrent.day})
	local dis = math.floor((dateB - dateA) / 86400)
	local str
	if dis == 0 then
		str = string.format("%02d:%02d",nDate.hour, nDate.min)
	elseif dis == 1 then
		str = string.format("%s %02d:%02d", GameString.STR_FARMDYNAMIC_YESTERDAY, nDate.hour, nDate.min)
	elseif dis == 2 then
		str = string.format("%s %02d:%02d", GameString.STR_FARMDYNAMIC_OTHERDAY, nDate.hour, nDate.min)
	else
		str = string.format("%04d-%02d-%02d %02d:%02d", nDate.year, nDate.month, nDate.day, nDate.hour, nDate.min)
	end
	
	return str
end

function getColor(showType)
	local color = nil
	if showType == eAll then
		color = ccc3(245,31,31)
	elseif showType == eSys then
		color = ccRED--ccc3(255,220,40)
	elseif showType == eWrold then
		color = ccc3(0,90,255)
	elseif showType == eCountry then
		color = ccc3(95,224,1)
	elseif showType == eUnion then
		color = ccc3(95,224,1)
	else
		color = ccc3(95,224,1)
	end
	
	return color
end

--组装消息
function createMsgLabel(info, itemWidth)
	local message = info.Msg
	local xmlContent="<?xml version='1.0' encoding='utf-8'?>"
	local str = GameString.STR_TABLEFT .. (mChatTpyes[info.ChatType] or GameString.STR_CHAT_ALL) .. GameString.STR_TABRIGHT
	
	local color = getColor(info.ChatType)
	xmlContent = xmlContent .. string.format("<label color='%d,%d,%d'>%s</label>", color.r, color.g, color.b, str)
	
	local commonColor = ccc3(38, 242, 249)
	if info.SenderName  then--
		local str = info.SenderName 
		userdata = 'aaaa' tag = '11' class = 'true'
		xmlContent = xmlContent .. string.format("<label color='%d,%d,%d' userdata='" .. tostring(info.SenderId)
		.. "' tag='1' class='true'>%s</label>", commonColor.r, commonColor.g, commonColor.b, str)	
	end

	if info.CharmTitle and string.len(info.CharmTitle) > 0 then
		local str = GameString.STR_TABLEFT .. info.CharmTitle .. GameString.STR_TABRIGHT 
		xmlContent = xmlContent .. string.format("<label color='255,85,245'>%s</label>", str)	
	end
	
	--if info.Vip and info.Vip > 0 then
	--	local strPath = P(string.format("icon/vip/vip%01d.png", info.Vip))
	--	xmlContent = xmlContent .. "<image src='" ..strPath .. "'/>"
	--end

	local str = GameString.STR_CHAT_SAY
	xmlContent = xmlContent .. string.format("<label color='%d,%d,%d'>%s</label>", commonColor.r, commonColor.g,commonColor.b, str)

	if string.sub(message, 1, 6) == "<label" or string.sub(message, 1, 6) == "<image" then
		xmlContent = xmlContent .. message
		xmlContent = xmlContent .. string.format(("<label>(%s)</label>"), getData(info.SendTime));	
	else
		if info.SenderName then--判断如果是玩家聊天　则替换\r\n
		    message = repleaseReturn(message)
		end
		xmlContent = xmlContent .. transFace(message)
		xmlContent = xmlContent ..string.format(("<label>(%s)</label>"), getData(info.SendTime));
	end
	
	local function linkFunc(tag, userData)
		if userData ~= nil and #userData > 0 then
			local userId = tonumber(userData[1])
			if tag == 1 then
				showUserInfo(MainScene.getMainScene(), userId)
			end
		end
		
	end
	local label = MultiLabel.new(xmlContent, itemWidth - mMargin*2, nil, nil, nil, getFaceAnimate, linkFunc)	
	
	return label
end

function repleaseReturn(str)
	str = string.gsub(str, "\r\n", "\n")
	local enterTimes = 0;
	local findStart = 1;
	local maxTimes = 3;
	while true do
		local keyStart, keyend = string.find(str, "\n", findStart);				
		if keyStart then
			findStart = keyend + 1;
			enterTimes = enterTimes + 1;	
			if enterTimes >= maxTimes then
				break;
			end
		else
			break;
		end					
	end
	if enterTimes >= maxTimes then
		str = string.gsub(str, "\n", "");
	end
	return str
end

--转义表情
function transFace(strContent)
	local xmlContent = ""
	
	while true do
		if string.len(strContent) > 0 then
			local startIndex, endIndex = string.find(strContent, "#%d+")
			if startIndex then
				if startIndex > 1 then
					local str = string.sub(strContent, 1, startIndex-1)
					if Font.stringTrim(str) ~= "" then
						xmlContent = xmlContent .. string.format("<label>%s</label>", XmlParser:ToXmlString(str))
					end
				end
				local faceId = tonumber(string.sub(strContent, startIndex+1, endIndex))
				if faceId >= 1 and faceId <= #mFaceCfg then
					xmlContent = xmlContent ..string.format("<image isani='true' userData='%d'/>", faceId)
				else
					local str = string.sub(strContent, startIndex, endIndex)
					if Font.stringTrim(str) ~= "" then
						xmlContent = xmlContent .. string.format("<label>%s</label>", XmlParser:ToXmlString(str))
					end
				end				
				strContent = string.sub(strContent, endIndex+1, string.len(strContent))				
			else
				if Font.stringTrim(strContent) ~= "" then
					xmlContent = xmlContent .. string.format("<label>%s</label>", XmlParser:ToXmlString(strContent))
				end
				
				break;
			end
		else
			break;
		end
	end
	
	return xmlContent
end

