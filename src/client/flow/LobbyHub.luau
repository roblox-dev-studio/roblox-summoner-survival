-- Read-only sanctuary navigation. Purchases, rolls and score writes are not implemented here.
-- Existing loadout/start flow is delegated explicitly through onLoadout.
return function(deps)
 local player,net=deps.player,deps.net
 local playerGui=player:WaitForChild('PlayerGui')
 local UIS=game:GetService('UserInputService');local GuiService=game:GetService('GuiService');local Prompts=game:GetService('ProximityPromptService')
 local theme=require(script.Parent.Parent.Theme);local make,label,round,stroke=theme.Make,theme.Label,theme.Round,theme.Stroke;local colors=theme.Palette
 local gui=make('ScreenGui',playerGui,{Name='SummonerLobbyHub',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=35,Enabled=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
 local connections,worldConnections,menuConnections,promptStates={},{},{},{}
 local inLobby,opened,destroyed=false,nil,false;local scores={};local savedSelection;local viewportConnection
 local copy={shop={title='별빛 교역소',eyebrow='ACADEMY SHOP',accent=colors.gold,description='마법 도구와 장비를 만나는 학술원의 교역소입니다.',note='상점 준비 중',detail='지금은 진열 공간을 둘러볼 수 있어요.\n상품 구매와 재화 사용은 아직 열리지 않았습니다.'},
  gacha={title='별의 소환 제단',eyebrow='ASTRAL SUMMONING',accent=Color3.fromRGB(185,160,231),description='별의 힘이 모이는 소환 제단입니다.',note='가챠 준비 중',detail='소환 기능을 준비하고 있어요.\n현재는 추첨이나 보상 지급이 이루어지지 않습니다.'},
  ranking={title='최고 처치 기록관',eyebrow='ACADEMY RECORDS',accent=colors.mint,description='현재 서버에 접속한 플레이어의 이번 접속 최고 처치 수입니다.'}}
 local dock=make('Frame',gui,{Name='Navigation',Size=UDim2.fromOffset(700,100),Position=UDim2.new(.5,0,1,-20),AnchorPoint=Vector2.new(.5,1),BackgroundColor3=colors.bg,BackgroundTransparency=.08});round(dock,15);stroke(dock)
 local dockScale=make('UIScale',dock,{Scale=1})
 local welcome=label(dock,'별빛 학술원  ·  자유롭게 둘러보세요',UDim2.new(1,-28,0,22),UDim2.fromOffset(14,8),Enum.Font.GothamBold,colors.text);welcome.TextSize=14;welcome.TextXAlignment=Enum.TextXAlignment.Left
 local hint=label(dock,'WASD 이동  ·  구역 입구에서 E / 패드 X',UDim2.fromOffset(345,22),UDim2.new(1,-359,0,8),nil,colors.muted);hint.TextSize=12;hint.TextXAlignment=Enum.TextXAlignment.Right
 local buttons={}
 for i,item in ipairs({{'loadout','출전 준비'},{'shop','상점 · 준비 중'},{'gacha','가챠 · 준비 중'},{'ranking','최고 점수'}})do
  local b=make('TextButton',dock,{Name='Open_'..item[1],Size=UDim2.fromOffset(158,44),Position=UDim2.fromOffset(14+(i-1)*171,42),Text=item[2],Font=Enum.Font.GothamBold,TextSize=14,BackgroundColor3=i==1 and colors.mint or colors.card,TextColor3=i==1 and colors.bg or colors.text});round(b,9);buttons[item[1]]=b
 end
 local veil=make('Frame',gui,{Name='Veil',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(6,12,21),BackgroundTransparency=.25,Visible=false,Active=true})
 local panel=make('Frame',veil,{Name='Panel',Size=UDim2.fromOffset(720,510),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=colors.bg});round(panel,18);stroke(panel)
 local panelScale=make('UIScale',panel,{Scale=1})
 local eyebrow=label(panel,'',UDim2.fromOffset(580,22),UDim2.fromOffset(28,22),Enum.Font.GothamBold,colors.mint);eyebrow.TextSize=12;eyebrow.TextXAlignment=Enum.TextXAlignment.Left
 local heading=label(panel,'',UDim2.fromOffset(580,38),UDim2.fromOffset(28,49),Enum.Font.GothamBold,colors.text);heading.Name='Heading';heading.TextSize=27;heading.TextXAlignment=Enum.TextXAlignment.Left
 local description=label(panel,'',UDim2.fromOffset(664,44),UDim2.fromOffset(28,98),nil,colors.muted);description.TextSize=15;description.TextXAlignment=Enum.TextXAlignment.Left
 local close=make('TextButton',panel,{Name='Close',Size=UDim2.fromOffset(72,34),Position=UDim2.new(1,-100,0,26),Text='닫기',Font=Enum.Font.GothamBold,TextSize=14,BackgroundColor3=colors.card,TextColor3=colors.text});round(close,8)
 local notice=make('Frame',panel,{Name='ComingSoon',Size=UDim2.fromOffset(664,252),Position=UDim2.fromOffset(28,162),BackgroundColor3=colors.card});round(notice,13)
 local ornament=make('Frame',notice,{Size=UDim2.fromOffset(58,58),Position=UDim2.fromOffset(32,34),Rotation=45,BackgroundColor3=Color3.fromRGB(52,66,77)});round(ornament,9);stroke(ornament,colors.gold)
 local note=label(notice,'',UDim2.fromOffset(510,42),UDim2.fromOffset(120,35),Enum.Font.GothamBold,colors.gold);note.Name='Status';note.TextSize=24;note.TextXAlignment=Enum.TextXAlignment.Left
 local detail=label(notice,'',UDim2.fromOffset(590,108),UDim2.fromOffset(34,113),nil,colors.text);detail.Name='Description';detail.TextSize=18;detail.TextXAlignment=Enum.TextXAlignment.Left
 local records=make('ScrollingFrame',panel,{Name='Scores',Size=UDim2.fromOffset(664,252),Position=UDim2.fromOffset(28,162),BackgroundTransparency=1,ScrollBarThickness=4,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,BorderSizePixel=0,Visible=false})
 make('UIListLayout',records,{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder})
 local empty=label(panel,'아직 기록이 없어요.\n전투를 마치면 이번 접속의 최고 점수를 확인할 수 있습니다.',UDim2.fromOffset(620,160),UDim2.fromOffset(50,200),nil,colors.muted);empty.Name='EmptyScores';empty.TextSize=18;empty.Visible=false
 local footer=label(panel,'',UDim2.fromOffset(664,50),UDim2.fromOffset(28,435),nil,colors.muted);footer.Name='Scope';footer.TextSize=13;footer.TextXAlignment=Enum.TextXAlignment.Left
 local function connect(signal,callback)local connection=signal:Connect(callback);table.insert(connections,connection);return connection end
 local function resize()
  local camera=workspace.CurrentCamera;if not camera then return end;local size=camera.ViewportSize
  panelScale.Scale=math.max(.3,math.min(1,(size.X-24)/720,(size.Y-24)/510));dockScale.Scale=math.max(.3,math.min(1,(size.X-24)/700))
 end
 local function bindCamera()
  if viewportConnection then viewportConnection:Disconnect();viewportConnection=nil end
  local camera=workspace.CurrentCamera;if camera then viewportConnection=camera:GetPropertyChangedSignal('ViewportSize'):Connect(resize)end;resize()
 end
 local function menuBlocked()
  for _,name in ipairs({'SummonerLobbyUI','DragonPreview','SkillPreview','EnemyPreview'})do
   local other=playerGui:FindFirstChild(name)
   if other and(other:GetAttribute('Open')==true or other:GetAttribute('LoadoutOpen')==true)then return true end
  end
  return false
 end
 local function closePanel()
  if not opened then return end;opened=nil;veil.Visible=false;gui:SetAttribute('Open',false);gui:SetAttribute('Panel',nil)
  GuiService.SelectedObject=savedSelection and savedSelection.Parent and savedSelection or nil;savedSelection=nil
  if deps.onPanelChanged then deps.onPanelChanged(false)end
 end
 local function syncVisibility()
  if destroyed then return end
  local blocked=menuBlocked();if not inLobby or blocked then closePanel()end
  gui.Enabled=inLobby and not blocked;dock.Visible=opened==nil
  for prompt in pairs(promptStates)do if prompt.Parent then prompt.Enabled=inLobby and not blocked and opened==nil end end
 end
 local function renderScores()
  for _,child in ipairs(records:GetChildren())do if child:IsA('Frame')then child:Destroy()end end
  for i,score in ipairs(scores)do
   local row=make('Frame',records,{Name='Score_'..score.userId,Size=UDim2.new(1,-8,0,46),LayoutOrder=i,BackgroundColor3=score.userId==player.UserId and Color3.fromRGB(34,64,68)or colors.card});round(row,8)
   local rank=label(row,tostring(i),UDim2.fromOffset(42,46),UDim2.fromOffset(5,0),Enum.Font.GothamBold,colors.gold);rank.TextSize=16
   local name=label(row,score.name,UDim2.new(1,-190,1,0),UDim2.fromOffset(56,0),Enum.Font.GothamMedium,colors.text);name.Name='PlayerName';name.TextSize=15;name.TextXAlignment=Enum.TextXAlignment.Left
   local value=label(row,tostring(score.bestScore),UDim2.fromOffset(125,46),UDim2.new(1,-140,0,0),Enum.Font.GothamBold,colors.mint);value.Name='BestScore';value.TextSize=18;value.TextXAlignment=Enum.TextXAlignment.Right
  end
  empty.Visible=opened=='ranking'and #scores==0;gui:SetAttribute('ScoreCount',#scores)
 end
 local function open(action)
  if destroyed or not inLobby or menuBlocked()then return false end
  if action=='loadout'then
   closePanel();syncVisibility();if deps.onLoadout then deps.onLoadout()end;return deps.onLoadout~=nil
  end
  local content=copy[action];if not content then return false end
  local wasOpen=opened~=nil;if not wasOpen then savedSelection=GuiService.SelectedObject end
  opened=action;eyebrow.Text=content.eyebrow;eyebrow.TextColor3=content.accent;heading.Text=content.title;description.Text=content.description
  notice.Visible=action~='ranking';records.Visible=action=='ranking';empty.Visible=action=='ranking'and #scores==0
  if action=='ranking'then footer.Text='현재 서버 · 이번 접속 기록\n영구 저장과 전체 서버 랭킹은 준비 중입니다.';renderScores()
  else note.Text=content.note;note.TextColor3=content.accent;detail.Text=content.detail;footer.Text='준비 중인 기능입니다. 결제·추첨·보상 지급은 진행되지 않습니다.'end
  veil.Visible=true;gui:SetAttribute('Open',true);gui:SetAttribute('Panel',action);syncVisibility()
  if UIS.GamepadEnabled then GuiService.SelectedObject=close end
  if not wasOpen and deps.onPanelChanged then deps.onPanelChanged(true)end;return true
 end
 for action,b in pairs(buttons)do b.Activated:Connect(function()open(action)end)end
 close.Activated:Connect(function()closePanel();syncVisibility()end)
 connect(UIS.InputBegan,function(key)if opened and(key.KeyCode==Enum.KeyCode.Escape or key.KeyCode==Enum.KeyCode.ButtonB)then closePanel();syncVisibility()end end)
 local function bindPrompt(prompt)
  if not prompt:IsA('ProximityPrompt')or promptStates[prompt]~=nil then return end
  local action=prompt:GetAttribute('LobbyHubAction');if action~='loadout'and not copy[action]then return end
  promptStates[prompt]=prompt.Enabled;syncVisibility()
 end
 local currentWorld
 local function bindWorld(world)
  if world.Name~='SummonerLobby'or currentWorld==world then return end
  for _,connection in ipairs(worldConnections)do connection:Disconnect()end;table.clear(worldConnections)
  for prompt,enabled in pairs(promptStates)do if prompt.Parent then prompt.Enabled=enabled end end;table.clear(promptStates)
  currentWorld=world
  for _,object in ipairs(world:GetDescendants())do bindPrompt(object)end
  table.insert(worldConnections,world.DescendantAdded:Connect(bindPrompt))
  table.insert(worldConnections,world.DescendantRemoving:Connect(function(object)promptStates[object]=nil end))
 end
 if deps.world then bindWorld(deps.world)else connect(workspace.ChildAdded,bindWorld);local world=workspace:FindFirstChild('SummonerLobby');if world then bindWorld(world)end end
 connect(Prompts.PromptTriggered,function(prompt,who)
  if who and who~=player then return end
  if currentWorld and prompt:IsDescendantOf(currentWorld)and promptStates[prompt]~=nil then open(prompt:GetAttribute('LobbyHubAction'))end
 end)
 local function watchMenu(other)
  if not table.find({'SummonerLobbyUI','DragonPreview','SkillPreview','EnemyPreview'},other.Name)or menuConnections[other]then return end
  menuConnections[other]={other:GetAttributeChangedSignal('Open'):Connect(syncVisibility),other:GetAttributeChangedSignal('LoadoutOpen'):Connect(syncVisibility)};syncVisibility()
 end
 for _,other in ipairs(playerGui:GetChildren())do watchMenu(other)end
 connect(playerGui.ChildAdded,watchMenu)
 connect(playerGui.ChildRemoved,function(other)
  local items=menuConnections[other];if items then for _,connection in ipairs(items)do connection:Disconnect()end;menuConnections[other]=nil;syncVisibility()end
 end)
 connect(net.State.OnClientEvent,function(state)
  inLobby=state.lobby==true;gui:SetAttribute('InLobby',inLobby)
  if inLobby then
   local fresh={};local seen={}
   for _,record in ipairs(type(state.lobbyScores)=='table'and state.lobbyScores or{})do
    if #fresh>=20 then break end
    if type(record)=='table'and type(record.userId)=='number'and math.abs(record.userId)<1e12 and record.userId%1==0 and type(record.name)=='string'and type(record.bestScore)=='number'and record.bestScore>=0 and record.bestScore<1e12 and not seen[record.userId]then
     seen[record.userId]=true;table.insert(fresh,{userId=record.userId,name=string.sub(record.name,1,80),bestScore=math.floor(record.bestScore)})
    end
   end
   table.sort(fresh,function(a,b)if a.bestScore==b.bestScore then return a.userId<b.userId end;return a.bestScore>b.bestScore end);scores=fresh
   if opened=='ranking'then renderScores()end
  end
  syncVisibility()
 end)
 connect(player.CharacterAdded,function()closePanel();syncVisibility()end)
 if player.CharacterRemoving then connect(player.CharacterRemoving,function()closePanel();syncVisibility()end)end
 connect(workspace:GetPropertyChangedSignal('CurrentCamera'),bindCamera);bindCamera()
 local function destroy()
  if destroyed then return end;closePanel();destroyed=true
  for _,connection in ipairs(connections)do connection:Disconnect()end
  for _,connection in ipairs(worldConnections)do connection:Disconnect()end
  for _,items in pairs(menuConnections)do for _,connection in ipairs(items)do connection:Disconnect()end end
  if viewportConnection then viewportConnection:Disconnect()end
  for prompt,enabled in pairs(promptStates)do if prompt.Parent then prompt.Enabled=enabled end end
  gui:Destroy()
 end
 gui.Destroying:Connect(destroy);gui:SetAttribute('Open',false);gui:SetAttribute('InLobby',false);syncVisibility()
 return {Gui=gui,Open=open,Close=function()closePanel();syncVisibility()end,Destroy=destroy}
end
