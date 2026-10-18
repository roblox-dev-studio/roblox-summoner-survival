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
 local function advance(seconds)for _=1,math.ceil(seconds/.05)do boss.Step(.05)end end
 boss.Step(.05);assert(not clock.fieldBoss,'Not before 60s')
 clock.elapsed=60;boss.Step(.05);local b=clock.fieldBoss
 local function untilAction(name,limit)
  for _=1,math.ceil(limit/.05)do if b.action==name then return end;boss.Step(.05)end
  error('Missing action: '..name..' current '..b.action)
 end
 assert(b and b.maxHp==1560 and b.isFieldBoss and not b.isBoss and #enemies==1,'Separate miniboss classification')
 assert((root.Position-b.pos).Magnitude>24,'Spawn separated from player')
 root.Position=b.pos+b.direction*10;untilAction('cleaveWindup',2)
 local locked=b.direction;assert(folder.FieldBossTelegraphs:FindFirstChild('CleaveSector'),'Sector warning')
 root.Position=b.pos-locked*8;advance(.3);assert(b.direction:Dot(locked)>.999,'Cleave direction stays locked')
 root.Position=b.pos+locked*8;local before=h.Health;untilAction('recover',2)
 assert(h.Health==before-18,'Cleave damages once')
 untilAction('slamWindup',3);local impact=b.impactPoint
 assert(folder.FieldBossTelegraphs:FindFirstChild('SlamArea'),'Slam circular warning')
 root.Position=b.pos-b.direction*10;advance(.35);assert(b.impactPoint==impact,'Slam landing point stays locked')
 root.Position=impact;before=h.Health;untilAction('recover',2)
 assert(h.Health==before-26,'Overhead slam damages once')
 untilAction('thrustWindup',3);locked=b.direction
 assert(folder.FieldBossTelegraphs:FindFirstChild('ThrustLane'),'Thrust narrow lane')
 root.Position=b.pos-locked*7;advance(.25);assert(b.direction:Dot(locked)>.999,'Thrust aim locked')
 root.Position=b.strikeOrigin+locked*18;before=h.Health;untilAction('recover',2)
 assert(h.Health==before-22,'Thrust damages once');assert((b.pos-b.strikeOrigin).Magnitude>4,'Thrust includes short lunge')
 root.Position=b.pos+b.direction*45;untilAction('chargeWindup',4)
 local start=b.pos;root.Position=start+b.direction*16;s.invulnerable=1;before=h.Health
 untilAction('recover',2);assert(h.Health==before,'Dash immunity applies to swept charge');assert((b.pos-start).Magnitude>28,'Charge travels 30 studs')
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
 assert((b.pos-begin).Magnitude>3.3,'Fast approach')
 b.lastAttack='charge';untilAction('thrustWindup',3)
 local tangent=Vector3.new(-b.direction.Z,0,b.direction.X)
 root.Position=b.strikeOrigin+b.direction*15+tangent*4;before=h.Health;untilAction('recover',2)
 assert(h.Health==before,'Sideways movement escapes thrust lane')
 return {cleave=true,slam=true,thrust=true,mountedCharge=true,lockedTelegraphs=true,oneHit=true,dashImmunity=true,sideDodge=true,sharedReward=true,retreat=true,reset=true,coopScaling=true,fastApproach=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
