-- Server-owned identity, unlock and balance catalog. No Roblox dependencies.
-- Role weights preserve the original wave mix; variant weights divide those slots.
local families=table.freeze({undead='망자',beast='야수',slime='슬라임',crystal='결정체'})
local roles={
 stalker={unlock=0,weight=6,hpScale=1,speedScale=1,contactDamage=8},
 skitter={unlock=12,weight=3,hpScale=.7,speedScale=1.18,contactDamage=6},
 brute={unlock=28,weight=2,hpScale=1.5,speedScale=.68,contactDamage=11},
 caster={unlock=42,weight=2,hpScale=1,speedScale=.85,contactDamage=0},
 ember={unlock=60,weight=1,hpScale=1,speedScale=1,contactDamage=0},
 charger={unlock=32,weight=2,hpScale=1.15,speedScale=1,contactDamage=12},
}
local roleOrder=table.freeze({'stalker','skitter','brute','caster','ember','charger'})
local entries={
 {id='stalker',family='undead',role='stalker',variant='soldier',unlock=0,weight=2,visualAsset='KayKitSkeletonWarrior',displayName='잿빛 해골 병사',roleLabel='해골 근접형',description='고대 왕국의 해골 병사. 플레이어를 추적하며 가까이 붙으면 공격합니다. 정예는 검과 방패로 무장합니다.'},
 {id='skitter',family='undead',role='skitter',variant='rogue',unlock=12,weight=1,visualAsset='KayKitSkeletonRogue',displayName='쌍검 해골 도적',roleLabel='빠른 측면 접근',description='두 자루의 검과 두건을 쓴 해골 도적. 옆으로 파고들어 플레이어를 포위합니다.'},
 {id='brute',family='undead',role='brute',variant='executioner',unlock=28,weight=1,visualAsset='KayKitSkeletonWarriorHeavy',displayName='철갑 해골 집행자',roleLabel='느리고 튼튼한 중갑형',description='큰 도끼와 방패를 든 중갑 해골. 느리지만 체력과 접촉 피해가 높습니다.'},
 {id='caster',family='undead',role='caster',variant='mage',unlock=42,weight=2,visualAsset='KayKitSkeletonMage',displayName='황혼 해골 마도사',roleLabel='지팡이 원거리 마법탄',description='커다란 모자와 지팡이를 든 해골 마법사. 거리를 유지하며 힘을 모아 보라색 마법탄을 쏩니다.',cueColor={226,126,255}},
 {id='ember',family='undead',role='ember',variant='bomber',unlock=60,weight=1,visualAsset='KayKitSkeletonMinionBomber',displayName='불씨 폭탄 운반꾼',roleLabel='폭탄을 안고 접근 후 자폭',description='불붙은 폭탄을 안고 달려옵니다. 붉은 범위가 나타나면 폭발 전에 벗어나거나 처치하세요.'},
 {id='charger',family='beast',role='charger',variant='hound',unlock=32,weight=1,visualAsset='AshHound',displayName='잿불 뿔사냥개',roleLabel='사족 보행과 직선 돌진',description='갈비 갑옷과 긴 꼬리, 잿빛 두개골을 가진 사냥개. 주황색 경로를 예고한 뒤 직선으로 돌진합니다.',cueColor={255,151,75}},
 {id='slime_blob',family='slime',role='stalker',variant='blob',unlock=8,weight=1,visualAsset='VerdantSlime',displayName='초록 방울 슬라임',roleLabel='통통 튀는 근접형',description='초록 젤 몸통으로 통통 튀며 다가오는 슬라임. 가까이 붙으면 몸을 부딪쳐 공격합니다.'},
 {id='slime_spitter',projectileHeight=-.8,family='slime',role='caster',variant='spitter',unlock=48,weight=1,visualAsset='SlimeSpitter',displayName='독방울 슬라임',roleLabel='준비 후 초록 탄환 발사',description='몸을 부풀려 힘을 모은 뒤 초록 점액탄을 쏩니다. 발사 준비를 보고 옆으로 움직이세요. 점액탄은 지속 피해를 남기지 않습니다.',cueColor={145,245,82}},
 {id='slime_bulwark',family='slime',role='brute',variant='bulwark',unlock=36,weight=1,visualAsset='SlimeBulwark',displayName='철갑 왕슬라임',roleLabel='크고 느린 중갑형',description='단단한 갑각을 두른 커다란 슬라임. 이동은 느리지만 체력과 접촉 피해가 높습니다.'},
 {id='crystal_scout',family='crystal',role='skitter',variant='scout',unlock=20,weight=1,visualAsset='CrystalScout',displayName='수정 척후병',roleLabel='작고 빠른 측면 접근',description='작은 수정 조각들이 모인 척후병. 빠르게 옆으로 파고들어 거리를 좁힙니다.'},
 {id='crystal_lancer',family='crystal',role='charger',variant='lancer',unlock=52,weight=1,visualAsset='CrystalLancer',displayName='수정 창돌격병',roleLabel='경로 예고 후 직선 돌진',description='길고 뾰족한 수정 창날을 앞세운 돌격병. 청록색 경로가 나타나면 옆으로 피하세요. 돌진 도중에는 방향을 바꾸지 않습니다.',cueColor={93,231,255}},
 {id='crystal_mage',projectileHeight=0,family='crystal',role='caster',variant='mage',unlock=74,weight=1,visualAsset='CrystalMage',displayName='수정 고리술사',roleLabel='회전 고리와 원거리 결정탄',description='공중에 떠 보이는 수정 핵 주위를 고리가 맴돕니다. 힘을 모은 뒤 청록색 결정탄을 발사하며, 모든 지상 공격에 맞습니다.',cueColor={109,221,255}},
}
local byId={}
for order,entry in ipairs(entries)do
 local role=roles[entry.role]
 entry.order=order;entry.familyName=families[entry.family]
 entry.hpScale=role.hpScale;entry.speedScale=role.speedScale;entry.contactDamage=role.contactDamage
 if entry.role=='caster'and entry.projectileHeight==nil then entry.projectileHeight=1.1 end
 if entry.cueColor then table.freeze(entry.cueColor)end
 table.freeze(entry);byId[entry.id]=entry
end
for _,role in pairs(roles)do table.freeze(role)end
table.freeze(entries);table.freeze(roles);table.freeze(byId)
local function get(kind)return byId[kind]end
local function role(kindOrRole)local entry=byId[kindOrRole];return roles[entry and entry.role or kindOrRole]end
local function pool(elapsed,fieldBossActive)
 local result={}
 for _,id in ipairs(roleOrder)do
  local data=roles[id]
  if elapsed>=data.unlock and not(id=='ember'and fieldBossActive)then
   for _=1,data.weight do table.insert(result,id)end
  end
 end
 return result
end
local function choose(roleId,elapsed,sequence)
 local total=0
 for _,entry in ipairs(entries)do if entry.role==roleId and elapsed>=entry.unlock then total+=entry.weight end end
 if total==0 then return nil end
 local slot=((sequence or 1)-1)%total+1
 for _,entry in ipairs(entries)do
  if entry.role==roleId and elapsed>=entry.unlock then
   slot-=entry.weight;if slot<=0 then return entry.id end
  end
 end
 return nil
end
return table.freeze({Entries=entries,Families=families,Roles=roles,Get=get,Role=role,Pool=pool,Choose=choose})
