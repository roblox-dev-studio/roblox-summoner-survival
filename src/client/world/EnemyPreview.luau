-- Studio-only enemy catalog with a private camera/WorldModel; never moves live enemies.
return function(deps)
 local Run=game:GetService('RunService');if not Run:IsStudio()then return end
 local UIS=game:GetService('UserInputService');local GuiService=game:GetService('GuiService')
 local player,net,input,hud=deps.player,deps.net,deps.input,deps.hud
 local theme=require(script.Parent.Parent.Theme);local make,label,round=theme.Make,theme.Label,theme.Round;local colors=theme.Palette
 local gui=make('ScreenGui',player:WaitForChild('PlayerGui'),{Name='EnemyPreview',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=95,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
 local button=make('TextButton',gui,{Name='OpenButton',Text='몹 미리보기 [N]',Size=UDim2.fromOffset(166,32),Position=UDim2.fromOffset(186,64),BackgroundColor3=colors.card,TextColor3=colors.mint,Font=Enum.Font.GothamBold,TextSize=13});round(button,8)
 local overlay=make('Frame',gui,{Name='Overlay',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(7,13,23),BackgroundTransparency=0,Visible=false,Active=true})
 local title=label(overlay,'몹 미리보기',UDim2.new(1,-150,0,32),UDim2.fromOffset(20,14),Enum.Font.GothamBold,colors.gold);title.TextSize=21;title.TextXAlignment=Enum.TextXAlignment.Left
 local description=label(overlay,'외형은 실전 모델 · 행동은 피해 없는 시연 · 드래그 회전 / 휠 확대',UDim2.new(1,-40,0,42),UDim2.fromOffset(20,51),nil,colors.muted);description.TextSize=13;description.TextXAlignment=Enum.TextXAlignment.Left;description.TextWrapped=true
 local close=make('TextButton',overlay,{Name='Close',Size=UDim2.fromOffset(92,34),Position=UDim2.new(1,-112,0,14),Text='닫기 [N]',BackgroundColor3=colors.card,TextColor3=colors.text,Font=Enum.Font.GothamBold,TextSize=13});round(close,8)
 local familyFilter=make('TextButton',overlay,{Name='FamilyFilter',Text='종족: 전체',Size=UDim2.fromOffset(194,32),Position=UDim2.fromOffset(16,100),BackgroundColor3=colors.card,TextColor3=colors.mint,Font=Enum.Font.GothamBold,TextSize=13});round(familyFilter,8)
 local list=make('ScrollingFrame',overlay,{Name='Enemies',Size=UDim2.new(0,194,1,-158),Position=UDim2.fromOffset(16,142),BackgroundTransparency=1,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,BorderSizePixel=0})
 make('UIListLayout',list,{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})
 local view=make('ViewportFrame',overlay,{Name='Viewport',Size=UDim2.new(1,-238,1,-174),Position=UDim2.fromOffset(222,100),BackgroundColor3=Color3.fromRGB(22,31,45),Ambient=Color3.fromRGB(185,192,210),LightColor=Color3.fromRGB(255,237,215),LightDirection=Vector3.new(-.6,-1,-1),Active=true});round(view,12)
 local camera=make('Camera',view,{Name='EnemyCamera',FieldOfView=42});view.CurrentCamera=camera
 local world=make('WorldModel',view,{Name='PreviewWorld'})
 local scene=require(script.Parent.EnemyPreviewScene)({world=world})
 local bar=make('Frame',overlay,{Name='Controls',Size=UDim2.new(1,-238,0,44),Position=UDim2.new(0,222,1,-60),BackgroundTransparency=1})
 local actions={};for i,item in ipairs({{'Mode','행동: 대기'},{'Elite','일반 몹'},{'Pause','일시정지'},{'Reset','시점 초기화'}})do
  local b=make('TextButton',bar,{Name=item[1],Text=item[2],Size=UDim2.new(.25,-8,1,0),Position=UDim2.new((i-1)*.25,0,0,0),BackgroundColor3=colors.card,TextColor3=colors.text,Font=Enum.Font.GothamBold,TextSize=13});round(b,8);actions[item[1]]=b
 end
 local opened,lastLobby,elite,playing=false,false,false,true
 local selected,templates=nil,{};local buttons={};local familyHeaders={};local familyIndex=1
 local families={'all','undead','beast','slime','crystal'};local familyNames={all='전체',undead='망자',beast='야수',slime='슬라임',crystal='결정체'}
 local modes={'idle','walk','attack'};local names={'대기','이동','공격 시연'};local modeIndex=1
 local yaw,pitch,distance=-.35,.3,30;local dragging,touch,lastPosition=false,nil,nil;local stick=Vector2.zero
 local oldSelection,controls,oldCamera
 local function replay()
  if selected then scene.Play(selected,elite,modes[modeIndex]);title.Text='몹 미리보기 · '..selected:GetAttribute('DisplayName')..(elite and ' · 정예'or'')
   description.Text=(selected:GetAttribute('FamilyName')or familyNames[selected:GetAttribute('EnemyFamily')]or'종족')..' · '..selected:GetAttribute('Role')..'  |  '..selected:GetAttribute('Description')..'\n외형은 실전 모델 · 행동은 피해 없는 시연 · 드래그 회전 / 휠 확대' end
  actions.Mode.Text='행동: '..names[modeIndex];actions.Elite.Text=elite and '정예 · 크기 1.2배'or'일반 몹';actions.Pause.Text=playing and '일시정지'or'재생'
  for id,b in pairs(buttons)do b.BackgroundColor3=selected and selected.Name==id and colors.mint or colors.card;b.TextColor3=selected and selected.Name==id and colors.bg or colors.text end
  gui:SetAttribute('SelectedEnemy',selected and selected.Name);gui:SetAttribute('Elite',elite);gui:SetAttribute('Mode',modes[modeIndex])
 end
 local function setOpen(value)
  if opened==value then return end
  if value and deps.beforeOpen then deps.beforeOpen()end
  opened=value;overlay.Visible=value;gui:SetAttribute('Open',value);input.SetSuspended(value or lastLobby);net.Action:FireServer('previewSkills',value)
  if value then
   oldSelection=GuiService.SelectedObject;local c=workspace.CurrentCamera;oldCamera={type=c.CameraType,subject=c.CameraSubject,frame=c.CFrame,focus=c.Focus,fov=c.FieldOfView}
   if deps.camera then deps.camera.Suspend(true)end
   local module=player.PlayerScripts:FindFirstChild('PlayerModule');if module then local ok,result=pcall(function()return require(module):GetControls()end);if ok then controls=result;controls:Disable()end end
   hud.Enabled=false;local lobby=player.PlayerGui:FindFirstChild('SummonerLobbyUI');if lobby then lobby.Enabled=false end
   replay();if UIS.GamepadEnabled and selected then GuiService.SelectedObject=buttons[selected.Name]end
  else
   dragging=false;touch=nil;stick=Vector2.zero;scene.Clear();if controls then controls:Enable()end
   if deps.camera then deps.camera.Restore(oldCamera)end
   hud.Enabled=not lastLobby;local lobby=player.PlayerGui:FindFirstChild('SummonerLobbyUI');if lobby then lobby.Enabled=lastLobby end
   GuiService.SelectedObject=oldSelection and oldSelection.Parent and oldSelection or nil
  end
 end
 local folder=game.ReplicatedStorage:WaitForChild('EnemyPreviewModels',10)
 if folder then
  templates=folder:GetChildren();table.sort(templates,function(a,b)return a:GetAttribute('Order')<b:GetAttribute('Order')end)
  for i,model in ipairs(templates)do
   local family=model:GetAttribute('EnemyFamily')or(model.Name=='charger'and'beast'or'undead')
   if not familyHeaders[family]then
    local heading=label(list,model:GetAttribute('FamilyName')or familyNames[family]or family,UDim2.new(1,-6,0,24),UDim2.new(),Enum.Font.GothamBold,colors.muted);heading.Name='Family_'..family;heading.LayoutOrder=i*2-1;heading.TextSize=12;heading.TextXAlignment=Enum.TextXAlignment.Left;familyHeaders[family]=heading
   end
   local b=make('TextButton',list,{Name='Enemy_'..model.Name,Text=model:GetAttribute('DisplayName')..'\n'..model:GetAttribute('Role'),Size=UDim2.new(1,-6,0,64),LayoutOrder=i*2,BackgroundColor3=colors.card,TextColor3=colors.text,Font=Enum.Font.GothamBold,TextSize=13});round(b,9);buttons[model.Name]=b
   b.Activated:Connect(function()selected=model;playing=true;replay()end)
  end
  selected=templates[1]
 else description.Text='몹 모델을 준비하지 못했어요. Studio를 다시 재생해 주세요.'end
 local function filterFamilies()
  local family=families[familyIndex];local first;local count=0
  for _,model in ipairs(templates)do
   local group=model:GetAttribute('EnemyFamily')or(model.Name=='charger'and'beast'or'undead');local visible=family=='all'or group==family
   buttons[model.Name].Visible=visible;if visible then first=first or model;count+=1 end
  end
  for group,heading in pairs(familyHeaders)do heading.Visible=family=='all'or group==family end
  if selected and not buttons[selected.Name].Visible then selected=first;replay()end
  familyFilter.Text='종족: '..familyNames[family]..' · '..count;gui:SetAttribute('SelectedFamily',family);list.CanvasPosition=Vector2.zero
 end
 familyFilter.Activated:Connect(function()familyIndex=familyIndex%#families+1;filterFamilies()end);filterFamilies()
 button.Activated:Connect(function()setOpen(true)end);close.Activated:Connect(function()setOpen(false)end)
 actions.Mode.Activated:Connect(function()modeIndex=modeIndex%#modes+1;playing=true;replay()end)
 actions.Elite.Activated:Connect(function()elite=not elite;replay()end)
 actions.Pause.Activated:Connect(function()playing=not playing;actions.Pause.Text=playing and '일시정지'or'재생'end)
 actions.Reset.Activated:Connect(function()yaw=-.35;pitch=.3;distance=30 end)
 view.InputBegan:Connect(function(key)if key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.MouseButton2 or key.UserInputType==Enum.UserInputType.Touch then dragging=true;lastPosition=key.Position;touch=key.UserInputType==Enum.UserInputType.Touch and key or nil end end)
 view.InputChanged:Connect(function(key)if opened and key.UserInputType==Enum.UserInputType.MouseWheel then distance=math.clamp(distance*math.exp(-key.Position.Z*.13),12,60)end end)
 local keyConnection=UIS.InputBegan:Connect(function(key,processed)
  if key.KeyCode==Enum.KeyCode.N and(opened or not processed)and not UIS:GetFocusedTextBox()then setOpen(not opened)
  elseif opened and key.KeyCode==Enum.KeyCode.ButtonB then setOpen(false)
  elseif opened and key.KeyCode==Enum.KeyCode.ButtonL1 then distance=math.min(60,distance*1.15)
  elseif opened and key.KeyCode==Enum.KeyCode.ButtonR1 then distance=math.max(12,distance/1.15)end
 end)
 local changedConnection=UIS.InputChanged:Connect(function(key)
  if not opened then return end
  if key.KeyCode==Enum.KeyCode.Thumbstick2 then stick=Vector2.new(key.Position.X,key.Position.Y)end
  if dragging and(key.UserInputType==Enum.UserInputType.MouseMovement or key==touch)then local d=key.Position-lastPosition;lastPosition=key.Position;yaw-=d.X*.008;pitch=math.clamp(pitch+d.Y*.006,-.1,1.2)end
 end)
 local endedConnection=UIS.InputEnded:Connect(function(key)if key==touch or key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.MouseButton2 then dragging=false;touch=nil end end)
 local stateConnection=net.State.OnClientEvent:Connect(function(s)
  lastLobby=s.lobby==true
  local lobby=player.PlayerGui:FindFirstChild('SummonerLobbyUI');local panel=lobby and lobby:FindFirstChild('Frame')and lobby.Frame:FindFirstChild('Panel')
  if lastLobby and panel then button.Parent=panel;button.Position=UDim2.fromOffset(304,642);button.Size=UDim2.fromOffset(166,48)
  else button.Parent=gui;button.Position=UDim2.fromOffset(186,64);button.Size=UDim2.fromOffset(166,32)end
  if opened then hud.Enabled=false;if lobby then lobby.Enabled=false end end
 end)
 local render=Run.RenderStepped:Connect(function(dt)
  local other=false;for _,name in ipairs({'DragonPreview','SkillPreview'})do local g=player.PlayerGui:FindFirstChild(name);if g and g:GetAttribute('Open')then other=true end end
  button.Visible=not opened and not other
  if not opened then return end
  yaw-=stick.X*dt*2;pitch=math.clamp(pitch-stick.Y*dt*1.2,-.1,1.2)
  local focus=Vector3.new(0,2,0);local radius=distance*math.max(1,1.3/(view.AbsoluteSize.X/math.max(1,view.AbsoluteSize.Y)))
  camera.CFrame=CFrame.lookAt(focus+Vector3.new(math.sin(yaw)*math.cos(pitch),math.sin(pitch),-math.cos(yaw)*math.cos(pitch))*radius,focus)
  if playing then scene.Step(math.min(dt,.1))end
 end)
 gui:SetAttribute('Open',false);replay()
 gui.Destroying:Connect(function()if opened then setOpen(false)end;keyConnection:Disconnect();changedConnection:Disconnect();endedConnection:Disconnect();stateConnection:Disconnect();render:Disconnect();scene.Destroy();button:Destroy()end)
 return {Gui=gui,Open=function()setOpen(true)end,Close=function()setOpen(false)end}
end
