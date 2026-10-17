-- Real engine Q fixture; does not access live session state.
local folder=Instance.new('Folder');folder.Name='ActiveSpellCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local enemies={};local events={}
 local root=Instance.new('Part');root.Anchored=true;root.Position=Vector3.new(0,3,0);root.Parent=folder
 local function enemy(pos,air,boss)
  local m=Instance.new('Model');m.Parent=folder;local e={model=m,pos=pos,hp=1000,slow=0,airborne=air,isBoss=boss};table.insert(enemies,e);return e
 end
 local ground=enemy(Vector3.new(0,3,-25));local air=enemy(Vector3.new(0,25,-42),true);local side=enemy(Vector3.new(8,3,-25));local behind=enemy(Vector3.new(0,3,6));local boss=enemy(Vector3.new(0,3,-20),false,true)
 local far=enemy(Vector3.new(0,3,-42))
 local s={player={Character=folder},activeSkill='thunder',cooldown=0,lightning=1,ice=1,kills=0}
 local paused=false
 local deps={world=folder,enemies=enemies,effect={FireAllClients=function(_,kind)events[kind]=(events[kind]or 0)+1 end},damage=function(e,amount)e.hp-=amount end,drop=function()end,rootOf=function()if not s.lobby then return root end end,paused=function()return paused end}
 local active=require(modules.combat.ActiveSpells)(deps)
 local combat=require(modules.combat.Combat)(deps)
 assert(not combat.RequestWave(s,Vector3.new(0/0,0,0))and s.cooldown==0,'Reject invalid direction')
 s.offers={};assert(not combat.RequestWave(s));s.offers=nil
 s.lobby=true;assert(not combat.RequestWave(s));s.lobby=false
 paused=true;assert(not combat.RequestWave(s));paused=false
 assert(combat.RequestWave(s,Vector3.new(0,0,-1))and s.cooldown==7,'Q uses selected active')
 assert(not combat.RequestWave(s,Vector3.new(0,0,-1)),'Cooldown blocks repeated input')
 active.Step(s,.2);assert(ground.hp==1000,'Charge does not deal early damage')
 local anchor=s.activeCast.anchor;task.wait(.05);assert(anchor:GetAttribute('Elapsed')==.2,'No independent timer')
 active.Step(s,.2);assert(ground.hp==1000,'Spear starts travelling instead of hitting whole line instantly')
 active.Step(s,.1);assert(ground.hp==1000,'Distant enemy waits for the moving spear')
 for _=1,12 do active.Step(s,.1)end
 assert(ground.hp==920 and far.hp==920 and boss.hp==920 and air.hp==1000 and side.hp==1000 and behind.hp==1000,'Moving spear penetrates actual 3D path only')
 active.Step(s,.2);assert(ground.hp==920 and not s.activeCast and events.thunderSpear==1,'Each enemy hit once and spear expires')
 s.cooldown=0;s.activeSkill='iceRush';assert(combat.RequestWave(s,Vector3.new(0,0,-1)))
 local close=enemy(Vector3.new(0,3,-3))
 active.Step(s,.4);assert(close.hp==1000 and ground.hp==920,'Ice waits for the first eruption')
 active.Step(s,.1);assert(close.hp==941 and ground.hp==920,'Near ground erupts before distant ground')
 active.Step(s,.5)
 assert(ground.hp==861 and ground.frozen==1.1 and ground.knockTime==.2,'Glacial lane damage and freeze')
 assert(air.hp==1000 and boss.hp==861 and not boss.frozen,'Air excluded and boss freeze immunity')
 assert(not s.activeCast and close.hp==941 and events.activeStrike==1,'Seven rows complete with one hit per enemy')
 s.cooldown=0;s.activeSkill='iceRush';combat.RequestWave(s,Vector3.new(0,0,-1));active.Step(s,.5);local cancelledHP=ground.hp;combat.ClearProjectiles(s);active.Step(s,1);assert(ground.hp==cancelledHP,'Cancelling stops remaining ice rows')
 s.cooldown=0;s.activeSkill='thunder';combat.RequestWave(s,Vector3.new(0,0,-1));combat.ClearProjectiles(s)
 assert(not s.activeCast,'Death cancels Q windup')
 local widened=enemy(Vector3.new(4.2,4.2,-25));local outside=enemy(Vector3.new(5.2,4.2,-25));local high=enemy(Vector3.new(0,7,-25),true)
 local before=ground.hp;s.cooldown=0;s.activeSkill='aetherLance';assert(combat.RequestWave(s,Vector3.new(0,0,-1)),'New energy Q accepted')
 active.Step(s,.2);assert(ground.hp==before,'Energy lance also has a charge')
 for _=1,14 do active.Step(s,.1)end
 assert(ground.hp==before-80 and events.aetherSpear==1 and events.aetherHit>=1 and not s.activeCast,'Separate energy Q has actual flight, hits and cleanup')
 assert(widened.hp==920 and outside.hp==1000 and high.hp==1000,'Energy lance has wider horizontal reach, bounded sides and unchanged vertical reach')
 s.cooldown=0;s.activeSkill='thunder';assert(combat.RequestWave(s,Vector3.new(0,0,-1)))
 for _=1,16 do active.Step(s,.1)end
 assert(widened.hp==920,'Lightning lance keeps its original narrower reach')
 table.clear(enemies)
 local fireTarget=enemy(Vector3.new(0,4.2,-16));local splash=enemy(Vector3.new(0,4.2,-20));local untouched=enemy(Vector3.new(0,4.2,-29));local offPath=enemy(Vector3.new(9,4.2,-16));local highFire=enemy(Vector3.new(0,20,-16),true)
 s.cooldown=0;s.activeSkill='fire';assert(combat.RequestWave(s,Vector3.new(0,0,-1))and s.cooldown==7,'Fireball Q accepted')
 assert(events.fireProjectile==1 and not events.fireWave,'Fireball projectile replaces fan event')
 assert(not combat.RequestWave(s,Vector3.new(0,0,-1)),'Fireball obeys cooldown')
 active.Step(s,.1);assert(fireTarget.hp==1000 and s.activeCast,'Fireball must fly before damage')
 for _=1,5 do active.Step(s,.1)end
 assert(fireTarget.hp==925 and splash.hp==925 and untouched.hp==1000 and offPath.hp==1000 and highFire.hp==1000 and not s.activeCast,'First contact splashes only nearby enemies')
 table.clear(enemies);local blocked=enemy(Vector3.new(0,4.2,-30))
 local wall=Instance.new('Part');wall.Anchored=true;wall.Size=Vector3.new(20,20,1);wall.Position=Vector3.new(0,5,-12);wall.Parent=workspace
 s.cooldown=0;assert(combat.RequestWave(s,Vector3.new(0,0,-1)));active.Step(s,1);wall:Destroy();assert(blocked.hp==1000 and not s.activeCast,'Wall stops fireball')
 s.cooldown=0;assert(combat.RequestWave(s,Vector3.new(0,0,-1)));combat.ClearProjectiles(s);active.Step(s,1);assert(blocked.hp==1000 and not s.activeCast,'Cancel stops fireball')
 s.cooldown=0;s.activeSkill='fireWave';assert(not combat.RequestWave(s,Vector3.new(0,0,-1))and s.cooldown==0,'Retired fan rejected')
 s.cooldown=0;s.activeSkill='invalid';assert(not combat.RequestWave(s,Vector3.new(0,0,-1))and s.cooldown==0,'Unknown active rejected')
 return {fireball=true,fireCollision=true,fireSplash=true,fireWall=true,retiredWave=true,selection=true,validation=true,cooldown=true,thunder=true,aetherLance=true,widerHorizontal=true,iceRush=true,cancel=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
