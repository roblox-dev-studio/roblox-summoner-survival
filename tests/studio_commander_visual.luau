-- Run in Client Play; exercise the live presentation watcher and cleanup.
local world=workspace:WaitForChild('SummonerRuntime');local m=game.ReplicatedStorage.EnemyPreviewModels.stalker:Clone()
m.Name='CommanderVisualCheck';m:SetAttribute('EnemyKind','commander');m:SetAttribute('FieldAction','approach');m:PivotTo(CFrame.new(0,3,-15));m.Parent=world
local run=game:GetService('RunService');local camera=workspace.CurrentCamera;local saved={frame=camera.CFrame,focus=camera.Focus,kind=camera.CameraType}
run:BindToRenderStep('CommanderVisualCheckCamera',999,function()camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(Vector3.new(20,14,10),Vector3.new(0,6,-15))end)
local ok,result=xpcall(function()
 local deadline=os.clock()+10;repeat task.wait()until m:GetAttribute('SkeletonMeshStatus')or os.clock()>deadline
 assert(m:GetAttribute('SkeletonMeshStatus')=='Ready','Native rider ready')
 assert(m:FindFirstChild('SpectralWarhorse')and #m.SpectralWarhorse:GetChildren()>=60,'Horse and royal equipment created')
 assert(m:GetAttribute('EquipmentCount')==2,'Blade and shield follow native hands')
 local hoof=m.SpectralWarhorse:FindFirstChild('Hoof');local before=hoof.CFrame;local relative=m:GetPivot():ToObjectSpace(before)
 for _=1,12 do m:PivotTo(m:GetPivot()*CFrame.new(0,0,-.3));task.wait(.05)end
 local rootMove=(m:GetPivot().Position-Vector3.new(0,3,-15)).Magnitude
 assert(rootMove>3 and(hoof.CFrame.Position-before.Position).Magnitude>1,'Horse follows authoritative root')
 assert((m:GetPivot():ToObjectSpace(hoof.CFrame).Position-relative.Position).Magnitude>.005,'Hooves articulate beyond whole-body translation')
 local bone=m.KayKitSkeleton:FindFirstChild('head',true);assert(bone and bone.TransformedWorldCFrame.Position.Y>7,'Mounted rider lifted above saddle')
 m:SetAttribute('FieldAction','cleaveWindup');m:SetAttribute('FieldProgress',.8);task.wait(.1);assert(m:GetAttribute('SkeletonMotion')=='sweep','Cleave windup uses sword animation')
 m:SetAttribute('FieldAction','charge');task.wait(.1);assert(m:GetAttribute('SkeletonMotion')=='guard','Mounted charge braces rider')
 return {nativeRider=true,horse=true,equipment=true,movement=true,actionAnimation=true}
end,debug.traceback)
m:Destroy();run:UnbindFromRenderStep('CommanderVisualCheckCamera');camera.CFrame=saved.frame;camera.Focus=saved.focus;camera.CameraType=saved.kind;task.wait(.1);assert(not world:FindFirstChild('CommanderVisualCheck'),'Visual cleanup')
if not ok then error(result)end;return result
