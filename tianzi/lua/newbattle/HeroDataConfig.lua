--数据配置
K_SIZE = 32
K_WIDTH = 40
K_HEIGHT = 40
K_HSPACE = 60
--攻击气势增加
AttackQishiAdd =  300
--被攻击气势增加
BeAttackQishiAdd = 150
--杀敌气势增加
KillQishiAdd = 300

MaxQishi = 1000

HeroConfigs = {
	[1]   = {HeroId = 1,SoldierId=1,Mount="mount88001",Siteid=100,ad=80,hp=810,attackspeed=2000,movespeed=800,attackmode="12112"},
	[2]   = {HeroId = 2,SoldierId=2,Mount="mount88002",Siteid=102,ad=75,hp=750,attackspeed=1800,movespeed=1000,attackmode="12112"},
	[151] = {HeroId = 151,SoldierId=3,Mount="mount88004",Siteid=302,ad=110,hp=500,attackspeed=2300,movespeed=2200,attackmode="12"},
    [153] = {HeroId = 153,SoldierId=4,Mount="mount88005",Siteid=205,ad=115,hp=700,attackspeed=1700,movespeed=1500,attackmode="112"},
    [155] = {HeroId = 155,SoldierId=5,Mount="mount88006",Siteid=301,ad=95,hp=450,attackspeed=2200,movespeed=2100,attackmode="12112"},
    [177] = {HeroId = 177,SoldierId=6,Mount="mount88007",Siteid=206,ad=98,hp=750,attackspeed=1500,movespeed=1600,attackmode="12"}
}  

SmallGrid = {
	[1] = ccp(K_WIDTH * 4 -K_HSPACE,K_HEIGHT*(3/2)),
	[2] = ccp(K_WIDTH * 4 -K_HSPACE,K_HEIGHT* (3+3/2)),
	[3] = ccp(K_WIDTH * 8 -K_HSPACE, K_HEIGHT * (3 / 2)),
	[4] = ccp(K_WIDTH * 8 -K_HSPACE, K_HEIGHT * (3 + 3/2)),
	[5] = ccp(K_WIDTH * 12-K_HSPACE,K_HEIGHT * (3 / 2)),
	[6] = ccp(K_WIDTH * 12-K_HSPACE, K_HEIGHT * (3 + 3/2)),
	[7] = ccp(K_WIDTH * 12 +K_HSPACE, K_HEIGHT * (3 / 2)),
	[8] = ccp(K_WIDTH * 12 +K_HSPACE , K_HEIGHT * (3 + 3/2)),
	[9]	= ccp(K_WIDTH * 16 +K_HSPACE, K_HEIGHT * (3 / 2)),
	[10] = ccp(K_WIDTH * 16 +K_HSPACE, K_HEIGHT * (3 + 3/2)),
	[11] = ccp(K_WIDTH * 20+K_HSPACE,K_HEIGHT * (3 / 2)),
	[12] = ccp(K_WIDTH * 20+K_HSPACE, K_HEIGHT * (3 + 3/2))
}
