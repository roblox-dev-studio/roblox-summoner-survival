-- Before a run: choose four spells, ready up, then enter the arena together.
return function(deps)
 local player,net,hud,input=deps.player,deps.net,deps.hud,deps.input
 local theme=require(script.Parent.Parent.Theme)
 local make,label,round,stroke=theme.Make,theme.Label,theme.Round,theme.Stroke
 local palette=theme.Palette
 local gui=make('ScreenGui',player:WaitForChild('PlayerGui'),{Name='SummonerLobbyUI',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=30,Enabled=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
 local veil=make('Frame',gui,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(8,14,27),BackgroundTransparency=.2})
 local panel=make('Frame',veil,{Name='Panel',Size=UDim2.fromOffset(960,768),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=palette.bg,BackgroundTransparency=.04});round(panel,20);stroke(panel)
 local scale=make('UIScale',panel,{Scale=1})
 local function resize()local v=workspace.CurrentCamera.ViewportSize;scale.Scale=math.min(1,(v.X-24)/960,(v.Y-24)/768)end
 workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(resize);resize()
 local heading=label(panel,'ARCANE HAVEN  /  마법사의 안식처',UDim2.fromOffset(900,38),UDim2.fromOffset(28,18),Enum.Font.GothamBold,palette.mint);heading.TextSize=25;heading.TextXAlignment=Enum.TextXAlignment.Left
 local hint=label(panel,'Q 사용 스킬 1개와 자동 마법 4개를 골라 출발하세요.',UDim2.fromOffset(900,24),UDim2.fromOffset(28,62),nil,palette.muted);hint.TextXAlignment=Enum.TextXAlignment.Left;hint.TextSize=15
 local slots=label(panel,'마법 목록을 불러오는 중…',UDim2.fromOffset(900,24),UDim2.fromOffset(28,196),Enum.Font.GothamBold,palette.gold);slots.Name='SelectedSpells';slots.TextXAlignment=Enum.TextXAlignment.Left;slots.TextSize=15
 local grid=make('ScrollingFrame',panel,{Name='Spells',Size=UDim2.fromOffset(904,390),Position=UDim2.fromOffset(28,232),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,BackgroundTransparency=1,BorderSizePixel=0})
 make('UIGridLayout',grid,{CellSize=UDim2.new(.5,-8,0,88),CellPadding=UDim2.fromOffset(12,10),SortOrder=Enum.SortOrder.LayoutOrder})
 local start=make('TextButton',panel,{Name='Start',Size=UDim2.fromOffset(270,48),Position=UDim2.fromOffset(662,642),BackgroundColor3=palette.mint,TextColor3=palette.bg,Font=Enum.Font.GothamBold,TextSize=19,Text='전투 시작',AutoButtonColor=true});round(start,12)
 local bossTest,fieldTest
 if game:GetService('RunService'):IsStudio()then
  bossTest=make('TextButton',panel,{Name='BossTest',Size=UDim2.fromOffset(130,48),Position=UDim2.fromOffset(28,642),BackgroundColor3=Color3.fromRGB(159,92,59),TextColor3=palette.text,Font=Enum.Font.GothamBold,TextSize=16,Text='드래곤 테스트\n스킬 5단계',AutoButtonColor=true});round(bossTest,12)
  fieldTest=make('TextButton',panel,{Name='FieldBossTest',Size=UDim2.fromOffset(130,48),Position=UDim2.fromOffset(164,642),BackgroundColor3=Color3.fromRGB(89,103,141),TextColor3=palette.text,Font=Enum.Font.GothamBold,TextSize=14,Text='필드보스 테스트\n스킬 3단계',AutoButtonColor=true});round(fieldTest,12)
 end
 local status=label(panel,'',UDim2.fromOffset(904,24),UDim2.fromOffset(28,694),nil,palette.muted);status.TextSize=14;status.TextXAlignment=Enum.TextXAlignment.Left
 local footer=label(panel,'Q / 패드 R2 선택한 스킬 · E / 패드 B 대시 · 골렘은 기본 동행  |  선택한 마법은 1단계로 시작하고 레벨업으로 강화됩니다.',UDim2.fromOffset(904,26),UDim2.fromOffset(28,730),nil,palette.muted);footer.TextSize=12
 local activeLabel=label(panel,'Q 사용 스킬',UDim2.fromOffset(900,20),UDim2.fromOffset(28,90),Enum.Font.GothamBold,palette.gold);activeLabel.TextSize=13;activeLabel.TextXAlignment=Enum.TextXAlignment.Left
 local selected,options,buttons={},{},{}
 local activeSkill='iceRush';local activeButtons={}
 local queued=false;local inLobby=nil;local pending=false
 local function refresh()
  local names={};for _,id in ipairs(selected)do for _,v in ipairs(options)do if v.id==id then table.insert(names,v.name)end end end
  slots.Text=string.format('선택 %d / 4   ·   ',#selected)..table.concat(names,'  +  ')
  for id,item in pairs(buttons)do
   local active=table.find(selected,id)~=nil
   item.button.BackgroundColor3=active and Color3.fromRGB(40,65,73) or palette.card
   item.mark.Text=active and '선택됨 ✓' or '선택';item.mark.TextColor3=active and palette.mint or palette.muted
  end
  for id,b in pairs(activeButtons)do b.BackgroundColor3=id==activeSkill and Color3.fromRGB(53,89,99) or palette.card end
  start.Text=queued and '준비 취소' or '전투 시작'
  start.BackgroundColor3=#selected==4 and palette.mint or Color3.fromRGB(92,119,127)
 end
 local function buildActive(items)
  local width=(904-(#items-1)*10)/#items
  for index,v in ipairs(items)do
   local b=make('TextButton',panel,{Name='Active_'..v.id,Size=UDim2.fromOffset(width,58),Position=UDim2.fromOffset(28+(index-1)*(width+10),116),BackgroundColor3=palette.card,Text=v.name..'\n'..v.desc,TextColor3=palette.text,TextSize=14,Font=Enum.Font.GothamBold,AutoButtonColor=true});round(b,10);stroke(b)
   activeButtons[v.id]=b
   b.Activated:Connect(function()if queued or pending then return end;activeSkill=v.id;refresh()end)
  end
 end
 local function build()
  for index,v in ipairs(options)do
   local b=make('TextButton',grid,{Name=v.id,Text='',BackgroundColor3=palette.card,LayoutOrder=index,AutoButtonColor=true});round(b,12);stroke(b,Color3.fromRGB(v.color[1],v.color[2],v.color[3]))
   local name=label(b,v.name,UDim2.new(1,-110,0,23),UDim2.fromOffset(14,8),Enum.Font.GothamBold,Color3.fromRGB(v.color[1],v.color[2],v.color[3]));name.TextSize=18;name.TextXAlignment=Enum.TextXAlignment.Left
   local mark=label(b,'',UDim2.fromOffset(80,23),UDim2.new(1,-90,0,8),nil,palette.mint);mark.TextSize=12
   local role=label(b,v.role,UDim2.new(1,-28,0,18),UDim2.fromOffset(14,33),nil,palette.gold);role.TextSize=11;role.TextXAlignment=Enum.TextXAlignment.Left
   local desc=label(b,v.desc,UDim2.new(1,-28,0,26),UDim2.fromOffset(14,53),nil,palette.muted);desc.TextSize=12;desc.TextXAlignment=Enum.TextXAlignment.Left
   buttons[v.id]={button=b,mark=mark}
   b.Activated:Connect(function()
    if queued or pending then return end
    local i=table.find(selected,v.id)
    if i then table.remove(selected,i)elseif #selected<4 then table.insert(selected,v.id)else status.Text='선택한 마법 하나를 해제한 뒤 다른 마법을 골라 주세요.'end
    refresh()
   end)
  end
 end
 if bossTest then bossTest.Activated:Connect(function()
  if pending or queued then return end
  if #selected~=4 then status.Text='서로 다른 마법을 4개 골라 주세요.';return end
  pending=true;bossTest.Text='보스전 준비 중…';net.Action:FireServer('startBossTest',table.clone(selected),activeSkill)
  task.delay(2,function()pending=false;bossTest.Text='드래곤 테스트\n스킬 5단계';refresh()end)
 end)end
 if fieldTest then fieldTest.Activated:Connect(function()
  if pending or queued then return end
  if #selected~=4 then status.Text='서로 다른 마법을 4개 골라 주세요.';return end
  pending=true;net.Action:FireServer('startFieldBossTest',table.clone(selected),activeSkill)
  task.delay(2,function()pending=false;refresh()end)
 end)end
 start.Activated:Connect(function()
  if pending then return end
  if queued then net.Action:FireServer('cancelReady');return end
  if #selected~=4 then status.Text='서로 다른 마법을 4개 골라 주세요.';return end
  pending=true;start.Text='출발 준비 중…';net.Action:FireServer('startRound',table.clone(selected),activeSkill)
  task.delay(2,function()pending=false;refresh()end)
 end)
 net.State.OnClientEvent:Connect(function(s)
  local visible=s.lobby==true
  if visible and inLobby~=true then selected=table.clone(s.loadout or {});activeSkill=s.activeSkill or 'iceRush';input.SetSuspended(true);hud.Enabled=false end
  if not visible and inLobby~=false then
   input.SetSuspended(false);hud.Enabled=true
   local c=player.Character;local root=c and c:FindFirstChild('HumanoidRootPart')
   if root and deps.camera then deps.camera.Reset()end
  end
  local preview=player.PlayerGui:FindFirstChild('DragonPreview');local open=preview and preview:FindFirstChild('OpenButton')
  if open then open.Visible=not visible end
  local skillView=player.PlayerGui:FindFirstChild("SkillPreview")
  inLobby=visible;gui.Enabled=visible and not(skillView and skillView:GetAttribute("Open"));gui:SetAttribute('InLobby',visible)
  if not visible then return end
  if #options==0 and s.spellOptions then options=s.spellOptions;build()end
  if not next(activeButtons) and s.activeOptions then buildActive(s.activeOptions)end
  queued=s.queued==true;pending=false
  if bossTest then bossTest.Text=s.bossTestQueued and '보스전 준비 완료 · 취소는 오른쪽' or '드래곤 테스트\n스킬 5단계'end
  if fieldTest then fieldTest.Text=s.fieldBossTestQueued and '필드보스 준비 완료' or '필드보스 테스트\n스킬 3단계'end
  status.Text=s.lobbyMessage or(queued and '준비 완료 · 다른 플레이어가 준비하면 함께 출발합니다.' or '혼자라면 바로 출발 · 친구와 함께라면 전원 준비 후 출발')
  refresh()
 end)
 return {Gui=gui}
end
