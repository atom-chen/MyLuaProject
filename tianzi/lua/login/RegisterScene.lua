--ע��
module("RegisterScene", package.seeall)

local mScene = nil
--�������
local mEditWidth = SX(100)

local mEdAcc--�˺������
local mEdPsw--���������
local mEdConfirm--ȷ�����������
--------------��ťTAG--------------
local tagBtnReg = 1--ע�ᰴť
local tagBtnOldLogin = 2--���û���¼��ť

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
	
	createRegister()
	
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

function close()
	if mScene then	
		mEdAcc = nil
		mEdPsw = nil
		mEdConfirm = nil
		
		mScene = nil
	end
end

--------------���ע��--------------
--����ע��ҳ��
function createRegister()
	--��ť�ص�
	local function menuCallback(tag, tagData)
		if tagData == tagBtnReg then--ע�ᰴť
			local strAcc = mEdAcc:getText()
			local strPsw = mEdPsw:getText()
			local strConfirm = mEdConfirm:getText()
			--�˺ų��Ȳ���
			if string.len(strAcc) < 6 or string.len(strAcc) > 20 then
				Toast.show(mScene, GameString.STR_FARMDYNAMIC_LimitAcc, nil, 0, showEdit)
			elseif string.len(strPsw) < 6 or string.len(strPsw) > 20 then
				Toast.show(mScene, GameString.STR_FARMDYNAMIC_LimitPsw, nil, 0, showEdit)
			--���벻һ��
			elseif strPsw ~= strConfirm then
				Toast.show(mScene, GameString.STR_FARMDYNAMIC_NotEqualPsw, nil, 0, showEdit)
			--�ύע��
			else
				registerReq(strAcc, strPsw)
			end
		elseif tagData == tagBtnOldLogin then--���û���¼��ť
			enterScene(LoginScene.initScene())
		end
	end
	
	--����Layer
	local mLayReg = CCLayer:create()
	mScene:addChild(mLayReg, 0)

	--����
	local spBgImg = CCSprite:create(P("background/background001.jpg"))
	mLayReg:addChild(spBgImg, 0)
	spBgImg:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))
	
	local spBgForm = CCSprite:create(P("form/form571471.png"))
	mLayReg:addChild(spBgForm, 0)
	spBgForm:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))
	local bgSize = spBgForm:getContentSize()
	
	--�����Ϣ
	local spTitle = CCSprite:create(P("text/wjxx001.png"))
	spBgForm:addChild(spTitle, 0)
	spTitle:setAnchorPoint(ccp(0.5, 1))
	spTitle:setPosition(ccp(bgSize.width/2, bgSize.height - SY(15)))
	
	-- �˺�
	local lb = CCLabelTTF:create("", FONT_NAME, FONT_SIZE_M)
	spBgForm:addChild(lb, 0)
	lb:setPosition(ccp(bgSize.width/2, spTitle:getPositionY() - spTitle:getContentSize().height - PY(15)))
	
	local spAcc = CCSprite:create(P("text/account.png"))
	spBgForm:addChild(spAcc, 0)
	spAcc:setAnchorPoint(ccp(1, 0.5))
	spAcc:setPosition(ccp(lb:getPositionX() - mEditWidth*0.55, lb:getPositionY()))
	
	--�˺�Edit
	mEdAcc = Edit.create(lb:getPositionX(), lb:getPositionY(), SZ(mEditWidth, Edit.EDIT_HEIGHT), false, nil, P("dian9/editbox.png"))
	mEdAcc:setAnchorPoint(ccp(0.5, 0.5))
	spBgForm:addChild(mEdAcc, 1)
	
	local lblTip = CCLabelTTF:create(GameString.STR_FARMDYNAMIC_Limit6_20, FONT_NAME, FONT_SIZE_M)
	spBgForm:addChild(lblTip, 1)
	lblTip:setAnchorPoint(ccp(0, 0.5))
	lblTip:setPosition(ccp(lb:getPositionX() + mEditWidth*0.55, lb:getPositionY()))
	
	local spPwd = CCSprite:create(P("text/password.png"))
	spBgForm:addChild(spPwd, 0)
	spPwd:setAnchorPoint(ccp(1, 0.5))
	spPwd:setPosition(ccp(spAcc:getPositionX(), spAcc:getPositionY() - Edit.EDIT_HEIGHT - SY(10)))
	
	--����Edit
	mEdPsw = Edit.create(lb:getPositionX(), spPwd:getPositionY(), SZ(mEditWidth, Edit.EDIT_HEIGHT), true, nil, P("dian9/editbox.png"))
	mEdPsw:setAnchorPoint(ccp(0.5, 0.5))
	spBgForm:addChild(mEdPsw, 1)

	--ȷ������
	local spCkeckPwd = CCSprite:create(P("text/checkpwd.png"))
	spBgForm:addChild(spCkeckPwd, 0)
	spCkeckPwd:setAnchorPoint(ccp(1, 0.5))
	spCkeckPwd:setPosition(ccp(spAcc:getPositionX(), spPwd:getPositionY() - Edit.EDIT_HEIGHT - SY(10)))

	--ȷ������Edit
	mEdConfirm = Edit.create(lb:getPositionX(), spCkeckPwd:getPositionY(), SZ(mEditWidth, Edit.EDIT_HEIGHT), true, nil, P("dian9/editbox.png"))
	mEdConfirm:setAnchorPoint(ccp(0.5, 0.5))
	spBgForm:addChild(mEdConfirm, 1)

	--���ע�ᰴť
	local btnReg = Button.new(P("button/button18070_nor.png"), P("button/button18070_sel.png"), nil, menuCallback)
	spBgForm:addChild(btnReg, 0)
	btnReg:setPosition(ccp(lb:getPositionX() - btnReg:getContentSize().width/2, mEdConfirm:getPositionY() - Edit.EDIT_HEIGHT/2 - btnReg:getContentSize().height - SY(15)))
	btnReg:getMenuItem():setTag(tagBtnReg)
	btnReg:setData(tagBtnReg)
	btnReg:setImgText(P("text/mfzc002.png"))

	--���û���¼��ť
	local lbLoginTip = CCLabelTTF:create(GameString.STR_LOGIN_OLDACCT, FONT_NAME, FONT_SIZE_M)
	spBgForm:addChild(lbLoginTip, 0)
	lbLoginTip:setAnchorPoint(ccp(0, 0))
	lbLoginTip:setPosition(ccp(PX(30), PY(25)))
	
	local lbLoginClick = LinkLabel.new(GameString.STR_LOGIN_LOGGAME, ccc3(16,222,217), FONT_NAME, FONT_SIZE_XL)
	lbLoginClick:setFunc(menuCallback)
	lbLoginClick:setData(tagBtnOldLogin)
	spBgForm:addChild(lbLoginClick, 0)
	lbLoginClick:setAnchorPoint(ccp(0, 0))
	lbLoginClick:setPosition(ccp(lbLoginTip:getPositionX() + lbLoginTip:getContentSize().width, lbLoginTip:getPositionY()))
end

function showEdit()
	if mEdPsw then
	    --mEdPsw:setVisible(true)
	end
	if mEdConfirm then
	    --mEdConfirm:setVisible(true)
	end
end

function hideEdit()
	if mEdPsw then
	    --mEdPsw:setVisible(false)
	end
	if mEdConfirm then
	   --mEdConfirm:setVisible(false)
	end
end

--ע������
function registerReq(username, psw)
	--��¼�û�������
	local info = PersonalInfo.getInfo()
	info.UserName = username
	info.Psw = psw
	
	GWriter:writeInt32("s", info.ServerID)
	GWriter:writeString("username", username)
	GWriter:writeString("pwd", psw)
	
	ExecRequest(mScene, 1010)
end

------------------------------------------
--����ص�
function netCallBack(pScene, lpExternalData)
	if GReader:getActionID() == 1010 then--ע��
		Callback_1010(pScene, lpExternalData)
	end
end

--ע��ص�
function Callback_1010()
	if GReader:getResult() == eGNetSuccess then
		--���봴���û�ҳ��
		enterScene(CreateUserScene.initScene())
	else
		Toast.show(mScene, GReader:readErrorMsg(), nil, 0, showEdit)
	end
end

-- �����Ƿ���ʾFPS
CCDirector:sharedDirector():setDisplayStats(false)

