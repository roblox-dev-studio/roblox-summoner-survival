-- Server fixture: real parts/damage, isolated dragon controller and target.
local folder=Instance.new('Folder');folder.Name='RearTailCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local root=Instance.new('Part');root.Anchored=true;root.Parent=folder
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.MaxHealth=1000;h.Health=1000;h.Parent=folder
 local state={player={Character=folder},invulnerable=0};local clock={phase='survival',elapsed=0,roundLength=0};local enemies={};local events={}
 local factory={create=function(parent,cf)local m=Instance.new('Model');m.Parent=parent;local r=Instance.new('Part');r.Name='Root';r.Anchored=true;r.Parent=m;m.PrimaryPart=r;return {model=m,origin=cf}end,pose=function(rig)rig.model:PivotTo(rig.origin)end}
 local bossController=require(game.ServerScriptService.SummonerServer.Modules.world.Boss)({world=folder,enemies=enemies,states={state},clock=clock,rootOf=function()return root,h end,effect={FireAllClients=function(_,kind)events[kind]=(events[kind]or 0)+1 end},modelFactory=factory,drop=function()end,endPlayer=function()end})
 local function advance(seconds)for _=1,math.ceil(seconds/.05)do bossController.Step(.05)end end
 bossController.Step(0);local boss=clock.boss
 root.Position=boss.pos+boss.heading*15;advance(1.05)
 assert(boss.model:GetAttribute('Attack')=='breath','Front target uses frontal rotation pattern, not tail')
 bossController.Reset();table.clear(enemies);bossController.Step(0);boss=clock.boss
 local original=boss.heading;local position=boss.pos;local target=boss.pos-boss.heading*15;root.Position=target;advance(1.05)
 assert(boss.model:GetAttribute('Attack')=='tail' and boss.heading:Dot(original)>.999,'Rear target starts tail without first turning to face it')
 advance(.95);assert(h.Health==1000,'Windup is safe');assert((boss.pos-position).Magnitude<.01,'Tail does not slide toward rear target')
 advance(.35);assert(h.Health==980 and events.dragonTailSpin==1,'Rear sweep hits once after warning')
 advance(1.3);assert(h.Health==980 and boss.heading:Dot((target-boss.pos).Unit)>.99,'Sweep ends facing the rear target without a full extra spin')
 root.Position=boss.pos-boss.heading*15;advance(.8)
 assert(boss.model:GetAttribute('Attack')~='tail','Tail cooldown prevents repeated rear counters')
 bossController.Reset();table.clear(enemies);bossController.Step(0);boss=clock.boss;root.Position=boss.pos-boss.heading*40;advance(1.05)
 assert(boss.model:GetAttribute('Attack')=='breath','Distant rear target is not a close tail opportunity')
 bossController.Reset();table.clear(enemies);state.bossTest=true;bossController.Step(0);assert(clock.boss.maxHp==5760,'Only boss test doubles base health');state.bossTest=false;bossController.Reset();table.clear(enemies);bossController.Step(0);assert(clock.boss.maxHp==2880,'Normal boss health remains unchanged');bossController.Reset();return {testHealth=true,front=true,rear=true,windup=true,stationary=true,singleHit=true,turnToTarget=true,cooldown=true,distance=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
