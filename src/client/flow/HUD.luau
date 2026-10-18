-- Native editable GUI, offers and state rendering.
return function(deps)
	local player, net = deps.player, deps.net
	local theme = require(script.Parent.Parent:WaitForChild("Theme"))
	local palette, make, round, stroke, label = theme.Palette, theme.Make, theme.Round, theme.Stroke, theme.Label
	local icons=require(script.Parent.SkillIcons)
	local gui=Instance.new("ScreenGui"); gui.Name="SummonerHUD"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=player:WaitForChild("PlayerGui")
	local encounter=make("Frame",gui,{Name="EncounterPanel",Size=UDim2.new(.8,0,0,26),Position=UDim2.new(1,-12,0,6),AnchorPoint=Vector2.new(1,0),BackgroundColor3=palette.bg,BackgroundTransparency=.15})
	make("UISizeConstraint",encounter,{MaxSize=Vector2.new(320,26)});round(encounter,8)
	local title=label(encounter,"SURVIVAL / 드래곤 등장까지",UDim2.new(1,-76,1,0),UDim2.fromOffset(10,0),Enum.Font.GothamBold,palette.mint);title.TextSize=11;title.TextXAlignment=Enum.TextXAlignment.Left
	local timer=label(encounter,"02:00",UDim2.fromOffset(60,26),UDim2.new(1,-70,0,0),Enum.Font.GothamBold);timer.TextSize=16;timer.TextXAlignment=Enum.TextXAlignment.Right
	local top=make("Frame",gui,{Name="PlayerPanel",Size=UDim2.fromOffset(340,146),Position=UDim2.new(0,12,1,-12),AnchorPoint=Vector2.new(0,1),BackgroundColor3=palette.bg,BackgroundTransparency=.12})
	round(top,10);stroke(top)
	local info=label(top,"Lv.1  체력 150/150  처치 0",UDim2.new(1,-24,0,18),UDim2.fromOffset(12,6),Enum.Font.GothamBold,palette.text);info.TextSize=12;info.TextXAlignment=Enum.TextXAlignment.Left
	local healthBack=make("Frame",top,{Size=UDim2.new(1,-24,0,6),Position=UDim2.fromOffset(12,30),BackgroundColor3=Color3.fromRGB(49,48,59),BorderSizePixel=0});round(healthBack,3)
	local health=make("Frame",healthBack,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(249,117,133),BorderSizePixel=0});round(health,3)
	local xpInfo=label(top,"경험치 0/5",UDim2.new(1,-24,0,16),UDim2.fromOffset(12,42),nil,palette.muted);xpInfo.TextSize=11;xpInfo.TextXAlignment=Enum.TextXAlignment.Left
	local xpBack=make("Frame",top,{Size=UDim2.new(1,-24,0,3),Position=UDim2.fromOffset(12,62),BackgroundColor3=Color3.fromRGB(38,63,67),BorderSizePixel=0});round(xpBack,2)
	local xp=make("Frame",xpBack,{Size=UDim2.fromScale(0,1),BackgroundColor3=palette.mint,BorderSizePixel=0});round(xp,2)
	local bossPanel=make("Frame",gui,{Name="BossPanel",Size=UDim2.new(.8,0,0,36),Position=UDim2.new(1,-12,0,38),AnchorPoint=Vector2.new(1,0),BackgroundColor3=palette.bg,BackgroundTransparency=.12,Visible=false})
	make("UISizeConstraint",bossPanel,{MaxSize=Vector2.new(320,36)});round(bossPanel,8);stroke(bossPanel,palette.gold)
	local bossTitle=label(bossPanel,"흑염룡 · 아그니스",UDim2.new(1,-20,0,18),UDim2.fromOffset(10,3),Enum.Font.GothamBold,palette.gold);bossTitle.TextSize=11
	local bossBack=make("Frame",bossPanel,{Size=UDim2.new(1,-20,0,5),Position=UDim2.fromOffset(10,25),BackgroundColor3=palette.card});round(bossBack,3)
	local bossHealth=make("Frame",bossBack,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(187,110,255),BorderSizePixel=0});round(bossHealth,3)
	local skills=label(top,"화염탄 1 · 골렘 1",UDim2.new(1,-24,0,16),UDim2.fromOffset(12,72),nil,palette.text);skills.TextSize=11;skills.TextXAlignment=Enum.TextXAlignment.Left
	skills.Size=UDim2.new(1,-24,0,26);skills.Position=UDim2.fromOffset(12,68)
	local golemStatus=label(top,"대지 강타 · 자동",UDim2.new(1,-24,0,16),UDim2.fromOffset(12,96),nil,palette.gold);golemStatus.TextSize=11;golemStatus.TextXAlignment=Enum.TextXAlignment.Left
	local pulse=make("TextButton",gui,{Name="Pulse",Size=UDim2.fromOffset(108,72),Position=UDim2.new(1,-20,1,-88),AnchorPoint=Vector2.new(1,1),BackgroundColor3=palette.mint,TextColor3=palette.bg,Text="빙하 쇄도\n[Q] 준비",Font=Enum.Font.GothamBold,TextSize=17,AutoButtonColor=true}); round(pulse,16)
	local dashButton=make("TextButton",gui,{Name="Dash",Size=UDim2.fromOffset(108,58),Position=UDim2.new(1,-20,1,-18),AnchorPoint=Vector2.new(1,1),BackgroundColor3=Color3.fromRGB(135,203,255),TextColor3=palette.bg,Text="대시 [E]\n준비",Font=Enum.Font.GothamBold,TextSize=15,AutoButtonColor=true});round(dashButton,14)
 local basicButton=make("TextButton",gui,{Name="BasicAttack",Size=UDim2.fromOffset(108,58),Position=UDim2.new(1,-20,1,-172),AnchorPoint=Vector2.new(1,1),BackgroundColor3=Color3.fromRGB(177,210,255),TextColor3=palette.bg,Text="마법탄 [F/R1]\n누르고 연속 발사",Font=Enum.Font.GothamBold,TextSize=13,AutoButtonColor=true});round(basicButton,14)
 basicButton.InputBegan:Connect(function(key)if key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.Touch then deps.input.SetBasicHeld('HUD',true,key)end end)
 basicButton.InputEnded:Connect(function(key)if key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.Touch then deps.input.SetBasicHeld('HUD',false,key)end end)
 basicButton.SelectionLost:Connect(function()deps.input.SetBasicHeld('HUD',false)end)
 local returnButton=make('TextButton',gui,{Name='ReturnToLobby',Size=UDim2.fromOffset(132,30),Position=UDim2.new(1,-12,0,82),AnchorPoint=Vector2.new(1,0),BackgroundColor3=palette.card,TextColor3=palette.muted,Text='도전 중단 · 로비',Font=Enum.Font.GothamBold,TextSize=12,Visible=false,ZIndex=30,AutoButtonColor=true});round(returnButton,8)
 local returning=false
 returnButton.Activated:Connect(function()
  if returning then return end;returning=true;deps.input.SetBasicHeld('HUD',false)
  returnButton.Text='돌아가는 중…';net.Action:FireServer('returnToLobby')
 end)
	local function layoutActions()
		local width=workspace.CurrentCamera.ViewportSize.X
		top.Size=UDim2.fromOffset(math.clamp(width-152,180,340),146)
		info.TextSize=width<500 and 10 or 12
		skills.TextSize=width<500 and 10 or 11
	end
	local resizeConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutActions);layoutActions()
	local rarityColors={common=Color3.fromRGB(190,214,222),rare=Color3.fromRGB(113,194,255),epic=Color3.fromRGB(219,154,255)}
    local rarityNames={common="일반",rare="희귀",epic="영웅"}
    local buildButton=make("TextButton",top,{Name="AugmentSummary",Size=UDim2.new(1,-24,0,25),Position=UDim2.fromOffset(12,116),BackgroundColor3=palette.card,TextColor3=palette.mint,Text="행운 +0 · 증강 0 · 보기",TextSize=12,Font=Enum.Font.GothamBold});round(buildButton,6)
    local build=make("Frame",gui,{Name="AugmentBuild",Size=UDim2.new(.9,0,.82,0),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=palette.bg,Visible=false,ZIndex=40});round(build,14);make("UISizeConstraint",build,{MaxSize=Vector2.new(620,570)})
    local buildTitle=label(build,"이번 판 증강",UDim2.new(1,-80,0,40),UDim2.fromOffset(16,8),Enum.Font.GothamBold,palette.mint);buildTitle.ZIndex=41
    local close=make("TextButton",build,{Size=UDim2.fromOffset(52,32),Position=UDim2.new(1,-66,0,10),BackgroundColor3=palette.card,TextColor3=palette.text,Text="닫기",TextSize=13,ZIndex=41});round(close,6)
    local buildScroll=make("ScrollingFrame",build,{Name="BuildList",Size=UDim2.new(1,-32,1,-64),Position=UDim2.fromOffset(16,52),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,ZIndex=41})
    local buildText=label(buildScroll,"",UDim2.new(1,-12,0,0),UDim2.new(),nil,palette.text);buildText.AutomaticSize=Enum.AutomaticSize.Y;buildText.TextSize=14;buildText.TextXAlignment=Enum.TextXAlignment.Left;buildText.TextYAlignment=Enum.TextYAlignment.Top;buildText.ZIndex=42
    buildButton.Activated:Connect(function()build.Visible=not build.Visible end);close.Activated:Connect(function()build.Visible=false end)
    local overlay=make("Frame",gui,{Name="ChoiceOverlay",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(6,12,19),BackgroundTransparency=.18,Visible=false,ZIndex=10})
	local modal=make("Frame",overlay,{Size=UDim2.new(.88,0,.82,0),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=palette.bg,ZIndex=11}); round(modal,18); stroke(modal,palette.mint); make("UISizeConstraint",modal,{MaxSize=Vector2.new(650,620)})
	local modalTitle=label(modal,"증강 선택",UDim2.new(1,-32,0,32),UDim2.new(0,16,0,14),Enum.Font.GothamBold,palette.mint); modalTitle.TextSize=25; modalTitle.ZIndex=12
	local modalHint=label(modal,"이번 성장을 선택하세요",UDim2.new(1,-32,0,24),UDim2.new(0,16,0,48),nil,palette.muted); modalHint.TextSize=14; modalHint.ZIndex=12
	local luckInfo=label(modal,"",UDim2.new(1,-32,0,38),UDim2.fromOffset(16,73),nil,palette.muted);luckInfo.Name="LuckInfo";luckInfo.TextSize=11;luckInfo.ZIndex=12
    local cards=make("ScrollingFrame",modal,{Name="AugmentCards",Size=UDim2.new(1,-32,1,-176),Position=UDim2.new(0,16,0,116),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,ZIndex=12})
    local reroll=make("TextButton",modal,{Name="Reroll",Size=UDim2.new(.5,-22,0,36),Position=UDim2.new(0,16,1,-46),BackgroundColor3=palette.card,TextColor3=palette.mint,Font=Enum.Font.GothamBold,TextSize=13,Text="무료 새로고침 · 2회",ZIndex=13});round(reroll,8)
    local inspect=make("TextButton",modal,{Name="InspectBuild",Size=UDim2.new(.5,-22,0,36),Position=UDim2.new(.5,6,1,-46),BackgroundColor3=palette.card,TextColor3=palette.text,Text="보유 증강·행운 설명",TextSize=13,ZIndex=13});round(inspect,8)
    inspect.Activated:Connect(function()build.Visible=true end)
	make("UIListLayout",cards,{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder})
	local buttons={}
	local waiting=false
    local offerRevision=0
    reroll.Activated:Connect(function()if not waiting and reroll.Active then waiting=true;net.Action:FireServer("reroll",offerRevision)end end)
	for i=1,3 do
		local b=make("TextButton",cards,{Name="Choice"..i,Size=UDim2.new(1,-8,0,112),BackgroundColor3=palette.card,Text="",LayoutOrder=i,ZIndex=13,AutoButtonColor=true}); round(b,12); stroke(b)
		local tile=make('Frame',b,{Name='IconTile',Size=UDim2.fromOffset(68,68),Position=UDim2.fromOffset(12,22),BackgroundColor3=Color3.fromRGB(17,28,43),ZIndex=14});round(tile,9)
		local fallback=label(tile,'✦',UDim2.fromScale(1,1),UDim2.new(),Enum.Font.GothamBold,palette.mint);fallback.Name='IconFallback';fallback.TextSize=32;fallback.ZIndex=15
		local image=make('ImageLabel',tile,{Name='SkillIcon',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,Visible=false,ZIndex=15});round(image,9)
		local tag=label(b,"마법 강화",UDim2.new(1,-108,.25,0),UDim2.new(0,94,0,4),Enum.Font.GothamBold,palette.mint); tag.TextSize=11; tag.TextXAlignment=Enum.TextXAlignment.Left; tag.ZIndex=14
		local name=label(b,"화염탄 강화",UDim2.new(1,-108,.3,0),UDim2.new(0,94,.27,0),Enum.Font.GothamBold); name.TextSize=19; name.TextXAlignment=Enum.TextXAlignment.Left; name.ZIndex=14
		local desc=label(b,"피해량 증가",UDim2.new(1,-108,.29,0),UDim2.new(0,94,.63,0),nil,palette.muted); desc.TextSize=13; desc.TextXAlignment=Enum.TextXAlignment.Left; desc.ZIndex=14
		buttons[i]={button=b,tag=tag,name=name,desc=desc,image=image,fallback=fallback,border=b:FindFirstChildOfClass("UIStroke")}
		b.Activated:Connect(function() if b:GetAttribute("ChoiceId") and not waiting then waiting=true; net.Action:FireServer("choose",b:GetAttribute("ChoiceId"),offerRevision) end end)
	end
	pulse.Activated:Connect(deps.input.FireWave)
	dashButton.Activated:Connect(deps.input.Dash)
	local lastChoice=""
	local stateConnection=net.State.OnClientEvent:Connect(function(s)
        returnButton.Visible=s.lobby~=true and s.over~=true
        local augments=s.augments or {};local ranks=0;local descriptions={}
        for _,a in ipairs(augments)do ranks+=a.count;table.insert(descriptions,string.format("[%s] %s ×%d\n%s",rarityNames[a.rarity]or"일반",a.name,a.count,a.desc))end
        buildButton.Text=string.format("행운 +%d · 증강 %d · 보기",s.luck or 0,ranks)
        local weights=s.augmentWeights or {common=70,rare=25,epic=5}
        buildText.Text=string.format("행운 +%d / 최대 60\n일반 %.0f · 희귀 %.0f · 영웅 %.0f 등급 가중치\n강화 가능한 마법 1장은 보장. 나머지는 유효 등급 안에서 추첨합니다.\n해당 등급 후보가 없으면 남은 등급으로 확률을 재분배합니다.\n행운은 피해·아이템 드롭에 영향을 주지 않습니다. 매 판 초기화됩니다.\n\n",s.luck or 0,weights.common,weights.rare,weights.epic)..(#descriptions>0 and table.concat(descriptions,"\n\n")or"아직 선택한 증강이 없습니다.")
        if s.lobby then build.Visible=false end
        if s.lobby then returning=false;returnButton.Text='도전 중단 · 로비'end
        deps.input.SetBasicBlocked(s.lobby==true or s.over==true or s.offers~=nil or s.paused==true)
        title.Text=s.phase=="boss" and "DRAGON / 시간 제한 없음" or "SURVIVAL / 드래곤 등장까지"
        bossPanel.Visible=(s.boss~=nil or s.fieldBoss~=nil)and not s.over and not s.lobby
        bossHealth.BackgroundColor3=s.boss and Color3.fromRGB(187,110,255)or palette.gold
        if s.fieldBoss and not s.boss then local f=s.fieldBoss;bossHealth.Size=UDim2.fromScale(math.clamp(f.hp/f.maxHp,0,1),1);bossTitle.Text=string.format("%s · %d / %d",f.name,math.ceil(f.hp),f.maxHp)end
        if s.boss then
            bossHealth.Size=UDim2.fromScale(math.clamp(s.boss.hp/s.boss.maxHp,0,1),1)
            bossTitle.Text=string.format("흑염룡 · 아그니스 · %d단계 · %d / %d",s.boss.stage or 1,math.ceil(s.boss.hp),s.boss.maxHp)..(s.boss.airborne and " · 비행 중" or "")
        end
		timer.Text=s.phase=="boss" and "∞" or string.format("%02d:%02d",math.floor(s.time/60),s.time%60)
		health.Size=UDim2.fromScale(math.clamp(s.hp/s.maxHp,0,1),1)
		xp.Size=UDim2.fromScale(math.clamp(s.xp/s.need,0,1),1)
		info.Text=string.format("Lv.%d  체력 %d/%d  처치 %d",s.level,s.hp,s.maxHp,s.kills)
        xpInfo.Text=string.format("경험치 %d/%d",s.xp,s.need)
		local text={"골렘 "..s.golem}; if s.fire>0 then table.insert(text,"화염탄 "..s.fire)end; if s.lightning>0 then table.insert(text,"번개 "..s.lightning) end; if s.ice>0 then table.insert(text,"얼음 "..s.ice) end
		if (s.meteor or 0)>0 then table.insert(text,"메테오 "..s.meteor)end
		for _,v in ipairs({{"blades","결정"},{"frost","서리"},{"ward","결계"},{"missile","마탄"},{"skyLances","천공"},{"lightRing","광륜"}})do if (s[v[1]] or 0)>0 then table.insert(text,v[2].." "..s[v[1]])end end
		local lines={}
		for i=1,#text,3 do table.insert(lines,table.concat(text," · ",i,math.min(i+2,#text)))end
		skills.Text=table.concat(lines,"\n")
		local activeName=s.activeName or "빙하 쇄도"
		pulse.Text=activeName.."\n"..(s.cooldown>0 and s.cooldown.."초" or "[Q] 준비")
		local dashCd=s.dashCooldown or 0
		dashButton.Text=dashCd>0 and "대시 [E]\n"..string.format("%.1f초",dashCd) or "대시 [E]\n준비"
		dashButton.BackgroundColor3=dashCd>0 and Color3.fromRGB(87,119,143) or Color3.fromRGB(135,203,255)
		golemStatus.Text=(s.golemCooldown or 0)>0 and "대지 강타 · 자동 · "..s.golemCooldown.."초" or "대지 강타 · 자동 · 적 탐색 중"
		if (s.shield or 0)>0 then golemStatus.Text="수호 결계 "..math.ceil(s.shield).." · "..golemStatus.Text end
		pulse.BackgroundColor3=s.cooldown>0 and Color3.fromRGB(101,131,139) or palette.mint
		overlay.Visible=s.offers~=nil and not s.over
		if s.offers then
			local ids={}; for _,v in ipairs(s.offers) do table.insert(ids,v.id..v.level) end
			local key=tostring(s.offerRevision or s.level)..table.concat(ids)
            offerRevision=s.offerRevision or 0
			if key~=lastChoice then waiting=false; lastChoice=key end
			local odds=s.offerOdds or {common=100,rare=0,epic=0}
            luckInfo.Text=string.format("행운 +%d · 첫 무작위 칸: 일반 %.1f%% / 희귀 %.1f%% / 영웅 %.1f%%\n다음 칸은 선택된 카드 제외 후 재계산 · 단계 강화 1장 보장(가능 시)",s.luck or 0,odds.common,odds.rare,odds.epic)
            reroll.Text=string.format("무료 새로고침 · %d회",s.rerolls or 0);reroll.Active=(s.rerolls or 0)>0;reroll.TextColor3=reroll.Active and palette.mint or palette.muted
            modalHint.Text=s.paused and "전투 일시 정지 · 하나를 선택하세요" or "선택하는 동안 보호됩니다 · 하나를 선택하세요"
			for i,v in ipairs(buttons) do
				local offer=s.offers[i]; v.button.Visible=offer~=nil
				if offer then v.button:SetAttribute("ChoiceId",offer.id); v.tag.Text=(rarityNames[offer.rarity]or"일반").." · "..offer.tag.."  /  "..offer.level..(offer.kind=="level"and"단계"or"회");v.tag.TextColor3=rarityColors[offer.rarity]or palette.mint;if v.border then v.border.Color=v.tag.TextColor3;v.border.Thickness=offer.rarity=="epic"and 2 or 1 end; v.name.Text=offer.title; v.desc.Text=offer.desc;icons.Apply(v.image,offer.id,v.fallback);v.fallback.TextColor3=v.tag.TextColor3 end
			end
		else waiting=false; lastChoice="" end
	end)

	gui.Destroying:Connect(function()resizeConnection:Disconnect();stateConnection:Disconnect()end)
	return {
		Gui = gui,
	}
end
