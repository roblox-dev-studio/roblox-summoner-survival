-- Isolated real-engine fixtures. They test authored combat modules, not human enjoyment.
local folder=Instance.new('Folder');folder.Name='AugmentCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local A=require(modules.flow.Augments)
 local root=Instance.new('Part');root.Anchored=true;root.CanCollide=false;root.CFrame=CFrame.new(250,3,0);root.Parent=folder
 local enemies,events={},{}
 local function enemy(x,z,hp)
  local m=Instance.new('Model');m.Parent=folder
  local e={model=m,pos=Vector3.new(250+x,3,z),hp=hp or 1000,maxHp=1000,slow=0};table.insert(enemies,e);return e
 end
 local function reset()table.clear(enemies);table.clear(events)end
 local function state(augments)return {player={Character=folder},augments=augments or {},kills=0,cooldown=0}end
 local deps={world=folder,enemies=enemies,rootOf=function()return root end,paused=function()return false end,rng=Random.new(17),drop=function()end,
  damage=function(e,n)e.hp-=n end,effect={FireAllClients=function(_,kind,...)events[kind]=events[kind]or {};table.insert(events[kind],{...})end},
  block=function(parent,name,size,pos,color)local p=Instance.new('Part');p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.Parent=parent;return p end}
 local function near(a,b,label)assert(math.abs(a-b)<.001,label..': '..tostring(a)..' ~= '..tostring(b))end
 local function count(prefix)local n=0;for _,v in ipairs(folder:GetChildren())do if v.Name:match('^'..prefix)then n+=1 end end;return n end
 local area=require(modules.combat.AreaSpells)(deps)
 local s=state({meteor_wide=1,meteor_echo=1,quick_cast=3});s.meteor=2
 local target=enemy(10,-10);area.Step(s,root,.01)
 near(s.areaCasts[1].radius,21.6,'Widened warning');near(s.meteorClock,8.4*.76,'Automatic cooldown')
 area.Step(s,root,3.2);near(target.hp,891,'Primary meteor');assert(#s.areaEchoes==1)
 area.Step(s,root,.64);near(target.hp,891,'Echo waits');area.Step(s,root,.02);near(target.hp,836.5,'Half damage echo')
 area.Clear(s);s.meteorClock=0;area.Step(s,root,.01);area.Step(s,root,3.2);local before=target.hp;area.Clear(s);s.meteor=0;area.Step(s,root,1);near(target.hp,before,'Cancellation removes echo')
 reset();s=state({frost_wide=1,frost_echo=1});s.frost=2;target=enemy(17,0)
 area.Step(s,root,.01);near(s.areaCasts[1].radius,18.2,'Frost detects extended range');area.Step(s,root,.75);near(target.hp,966,'Frost hit');assert(target.frozen>0)
 area.Step(s,root,.61);near(target.hp,949,'Frost echo');area.Clear(s)
 reset();s=state({ward_reservoir=1,ward_pulse=1});s.ward=1;target=enemy(7,0)
 area.Step(s,root,.01);near(s.shield,63,'Extra shield');assert(s.areaCasts[1].duration==7)
 s.shield=0;area.Step(s,root,.01);near(target.hp,952.75,'Shield break pulse');assert(#events.augmentPulse==1)
 s.wardClock=0;area.Step(s,root,.01);area.Clear(s);area.Step(s,root,.1);assert(#events.augmentPulse==1,'Cancel never detonates')
 reset();s=state({missile_salvo=1,missile_hunter=1});s.missile=2;target=enemy(0,-20);target.elite=true
 local missiles=require(modules.combat.HomingMissiles)(deps);missiles.StepPlayer(s,root,.01)
 assert(count('HomingMissile_')==5,'Three base plus two');for _=1,30 do missiles.Step(.05)end
 near(target.hp,760,'Five elite hits at 32 x 1.5');missiles.Clear(s)
 reset();s=state({blades_volley=1,blades_pierce=1});s.blades=2
 target=enemy(0,-20);local nextTarget=enemy(0,-21)
 local crystals=require(modules.combat.ArcaneCrystals)(deps);crystals.StepPlayer(s,root,.01)
 local bolt;for _,v in ipairs(folder:GetChildren())do if v.Name:match('^CrystalBolt_')then bolt=v end end
 assert(bolt and events.areaCast[1][2]=='blades')
 -- Put both contacts on this bolt's observed ray; one large tick crosses both.
 target.pos=bolt.Position+bolt.CFrame.LookVector*8;nextTarget.pos=bolt.Position+bolt.CFrame.LookVector*9
 crystals.Step(.3);near(target.hp,982,'First pierced contact');near(nextTarget.hp,982,'Second contact in same tick')
 for _=1,6 do crystals.StepPlayer(s,root,.18)end
 assert(#events.crystalBolt==7,'Seven crystals');crystals.Clear(s)
 reset();s=state({skyLances_rain=1,skyLances_execute=1});s.skyLances=2;target=enemy(0,-12,500)
 local sky=require(modules.combat.SkyLances)(deps);sky.Step(s,root,.01)
 for _=1,62 do sky.Step(s,root,.05)end
 near(target.hp,438.5,'Low-health sky execution');assert(#events.skyLanceHit==7 and count('SkyLanceCast_')==0,'Seven impacts finish');sky.Clear(s)
 reset();s=state({lightRing_twin=1});s.lightRing=2;target=enemy(0,-15)
 local rings=require(modules.combat.LightSpells)(deps);rings.StepPlayer(s,root,.01);assert(count('LightCast_')==2,'Twin ring anchors');rings.Clear(s)
 reset();s=state({lightRing_return=1});s.lightRing=2;target=enemy(0,-15)
 rings.StepPlayer(s,root,.01);for _=1,50 do rings.Step(.05)end
 near(target.hp,1000-34-34*1.75,'Outbound and stronger return exactly once');rings.Clear(s)
 local active=require(modules.combat.ActiveSpells)(deps)
 reset();s=state({fire_blast=1,active_focus=2});s.activeSkill='fire';target=enemy(0,-16);local wide=enemy(6,-16);local outside=enemy(8,-16)
 active.Request(s,root.Position,Vector3.new(0,0,-1));near(s.cooldown,4.9,'Q cooldown');for _=1,12 do active.Step(s,.05)end
 assert(target.hp==925 and wide.hp==925 and outside.hp==1000,'Fire expanded radius');assert(events.augmentFireHit[1][2]==7,'Fire visual radius matches')
 reset();s=state({thunder_chain=1});s.activeSkill='thunder';s.lightning=1;target=enemy(0,-15);local extra1=enemy(6,-15);local extra2=enemy(-6,-15);outside=enemy(9,-15)
 active.Request(s,root.Position,Vector3.new(0,0,-1));for _=1,40 do active.Step(s,.05)end
 assert(target.hp==920 and extra1.hp==960 and extra2.hp==960 and outside.hp==1000 and #events.lightning==2,'Thunder adds exactly two arcs')
 reset();s=state({aether_execute=1});s.activeSkill='aetherLance';s.lightning=1;target=enemy(0,-15,500)
 active.Request(s,root.Position,Vector3.new(0,0,-1));for _=1,40 do active.Step(s,.05)end;near(target.hp,380,'Q execution')
 reset();s=state({iceRush_wide=1});s.activeSkill='iceRush';s.ice=1;target=enemy(8,-15);outside=enemy(10,-15)
 active.Request(s,root.Position,Vector3.new(0,0,-1));assert(s.activeCast.anchor:GetAttribute('Width')==9)
 for _=1,22 do active.Step(s,.05)end;assert(target.hp==941 and outside.hp==1000 and events.activeStrike[1][3].width==9,'Ice damage and visual width')
 reset();s=state({ice_twin=1,ice_shatter=1});s.ice=2;s.lightning=0;s.golem=1;s.fireClock=99;s.lightningClock=99;s.iceClock=0;s.golemClock=99;s.petHeavyCooldown=99;s.petRig={}
 s.pet=Instance.new('Model');local core=deps.block(s.pet,'Core',Vector3.one,root.Position,Color3.new());s.pet.PrimaryPart=core;s.pet.Parent=folder
 target=enemy(0,-12);nextTarget=enemy(0,-15)
 local combat=require(modules.combat.Combat)(deps);combat.StepPlayer(s,root,.01);assert(count('IceSpearAnchor_')==2,'Two ice spears')
 for _=1,30 do combat.StepProjectiles(.05)end
 near(target.hp,970.75,'Ice 75% primary plus half shard');near(nextTarget.hp,970.75,'Separate second target and shards');combat.ClearProjectiles(s)
 reset();s.ice=0;s.lightning=2;s.lightningClock=0;s.augments={lightning_fork=1,lightning_frozen=1}
 for i=1,6 do local e=enemy(i*3,-12);e.slow=1 end
 combat.StepPlayer(s,root,.01)
 for i=1,5 do near(enemies[i].hp,958.4,'Five chain targets with frozen synergy')end
 assert(enemies[6].hp==1000 and #events.lightning==5,'Extra hops no duplicate hits');combat.ClearProjectiles(s)
 -- Luck is a server lottery weight, not extra damage or loot.
 local luck=state({lucky_charm=3});assert(A.Luck(luck)==60 and A.Weights(luck).epic==8)
 return {area=true,shield=true,missiles=true,crystalPiercingSameTick=true,sky=true,rings=true,Q=true,ice=true,chain=true,cooldowns=true,luck=true,cancel=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
