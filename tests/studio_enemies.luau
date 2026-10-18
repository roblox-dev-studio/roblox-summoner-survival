-- Server play-mode checks with temporary actors, no live player changes.
local folder=Instance.new('Folder');folder.Name='EnemyCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local actors=require(modules.shared.Actors)({world=folder})
 local root=actors.Block(folder,'PlayerRoot',Vector3.one,Vector3.new(0,3,0),Color3.new())
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.MaxHealth=5000;h.Health=5000;h.Parent=folder
 local s={offers=nil,invulnerable=0};local states={s};local enemies={};local drops=0;local index=1
 local clock={phase='survival'}
 local waves=require(modules.world.Waves)({world=folder,states=states,enemies=enemies,clock=clock,roundLength=120,creature=actors.Create,
  rootOf=function()return root,h end,rng={NextInteger=function()return index end,NextNumber=function(_,lo)return lo end},effect={FireAllClients=function()end},drop=function()drops+=1 end})
 local kinds={'stalker','skitter','brute','caster','ember','charger'}
 local selected={}
 -- A fresh pack may add six actors; inspect the first newly spawned actor.
 for i,value in ipairs({1,7,10,12,14,15})do index=value;local before=#enemies;waves.Spawn(2,1,90);local e=enemies[before+1];selected[i]=e;assert(e.role==kinds[i]);assert(e.model:GetAttribute('EnemyKind')==e.kind and e.model:GetAttribute('EnemyRole')==kinds[i])end
 for _,e in ipairs(enemies)do if not table.find(selected,e)then e.hp=0;e.model:Destroy()end end
 table.clear(enemies);for _,e in ipairs(selected)do table.insert(enemies,e)end
 assert(enemies[2].speed>enemies[1].speed and enemies[3].speed<enemies[1].speed and enemies[3].hp>enemies[1].hp,'Role stats')
 for i=1,6 do if i~=4 then enemies[i].hp=0;enemies[i].model:Destroy()end end
 local mage=enemies[4];mage.pos=Vector3.new(10,3,0);mage.castClock=0
 waves.Step(.4);assert(not folder:FindFirstChild('EnemyArcaneBolt'),'Mage must wind up first')
 waves.Step(.5);assert(folder:FindFirstChild('EnemyArcaneBolt'),'Mage projectile')
 local hp=h.Health;waves.Step(.5);assert(h.Health==hp-6,'Swept projectile damage')
 mage.hp=0;mage.model:Destroy();waves.Step(.01)
 local function bomb()
  local m=actors.Create('TestBomb',Color3.new(),false,'ember');m:PivotTo(CFrame.new(4,3,0))
  local e={model=m,pos=Vector3.new(4,3,0),kind='ember',hp=30,speed=9,slow=0,hitClock=0,seed=0};table.insert(enemies,e);return e
 end
 local e=bomb();hp=h.Health;waves.Step(.4);assert(e.model:FindFirstChild('EnemyBlastWarning'),'Bomb warning')
 root.Position=Vector3.new(20,3,0);waves.Step(.9);assert(h.Health==hp and e.hp==0 and drops==1,'Dodge bomb')
 root.Position=Vector3.new(0,3,0);e=bomb();waves.Step(1.3);assert(h.Health==hp-12 and drops==2,'Bomb damage and XP')
 e=bomb();e.frozen=2;hp=h.Health;waves.Step(.5);assert(e.fuse==0 and h.Health==hp,'Freeze interrupts bomb fuse')
 e.hp=0;e.model:Destroy();waves.Step(.1)
 local m=actors.Create('TestCharger',Color3.new(),false,'charger');m:PivotTo(CFrame.new(20,3,0))
 local charger={model=m,pos=Vector3.new(20,3,0),kind='charger',hp=100,speed=10,slow=0,hitClock=0,seed=1,castClock=0};table.insert(enemies,charger)
 root.Position=Vector3.new(0,3,0);waves.Step(.4);assert(m:FindFirstChild('ChargeWarning')and charger.pos.X==20,'Charger warns before moving')
 waves.Step(.5);assert(charger.chargeTime and not m:FindFirstChild('ChargeWarning'),'Telegraph ends before dash')
 root.Position=Vector3.new(0,3,12);waves.Step(.2);assert(charger.pos.X<20 and math.abs(charger.pos.Z)<.1,'Charge keeps locked direction and can be dodged')
 charger.frozen=1;local pos=charger.pos;waves.Step(.2);assert(charger.pos==pos,'Freeze stops charge movement')
 clock.phase='boss';local count=#enemies;waves.Spawn(2,1,90);assert(#enemies==count,'No spawn during boss')
 waves.ResetSpawn();assert(not folder:FindFirstChild('EnemyArcaneBolt'),'Projectile cleanup')
 return 'PASS: six roles, mixed packs, role stats, caster shots, bomb dodge/freeze, locked-direction charger warning/dash/freeze, boss gate and cleanup'
end,debug.traceback)
folder:Destroy();assert(ok,result);return result
