-- Public spell descriptions and strict server-side loadout validation.
local SLOT_COUNT=4
local options={
 {id='lightRing',name='성운 광륜',role='초승달 부메랑 · 왕복 관통',desc='빛나는 초승달이 곡선을 그리며 날아갔다가 돌아오며 다시 타격합니다.',color={204,163,255}},
 {id='ice',name='빙결 얼음창',role='빙결 · 밀치기',desc='마법진에서 얼음창을 쏘아 적을 밀치고 얼립니다.',color={132,218,255}},
 {id='lightning',name='연쇄 번개',role='여러 적 연속 타격',desc='하늘에서 내려꽂힌 번개가 주변 적에게 이어집니다.',color={208,191,255}},
 {id='meteor',name='메테오',role='강력한 광역 폭발',desc='거대한 운석이 하늘에서 낙하해 밀집한 적을 강타합니다.',color={255,188,91}},
 {id='blades',name='비전 결정',role='다섯 결정 · 순차 추적 발사',desc='등 뒤의 결정 5개가 한 발씩 적을 추적한 뒤 다시 충전됩니다.',color={128,255,220}},
 {id='skyLances',name='천공의 창',role='상공 마법진 · 다섯 창 순차 낙하',desc='적 머리 위 마법진에서 긴 마법 창들이 차례로 내려꽂힙니다.',color={172,205,255}},
 {id='frost',name='서리 폭발',role='포위 탈출 · 빙결',desc='몸에서 냉기 파동이 퍼져 가까운 적을 한꺼번에 얼립니다.',color={157,234,255}},
 {id='missile',name='추적 마탄',role='강한 적 하나를 집중 공격',desc='보스와 체력이 높은 적을 우선 추적하는 마탄입니다. 범위 피해는 없습니다.',color={216,159,255}},
 {id='ward',name='수호 결계',role='피해 흡수 · 생존',desc='주기적으로 보호막을 펼칩니다. 흡수량을 다 쓰면 깨집니다.',color={255,223,146}},
}
local allowed={};for _,v in ipairs(options)do allowed[v.id]=true end
local function validate(ids)
 if type(ids)~='table' then return nil end
 local result,seen,count={},{},0
 for key,id in pairs(ids)do
  if type(key)~='number' or key%1~=0 or key<1 or key>SLOT_COUNT or type(id)~='string' or not allowed[id] or seen[id] then return nil end
  seen[id]=true;result[key]=id;count+=1
 end
 if count~=SLOT_COUNT then return nil end
 for i=1,SLOT_COUNT do if not result[i]then return nil end end
 return result
end
local activeOptions={
 {id='fire',name='화염탄',desc='정면 불꽃 탄환 · 적중 범위 피해 · 7초'},
 {id='thunder',name='뇌창',desc='정면으로 날아가는 번개 창 · 관통 · 7초'},
 {id='aetherLance',name='성운창',desc='아지랑이 빛의 창 · 관통 · 7초'},
 {id='iceRush',name='빙하 쇄도',desc='정면 얼음 기둥 · 빙결 · 7초'},
}
local activeNames={};for _,v in ipairs(activeOptions)do activeNames[v.id]=v.name end
local function validateActive(id)return type(id)=='string' and activeNames[id]~=nil end
return {Options=options,Validate=validate,SlotCount=SLOT_COUNT,Defaults={'ice','meteor','blades','lightRing'},ActiveOptions=activeOptions,ActiveNames=activeNames,ValidateActive=validateActive}
