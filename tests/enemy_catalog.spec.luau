-- Pure catalog regression: role pressure stays fixed as family variants unlock.
local catalog=require('../src/server/world/EnemyCatalog')
local old={stalker={0,6,1,1,8},skitter={12,3,.7,1.18,6},brute={28,2,1.5,.68,11},caster={42,2,1,.85,0},ember={60,1,1,1,0},charger={32,2,1.15,1,12}}
local added={slime_blob={'slime','stalker',8},slime_spitter={'slime','caster',48},slime_bulwark={'slime','brute',36},crystal_scout={'crystal','skitter',20},crystal_lancer={'crystal','charger',52},crystal_mage={'crystal','caster',74}}
assert(#catalog.Entries==12,'Twelve concrete enemy identities')
local seen,families={},{}
for order,entry in ipairs(catalog.Entries)do
 assert(not seen[entry.id],'Unique kind');seen[entry.id]=true
 families[entry.family]=(families[entry.family]or 0)+1
 assert(catalog.Get(entry.id)==entry and entry.order==order,'Stable ordering and lookup')
 assert(entry.displayName~=''and entry.roleLabel~=''and entry.description~=''and entry.visualAsset~='','Gallery and visual contract')
 assert(entry.familyName==catalog.Families[entry.family]and entry.variant~='','Readable family and variant')
 assert(entry.weight>0 and entry.weight%1==0,'Positive integer rotation weight')
 local role=catalog.Role(entry.id)
 assert(role==catalog.Roles[entry.role]and entry.unlock>=role.unlock,'Role lookup and unlock floor')
 assert(entry.hpScale==role.hpScale and entry.speedScale==role.speedScale and entry.contactDamage==role.contactDamage,'Variants inherit existing role balance')
 local locked={}
 for seq=1,24 do locked[catalog.Choose(entry.role,entry.unlock-.01,seq)or 'none']=true end
 assert(not locked[entry.id],'Variant must not appear before unlock: '..entry.id)
 local unlocked={}
 for seq=1,24 do unlocked[catalog.Choose(entry.role,entry.unlock,seq)or 'none']=true end
 assert(unlocked[entry.id],'Variant appears at unlock: '..entry.id)
end
assert(families.undead==5 and families.beast==1 and families.slime==3 and families.crystal==3,'Family roster')
for id,expected in pairs(old)do
 local role=catalog.Role(id);local entry=catalog.Get(id)
 assert(entry.unlock==expected[1]and role.weight==expected[2]and role.hpScale==expected[3]and role.speedScale==expected[4]and role.contactDamage==expected[5],'Existing role balance: '..id)
end
for id,expected in pairs(added)do
 local entry=catalog.Get(id)
 assert(entry.family==expected[1]and entry.role==expected[2]and entry.unlock==expected[3],'New family identity: '..id)
end
for _,elapsed in ipairs({0,7.99,8,12,20,28,32,36,42,48,52,60,65,74,119.99})do
 for _,field in ipairs({false,true})do
  local counts={}
  for _,roleId in ipairs(catalog.Pool(elapsed,field))do counts[roleId]=(counts[roleId]or 0)+1 end
  for roleId,expected in pairs(old)do
   local weight=(elapsed>=expected[1]and not(field and roleId=='ember'))and expected[2]or 0
   assert((counts[roleId]or 0)==weight,'Role spawn weight remains fixed at each unlock')
  end
 end
end
for roleId in pairs(old)do
 local total,expected=0,{}
 for _,entry in ipairs(catalog.Entries)do if entry.role==roleId then total+=entry.weight;expected[entry.id]=entry.weight end end
 local actual={}
 for seq=1,total do
  local kind=catalog.Choose(roleId,90,seq);actual[kind]=(actual[kind]or 0)+1
  assert(kind==catalog.Choose(roleId,90,seq+total),'Deterministic cycle')
 end
 for kind,count in pairs(expected)do assert(actual[kind]==count,'Variant weight: '..kind)end
end
assert(catalog.Get('caster').projectileHeight==1.1 and catalog.Get('slime_spitter').projectileHeight==-.8 and catalog.Get('crystal_mage').projectileHeight==0,'Grounded family casting origins')
assert(catalog.Choose('caster',0,1)==nil and catalog.Get('unknown')==nil,'Locked and unknown kinds do not silently spawn')
print('PASS: twelve identities, four families, stable roles/stats, exact unlocks, fixed spawn weights and deterministic variant rotation')
