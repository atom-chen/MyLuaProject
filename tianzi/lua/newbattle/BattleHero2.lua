BattleHero2 = class("BattleHero2",function(herocfg,isattack,index,pos,battleScene)
    return BattleHero:create(herocfg,isattack,index,pos,battleScene)
end)

function BattleHero2:create(herocfg,isattack,index,pos,battleScene)
   local item = BattleHero2.new(herocfg,isattack,index,pos,battleScene)
   return item
end

function BattleHero2:skill()
    print("battleHero2:skill")
end
 