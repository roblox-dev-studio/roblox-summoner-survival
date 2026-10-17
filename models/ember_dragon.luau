-- Server hit anchor for the CC0 Cethiel/Drummyfish dragon, rendered on each client.
local Dragon={}
function Dragon.create(parent,cf)
 local model=Instance.new('Model');model.Name='EmberDragon';model:SetAttribute('DisplayName','흑염룡 · 아그니스');model:SetAttribute('IsBoss',true);model:SetAttribute('Animation','idle')
 local root=Instance.new('Part');root.Name='Root';root.Size=Vector3.new(7,9,15);root.CFrame=cf;root.Anchored=true;root.CanCollide=false;root.CanTouch=false;root.CanQuery=false;root.Transparency=1;root.Parent=model;model.PrimaryPart=root;model.Parent=parent
 return {model=model,root=root,origin=cf}
end
function Dragon.pose(rig,t,attack,progress,phase)
 rig.root.CFrame=rig.origin
 rig.model:SetAttribute('Animation',attack or'idle')
 rig.model:SetAttribute('PoseProgress',progress or 0)
 rig.model:SetAttribute('DragonPhase',phase or 1)
end
return Dragon
