-- Isolated real engine fixture for single-target seeking, retargeting and cleanup.
local folder=Instance.new('Folder');folder.Name='MissileCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local root=Instance.new('Part');root.Anchored=true;root.Position=Vector3.new(0,4,0);root.Parent=folder
 local enemies={};local spawns=0
 local function enemy(x,hp,boss)local e={pos=Vector3.new(x,4,0),hp=hp,isBoss=boss};table.insert(enemies,e);return e end
 local weak=enemy(5,100);local strong=enemy(10,200);local boss=enemy(20,10000,true)
 local s={player={Character=folder},missile=1}
 local missiles=require(game.ServerScriptService.SummonerServer.Modules.combat.HomingMissiles)({world=folder,enemies=enemies,rootOf=function(state)if not state.over then return root end end,effect={FireAllClients=function(_,kind)if kind=='homingMissile'then spawns+=1 end end},damage=function(e,n)e.hp-=n end})
 local function count()local n=0;for _,p in ipairs(folder:GetChildren())do if p.Name:match('HomingMissile_')then n+=1 end end;return n end
 missiles.StepPlayer(s,root,.05);assert(count()==2 and spawns==2,'Rank one shoots two projectiles')
 missiles.Step(.1);assert(boss.hp==10000,'No instant damage')
 for _=1,10 do missiles.Step(.1)end
 assert(boss.hp==9950 and strong.hp==200 and weak.hp==100 and count()==0,'Boss focus and no splash damage')
 boss.hp=0;s.missileClock=0;missiles.StepPlayer(s,root,.05);strong.hp=0
 for _=1,10 do missiles.Step(.1)end
 assert(weak.hp==50,'Dead target retargets a living enemy')
 s.missile=5;s.missileClock=0;weak.hp=1000;missiles.StepPlayer(s,root,.05);assert(count()==4,'Rank five shoots four')
 s.offers={};local position
 for _,p in ipairs(folder:GetChildren())do if p.Name:match('HomingMissile_')then position=p.Position;break end end
 missiles.Step(.3);local unchanged=false
 for _,p in ipairs(folder:GetChildren())do if p.Name:match('HomingMissile_')and p.Position==position then unchanged=true end end
 assert(unchanged,'Player offer freezes missiles');s.offers=nil;missiles.Clear(s);assert(count()==0,'Explicit cancellation')
 s.missileClock=0;missiles.StepPlayer(s,root,.05);s.over=true;missiles.Step(.05);assert(count()==0,'Death cancellation')
 s.over=false;s.missileClock=0;weak.pos=Vector3.new(10,4,0);missiles.StepPlayer(s,root,.05);weak.pos=Vector3.new(250,4,0)
 for _=1,40 do missiles.Step(.1)end
 assert(count()==0,'Projectile lifetime is bounded')
 return {singleTarget=true,bossPriority=true,retarget=true,rank=true,pause=true,cleanup=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
