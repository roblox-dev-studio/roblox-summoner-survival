-- Pure server-owned catalog, offer lottery and bounded stat helpers.
local A = {}
local definitions = {
 {id="ice_twin",spell="ice",rarity="rare",name="쌍빙창",desc="얼음창을 2발 발사. 다른 적을 우선하고 각 발은 피해 75%."},
 {id="ice_shatter",spell="ice",rarity="epic",name="빙쇄",desc="얼음창 적중 시 반경 5에 50% 파편 피해와 짧은 빙결."},
 {id="lightning_fork",spell="lightning",rarity="rare",name="갈래 번개",desc="연쇄 번개의 최대 타깃 +2. 같은 적은 한 번만 타격."},
 {id="lightning_frozen",spell="lightning",rarity="epic",name="빙결 전도",desc="빙결 또는 둔화 중인 적에게 연쇄 번개 피해 +60%.",requiresAny={"ice","frost"}},
 {id="meteor_wide",spell="meteor",rarity="rare",name="거대 운석",desc="메테오 폭발 반경 +35%. 예고와 폭발도 함께 확대."},
 {id="meteor_echo",spell="meteor",rarity="epic",name="운석의 여진",desc="메테오 착탄 0.65초 후 같은 지점에 50% 피해의 후속 폭발."},
 {id="blades_volley",spell="blades",rarity="rare",name="칠성 결정",desc="충전되는 비전 결정 5개 → 7개. 순서대로 발사."},
 {id="blades_pierce",spell="blades",rarity="epic",name="관통 결정",desc="각 결정이 적을 한 번 더 관통. 같은 적 재타격 없음."},
 {id="frost_wide",spell="frost",rarity="rare",name="광역 한파",desc="서리 폭발 탐지·피해·빙결 반경 +30%."},
 {id="frost_echo",spell="frost",rarity="epic",name="이중 서리",desc="서리 폭발 0.6초 후 현재 위치에서 50% 피해의 추가 냉기 파동."},
 {id="ward_reservoir",spell="ward",rarity="rare",name="깊은 결계",desc="수호 결계 흡수량 +50%, 지속시간 5초 → 7초."},
 {id="ward_pulse",spell="ward",rarity="epic",name="결계 해방",desc="결계 소진·만료 시 반경 8에 최초 흡수량의 75% 피해. 취소 시 발동 안 함."},
 {id="missile_salvo",spell="missile",rarity="rare",name="추적 탄막",desc="추적 마탄 시전마다 탄환 +2. 각 탄환은 한 대상만 타격."},
 {id="missile_hunter",spell="missile",rarity="epic",name="거수 사냥꾼",desc="추적 마탄이 정예·필드보스·드래곤에게 피해 +50%."},
 {id="skyLances_rain",spell="skyLances",rarity="rare",name="칠성 창우",desc="천공의 창 5자루 → 7자루. 추가 두 창은 대각선에 낙하."},
 {id="skyLances_execute",spell="skyLances",rarity="epic",name="천공의 심판",desc="체력 50% 이하 적에게 천공의 창 피해 +50%."},
 {id="lightRing_twin",spell="lightRing",rarity="rare",name="쌍월",desc="광륜을 좌우 12도로 2개 발사. 각각 기존 피해의 70%."},
 {id="lightRing_return",spell="lightRing",rarity="epic",name="귀환의 칼날",desc="돌아오는 광륜 피해 +75%. 출발·귀환 각각 적당 1회."},
 {id="fire_blast",active="fire",rarity="rare",name="작열 화염탄",desc="Q 화염탄 폭발 반경 5 → 7. 착탄 범위가 화면에 표시됨."},
 {id="thunder_chain",active="thunder",rarity="epic",name="뇌창 전도",desc="Q 뇌창 적중 시 근처 최대 2명에 50% 전류. 시전당 추가 타격 2회 제한."},
 {id="aether_execute",active="aetherLance",rarity="rare",name="성운 처형",desc="체력 50% 이하 적에게 Q 성운창 피해 +50%."},
 {id="iceRush_wide",active="iceRush",rarity="rare",name="빙하 대로",desc="Q 빙하 쇄도 폭 +50%. 기둥 연출과 판정 함께 확대."},
 {id="quick_cast",rarity="common",name="신속 시전",desc="자동 마법 재사용 주기 -8%p. 최대 3회, Q·골렘·비행 시간 제외.",max=3},
 {id="active_focus",rarity="common",name="집중된 주문",desc="Q 재사용 주기 -15%p. 최대 2회, 7초 → 최저 4.9초.",max=2},
 {id="lucky_charm",rarity="common",name="행운의 부적",desc="행운 +20. 다음 무작위 카드의 희귀·영웅 등급 가중치 증가.",max=3},
}
local byId={}
for _,d in ipairs(definitions) do byId[d.id]=d end
A.Definitions=definitions
A.Labels={ice="빙결 얼음창",lightning="연쇄 번개",meteor="메테오",blades="비전 결정",skyLances="천공의 창",frost="서리 폭발",missile="추적 마탄",ward="수호 결계",lightRing="성운 광륜",golem="골렘"}
A.SpellOrder={"ice","lightning","meteor","blades","skyLances","frost","missile","ward","lightRing","golem"}
local descriptions={ice="피해 +8 · 빙결 +0.1초 · 둔화 +0.4초",lightning="피해 +7 · 연쇄 타깃 +1",meteor="피해 +22 · 반경 +1 · 주기 -0.3초",blades="결정 피해 +4 · 재충전 -0.35초",skyLances="창 피해 +8 · 주기 -0.4초",frost="피해 +8 · 반경 +1 · 빙결 +0.2초",missile="피해 +7 · 짝수 단계에 탄환 +1",ward="흡수량 +12 · 주기 -0.3초",lightRing="피해 +8 · 주기 -0.25초",golem="내려찍기·강타 피해와 범위 증가"}
function A.Count(s,id) return (s.augments and s.augments[id]) or 0 end
function A.Has(s,id) return A.Count(s,id)>0 end
function A.Luck(s) return math.min(60,A.Count(s,"lucky_charm")*20) end
function A.Cooldown(s,base) return base*(1-.08*math.min(3,A.Count(s,"quick_cast"))) end
function A.ActiveCooldown(s) return 7*(1-.15*math.min(2,A.Count(s,"active_focus"))) end
function A.Damage(s,kind,base,e,returning)
 if kind=="lightning" and A.Has(s,"lightning_frozen") and ((e.frozen or 0)>0 or (e.slow or 0)>0)then base*=1.6 end
 if kind=="missile" and A.Has(s,"missile_hunter") and (e.elite or e.isBoss or e.isFieldBoss)then base*=1.5 end
 if ((kind=="skyLances" and A.Has(s,"skyLances_execute"))or(kind=="aetherLance"and A.Has(s,"aether_execute")))and e.maxHp and e.hp<=e.maxHp*.5 then base*=1.5 end
 if kind=="lightRing"and returning and A.Has(s,"lightRing_return")then base*=1.75 end
 return base
end
function A.Weights(s)
 local luck=A.Luck(s)
 return {common=70-.25*luck,rare=25+.2*luck,epic=5+.05*luck}
end
function A.Eligible(s,d)
 if A.Count(s,d.id)>=(d.max or 1) then return false end
 if d.spell and ((s[d.spell]or 0)<(d.rarity=="epic" and 2 or 1) or (s.loadout and not table.find(s.loadout,d.spell))) then return false end
 if d.active and (s.activeSkill or "fire")~=d.active then return false end
 if d.requiresAny then
  local found=false
  for _,id in ipairs(d.requiresAny)do if (s[id]or 0)>0 and (not s.loadout or table.find(s.loadout,id))then found=true end end
  if not found then return false end
 end
 return true
end
local function item(d,s)
 return {id="aug_"..d.id,title=d.name,desc=d.desc,tag=d.active and "Q 전용" or (d.spell and A.Labels[d.spell] or "공통 증강"),rarity=d.rarity,level=A.Count(s,d.id)+1,max=d.max or 1,kind="augment"}
end
function A.Pool(s)
 local levels,pool={},{}
 for _,id in ipairs(A.SpellOrder)do
  local level=s[id]or 0
  if level>0 and level<5 and (id=="golem" or not s.loadout or table.find(s.loadout,id))then
   table.insert(levels,{id=id,title=A.Labels[id].." 강화",desc=descriptions[id],tag="단계 성장",rarity="common",level=level+1,kind="level"})
  end
 end
 for _,d in ipairs(definitions)do if A.Eligible(s,d)then table.insert(pool,item(d,s))end end
 for _,d in ipairs({
  {id="vitality",title="생명의 축복",desc="최대 체력 +15 · 체력 30 회복"},
  {id="agility",title="바람의 발걸음",desc="이동 속도 +2 · 최대 3회",max=3},
  {id="magnet",title="경험치 자석",desc="수집 반경 +3 · 최대 3회",max=3},
 })do if not d.max or (s[d.id]or 0)<d.max then
  table.insert(pool,{id=d.id,title=d.title,desc=d.desc,tag="생존·수집",rarity="common",level=(s[d.id]or 0)+1,kind="utility"})
 end end
 return levels,pool
end
local function probabilities(pool,weights)
 local available,total={},0
 for _,v in ipairs(pool)do available[v.rarity]=true end
 for tier in pairs(available)do total+=weights[tier]end
 local p={common=0,rare=0,epic=0}
 for tier in pairs(available)do p[tier]=weights[tier]/total*100 end
 return p
end
function A.Choices(s,rng)
 local levels,pool=A.Pool(s)
 local result={}
 -- One level card is guaranteed while an equipped spell/summon can still grow.
 if #levels>0 then table.insert(result,table.remove(levels,rng:NextInteger(1,#levels)))end
 for _,v in ipairs(levels)do table.insert(pool,v)end
 local weights=A.Weights(s)
 local firstOdds=probabilities(pool,weights)
 while #result<3 and #pool>0 do
  local p=probabilities(pool,weights)
  local roll=rng:NextNumber()*100
  local tier,cumulative="common",0
  -- Also handle an inclusive RNG upper endpoint without selecting an empty tier.
  for _,candidate in ipairs({"common","rare","epic"})do
   if p[candidate]>0 then tier=candidate;cumulative+=p[candidate];if roll<cumulative then break end end
  end
  local eligible={}
  for i,v in ipairs(pool)do if v.rarity==tier then table.insert(eligible,i)end end
  local chosen=eligible[rng:NextInteger(1,#eligible)]
  table.insert(result,table.remove(pool,chosen))
 end
 -- Three distinct bounded choices remain even after every upgrade is exhausted.
 for _,d in ipairs({{id="recovery",title="긴급 회복",desc="최대 체력의 35% 회복"},{id="overheal",title="완전 회복",desc="체력을 모두 회복"}})do
  if #result>=3 then break end
  table.insert(result,{id=d.id,title=d.title,desc=d.desc,tag="성장 완료 보충",rarity="common",level=1,kind="utility"})
 end
 return result,firstOdds
end
function A.Apply(s,id)
 local key=string.match(id,"^aug_(.+)$")
 if key then
  local d=byId[key];if not d or not A.Eligible(s,d)then return false end
  s.augments=s.augments or {};s.augments[key]=A.Count(s,key)+1
  return true
 end
 if A.Labels[id]then
  if (s[id]or 0)<=0 or s[id]>=5 or (id~="golem" and s.loadout and not table.find(s.loadout,id))then return false end
 elseif id=="agility" or id=="magnet" then if (s[id]or 0)>=3 then return false end
 elseif id~="vitality" and id~="recovery" and id~="overheal"then return false end
 if id~="recovery" and id~="overheal"then s[id]=(s[id]or 0)+1 end
 return true
end
function A.Summary(s)
 local result={}
 for _,d in ipairs(definitions)do if A.Count(s,d.id)>0 then table.insert(result,{name=d.name,count=A.Count(s,d.id),desc=d.desc,rarity=d.rarity})end end
 return result
end
return A
