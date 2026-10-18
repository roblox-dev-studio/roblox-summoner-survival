-- Client fixture: native deformation, independent instances, scale, shared data and cleanup.
local modules=game.Players.LocalPlayer.PlayerScripts.SummonerClient.Modules.world
local mesh=require(modules.SkeletonMesh)
local folder=Instance.new('Folder');folder.Name='SkeletonCheck';folder.Parent=workspace
local template=game.ReplicatedStorage.EnemyPreviewModels.stalker
local rigs={}
local ok,result=xpcall(function()
 local models={}
 for i=1,16 do
  local m=template:Clone();m.Parent=folder;m:PivotTo(CFrame.new(i*8,3,0));if i==2 then m:ScaleTo(1.2)end
  local rig=mesh.create(m);assert(rig and m:GetAttribute('SkeletonMeshStatus')=='Ready','Imported mesh created')
  assert(rig.part.HasSkinnedMesh and #rig.part:GetDescendants()==42,'Native skinned geometry and original rig')
  rigs[i]=rig;models[i]=m
 end
 assert(rigs[1].part.MeshContent==rigs[2].part.MeshContent,'Instances share one immutable mesh')
 local function bone(rig,name)for _,b in ipairs(rig.bones)do if b.Name==name then return b end end;error(name)end
 mesh.pose(rigs[1],CFrame.new(8,3,0),0,'walk');local leg=bone(rigs[1],'lowerleg.l');local first=leg.Transform
 mesh.pose(rigs[1],CFrame.new(8,3,0),.4,'walk');assert(first~=leg.Transform,'Original walking clip animates leg')
 mesh.pose(rigs[2],CFrame.new(16,3,0),.25,'attack');local arm=bone(rigs[2],'lowerarm.r');local attack=arm.Transform
 mesh.pose(rigs[2],CFrame.new(16,3,0),.6,'attack');assert(attack~=arm.Transform,'Original melee clip animates arm')
 assert(leg.Transform~=bone(rigs[2],'lowerleg.l').Transform,'Separate bone poses per instance')
 local center=Vector3.new(table.unpack(require(modules.skeleton.Rig).center))
 assert(math.abs(rigs[2].part.Position.Y-center.Y*1.2)<.001,'Elite feet retain same ground level')
 local start=os.clock()
 for frame=1,24 do for i,rig in ipairs(rigs)do mesh.pose(rig,models[i]:GetPivot(),frame/24+i*.07,'walk')end end
 local elapsed=os.clock()-start
 for i,m in ipairs(models)do
  for v in pairs(rigs[i].hidden)do assert(v.LocalTransparencyModifier==1,'Fallback hidden only after success')end
  mesh.destroy(rigs[i]);assert(not m:FindFirstChild('KayKitSkeleton'),'Mesh and bones removed')
  for v,previous in pairs(rigs[i].hidden)do assert(v.LocalTransparencyModifier==previous,'Fallback restored')end
 end
 return {nativeSkin=true,sharedMesh=true,walk=true,attack=true,independent=true,eliteGround=true,cleanup=true,instances=16,pose24FramesSeconds=elapsed}
end,debug.traceback)
for _,rig in ipairs(rigs)do mesh.destroy(rig)end
folder:Destroy();mesh.releaseUnused();if not ok then error(result)end;return result
