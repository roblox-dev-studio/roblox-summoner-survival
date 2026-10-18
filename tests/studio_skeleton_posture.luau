-- Client fixture: eliminate constant torso lean without changing foot animation.
local modules=game.Players.LocalPlayer.PlayerScripts.SummonerClient.Modules.world
local Mesh=require(modules.SkeletonMesh)
local folder=Instance.new('Folder');folder.Name='PostureCheck';folder.Parent=workspace
local rig
local ok,result=xpcall(function()
 local m=game.ReplicatedStorage.EnemyPreviewModels.stalker:Clone();m.Parent=folder;rig=Mesh.create(m);assert(rig,'Skeleton ready')
 local raw=require(modules.skeleton.Walk);local source=require(modules.skeleton.Rig)
 local indices={};for i,b in ipairs(source.bones)do indices[b.name]=i end
 local maxLean,totalLean,maxHeadRoll=0,0,0;local firstFoot
 for f,frame in ipairs(raw.frames)do
  local time=(f-1)/(#raw.frames-1)*raw.duration
  Mesh.pose(rig,CFrame.new(0,3,0),time,'walk')
  local hips=rig.byName.hips.TransformedWorldCFrame.Position;local head=rig.byName.head.TransformedWorldCFrame.Position
  local line=rig.part.CFrame:VectorToObjectSpace(head-hips)
  local lean=math.deg(math.atan2(line.X,line.Y));maxLean=math.max(maxLean,math.abs(lean));totalLean+=lean
  local up=rig.part.CFrame:VectorToObjectSpace(rig.byName.head.TransformedWorldCFrame.UpVector)
  maxHeadRoll=math.max(maxHeadRoll,math.abs(math.deg(math.atan2(up.X,up.Y))))
  if f<#raw.frames then
   local footIndex=indices['foot.l'];local rest=CFrame.new(table.unpack(source.bones[footIndex].rest))
   local expected=rest:ToObjectSpace(CFrame.new(table.unpack(frame[footIndex])))
   local observed=rig.byName['foot.l'].Transform
   assert((observed.Position-expected.Position).Magnitude<.001 and observed.UpVector:Dot(expected.UpVector)>.9999,'Original foot motion preserved')
  end
  if f==1 then firstFoot=rig.byName['foot.l'].Transform elseif f==10 then assert(firstFoot~=rig.byName['foot.l'].Transform,'Foot still animates')end
 end
 assert(maxLean<3 and math.abs(totalLean/#raw.frames)<.2,'Walk alternates about upright rather than permanently leaning')
 assert(maxHeadRoll<.2,'Visible head and attached helmet stay upright through the entire cycle')
 Mesh.pose(rig,CFrame.new(0,3,0),.3,'idle')
 local line=rig.byName.head.TransformedWorldCFrame.Position-rig.byName.hips.TransformedWorldCFrame.Position
 assert(math.abs(math.deg(math.atan2(line.X,line.Y)))<.2,'Neutral idle unchanged')
 return {maxWalkLeanDegrees=maxLean,maxHeadRollDegrees=maxHeadRoll,meanLeanDegrees=totalLean/#raw.frames,feetPreserved=true,walking=true,idle=true}
end,debug.traceback)
if rig then Mesh.destroy(rig)end;folder:Destroy();Mesh.releaseUnused();if not ok then error(result)end;return result
