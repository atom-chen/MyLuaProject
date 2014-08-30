require "extern"

function handler(target, method)
    return function(...)
        return method(target, ...)
    end
end 

MyHero = class("MyHero", function(str)
    return  CCArmature:create(str)
end)



function MyHero:ctor()
    print("hello myHero")
    self:getAnimation():registerMovementHandler(handler(self, self.MovementEventCallFun))
    self:getAnimation():regisetrFrameHandler(handler(self, self.FrameEventCallFun))
end

function MyHero:MovementEventCallFun(armature,moveevnettype,movementid)
    print(movementid..moveevnettype)
end

function MyHero:FrameEventCallFun(bone,frameeventname,originframeindex,currentframeindex)
	print(movementid)
end

return MyHero

