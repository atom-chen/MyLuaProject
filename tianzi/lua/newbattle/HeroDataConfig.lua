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

--英雄配置
HeroConfigs = {
	[1]   = {HeroId = 1,SoldierId=1,Mount="mount88001",skill1id=20001,ultid=10001,Siteid=100,ad=80,ap=80,hp=2620,attackspeed=2000,movespeed=400,attackmode="1122"},
	[2]   = {HeroId = 2,SoldierId=2,Mount="mount88002",skill1id=20002,ultid=10002,Siteid=102,ad=75,ap=75,hp=2500,attackspeed=1800,movespeed=500,attackmode="1212"},
	[151] = {HeroId = 151,SoldierId=3,Mount="mount88004",skill1id=20003,ultid=10003,Siteid=302,ad=110,ap=100,hp=2000,attackspeed=2300,movespeed=1100,attackmode="121112"},
  [153] = {HeroId = 153,SoldierId=4,Mount="mount88005",skill1id=20004,ultid=10004,Siteid=205,ad=115,ap=115,hp=2400,attackspeed=1700,movespeed=750,attackmode="11212",skill1id=20001,ultid=10001},
  [155] = {HeroId = 155,SoldierId=5,Mount="mount88006",skill1id=20001,ultid=10001,Siteid=301,ad=95,ap=95,hp=1900,attackspeed=2200,movespeed=1010,attackmode="112",skill1id=20001,ultid=10001},
  [177] = {HeroId = 177,SoldierId=6,Mount="mount88007",skill1id=20001,ultid=10001,Siteid=206,ad=98,ap=98,hp=2500,attackspeed=1500,movespeed=800,attackmode="1112",skill1id=20001,ultid=10001}
} 

--技能配置
SkillConfigs = {
    [10001] = {id=10001,type=1,damage=330,apadd=0.6,adadd=0,hitrate=100,time=0,bufftype=0,buffvalue=0,buffname=""},
    [10002] = {id=10002,type=2,damage=320,apadd=0,adadd=0.7,hitrate=100,time=0,bufftype=0,buffvalue=0,buffname=""},
    [20001] = {id=20001,type=1,damage=230,apadd=0.7,adadd=0,hitrate=100,time=0,bufftype=0,buffvalue=0,buffname=""},
    [20002] = {id=20002,type=2,damage=220,apadd=0,adadd=0.8,hitrate=100,time=5000,bufftype=1,buffvalue=0.3,buffname="power"},
    [10003] = {id=10003,type=2,damage=360,apadd=0.8,adadd=0,hitrate=100,time=0,bufftype=0,buffvalue=0,buffname=""},
    [20003] = {id=20003,type=1,damage=250,apadd=0,adadd=0.5,hitrate=100,time=0,bufftype=0,buffvalue=0,buffname=""},
    [10004] = {id=10004,type=1,damage=250,apadd=0,adadd=0.6,hitrate=100,time=0,bufftype=0,buffvalue=0,buffname=""},
    [20004] = {id=20004,type=2,damage=460,apadd=0.8,adadd=0,hitrate=100,time=0,bufftype=0,buffvalue=0,buffname=""}
}


SmallOne = {
	[1] = {x=3,y=3}
}
SmallTwo = {
	[1] = {x=3,y=2},
	[2] = {x=3,y=4}
}
SmallThree = {
	[1] = {x=3,y=1},
	[2] = {x=3,y=3},
	[3] = {x=3,y=5}
}

SmallGrid2 = {
	[1] = SmallOne,
	[2] = SmallTwo,
	[3] = SmallThree
}

--大格,英雄数目,从上到下的数目 
function getSmallGrid(bigGrid,herocount,index)
	local posx = 0
	local posy = 0
	local grid = SmallGrid2[herocount][index]
    if bigGrid <= 3 then     
       posx = 4 * (bigGrid-1) + grid.x
       posy = grid.y 
    else
       posx = 12 + (bigGrid -4) * 4 + (4-grid.x) 
       posy = 6 - grid.y      	
    end
    return ccp(posx * K_WIDTH, posy *K_HEIGHT)
end


SoldierShootTime = {  
   ["soldat1"] = 0.15,
   ["soldat2"] = 0.15,
   ["soldat3"] = 0.15,
   ["soldat4"] = 0.15,
   ["soldat5"] = 0.10,
   ["soldat6"] = 0.20
}

--攻击列表
--AttackList = {HeroConfigs[2],HeroConfigs[1],HeroConfigs[151],HeroConfigs[153],HeroConfigs[177]}
AttackList = {HeroConfigs[1],HeroConfigs[1],HeroConfigs[2]}
--防守列表
--DefendList = {HeroConfigs[1],HeroConfigs[2],HeroConfigs[151],HeroConfigs[153],HeroConfigs[177]}
DefendList = {HeroConfigs[151],HeroConfigs[151],HeroConfigs[153]}