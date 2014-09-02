--英雄按钮 
--TODO 显示血条气势条,是否是激活状态

local VSPACE = 3
local BarHight = 12

HeroButton = class("HeroButton", function()
	return  CCLayer:create()
end)

--构造函数
function HeroButton:ctor()
   self.menu = nil
   self.menuitem = nil
   self.activesp = nil
   self.hpbar = nil
   self.qishibar = nil
   --回调函数
   self.callfun = nil
end

--创建函数
function HeroButton:Create(heroId,func)
   local  item = HeroButton.new()
   item:createBtn(heroId)
   item:createHp()
   item:createQishi()
   item.callfun = func
   return item
end

--按钮回调
function HeroButton:BtnCallBack(tag)
    if self.callfun then
    	self.callfun(tag,self)
    end
end

--创建按钮
function HeroButton:createBtn(heroId)
    local  norsp  = CCSprite:create(P(string.format("head/herohead_%03d.png",heroId)))
    local menuitem = CCMenuItemSprite:create(norsp, nil, nil)
    menuitem:setTag(heroId)
    menuitem:registerScriptTapHandler(handler(self, self.BtnCallBack))
    local menu = CCMenu:createWithItem(menuitem)
    menu:setContentSize(menuitem:getContentSize())
    menuitem:setAnchorPoint(ccp(0, 0))
    menuitem:setPosition(ccp(0,0))
     
    self:setContentSize(CCSize(menu:getContentSize().width,menu:getContentSize().height + 2 * (VSPACE + BarHight)))
    menu:setPosition(ccp(0, self:getContentSize().height - menu:getContentSize().height)) 
    self:addChild(menu)
    
    local activesp = CCSprite:create(P("herobattle/active.png"))
    self:addChild(activesp,-1)
    activesp:setPosition(ccp(self:getContentSize().width / 2, 2 * (VSPACE + BarHight) + menu:getContentSize().height/2))
    self.activesp = activesp
    self.activesp:setVisible(false)

    self.menu = menu
    self.menuitem = menuitem
end

--创建血条
function HeroButton:createHp()
    local x = self:getContentSize().width / 2
    local y = VSPACE + BarHight + BarHight / 2
    local bg = CCSprite:create(P("herobattle/bg_big.png"))
    self:addChild(bg)
    bg:setPosition(ccp(x, y))

    local hpbarsp = CCSprite:create(P("herobattle/hp1_big.png"))
    self.hpbar = CCProgressTimer:create(hpbarsp)
    self.hpbar:setType(1)
    self.hpbar:setMidpoint(ccp(0, 0))
    self.hpbar:setBarChangeRate(ccp(1,0))
    self.hpbar:setPercentage(100);
    self.hpbar:setAnchorPoint(ccp(0.5,0.5))
    self.hpbar:setPosition(ccp(x, y))
    self:addChild(self.hpbar)

end

--创建气势条
function HeroButton:createQishi()

    local x = self:getContentSize().width / 2
    local y = BarHight / 2 
    local bg = CCSprite:create(P("herobattle/bg_big.png"))
    self:addChild(bg)
    bg:setPosition(ccp(x, y))

    local qishisp = CCSprite:create(P("herobattle/energy_big.png"))
    self.qishibar = CCProgressTimer:create(qishisp)
    self.qishibar:setType(1)
    self.qishibar:setMidpoint(ccp(0, 0))
    self.qishibar:setBarChangeRate(ccp(1,0))
    self.qishibar:setPercentage(0);
    self.qishibar:setAnchorPoint(ccp(0.5,0.5))
    self.qishibar:setPosition(ccp(x, y))
    self:addChild(self.qishibar)
end

--设置是否激活
function HeroButton:setActive(isactive)
   self.activesp:setVisible(isactive)
   self.menuitem:setEnabled(isactive)
end

--设置血量
function HeroButton:setHp(value)
    if value <0 then
       value = 0
    end
    self.hpbar:setPercentage(value)
end

--设置气势
function HeroButton:setQishi(value)
    if value > 100 then
       value = 100
    end
    self.qishibar:setPercentage(value)
end
