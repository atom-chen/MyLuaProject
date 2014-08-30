--用于封装获取各种图片路径的
module("ImagePool", package.seeall)

--获得玩家头像
function getPlayerHead(Id)
    if Id == nil or Id < 1 or Id > 12 then
        Id = 1
    end
	
	local strPath = string.format("playerhead/%03d.png", Id)
	
	return P(strPath)
end

