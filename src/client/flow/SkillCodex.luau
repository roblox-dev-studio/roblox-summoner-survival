-- Read-only spell book. All descriptions/conditions come from the generated server catalog.
-- This view never equips, grants an augmentation, or sends a remote request.
return function(parent)
 local theme=require(script.Parent.Parent.Theme)
 local icons=require(script.Parent.SkillIcons)
 local make,label,round=theme.Make,theme.Label,theme.Round
 local colors=theme.Palette
 local frame=make('Frame',parent,{Name='SkillCodex',Position=UDim2.fromOffset(28,154),Size=UDim2.fromOffset(664,420),BackgroundTransparency=1,Visible=false})
 local filters={};local connections={};local group='all';local alive=true;local generation=0
 local rarityColors={common=colors.muted,rare=Color3.fromRGB(126,191,255),epic=Color3.fromRGB(204,157,255)}
 local tabs={{'all','전체'},{'auto','자동 마법'},{'active','Q 마법'},{'augments','증강'},{'builtin','기본 능력'}}
 for i,tab in ipairs(tabs)do
  local button=make('TextButton',frame,{Name='Filter_'..tab[1],Position=UDim2.fromOffset((i-1)*134,0),Size=UDim2.fromOffset(128,30),Text=tab[2],TextSize=13,Font=Enum.Font.GothamBold,BackgroundColor3=colors.card,TextColor3=colors.text})
  round(button,7);filters[tab[1]]=button
 end
 local search=make('TextBox',frame,{Name='Search',Position=UDim2.fromOffset(0,40),Size=UDim2.new(1,-82,0,34),BackgroundColor3=colors.card,TextColor3=colors.text,PlaceholderColor3=colors.muted,PlaceholderText='이름 · 효과 · 조합 조건 검색',Text='',TextSize=14,Font=Enum.Font.GothamMedium,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left})
 round(search,7);make('UIPadding',search,{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})
 local clear=make('TextButton',frame,{Name='ClearSearch',Position=UDim2.new(1,-72,0,40),Size=UDim2.fromOffset(72,34),Text='지우기',TextSize=13,Font=Enum.Font.GothamMedium,BackgroundColor3=colors.card,TextColor3=colors.text});round(clear,7)
 local scroll=make('ScrollingFrame',frame,{Name='Entries',Position=UDim2.fromOffset(0,84),Size=UDim2.new(1,0,1,-84),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y})
 make('UIListLayout',scroll,{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder})
 local empty=label(frame,'검색 결과가 없어요.\n다른 이름이나 효과로 찾아보세요.',UDim2.new(1,-20,0,120),UDim2.fromOffset(10,150),nil,colors.muted);empty.Name='Empty';empty.Visible=false
 local function leftText(holder,name,text,x,y,width,height,size,color,font)
  local textLabel=label(holder,text,UDim2.fromOffset(width,height),UDim2.fromOffset(x,y),font or Enum.Font.GothamMedium,color)
  textLabel.Name=name;textLabel.TextSize=size;textLabel.TextXAlignment=Enum.TextXAlignment.Left;textLabel.TextYAlignment=Enum.TextYAlignment.Top
  return textLabel
 end
 local function render()
  if not alive or not frame.Visible then return end
  for _,child in ipairs(scroll:GetChildren())do if child:IsA('Frame')then child:Destroy()end end
  local entries=icons.List(group,search.Text)
  frame:SetAttribute('EntryCount',#entries);frame:SetAttribute('Filter',group)
  empty.Visible=#entries==0;scroll.CanvasPosition=Vector2.zero
  for key,button in pairs(filters)do button.BackgroundColor3=key==group and colors.mint or colors.card;button.TextColor3=key==group and colors.bg or colors.text end
  for index,entry in ipairs(entries)do
   local row=make('Frame',scroll,{Name='Entry_'..entry.id,LayoutOrder=index,Size=UDim2.new(1,-12,0,176),BackgroundColor3=colors.card});round(row,10)
   local accent=rarityColors[entry.rarity]or colors.mint
   local tile=make('Frame',row,{Name='IconTile',Position=UDim2.fromOffset(12,14),Size=UDim2.fromOffset(72,72),BackgroundColor3=colors.bg});round(tile,8)
   local fallback=label(tile,'✦',UDim2.fromScale(1,1),UDim2.new(),Enum.Font.GothamBold,accent);fallback.Name='Fallback';fallback.TextSize=32
   local icon=make('ImageLabel',tile,{Name='Icon',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit});round(icon,8);icons.Apply(icon,entry.id,fallback)
   leftText(row,'Title',entry.name,98,12,528,25,19,colors.text,Enum.Font.GothamBold)
   leftText(row,'Category',entry.badge or entry.categoryName,98,40,528,18,12,accent)
   leftText(row,'Description',entry.description,98,66,528,46,14,colors.text)
   leftText(row,'Condition',entry.condition,14,116,612,33,12,colors.gold)
   local extra=entry.visualNote or entry.upgradeDescription
   leftText(row,'Detail',extra~=''and extra or '출전 준비에서 자신의 빌드와 함께 확인하세요.',14,151,612,21,11,colors.muted)
  end
 end
 local function setFilter(value)
  if not alive or not filters[value]then return false end
  group=value;generation+=1;render();return true
 end
 for key,button in pairs(filters)do table.insert(connections,button.Activated:Connect(function()setFilter(key)end))end
 table.insert(connections,search:GetPropertyChangedSignal('Text'):Connect(function()
  generation+=1;local version=generation
  task.delay(.12,function()if alive and generation==version then render()end end)
 end))
 table.insert(connections,clear.Activated:Connect(function()search.Text='';generation+=1;render()end))
 local function setVisible(value)
  if not alive then return end;generation+=1;frame.Visible=value
  if value then render()else search:ReleaseFocus()end
 end
 local function destroy()
  if not alive then return end;setVisible(false);alive=false
  for _,connection in ipairs(connections)do connection:Disconnect()end
  frame:Destroy()
 end
 return {Frame=frame,SetVisible=setVisible,SetFilter=setFilter,Destroy=destroy}
end
