-- Studio Server play-mode regression check in a disposable fixture.
local folder=Instance.new('Folder');folder.Name='MagnetCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local actors=require(modules.shared.Actors)({world=folder})
 local states,gems={},{}
 local function playerAt(x)
  local player={};local root=actors.Block(folder,'TestRoot',Vector3.one,Vector3.new(x,3,250),Color3.new())
  local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=folder;h.WalkSpeed=22
  local s={player=player,root=root,h=h,level=100,xp=0,magnet=0,over=false}
  states[player]=s;return s
 end
 local a,b=playerAt(0),playerAt(200)
 local function rootOf(s)if not s.over then return s.root,s.h end end
 local p=require(modules.flow.Progression)({world=folder,states=states,gems=gems,block=actors.Block,rootOf=rootOf})
 p.Drop(Vector3.new(19,0,250));p.Collect(.05)
 assert(gems[1].collector==nil,'Outside base radius should stay on ground')
 a.root.Position=Vector3.new(2,3,250);p.Collect(.05)
 assert(gems[1].collector==a and gems[1].pos.X<19,'Enter radius to start attraction')
 a.root.Position=Vector3.new(-30,3,250);local before=gems[1].pos.X;p.Collect(.05)
 assert(gems[1].collector==a and gems[1].pos.X<before,'Attracted XP must follow beyond radius')
 for _=1,100 do p.Collect(.05) end
 assert(#gems==0 and a.xp==1 and b.xp==1,'Pickup and shared XP exactly once')
 p.Collect(.2);assert(a.xp==1 and b.xp==1,'No duplicate reward')
 a.root.Position=Vector3.new(0,3,250);a.magnet=1
 p.Drop(Vector3.new(20,0,250));p.Collect(.05)
 assert(gems[1].collector==a,'Magnet upgrade expands pickup radius')
 b.root.Position=Vector3.new(19,3,250);a.over=true;p.Collect(.2)
 assert(#gems==0 and b.xp==2 and a.xp==1,'Reassign dead collector and exclude them from XP')
 a.over=false;a.magnet=0;a.offers={};a.root.Position=Vector3.new(0,3,250);b.root.Position=Vector3.new(200,3,250)
 p.Drop(Vector3.new(10,0,250));p.Collect(.1)
 assert(gems[1].collector==nil,'Choice screen must not attract new XP')
 a.offers=nil;p.Collect(.1);states[a.player]=nil;b.root.Position=Vector3.new(10,3,250);p.Collect(.2)
 assert(#gems==0 and b.xp==3,'Reassign disconnected collector')
 return 'PASS: 18-stud attraction, sticky following, pickup once, shared XP, magnet upgrade, dead/disconnected collector reassignment, choice guard'
end,debug.traceback)
folder:Destroy();assert(ok,result);return result
