-- Native editable GUI, offers and state rendering.
return function(deps)
	local player, net = deps.player, deps.net
	local theme = require(script.Parent.Parent:WaitForChild("Theme"))
	local palette, make, round, stroke, label = theme.Palette, theme.Make, theme.Round, theme.Stroke, theme.Label
	local gui=Instance.new("ScreenGui"); gui.Name="SummonerHUD"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=player:WaitForChild("PlayerGui")
	local encounter=make("Frame",gui,{Name="EncounterPanel",Size=UDim2.new(.8,0,0,26),Position=UDim2.new(1,-12,0,6),AnchorPoint=Vector2.new(1,0),BackgroundColor3=palette.bg,BackgroundTransparency=.15})
	make("UISizeConstraint",encounter,{MaxSize=Vector2.new(320,26)});round(encounter,8)
	local title=label(encounter,"SURVIVAL / 드래곤 등장까지",UDim2.new(1,-76,1,0),UDim2.fromOffset(10,0),Enum.Font.GothamBold,palette.mint);title.TextSize=11;title.TextXAlignment=Enum.TextXAlignment.Left
	local timer=label(encounter,"02:00",UDim2.fromOffset(60,26),UDim2.new(1,-70,0,0),Enum.Font.GothamBold);timer.TextSize=16;timer.TextXAlignment=Enum.TextXAlignment.Right
	local top=make("Frame",gui,{Name="PlayerPanel",Size=UDim2.fromOffset(340,116),Position=UDim2.new(0,12,1,-12),AnchorPoint=Vector2.new(0,1),BackgroundColor3=palette.bg,BackgroundTransparency=.12})
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
	local pulse=make("TextButton",gui,{Name="Pulse",Size=UDim2.fromOffset(108,72),Position=UDim2.new(1,-20,1,-88),AnchorPoint=Vector2.new(1,1),BackgroundColor3=palette.mint,TextColor3=palette.bg,Text="화염 파동\n[Q] 준비",Font=Enum.Font.GothamBold,TextSize=17,AutoButtonColor=true}); round(pulse,16)
	local dashButton=make("TextButton",gui,{Name="Dash",Size=UDim2.fromOffset(108,58),Position=UDim2.new(1,-20,1,-18),AnchorPoint=Vector2.new(1,1),BackgroundColor3=Color3.fromRGB(135,203,255),TextColor3=palette.bg,Text="대시 [E]\n준비",Font=Enum.Font.GothamBold,TextSize=15,AutoButtonColor=true});round(dashButton,14)
	local function layoutActions()
		local width=workspace.CurrentCamera.ViewportSize.X
		top.Size=UDim2.fromOffset(math.clamp(width-152,180,340),116)
		info.TextSize=width<500 and 10 or 12
		skills.TextSize=width<500 and 10 or 11
	end
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutActions);layoutActions()
	local overlay=make("Frame",gui,{Name="ChoiceOverlay",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(6,12,19),BackgroundTransparency=.18,Visible=false,ZIndex=10})
	local modal=make("Frame",overlay,{Size=UDim2.new(.88,0,.82,0),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=palette.bg,ZIndex=11}); round(modal,18); stroke(modal,palette.mint); make("UISizeConstraint",modal,{MaxSize=Vector2.new(570,480)})
	local modalTitle=label(modal,"LEVEL UP",UDim2.new(1,-32,0,32),UDim2.new(0,16,0,14),Enum.Font.GothamBold,palette.mint); modalTitle.TextSize=25; modalTitle.ZIndex=12
	local modalHint=label(modal,"이번 성장을 선택하세요",UDim2.new(1,-32,0,24),UDim2.new(0,16,0,48),nil,palette.muted); modalHint.TextSize=14; modalHint.ZIndex=12
	local cards=make("Frame",modal,{Size=UDim2.new(1,-32,1,-94),Position=UDim2.new(0,16,0,80),BackgroundTransparency=1,ZIndex=12})
	make("UIListLayout",cards,{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder})
	local buttons={}
	local waiting=false
	for i=1,3 do
		local b=make("TextButton",cards,{Name="Choice"..i,Size=UDim2.new(1,0,1/3,-7),BackgroundColor3=palette.card,Text="",LayoutOrder=i,ZIndex=13,AutoButtonColor=true}); round(b,12); stroke(b)
		local tag=label(b,"마법 강화",UDim2.new(1,-28,.25,0),UDim2.new(0,14,0,4),Enum.Font.GothamBold,palette.mint); tag.TextSize=11; tag.TextXAlignment=Enum.TextXAlignment.Left; tag.ZIndex=14
		local name=label(b,"화염탄 강화",UDim2.new(1,-28,.3,0),UDim2.new(0,14,.27,0),Enum.Font.GothamBold); name.TextSize=20; name.TextXAlignment=Enum.TextXAlignment.Left; name.ZIndex=14
		local desc=label(b,"피해량 증가",UDim2.new(1,-28,.29,0),UDim2.new(0,14,.63,0),nil,palette.muted); desc.TextSize=13; desc.TextXAlignment=Enum.TextXAlignment.Left; desc.ZIndex=14
		buttons[i]={button=b,tag=tag,name=name,desc=desc}
		b.Activated:Connect(function() if b:GetAttribute("ChoiceId") and not waiting then waiting=true; net.Action:FireServer("choose",b:GetAttribute("ChoiceId")) end end)
	end
	local ending=make("Frame",gui,{Name="Ending",Size=UDim2.fromScale(1,1),BackgroundColor3=palette.bg,BackgroundTransparency=.08,Visible=false,ZIndex=20})
	local resultTitle=label(ending,"생존 성공!",UDim2.new(.9,0,0,70),UDim2.fromScale(.5,.32),Enum.Font.GothamBold,palette.mint); resultTitle.AnchorPoint=Vector2.new(.5,.5); resultTitle.TextSize=38; resultTitle.ZIndex=21
	local resultInfo=label(ending,"",UDim2.new(.9,0,0,60),UDim2.fromScale(.5,.48),nil,palette.text); resultInfo.AnchorPoint=Vector2.new(.5,.5); resultInfo.TextSize=19; resultInfo.ZIndex=21
	local again=make("TextButton",ending,{Name="Restart",Size=UDim2.fromOffset(220,58),Position=UDim2.fromScale(.5,.65),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=palette.mint,TextColor3=palette.bg,Text="로비로 돌아가기",Font=Enum.Font.GothamBold,TextSize=20,ZIndex=21}); round(again)
	again.Activated:Connect(function() net.Action:FireServer("restart") end)
	pulse.Activated:Connect(deps.input.FireWave)
	dashButton.Activated:Connect(deps.input.Dash)
	local lastChoice=""
	net.State.OnClientEvent:Connect(function(s)
        title.Text=s.phase=="boss" and "DRAGON / 시간 제한 없음" or "SURVIVAL / 드래곤 등장까지"
        bossPanel.Visible=s.phase=="boss" and s.boss~=nil and not s.over
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
		for _,v in ipairs({{"blades","결정"},{"frost","서리"},{"ward","결계"},{"missile","마탄"},{"skyLances","천공"}})do if (s[v[1]] or 0)>0 then table.insert(text,v[2].." "..s[v[1]])end end
		local lines={}
		for i=1,#text,3 do table.insert(lines,table.concat(text," · ",i,math.min(i+2,#text)))end
		skills.Text=table.concat(lines,"\n")
		local activeName=s.activeName or "화염 파동"
		pulse.Text=activeName.."\n"..(s.cooldown>0 and s.cooldown.."초" or "[Q] 준비")
		local dashCd=s.dashCooldown or 0
		dashButton.Text=dashCd>0 and "대시 [E]\n"..string.format("%.1f초",dashCd) or "대시 [E]\n준비"
		dashButton.BackgroundColor3=dashCd>0 and Color3.fromRGB(87,119,143) or Color3.fromRGB(135,203,255)
		golemStatus.Text=(s.golemCooldown or 0)>0 and "대지 강타 · 자동 · "..s.golemCooldown.."초" or "대지 강타 · 자동 · 적 탐색 중"
		if (s.shield or 0)>0 then golemStatus.Text="수호 결계 "..math.ceil(s.shield).." · "..golemStatus.Text end
		pulse.BackgroundColor3=s.cooldown>0 and Color3.fromRGB(101,131,139) or palette.mint
		ending.Visible=s.over==true; overlay.Visible=s.offers~=nil and not s.over
		if s.offers then
			local ids={}; for _,v in ipairs(s.offers) do table.insert(ids,v.id..v.level) end
			local key=s.level..table.concat(ids)
			if key~=lastChoice then waiting=false; lastChoice=key end
			modalHint.Text=s.paused and "전투 일시 정지 · 하나를 선택하세요" or "선택하는 동안 보호됩니다 · 하나를 선택하세요"
			for i,v in ipairs(buttons) do
				local offer=s.offers[i]; v.button.Visible=offer~=nil
				if offer then v.button:SetAttribute("ChoiceId",offer.id); v.tag.Text=offer.tag.."  /  Lv."..offer.level; v.name.Text=offer.title; v.desc.Text=offer.desc end
			end
		else waiting=false; lastChoice="" end
		if s.over then resultTitle.Text=s.result=="victory" and "드래곤 격파!" or "다시 도전!"; resultInfo.Text=string.format("레벨 %d  ·  처치 %d\n이번에 완성한 조합으로 다시 도전해 보세요",s.level,s.kills) end
	end)

	return {
		Gui = gui,
	}
end
