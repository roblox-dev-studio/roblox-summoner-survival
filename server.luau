local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
Players.CharacterAutoLoads = false
local net = RS:WaitForChild("SummonerNet")
local update, action, effect = net.State, net.Action, net.Effect
local world = Instance.new("Folder"); world.Name="SummonerRuntime"; world.Parent=workspace
local enemies, gems, states = {}, {}, {}
local iceShots = {}
local nextIceShot = 0
local elapsed, spawnClock, sendClock, tickClock = 0, 0, 0, 0
local roundLength, nextEnemy = 180, 0
local rng = Random.new()
local starting = false
local finishDash
-- Temporary visual preview: all golems show the final-tier presentation.
-- Damage, fragment damage and extra damage hits still use the actual upgrade level.
local PREVIEW_MAX_GOLEM_EFFECTS = true

local function block(parent, name, size, pos, color, material)
	local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=CFrame.new(pos)
	p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
	p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Parent=parent
	return p
end
local function creature(name, color, golem)
	local m=Instance.new("Model"); m.Name=name
	local size=golem and 1.2 or 0.85
	local root=block(m,"Core",Vector3.new(2.6,2.5,1.8)*size,Vector3.new(0,3,0),color,Enum.Material.Slate)
	m.PrimaryPart=root
	block(m,"Head",Vector3.new(1.9,1.5,1.6)*size,Vector3.new(0,5.1*size,0),color,Enum.Material.Slate)
	for _,side in ipairs({-1,1}) do
		block(m,golem and (side==-1 and "LeftArm" or "RightArm") or "Arm",Vector3.new(1,2.5,1.2)*size,Vector3.new(side*1.9*size,2.8*size,0),color,Enum.Material.Slate)
		block(m,"Leg",Vector3.new(1,1.8,1.3)*size,Vector3.new(side*.72*size,.9*size,0),color,Enum.Material.Slate)
		block(m,"Eye",Vector3.new(.3,.25,.12),Vector3.new(side*.45*size,5.25*size,-.85*size),golem and Color3.fromRGB(96,255,222) or Color3.fromRGB(255,112,115),Enum.Material.Neon)
	end
	block(m,"Rune",Vector3.new(.65,.8,.12),Vector3.new(0,3*size,-.96*size),golem and Color3.fromRGB(96,255,222) or Color3.fromRGB(215,70,104),Enum.Material.Neon)
	m.Parent=world
	return m
end
local function rootOf(s)
	local c=s.player.Character
	local h=c and c:FindFirstChildOfClass("Humanoid")
	local r=c and c:FindFirstChild("HumanoidRootPart")
	if h and r and h.Health>0 and not s.over then return r,h end
end
local function liveCount()
	local n=0; for _,s in pairs(states) do if rootOf(s) then n+=1 end end; return n
end
local function paused()
	if liveCount()~=1 then return false end
	for _,s in pairs(states) do if rootOf(s) and s.offers then return true end end
	return false
end
local function need(s) return 5+(s.level-1)*3 end
local labels={fire="화염탄",lightning="연쇄 번개",ice="빙결 얼음창",golem="골렘"}
local function choices(s)
	local pool={}
	for _,id in ipairs({"fire","lightning","ice","golem"}) do
		local lv=s[id]
		if lv<5 then
			local description
			if id=="fire" then description="피해량 +8 · 폭발 범위 증가"
			elseif id=="lightning" then description=lv==0 and "주변 적을 연결하는 번개를 자동 발사" or "피해량과 연쇄 타격 수 증가"
			elseif id=="ice" then description=lv==0 and "얼음창 자동 발사 · 적을 밀쳐내고 빙결" or "피해량과 빙결·둔화 지속시간 증가"
			else
				description=lv==2 and "대지 강타에 바위 파편 추가 · 피해와 범위 증가" or (lv==4 and "대지 강타를 두 번 연속 사용 · 피해와 범위 증가" or "내려찍기와 대지 강타의 피해·범위 증가")
			end
			table.insert(pool,{id=id,title=labels[id]..(lv==0 and " 배우기" or " 강화"),desc=description,tag=lv==0 and "새로운 마법" or (id=="golem" and "소환수 강화" or "마법 강화"),level=lv+1})
		end
	end
	local fallback={
		{id="vitality",title="생명의 축복",desc="최대 체력 +15 · 체력 30 회복",tag="생존 강화",level=s.vitality+1},
		{id="agility",title="바람의 발걸음",desc="이동 속도 +2",tag="생존 강화",level=s.agility+1},
		{id="magnet",title="경험치 자석",desc="경험치를 끌어오는 범위 +3",tag="수집 강화",level=s.magnet+1},
	}
	for _,v in ipairs(fallback) do if #pool>=3 then break end; table.insert(pool,v) end
	for i=#pool,2,-1 do local j=rng:NextInteger(1,i); pool[i],pool[j]=pool[j],pool[i] end
	local result={}; for i=1,math.min(3,#pool) do result[i]=pool[i] end
	return result
end
local function sync(s)
	local _,h=rootOf(s)
	update:FireClient(s.player,{time=math.max(0,roundLength-math.floor(elapsed)),level=s.level,xp=s.xp,need=need(s),hp=h and math.ceil(h.Health) or 0,maxHp=h and h.MaxHealth or 100,
		kills=s.kills,fire=s.fire,lightning=s.lightning,ice=s.ice,golem=s.golem,offers=s.offers,over=s.over,result=s.result,cooldown=math.max(0,math.ceil(s.cooldown)),dashCooldown=math.ceil((s.dashCooldown or 0)*10)/10,golemCooldown=math.max(0,math.ceil(s.petHeavyCooldown or 0)),paused=paused()})
end
local function levelCheck(s)
	if s.over or s.offers then return end
	if s.xp>=need(s) then
		s.xp-=need(s); s.level+=1; s.offers=choices(s)
		if finishDash then finishDash(s) end
		local _,h=rootOf(s); if h then h.WalkSpeed=0 end
		sync(s)
	end
end
local function drop(pos)
	if #gems>=180 then return end
	local p=block(world,"Experience",Vector3.new(.8,.8,.8),Vector3.new(pos.X,1.1,pos.Z),Color3.fromRGB(72,250,212),Enum.Material.Neon)
	p.CFrame*=CFrame.Angles(0,math.pi/4,math.pi/4)
	table.insert(gems,{part=p,pos=p.Position})
end
local function damage(e,amount,s)
	if e.hp<=0 then return end
	e.hp-=amount
	e.model:SetAttribute("HP",math.max(0,e.hp))
	effect:FireAllClients("hit",e.pos,amount)
	if e.hp<=0 then
		s.kills+=1; drop(e.pos); e.model:Destroy()
	end
end
local function nearest(pos,range)
	local found,dist=nil,range
	for _,e in ipairs(enemies) do if e.hp>0 then local d=(e.pos-pos).Magnitude; if d<dist then found,dist=e,d end end end
	return found
end
local function clearIceShots(source)
	for i=#iceShots,1,-1 do
		local shot=iceShots[i]
		if not source or shot.source==source then shot.anchor:Destroy();table.remove(iceShots,i) end
	end
end
local function castIceSpear(s,root,target)
	local delta=Vector3.new(target.pos.X-root.Position.X,0,target.pos.Z-root.Position.Z)
	local forward=delta.Magnitude>.01 and delta.Unit or Vector3.new(0,0,-1)
	local portalPos=root.Position+forward*3.5+Vector3.new(0,1.2,0)
	local portal=CFrame.lookAt(portalPos,portalPos+forward)
	nextIceShot+=1
	local anchor=block(world,"IceSpearAnchor_"..nextIceShot,Vector3.new(.1,.1,.1),portalPos,Color3.fromRGB(170,237,255))
	anchor.Transparency=1;anchor.CFrame=portal
	anchor:SetAttribute("Launched",false)
	table.insert(iceShots,{source=s,target=target,anchor=anchor,time=0,charge=.42,speed=36,level=s.ice})
	effect:FireAllClients("iceCast",anchor.Name,portal,.42)
end
local function advanceIceSpears(dt)
	for i=#iceShots,1,-1 do
		local shot=iceShots[i]
		local alive=rootOf(shot.source)
		local remove=not alive or not shot.anchor.Parent
		if not remove and not shot.source.offers then
			shot.time+=dt
			if shot.target.hp<=0 then shot.target=nearest(shot.anchor.Position,46) end
			if not shot.target or shot.time>2.8 then remove=true
			elseif shot.time>=shot.charge then
				shot.anchor:SetAttribute("Launched",true)
				local travelDt=math.min(dt,shot.time-shot.charge)
				local delta=shot.target.pos-shot.anchor.Position
				local step=shot.speed*travelDt
				if delta.Magnitude<=step+1 then
					local target=shot.target;local pos=target.pos
					local duration=.55+shot.level*.1
					target.frozen=math.max(target.frozen or 0,duration)
					target.slow=math.max(target.slow,2+shot.level*.4)
					target.model:SetAttribute("Frozen",true)
					damage(target,10+shot.level*8,shot.source)
					if target.hp>0 then
						local forward=shot.anchor.CFrame.LookVector
						local flat=Vector3.new(forward.X,0,forward.Z)
						if flat.Magnitude>.01 then target.knockback=flat.Unit*34;target.knockTime=.23 end
					end
					effect:FireAllClients("iceHit",target.hp>0 and target.model or nil,pos,duration)
					remove=true
				else
					local move=delta.Unit*step
					local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={world,shot.source.player.Character};params.RespectCanCollide=true
					local hit=workspace:Raycast(shot.anchor.Position,move,params)
					if hit then effect:FireAllClients("iceHit",nil,hit.Position,.4);remove=true
					else shot.anchor.CFrame=CFrame.lookAt(shot.anchor.Position+move,shot.target.pos) end
				end
			end
		end
		if remove then if shot.anchor.Parent then shot.anchor:Destroy() end;table.remove(iceShots,i) end
	end
end
local function blast(pos,radius,amount,s,knock,slow)
	for _,e in ipairs(enemies) do
		if e.hp>0 and (e.pos-pos).Magnitude<=radius then
			damage(e,amount,s)
			if e.hp>0 then
				if slow then e.slow=math.max(e.slow,slow) end
				if knock and knock>0 then
					local dir=Vector3.new(e.pos.X-pos.X,0,e.pos.Z-pos.Z)
					if dir.Magnitude>.01 then e.pos+=dir.Unit*knock end
					local flat=Vector3.new(e.pos.X,0,e.pos.Z)
					if flat.Magnitude>82 then e.pos=flat.Unit*82+Vector3.new(0,e.pos.Y,0) end
				end
			end
		end
	end
end
local function beginGolemAttack(s,heavy,repeatStrike)
	if heavy and not repeatStrike then s.petHeavyCooldown=9; s.petSlamTarget=nil; s.petSlamPoint=nil end
	s.petHand=not s.petHand
	s.petAttack={time=0,heavy=heavy,windup=heavy and (repeatStrike and .3 or .65) or .3,hit=false,hand=s.petHand,repeatStrike=repeatStrike,visualOnly=repeatStrike and PREVIEW_MAX_GOLEM_EFFECTS and s.golem<5}
	if heavy then effect:FireAllClients("golemCharge",s.pet,s.petAttack.windup) end
	s.golemClock=heavy and 1.8 or 1.5
end
local function planGolemSlam(s,ownerPos,petPos,dt)
	s.petHeavyCooldown=math.max(0,(s.petHeavyCooldown or 0)-dt)
	if s.petHeavyCooldown>0 or s.petReturning then s.petSlamTarget=nil; s.petSlamPoint=nil; return end
	if s.petAttack then return end
	s.petScanClock=(s.petScanClock or 0)-dt
	if s.petScanClock>0 then return end
	s.petScanClock=.35
	local danger=0
	for _,e in ipairs(enemies) do if e.hp>0 and (e.pos-ownerPos).Magnitude<10 then danger+=1 end end
	local best,bestPoint,bestScore=nil,nil,-math.huge
	local radius=(11+s.golem)*.75
	for _,candidate in ipairs(enemies) do
		local ownerDistance=(candidate.pos-ownerPos).Magnitude
		local petDistance=(candidate.pos-petPos).Magnitude
		if candidate.hp>0 and ownerDistance<44 and petDistance<32 then
			local count,total=0,Vector3.zero
			for _,e in ipairs(enemies) do
				if e.hp>0 and (e.pos-candidate.pos).Magnitude<radius then count+=1; total+=e.pos end
			end
			local emergency=danger>=3 and ownerDistance<12
			if count>=3 or emergency or candidate.model:GetAttribute("IsBoss")==true then
				local score=count*100-petDistance-ownerDistance*.2+(emergency and 200 or 0)+(candidate==s.petSlamTarget and 20 or 0)
				if score>bestScore then best,bestPoint,bestScore=candidate,total/count,score end
			end
		end
	end
	s.petSlamTarget=best
	s.petSlamPoint=bestPoint and Vector3.new(bestPoint.X,3.6,bestPoint.Z) or nil
end
local function poseGolem(s)
	local pivot=s.pet:GetPivot()
	local attack=s.petAttack
	local raised,impact=0,0
	if attack then
		local t=attack.time
		if t<attack.windup then
			raised=math.clamp(t/attack.windup,0,1)
		elseif t<attack.windup+.12 then
			impact=math.clamp((t-attack.windup)/.12,0,1); raised=1-impact
		else
			impact=1-math.clamp((t-attack.windup-.12)/.38,0,1)
		end
	end
	for part,rest in pairs(s.petRig) do
		if part.Parent and part~=s.pet.PrimaryPart then
			local cf=rest
			if part.Name=="LeftArm" or part.Name=="RightArm" then
				local active=attack and (attack.heavy or (attack.hand and part.Name=="RightArm") or (not attack.hand and part.Name=="LeftArm"))
				if active then
					local side=part.Name=="LeftArm" and -1 or 1
					local raisedPose=CFrame.new(side*2.1,3.3,-.65)*CFrame.Angles(math.rad(155),0,side*math.rad(-12))
					local impactPose=CFrame.new(side*(attack.heavy and 1.7 or 2),-1.7,-2.1)*CFrame.Angles(math.rad(25),0,0)
					cf=rest:Lerp(raisedPose,raised):Lerp(impactPose,impact)
				end
			elseif part.Name=="Head" then cf=rest*CFrame.new(0,-impact*.35,0) end
			part.CFrame=pivot*cf
		end
	end
	local rune=s.pet:FindFirstChild("Rune")
	if rune then rune.Color=attack and attack.heavy and Color3.fromRGB(255,204,104) or Color3.fromRGB(96,255,222) end
	s.pet:SetAttribute("AttackPhase",attack and (attack.hit and "Recover" or "Windup") or "Idle")
end
local function advanceGolemAttack(s,dt)
	local attack=s.petAttack
	if not attack then return end
	attack.time+=dt
	-- Resolve the hit when the fist reaches the ground, on the simulation clock.
	if not attack.hit and attack.time>=attack.windup+.12 then
		attack.hit=true
		local pivot=s.pet:GetPivot()
		local pos=pivot.Position+(attack.heavy and Vector3.zero or pivot.LookVector*2.5)
		local radius=attack.heavy and 11+s.golem or 4+s.golem*.5
		local effectLevel=PREVIEW_MAX_GOLEM_EFFECTS and 5 or s.golem
		local effectRadius=attack.heavy and 11+effectLevel or 4+effectLevel*.5
		effect:FireAllClients(attack.heavy and "golemHeavy" or "golemLight",pos,effectRadius,effectLevel)
		if not attack.visualOnly then blast(pos,radius,attack.heavy and 22+s.golem*10 or 12+s.golem*8,s,attack.heavy and 10 or nil,attack.heavy and 2 or nil) end
		if attack.heavy and s.golem>=3 and not attack.visualOnly then
			for i=1,6 do
				local a=i*math.pi/3
				local fragment=pos+Vector3.new(math.cos(a),0,math.sin(a))*radius*.75
				blast(fragment,2.8,8+s.golem*2,s,nil,1)
			end
		end
		s.pet:SetAttribute("LastImpactPosition",pos)
		s.pet:SetAttribute("LastImpactHeavy",attack.heavy)
		s.pet:SetAttribute("ImpactCount",(s.pet:GetAttribute("ImpactCount") or 0)+1)
	end
	if attack.time>=attack.windup+.5 then
		if attack.heavy and (s.golem>=5 or PREVIEW_MAX_GOLEM_EFFECTS) and not attack.repeatStrike then beginGolemAttack(s,true,true)
		else s.petAttack=nil end
	end
end
finishDash=function(s)
	if not s.dash then return end
	s.dash=nil
	local char=s.player.Character
	local r=char and char:FindFirstChild("HumanoidRootPart")
	local h=char and char:FindFirstChildOfClass("Humanoid")
	if r then pcall(function() r:SetNetworkOwnershipAuto() end) end
	if h then h.AutoRotate=true;h.WalkSpeed=(s.over or s.offers) and 0 or 22+s.agility*2 end
end
local function advanceDash(s,dt)
	s.dashCooldown=math.max(0,(s.dashCooldown or 0)-dt)
	s.invulnerable=math.max(0,(s.invulnerable or 0)-dt)
	local dash=s.dash;if not dash then return end
	local r=rootOf(s)
	if not r or s.offers then finishDash(s);return end
	local step=64*math.min(dt,dash.remaining)
	local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={s.player.Character,world};params.RespectCanCollide=true
	local hit=workspace:Blockcast(r.CFrame,Vector3.new(2.8,4,2.8),dash.direction*step,params)
	if hit then step=math.max(0,hit.Distance-.15) end
	local dest=r.Position+dash.direction*step
	local flat=Vector3.new(dest.X,0,dest.Z)
	local boundary=flat.Magnitude>81
	if boundary then dest=flat.Unit*81+Vector3.new(0,dest.Y,0) end
	r.CFrame=CFrame.lookAt(dest,dest+dash.direction)
	r.AssemblyLinearVelocity=Vector3.new(0,r.AssemblyLinearVelocity.Y,0)
	dash.remaining-=dt
	if dash.remaining<=0 or hit or boundary then finishDash(s) end
end
local function endPlayer(s,result)
	if s.over then return end
	s.over=true; s.result=result; s.offers=nil
	finishDash(s)
	clearIceShots(s)
	local c=s.player.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
	if h then h.WalkSpeed=0 end
	sync(s)
end
local function addPlayer(player)
	local s={player=player,level=1,xp=0,kills=0,fire=1,lightning=0,ice=0,golem=1,vitality=0,agility=0,magnet=0,cooldown=0,fireClock=0,lightningClock=0,iceClock=0,golemClock=0,over=false}
	states[player]=s
	s.pet=creature(player.Name.."_Golem",Color3.fromRGB(95,112,120),true)
	s.petRig={}
	for _,part in ipairs(s.pet:GetChildren()) do if part:IsA("BasePart") then s.petRig[part]=s.pet:GetPivot():ToObjectSpace(part.CFrame) end end
	player:LoadCharacterAsync()
	local character=player.Character
	if states[player]~=s or not character then return end
	local root=character:WaitForChild("HumanoidRootPart")
	root.CFrame=CFrame.new(rng:NextNumber(-4,4),4,rng:NextNumber(-4,4))
	s.pet:PivotTo(CFrame.new(root.Position.X+5,3.6,root.Position.Z+4))
	local humanoid=character:WaitForChild("Humanoid")
	humanoid.WalkSpeed=22; humanoid.MaxHealth=100; humanoid.Health=100
	humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
	humanoid.Died:Connect(function() if states[player]==s then endPlayer(s,"defeat") end end)
	sync(s)
end
local function restart()
	if starting then return end
	starting=true
	for _,s in pairs(states) do if not s.over then starting=false; return end end
	world:ClearAllChildren(); table.clear(enemies); table.clear(gems); table.clear(states)
	table.clear(iceShots)
	elapsed=0; spawnClock=0
	for _,p in ipairs(Players:GetPlayers()) do task.spawn(addPlayer,p) end
	starting=false
end
action.OnServerEvent:Connect(function(player,kind,id)
	local s=states[player]; if not s then return end
	if kind=="ready" then sync(s); return end
	if kind=="restart" then if s.over then restart() end; return end
	if s.over then return end
	if kind=="choose" then
		if not s.offers or type(id)~="string" then return end
		local valid=false; for _,v in ipairs(s.offers) do if v.id==id then valid=true; break end end
		if not valid then return end
		if id=="vitality" then
			s.vitality+=1; local _,h=rootOf(s); if h then h.MaxHealth+=15; h.Health=math.min(h.MaxHealth,h.Health+30) end
		else s[id]+=1 end
		s.offers=nil
		local _,h=rootOf(s); if h then h.WalkSpeed=22+s.agility*2 end
		levelCheck(s); sync(s)
	elseif kind=="dash" and (s.dashCooldown or 0)<=0 and not s.offers and not paused() then
		local root,h=rootOf(s);if not root then return end
		local facing=root.CFrame.LookVector
		if typeof(id)=="Vector3" and id.X==id.X and id.Z==id.Z and math.abs(id.X)<10000 and math.abs(id.Z)<10000 then facing=id end
		local direction=Vector3.new(facing.X,0,facing.Z)
		if direction.Magnitude<.01 then direction=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z) end
		if direction.Magnitude<.01 then direction=Vector3.new(0,0,-1) else direction=direction.Unit end
		s.dashCooldown=3;s.invulnerable=.28;s.dash={direction=direction,remaining=.23}
		h.WalkSpeed=0;h.AutoRotate=false
		pcall(function()root:SetNetworkOwner(nil)end)
		effect:FireAllClients("dash",player.Character,.23,direction)
		sync(s)
	elseif kind=="fireWave" and s.cooldown<=0 and not s.offers and not paused() then
		local root=rootOf(s); if not root then return end
		s.cooldown=7
		local origin=root.Position
		local facing=root.CFrame.LookVector
		local direction=Vector3.new(facing.X,0,facing.Z)
		if direction.Magnitude<.01 then direction=Vector3.new(0,0,-1) else direction=direction.Unit end
		effect:FireAllClients("fireWave",origin,direction,30)
		for _,e in ipairs(enemies) do
			local delta=Vector3.new(e.pos.X-origin.X,0,e.pos.Z-origin.Z)
			local distance=delta.Magnitude
			if e.hp>0 and distance<=30 and (distance<.1 or delta.Unit:Dot(direction)>=math.cos(math.rad(35))) then
				damage(e,40+s.fire*10,s)
				if e.hp>0 then
					e.pos+=direction*5; e.slow=math.max(e.slow,.7)
					local flat=Vector3.new(e.pos.X,0,e.pos.Z)
					if flat.Magnitude>82 then e.pos=flat.Unit*82+Vector3.new(0,e.pos.Y,0) end
				end
			end
		end
		sync(s)
	end
end)
Players.PlayerAdded:Connect(function(p) task.spawn(addPlayer,p) end)
Players.PlayerRemoving:Connect(function(p)
	local s=states[p]; if s and s.pet then s.pet:Destroy() end; states[p]=nil
	if s then clearIceShots(s) end
	if next(states)==nil then world:ClearAllChildren(); table.clear(enemies); table.clear(gems); elapsed=0 end
end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(addPlayer,p) end

RunService.Heartbeat:Connect(function(dt)
	tickClock+=dt; if tickClock<.05 then return end
	dt=math.min(tickClock,.15); tickClock=0
	local alive=liveCount()
	local pause=paused()
	if alive>0 and not pause then
		elapsed+=dt; spawnClock-=dt
		if elapsed>=roundLength then for _,s in pairs(states) do if not s.over then endPlayer(s,"victory") end end end
		if spawnClock<=0 and #enemies<65 and elapsed<roundLength then
			spawnClock=math.max(.28,1.1-elapsed*.004)/math.max(1,alive*.65)
			local a=rng:NextNumber(0,math.pi*2); local pos=Vector3.new(math.cos(a)*77,2.8,math.sin(a)*77)
			nextEnemy+=1
			local m=creature("Shade_"..nextEnemy,Color3.fromRGB(82,69,105),false)
			m:PivotTo(CFrame.new(pos)); m:SetAttribute("HP",26+math.floor(elapsed/20)*7)
			table.insert(enemies,{model=m,pos=pos,hp=26+math.floor(elapsed/20)*7,speed=9+math.min(5,elapsed/35),hitClock=0,slow=0})
		end
		for _,s in pairs(states) do advanceDash(s,dt) end
		advanceIceSpears(dt)
		for i=#enemies,1,-1 do
			local e=enemies[i]
			if e.hp<=0 then table.remove(enemies,i) else
				local target,dist=nil,math.huge
				for _,s in pairs(states) do local r=rootOf(s); if r then local d=(r.Position-e.pos).Magnitude; if d<dist then target,dist=s,d end end end
				if target then
					if (e.knockTime or 0)>0 then
						local step=math.min(dt,e.knockTime)
						e.pos+=e.knockback*step;e.knockback*=math.exp(-step*4);e.knockTime-=step
						local flat=Vector3.new(e.pos.X,0,e.pos.Z)
						if flat.Magnitude>82 then local bounded=flat.Unit*82;e.pos=Vector3.new(bounded.X,e.pos.Y,bounded.Z)end
					end
					local r,h=rootOf(target); local diff=Vector3.new(r.Position.X-e.pos.X,0,r.Position.Z-e.pos.Z)
					e.slow=math.max(0,e.slow-dt); e.hitClock=math.max(0,e.hitClock-dt)
					e.frozen=math.max(0,(e.frozen or 0)-dt)
					e.model:SetAttribute("Frozen",e.frozen>0)
					if diff.Magnitude>2.5 and e.frozen<=0 then e.pos+=diff.Unit*math.min(diff.Magnitude-2.5,e.speed*(e.slow>0 and .45 or 1)*dt) end
					if diff.Magnitude>.01 then e.model:PivotTo(CFrame.lookAt(e.pos,e.pos+diff.Unit)) end
					if dist<4 and e.hitClock<=0 and e.frozen<=0 and (target.invulnerable or 0)<=0 and not target.offers then h:TakeDamage(8); e.hitClock=.85 end
				end
			end
		end
		for _,s in pairs(states) do
			local r=rootOf(s)
			if r then
				local flat=Vector3.new(r.Position.X,0,r.Position.Z)
				if flat.Magnitude>82 then r.CFrame=CFrame.new(flat.Unit*81+Vector3.new(0,r.Position.Y,0)) end
				if r.Position.Y < -10 then endPlayer(s,"defeat") end
				-- The golem commits to its own target instead of staying at an owner offset.
				local old=s.pet:GetPivot().Position
				local ownerPos=Vector3.new(r.Position.X,3.6,r.Position.Z)
				local ownerDistance=(old-ownerPos).Magnitude
				if ownerDistance>52 then s.petReturning=true; s.petTarget=nil end
				if s.petReturning and ownerDistance<10 then s.petReturning=false end
				if not s.offers then planGolemSlam(s,ownerPos,old,dt) end
				if s.petSlamTarget and s.petSlamTarget.hp<=0 then s.petSlamTarget=nil; s.petSlamPoint=nil; s.petScanClock=0 end
				local petTarget=s.petTarget
				if petTarget and (petTarget.hp<=0 or (petTarget.pos-ownerPos).Magnitude>48) then petTarget=nil end
				if not s.petReturning and not petTarget then
					local best=32
					for _,e in ipairs(enemies) do
						local d=(e.pos-old).Magnitude
						if e.hp>0 and d<best and (e.pos-ownerPos).Magnitude<44 then petTarget=e; best=d end
					end
				end
				s.petTarget=petTarget
				local goal,look,speed
				if s.petSlamPoint and not s.petReturning then
					goal=s.petSlamPoint; look=goal; speed=26
				elseif petTarget then
					local targetPos=Vector3.new(petTarget.pos.X,3.6,petTarget.pos.Z)
					local diff=targetPos-old
					goal=diff.Magnitude>3.5 and targetPos-diff.Unit*3.5 or old
					look=targetPos; speed=24
				elseif s.petReturning or ownerDistance>15 then
					goal=ownerPos+Vector3.new(4,0,3); look=goal; speed=32
					s.petPatrol=nil
				else
					s.petPatrolClock=(s.petPatrolClock or 0)-dt
					if not s.petPatrol or s.petPatrolClock<=0 or (s.petPatrol-ownerPos).Magnitude>16 then
						local a=rng:NextNumber(0,math.pi*2)
						local radius=rng:NextNumber(5,10)
						s.petPatrol=ownerPos+Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius)
						s.petPatrolClock=rng:NextNumber(2,4)
					end
					goal=s.petPatrol; look=goal; speed=9
				end
				local flatGoal=Vector3.new(goal.X,0,goal.Z)
				if flatGoal.Magnitude>82 then goal=flatGoal.Unit*82+Vector3.new(0,3.6,0) end
				local delta=goal-old
				if s.petAttack then speed=0 end
				local pos=delta.Magnitude>.08 and old+delta.Unit*math.min(delta.Magnitude,speed*dt) or old
				local facing=Vector3.new(look.X,pos.Y,look.Z)-pos
				local rotation=s.pet:GetPivot().Rotation
				if facing.Magnitude>.1 then rotation=rotation:Lerp(CFrame.lookAt(Vector3.zero,facing.Unit).Rotation,math.min(1,dt*10)) end
				s.pet:PivotTo(CFrame.new(pos)*rotation)
				s.pet:SetAttribute("Behavior",s.petAttack and (s.petAttack.heavy and "EarthSlam" or "GroundPunch") or (petTarget and "Attack" or (s.petReturning and "Return" or "Patrol")))
				s.cooldown=math.max(0,s.cooldown-dt)
				if not s.offers then
					s.fireClock-=dt; s.lightningClock-=dt; s.iceClock-=dt; s.golemClock-=dt
					local target=nearest(r.Position,46)
					if target and s.fireClock<=0 then
						s.fireClock=math.max(.4,1.05-s.fire*.09)
						effect:FireAllClients("fire",r.Position,target.pos,2.5+s.fire*.6)
						blast(target.pos,2.5+s.fire*.6,15+s.fire*8,s)
					end
					if target and s.lightning>0 and s.lightningClock<=0 then
						s.lightningClock=2; local last=r.Position; local struck={}
						for hop=1,1+s.lightning do
							local hit,range=nil,35
							for _,e in ipairs(enemies) do local d=(e.pos-last).Magnitude; if e.hp>0 and not struck[e] and d<range then hit,range=e,d end end
							if not hit then break end
							struck[hit]=true; effect:FireAllClients("lightning",last,hit.pos,hop); damage(hit,12+s.lightning*7,s); last=hit.pos
						end
					end
					local iceTarget=s.ice>0 and nearest(r.Position,46)
					if iceTarget and s.iceClock<=0 then
						s.iceClock=1.6
						castIceSpear(s,r,iceTarget)
					end
					local slamReady=s.petSlamPoint and (pos-s.petSlamPoint).Magnitude<3 and (s.petHeavyCooldown or 0)<=0
					if slamReady and not s.petAttack then
						beginGolemAttack(s,true)
					elseif petTarget and petTarget.hp>0 and not s.petAttack and not s.petSlamPoint and s.golemClock<=0 and (pos-petTarget.pos).Magnitude<7 then
						beginGolemAttack(s,false)
					end
					advanceGolemAttack(s,dt)
				end
				poseGolem(s)
			end
		end
		for i=#gems,1,-1 do
			local gem=gems[i]; local collector=nil; local best=math.huge
			for _,s in pairs(states) do local r=rootOf(s); if r and not s.offers then local d=(r.Position-gem.pos).Magnitude; if d<12+s.magnet*3 and d<best then collector,best=s,d end end end
			if collector then
				local r=rootOf(collector)
				if best<4 then
					gem.part:Destroy(); table.remove(gems,i)
					for _,s in pairs(states) do if rootOf(s) then s.xp+=1; levelCheck(s) end end
				else gem.pos=gem.pos:Lerp(r.Position,math.min(1,dt*9)); gem.part.Position=gem.pos end
			end
		end
	end
	sendClock+=dt
	if sendClock>=.2 then sendClock=0; for _,s in pairs(states) do sync(s) end end
end)
print("[Summoner] Survival server ready")
