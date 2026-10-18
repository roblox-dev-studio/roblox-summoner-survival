-- Client presentation integration. Uses the running LocalScript's watcher/cache,
-- rather than requiring a second renderer cache in the fixture's execution context.
-- These local visual-only models never enter authoritative enemies/AI/damage lists.
local world=workspace:WaitForChild('SummonerRuntime')
local templates=game.ReplicatedStorage:WaitForChild('EnemyPreviewModels')
local Run=game:GetService('RunService')
local camera=workspace.CurrentCamera
assert(camera,'ENVIRONMENT_UNAVAILABLE: Live roster needs a client camera')
local savedCamera={type=camera.CameraType,subject=camera.CameraSubject,frame=camera.CFrame,focus=camera.Focus,fov=camera.FieldOfView}
local rendered,heartbeats=0,0
local renderConnection=Run.RenderStepped:Connect(function()rendered+=1 end)
local heartbeatConnection=Run.Heartbeat:Connect(function()heartbeats+=1 end)
local models={}
local ok,result=xpcall(function()
 -- A locked/minimized Studio can keep Heartbeat alive while rendering is suspended.
 -- Do not wait on RenderStepped itself, which would hang in that environment.
 task.wait(2)
 assert(rendered>=2,string.format('ENVIRONMENT_UNAVAILABLE: RenderStepped inactive (%d frames, %d Heartbeats in 2 seconds). Unlock the Mac and keep the Studio client rendering before running this fixture.',rendered,heartbeats))
 -- Temporarily reuse the saved camera in Scriptable mode so replacing CurrentCamera
 -- cannot destroy Roblox's original camera. Every fixture row is within 110 studs.
 camera.CameraType=Enum.CameraType.Scriptable
 camera.CFrame=CFrame.lookAt(Vector3.new(0,20,12),Vector3.new(0,3,-25))
 camera.Focus=CFrame.new(0,3,-25)
 local count=0;local equipment={stalker=0,skitter=2,brute=2,caster=1,ember=1}
 for _,kind in ipairs({'stalker','skitter','brute','caster','ember','charger','slime_blob','slime_spitter','slime_bulwark','crystal_scout','crystal_lancer','crystal_mage'})do
  for _,elite in ipairs({false,true})do
   count+=1;local m=templates[kind]:Clone();m.Name='EnemyLiveFixture_'..count
   if elite then m:ScaleTo(1.2);m:SetAttribute('Elite',true)end
   m:PivotTo(CFrame.new((count-1)%6*6-15,3,-12-math.floor((count-1)/6)*9));m.Parent=world;table.insert(models,m)
   local deadline=os.clock()+10;repeat task.wait()until m:GetAttribute('SkeletonMeshStatus')or os.clock()>deadline
   assert(m:GetAttribute('SkeletonMeshStatus')=='Ready',kind..' live watcher attaches')
   local family=m:GetAttribute('EnemyFamily')
   if family=='slime'or family=='crystal'then
    assert(workspace.CurrentCamera==camera and(camera.CFrame.Position-m.PrimaryPart.Position).Magnitude<110,kind..' fixture camera remains inside live pose range')
    local visual=m:FindFirstChild(m:GetAttribute('VisualProfile'));assert(visual,kind..' native live visual')
    assert(m:GetAttribute('EnemyVisualFamily')==family,kind..' watcher routes family')
    m:SetAttribute('Preparing',true);task.wait(.15);assert(m:GetAttribute('SkeletonMotion')=='prepare',kind..' watcher reads preparing')
    m:SetAttribute('Frozen',true);task.wait(.1);local held={}
    for _,p in ipairs(visual:GetDescendants())do if p:IsA('BasePart')then held[p]={frame=p.CFrame,size=p.Size}end end
    m:SetAttribute('Preparing',false);task.wait(.15)
    for p,state in pairs(held)do assert((p.Position-state.frame.Position).Magnitude<.001 and (p.Size-state.size).Magnitude<.001 and p.CFrame.Rotation==state.frame.Rotation,kind..' live freeze holds pose through state transition')end
    m:SetAttribute('Frozen',false);m:SetAttribute('AttackSequence',1);task.wait(.1);assert(m:GetAttribute('SkeletonMotion')=='attack',kind..' watcher reads attack sequence')
   elseif kind~='charger'then
    assert(m.KayKitSkeleton.HasSkinnedMesh,kind..' native live mesh')
    local expected=kind=='stalker'and(elite and 2 or 0)or equipment[kind]
    assert(m:GetAttribute('EquipmentCount')==expected,kind..' correct live equipment')
   else assert(m:FindFirstChild('AshHound'),'Hound live visual')end
  end
 end
 return {liveWatcher=true,simultaneousModels=count,normal=12,elite=12,nativeFamilies=true,freeze=true,equipment=true}
end,debug.traceback)
-- Finally: restore camera and connections before checking model cleanup, on success
-- and on environment/renderer/assertion failures alike.
renderConnection:Disconnect();heartbeatConnection:Disconnect()
local cleanupOK,cleanupError=xpcall(function()
 camera.CameraType=savedCamera.type;camera.CameraSubject=savedCamera.subject
 camera.CFrame=savedCamera.frame;camera.Focus=savedCamera.focus;camera.FieldOfView=savedCamera.fov
 workspace.CurrentCamera=camera
 for _,m in ipairs(models)do m:Destroy()end
 task.wait(.1)
 for _,m in ipairs(world:GetChildren())do assert(not m.Name:match('^EnemyLiveFixture_'),'Live fixture cleanup')end
end,debug.traceback)
if not ok then error(result)end;if not cleanupOK then error(cleanupError)end;return result
