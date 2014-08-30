module("PersonalInfo", package.seeall)
info = {
	UserName = "",	 -- 帐号
	Psw = "",
	ServerID = 0,		-- 服务器ID
	NickName = "", 
	UserId = 0,
	HeadId = 1,		 --　Int32　头像Id
	Level = 0,		 --	 int32	等级
	Exp	  = 0,		 --	 int32	当前经验
	NextExp=0,		 --	 int32  下一级升级需要的经验
	
	Money = 0,		 --	 int32	游戏币（RMB）
	Coin  = 0,		 --  Int64	铜钱
}

function getInfo()
	return info
end