--���ڴ���Back���Ľű�
module("BackKeyManager", package.seeall)
local mtWinStack = {}	--ά�������˵��Ķ�ջ�������CCNode���� ������Lua�Ķ���
--info = {key=layer func=closeFunc}

function addChildWin(key, closeFunc, parameter)
	if key == nil or closeFunc == nil then
		error("addChildWin parameter error")
	end
	
	local bExisted = false
	for k, v in pairs(mtWinStack) do
		if v.key == key then
			bExisted = true
			break
		end
	end

	if bExisted == false then
		local info = {key = key, func = closeFunc, parameter = parameter}
		table.push_back(mtWinStack, info)
	end
end

function removeChildWin(key)
	local index = nil
	for k, v in pairs(mtWinStack) do
		if v.key == key then
			index = k
			break
		end
	end
	if index then
		table.remove(mtWinStack, index)
	end
end

--�رյ�ǰ�Ķ��㴰��
--�ɹ����� true  ʧ�ܷ���false
function popTopWin()
	if #mtWinStack > 0 then
		local info = mtWinStack[#mtWinStack]
		local bRemove = nil
		if info.func then
		    local f = info.func
			bRemove = f(info.parameter)
		end
		if bRemove ~= false then
			removeChildWin(info.key)
		end
		return true
	else
		return false
	end
end
