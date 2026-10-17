-- Real server fixture, isolated from live-player state.
local folder=Instance.new('Folder');folder.Name='AreaSpellCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local enemies,events={},{ }
 local function enemy(pos,boss,air)
  local model=Instance.new('Model');model.Parent=folder
  local e={model=model,pos=pos,hp=10000,slow=0,isBoss=boss,airborne=air};table.insert(enemies,e);return e
 end
 local normal=enemy(Vector3.new(10,3,0));local boss=enemy(Vector3.new(17,3,0),true);local air=enemy(Vector3.new(10,3,0),false,true);local outside=enemy(Vector3.new(75,3,0))
 local effect={FireAllClients=function(_,kind)events[kind]=(events[kind]or 0)+1 end}
 local spells=require(modules.combat.AreaSpells)({world=folder,enemies=enemies,effect=effect,damage=function(e,n)e.hp-=n end})
 local s={meteor=1};local root={Position=Vector3.new(0,3,0)}
 spells.Step(s,root,.05);local anchor=s.areaCasts[1].anchor
 assert(normal.hp==10000 and anchor:GetAttribute('Duration')==3.2 and anchor:GetAttribute('Radius')==15,'Large meteor warns first')
 task.wait(.06);assert(anchor:GetAttribute('Elapsed')==0,'No independent damage timer')
 for _=1,60 do spells.Step(s,root,.05)end
 assert(normal.hp==10000,'Meteor cannot land early')
 for _=1,5 do spells.Step(s,root,.05)end
 assert(normal.hp==9913 and boss.hp==9913 and air.hp==10000 and outside.hp==10000,'One large ground impact, range and air rules')
 assert(events.meteorHit==1 and #s.areaCasts==0,'Impact cleans up once')
 s.meteor=0;s.blades=1;spells.Step(s,root,.05)
 assert(#s.areaCasts==0,'Old sword wall no longer casts an area attack')
 spells.Clear(s);s.blades=0;s.frost=1;normal.pos=Vector3.new(5,3,0);boss.pos=Vector3.new(7,3,0)
 local hp=normal.hp;spells.Step(s,root,.05)
 for _=1,16 do spells.Step(s,root,.05)end
 assert(events.frostHit==1 and normal.hp==hp-26 and normal.frozen>=1,'Frost nova hits and freezes')
 assert(not boss.frozen,'Boss immune to freeze')
 spells.Clear(s);s.frost=0;s.ward=1;s.player={Character=folder};spells.Step(s,root,.05)
 assert(s.shield==42,'Ward creates shield')
 local humanoid={Health=150,TakeDamage=function(self,n)self.Health-=n end}
 local takeDamage=require(modules.shared.PlayerDamage)
 takeDamage(s,humanoid,25,effect);assert(s.shield==17 and humanoid.Health==150,'Shield absorbs first')
 takeDamage(s,humanoid,30,effect);assert(s.shield==0 and humanoid.Health==137,'Shield overflow reaches health')
 spells.Step(s,root,.05);assert(#s.areaCasts==0,'Broken shield visual ends')
 s.wardClock=0;spells.Step(s,root,.05);spells.Clear(s);assert(s.shield==0 and #s.areaCasts==0,'Death cancels all casts and shield')
 return {meteor=true,blades=true,frost=true,ward=true,cleanup=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
