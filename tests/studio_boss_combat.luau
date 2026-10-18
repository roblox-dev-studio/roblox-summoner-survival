-- Run on Server. Real engine fixture; no live-player state is modified.
local modules=game.ServerScriptService.SummonerServer.Modules
local folder=Instance.new('Folder');folder.Name='DragonCombatCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local root=Instance.new('Part');root.Anchored=true;root.Position=Vector3.new(70,3,0);root.Parent=folder
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.MaxHealth=5000;h.Health=5000;h.Parent=folder
 local s={player={Character=folder},over=false,activeSkill="iceRush",cooldown=0,kills=0,fire=0,ice=1,invulnerable=0}
 local states={s};local enemies={};local events={};local counts={};local ended=0
 local clock={elapsed=0,roundLength=0,bossLimit=90,bossElapsed=0,phase='survival'}
 local function rootOf()if not s.over then return root,h end end
 local effect={FireAllClients=function(_,kind,a,b,c)events[kind]={a,b,c};counts[kind]=(counts[kind]or 0)+1 end}
 local controller=require(modules.world.Boss)({world=folder,enemies=enemies,states=states,clock=clock,rootOf=rootOf,effect=effect,modelFactory=require(game.ReplicatedStorage.EmberDragonModel),drop=function()end,endPlayer=function(state,r)state.over=true;state.result=r;ended+=1 end})
 controller.Step(0);local boss=clock.boss
 local function advance(seconds)for _=1,math.ceil(seconds/.05)do controller.Step(.05)end end
 local function untilTrue(predicate)
  for i=1,1200 do if predicate()then return end;controller.Step(.05);if i%100==0 then task.wait()end end
  error('Expected state not reached')
 end
 local function waitFor(kind)untilTrue(function()return boss.model:GetAttribute('Attack')==kind end)end
 waitFor('breath');assert(clock.bossElapsed<1.2,'Long-range target must not cause prolonged walking')
 local origin=boss.model.Root.CFrame:PointToWorldSpace(Vector3.new(0,19.2,-10.2))
 root.Position=Vector3.new(origin.X,3,origin.Z)+boss.heading*48;local hp=h.Health
 advance(.85);assert(h.Health==hp,'Breath warning is safe');advance(.15)
 assert(h.Health==hp-17 and events.dragonBreath[3].range==55,'Large fan reaches beyond old range')
 advance(.1);assert(h.Health==hp-17,'Breath hits once')
 advance(.95);assert(boss.model:GetAttribute('Attack')=='Recover','Breath completes')
 advance(.45);assert(boss.model:GetAttribute('Attack')=='Recover','Recovery leaves a readable gap before next skill')
 waitFor('airBreath');advance(.6)
 assert(boss.airborne and boss.model.Root.Position.Y>18,'Actual aerial takeoff')
 local combat=require(modules.combat.Combat)({world=folder,enemies=enemies,rootOf=rootOf,paused=function()return false end,effect=effect,drop=function()end})
 root.Position=Vector3.new(boss.pos.X+15,3,boss.pos.Z);local before=boss.hp
 combat.RequestWave(s,Vector3.new(-1,0,0));assert(boss.hp==before,'Ground Q cannot hit high dragon')
 root.Position=Vector3.new(65,3,65);hp=h.Health
 untilTrue(function()return events.dragonAirBreath~=nil end)
 assert(h.Health==hp,'Air sweep can be avoided')
 local points=events.dragonAirBreath[2];root.Position=points[#points];advance(1.25)
 assert(h.Health==hp-20,'Expanded aerial patch damage, once')
 -- After the fire sweep, move into the separately warned landing attack.
 advance(.5)
 local warning=folder.BossTelegraphs:FindFirstChild('LandingWarning');assert(warning and warning.Size.Y==36,'Landing disc shares 18-stud radius')
 root.Position=Vector3.new(warning.Position.X,3,warning.Position.Z);hp=h.Health;advance(.4)
 assert(events.dragonSlam and h.Health==hp-26 and boss.altitude==0,'Flight ends with a damaging ground slam')
 advance(.1);assert(h.Health==hp-26,'Landing hits once independently of aerial fire')
 waitFor('dive');local start=boss.pos;s.invulnerable=1;hp=h.Health;advance(1.5)
 assert((boss.pos-start).Magnitude>30 and boss.altitude==0 and h.Health==hp,'Fast dive displacement, landing, dash immunity')
 assert(events.dragonDive[2]==.55 and events.dragonSlam[2]==16,'Dive timing and landing radius are replicated')
 s.invulnerable=0;boss.hp=boss.maxHp*.49
 waitFor('eruption');local count=0;local marker
 for _,v in ipairs(folder.BossTelegraphs:GetChildren())do if v.Name=='EruptionWarning'then count+=1;marker=v end end
 assert(count==5 and marker.Size.Y==28,'Phase two has five 14-stud eruptions')
 root.Position=Vector3.new(marker.Position.X,3,marker.Position.Z+13.8);hp=h.Health
 advance(.9);assert(h.Health==hp,'Eruption windup');advance(.2);assert(h.Health==hp-22,'Expanded eruption rim hits')
 advance(.15);assert(h.Health==hp-22,'Overlapping eruptions hit once')
 root.Position=boss.pos-boss.heading*20
 waitFor('tail');warning=folder.BossTelegraphs:FindFirstChild('TailWarning');assert(warning and warning.Size.Y==48,'Rear sweep keeps 24-stud warning radius')
 local target=root.Position;local heading=boss.heading;hp=h.Health
 advance(1);assert(h.Health==hp,'Tail windup is safe')
 local first=boss.heading;advance(.1);local second=boss.heading
 local early=math.acos(math.clamp(first:Dot(second),-1,1));assert(early<math.rad(10),'Tail starts slowly')
 advance(.2);assert(h.Health==hp-20 and events.dragonTailSpin[3]==1.35,'Rear target is swept once')
 advance(1.3);assert(h.Health==hp-20 and boss.heading:Dot((target-boss.pos).Unit)>.99,'Tail turns toward the rear target rather than spinning a full circle')
 waitFor('flameCross');local lane=folder.BossTelegraphs:FindFirstChild('FireLineWarning'):FindFirstChild('FireLane');assert(lane.Size.X==18 and lane.Size.Z==72,'Large crossed ground lanes')
 root.Position=lane.Position+Vector3.new(0,3,0);hp=h.Health;local fired=counts.dragonFireLine or 0
 advance(.85);assert(h.Health==hp,'Cross warning');advance(.2);assert(h.Health==hp-22,'First lane hits')
 advance(.55);assert(h.Health==hp-22 and counts.dragonFireLine==fired+2,'Second lane fires, crossing does not double-hit')
 waitFor('airCross');lane=folder.BossTelegraphs:FindFirstChild('FireLineWarning'):FindFirstChild('FireLane');assert(lane.Size.X==20 and lane.Size.Z==76,'Aerial cross is wider')
 local center=lane.Position;local forward=lane.CFrame.LookVector;local right=lane.CFrame.RightVector
 root.Position=center+forward*27+right*27+Vector3.new(0,3,0);hp=h.Health;fired=counts.dragonFireLine
 advance(3.1);assert(h.Health==hp and counts.dragonFireLine==fired+2,'Cross quadrants and landing can be dodged')
 waitFor('airRing');local rings={}
 for _,v in ipairs(folder.BossTelegraphs:GetChildren())do if v.Name=='EruptionWarning'then table.insert(rings,v)end end
 assert(#rings==8 and rings[1].Size.Y==22,'Eight broad ring patches')
 root.Position=rings[1].Position+Vector3.new(0,3,0);hp=h.Health;advance(2.2)
 assert(h.Health==hp-20,'Ring fire hits once despite overlapping patches')
 local loop=events.dragonAirBreath[2];assert(#loop==9 and(loop[1]-loop[9]).Magnitude<.01,'Aerial breath closes the visual loop')
 root.Position=Vector3.new(-65,3,-65);advance(1.1)
 assert(not boss.airborne and events.dragonSlam[2]==22,'Ring flight also ends in a phase-two slam')
 -- Guard existing combat and round contracts after the new eight-pattern cycle.
 root.Position=Vector3.new(boss.pos.X+15,3,boss.pos.Z);s.cooldown=0
 assert(not combat.RequestWave(s,Vector3.new(0/0,0,0))and s.cooldown==0,'Invalid Q rejected')
 combat.ClearProjectiles(s);s.activeSkill='fire'
 local active=require(modules.combat.ActiveSpells)({world=folder,enemies=enemies,effect=effect,damage=function(e,n)e.hp-=n end})
 before=boss.hp;combat.RequestWave(s,Vector3.new(-1,0,0));assert(boss.hp==before,'Fire Q must travel first')
 for _=1,5 do active.Step(s,.1)end;assert(boss.hp==before-75,'Ground fire Q still reaches the dragon')
 boss.hp=0;clock.bossElapsed=90;controller.Resolve()
 assert(clock.phase=='victory'and ended==1,'Boss defeat still wins after long combat')
 controller.Reset();table.clear(enemies);s.over=false;controller.Step(0);clock.bossElapsed=900;controller.Resolve()
 assert(clock.phase=='boss'and ended==1,'No timeout after 900 seconds')
 controller.Step(.05);controller.Resolve();assert(clock.phase=='boss'and clock.bossElapsed>900,'Boss keeps fighting without a limit')
 clock.boss.hp=0;controller.Resolve();assert(clock.phase=='victory'and ended==2,'Unlimited fight can still be won')
 controller.Reset();table.clear(enemies);s.over=false;controller.Step(0)
 local session=require(modules.flow.Session)({world=folder,states=states,enemies=enemies,gems={},clock=clock,resetSpawn=function()end,resetBoss=controller.Reset,clearIceShots=function()end})
 session.RemovePlayer(1);assert(clock.phase=='survival'and clock.boss==nil and #folder.BossTelegraphs:GetChildren()==0,'Departure removes dragon and every warning')
 return 'PASS: long-range engagement, broad fan, aerial sweep + landing slam, fast dive, large eruptions, rotating tail, ground/aerial crosses, aerial ring, dodge/immunity/single-hit guards, Q and round cleanup'
end,debug.traceback)
folder:Destroy();assert(ok,result);return result
