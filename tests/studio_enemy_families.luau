-- Server-only fixture. Temporary actors test the actual catalog, Waves and fallback factory.
local folder=Instance.new('Folder');folder.Name='EnemyFamiliesCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local catalog=require(modules.world.EnemyCatalog)
 local actors=require(modules.shared.Actors)({world=folder})
 local root=actors.Block(folder,'PlayerRoot',Vector3.one,Vector3.new(0,3,0),Color3.new())
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.MaxHealth=5000;h.Health=5000;h.Parent=folder
 local state={offers=nil,invulnerable=0};local enemies={};local clock={phase='survival'}
 local draw=0
 local rng={NextInteger=function(_,lo,hi)draw+=1;return lo+(draw-1)%(hi-lo+1)end,NextNumber=function(_,lo)return lo end}
 local waves=require(modules.world.Waves)({world=folder,states={state},enemies=enemies,clock=clock,roundLength=120,creature=actors.Create,rootOf=function()return root,h end,rng=rng,effect={FireAllClients=function()end}})
 local function clear()
  for _,e in ipairs(enemies)do e.model:Destroy()end;table.clear(enemies);waves.ResetSpawn()
  state.offers=nil;state.invulnerable=0;root.Position=Vector3.new(0,3,0)
 end
 local function enemy(kind,pos)
  local data=catalog.Get(kind);local model=actors.Create(kind,Color3.new(),false,kind);model:PivotTo(CFrame.new(pos))
  -- Omit role deliberately: old fixtures and adapters resolve from concrete identity.
  local e={kind=kind,model=model,pos=pos,hp=100,maxHp=100,speed=10*data.speedScale,slow=0,hitClock=0,castClock=0,seed=1}
  table.insert(enemies,e);return e
 end
 local gallery=require(modules.world.EnemyGallery)({parent=folder,create=function(name,kind,parent)local model=actors.Create(name,Color3.new(),false,kind);model.Parent=parent;return model end})
 assert(#gallery:GetChildren()==12,'Twelve server-built visual templates')
 for _,data in ipairs(catalog.Entries)do
  local model=gallery:FindFirstChild(data.id)
  assert(model and model.PrimaryPart and model.PrimaryPart.Name=='Core','Fallback has anchored ground reference')
  for _,key in ipairs({'EnemyKind','EnemyRole','EnemyFamily','EnemyVariant','FamilyName','DisplayName','Description','Role','Order','VisualAsset'})do assert(model:GetAttribute(key)~=nil,'Missing '..key..' for '..data.id)end
  assert(model:GetAttribute('EnemyFamily')==data.family and model:GetAttribute('EnemyRole')==data.role,'Identity and behavior stay separate')
  local visible=0
  for _,v in ipairs(model:GetDescendants())do
   assert(not v:IsA('LuaSourceContainer'),'No server code in gallery')
   if v:IsA('BasePart')then
    assert(v.Anchored and not v.CanCollide and not v.CanTouch and not v.CanQuery,'Native fallback has no physics side effects')
    if v.Transparency<1 then visible+=1 end
   end
  end
  assert(visible>0,'Fallback remains visible before client renderer readiness')
 end
 gallery:Destroy()
 -- The same finite role pool fills 84 slots, including every eligible identity.
 for _=1,120 do waves.Spawn(2,1,90)end
 assert(#enemies==84,'New families do not raise the hard cap')
 local kinds={}
 for _,e in ipairs(enemies)do
  kinds[e.kind]=true;local data=catalog.Get(e.kind)
  assert(e.role==data.role and e.family==data.family and e.pos.Y==3,'Spawn records preserve role and ground height')
  assert(e.hp==math.floor((26+90*.35)*data.hpScale*(e.elite and 1.75 or 1)),'Role HP and elite multiplier unchanged')
 end
 for _,data in ipairs(catalog.Entries)do assert(kinds[data.id],'Mixed wave reaches '..data.id)end
 clear()
 -- Both new caster identities retain the same warning, damage and defenses.
 for _,kind in ipairs({'slime_spitter','crystal_mage'})do
  local e=enemy(kind,Vector3.new(10,3,0));local hp=h.Health
  e.frozen=2;waves.Step(.3);assert(not e.windup and not folder:FindFirstChild('EnemyArcaneBolt'),'Freeze prevents new caster windup')
  e.frozen=0;waves.Step(.4);assert(e.model:GetAttribute('Preparing')and not folder:FindFirstChild('EnemyArcaneBolt'),'Caster windup precedes projectile')
  waves.Step(.5);local bolt=folder:FindFirstChild('EnemyArcaneBolt')
  assert(bolt and bolt:GetAttribute('EnemyKind')==kind and bolt:GetAttribute('EnemyFamily')==catalog.Get(kind).family,'Family-colored projectile identity')
  local rgb=catalog.Get(kind).cueColor;assert(bolt.Color==Color3.fromRGB(rgb[1],rgb[2],rgb[3]),'Family projectile color')
  assert(math.abs(bolt.Position.Y-(3+catalog.Get(kind).projectileHeight))<.01,'Projectile launch matches family casting point')
  assert(e.model:GetAttribute('AttackSequence')==1 and not e.model:GetAttribute('Preparing'),'Cast event completes windup')
  assert(e.pos.Y==3 and e.model:GetPivot().Position.Y==3,'Floating appearance keeps ground damage anchor')
  waves.Step(.5);assert(h.Health==hp-6,'New caster uses existing swept six-damage shot')
  clear();e=enemy(kind,Vector3.new(10,3,0));state.invulnerable=1;hp=h.Health
  waves.Step(.9);waves.Step(.5);assert(h.Health==hp,'Dash immunity protects against family projectiles')
  clear();e=enemy(kind,Vector3.new(10,3,0));state.offers={'choice'};hp=h.Health
  waves.Step(.9);waves.Step(.5);assert(h.Health==hp,'Upgrade selection protects against family projectiles')
  clear()
 end
 local lancer=enemy('crystal_lancer',Vector3.new(20,3,0))
 waves.Step(.4);assert(lancer.model:FindFirstChild('ChargeWarning')and lancer.model:GetAttribute('Preparing'),'Crystal lancer warns before moving')
 lancer.frozen=1;waves.Step(.2);assert(lancer.pos.X==20 and lancer.chargeWindup==.4,'Freeze suspends charge warning')
 lancer.frozen=0;waves.Step(.5);assert(lancer.chargeTime and lancer.model:GetAttribute('AttackSequence')==1 and not lancer.model:GetAttribute('Preparing'),'Launch clears warning and emits attack cue')
 root.Position=Vector3.new(0,3,12);waves.Step(.2);assert(lancer.pos.X<20 and math.abs(lancer.pos.Z)<.01,'Crystal charge keeps locked direction')
 local pos=lancer.pos;lancer.frozen=1;waves.Step(.2);assert(lancer.pos==pos,'Freeze stops active crystal charge')
 clear()
 for kind,damage in pairs({slime_blob=8,slime_bulwark=11,crystal_scout=6})do
  local e=enemy(kind,Vector3.new(3,3,0));local hp=h.Health;waves.Step(.1)
  assert(h.Health==hp-damage,'Inherited contact damage: '..kind)
  hp=h.Health;waves.Step(.1);assert(h.Health==hp,'Contact cooldown: '..kind)
  e.hitClock=0;state.invulnerable=1;waves.Step(.1);assert(h.Health==hp,'Dash protects against contact: '..kind)
  clear()
 end
 local scout=enemy('crystal_scout',Vector3.new(20,3,0));waves.Step(.1);assert(math.abs(scout.pos.Z)>.1,'Crystal scout uses flanking movement');clear()
 clock.fieldBoss={}
 for _=1,40 do waves.Spawn(2,1,90)end
 assert(#enemies==40,'Field boss suppresses the six-actor pincer pack')
 for _,e in ipairs(enemies)do assert(e.role~='ember','Field boss suppresses exploding enemies')end
 clear();clock.fieldBoss=nil;clock.phase='boss';waves.Spawn(2,1,90);assert(#enemies==0,'Dragon phase blocks every family')
 clock.phase='survival';waves.Spawn(2,1,120);assert(#enemies==0,'Two-minute endpoint blocks every family')
 return {identities=12,families=4,cap=84,grounded=true,roleDamage=true,castWarning=true,chargeWarning=true,freeze=true,dash=true,offers=true,fieldPressure=true,dragonGate=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
