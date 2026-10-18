-- Client fixture: all roles use distinct visuals, weapons track animated hands,
-- independent rigs share immutable meshes, and close/switch releases local objects.
local modules=game.Players.LocalPlayer.PlayerScripts.SummonerClient.Modules.world
local renderer=require(modules.EnemyVisuals)
local templates=game.ReplicatedStorage.EnemyPreviewModels
local holder=Instance.new('Folder');holder.Name='EnemyRosterCheck';holder.Parent=workspace
local rigs={}
local ok,result=xpcall(function()
 local seen={};local expected={stalker=0,skitter=2,brute=2,caster=1,ember=1}
 for _,kind in ipairs({'stalker','skitter','brute','caster','ember','charger'})do
  for _,elite in ipairs({false,true})do
   local model=templates[kind]:Clone();model.Parent=holder;if elite then model:ScaleTo(1.2);model:SetAttribute('Elite',true)end;model:PivotTo(CFrame.new(0,3,0))
   local rig=renderer.create(model);assert(rig and model:GetAttribute('SkeletonMeshStatus')=='Ready',kind..' visual available');table.insert(rigs,rig)
   local profile=model:GetAttribute('VisualProfile');seen[kind]=profile
   if kind~='charger'then
    assert(rig.part.HasSkinnedMesh,kind..' has native skinning')
    local count=kind=='stalker'and(elite and 2 or 0)or expected[kind]
    assert(model:GetAttribute('EquipmentCount')==count,kind..' correct equipment')
    if count>0 and not rig.profile.bomb then
     renderer.pose(rig,CFrame.new(0,3,0),.1,'attack');local first=rig.gear[1].part.CFrame
     renderer.pose(rig,CFrame.new(0,3,0),.5,'attack');assert(first~=rig.gear[1].part.CFrame,kind..' weapon follows original animation')
     local item=rig.gear[1];local expectedFrame=item.bone.TransformedWorldCFrame*item.rotation*CFrame.new(item.offset*rig.scale)
     assert((expectedFrame.Position-item.part.Position).Magnitude<.001,kind..' weapon stays on hand')
    end
    if kind=='ember'then
     rig.charging=true;renderer.pose(rig,CFrame.new(0,3,0),.3,'idle');assert(rig.sparks.Rate==24 and model.EnemyEquipment:FindFirstChild('EmberBomb'),'Bomb fuse anticipates explosion')
    end
   else
    renderer.pose(rig,CFrame.new(0,3,0),.1,'walk');local foot=rig.legs[1].paw.Position;local tail=rig.tail[4].CFrame
    renderer.pose(rig,CFrame.new(0,3,0),.4,'walk');assert(foot~=rig.legs[1].paw.Position and tail~=rig.tail[4].CFrame,'Hound limbs and tail articulate')
    local lowest=math.huge;for _,leg in ipairs(rig.legs)do lowest=math.min(lowest,leg.paw.Position.Y)end;assert(lowest>=0,'Elite hound paws above floor')
   end
   renderer.place(rig,CFrame.new(7,3,5));renderer.destroy(rig)
   assert(not model:FindFirstChild('KayKitSkeleton')and not model:FindFirstChild('EnemyEquipment')and not model:FindFirstChild('AshHound'),kind..' cleanup')
   for part,old in pairs(rig.hidden)do assert(part.LocalTransparencyModifier==old,kind..' fallback restored')end
  end
 end
 assert(seen.stalker~=seen.skitter and seen.skitter~=seen.caster and seen.ember~=seen.caster and seen.charger=='AshHound','Role silhouettes use distinct assets')
 return {roles=6,eliteVariants=6,handAttachments=true,animatedWeapons=true,bombFuse=true,houndLegsAndTail=true,cleanup=true}
end,debug.traceback)
for _,rig in ipairs(rigs)do renderer.destroy(rig)end;holder:Destroy();renderer.releaseUnused();if not ok then error(result)end;return result
