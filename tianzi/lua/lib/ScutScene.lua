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
-- 未使用
function ScutScene:registerNetErrorFunc(func)
    func = func or function()end
    self.mNetErrorFunc = func
end
-- 未使用
function ScutScene:registerNetCommonDataFunc(func)
    func = func or function()end
    self.mNetCommonDataFunc = func
end
-- 未使用
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


--必须用此方法，用于代替CCDirector里的popScene方法
--维护窗口的堆栈 
function ScutScene:popScene(scene)
	assert(scene ~= nil, "popScene scene==nil")
	if type(scene) == "table" then--处理tableScene 情况
		BackKeyManager.removeChildWin(scene.key)
	else	
		BackKeyManager.removeChildWin(scene)
	end
	CCDirector:sharedDirector():popScene()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

--代替CCDirector pushScene方法
function ScutScene:pushScene(scene)
	CCDirector:sharedDirector():pushScene(scene)
end

