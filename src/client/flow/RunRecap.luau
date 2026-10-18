-- Read-only result screen. The server freezes the record when this player's run ends.
return function(deps)
 local player,net=deps.player,deps.net
 local playerGui=player:WaitForChild('PlayerGui')
 local theme=require(script.Parent.Parent.Theme)
 local make,label,round,stroke=theme.Make,theme.Label,theme.Round,theme.Stroke
 local palette=theme.Palette
 local icons=require(script.Parent.SkillIcons)
 local UIS=game:GetService('UserInputService');local GuiService=game:GetService('GuiService')
 local gui=make('ScreenGui',playerGui,{Name='SummonerRunRecap',ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=40,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
 local history=make('TextButton',gui,{Name='LastRun',Size=UDim2.fromOffset(148,34),Position=UDim2.new(1,-16,0,14),AnchorPoint=Vector2.new(1,0),BackgroundColor3=palette.bg,TextColor3=palette.gold,Text='직전 전투 기록',Font=Enum.Font.GothamBold,TextSize=13,Visible=false});round(history,8);stroke(history,palette.gold)
 local veil=make('Frame',gui,{Name='Veil',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(4,10,17),BackgroundTransparency=.12,Active=true,Visible=false})
 local panel=make('Frame',veil,{Name='Panel',Size=UDim2.fromOffset(760,690),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=palette.bg});round(panel,18);stroke(panel,palette.gold)
 local scale=make('UIScale',panel,{Scale=1})
 local function text(parent,name,value,size,pos,font,color)
  local item=label(parent,value,size,pos,font,color);item.Name=name;item.TextXAlignment=Enum.TextXAlignment.Left;return item
 end
 text(panel,'Eyebrow','EXPEDITION / 이번 판의 기록',UDim2.fromOffset(650,22),UDim2.fromOffset(28,18),Enum.Font.GothamBold,palette.gold).TextSize=12
 local heading=text(panel,'Outcome','전투 종료',UDim2.fromOffset(560,44),UDim2.fromOffset(28,44),Enum.Font.GothamBold,palette.text);heading.TextSize=30
 local record=text(panel,'Record','',UDim2.fromOffset(704,24),UDim2.fromOffset(28,94),nil,palette.mint);record.TextSize=14
 local close=make('TextButton',panel,{Name='Close',Size=UDim2.fromOffset(74,34),Position=UDim2.new(1,-102,0,34),BackgroundColor3=palette.card,TextColor3=palette.text,Text='닫기',Font=Enum.Font.GothamBold,TextSize=14});round(close,8)
 local metrics={}
 for i,name in ipairs({'전투 시간','처치','도달 레벨'})do
  local tile=make('Frame',panel,{Name='Metric'..i,Size=UDim2.fromOffset(226,76),Position=UDim2.fromOffset(28+(i-1)*239,130),BackgroundColor3=palette.card});round(tile,10)
  text(tile,'Label',name,UDim2.fromOffset(194,20),UDim2.fromOffset(16,9),nil,palette.muted).TextSize=12
  metrics[i]=text(tile,'Value','',UDim2.fromOffset(194,36),UDim2.fromOffset(16,31),Enum.Font.GothamBold,palette.text);metrics[i].TextSize=26
 end
 local scroll=make('ScrollingFrame',panel,{Name='Build',Size=UDim2.fromOffset(712,368),Position=UDim2.fromOffset(28,222),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4})
 make('UIListLayout',scroll,{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder})
 local footer=text(panel,'Scope','전투 시간은 일시 정지를 제외합니다. 기록은 이번 접속 동안만 유지됩니다.',UDim2.fromOffset(704,30),UDim2.fromOffset(28,596),nil,palette.muted);footer.TextSize=12
 local back=make('TextButton',panel,{Name='ReturnToLobby',Size=UDim2.fromOffset(704,44),Position=UDim2.fromOffset(28,632),BackgroundColor3=palette.mint,TextColor3=palette.bg,Text='로비로 돌아가기',Font=Enum.Font.GothamBold,TextSize=18});round(back,10)
 local connections,menuConnections={},{}
 local viewportConnection,savedSelection
 local inLobby,over,opened,returning,destroyed=false,false,false,false,false
 local data,renderedRevision
 local menuNames={'SummonerLobbyUI','SummonerLobbyHub','DragonPreview','SkillPreview','EnemyPreview'}
 local function connect(signal,callback)local c=signal:Connect(callback);table.insert(connections,c);return c end
 local function blocked()
  for _,name in ipairs(menuNames)do
   local other=playerGui:FindFirstChild(name)
   if other and(other:GetAttribute('Open')==true or other:GetAttribute('LoadoutOpen')==true)then return true end
  end
  return false
 end
 local function refreshHistory()history.Visible=inLobby and data~=nil and not opened and not blocked()end
 local function setOpen(value)
  if value and not data then return false end
  if opened==value then return true end
  if value and deps.beforeOpen then deps.beforeOpen()end
  opened=value;veil.Visible=value;gui:SetAttribute('Open',value)
  if value then savedSelection=GuiService.SelectedObject;if UIS.GamepadEnabled then GuiService.SelectedObject=inLobby and close or back end
  else GuiService.SelectedObject=savedSelection and savedSelection.Parent and savedSelection or nil;savedSelection=nil end
  if deps.onPanelChanged then deps.onPanelChanged(value)end
  refreshHistory();return true
 end
 local function section(name,order)
  local item=text(scroll,'Section'..order,name,UDim2.new(1,-12,0,26),UDim2.new(),Enum.Font.GothamBold,palette.mint)
  item.LayoutOrder=order;item.TextSize=14
 end
 local function row(id,name,detail,order,accent)
  local card=make('Frame',scroll,{Name='Item_'..id,Size=UDim2.new(1,-12,0,76),BackgroundColor3=palette.card,LayoutOrder=order});round(card,9)
  local tile=make('Frame',card,{Size=UDim2.fromOffset(50,50),Position=UDim2.fromOffset(12,13),BackgroundColor3=palette.bg});round(tile,7)
  local fallback=label(tile,'',UDim2.fromScale(1,1),UDim2.new(),Enum.Font.GothamBold,accent);fallback.Name='IconFallback'
  local image=make('ImageLabel',tile,{Name='SkillIcon',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit})
  icons.Apply(image,id,fallback)
  text(card,'Title',name,UDim2.new(1,-90,0,24),UDim2.fromOffset(76,7),Enum.Font.GothamBold,accent).TextSize=16
  local desc=text(card,'Description',detail,UDim2.new(1,-90,0,38),UDim2.fromOffset(76,32),nil,palette.muted);desc.TextSize=13
 end
 local function render()
  if not data or renderedRevision==data.revision then return end
  renderedRevision=data.revision;scroll.CanvasPosition=Vector2.zero
  for _,child in ipairs(scroll:GetChildren())do if child:IsA('GuiObject')then child:Destroy()end end
  heading.Text=({victory='드래곤 격파!',defeat='원정 종료 · 다시 도전!',retreat='원정 중단 · 전열 정비'})[data.result]or'전투 종료'
  heading.TextColor3=data.result=='victory'and palette.gold or palette.text
  record.Text=data.testMode and '개발용 보스 테스트 · 최고 처치 기록에 반영하지 않습니다.'or
   ((data.newBest and '이번 접속 최고 기록!  ·  'or'이번 접속 최고  ·  ')..tostring(data.bestScore or data.kills)..' 처치')
  metrics[1].Text=string.format('%02d:%02d',math.floor(data.seconds/60),data.seconds%60)
  metrics[2].Text=tostring(data.kills);metrics[3].Text='Lv. '..data.level
  section('완성한 마법 조합',1)
  local names={};for _,spell in ipairs(data.spells)do table.insert(names,spell.name..' '..spell.level..'단계')end
  local spells=text(scroll,'Spells',table.concat(names,'  ·  ')..'\n골렘 '..data.golem..'단계',UDim2.new(1,-12,0,52),UDim2.new(),Enum.Font.GothamMedium,palette.text);spells.LayoutOrder=2;spells.TextSize=15
  row(data.activeSkill,'Q · '..data.activeName,'출전할 때 선택한 사용 스킬',3,palette.gold)
  section(string.format('보유 증강 %d회 · 행운 +%d',data.augmentCount,data.luck),4)
  local rarityNames={common='일반',rare='희귀',epic='영웅'}
  local rarityColors={common=palette.text,rare=Color3.fromRGB(113,194,255),epic=Color3.fromRGB(219,154,255)}
  for i,a in ipairs(data.augments)do
   row('aug_'..a.id,string.format('%s  ×%d  /  %s',a.name,a.count,rarityNames[a.rarity]or'일반'),a.desc,4+i,rarityColors[a.rarity]or palette.text)
  end
  local tailOrder=5+#data.augments
  if #data.augments==0 then
   local empty=text(scroll,'EmptyAugments','이 판에는 증강을 선택하지 않았습니다.',UDim2.new(1,-12,0,32),UDim2.new(),nil,palette.muted);empty.LayoutOrder=tailOrder;empty.TextSize=14
   tailOrder+=1
  end
  section('생존 강화와 진행',tailOrder)
  local detail=string.format('최대 체력 +%d · 이동 속도 +%d · 수집 범위 +%d\n무료 새로고침 %d / 2회 사용 · 군단장 보상 %s',data.vitality*15,data.agility*2,data.magnet*3,data.rerollsUsed,data.fieldBossRewarded and '수령'or'미수령')
  local utility=text(scroll,'Utility',detail,UDim2.new(1,-12,0,54),UDim2.new(),nil,palette.text);utility.LayoutOrder=tailOrder+1;utility.TextSize=14
 end
 local function resize()
  local camera=workspace.CurrentCamera;if not camera then return end
  local size=camera.ViewportSize
  scale.Scale=math.max(.1,math.min(1,(size.X-24)/760,(size.Y-72)/690))
 end
 local function bindCamera()
  if viewportConnection then viewportConnection:Disconnect()end
  local camera=workspace.CurrentCamera;if camera then viewportConnection=camera:GetPropertyChangedSignal('ViewportSize'):Connect(resize)end;resize()
 end
 local function closeHistory()if inLobby then setOpen(false)end end
 history.Activated:Connect(function()if inLobby and not blocked()then render();setOpen(true)end end)
 close.Activated:Connect(closeHistory)
 back.Activated:Connect(function()
  if inLobby then closeHistory();return end
  if over and not returning then returning=true;back.Text='로비로 이동 중…';net.Action:FireServer('returnToLobby')end
 end)
 connect(UIS.InputBegan,function(key)if opened and inLobby and(key.KeyCode==Enum.KeyCode.Escape or key.KeyCode==Enum.KeyCode.ButtonB)then closeHistory()end end)
 local function watchMenu(other)
  if not table.find(menuNames,other.Name)or menuConnections[other]then return end
  menuConnections[other]={other:GetAttributeChangedSignal('Open'):Connect(refreshHistory),other:GetAttributeChangedSignal('LoadoutOpen'):Connect(refreshHistory)}
 end
 for _,other in ipairs(playerGui:GetChildren())do watchMenu(other)end
 connect(playerGui.ChildAdded,watchMenu)
 connect(playerGui.ChildRemoved,function(other)
  local items=menuConnections[other];if items then for _,c in ipairs(items)do c:Disconnect()end;menuConnections[other]=nil;refreshHistory()end
 end)
 connect(net.State.OnClientEvent,function(s)
  local wasLobby,wasOver=inLobby,over
  inLobby=s.lobby==true;over=s.over==true
  data=over and s.runResult or(inLobby and s.lastRun or nil)
  close.Visible=inLobby;back.Text=inLobby and '기록 닫기 · 로비 둘러보기'or(returning and '로비로 이동 중…'or'로비로 돌아가기')
  if inLobby then returning=false end
  if wasLobby~=inLobby or(wasOver and not over)or not data then setOpen(false)end
  if data then render();if over and not blocked()then setOpen(true)end end
  refreshHistory()
 end)
 connect(workspace:GetPropertyChangedSignal('CurrentCamera'),bindCamera);bindCamera()
 local function destroy()
  if destroyed then return end;destroyed=true;setOpen(false)
  for _,c in ipairs(connections)do c:Disconnect()end
  for _,items in pairs(menuConnections)do for _,c in ipairs(items)do c:Disconnect()end end
  if viewportConnection then viewportConnection:Disconnect()end
  gui:Destroy()
 end
 gui.Destroying:Connect(destroy);gui:SetAttribute('Open',false)
 return {Gui=gui,Close=function()setOpen(false)end,Destroy=destroy}
end
