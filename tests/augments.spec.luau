-- Meaningful pure catalog tests; live projectile/FX checks belong to Studio fixtures.
local A=require('../src/server/flow/Augments')
math.randomseed(1008)
local rng={NextNumber=function()return math.random()end,NextInteger=function(_,a,b)return math.random(a,b)end}
local s={loadout={'ice','meteor','lightning','ward'},ice=2,meteor=2,lightning=2,ward=2,golem=5,activeSkill='fire',augments={}}
assert(#A.Definitions==25)
local seen={}
for _,d in ipairs(A.Definitions)do assert(not seen[d.id]);seen[d.id]=true end
assert(A.Apply(s,'aug_lucky_charm')and A.Luck(s)==20)
assert(A.Apply(s,'aug_lucky_charm')and A.Apply(s,'aug_lucky_charm'))
assert(not A.Apply(s,'aug_lucky_charm')and A.Luck(s)==60)
local w=A.Weights(s);assert(w.common==55 and w.rare==37 and w.epic==8)
assert(not A.Apply(s,'aug_missile_salvo')and not A.Apply(s,'aug_thunder_chain')and not A.Apply(s,'aug_unknown'))
assert(A.Apply(s,'aug_ice_twin')and not A.Apply(s,'aug_ice_twin'))
assert(not A.Apply(s,'ward_Clock')and not A.Apply(s,'fire'))
local noIce={loadout={'lightning','meteor','ward','missile'},lightning=2,meteor=2,ward=2,missile=2,activeSkill='fire'}
assert(not A.Apply(noIce,'aug_lightning_frozen'),'A synergy needs equipped ice/frost')
local low={loadout=s.loadout,ice=1,meteor=1,lightning=1,ward=1,activeSkill='fire'}
local _,odds=A.Choices(low,rng)
assert(odds.epic==0 and math.abs(odds.common+odds.rare-100)<.0001,'Empty epic tier redistributed truthfully')
local endpoint=A.Choices(low,{NextNumber=function()return 1 end,NextInteger=function(_,a)return a end})
assert(#endpoint==3 and endpoint[2].rarity=='rare','Upper RNG endpoint never picks an empty tier')
for i=1,1500 do
 local cards=A.Choices(s,rng);assert(#cards==3 and cards[1].kind=='level')
 local ids={}
 for _,c in ipairs(cards)do
  assert(not ids[c.id],'No repeated cards in one offer');ids[c.id]=true
  assert(c.id~='aug_ice_twin'and c.id~='aug_lucky_charm','Capped augments excluded')
  if c.kind=='level'then assert(table.find(s.loadout,c.id)and s[c.id]<5)end
 end
end
-- At full completion the player must still be able to choose three distinct cards.
local maxed={loadout=s.loadout,ice=5,meteor=5,lightning=5,ward=5,golem=5,activeSkill='fire',augments={},agility=3,magnet=3}
for _,d in ipairs(A.Definitions)do maxed.augments[d.id]=d.max or 1 end
local choices=A.Choices(maxed,rng);assert(#choices==3 and choices[1].id=='vitality')
local base={loadout=s.loadout,ice=2,meteor=2,lightning=2,ward=2,golem=5,activeSkill='fire',augments={}}
local lucky=table.clone(base);lucky.augments={lucky_charm=3}
local function epicRate(state)
 local epics=0
 for _=1,12000 do local cards=A.Choices(state,rng);if cards[2].rarity=='epic'then epics+=1 end end
 return epics/12000
end
local normalRate,luckyRate=epicRate(base),epicRate(lucky)
assert(normalRate>.04 and normalRate<.06 and luckyRate>.068 and luckyRate<.092 and luckyRate>normalRate,'Luck raises sampled eligible epic offers')
local state={augments={quick_cast=3,active_focus=2,missile_hunter=1,skyLances_execute=1,aether_execute=1,lightRing_return=1,lightning_frozen=1}}
assert(math.abs(A.Cooldown(state,10)-7.6)<1e-6 and math.abs(A.ActiveCooldown(state)-2.8)<1e-6)
assert(A.Damage(state,'missile',100,{isBoss=true})==150 and A.Damage(state,'missile',100,{})==100)
assert(A.Damage(state,'skyLances',100,{hp=50,maxHp=100})==150 and A.Damage(state,'skyLances',100,{hp=51,maxHp=100})==100)
assert(A.Damage(state,'aetherLance',100,{hp=50,maxHp=100})==150)
assert(A.Damage(state,'lightRing',100,{},true)==175 and A.Damage(state,'lightRing',100,{},false)==100)
assert(A.Damage(state,'lightning',100,{slow=1})==160 and A.Damage(state,'lightning',100,{slow=0})==100)
print(string.format('PASS: 25 augment eligibility/caps, complete pool fallback, lottery %.2f%% -> %.2f%% epic, bounded combat multipliers',normalRate*100,luckyRate*100))

local styles=require('../src/client/combat/AugmentStyles')
local stylesById={};local visualCount=0
for kind,entries in pairs(styles)do for _,entry in ipairs(entries)do stylesById[entry.id]=kind;visualCount+=1 end end
assert(visualCount==22)
for _,d in ipairs(A.Definitions)do
 if d.spell or d.active then
  assert(stylesById[d.id]==(d.spell or d.active),'Missing augment art: '..d.id)
  assert(A.Visuals({augments={[d.id]=1}},d.spell or d.active)==d.id)
 end
end
assert(A.Visuals({augments={lucky_charm=3}},'ice')=='','Luck never adds combat art')
print('PASS: 22 visual variants match server catalog; common stats add no combat clutter')

assert(A.ActiveCooldown({})==4,"Default Q cooldown follows current combat tuning")
assert(math.abs(A.ActiveCooldown({augments={active_focus=1}})-3.4)<1e-6,"First Q augment keeps the 15 percent reduction")
