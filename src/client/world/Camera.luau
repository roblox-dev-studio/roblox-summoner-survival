-- A short camera reset at spawn/entry, then Roblox's standard free orbit takes over.
return function(deps)
 local Run=game:GetService('RunService')
 local player=deps.player
 local binding='SummonerCameraReset_'..player.UserId
 local suspended=false;local seeding=false
 local function cancel()
  Run:UnbindFromRenderStep(binding)
  if seeding then
   seeding=false;player.CameraMinZoomDistance=8;player.CameraMaxZoomDistance=85
   if workspace.CurrentCamera then workspace.CurrentCamera.CameraType=Enum.CameraType.Custom end
  end
 end
 local function seed(offset,fov)
  cancel();if suspended then return end
  local c=player.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local root=c and c:FindFirstChild('HumanoidRootPart')
  if not h or not root then return end
  if not offset then
   local back=Vector3.new(-root.CFrame.LookVector.X,0,-root.CFrame.LookVector.Z)
   if back.Magnitude<.1 then back=Vector3.zAxis else back=back.Unit end
   offset=back*24+Vector3.new(0,14,0)
  end
  local distance=math.clamp(offset.Magnitude,8,85);offset=offset.Unit*distance
  player.CameraMode=Enum.CameraMode.Classic;player.CameraMaxZoomDistance=distance;player.CameraMinZoomDistance=distance
  local camera=workspace.CurrentCamera;camera.CameraSubject=h;camera.FieldOfView=fov or 70;camera.CameraType=Enum.CameraType.Scriptable
  seeding=true;local elapsed,frames,released=0,0,0
  Run:BindToRenderStep(binding,Enum.RenderPriority.Camera.Value+1,function(dt)
   if suspended or player.Character~=c or not root.Parent then cancel();return end
   elapsed+=dt;frames+=1
   local focus=root.Position+Vector3.new(0,1.5,0)
   camera.Focus=CFrame.new(focus);camera.CFrame=CFrame.lookAt(focus+offset,focus)
   if elapsed>=.18 and frames>=4 then
    camera.CameraType=Enum.CameraType.Custom;released+=1
    if released>=3 then cancel()end
   else camera.CameraType=Enum.CameraType.Scriptable end
  end)
 end
 local function bind(character)
  character:WaitForChild('Humanoid');character:WaitForChild('HumanoidRootPart')
  if player.Character==character and not suspended then seed()end
 end
 player.CharacterAdded:Connect(function(c)task.spawn(bind,c)end)
 if player.Character then task.spawn(bind,player.Character)end
 return {
  Reset=function()seed()end,
  Suspend=function(value)suspended=value;if value then cancel()end end,
  Restore=function(snapshot)
   suspended=false
   local c=player.Character;local root=c and c:FindFirstChild('HumanoidRootPart')
   if snapshot and snapshot.type==Enum.CameraType.Custom and snapshot.focus and root and (snapshot.focus.Position-root.Position).Magnitude<12 then
    local offset=snapshot.frame.Position-snapshot.focus.Position
    if offset.Magnitude>=8 and offset.Magnitude<=85 then seed(offset,snapshot.fov);return end
   end
   seed()
  end,
 }
end
