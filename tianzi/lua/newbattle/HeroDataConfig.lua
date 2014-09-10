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
	[1]   = {HeroId = 1,SoldierId=3,Mount="mount88001",Siteid=100,ad=80,hp=810 * 2,attackspeed=2000,movespeed=400,attackmode="2221"},
	[2]   = {HeroId = 2,SoldierId=3,Mount="mount88002",Siteid=102,ad=75,hp=750 * 2,attackspeed=1800,movespeed=500,attackmode="11112"},
	[151] = {HeroId = 151,SoldierId=3,Mount="mount88004",Siteid=302,ad=110,hp=500 * 2,attackspeed=2300,movespeed=1100,attackmode="222111"},
    [153] = {HeroId = 153,SoldierId=3,Mount="mount88005",Siteid=205,ad=115,hp=700 * 2,attackspeed=1700,movespeed=750,attackmode="21111"},
    --[155] = {HeroId = 155,SoldierId=5,Mount="mount88006",Siteid=301,ad=95,hp=450 * 2,attackspeed=2200,movespeed=1010,attackmode="11112"},
    [177] = {HeroId = 177,SoldierId=3,Mount="mount88007",Siteid=206,ad=98,hp=750 * 2,attackspeed=1500,movespeed=800,attackmode="1112"}
}  

SmallGrid = {
	[1] = ccp(K_WIDTH * 3 ,K_HEIGHT*2),
	[2] = ccp(K_WIDTH * 3 ,K_HEIGHT*4),
	[3] = ccp(K_WIDTH * (3 + 4), K_HEIGHT*2),
	[4] = ccp(K_WIDTH * (3 + 4), K_HEIGHT*4),
	[5] = ccp(K_WIDTH * (3 + 4*2), K_HEIGHT*2),
	[6] = ccp(K_WIDTH * (3 + 4*2), K_HEIGHT*4),
	[7] = ccp(K_WIDTH * (12 + 1), K_HEIGHT*2),
	[8] = ccp(K_WIDTH * (12 + 1) ,K_HEIGHT*4),
	[9]	= ccp(K_WIDTH *  (12 + 4*1 + 1), K_HEIGHT*2),
	[10] = ccp(K_WIDTH * (12 + 4*1 + 1), K_HEIGHT*4),
	[11] = ccp(K_WIDTH * (12 + 4*2 + 1),K_HEIGHT*2),
	[12] = ccp(K_WIDTH * (12 + 4*2 + 1), K_HEIGHT*4)
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


--攻击列表
--AttackList = {HeroConfigs[2],HeroConfigs[1],HeroConfigs[151],HeroConfigs[153],HeroConfigs[177]}
AttackList = {HeroConfigs[1],HeroConfigs[1]}
--防守列表
--DefendList = {HeroConfigs[1],HeroConfigs[2],HeroConfigs[151],HeroConfigs[153],HeroConfigs[177]}
DefendList = {HeroConfigs[151],HeroConfigs[151]}