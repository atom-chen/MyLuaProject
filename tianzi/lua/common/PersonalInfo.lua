module("PersonalInfo", package.seeall)
info = {
	UserName = "",	 -- �ʺ�
	Psw = "",
	ServerID = 0,		-- ������ID
	NickName = "", 
	UserId = 0,
	HeadId = 1,		 --��Int32��ͷ��Id
	Level = 0,		 --	 int32	�ȼ�
	Exp	  = 0,		 --	 int32	��ǰ����
	NextExp=0,		 --	 int32  ��һ��������Ҫ�ľ���
	
	Money = 0,		 --	 int32	��Ϸ�ң�RMB��
	Coin  = 0,		 --  Int64	ͭǮ
}

function getInfo()
	return info
end