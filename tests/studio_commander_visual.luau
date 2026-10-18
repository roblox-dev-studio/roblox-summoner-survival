-- Client live watcher: skeletal barding on CC0 horse animation, KayKit skull rider.
local world=workspace:WaitForChild('SummonerRuntime');local m=game.ReplicatedStorage.EnemyPreviewModels.stalker:Clone()
m.Name='CommanderVisualCheck';m:SetAttribute('EnemyKind','commander');m:SetAttribute('FieldAction','approach');m:PivotTo(CFrame.new(0,3,-15));m.Parent=world
local run=game:GetService('RunService');local camera=workspace.CurrentCamera;local saved={frame=camera.CFrame,focus=camera.Focus,kind=camera.CameraType}
run:BindToRenderStep('CommanderVisualCheckCamera',999,function()camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(Vector3.new(20,14,10),Vector3.new(0,6,-15))end)
local ok,result=xpcall(function()
 local deadline=os.clock()+12;repeat task.wait()until m:GetAttribute('SkeletonMeshStatus')or os.clock()>deadline
 assert(m:GetAttribute('SkeletonMeshStatus')=='Ready','Mounted rider ready')
 local art=m.SpectralWarhorse;local horse=art:FindFirstChild('QuaterniusHorse')
 assert(horse and horse.HasSkinnedMesh,'Original CC0 horse is natively skinned')
 assert(horse.Transparency==1 and horse:GetAttribute('HorseAppearance')=='ArmoredSkeleton','Living horse skin hidden')
 local barding=art.SkeletalHorseBarding
 assert(barding.HorseCranium and barding.LowerJaw and barding.EyeSocket and barding.ChestArmor and barding.HeadArmor and barding.HindArmor,'Skull and layered horse armor')
 local ribs=0;for _,p in ipairs(barding:GetChildren())do if p.Name=='RibBone'then ribs+=1 end end
 assert(ribs==96,'Separated ribs leave open cage')
 local headArmor=barding.HeadArmor;local head=horse:FindFirstChild('Head',true);local attachment=head.TransformedWorldCFrame:ToObjectSpace(headArmor.CFrame)
 assert(m:GetAttribute('CommanderStyle')=='SkeletonKnightCommander'and art.KayKitWarriorSkull:IsA('MeshPart')and art.ExposedNeck,'Actual KayKit skull and open helmet')
 assert(not art:FindFirstChild('HelmetCrest')and not art:FindFirstChild('HelmetWing')and not art:FindFirstChild('RoyalPlume'),'Royal helmet ornaments removed')
 assert(not m:FindFirstChild('KayKitSkeleton')and not m:FindFirstChild('EnemyEquipment'),'No generic warrior mesh or shield')
 assert(art.GreatswordGrip and not art:FindFirstChild('HalberdShaft')and m:GetAttribute('EquipmentCount')==1,'Greatsword replaces halberd')
 local facets=0;for _,p in ipairs(art:GetChildren())do if p.Name=='GreatswordBladeFacet'then facets+=1 end;assert(not p.Name:find('Shield'),'No shield')end
 assert(facets>=10,'Tapered double-sided blade faces')
 local leg=horse:FindFirstChild('FrontLowerLeg.L',true);local before=horse.CFrame:ToObjectSpace(leg.TransformedWorldCFrame)
 for _=1,12 do m:PivotTo(m:GetPivot()*CFrame.new(0,0,-.3));task.wait(.05)end
 local after=horse.CFrame:ToObjectSpace(leg.TransformedWorldCFrame)
 assert((after.Position-before.Position).Magnitude>.03 or after.LookVector:Dot(before.LookVector)<.99,'Original walking leg moves independently of world translation')
 assert(horse:GetAttribute('HorseMotion')=='walk','Uses original Walk clip')
 local armorAfter=head.TransformedWorldCFrame:ToObjectSpace(headArmor.CFrame)
 assert((armorAfter.Position-attachment.Position).Magnitude<.02 and armorAfter.LookVector:Dot(attachment.LookVector)>.999,'Head armor follows animated skull')
 local midpoint=(horse:FindFirstChild('FrontLowerLeg.L',true).TransformedWorldCFrame.Position+horse:FindFirstChild('FrontLowerLeg.L_end',true).TransformedWorldCFrame.Position)/2
 local found=false;for _,p in ipairs(barding:GetChildren())do if p.Name=='LimbBone'and(p.Position-midpoint).Magnitude<.02 then found=true end end
 assert(found,'Visible leg bone follows animated joints')
 assert(art.KayKitWarriorSkull.Position.Y>8 and art.KnightCuirass.Position.Y-horse:FindFirstChild('Torso2',true).TransformedWorldCFrame.Position.Y<6.3,'Rider seated over animated back')
 assert(m:GetAttribute('CommanderVisualScale')==1.8,'Whole mounted boss enlarged to 180 percent')
 assert(not art:FindFirstChild('CommanderHelmet')and not art:FindFirstChild('VisorShadow')and not art:FindFirstChild('NasalGuard'),'Box mask removed')
 local poses={}
 for _,action in ipairs({'cleaveWindup','cleave','slamWindup','slam','thrustWindup','thrust','charge'})do
  m:SetAttribute('FieldAction',action);m:SetAttribute('FieldProgress',.75);task.wait(.1)
  assert(m:GetAttribute('CommanderMotion')==action,'Correct weapon action pose');poses[action]=art.GreatswordGrip.CFrame
  if action=='charge'then assert(horse:GetAttribute('HorseMotion')=='gallop','Original Gallop on charge')end
  local grips={};for _,p in ipairs(art:GetChildren())do if p.Name=='Gauntlet'then table.insert(grips,p.Position)end end
  assert(#grips==2,'Two hands')
  for _,at in ipairs(grips)do local localPos=art.GreatswordGrip.CFrame:PointToObjectSpace(at);assert(math.abs(localPos.X)<.01 and math.abs(localPos.Z)<.01,'Hands stay on sword grip')end
 end
 assert((poses.slamWindup.Position-poses.slam.Position).Magnitude>2,'Overhead swing comes down')
 assert((poses.thrustWindup.Position-poses.thrust.Position).Magnitude>2,'Visible thrust extension')
 return {skeletalHorse=true,horseArmor=true,animatedBoneAttachments=true,cc0Horse=true,nativeSkinning=true,originalWalk=true,originalGallop=true,skeletonKnight=true,largerMount=true,noLegacyHelmet=true,noShield=true,greatsword=true,twoHandGrip=true,fourAttackPoses=true}
end,debug.traceback)
m:Destroy();run:UnbindFromRenderStep('CommanderVisualCheckCamera');camera.CFrame=saved.frame;camera.Focus=saved.focus;camera.CameraType=saved.kind;task.wait(.1)
assert(not world:FindFirstChild('CommanderVisualCheck'),'Visual cleanup');if not ok then error(result)end;return result
