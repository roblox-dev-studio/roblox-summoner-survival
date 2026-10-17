-- A single local mesh per boss; server only replicates root and animation state.
return function()
 local Run=game:GetService('RunService')
 local mesh=require(script.Parent.DragonMesh)
 local rigs={};local creating={};local elapsed=0
 local function attach(model)
  if rigs[model]or creating[model]then return end
  creating[model]=true
  task.spawn(function()
   local root=model:WaitForChild('Root',5)
   if not root or not model.Parent then creating[model]=nil;return end
   local ok,rig=pcall(mesh.create,model)
   creating[model]=nil
   if not ok then model:SetAttribute('DragonMeshStatus','Failed');warn('[DragonMesh] '..tostring(rig));return end
   if not model.Parent then mesh.destroy(rig);return end
   model:SetAttribute('DragonMeshStatus','Ready');rig.root=root;rig.time=0;rig.gaitTime=0;rig.previousPosition=root.Position;rig.visualFrame=root.CFrame;rigs[model]=rig
  end)
 end
 local world=workspace:WaitForChild('SummonerRuntime')
 for _,v in ipairs(world:GetChildren())do if v.Name=='EmberDragon'then attach(v)end end
 world.ChildAdded:Connect(function(v)if v.Name=='EmberDragon'then attach(v)end end)
 Run.RenderStepped:Connect(function(dt)
  elapsed+=dt;if elapsed<1/24 then return end
  local delta=elapsed;elapsed=0
  for model,rig in pairs(rigs)do
   if not model.Parent or not rig.root.Parent then mesh.destroy(rig);rigs[model]=nil
   else
    rig.time+=delta
    local mode=model:GetAttribute('Animation')or'idle'
    local movement=rig.root.Position-rig.previousPosition;rig.previousPosition=rig.root.Position
    local distance=Vector3.new(movement.X,0,movement.Z).Magnitude
    if mode=='walk'then rig.gaitTime+=math.min(distance,3)/12*1.66667 end
    local target=rig.root.CFrame
    local relative=rig.visualFrame:ToObjectSpace(target);local _,turn=relative:ToOrientation()
    rig.bank=(rig.bank or 0)+(math.clamp(-turn*.4,-.18,.18)-(rig.bank or 0))*.25
    rig.visualFrame=rig.visualFrame:Lerp(target,1-math.exp(-delta*24))
    mesh.pose(rig,rig.visualFrame,rig.time,mode,model:GetAttribute('PoseProgress')or 0,rig.gaitTime)
   end
  end
 end)
end
