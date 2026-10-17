-- Studio effect gallery. Uses a local world stage so particles, trails and lights render.
return function(deps)
 local Run=game:GetService('RunService');if not Run:IsStudio()then return end
 local UIS=game:GetService('UserInputService');local GuiService=game:GetService('GuiService')
 local player,net,input,hud=deps.player,deps.net,deps.input,deps.hud
 local theme=require(script.Parent.Parent.Theme);local make,label,round=theme.Make,theme.Label,theme.Round;local palette=theme.Palette
 local spells={
  {id='lightRing',name='성운 광륜',note='빛나는 초승달 부메랑 · 곡선 왕복 관통'},
  {id='basic',name='기본 공격 · 별빛 마법탄',note='작은 빛의 탄환 · 누르고 연속 발사',common=true},
  {id='meteor',name='메테오',note='천천히 낙하하는 대형 운석과 충돌 폭발'},
  {id='skyLances',name='천공의 창',note='상공의 마법진에서 차례로 내려오는 다섯 마법 창'},
  {id='blades',name='비전 결정',note='등 뒤의 다섯 결정 · 개별 발사 · 재충전'},
  {id='frost',name='서리 폭발',note='냉기 응축 · 충격파 · 얼음 결정'},
  {id='missile',name='추적 마탄',note='강한 적 하나를 노리는 단일 대상 추적탄'},
  {id='ward',name='수호 결계',note='결계 생성 · 타격 · 보호막 파괴'},
  {id='fire',name='화염탄 [Q]',note='정면으로 발사하는 불꽃 탄환 · 적중 범위 피해',common=true},
  {id='ice',name='빙결 얼음창',note='정면 마법진 · 얼음창 · 빙결'},
  {id='lightning',name='연쇄 번개',note='하늘에서 내려꽂히는 연쇄 번개'},
  {id='thunder',name='뇌창 [Q]',note='정면으로 쏘아 보내는 관통 번개 창',common=true},
  {id='aetherLance',name='성운창 [Q]',note='푸른 아지랑이가 모여 가느다란 창으로 발사',common=true},
  {id='iceRush',name='빙하 쇄도 [Q]',note='땅에서 차례로 솟는 얼음 결정 · 빙결과 섬광',common=true},
  {id='golem',name='골렘 대지 강타',note='현재 게임과 같은 5단계 최대 연출',common=true},
  {id='dash',name='대시',note='이동 궤적과 잔상',common=true},
 }
 local gui=make('ScreenGui',player:WaitForChild('PlayerGui'),{Name='SkillPreview',ResetOnSpawn=false,DisplayOrder=90,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
 local launcher=make('Frame',gui,{Name='Launcher',Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
 local button=make('TextButton',launcher,{Name='SkillPreviewButton',Size=UDim2.fromOffset(166,32),Position=UDim2.fromOffset(174,8),Text='스킬 미리보기 [P]',Font=Enum.Font.GothamBold,TextSize=13,BackgroundColor3=palette.card,TextColor3=palette.gold});round(button,8)
 local overlay=make('Frame',gui,{Name='Overlay',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false})
 local header=make('Frame',overlay,{Name='Header',Size=UDim2.new(1,-24,0,60),Position=UDim2.fromOffset(12,8),BackgroundColor3=palette.bg,BackgroundTransparency=.04});round(header,10)
 local title=label(header,'스킬 미리보기',UDim2.new(1,-120,0,26),UDim2.fromOffset(14,5),Enum.Font.GothamBold,palette.gold);title.TextSize=18;title.TextXAlignment=Enum.TextXAlignment.Left
 local hint=label(header,'연출만 재생 · 전투 일시 정지 · 드래그 회전 / 휠 확대 · 패드 오른쪽 스틱 회전',UDim2.new(1,-120,0,19),UDim2.fromOffset(14,34),nil,palette.muted);hint.TextSize=11;hint.TextXAlignment=Enum.TextXAlignment.Left
 local close=make('TextButton',header,{Name='Close',Size=UDim2.fromOffset(78,34),Position=UDim2.new(1,-90,0,12),BackgroundColor3=palette.card,TextColor3=palette.text,Text='닫기',Font=Enum.Font.GothamBold,TextSize=13});round(close,8)
 local list=make('ScrollingFrame',overlay,{Name='Spells',Size=UDim2.new(0,200,1,-158),Position=UDim2.fromOffset(12,78),BackgroundColor3=palette.bg,BackgroundTransparency=.06,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,BorderSizePixel=0});round(list,8)
 make('UIListLayout',list,{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
 make('UIPadding',list,{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,8)})
 local surface=make('Frame',overlay,{Name='StageInput',Size=UDim2.new(1,-236,1,-160),Position=UDim2.fromOffset(224,78),BackgroundTransparency=1,Active=true})
 local controlsBar=make('Frame',overlay,{Name='Controls',Size=UDim2.new(1,-236,0,42),Position=UDim2.new(0,224,1,-54),BackgroundColor3=palette.bg,BackgroundTransparency=.04});round(controlsBar,10)
 local clockLabel=label(overlay,'',UDim2.new(1,-236,0,20),UDim2.new(0,224,1,-79),nil,palette.text);clockLabel.TextSize=12
 local controls={}
 for i,item in ipairs({{'Replay','다시 재생'},{'Loop','반복 켬'},{'Level','단계 1'},{'ResetView','시점 초기화'},{'Close','닫기'}})do
  local b=make('TextButton',controlsBar,{Name=item[1],Text=item[2],Size=UDim2.new(.2,-10,1,-12),Position=UDim2.new((i-1)*.2,5,0,6),BackgroundColor3=palette.card,TextColor3=palette.text,Font=Enum.Font.GothamBold,TextSize=12});round(b,7);controls[item[1]]=b
 end
 local opened,lastLobby,loop,playing=false,false,true,true
 local selected,levelIndex=spells[1],1;local levels={1,3,5}
 local yaw,pitch,distance=0,.65,82
 local scene,oldCamera,oldSelection,playerControls
 local dragging,touch,lastPosition=false,nil,nil;local stick=Vector2.zero
 local spellButtons={};local setOpen
 local function fit()
  yaw=0;pitch=(selected.id=='meteor' or selected.id=='skyLances') and .48 or .65;distance=(selected.id=='meteor' or selected.id=='skyLances') and 140 or 84
 end
 local function refresh()
  title.Text='스킬 미리보기 · '..selected.name..' · '..selected.note
  controls.Loop.Text=loop and '반복 켬'or'반복 끔'
  controls.Level.Text=selected.common and(selected.id=='golem' and '단계 5 · 최대 연출'or'단계 공통')or('단계 '..levels[levelIndex])
  for id,b in pairs(spellButtons)do b.BackgroundColor3=id==selected.id and palette.mint or palette.card;b.TextColor3=id==selected.id and palette.bg or palette.text end
  gui:SetAttribute('SelectedSpell',selected.id);gui:SetAttribute('Level',selected.id=='golem' and 5 or levels[levelIndex]);gui:SetAttribute('Loop',loop)
 end
 local function replay()
  if not scene then return end
  scene.Play(selected.id,selected.id=='golem' and 5 or levels[levelIndex]);playing=true;clockLabel.Text='재생 중…';gui:SetAttribute('PlaybackTime',0);refresh()
 end
 local function selectSpell(item)
  selected=item;fit();replay()
 end
 for i,item in ipairs(spells)do
  local b=make('TextButton',list,{Name='Spell_'..item.id,Size=UDim2.new(1,-2,0,34),LayoutOrder=i,Text=item.name,BackgroundColor3=palette.card,TextColor3=palette.text,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=true});round(b,7);spellButtons[item.id]=b
  b.Activated:Connect(function()selectSpell(item)end)
 end
 setOpen=function(value)
  if opened==value then return end
  if value and deps.dragon then deps.dragon.Close()end
  opened=value;overlay.Visible=value;button.Visible=not value;gui:SetAttribute('Open',value)
  input.SetSuspended(value or lastLobby);net.Action:FireServer('previewSkills',value)
  local lobby=player.PlayerGui:FindFirstChild('SummonerLobbyUI')
  if value then
   oldSelection=GuiService.SelectedObject
   if deps.camera then deps.camera.Suspend(true)end
   local camera=workspace.CurrentCamera;oldCamera={type=camera.CameraType,subject=camera.CameraSubject,frame=camera.CFrame,focus=camera.Focus,fov=camera.FieldOfView}
   hud.Enabled=false;if lobby then lobby.Enabled=false end
   if deps.dragon then deps.dragon.Gui.Enabled=false end
   local module=player.PlayerScripts:FindFirstChild('PlayerModule')
   if module then local ok,result=pcall(function()return require(module):GetControls()end);if ok then playerControls=result;playerControls:Disable()end end
   if not scene then scene=require(script.Parent.Parent.combat.PreviewScene)({player=player,net=net,gui=gui})end
   fit();replay()
   if UIS.GamepadEnabled then GuiService.SelectedObject=spellButtons[selected.id]end
  else
   dragging=false;touch=nil;stick=Vector2.zero;if scene then scene.Clear()end
   hud.Enabled=not lastLobby;if lobby then lobby.Enabled=lastLobby end
   if deps.dragon then deps.dragon.Gui.Enabled=true end
   if playerControls then playerControls:Enable()end
   local camera=workspace.CurrentCamera
   if deps.camera then deps.camera.Restore(oldCamera)
   elseif oldCamera then
    camera.FieldOfView=oldCamera.fov;camera.CameraSubject=oldCamera.subject and oldCamera.subject.Parent and oldCamera.subject or(player.Character and player.Character:FindFirstChildOfClass('Humanoid'));camera.CameraType=oldCamera.type;camera.CFrame=oldCamera.frame
   end
   GuiService.SelectedObject=oldSelection and oldSelection.Parent and oldSelection or nil
  end
 end
 button.Activated:Connect(function()setOpen(true)end);close.Activated:Connect(function()setOpen(false)end)
 controls.Close.Activated:Connect(function()setOpen(false)end)
 controls.Replay.Activated:Connect(replay)
 controls.Loop.Activated:Connect(function()loop=not loop;if loop and not playing then replay()end;refresh()end)
 controls.Level.Activated:Connect(function()if selected.common then return end;levelIndex=levelIndex%#levels+1;replay()end)
 controls.ResetView.Activated:Connect(fit)
 surface.InputBegan:Connect(function(key)
  if key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.MouseButton2 or key.UserInputType==Enum.UserInputType.Touch then dragging=true;lastPosition=key.Position;if key.UserInputType==Enum.UserInputType.Touch then touch=key end end
 end)
 surface.InputChanged:Connect(function(key)if opened and key.UserInputType==Enum.UserInputType.MouseWheel then distance=math.clamp(distance*math.exp(-key.Position.Z*.13),24,220)end end)
 local keyConnection=UIS.InputBegan:Connect(function(key,processed)
  if key.KeyCode==Enum.KeyCode.P and(opened or not processed)and not UIS:GetFocusedTextBox()then setOpen(not opened)
  elseif opened then
   if key.KeyCode==Enum.KeyCode.ButtonB then setOpen(false)
   elseif key.KeyCode==Enum.KeyCode.ButtonL1 then distance=math.min(220,distance*1.15)
   elseif key.KeyCode==Enum.KeyCode.ButtonR1 then distance=math.max(24,distance/1.15)end
  end
 end)
 local changedConnection=UIS.InputChanged:Connect(function(key)
  if not opened then return end
  if key.KeyCode==Enum.KeyCode.Thumbstick2 then stick=Vector2.new(key.Position.X,key.Position.Y)end
  if dragging and(key.UserInputType==Enum.UserInputType.MouseMovement or key==touch)then local delta=key.Position-lastPosition;lastPosition=key.Position;yaw-=delta.X*.008;pitch=math.clamp(pitch+delta.Y*.006,.12,1.35)end
 end)
 local endedConnection=UIS.InputEnded:Connect(function(key)if key==touch or key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.MouseButton2 then dragging=false;touch=nil end end)
 local stateConnection=net.State.OnClientEvent:Connect(function(s)
  lastLobby=s.lobby==true
  if not opened then
   local lobby=player.PlayerGui:FindFirstChild('SummonerLobbyUI')
   local panel=lobby and lobby:FindFirstChild('Frame') and lobby.Frame:FindFirstChild('Panel')
   if lastLobby and panel then button.Parent=panel;button.Position=UDim2.fromOffset(480,642);button.Size=UDim2.fromOffset(166,48)
   else button.Parent=launcher;button.Position=UDim2.fromOffset(12,64);button.Size=UDim2.fromOffset(166,32)end
  end
 end)
 local infoClock=0
 local renderConnection=Run.RenderStepped:Connect(function(dt)
  local dragonOpen=deps.dragon and deps.dragon.Gui:GetAttribute('Open')
  button.Visible=not opened and not dragonOpen
  if not opened or not scene then return end
  yaw-=stick.X*dt*2;pitch=math.clamp(pitch-stick.Y*dt*1.2,.12,1.35)
  local focus=scene.Origin+Vector3.new(0,(selected.id=='meteor' or selected.id=='skyLances') and 25 or 5,-5)
  local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=55
  local offset=Vector3.new(math.sin(yaw)*math.cos(pitch),math.sin(pitch),math.cos(yaw)*math.cos(pitch))*distance
  camera.CFrame=CFrame.lookAt(focus+offset,focus)
  if playing then
   local done,time,duration=scene.Step(math.min(dt,.1));infoClock+=dt
   if infoClock>.15 then infoClock=0;clockLabel.Text=string.format('%.1f / %.1f초  ·  피해 없이 연출만 확인',time,duration);gui:SetAttribute('PlaybackTime',time)end
   if done then if loop then replay()else playing=false;clockLabel.Text='재생 완료 · 다시 재생을 누르세요'end end
  end
 end)
 gui:SetAttribute('Open',false);refresh()
 gui.Destroying:Connect(function()
  if opened then setOpen(false)end
  keyConnection:Disconnect();changedConnection:Disconnect();endedConnection:Disconnect();stateConnection:Disconnect();renderConnection:Disconnect()
  if scene then scene.Destroy();scene=nil end
  button:Destroy()
 end)
 return {Gui=gui,Open=function()setOpen(true)end,Close=function()setOpen(false)end}
end
