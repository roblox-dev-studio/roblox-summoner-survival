-- Studio-only model viewer. Own WorldModel/camera; it never moves the live dragon.
return function(deps)
 local Run=game:GetService('RunService')
 if not Run:IsStudio()then return end
 local UIS=game:GetService('UserInputService')
 local player,net,input,hud=deps.player,deps.net,deps.input,deps.hud
 local theme=require(script.Parent.Parent.Theme)
 local make,label,round=theme.Make,theme.Label,theme.Round
 local colors=theme.Palette
 local renderer=require(script.Parent.DragonMesh)
 local gui=make('ScreenGui',player:WaitForChild('PlayerGui'),{Name='DragonPreview',ResetOnSpawn=false,DisplayOrder=80,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
 local button=make('TextButton',gui,{Name='OpenButton',Text='드래곤 보기 [V]',Size=UDim2.fromOffset(150,32),Position=UDim2.fromOffset(12,8),BackgroundColor3=colors.card,TextColor3=colors.mint,Font=Enum.Font.GothamBold,TextSize=13});round(button,8)
 local overlay=make('Frame',gui,{Name='Overlay',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(5,10,16),BackgroundTransparency=.05,Visible=false,Active=true})
 local panel=make('Frame',overlay,{Size=UDim2.fromScale(.96,.94),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=colors.bg});round(panel,14)
 make('UISizeConstraint',panel,{MaxSize=Vector2.new(1100,820)})
 local title=label(panel,'흑염룡 · 아그니스',UDim2.new(1,-32,0,28),UDim2.fromOffset(16,10),Enum.Font.GothamBold,colors.gold);title.TextSize=19;title.TextXAlignment=Enum.TextXAlignment.Left
 local hint=label(panel,'드래그 회전 · 휠 확대/축소 · 전투 일시 정지',UDim2.new(1,-32,0,20),UDim2.fromOffset(16,41),nil,colors.muted);hint.TextSize=11;hint.TextXAlignment=Enum.TextXAlignment.Left

 local view=make('ViewportFrame',panel,{Name='Viewport',Size=UDim2.new(1,-24,1,-150),Position=UDim2.fromOffset(12,68),BackgroundColor3=Color3.fromRGB(23,33,49),Ambient=Color3.fromRGB(205,215,235),LightColor=Color3.fromRGB(255,242,226),LightDirection=Vector3.new(.6,-.7,1),Active=true});round(view,10)
 local camera=make('Camera',view,{Name='PreviewCamera',FieldOfView=40});view.CurrentCamera=camera
 local world=make('WorldModel',view,{Name='PreviewWorld'})
 local loading=label(view,'드래곤을 불러오는 중…',UDim2.fromScale(1,1),UDim2.new(),nil,colors.muted);loading.TextSize=14
 local rig,creating,opened=nil,false,false
 local yaw,pitch,distance=-.35,.22,80
 local mode,elapsed,autoRotate,playing='fly',0,false,true
 local dragging,touch,lastPosition=false,nil,nil
 local controls,oldHudEnabled,oldSelection
 local poseButtons={};local utility={}
 local function cameraStep()
  local aspect=view.AbsoluteSize.X/math.max(1,view.AbsoluteSize.Y)
  local radius=distance*math.max(1,1.6/aspect)
  local focus=Vector3.new(0,12,7)
  local offset=Vector3.new(math.sin(yaw)*math.cos(pitch),math.sin(pitch),-math.cos(yaw)*math.cos(pitch))*radius
  camera.CFrame=CFrame.lookAt(focus+offset,focus)
 end
 local function refresh()
  for name,b in pairs(poseButtons)do b.BackgroundColor3=name==mode and colors.mint or colors.card;b.TextColor3=name==mode and colors.bg or colors.text end
  utility.Auto.Text=autoRotate and '자동회전 켬'or'자동회전 끔'
  utility.Pause.Text=playing and '일시정지'or'재생'
  gui:SetAttribute('ViewingMode',mode)
 end
 local function buildRig()
  if rig or creating then return end
  creating=true;loading.Visible=true;loading.Text='드래곤을 불러오는 중…'
  task.spawn(function()
   local model=Instance.new('Model');model.Name='PreviewDragon';model.Parent=world
   local ok,result=pcall(renderer.create,model);creating=false
   if not gui.Parent then if ok then renderer.destroy(result)end;model:Destroy();return end
   if not ok then model:Destroy();loading.Text='드래곤을 표시하지 못했어요. Mesh / Image APIs 설정을 확인해 주세요.';gui:SetAttribute('MeshStatus','Failed');warn('[DragonPreview] '..tostring(result));return end
   rig=result;loading.Visible=false;gui:SetAttribute('MeshStatus','Ready')
  end)
 end
 local function setOpen(value)
  if opened==value then return end
  if value and deps.beforeOpen then deps.beforeOpen()end
  opened=value;overlay.Visible=value;button.Visible=not value;gui:SetAttribute('Open',value)
  local lobbyGui=player.PlayerGui:FindFirstChild('SummonerLobbyUI')
  input.SetSuspended(value or(lobbyGui and lobbyGui:GetAttribute('InLobby')==true))
  net.Action:FireServer('previewDragon',value)
  if value then
   oldHudEnabled=hud.Enabled;hud.Enabled=false
   oldSelection=game:GetService('GuiService').SelectedObject
   local module=player.PlayerScripts:FindFirstChild('PlayerModule')
   if module then local ok,result=pcall(function()return require(module):GetControls()end);if ok then controls=result;controls:Disable()end end
   if UIS.GamepadEnabled then game:GetService('GuiService').SelectedObject=poseButtons.fly end
   cameraStep();buildRig()
  else
   dragging=false;touch=nil;hud.Enabled=oldHudEnabled~=false
   if controls then controls:Enable()end
   game:GetService('GuiService').SelectedObject=oldSelection
  end
 end
 for i,item in ipairs({{'idle','기본 모습'},{'walk','걷기'},{'fly','비행'},{'tail','꼬리 공격'}})do
  local b=make('TextButton',panel,{Name='Pose_'..item[1],Text=item[2],Size=UDim2.new(.25,-12,0,28),Position=UDim2.new((i-1)*.25,12-(i-1)*6,1,-72),BackgroundColor3=colors.card,TextColor3=colors.text,Font=Enum.Font.GothamBold,TextSize=12});round(b,7);poseButtons[item[1]]=b
  b.Activated:Connect(function()mode=item[1];elapsed=0;refresh()end)
 end
 for i,item in ipairs({{'Auto','자동회전 끔'},{'Front','정면'},{'Side','측면'},{'Pause','일시정지'},{'Close','닫기'}})do
  local b=make('TextButton',panel,{Name=item[1],Text=item[2],Size=UDim2.new(.2,-11,0,28),Position=UDim2.new((i-1)*.2,12-(i-1)*4.8,1,-38),BackgroundColor3=colors.card,TextColor3=colors.text,Font=Enum.Font.GothamMedium,TextSize=11});round(b,7);utility[item[1]]=b
 end
 utility.Auto.Activated:Connect(function()autoRotate=not autoRotate;refresh()end)
 utility.Front.Activated:Connect(function()yaw=0;pitch=.18;distance=80;cameraStep()end)
 utility.Side.Activated:Connect(function()yaw=math.pi/2;pitch=.22;distance=80;cameraStep()end)
 utility.Pause.Activated:Connect(function()playing=not playing;refresh()end)
 button.Activated:Connect(function()setOpen(true)end)
 utility.Close.Activated:Connect(function()setOpen(false)end)
 local keyConnection=UIS.InputBegan:Connect(function(key,processed)
  if key.KeyCode==Enum.KeyCode.V and(opened or not processed)and not UIS:GetFocusedTextBox()then setOpen(not opened)
  elseif opened and key.KeyCode==Enum.KeyCode.ButtonB then setOpen(false)end
 end)
 view.InputBegan:Connect(function(key)
  if key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.MouseButton2 or key.UserInputType==Enum.UserInputType.Touch then
   dragging=true;lastPosition=key.Position;if key.UserInputType==Enum.UserInputType.Touch then touch=key end
  end
 end)
 local changedConnection=UIS.InputChanged:Connect(function(key)
  if opened and dragging and(key.UserInputType==Enum.UserInputType.MouseMovement or key==touch)then
   local delta=key.Position-lastPosition;lastPosition=key.Position;yaw-=delta.X*.008;pitch=math.clamp(pitch+delta.Y*.006,-.15,1.15)
  end
 end)
 local endedConnection=UIS.InputEnded:Connect(function(key)
  if key==touch or key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.MouseButton2 then dragging=false;touch=nil end
 end)
 view.InputChanged:Connect(function(key)if opened and key.UserInputType==Enum.UserInputType.MouseWheel then distance=math.clamp(distance*math.exp(-key.Position.Z*.12),55,190)end end)
 gui:SetAttribute('Open',false)
 refresh();cameraStep()
 local renderClock=0
 local renderConnection=Run.RenderStepped:Connect(function(dt)
  if not opened then return end
  if autoRotate then yaw+=dt*.22 end
  cameraStep();renderClock+=dt;if renderClock<1/24 then return end
  local delta=renderClock;renderClock=0;if playing then elapsed+=math.min(delta,.1)end
  if not rig then return end
  local pose,progress,origin=mode,0,CFrame.identity
  if mode=='tail'then
   local cycle=elapsed%3.2
   if cycle<1 then pose='tailWindup';progress=math.clamp((cycle-.5)/.5,0,1);origin=CFrame.Angles(0,math.rad(18)*progress*progress*(3-2*progress),0)
   elseif cycle<2.35 then
    progress=(cycle-1)/1.35;local eased=progress^3*(progress*(progress*6-15)+10);origin=CFrame.Angles(0,math.rad(18)-(math.pi*2+math.rad(18))*eased,0)
   else pose='idle'end
  end
  renderer.pose(rig,origin,elapsed,pose,progress,elapsed)
 end)
 gui.Destroying:Connect(function()
  if opened then setOpen(false)end
  keyConnection:Disconnect();changedConnection:Disconnect();endedConnection:Disconnect();renderConnection:Disconnect()
  if rig then renderer.destroy(rig);rig=nil end
 end)
 return {Gui=gui,Open=function()setOpen(true)end,Close=function()setOpen(false)end}
end
