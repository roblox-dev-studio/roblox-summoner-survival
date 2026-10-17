-- Run on Client: exercises real EditableMesh vertices, not a mocked rig.
local world=game.Players.LocalPlayer.PlayerScripts.SummonerClient.Modules.world
local renderer=require(world.DragonMesh)
local geometry=require(world.dragon.Geometry)
local skeleton=require(world.dragon.Rig)
local folder=Instance.new('Model');folder.Name='DragonMotionCheck';folder.Parent=workspace
local rig
local ok,result=xpcall(function()
 local walk=require(world.dragon.Walk)
 local names={};for _,bone in ipairs(skeleton.bones)do names[bone.index]=bone.name end
 for index,name in pairs(names)do
  if string.find(name,'leg_')or string.find(name,'wing_')then
   assert(walk.tracks[tostring(index)],'Missing animated joint: '..name)
  end
 end
 rig=renderer.create(folder)
 local function pose(mode,time,gait)
  for _=1,24 do renderer.pose(rig,CFrame.identity,time,mode,.5,gait)end
  local points={};local lo,hi=math.huge,-math.huge
  for i,id in ipairs(rig.ids)do local p=rig.mesh:GetPosition(id);points[i]=p;lo=math.min(lo,p.X);hi=math.max(hi,p.X)end
  return points,hi-lo
 end
 local a=pose('walk',0,0);local b=pose('walk',0,.5)
 local movement=0
 for i,weights in ipairs(geometry.weights)do
  for _,weight in ipairs(weights)do
   if weight[2]>.3 and string.find(names[weight[1]],'foot')then movement=math.max(movement,(a[i]-b[i]).Magnitude)end
  end
 end
 assert(movement>.5,'Walking feet must move with gait time')
 local _,idleWidth=pose('idle',0,0)
 local flight,flightWidth=pose('fly',.4,0)
 assert(flightWidth>idleWidth*1.5,'Flight must unfold a visibly wider silhouette')
 local other=pose('fly',1,0);local flap=0
 for i,weights in ipairs(geometry.weights)do
  for _,weight in ipairs(weights)do
   if weight[2]>.3 and string.find(names[weight[1]],'wing')then flap=math.max(flap,(flight[i]-other[i]).Magnitude)end
  end
 end
 assert(flap>1,'Wing vertices must flap')
 local _,airWidth=pose('airBreath',.4,0)
 assert(airWidth>idleWidth*1.2,'Air breath retains spread wings')
 pose('dive',.4,0);assert(rig.part.CFrame.LookVector.Y<-.1,'Dive leans forward')
 pose('breath',0,0)
 assert(typeof(folder:GetAttribute('DragonMouth'))=='Vector3','Animated mouth tracks the rendered jaw')
 return string.format('PASS: animated legs/wings retained; foot movement %.2f; wing span %.2f -> %.2f; flap %.2f; mouth anchor',movement,idleWidth,flightWidth,flap)
end,debug.traceback)
if rig then renderer.destroy(rig)end
folder:Destroy();assert(ok,result);return result
