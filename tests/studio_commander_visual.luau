-- Client live watcher, original royal armor, two-handed polearm and server-timed poses.
local world=workspace:WaitForChild('SummonerRuntime');local m=game.ReplicatedStorage.EnemyPreviewModels.stalker:Clone()
m.Name='CommanderVisualCheck';m:SetAttribute('EnemyKind','commander');m:SetAttribute('FieldAction','approach');m:PivotTo(CFrame.new(0,3,-15));m.Parent=world
local run=game:GetService('RunService');local camera=workspace.CurrentCamera;local saved={frame=camera.CFrame,focus=camera.Focus,kind=camera.CameraType}
run:BindToRenderStep('CommanderVisualCheckCamera',999,function()camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(Vector3.new(20,14,10),Vector3.new(0,6,-15))end)
local ok,result=xpcall(function()
 local deadline=os.clock()+10;repeat task.wait()until m:GetAttribute('SkeletonMeshStatus')or os.clock()>deadline
 assert(m:GetAttribute('SkeletonMeshStatus')=='Ready','Original knight ready')
 local art=m.SpectralWarhorse
 assert(m:GetAttribute('CommanderStyle')=='GildedHalberdKnight'and art.ClosedHelmet and art.HelmetCrest and art.KnightVisor,'Royal closed helm replaces generic skeleton')
 assert(not m:FindFirstChild('KayKitSkeleton')and not m:FindFirstChild('EnemyEquipment'),'No generic warrior mesh or shield equipment')
 assert(art.HalberdShaft and m:GetAttribute('EquipmentCount')==1,'Single original halberd')
 local facets=0;for _,p in ipairs(art:GetChildren())do if p.Name=='HalberdBladeFacet'then facets+=1 end;assert(not p.Name:find('Shield'),'No shield')end
 assert(facets>=14,'Beveled axe faces')
 local hoof=art:FindFirstChild('Hoof');local before=hoof.CFrame;local relative=m:GetPivot():ToObjectSpace(before)
 for _=1,12 do m:PivotTo(m:GetPivot()*CFrame.new(0,0,-.3));task.wait(.05)end
 assert((hoof.Position-before.Position).Magnitude>1,'Horse follows server root')
 assert((m:GetPivot():ToObjectSpace(hoof.CFrame).Position-relative.Position).Magnitude>.005,'Horse leg articulation')
 assert(art.ClosedHelmet.Position.Y>9,'Seated rider above saddle')
 local poses={}
 for _,action in ipairs({'cleaveWindup','cleave','slamWindup','slam','thrustWindup','thrust','charge'})do
  m:SetAttribute('FieldAction',action);m:SetAttribute('FieldProgress',.75);task.wait(.1)
  assert(m:GetAttribute('CommanderMotion')==action,'Correct action pose');poses[action]=art.HalberdShaft.CFrame
  local grips={};for _,p in ipairs(art:GetChildren())do if p.Name=='Gauntlet'then table.insert(grips,p.Position)end end
  if action=='slam'then local low=math.huge;for _,part in ipairs(art:GetChildren())do if part.Name=='HalberdBladeFacet'then low=math.min(low,part.Position.Y)end end;assert(low<3,'Overhead blade reaches the ground zone')end
  assert(#grips==2,'Two hands')
  for _,at in ipairs(grips)do local localPos=art.HalberdShaft.CFrame:PointToObjectSpace(at);assert(math.abs(localPos.X)<.01 and math.abs(localPos.Z)<.01,'Hands stay on shaft')end
 end
 assert((poses.slamWindup.Position-poses.slam.Position).Magnitude>2,'Overhead weapon comes down')
 assert((poses.thrustWindup.Position-poses.thrust.Position).Magnitude>2,'Visible thrust extension')
 return {originalKnight=true,royalHelmet=true,noShield=true,halberd=true,twoHandGrip=true,movement=true,fourAttackPoses=true}
end,debug.traceback)
m:Destroy();run:UnbindFromRenderStep('CommanderVisualCheckCamera');camera.CFrame=saved.frame;camera.Focus=saved.focus;camera.CameraType=saved.kind;task.wait(.1)
assert(not world:FindFirstChild('CommanderVisualCheck'),'Visual cleanup');if not ok then error(result)end;return result
