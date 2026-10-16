-- Native editable GUI, offers and state rendering.
return function(deps)
	local player, net = deps.player, deps.net
	local theme = require(script.Parent.Parent:WaitForChild("Theme"))
	local palette, make, round, stroke, label = theme.Palette, theme.Make, theme.Round, theme.Stroke, theme.Label
	local gui=Instance.new("ScreenGui"); gui.Name="SummonerHUD"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=player:WaitForChild("PlayerGui")
	local top=make("Frame",gui,{Name="TopPanel",Size=UDim2.new(.92,0,0,100),Position=UDim2.new(.5,0,0,12),AnchorPoint=Vector2.new(.5,0),BackgroundColor3=palette.bg,BackgroundTransparency=.08})
	make("UISizeConstraint",top,{MaxSize=Vector2.new(680,100)}); round(top); stroke(top)
	local title=label(top,"SUMMONER  /  SURVIVAL",UDim2.new(.65,0,0,28),UDim2.new(0,16,0,8),Enum.Font.GothamBold,palette.mint); title.TextXAlignment=Enum.TextXAlignment.Left; title.TextSize=14
	local timer=label(top,"03:00",UDim2.new(.25,-16,0,30),UDim2.new(.75,0,0,7),Enum.Font.GothamBold); timer.TextSize=24; timer.TextXAlignment=Enum.TextXAlignment.Right
	local healthBack=make("Frame",top,{Size=UDim2.new(1,-32,0,10),Position=UDim2.new(0,16,0,44),BackgroundColor3=Color3.fromRGB(49,48,59),BorderSizePixel=0}); round(healthBack,5)
	local health=make("Frame",healthBack,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(249,117,133),BorderSizePixel=0}); round(health,5)
	local info=label(top,"LV.1     체력 100 / 100",UDim2.new(1,-32,0,24),UDim2.new(0,16,0,56),nil,palette.muted); info.TextSize=13; info.TextXAlignment=Enum.TextXAlignment.Left
	local xpBack=make("Frame",top,{Size=UDim2.new(1,-32,0,5),Position=UDim2.new(0,16,0,86),BackgroundColor3=Color3.fromRGB(38,63,67),BorderSizePixel=0}); round(xpBack,3)
	local xp=make("Frame",xpBack,{Size=UDim2.fromScale(0,1),BackgroundColor3=palette.mint,BorderSizePixel=0}); round(xp,3)
	local hint=label(gui,"우클릭 드래그: 시점 회전 · 휠: 확대/축소",UDim2.new(.9,0,0,24),UDim2.new(.5,0,0,120),nil,palette.text); hint.AnchorPoint=Vector2.new(.5,0); hint.TextSize=14
	local bottom=make("Frame",gui,{Size=UDim2.new(.64,0,0,54),Position=UDim2.new(.5,0,1,-18),AnchorPoint=Vector2.new(.5,1),BackgroundColor3=palette.bg,BackgroundTransparency=.08}); round(bottom); stroke(bottom); make("UISizeConstraint",bottom,{MaxSize=Vector2.new(550,54)})
	local skills=label(bottom,"화염탄 Lv.1  ·  골렘 Lv.1",UDim2.new(1,-20,1,0),UDim2.new(0,10,0,0)); skills.TextSize=14
	local golemStatus=label(gui,"골렘 대지 강타: 자동",UDim2.new(.64,0,0,22),UDim2.new(.5,0,1,-78),nil,palette.gold); golemStatus.AnchorPoint=Vector2.new(.5,1); golemStatus.TextSize=13
	local pulse=make("TextButton",gui,{Name="Pulse",Size=UDim2.fromOffset(108,72),Position=UDim2.new(1,-20,1,-88),AnchorPoint=Vector2.new(1,1),BackgroundColor3=palette.mint,TextColor3=palette.bg,Text="화염 파동\n[Q] 준비",Font=Enum.Font.GothamBold,TextSize=17,AutoButtonColor=true}); round(pulse,16)
	local dashButton=make("TextButton",gui,{Name="Dash",Size=UDim2.fromOffset(108,58),Position=UDim2.new(1,-20,1,-18),AnchorPoint=Vector2.new(1,1),BackgroundColor3=Color3.fromRGB(135,203,255),TextColor3=palette.bg,Text="대시 [E]\n준비",Font=Enum.Font.GothamBold,TextSize=15,AutoButtonColor=true});round(dashButton,14)
	local function layoutActions()
		local compact=workspace.CurrentCamera.ViewportSize.X<600
		bottom.Size=compact and UDim2.new(.56,0,0,54) or UDim2.new(.64,0,0,54)
		bottom.Position=UDim2.new(compact and .34 or .5,0,1,-18)
		skills.TextSize=compact and 11 or 14
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
	local again=make("TextButton",ending,{Name="Restart",Size=UDim2.fromOffset(220,58),Position=UDim2.fromScale(.5,.65),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=palette.mint,TextColor3=palette.bg,Text="다시 도전",Font=Enum.Font.GothamBold,TextSize=20,ZIndex=21}); round(again)
	again.Activated:Connect(function() net.Action:FireServer("restart") end)
	pulse.Activated:Connect(deps.input.FireWave)
	dashButton.Activated:Connect(deps.input.Dash)
	local lastChoice=""
	net.State.OnClientEvent:Connect(function(s)
		timer.Text=string.format("%02d:%02d",math.floor(s.time/60),s.time%60)
		health.Size=UDim2.fromScale(math.clamp(s.hp/s.maxHp,0,1),1)
		xp.Size=UDim2.fromScale(math.clamp(s.xp/s.need,0,1),1)
		info.Text=string.format("LV.%d    체력 %d / %d    경험치 %d / %d    처치 %d",s.level,s.hp,s.maxHp,s.xp,s.need,s.kills)
		local text={"화염탄 "..s.fire,"골렘 "..s.golem}; if s.lightning>0 then table.insert(text,"번개 "..s.lightning) end; if s.ice>0 then table.insert(text,"얼음 "..s.ice) end
		skills.Text=table.concat(text,"  ·  ")
		pulse.Text=s.cooldown>0 and "화염 파동\n"..s.cooldown.."초" or "화염 파동\n[Q] 준비"
		local dashCd=s.dashCooldown or 0
		dashButton.Text=dashCd>0 and "대시 [E]\n"..string.format("%.1f초",dashCd) or "대시 [E]\n준비"
		dashButton.BackgroundColor3=dashCd>0 and Color3.fromRGB(87,119,143) or Color3.fromRGB(135,203,255)
		golemStatus.Text=(s.golemCooldown or 0)>0 and "골렘 대지 강타 · 자동 · "..s.golemCooldown.."초" or "골렘 대지 강타 · 자동 · 적 무리 탐색 중"
		pulse.BackgroundColor3=s.cooldown>0 and Color3.fromRGB(101,131,139) or palette.mint
		ending.Visible=s.over==true; overlay.Visible=s.offers~=nil and not s.over
		hint.Visible=not s.over and not s.offers
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
		if s.over then resultTitle.Text=s.result=="victory" and "생존 성공!" or "다음엔 더 오래!"; resultInfo.Text=string.format("레벨 %d  ·  처치 %d\n이번에 완성한 조합으로 다시 도전해 보세요",s.level,s.kills) end
	end)

	return {
		Gui = gui,
	}
end
