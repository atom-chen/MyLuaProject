require("lib.BackKeyManager")
ScutScene = {}
g_scenes = {}

function ScutScene:new(closeFunc, parameter, o)
	if closeFunc == nil then
		error("ScutScene closeFunc == nil")
	end
    o = o or {}
    if o.root == nil then
        o.root = CCScene:create()
		BackKeyManager.addChildWin(o.root, closeFunc, parameter)
    end
    setmetatable(o, self)
    self.__index = self
    g_scenes[o.root] = o
    return o
end

function ScutScene:registerScriptHandler(func)
    self.root:registerScriptHandler(func)
end

function ScutScene:registerCallback(func)
    func = func or function()end
    self.mCallbackFunc = func
end
-- δʹ��
function ScutScene:registerNetErrorFunc(func)
    func = func or function()end
    self.mNetErrorFunc = func
end
-- δʹ��
function ScutScene:registerNetCommonDataFunc(func)
    func = func or function()end
    self.mNetCommonDataFunc = func
end
-- δʹ��
function ScutScene:registerNetDecodeEnd()
    func = func or function()end
    self.NetDecodeEndFunc = func
end

function ScutScene:execCallback(nTag, nNetState, pData)
	Loading.hide(self.root, nTag, true)
    if 2 == nNetState then -- Succeed
        local reader = ScutDataLogic.CDataRequest:Instance()
        local bValue = reader:LuaHandlePushDataWithInt(pData)	-- TODO
         if not bValue then return end
		--[[
        if self.mCallbackFunc then
            self.mCallbackFunc(self.root)
        end
        if self.mNetCommonDataFunc then
            self.mNetCommonDataFunc()
        end
        netDecodeEnd(self.root, nTag)

        if self.mNetErrorFunc then
            self.mNetErrorFunc()
        end
		--]]
		local bNext = netSucceedFunc()
        if bNext and self.mCallbackFunc then
			self.mCallbackFunc(self.root, nTag)
        end
	else
		netConnectError(self.root, nNetState, nTag)
	end
	-- elseif 3 == nNetState then -- TimeOut
		-- netTimeOutFunc(self.root)
	-- else -- Failed
		-- netFailedFunc(self.root)
    -- end
end


--�����ô˷��������ڴ���CCDirector���popScene����
--ά�����ڵĶ�ջ 
function ScutScene:popScene(scene)
	assert(scene ~= nil, "popScene scene==nil")
	if type(scene) == "table" then--����tableScene ���
		BackKeyManager.removeChildWin(scene.key)
	else	
		BackKeyManager.removeChildWin(scene)
	end
	CCDirector:sharedDirector():popScene()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

--����CCDirector pushScene����
function ScutScene:pushScene(scene)
	CCDirector:sharedDirector():pushScene(scene)
end

