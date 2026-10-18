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
 root.Position=b.pos+b.direction*10;advance(1.35);advance(.7)
 assert(b.action=='cleaveWindup','First nearby attack is cleave')
 local locked=b.direction;local warning=folder:FindFirstChild('FieldBossTelegraphs');assert(warning and #warning:GetChildren()>20,'Sector warning')
 root.Position=b.pos-locked*8;advance(.4);assert(b.direction:Dot(locked)>.999,'Windup direction stays locked')
 root.Position=b.pos+locked*8;local before=h.Health;advance(1)
 assert(h.Health==before-18,'Cleave damages once')
 advance(1.5);local count=0
 for _=1,100 do boss.Step(.05);if b.action=='chargeWindup'then count+=1;break end end
 assert(count==1,'Second attack is mounted charge')
 local start=b.pos;local dir=b.direction;root.Position=start+dir*16;s.invulnerable=1
 advance(1.65);assert(h.Health==before-18,'Dash immunity applies to swept charge');assert((b.pos-start).Magnitude>15,'Actual server movement')
 s.invulnerable=0;b.hp=0;boss.Resolve();boss.Resolve()
 assert(awards==1 and not clock.fieldBoss and #enemies==0 and clock.phase=='survival','Reward once, no final victory')
 boss.Reset();clock.elapsed=60;boss.Step(.05);assert(clock.fieldBoss,'Reset permits next round')
 clock.elapsed=105;advance(1.2);assert(not clock.fieldBoss and awards==1,'Retreat gives no reward')
 boss.Reset();s.bossTest=true;clock.elapsed=60;boss.Step(.05);assert(not clock.fieldBoss,'Dragon-only test excludes miniboss')
 s.bossTest=nil;boss.Reset();boss.Step(.05);clock.phase='boss';boss.Step(.05);assert(not clock.fieldBoss and not folder:FindFirstChild('FieldBossTelegraphs'),'Final boss clears miniboss and warnings')
 clock.phase='survival';boss.Reset();states[2]={player={Character=character}};clock.elapsed=60;boss.Step(.05)
 local coop=clock.fieldBoss;assert(coop.maxHp==1980,'Two-player HP scales on spawn');coop.hp=990;states[2].over=true;boss.Step(.05)
 assert(coop.maxHp==1200 and math.abs(coop.hp-600)<.01,'Departed participant scales remaining HP proportionally')
 states[2].over=false;coop.hp=0;boss.Resolve();assert(awards==3,'Both live participants receive defeat reward')
 return {coopScaling=true,sharedReward=true,spawn=true,lockedTelegraph=true,oneHit=true,dashImmunity=true,mountedCharge=true,rewardOnce=true,retreat=true,reset=true,dragonOnly=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
