--登录
module("LoginScene", package.seeall)

--输入框宽度
local mEditWidth = SX(100)
local mScene = nil
 
-------Layer
local mLayLogin--登录

local mEdAcc--账号输入框
local mEdPsw--密码输入框
--------------按钮TAG--------------
local tagBtnNewReg = 4--新用户注册按钮
local tagBtnLogin = 5--登录按钮

--变量初始化 新增的变量需在此赋初值
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
	
	createLogin()
	
	return mScene
end

-- 登录请求
function loginReq(scene, username, psw)
    --设置用户名密码
	local info = PersonalInfo.getInfo()
    info.UserName = username
    info.Psw = psw

	GWriter:writeInt32("s", tonumber(info.ServerID))
	GWriter:writeString("UserName", username)
	GWriter:writeString("Pwd", psw)
	GWriter:writeInt32("V1", SystemConfig.version)
	GWriter:writeInt32("V2", SystemConfig.codeVersion)
	GWriter:writeString("ChannelId", SystemConfig.cid)
	GWriter:writeString("UniqueId", GatMac())
	GWriter:writeInt32("MobileType", GetPlatformType())
	ExecRequest(scene, 1000, nil, true)
end

--------------创建登录页面--------------
function createLogin()
	--本游戏账号按钮回调
	local function menuCallback(tag, tagData)
		if tagData == tagBtnLogin then--登录按钮
			local strAcc = mEdAcc:getText()
			local strPsw = mEdPsw:getText()
			--账号空
			if string.len(strAcc) == 0 then
				Toast.show(mScene, GameString.STR_FARMDYNAMIC_NoneAcc, nil, 0, showEdit)
			--密码空
			elseif string.len(strPsw) == 0 then
				Toast.show(mScene, GameString.STR_FARMDYNAMIC_NonePsw, nil, 0, showEdit)				
			--登录请求
			else
				loginReq(mScene, strAcc, strPsw)
			end
		elseif tagData == tagBtnNewReg then--新用户注册按钮
			enterScene(RegisterScene.initScene())
		end
	end
		
	--创建Layer
	mLayLogin = CCLayer:create()
	mScene:addChild(mLayLogin, 0)
	
	--背景
	local spBgImg = CCSprite:create(P("background/background001.jpg"))
	mLayLogin:addChild(spBgImg, 0)
	spBgImg:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))
	
	local spBgForm = CCSprite:create(P("form/form571471.png"))
	mLayLogin:addChild(spBgForm, 0)
	spBgForm:setPosition(ccp(WINSIZE.width/2, WINSIZE.height/2))
	local bgSize = spBgForm:getContentSize()
	
	--玩家登录
	local spTitle = CCSprite:create(P("text/wjdl003.png"))
	spBgForm:addChild(spTitle, 0)
	spTitle:setAnchorPoint(ccp(0.5, 1))
	spTitle:setPosition(ccp(bgSize.width/2, bgSize.height - SY(15)))

	--账号
	local lb = CCLabelTTF:create("", FONT_NAME, FONT_SIZE_M)
	spBgForm:addChild(lb, 0)
	lb:setPosition(ccp(bgSize.width/2, spTitle:getPositionY() - spTitle:getContentSize().height - PY(15)))
	local spAcc = CCSprite:create(P("text/account.png"))
	spBgForm:addChild(spAcc, 0)
	spAcc:setAnchorPoint(ccp(1, 0.5))
	spAcc:setPosition(ccp(lb:getPositionX() - mEditWidth*0.55, lb:getPositionY()))
		
	--账号Edit
	mEdAcc = Edit.create(lb:getPositionX(), lb:getPositionY(), SZ(mEditWidth, Edit.EDIT_HEIGHT), false, nil, P("dian9/editbox.png"))
	mEdAcc:setAnchorPoint(ccp(0.5, 0.5))
	spBgForm:addChild(mEdAcc, 1)

	--密码
	local spPwd = CCSprite:create(P("text/password.png"))
	spBgForm:addChild(spPwd, 0)
	spPwd:setAnchorPoint(ccp(1, 0.5))
	spPwd:setPosition(ccp(spAcc:getPositionX(), spAcc:getPositionY() - Edit.EDIT_HEIGHT - SY(10)))
	
	--密码Edit
	mEdPsw = Edit.create(lb:getPositionX(), spPwd:getPositionY(), SZ(mEditWidth, Edit.EDIT_HEIGHT), true, nil, P("dian9/editbox.png"))
	mEdPsw:setAnchorPoint(ccp(0.5, 0.5))
	spBgForm:addChild(mEdPsw, 1)

	--登录按钮
	local btnLogin = Button.new(P("button/button18070_nor.png"), P("button/button18070_sel.png"), nil, menuCallback)
	spBgForm:addChild(btnLogin, 0)
	btnLogin:setPosition(ccp(lb:getPositionX() - btnLogin:getContentSize().width/2, mEdPsw:getPositionY() - Edit.EDIT_HEIGHT/2 - btnLogin:getContentSize().height - SY(15)))
	btnLogin:getMenuItem():setTag(tagBtnLogin)
	btnLogin:setData(tagBtnLogin)
	btnLogin:setImgText(P("text/dlyy004.png"))
	
	--注册按钮
	local lbRegTip = CCLabelTTF:create(GameString.STR_LOGIN_NEWACCT, FONT_NAME, FONT_SIZE_M)
	spBgForm:addChild(lbRegTip, 0)
	lbRegTip:setAnchorPoint(ccp(0, 0))
	lbRegTip:setPosition(ccp(PX(30), PY(25)))
	
	local lbRegClick = LinkLabel.new(GameString.STR_LOGIN_FREEREG, ccc3(16,222,217), FONT_NAME, FONT_SIZE_XL)
	lbRegClick:setFunc(menuCallback)
	lbRegClick:setData(tagBtnNewReg)
	spBgForm:addChild(lbRegClick, 0)
	lbRegClick:setAnchorPoint(ccp(0, 0))
	lbRegClick:setPosition(ccp(lbRegTip:getPositionX() + lbRegTip:getContentSize().width, lbRegTip:getPositionY()))		
end

function showEdit()
	if mEdPsw ~= nil then
	    --mEdPsw:setVisible(true)
	end
end

function hideEdit()
	if mEdPsw ~= nil then
	    --mEdPsw:setVisible(false)
	end
end

function close(bNoExit)
	if bNoExit then
		return
	end
	
	if mScene then
		mEdAcc = nil
		mEdPsw = nil
		
		mScene = nil
	end
end

------------------------------------------

-- 网络回调
function netCallBack(pScene, lpExternalData)
	if GReader:getActionID() == 1000 then--登录
		Callback_1000(pScene, close)
	end
end

--//登陆 1000
function Callback_1000(pScene, loginClose)
    if GReader:getResult() == eGNetSuccess then
        local LoginResponse = nil
        if GReader:getInt() ~= 0 then
            LoginResponse = {}
            GReader:recordBegin()
            LoginResponse.Sid = GReader:readString()
            LoginResponse.UserId = GReader:getInt()
            LoginResponse.NickName = GReader:readString()
            LoginResponse.HeadId = GReader:getInt()
            LoginResponse.ServerId = GReader:getInt()
            GReader:recordEnd()
			
			--设置人物昵称
			local info = PersonalInfo.getInfo()
			info.NickName = LoginResponse.NickName;
			info.UserId = LoginResponse.UserId;
			info.HeadId = LoginResponse.HeadId;
			info.ServerID = LoginResponse.ServerId
			ScutDataLogic.CNetWriter:setSessionID(LoginResponse.Sid)
			
			--写入INI
			local pIni = ScutDataLogic.CLuaIni:new()
			local bLoad = pIni:Load(P("config/accounts.ini"))
			pIni:SetInt("info0", "serverID", info.ServerID)
			pIni:Set("info0", "account", info.UserName)
			pIni:Set("info0", "pw", info.Psw)
			pIni:Set("info0", "nickName", info.NickName)
			pIni:SetInt("info0", "pwLength", string.len(info.Psw))
			local bSave = pIni:Save("config/accounts.ini")
			
			--进入游戏
			stopBgMusic()
			loginClose()
			ChoiceServerScene.close()
			enterScene(MainScene.initScene())
        end
    elseif GReader:getResult() == 10006 then--已注册帐号，未创建角色
		enterScene(CreateUserScene.initScene())	
	else
		--账号不存在等登录错误，要重新显示登录界面
		if mScene == nil then
		    enterScene(LoginScene.initScene())
		end
		
		Toast.show(mScene, GReader:readErrorMsg(), nil, 0, showEdit)
    end
end

-- 跳转Scene
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
