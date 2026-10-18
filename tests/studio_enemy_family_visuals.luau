-- Client fixture for all six original native rigs. Run in Studio client context.
-- Direct renderer checks supplement (not replace) the existing six-role imported mesh tests.
local modules=game.Players.LocalPlayer.PlayerScripts.SummonerClient.Modules.world
local Visuals=require(modules.EnemyVisuals);local Motion=require(modules.EnemyMotion)
local templates=game.ReplicatedStorage.EnemyPreviewModels
local kinds={'slime_blob','slime_spitter','slime_bulwark','crystal_scout','crystal_lancer','crystal_mage'}
local holder=Instance.new('Folder');holder.Name='EnemyFamilyVisualCheck';holder.Parent=workspace
local rigs={}
local function snapshot(rig)
 local state={};for _,p in ipairs(rig.visual:GetDescendants())do if p:IsA('BasePart')then state[p]={cf=p.CFrame,size=p.Size}end end;return state
end
local function differs(a,b)
 for p,v in pairs(a)do if v.cf~=b[p].cf or v.size~=b[p].size then return true end end;return false
end
local ok,result=xpcall(function()
 assert(#templates:GetChildren()==12,'All twelve identities in the gallery')
 local profiles={};local partCounts={};local normalSize={}
 for _,kind in ipairs(kinds)do
  for _,elite in ipairs({false,true})do
   local model=templates[kind]:Clone();model.Parent=holder;model:PivotTo(CFrame.new(0,3,0))
   if elite then model:ScaleTo(1.2);model:SetAttribute('Elite',true)end
   local root=model.PrimaryPart;local anchor=root.CFrame
   local rig=Visuals.create(model);assert(rig and model:GetAttribute('SkeletonMeshStatus')=='Ready',kind..' native renderer ready');table.insert(rigs,rig)
   assert(model:GetAttribute('EnemyVisualFamily')==model:GetAttribute('EnemyFamily'),kind..' family routed')
   profiles[model:GetAttribute('VisualProfile')]=true
   local count=0
   for _,p in ipairs(rig.visual:GetDescendants())do
    assert(not p:IsA('MeshPart')and not p:IsA('LuaSourceContainer'),kind..' no uploaded mesh or injected code')
    if p:IsA('BasePart')then count+=1;assert(p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery,kind..' visual-only parts')end
   end
   assert(count<=40,kind..' native part budget');partCounts[kind]=count
   assert(Visuals.duration(rig,'walk')>.4 and rig.stride>0,kind..' shared gait contract')
   Visuals.pose(rig,anchor,.15,'idle');local start=snapshot(rig)
   Visuals.pose(rig,anchor,.55,'idle');assert(differs(start,snapshot(rig)),kind..' alive idle')
   for _,mode in ipairs({'walk','prepare','attack'})do
    Visuals.pose(rig,anchor,.12,mode);local before=snapshot(rig)
    Visuals.pose(rig,anchor,.46,mode);assert(differs(before,snapshot(rig)),kind..' '..mode..' articulation')
   end
   local motion=Motion.create(kind,.8);Motion.advance(motion,.2,2,rig.stride,false)
   local frozenFrame=Motion.frame(motion,anchor,.2,true,false)
   Visuals.pose(rig,frozenFrame,motion.gait,'walk');local held=snapshot(rig)
   Motion.advance(motion,.5,4,rig.stride,true)
   Visuals.pose(rig,Motion.frame(motion,anchor,.5,true,true),motion.gait,'walk')
   assert(not differs(held,snapshot(rig)),kind..' frozen clocks hold every part')
   Visuals.pose(rig,anchor,0,'idle');local first=rig.pieces[1].part.Size
   if elite then assert((first-normalSize[kind]*1.2).Magnitude<.001,kind..' geometry scales exactly 1.2')else normalSize[kind]=first end
   if rig.legs then for _,leg in ipairs(rig.legs)do assert(leg.foot.Position.Y-leg.foot.Size.Y*.5>=-.01,kind..' ground claws above floor')end end
   if rig.body then for _,v in ipairs(rig.pieces)do if v.group=='foot'then assert(v.part.Position.Y-v.part.Size.Y*.5>=-.01,kind..' pseudopods grounded')end end end
   Visuals.pose(rig,anchor,.35,'prepare');local old=rig.pieces[1].part.CFrame;local oldSize=rig.pieces[1].part.Size
   Visuals.place(rig,anchor+Vector3.new(7,0,5));assert((rig.pieces[1].part.Position-old.Position-Vector3.new(7,0,5)).Magnitude<.001 and rig.pieces[1].part.Size==oldSize,kind..' culling placement preserves pose')
   assert(root.CFrame==anchor,kind..' renderer never moves the server anchor')
   Visuals.destroy(rig);Visuals.destroy(rig)
   assert(not rig.visual.Parent,kind..' cleanup is idempotent')
   for p,value in pairs(rig.hidden)do assert(p.LocalTransparencyModifier==value,kind..' fallback restored')end
   model:Destroy()
  end
 end
 local unique=0;for _ in pairs(profiles)do unique+=1 end;assert(unique==6,'Six distinct visual profiles')
 return {types=6,variants=12,nativeParts=partCounts,allModes=true,eliteScale=true,freeze=true,groundContact=true,anchorUnchanged=true,cleanup=true}
end,debug.traceback)
for _,rig in ipairs(rigs)do Visuals.destroy(rig)end;holder:Destroy()
if not ok then error(result)end;return result
