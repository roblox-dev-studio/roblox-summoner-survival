local skeleton=require(script.Parent.SkeletonMesh)
local hound=require(script.Parent.HoundMesh)
local mount=require(script.Parent.CommanderMount)
local slime=require(script.Parent.SlimeMesh)
local crystal=require(script.Parent.CrystalMesh)
local profiles=require(script.Parent.EnemyProfiles)
local Visuals={}
function Visuals.supports(kind)return profiles[kind]~=nil or kind=='charger'end
function Visuals.create(model)
 local kind=model:GetAttribute('EnemyKind');local profile=profiles[kind]
 local renderer=kind=='commander'and mount or(kind=='charger'and hound or(profile and profile.family=='slime'and slime or(profile and profile.family=='crystal'and crystal or skeleton)))
 local rig=renderer.create(model);if rig then rig.renderer=renderer end;return rig
end
function Visuals.pose(rig,origin,time,mode)rig.renderer.pose(rig,origin,time,mode)end
function Visuals.place(rig,origin)rig.renderer.place(rig,origin)end
function Visuals.duration(rig,mode)return rig.renderer.duration and rig.renderer.duration(rig,mode)or .8 end
function Visuals.destroy(rig)if rig then rig.renderer.destroy(rig)end end
function Visuals.releaseUnused()skeleton.releaseUnused()end
return Visuals
