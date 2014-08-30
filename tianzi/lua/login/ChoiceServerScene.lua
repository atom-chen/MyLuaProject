module("ChoiceServerScene", package.seeall)

local mScene = nil--����
local mServerLayer = nil--node�������б�
local mChoiceLable = nil
local mServerList = nil
local mBox = nil

-- ���� 
local mLoadingNote = nil			-- ��¼����������ʾ
-----------��ťTag-----------
local tagBtnSrv = 1000
 
--�����ı������ڴ˸���ֵ
function init()
	mScene = nil
	mBox = nil
	mServerList = nil
	mLoadingNote = nil			-- ��¼����������ʾ
end

--�˳�����ʱ�ÿ����ж���
function release()
	if mScene then
		mScene = nil
	end
	
	mServerList = nil	--��շ������б�
	mServerLayer = nil	--���node�������б�
	mChoiceLable = nil
	mBox = nil
end

function initScene()
	if mScene ~= nil then
		return nil
	end
	
	init()
	
    local scutScene = ScutScene:new(close, true)
	scutScene:registerCallback(netCallBack)
    mScene = scutScene.root

	--����	
	local spBgImg = CCSprite:create(P("background/choiceserverbg.jpg"))
	mScene:addChild(spBgImg, 0)
	spBgImg:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))
	
	--�����ʺ���Ϣ
	loadAccount()	
	--��ȡ�������б�
	getServerList()

	return mScene
end

-- �����ʺ���Ϣ
function loadAccount()	
	local info = PersonalInfo.getInfo()
	local pIni = ScutDataLogic.CLuaIni:new()
	local bLoad = pIni:Load(P("config/accounts.ini"))
	if bLoad then 
		info.ServerID = pIni:Get("info0", "serverID")
		info.UserName = pIni:Get("info0", "account", "")
		info.Psw = pIni:Get("info0", "pw", "")
	else
		CCLuaLog("load accounts.ini error")
		info.ServerID = 0
		info.UserName = ""
		info.Psw = ""
	end
	pIni:delete()
end

-- ��ȡ�������б�
function getServerList()
	-- ������ȡ�������б�
	local netErrorInfo = {Module = "ChoiceServerScene", DataInfo = {JieKou = 9999}}
	GWriter:writeInt32("ProductId", SystemConfig.pid)
	GWriter:writeInt32("Version", SystemConfig.version)
	GWriter:writeString("ResponseType", "byte")
	ExecRequest(mScene, 9999, netErrorInfo, true)
end

--����ServerID��ȡ���������
function getServerIndexById(svrId)
	for k, v in pairs(mServerList) do
		if v.Id == svrId then
			return k
		end
	end
	
	return nil
end

-- ����Layer
function createLayer()
	local serverLayer = CCLayer:create()
	mScene:addChild(serverLayer, 0)
	
	--Label��ѡ��������������¼�ķ�����
	local curServerName = "--"
	
	local index = getServerIndexById(tonumber(PersonalInfo.getInfo().ServerID))
	if index then
		curServerName = mServerList[index].Name
	end
	
	-- ���ӱ���ī�� λ�ò���
	local spNoteBg = CCSprite:create(P("form/inkbar75868.png"))
	serverLayer:addChild(spNoteBg, 0)
	spNoteBg:setAnchorPoint(ccp(0, 1))--ê�㣺����
	spNoteBg:setPosition(ccp(SX(40), WINSIZE.height - SY(35)))
	
	--ѡ����������������¼��
	mChoiceLable = MultiLabel.new(string.format(GameString.STR_FARMDYNAMIC_ChoiceSvr, curServerName), spNoteBg:getContentSize().width*1.5, FONT_NAME, FONT_SIZE_XL, 0, nil, nil)
	spNoteBg:addChild(mChoiceLable, 0)
	mChoiceLable:setPosition(ccp(spNoteBg:getContentSize().width*0.03, spNoteBg:getContentSize().height/2 - mChoiceLable:getContentSize().height/2))
	
	--�������б�
	mServerLayer = CCNode:create()
	mServerLayer:setContentSize(CCSize(WINSIZE.width, spNoteBg:getPositionY() - spNoteBg:getContentSize().height))
	serverLayer:addChild(mServerLayer, 0)
	mServerLayer:setPosition(ccp(0, 0))
end

-- ˢ�·������б�
function refreshServerLayer()
	if mChoiceLable then
		mChoiceLable:setVisible(true)
	end
	
	mServerLayer:removeAllChildrenWithCleanup(true)
	--����
	local iCol = 3
	local PADDLE = 20--���
	
	--ˮƽ���
	local iXSpace = (WINSIZE.width - PADDLE*2) / iCol;
	local spTemp = CCSprite:create(P("form/inkbar30563.png"))
	local x = PADDLE + iXSpace/2 - spTemp:getContentSize().width/2
	local y = mServerLayer:getContentSize().height - spTemp:getContentSize().height*1.5
	for i in pairs(mServerList) do
		--��ť
		local btnTemp = Button.new(P("form/inkbar30563.png"), P("form/inkbar30563.png"), nil, onClickServer)
		mServerLayer:addChild(btnTemp, 0)
		btnTemp:setPosition(ccp(x, y))
		btnTemp:getMenuItem():setTag(tagBtnSrv + i)
		--����
		local serverName = CCLabelTTF:create(mServerList[i].Name, FONT_NAME, FONT_SIZE_XL)
		btnTemp:getMenuItem():addChild(serverName, 0)
		serverName:setAnchorPoint(ccp(0, 0.5))
		serverName:setPosition(ccp(btnTemp:getContentSize().width*0.1, btnTemp:getContentSize().height/2))
		
		if tonumber(PersonalInfo.getInfo().ServerID) == mServerList[i].Id then
			serverName:setColor(ccYELLOW)
		else
			--serverName:setColor(ccc3(mServerList[i].R, mServerList[i].G, mServerList[i].B))--��ɫ
		end
		
		-- ��һ��Ĭ��Ϊ�·�����
		if i == 1 then
			local lbNewServer = CCLabelTTF:create(GameString.STR_XT_NEW, FONT_NAME, FONT_SIZE_XL)
			btnTemp:getMenuItem():addChild(lbNewServer, 0)
			lbNewServer:setColor(ccRED)
			lbNewServer:setAnchorPoint(ccp(0, 0.5))
			lbNewServer:setPosition(ccp(serverName:getPositionX() + serverName:getContentSize().width, serverName:getPositionY()))
		end
		
		--λ��
		x = x + iXSpace
		if i % iCol == 0 then
			x = PADDLE + iXSpace/2
			y = y - btnTemp:getContentSize().height*1.5
		end
	end
end

-- ѡ�������
function onClickServer(tag)
	local index = tag - tagBtnSrv
	if index < 1 or index > #mServerList then
		index = 1
	end
	--- ѡ�з����������ʾ
	if mLoadingNote then
		mLoadingNote:getParent():removeChild(mLoadingNote, true)
	end
	
	mLoadingNote = CCSprite:create(P("form/form44538.png"))
	mScene:addChild(mLoadingNote, 0)
	mLoadingNote:setPosition(ccp(WINSIZE.width/2, mLoadingNote:getContentSize().height))
	
	local lbNote = CCLabelTTF:create(GameString.STR_FARMDYNAMIC_ChoiceSrv_LOADING, FONT_NAME, FONT_SIZE_M)
	mLoadingNote:addChild(lbNote, 0)
	lbNote:setColor(ccYELLOW)
	lbNote:setPosition(ccp(mLoadingNote:getContentSize().width/2, mLoadingNote:getContentSize().height/2))
	
	--��¼������ID
	PersonalInfo.getInfo().ServerID = mServerList[index].Id
	--���������URL
	ScutDataLogic.CNetWriter:setUrl(mServerList[index].Address)
	
	--��������˺����Զ���¼��������ת������Ϸ�ĵ�¼ҳ��
	login()
end

function login()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene = runningScene or mScene
	
	local info = PersonalInfo.getInfo()
	if string.len(info.UserName) > 0 and string.len(info.Psw) > 0 then
		LoginScene.loginReq(runningScene, info.UserName, info.Psw)
	else -- ���˺����룿��ת����¼����
		enterScene(LoginScene.initScene())
	end
end

function sceneEventHandler(eventType)
	if eventType == kCCNodeOnEnter then
		onEnter()
	else
		onExit()
	end
end

function onEnter()

end

function onExit()

end

function close(bHint)
	local function closeMsg(tag)
		if tag == 0 then
			CCDirector:sharedDirector():endToLua();
		end
	end
    
	if bHint then
		local box = MessageBox.new(GameString.STR_MAIN_EXIT, 2, GameString.STR_OK, GameString.STR_CANCEL, closeMsg)
		box:show(mScene)
	else
		release()		
	end
	
	return false
end

function netCallBack(pScene, lpExternalData)
	local actionID = GReader:getActionID()
	if GReader:getActionID() == 9999 then
		Callback_9999(pScene, lpExternalData)
	elseif GReader:getActionID() == 1000 then --��¼
		LoginScene.Callback_1000(mScene, close)
	end
end

-- ����ص����������б�
function Callback_9999(pScene, lpExternalData)
	local bExtLogin = false
	local nDefaultServerId = 0
	if GReader:getResult() == eGNetSuccess then
		local GetServerListResponse = nil
		local num = GReader:getInt()
		if num ~= 0 then
			GetServerListResponse = {}
			GReader:recordBegin()
			local m_Groups = {}
			GetServerListResponse.Groups = m_Groups
			local nNum3 = GReader:getInt()
			for idx2 = 1, nNum3 do
				local v_item2 = {}
				GReader:recordBegin()
				v_item2.Id = GReader:getInt()
				v_item2.Name = GReader:readString()
				nDefaultServerId = v_item2.Id	--����Ĭ�Ϸ�����Id
				mServerList = {}
				v_item2.Servers = mServerList
				local nNum4 = GReader:getInt()
				for idx3 = 1, nNum4 do
					local v_item3 = {}
					GReader:recordBegin()
					v_item3.Id = GReader:getInt()
					v_item3.Name = GReader:readString()
					v_item3.Address = GReader:readString()
					v_item3.Status = GReader:readString()
					v_item3.R = GReader:getInt()
					v_item3.G = GReader:getInt()
					v_item3.B = GReader:getInt()
					GReader:recordEnd()
					table.push_back(mServerList, v_item3)
				end
				GReader:recordEnd()
				table.push_back(m_Groups, v_item2)
			end
			GReader:recordEnd()
			
			--����Layer
			createLayer()
			
			--ˢ�·������б�
			refreshServerLayer()
		end
	else
		Toast.show(pScene, GReader:readErrorMsg())
	end
end

-- �л�����
function enterScene(scene)
	if scene then
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		if runningScene == nil then
			CCDirector:sharedDirector():runWithScene(scene)
		else
			CCDirector:sharedDirector():replaceScene(scene)
		end
		
		if scene ~= mScene then
			close()
		end
	end
end

--��������ʧ�ܴ���
function netConnectError(info)
	local boxSize = SZ(FORMSIZE.width*0.45, FORMSIZE.height*0.3)
	local box = MSGBOX.new(nil, boxSize)

	-- ����
	local function retry()
		box:hide()
		if info.JieKou == 9999 then
			getServerList()
		end
	end

	-- ����
	local function back()
		box:hide()
		CCDirector:sharedDirector():endToLua();
	end
	
	local boxLayer = CCLayer:create()
	boxLayer:setContentSize(boxSize)
	
	local lblMsg = CCLabelTTF:create(GameString.STR_NETERROR_CONTENT, FONT_NAME, FONT_SIZE_M)
	boxLayer:addChild(lblMsg, 1)
	lblMsg:setAnchorPoint(ccp(0.5, 0.5))
	lblMsg:setPosition(ccp(boxSize.width/2, boxSize.height - lblMsg:getContentSize().height))
	-- �˳�
	local btnBack = Button.new(P("button/button12045_nor.png"), P("button/button12045_sel.png"), nil, back)
	boxLayer:addChild(btnBack, 0)
	btnBack:setText(GameString.STR_EXIT)
	btnBack:setPosition(ccp(boxSize.width/2-btnBack:getContentSize().width-PX(10), PY(15)))
	-- ����
	local btnRetry = Button.new(P("button/button12045_nor.png"), P("button/button12045_sel.png"), nil, retry)
	boxLayer:addChild(btnRetry, 0)
	btnRetry:setText(GameString.STR_RETRY)
	btnRetry:setPosition(ccp(boxSize.width/2+PX(10), btnBack:getPositionY()))	

	box:getContentLayer():addChild(boxLayer, 0)
	--box:setCallBack(callback)
	box:show(mScene)
end
