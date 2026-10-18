-- Isolated server-engine fixture: no live player or round state mutations.
local folder=Instance.new('Folder');folder.Name='FieldBossCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local enemies,states={},{};local clock={elapsed=59,roundLength=120,phase='survival'}
 local character=Instance.new('Model');character.Parent=folder
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.MaxHealth=150;h.Health=150;h.Parent=character
 local s={player={Character=character}};states[1]=s
 local function rootOf(state)if not state.over and not state.lobby and h.Health>0 then return root,h end end
 local awards=0
 local create=require(modules.shared.EnemyModels)({block=function(parent,name,size,pos,color,material)local p=Instance.new('Part');p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.Parent=parent;return p end})
 local boss=require(modules.world.FieldBoss)({world=folder,enemies=enemies,states=states,clock=clock,rootOf=rootOf,creature=function(name,_,_,kind)return create(name,kind,folder)end,reward=function()awards+=1 end})
 boss.Step(.05);assert(not clock.fieldBoss,'Not before 60s')
 clock.elapsed=60;boss.Step(.05);local b=clock.fieldBoss;assert(b and b.isFieldBoss and not b.isBoss and #enemies==1,'Separate miniboss classification')
 assert((root.Position-b.pos).Magnitude>24,'Spawn separated from player')
 local function advance(seconds)for _=1,math.ceil(seconds/.05)do boss.Step(.05)end end
 local function untilAction(name,limit)
  for _=1,math.ceil(limit/.05)do if b.action==name then return end;boss.Step(.05)end
  error('Missing action: '..name)
 end
 root.Position=b.pos+b.direction*10;untilAction('cleaveWindup',2)
 assert(b.actionTime==0,'Check the start of windup')
 assert(b.action=='cleaveWindup','First nearby attack is cleave')
 local locked=b.direction;local warning=folder:FindFirstChild('FieldBossTelegraphs');assert(warning and #warning:GetChildren()>20,'Sector warning')
 root.Position=b.pos-locked*8;advance(.4);assert(b.direction:Dot(locked)>.999,'Windup direction stays locked')
 root.Position=b.pos+locked*8;local before=h.Health;advance(1)
 assert(h.Health==before-18,'Cleave damages once')
 untilAction('chargeWindup',3)
 assert(b.action=='chargeWindup','Second attack is mounted charge')
 local start=b.pos;local dir=b.direction;root.Position=start+dir*16;s.invulnerable=1
 advance(1.35);assert(h.Health==before-18,'Dash immunity applies to swept charge');assert((b.pos-start).Magnitude>28,'Faster charge travels 30 studs')
 s.invulnerable=0;b.hp=0;boss.Resolve();boss.Resolve()
 assert(awards==1 and not clock.fieldBoss and #enemies==0 and clock.phase=='survival','Reward once, no final victory')
 boss.Reset();clock.elapsed=60;boss.Step(.05);assert(clock.fieldBoss,'Reset permits next round')
 clock.elapsed=105;advance(1.2);assert(not clock.fieldBoss and awards==1,'Retreat gives no reward')
 boss.Reset();s.bossTest=true;clock.elapsed=60;boss.Step(.05);assert(not clock.fieldBoss,'Dragon-only test excludes miniboss')
 s.bossTest=nil;boss.Reset();boss.Step(.05);clock.phase='boss';boss.Step(.05);assert(not clock.fieldBoss and not folder:FindFirstChild('FieldBossTelegraphs'),'Final boss clears miniboss and warnings')
 clock.phase='survival';boss.Reset();states[2]={player={Character=character}};clock.elapsed=60;boss.Step(.05)
 local coop=clock.fieldBoss;assert(coop.maxHp==2574,'Two-player HP scales on spawn');coop.hp=1287;states[2].over=true;boss.Step(.05)
 assert(coop.maxHp==1560 and math.abs(coop.hp-780)<.01,'Departed participant scales remaining HP proportionally')
 states[2].over=false;coop.hp=0;boss.Resolve();assert(awards==3,'Both live participants receive defeat reward')
 states[2]=nil;boss.Reset();boss.Step(.05);b=clock.fieldBoss
 root.Position=b.pos+b.direction*45;untilAction('approach',2);local begin=b.pos;advance(.25)
 assert((b.pos-begin).Magnitude>3.3,'Faster approach closes distance before a distant attack')
 return {fasterApproach=true,coopScaling=true,sharedReward=true,spawn=true,lockedTelegraph=true,oneHit=true,dashImmunity=true,mountedCharge=true,rewardOnce=true,retreat=true,reset=true,dragonOnly=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
