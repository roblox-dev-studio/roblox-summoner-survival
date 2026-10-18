-- Only presentation; server still owns roots, contact damage, freeze and death.
return function()
 local mesh=require(script.Parent.EnemyVisuals)
 local motion=require(script.Parent.EnemyMotion)
 local world=workspace:WaitForChild('SummonerRuntime');local rigs,creating={},{};local elapsed=0
 local function attach(model)
  if not model:IsA('Model')or not mesh.supports(model:GetAttribute('EnemyKind'))or rigs[model]or creating[model]then return end
  creating[model]=true
  task.spawn(function()
   local ok,rig=pcall(mesh.create,model);creating[model]=nil
   if not ok then warn('[EnemyPresentation] '..tostring(rig));return end
   if not rig then return end
   local root=model.PrimaryPart
   if not model.Parent or not root or not root.Parent then mesh.destroy(rig);return end
   rig.root=root;rig.previous=rig.root.Position;rig.motion=motion.create(model.Name..':'..model:GetAttribute('EnemyKind'),mesh.duration(rig,'walk'));rig.attack=0;rig.attackTime=10;rig.prepareTime=0;rig.modelScale=model:GetScale();rig.wasElite=model:GetAttribute('Elite');rig.frame=rig.root.CFrame;rigs[model]=rig
  end)
 end
 for _,v in ipairs(world:GetChildren())do attach(v)end
 world.ChildAdded:Connect(attach)
 game:GetService('RunService').RenderStepped:Connect(function(dt)
  elapsed+=dt;if elapsed<1/24 then return end;local delta=elapsed;elapsed=0
  local camera=workspace.CurrentCamera
  for model,rig in pairs(rigs)do
   if not model.Parent or not rig.root.Parent then mesh.destroy(rig);rigs[model]=nil
   elseif model:GetScale()~=rig.modelScale or model:GetAttribute('Elite')~=rig.wasElite then mesh.destroy(rig);rigs[model]=nil;attach(model)
   else
    local target=rig.root.CFrame;local movement=target.Position-rig.previous;local distance=Vector3.new(movement.X,0,movement.Z).Magnitude;rig.previous=target.Position
    local frozen=model:GetAttribute('Frozen')
    local attack=model:GetAttribute('AttackSequence')or 0
    if attack~=rig.attack then rig.attack=attack;rig.attackTime=0 end
    motion.advance(rig.motion,delta,distance,rig.stride,frozen)
    if not frozen then rig.attackTime+=delta end
    rig.frame=rig.frame:Lerp(target,1-math.exp(-delta*24))
    -- Far actors keep the shared mesh, but skip bone evaluation until near the camera.
    if not camera or(camera.CFrame.Position-target.Position).Magnitude<110 then
     local preparing=model:GetAttribute('Preparing')
     if not frozen then if preparing then rig.prepareTime+=delta else rig.prepareTime=0 end end
     rig.charging=preparing or model:GetAttribute('Detonating')
     local mode=preparing and'prepare'or(rig.attackTime<mesh.duration(rig,'attack')and'attack'or(rig.motion.speed>.35 and'walk'or'idle'))
     if frozen then mode=rig.mode or'idle'end;rig.mode=mode
     local visualFrame=motion.frame(rig.motion,rig.frame,delta,mode=='walk',frozen)
     if model:GetAttribute('EnemyKind')=='commander'then
      local action=model:GetAttribute('FieldAction')or'idle'
      mesh.pose(rig,visualFrame,(action=='approach'or action=='charge')and rig.motion.gait or rig.motion.time,action)
     else
     local clock=mode=='prepare'and rig.prepareTime or(mode=='attack'and rig.attackTime or(mode=='walk'and rig.motion.gait or rig.motion.time))
     if frozen then clock=rig.poseTime or clock else rig.poseTime=clock end
     mesh.pose(rig,visualFrame,clock,mode)
     end
    else mesh.place(rig,rig.frame)end
   end
  end
 end)
end
