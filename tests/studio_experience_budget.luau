-- Server Play fixture: real Parts/Humanoids, isolated from the active round.
local folder=Instance.new('Folder');folder.Name='ExperienceBudgetCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local actors=require(modules.shared.Actors)({world=folder})
 local states,gems={},{}
 local function playerAt(x)
  local model=Instance.new('Model');model.Parent=folder
  local root=actors.Block(model,'HumanoidRootPart',Vector3.one,Vector3.new(x,3,250),Color3.new())
  local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=model;h.WalkSpeed=22
  local player={Character=model}
  local s={player=player,level=1000,xp=0,magnet=0,agility=0,cooldown=0,kills=0,over=false,loadout={'ice','meteor','ward','missile'},golem=1}
  states[player]=s;return s,root
 end
 local a,ar=playerAt(-200)
 local b=playerAt(-180)
 local spectator=playerAt(-160);spectator.lobby=true
 local dead=playerAt(-140);dead.over=true
 local players=require(modules.shared.PlayerState)({states=states})
 local packets={}
 local p=require(modules.flow.Progression)({world=folder,states=states,gems=gems,block=actors.Block,
  rootOf=players.RootOf,rng=Random.new(10),paused=function()return false end,
  clock={elapsed=0,roundLength=120},update={FireClient=function(_,_,packet)table.insert(packets,packet)end}})
 local function total()
  local n=0;for _,g in ipairs(gems)do n+=g.value or 1 end;return n
 end
 local function reset()
  for _,g in ipairs(gems)do g.part:Destroy()end;table.clear(gems)
 end

 -- Fill the budget, then overflow it without deleting any reward.
 for i=1,180 do p.Drop(Vector3.new(50+i,0,250))end
 for _=181,1000 do p.Drop(Vector3.new(51,0,250))end
 assert(#gems==180 and total()==1000,'All 1000 XP must survive the 180-part budget')
 assert(gems[1].value==821 and gems[1].part:GetAttribute('ExperienceValue')==821,'Nearest gem carries the full reward')
 assert(gems[1].part.Size.X<=1.201 and gems[1].part.Color==Color3.fromRGB(125,45,200),'Merged value is visible and size stays bounded')
 local moving=gems[1];moving.collector=a;local oldPos=moving.pos
 p.Drop(moving.pos)
 assert(moving.value==821 and moving.pos==oldPos and total()==1001,'Prefer an unclaimed gem without moving an attracted one')
 for _,g in ipairs(gems)do g.collector=a end
 p.Drop(moving.pos)
 assert(moving.value==822 and total()==1002,'When all gems travel, merge without dropping XP')
 -- One collector can pick up all values; each active teammate receives the same total once.
 ar.Position=Vector3.new(51,3,250)
 for _=1,200 do p.Collect(.05)end
 assert(#gems==0 and a.xp==1002 and b.xp==1002,'Shared pickup must grant the stored value exactly once')
 assert(spectator.xp==0 and dead.xp==0,'Lobby and ended players receive no run XP')
 p.Collect(.1);assert(a.xp==1002 and b.xp==1002,'Repeated collection cannot duplicate XP')

 -- A large gem must queue multiple levels without overwriting the current card.
 a.level=1;a.xp=0;a.offers=nil;a.golem=1;a.rerolls=2
 ar.Position=Vector3.new(0,3,250)
 for _=1,180 do p.Drop(Vector3.new(0,0,250))end
 for _=1,30 do p.Drop(Vector3.new(0,0,250))end
 assert(total()==210)
 -- Retain the 31-XP gem; the other 179 XP is only removed by fixture cleanup.
 for i=#gems,2,-1 do gems[i].part:Destroy();table.remove(gems,i)end
 p.Collect(.1)
 assert(a.level==2 and a.xp==26 and a.offers,'First level consumes only its requirement')
 local count=0
 while a.offers do
  local revision=a.offerRevision;local id=a.offers[1].id
  p.Choose(a,id,revision);count+=1;assert(count<10,'Queued levels must terminate')
  local level,xp=a.level,a.xp;p.Choose(a,id,revision)
  assert(a.level==level and a.xp==xp,'Stale choices cannot consume another level')
 end
 assert(a.level==4 and a.xp==7 and count==3,'5+8+11 XP consumed; 7 XP remains')
 assert(a.player.Character.Humanoid.WalkSpeed>0,'Movement restored after queued choices')
 reset();p.Drop(Vector3.new(0,0,250));assert(#gems==1 and gems[1].value==1,'Fresh round has no carried gem value')
 return 'PASS: 1002 XP conserved in 180 parts, nearest/claimed merge, shared pickup once, lobby/dead exclusion, 31-XP queued levels and reset'
end,debug.traceback)
folder:Destroy();assert(ok,result);return result
