--���ڷ�װ��ȡ����ͼƬ·����
module("ImagePool", package.seeall)

--������ͷ��
function getPlayerHead(Id)
    if Id == nil or Id < 1 or Id > 12 then
        Id = 1
    end
	
	local strPath = string.format("playerhead/%03d.png", Id)
	
	return P(strPath)
end

