--������ɫ
module("CreateUserScene", package.seeall)

local mScene = nil
local mLayer = nil

local mEdGName = nil--���������
-------------tag-------------
local tagBtnHead = 2000--ͷ��
local tagHChecked = 2100--ͷ����ѡ��

--�����б�
local mCountryID = 0
--ͷ���б�
local mHeadID = nil

local mHeadList = {
	{id = 1, headpath = "playerhead/001.png"},
	{id = 2, headpath = "playerhead/002.png"},
	{id = 3, headpath = "playerhead/003.png"},
	{id = 4, headpath = "playerhead/004.png"},
	{id = 5, headpath = "playerhead/005.png"},
	{id = 6, headpath = "playerhead/006.png"},
	{id = 7, headpath = "playerhead/007.png"},
	{id = 8, headpath = "playerhead/008.png"},
	{id = 9, headpath = "playerhead/009.png"},
	{id = 10, headpath = "playerhead/010.png"},
	{id = 11, headpath = "playerhead/011.png"},
	{id = 12, headpath = "playerhead/012.png"}
}

--������ʼ�� �����ı������ڴ˸���ֵ
function init()
	mScene = nil
end

function initScene()
	if mScene ~= nil then
		return nil
	end
	init()
    local scutScene = ScutScene:new(close, true)
	
	scutScene:registerCallback(netCallBack)
	
    mScene = scutScene.root
	
	--����ҳ��
	createLayer()

	return mScene
end

function enterScene(scene)
	if scene then
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		if runningScene == nil then
			CCDirector:sharedDirector():runWithScene(scene)
		else
			CCDirector:sharedDirector():replaceScene(scene)
		end
		
		close()
	end
end

function close(bNoExit)
	if bNoExit then
		return
	end
	
	if mScene then
		--SceneHelper.pomScene(mScene)
		mScene = nil
		
		if mEdGName ~= nil then
			--mEdGName:remove()
			mEdGName = nil
		end
	end
end

--����ҳ��
function createLayer()
	--���
	local PADDLE = 8
	--�������
	local mEditWidth = SX(100)
	--����Layer
	mLayer = CCLayer:create()
	mScene:addChild(mLayer, 0)
	
	--����
	local spBgImg = CCSprite:create(P("background/background002.jpg"))
	mLayer:addChild(spBgImg, 0)
	spBgImg:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))
	
	--���֣����������
	local spGName = CCSprite:create(P("text/qiming.png"))
	mLayer:addChild(spGName, 0)
	spGName:setAnchorPoint(ccp(0, 1))
	spGName:setPosition(ccp(PX(30), WINSIZE.height - PY(30)))
	--���������
	local pt = ccp(0, 0)
	pt.x = spGName:getPositionX()
	pt.y = spGName:getPositionY() - spGName:getContentSize().height - SY(PADDLE) - Edit.EDIT_HEIGHT
	mEdGName = Edit.create(pt.x, pt.y, SZ(mEditWidth, Edit.EDIT_HEIGHT), false, nil, P("dian9/editbox.png"))
	mEdGName:setAnchorPoint(ccp(0, 0.5))
	mLayer:addChild(mEdGName, 1)
	
	--��ť������
	local btnDice = Button.new(P("button/shaizi_nor.png"), P("button/shaizi_sel.png"), nil, randomName)
	mLayer:addChild(btnDice, 0)
	btnDice:setPosition(ccp(pt.x + mEditWidth, pt.y - btnDice:getContentSize().height/2))
	
	--���֣�2��4������
	local labLimit = CCLabelTTF:create(GameString.STR_FARMDYNAMIC_Limit2_4CN, FONT_NAME, FONT_SIZE_L)
	mLayer:addChild(labLimit, 0)
	labLimit:setAnchorPoint(ccp(0, 1))
	labLimit:setPosition(ccp(pt.x, pt.y - Edit.EDIT_HEIGHT/2 - SY(5)))

	--ͷ��
	local hNum = 6--����
	local tempHead = CCSprite:create(P(mHeadList[1].headpath))
	tempHead = nil
	
	--���֣�ѡ��ͷ��
	local spChImg = CCSprite:create(P("text/xztx.png"))
	mLayer:addChild(spChImg, 0)
	spChImg:setAnchorPoint(ccp(0, 1))--ê�㣺����
	spChImg:setPosition(ccp(PX(30), labLimit:getPositionY() - labLimit:getContentSize().height - SY(PADDLE)*5))
	--ѭ��ͷ���б�
	local hX = spChImg:getPositionX()
	local hY = spChImg:getPositionY() - spChImg:getContentSize().height - SY(PADDLE)
	local cX = 0
	for k, v in pairs(mHeadList) do
		local btnHead = Button.new(P(v.headpath), P(v.headpath), nil, headCallBack)
		mLayer:addChild(btnHead, 0)
		btnHead:setPosition(ccp(hX, hY - btnHead:getContentSize().height))
		btnHead:getMenuItem():setTag(tagBtnHead + v.id)
		
		--ѡ��ͼ��
		local spChecked = CCSprite:create(P("icon/checkone4545.png"))
		spChecked:setTag(tagHChecked + v.id)
		mLayer:addChild(spChecked, 1)
		spChecked:setAnchorPoint(ccp(1, 0))--ê�㣺����
		spChecked:setPosition(ccp(btnHead:getPositionX() + btnHead:getContentSize().width, btnHead:getPositionY()))
		spChecked:setVisible(false)
		
		if k > 1 and k % hNum == 0 then
			cX = hX + btnHead:getContentSize().width + SX(PADDLE)
			hX = spChImg:getPositionX()
			hY = hY - btnHead:getContentSize().height - SY(PADDLE)
		else
			hX = hX + btnHead:getContentSize().width + SX(PADDLE)
		end
	end
	
	--���ѡ��һ��ͷ��
	headCallBack(tagBtnHead + mHeadList[math.random(12)].id)
	
	--��ť��������
	local btnJH = Button.new(P("button/chuangjhbutton_nor.png"), P("button/chuangjhbutton_sel.png"), nil, beginCallBack)
	mLayer:addChild(btnJH, 0)
	btnJH:setPosition(ccp(cX, hY))
	
	--���󣺻�ȡ�������
	randomName()
end

--ͷ��ť�ص�
function headCallBack(tag)
	--ͷ��ID
	mHeadID = tag - tagBtnHead
	
	--�޸Ĵ�ͼ��
	for k, v in pairs(mHeadList) do
		local spChecked = mLayer:getChildByTag(tagHChecked + v.id)
		
		if v.id == mHeadID then
			spChecked:setVisible(true)
		else
			spChecked:setVisible(false)
		end
	end
end
	
--���󣺻�ȡ�������
function randomName()
    GWriter:writeInt32("s", PersonalInfo.getInfo().ServerID)
	GWriter:writeInt32("Gender", 1)
	ExecRequest(mScene, 1100)
end

--��������ť�ص�
function beginCallBack(tag)
	if Font.stringLength(mEdGName:getText()) < 2 or Font.stringLength(mEdGName:getText()) > 4 then
		--���ֳ�������
		Toast.show(mScene, GameString.STR_FARMDYNAMIC_LimitGName)
	else
		--���󣺴������
		createUserReq()
	end
end

--���󣺴�����ɫ
function createUserReq()
	local info = PersonalInfo.getInfo()
	
	GWriter:writeInt32("s", info.ServerID)--������ID
	GWriter:writeString("UserName", info.UserName)--�˺�  
	GWriter:writeString("Pwd", info.Psw)--����  
	GWriter:writeString("Nickname", mEdGName:getText())--�ǳ�  
	GWriter:writeString("Gender", 0)--�Ա�  
	GWriter:writeString("HeadId", mHeadID)--ͷ��Id
	GWriter:writeString("UniqueId", GatMac())--�豸��
	GWriter:writeString("ChannelId", SystemConfig.cid)--����id
	GWriter:writeString("Mobiletype", GetPlatformType())--ƽ̨  
	GWriter:writeString("Country", mCountryID)--���� 
	
	GWriter:writeInt32("AccountType", 0)
	--if SystemConfig.cid == 2 then --91ƽ̨
	--	GWriter:writeInt32("AccountType", 3)
	--end
	GWriter:writeString("UserIdentity", info.UserId)
	GWriter:writeString("TeleNo", "")
	ExecRequest(mScene, 1001)
end

------------------------------------------
--����ص�
function netCallBack(pScene, lpExternalData)
	if GReader:getActionID() == 1100 then--�������
		Callback_1100(pScene, lpExternalData)
	elseif GReader:getActionID() == 1001 then--������ɫ
		Callback_1001(pScene, lpExternalData)
	end
end

--//��ȡһ��������ע���ǳ� 1100
function Callback_1100(pScene, lpExternalData)
    if GReader:getResult() == eGNetSuccess then
        local GetRndNameResponse = nil
        if GReader:getInt() ~= 0 then
            GetRndNameResponse = {}
            GReader:recordBegin()
            GetRndNameResponse.NickName = GReader:readString()
            GReader:recordEnd()
        end
		
		--��������
		mEdGName:setText(GetRndNameResponse.NickName)
    else
        Toast.show(pScene, GReader:readErrorMsg())
    end
end

--��Ӧ��������ɫ
function Callback_1001()
	if GReader:getResult() == eGNetSuccess then
		if mEdGName then
			--mEdGName:remove()
			mEdGName = nil
		end
		
		LoginScene.loginReq(pScene, PersonalInfo.getInfo().UserName, PersonalInfo.getInfo().Psw)
	else
		Toast.show(mScene, GReader:readErrorMsg())
	end
end
