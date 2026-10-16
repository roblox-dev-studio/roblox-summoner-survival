-- Run in a NEW, empty Studio project's Command Bar, in edit mode.
assert(not workspace:FindFirstChild("SummonerArena"), "SummonerArena already exists; installation cancelled")
assert(not game.ReplicatedStorage:FindFirstChild("SummonerNet"), "SummonerNet already exists; installation cancelled")
assert(not game.ServerScriptService:FindFirstChild("SummonerServer"), "SummonerServer already exists; installation cancelled")
assert(not game.StarterPlayer.StarterPlayerScripts:FindFirstChild("SummonerClient"), "SummonerClient already exists; installation cancelled")
(function()
-- Run in Studio edit mode. Only creates the prototype's own arena.
local Lighting = game:GetService("Lighting")
local arena = Instance.new("Folder")
arena.Name = "SummonerArena"
local function part(name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Anchored = true
	p.Color = color
	p.Material = material or Enum.Material.Slate
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = arena
	return p
end
local floor = part("ArenaFloor", Vector3.new(186, 3, 186), CFrame.new(0,-1.5,0), Color3.fromRGB(38,51,55))
local base = workspace:FindFirstChild("Baseplate")
if base then base.Transparency = 1; base.CanCollide = false end
local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
if spawn then spawn.Position=Vector3.new(0,0.5,0); spawn.Transparency=1; spawn.CanCollide=false; spawn.Neutral=true; spawn.Duration=0 end
for i=1,48 do
	local a=i*math.pi*2/48
	local cf=CFrame.new(math.cos(a)*88, 2.5, math.sin(a)*88)*CFrame.Angles(0,-a,0)
	part("BoundaryStone",Vector3.new(6,5+(i%3),5),cf,Color3.fromRGB(51,65,69))
	if i%4==0 then
		local p=part("RuneLantern",Vector3.new(1.5,1.5,1.5),cf*CFrame.new(0,4,0),Color3.fromRGB(72,232,205),Enum.Material.Neon)
		p.CanCollide=false
		local light=Instance.new("PointLight"); light.Color=p.Color; light.Range=18; light.Brightness=1.3; light.Parent=p
	end
end
for i=1,40 do
	local a=i*math.pi*2/40
	local p=part("SummoningCircle",Vector3.new(2.4,0.04,0.16),CFrame.new(math.cos(a)*10,0.035,math.sin(a)*10)*CFrame.Angles(0,-a-math.pi/2,0),Color3.fromRGB(64,133,127),Enum.Material.Neon)
	p.CanCollide=false
end
for i=1,28 do
	local a=i*2.39996; local radius=24+(i%6)*9
	local p=part("OldPaving",Vector3.new(5+i%3,0.06,4),CFrame.new(math.cos(a)*radius,0.04,math.sin(a)*radius)*CFrame.Angles(0,a,0),Color3.fromRGB(46,61,64))
	p.CanCollide=false
end
for _,edge in ipairs({{0,94,190,4},{0,-94,190,4},{94,0,4,190},{-94,0,4,190}}) do
	local p=part("InvisibleBoundary",Vector3.new(edge[3],30,edge[4]),CFrame.new(edge[1],12,edge[2]),Color3.new())
	p.Transparency=1
end
arena.Parent=workspace
Lighting.ClockTime=14.5
Lighting.Brightness=2
Lighting.Ambient=Color3.fromRGB(135,151,166)
Lighting.OutdoorAmbient=Color3.fromRGB(145,163,175)
Lighting.FogColor=Color3.fromRGB(44,65,75)
Lighting.FogStart=140; Lighting.FogEnd=350
local atmosphere=Instance.new("Atmosphere")
atmosphere.Density=0.22; atmosphere.Color=Color3.fromRGB(164,191,191); atmosphere.Decay=Color3.fromRGB(62,82,99); atmosphere.Parent=Lighting
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(0,95,80),Vector3.new(0,0,0))
return "SummonerArena created"

end)()
local folder=Instance.new("Folder"); folder.Name="SummonerNet"
for _,name in ipairs({"State","Action","Effect"}) do local r=Instance.new("RemoteEvent"); r.Name=name; r.Parent=folder end
folder.Parent=game.ReplicatedStorage
-- Optional public mesh. Built-in dust and procedural debris work if import is unavailable.
do
    local ok, model = pcall(function() return game:GetService("InsertService"):LoadAsset(12192129638) end)
    if ok and model then
        local source = model:FindFirstChild("GroundSpikes", true)
        if source and source:IsA("MeshPart") and not game.ReplicatedStorage:FindFirstChild("SummonerVFXAssets") then
            local folder = Instance.new("Folder"); folder.Name = "SummonerVFXAssets"
            local mesh = source:Clone(); mesh:ClearAllChildren(); mesh.Name = "GroundSpikes"
            mesh.Anchored = true; mesh.CanCollide = false; mesh.CanTouch = false; mesh.CanQuery = false; mesh.CastShadow = false
            mesh:SetAttribute("Source", "https://create.roblox.com/store/asset/12192129638")
            mesh:SetAttribute("Creator", "clotuder"); mesh:SetAttribute("Terms", "Roblox Creator Store Terms; not CC0")
            mesh.Parent = folder; folder.Parent = game.ReplicatedStorage
        end
        model:Destroy()
    end
end
local s=Instance.new("Script"); s.Name="SummonerServer"; s.Source=[====[
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

]====]; s.Parent=game.ServerScriptService
local s=Instance.new("LocalScript"); s.Name="SummonerClient"; s.Source=[====[
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local Debris=game:GetService("Debris")
local ContentProvider=game:GetService("ContentProvider")
local Lighting=game:GetService("Lighting")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local net=RS:WaitForChild("SummonerNet")
local palette={bg=Color3.fromRGB(15,25,34),card=Color3.fromRGB(25,40,50),text=Color3.fromRGB(234,244,244),muted=Color3.fromRGB(155,182,188),mint=Color3.fromRGB(93,242,207),gold=Color3.fromRGB(255,196,103)}
local gui=Instance.new("ScreenGui"); gui.Name="SummonerHUD"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=player:WaitForChild("PlayerGui")
local function make(class,parent,props)
	local obj=Instance.new(class); for k,v in pairs(props) do obj[k]=v end; obj.Parent=parent; return obj
end
local function round(obj,radius) make("UICorner",obj,{CornerRadius=UDim.new(0,radius or 12)}) end
local function stroke(obj,color) make("UIStroke",obj,{Color=color or Color3.fromRGB(57,82,91),Thickness=1}) end
local function label(parent,text,size,pos,font,color)
	return make("TextLabel",parent,{BackgroundTransparency=1,Text=text,Size=size,Position=pos or UDim2.new(),Font=font or Enum.Font.GothamMedium,TextColor3=color or palette.text,TextSize=16,TextWrapped=true})
end
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
pulse.Activated:Connect(function() net.Action:FireServer("fireWave") end)
local function requestDash()
	local char=player.Character;local h=char and char:FindFirstChildOfClass("Humanoid");local root=char and char:FindFirstChild("HumanoidRootPart")
	if not h or not root then return end
	local direction=h.MoveDirection.Magnitude>.1 and h.MoveDirection or root.CFrame.LookVector
	net.Action:FireServer("dash",direction)
end
dashButton.Activated:Connect(requestDash)
UIS.InputBegan:Connect(function(input,processed)
	if processed then return end
	if input.KeyCode==Enum.KeyCode.Q then net.Action:FireServer("fireWave")
	elseif input.KeyCode==Enum.KeyCode.E then requestDash() end
end)
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

local fx=Instance.new("Folder"); fx.Name="SummonerLocalEffects"; fx.Parent=workspace
local bloom=Lighting:FindFirstChild("SummonerSpellBloom")
if not bloom then
	bloom=Instance.new("BloomEffect");bloom.Name="SummonerSpellBloom";bloom.Intensity=.22;bloom.Size=22;bloom.Threshold=1.35;bloom.Parent=Lighting
end
-- Bundled Roblox textures loaded successfully in this project; see ASSET_CREDITS.md.
local smokeTexture="rbxasset://textures/particles/smoke_main.dds"
task.spawn(function()
	local ok=pcall(function()
		ContentProvider:PreloadAsync({smokeTexture},function(_,status)
			gui:SetAttribute("SmokeTextureStatus",status.Name)
			if status~=Enum.AssetFetchStatus.Success then smokeTexture="rbxasset://textures/particles/smoke_main.dds" end
		end)
	end)
	if not ok then smokeTexture="rbxasset://textures/particles/smoke_main.dds" end
end)
local function visual(size,cf,color,shape,lifetime)
	local p=Instance.new("Part"); p.Size=size; p.CFrame=cf; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Material=Enum.Material.Neon; p.Color=color
	p.Shape=shape or Enum.PartType.Ball; p.Parent=fx; Debris:AddItem(p,lifetime or 1); return p
end
local function ring(pos,radius,color)
	local p=visual(Vector3.new(.12,1,1),CFrame.new(pos.X,.2,pos.Z)*CFrame.Angles(0,0,math.pi/2),color,Enum.PartType.Cylinder)
	p.Transparency=.25
	TweenService:Create(p,TweenInfo.new(.4),{Size=Vector3.new(.12,radius*2,radius*2),Transparency=1}):Play()
end
local function dustBurst(point,direction,heavy)
	local host=visual(Vector3.new(.1,.1,.1),CFrame.lookAt(point,point+direction),palette.gold,nil,2)
	host.Name="SlamDust"; host.Transparency=1
	local emitter=Instance.new("ParticleEmitter")
	emitter.Name="ImpactDust"; emitter.Texture=smokeTexture; emitter.Rate=0
	emitter.Lifetime=NumberRange.new(.45,heavy and 1.1 or .7)
	emitter.Speed=NumberRange.new(heavy and 8 or 3,heavy and 15 or 7)
	emitter.EmissionDirection=Enum.NormalId.Front; emitter.SpreadAngle=Vector2.new(25,18)
	emitter.Acceleration=Vector3.new(0,3,0); emitter.Drag=3
	emitter.Rotation=NumberRange.new(0,360); emitter.RotSpeed=NumberRange.new(-70,70)
	emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,heavy and 2.8 or 1.3),NumberSequenceKeypoint.new(.45,heavy and 5 or 2.5),NumberSequenceKeypoint.new(1,heavy and 6.5 or 3)})
	emitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.45),NumberSequenceKeypoint.new(.4,.65),NumberSequenceKeypoint.new(1,1)})
	emitter.Color=ColorSequence.new(Color3.fromRGB(181,164,132),Color3.fromRGB(110,122,124))
	emitter.LightEmission=.08; emitter.LightInfluence=.8; emitter.Parent=host
	emitter:Emit(heavy and 5 or 3)
end
local function shockwave(pos,radius,color,heavy)
	local count=heavy and 24 or 12
	local center=Vector3.new(pos.X,.19,pos.Z)
	for i=1,count do
		local a=i*math.pi*2/count
		local dir=Vector3.new(math.cos(a),0,math.sin(a))
		local start=center+dir*1.7
		local finish=center+dir*radius
		local p=visual(Vector3.new(.8,.1,.18),CFrame.lookAt(start,start+dir),color,Enum.PartType.Block)
		p.Name="SlamShockwave";p.Transparency=.12
		TweenService:Create(p,TweenInfo.new(heavy and .5 or .32,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=CFrame.lookAt(finish,finish+dir),Size=Vector3.new(math.pi*2*radius/count*.91,.06,.12),Transparency=1}):Play()
	end
end
local function chargeGolem(pet,duration)
	if typeof(pet)~="Instance" or not pet.Parent then return end
	for _,name in ipairs({"LeftArm","RightArm"}) do
		local arm=pet:FindFirstChild(name)
		if arm then
			local attachment=Instance.new("Attachment"); attachment.Name="SlamCharge";attachment.Position=Vector3.new(0,-arm.Size.Y*.4,0);attachment.Parent=arm;Debris:AddItem(attachment,duration+1)
			local light=Instance.new("PointLight");light.Color=palette.gold;light.Range=9;light.Brightness=1.5;light.Parent=attachment
			local sparks=Instance.new("ParticleEmitter");sparks.Texture="rbxasset://textures/particles/sparkles_main.dds";sparks.Rate=25;sparks.Lifetime=NumberRange.new(.15,.35);sparks.Speed=NumberRange.new(1,4);sparks.SpreadAngle=Vector2.new(180,180);sparks.Size=NumberSequence.new(.45,0);sparks.Transparency=NumberSequence.new(0,1);sparks.Color=ColorSequence.new(palette.gold,palette.mint);sparks.LightEmission=1;sparks.Parent=attachment
			task.delay(duration,function()if attachment.Parent then sparks.Enabled=false;TweenService:Create(light,TweenInfo.new(.2),{Brightness=0}):Play() end end)
		end
	end
end
local function groundImpact(pos,radius,heavy,level)
	local color=heavy and palette.gold or palette.mint
	shockwave(pos,radius,color,heavy)
	if heavy then task.delay(.07,function()shockwave(pos,radius*.72,palette.mint,true)end) end
	local flash=visual(Vector3.new(1,.5,1),CFrame.new(pos.X,.4,pos.Z),color)
	flash.Name="SlamFlash"
	TweenService:Create(flash,TweenInfo.new(.18),{Size=Vector3.new(heavy and 7 or 3,.2,heavy and 7 or 3),Transparency=1}):Play()
	if heavy then
		local light=Instance.new("PointLight");light.Color=color;light.Range=20;light.Brightness=3;light.Parent=flash;TweenService:Create(light,TweenInfo.new(.2),{Brightness=0}):Play()
	end
	for i=1,(heavy and 10 or 4) do
		local a=i*math.pi*2/(heavy and 10 or 4)
		local dir=Vector3.new(math.cos(a),0,math.sin(a))
		dustBurst(Vector3.new(pos.X,.7,pos.Z)+dir*1.5,dir,heavy)
	end
	local count=heavy and 10 or 4
	for i=1,count do
		local a=i*math.pi*2/count
		local dir=Vector3.new(math.cos(a),0,math.sin(a))
		local point=Vector3.new(pos.X,.35,pos.Z)+dir*(heavy and 2.5 or 1.3)
		local size=heavy and 1.25 or .6
		local rock=visual(Vector3.new(size*1.3,size*.7,size),CFrame.new(point)*CFrame.Angles(a,a*.7,a*.3),Color3.fromRGB(105,121,123),Enum.PartType.Block)
		rock.Material=Enum.Material.Slate
		local land=point+dir*radius*.55
		TweenService:Create(rock,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=land+Vector3.new(0,heavy and 3 or 1.4,0)}):Play()
		task.delay(.22,function()
			if rock.Parent then TweenService:Create(rock,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=land,Transparency=1}):Play() end
		end)
		local midpoint=Vector3.new(pos.X,.12,pos.Z)+dir*radius*.38
		local crack=visual(Vector3.new(heavy and .22 or .12,.05,radius*.55),CFrame.lookAt(midpoint,midpoint+dir),Color3.fromRGB(16,23,25),Enum.PartType.Block)
		crack.Material=Enum.Material.Slate
		TweenService:Create(crack,TweenInfo.new(.8),{Transparency=1}):Play()
	end
	local templates=RS:FindFirstChild("SummonerVFXAssets")
	local spikes=templates and templates:FindFirstChild("GroundSpikes")
	if heavy and spikes and spikes:IsA("MeshPart") then
		local mound=spikes:Clone();mound.Name="SlamGroundSpikes";mound.Size=Vector3.new(radius*.75,3.6,radius*.75);mound.CFrame=CFrame.new(pos.X,-1.8,pos.Z)*CFrame.Angles(0,math.random()*math.pi,0);mound.Color=Color3.fromRGB(74,92,91);mound.Material=Enum.Material.Slate;mound.Transparency=0;mound.Parent=fx;Debris:AddItem(mound,1.8)
		TweenService:Create(mound,TweenInfo.new(.12,Enum.EasingStyle.Back),{Position=Vector3.new(pos.X,.7,pos.Z)}):Play()
		task.delay(.8,function()if mound.Parent then TweenService:Create(mound,TweenInfo.new(.7),{Position=Vector3.new(pos.X,-2.5,pos.Z),Transparency=1}):Play() end end)
	end
	if heavy and level>=3 then
		for i=1,6 do
			local a=i*math.pi/3
			local point=Vector3.new(pos.X,-1,pos.Z)+Vector3.new(math.cos(a),0,math.sin(a))*radius*.75
			local shard=visual(Vector3.new(1.7,3.3,1.7),CFrame.new(point)*CFrame.Angles(.2,a,.2),Color3.fromRGB(100,137,128),Enum.PartType.Block)
			shard.Material=Enum.Material.Slate
			TweenService:Create(shard,TweenInfo.new(.15,Enum.EasingStyle.Back),{Position=point+Vector3.new(0,2.1,0)}):Play()
			task.delay(.4,function() if shard.Parent then TweenService:Create(shard,TweenInfo.new(.4),{Position=point,Transparency=1}):Play() end end)
		end
	end
end
local function spellBurst(pos,texture,color,count,size,speed)
	local host=visual(Vector3.new(.1,.1,.1),CFrame.new(pos),color,nil,1.5)
	host.Name="SpellParticles";host.Transparency=1
	local p=Instance.new("ParticleEmitter");p.Texture=texture;p.Rate=0
	p.Color=ColorSequence.new(color,Color3.fromRGB(242,248,255))
	p.Lifetime=NumberRange.new(.2,.6);p.Speed=NumberRange.new(speed*.4,speed)
	p.SpreadAngle=Vector2.new(180,180);p.Drag=3
	p.Size=NumberSequence.new(size,0);p.Transparency=NumberSequence.new(.1,1)
	p.Rotation=NumberRange.new(0,360);p.RotSpeed=NumberRange.new(-90,90)
	p.LightEmission=.8;p.Parent=host;p:Emit(count)
	return host
end
local function spellGlow(pos,color,size)
	local host=spellBurst(pos,"rbxasset://textures/particles/forcefield_glow_main.dds",color,1,size,0)
	host.Name="SpellGlow"
	local p=host:FindFirstChildOfClass("ParticleEmitter")
	p.Lifetime=NumberRange.new(.22,.35);p.Size=NumberSequence.new(size,size*1.7);p.Transparency=NumberSequence.new(.35,1);p.LightEmission=1;p:Clear();p:Emit(1)
end
local function runeCircle(pos,radius,color,lifetime)
	local center=Vector3.new(pos.X,.16,pos.Z)
	for i=1,16 do
		local a=i*math.pi*2/16
		local dir=Vector3.new(math.cos(a),0,math.sin(a))
		local point=center+dir*radius
		local p=visual(Vector3.new(radius*.32,.055,.07),CFrame.lookAt(point,point+dir),color,Enum.PartType.Block,lifetime+.1)
		p.Name="SpellRune";p.Transparency=.25
		TweenService:Create(p,TweenInfo.new(lifetime),{Transparency=1}):Play()
		if i%4==0 then
			local glyph=visual(Vector3.new(.35,.055,.35),CFrame.new(center+dir*(radius+.6))*CFrame.Angles(0,math.pi/4,0),color,Enum.PartType.Block,lifetime+.1)
			glyph.Name="SpellRune";TweenService:Create(glyph,TweenInfo.new(lifetime),{Transparency=1,Size=Vector3.new(.07,.055,.07)}):Play()
		end
	end
end
local fireTexture="rbxasset://textures/particles/fire_main.dds"
local emberTexture="rbxasset://textures/particles/fire_sparks_main.dds"
task.spawn(function()
	ContentProvider:PreloadAsync({fireTexture,emberTexture},function(asset,status)
		gui:SetAttribute(asset==fireTexture and "FireTextureStatus" or "EmberTextureStatus",status.Name)
	end)
end)
local function flameEmitter(host,core)
	local p=Instance.new("ParticleEmitter");p.Name=core and "FlameHeart" or "FlameTongues";p.Texture=fireTexture
	p.Orientation=Enum.ParticleOrientation.FacingCameraWorldUp
	p.EmissionDirection=Enum.NormalId.Top;p.SpreadAngle=Vector2.new(28,28)
	p.Lifetime=core and NumberRange.new(.18,.32) or NumberRange.new(.32,.55)
	p.Speed=core and NumberRange.new(2,4) or NumberRange.new(4,8)
	p.Acceleration=Vector3.new(0,6,0);p.Drag=1;p.VelocityInheritance=0
	p.Rotation=NumberRange.new(-12,12);p.RotSpeed=NumberRange.new(-25,25)
	p.Color=core and ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,243,170)),ColorSequenceKeypoint.new(.45,Color3.fromRGB(255,193,57)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,93,25))}) or ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,194,49)),ColorSequenceKeypoint.new(.35,Color3.fromRGB(255,104,20)),ColorSequenceKeypoint.new(1,Color3.fromRGB(204,37,25))})
	p.Size=core and NumberSequence.new({NumberSequenceKeypoint.new(0,.6),NumberSequenceKeypoint.new(.25,1.5,.3),NumberSequenceKeypoint.new(1,0)}) or NumberSequence.new({NumberSequenceKeypoint.new(0,1.2,.2),NumberSequenceKeypoint.new(.3,2.7,.5),NumberSequenceKeypoint.new(.65,2.1,.4),NumberSequenceKeypoint.new(1,0)})
	p.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.3),NumberSequenceKeypoint.new(.12,.05),NumberSequenceKeypoint.new(.55,.2),NumberSequenceKeypoint.new(1,1)})
	p.LightEmission=.8;p.LightInfluence=0;p.Rate=core and 24 or 42;p.Parent=host
	return p
end
local function fireWave(origin,direction,range)
	local gold=Color3.fromRGB(255,175,48)
	runeCircle(origin,3.1,gold,.5)
	spellGlow(origin+direction*2,gold,3)
	-- Invisible moving sources leave curling flame sprites, never solid slabs.
	for i=-7,7 do
		local dir=CFrame.Angles(0,math.rad(i*4.8),0):VectorToWorldSpace(direction)
		local base=Vector3.new(origin.X,math.max(.8,origin.Y-1.7),origin.Z)
		local host=visual(Vector3.new(.3,.1,.3),CFrame.lookAt(base+dir*2,base+dir*3),gold,nil,1.5)
		host.Name="FlameWaveSource";host.Transparency=1
		local flame=flameEmitter(host,false);local core=flameEmitter(host,true)
		flame:Emit(5);core:Emit(3)
		local sparks=Instance.new("ParticleEmitter");sparks.Name="FlameEmbers";sparks.Texture=emberTexture;sparks.Rate=12;sparks.Lifetime=NumberRange.new(.35,.65);sparks.Speed=NumberRange.new(4,9);sparks.EmissionDirection=Enum.NormalId.Top;sparks.SpreadAngle=Vector2.new(65,65);sparks.Acceleration=Vector3.new(0,3,0);sparks.Drag=2;sparks.Color=ColorSequence.new(Color3.fromRGB(255,209,85),Color3.fromRGB(255,80,25));sparks.Size=NumberSequence.new(.55,0);sparks.Transparency=NumberSequence.new(.1,1);sparks.LightEmission=1;sparks.Parent=host
		if i%4==0 then local light=Instance.new("PointLight");light.Color=gold;light.Range=10;light.Brightness=1.4;light.Parent=host;task.delay(.45,function()if light.Parent then TweenService:Create(light,TweenInfo.new(.25),{Brightness=0}):Play()end end)end
		TweenService:Create(host,TweenInfo.new(.62,Enum.EasingStyle.Linear),{Position=base+dir*range}):Play()
		task.delay(.62,function()if host.Parent then flame.Enabled=false;core.Enabled=false;sparks.Enabled=false end end)
	end
end
local function magicBolt(a,b,radius)
	local delta=b-a;if delta.Magnitude<.01 then return end
	local host=visual(Vector3.new(.1,.1,.1),CFrame.lookAt(a,b),Color3.fromRGB(255,158,35),nil,1)
	host.Name="ArcaneFireBolt";host.Transparency=1
	local flame=flameEmitter(host,false);flame.Rate=65;flame.Size=NumberSequence.new(1.25,0);flame.Lifetime=NumberRange.new(.15,.25);flame.Speed=NumberRange.new(1,3);flame:Emit(5)
	local core=flameEmitter(host,true);core.Rate=35;core.Size=NumberSequence.new(.7,0);core:Emit(3)
	TweenService:Create(host,TweenInfo.new(.12,Enum.EasingStyle.Linear),{Position=b}):Play()
	task.delay(.12,function()
		if not host.Parent then return end
		flame.Enabled=false;core.Enabled=false
		spellGlow(b,Color3.fromRGB(255,171,45),2.5)
		local burst=spellBurst(b,fireTexture,Color3.fromRGB(255,127,30),12,1.6,7)
		local p=burst:FindFirstChildOfClass("ParticleEmitter");p:Clear();p.Color=ColorSequence.new(Color3.fromRGB(255,193,64),Color3.fromRGB(232,59,20));p.Orientation=Enum.ParticleOrientation.FacingCameraWorldUp;p.Rotation=NumberRange.new(-15,15);p:Emit(12)
	end)
end
local function dashEffect(character,duration,direction)
	if typeof(character)~="Instance" or not character.Parent then return end
	local root=character:FindFirstChild("HumanoidRootPart");if not root then return end
	local a=Instance.new("Attachment");a.Position=Vector3.new(-.8,0,0);a.Parent=root;Debris:AddItem(a,duration+.4)
	local b=Instance.new("Attachment");b.Position=Vector3.new(.8,0,0);b.Parent=root;Debris:AddItem(b,duration+.4)
	local trail=Instance.new("Trail");trail.Name="DashRibbon";trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.18;trail.MinLength=.05;trail.Color=ColorSequence.new(Color3.fromRGB(216,251,255),Color3.fromRGB(116,176,255));trail.Transparency=NumberSequence.new(.45,1);trail.WidthScale=NumberSequence.new(1,0);trail.LightEmission=.8;trail.Parent=a
	spellBurst(root.Position,"rbxasset://textures/particles/sparkles_main.dds",Color3.fromRGB(159,223,255),8,.25,5)
	task.spawn(function()
		for frame=1,3 do
			if not character.Parent then break end
			local count=0
			for _,part in ipairs(character:GetDescendants())do
				if part:IsA("BasePart") and part.Name~="HumanoidRootPart" and count<16 then
					local ghost=part:Clone()
					if ghost then
						for _,child in ipairs(ghost:GetChildren())do if not child:IsA("SpecialMesh") then child:Destroy() elseif child:IsA("SpecialMesh") then child.TextureId="" end end
						ghost.Name="ArcaneDashGhost";ghost.Anchored=true;ghost.CanCollide=false;ghost.CanTouch=false;ghost.CanQuery=false;ghost.CastShadow=false;ghost.Color=Color3.fromRGB(139,206,255);ghost.Material=Enum.Material.Neon;ghost.Transparency=.72
						if ghost:IsA("MeshPart") then ghost.TextureID="" end
						ghost.Parent=fx;Debris:AddItem(ghost,.32);TweenService:Create(ghost,TweenInfo.new(.3),{Transparency=1}):Play();count+=1
					end
				end
			end
			task.wait(.065)
		end
	end)
	task.delay(duration,function()if trail.Parent then trail.Enabled=false end end)
end
local function lightningBolt(a,b,hop)
	local blue=Color3.fromRGB(65,164,255);local white=Color3.fromRGB(230,251,255)
	local function ground(pos)
		local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
		local excluded={fx};local runtime=workspace:FindFirstChild("SummonerRuntime");if runtime then table.insert(excluded,runtime)end
		for _,plr in ipairs(Players:GetPlayers())do if plr.Character then table.insert(excluded,plr.Character)end end
		params.FilterDescendantsInstances=excluded;params.RespectCanCollide=true
		local hit=workspace:Raycast(pos+Vector3.new(0,8,0),Vector3.new(0,-50,0),params)
		return hit and hit.Position+Vector3.new(0,.12,0) or Vector3.new(pos.X,.15,pos.Z)
	end
	local function segment(start,finish,width,color,alpha,delay)
		local length=(finish-start).Magnitude;if length<.01 then return end
		task.delay(delay,function()
			local p=visual(Vector3.new(width,width,length),CFrame.lookAt((start+finish)/2,finish),color,Enum.PartType.Block,.48)
			p.Name="ChainLightning";p.Transparency=alpha
			task.delay(.09,function()if p.Parent then TweenService:Create(p,TweenInfo.new(.28),{Transparency=1}):Play()end end)
		end)
	end
	local function line(start,finish,width,delay)
		segment(start,finish,width,blue,.5,delay);segment(start,finish,width*.32,white,.02,delay)
	end
	local landing=ground(b)
	if (hop or 1)==1 then
		-- The upper leader arrives first, then the flash and floor discharge.
		local top=landing+Vector3.new(0,22,0);local points={top}
		for i=1,7 do table.insert(points,top:Lerp(landing,i/8)+Vector3.new((i%2==0 and 1 or -1)*(1.1+math.random()),0,(math.random()-.5)*1.6))end
		table.insert(points,landing)
		for i=1,#points-1 do
			line(points[i],points[i+1],.85,(i-1)*.008)
			if i==3 or i==5 then
				local branch=points[i]+Vector3.new(i==3 and 3 or -3,-3,1)
				line(points[i],branch,.25,(i-1)*.008)
			end
		end
		task.delay(.11,function()for i=1,#points-1 do line(points[i],points[i+1],.4,0)end end)
	else
		local start=ground(a);local delta=landing-start;local side=Vector3.new(-delta.Z,0,delta.X)
		if side.Magnitude>.01 then side=side.Unit else side=Vector3.xAxis end
		local last=start
		for i=1,6 do
			local point=i==6 and landing or start+delta*(i/6)+side*(i%2==0 and 1 or -1)*.75
			line(last,point,.45,.055+i*.012);last=point
		end
	end
	-- Radial arcs crawl out from the impact over the floor.
	for ray=1,6 do
		local angle=ray*math.pi/3+math.random()*.35
		local dir=Vector3.new(math.cos(angle),0,math.sin(angle));local side=Vector3.new(-dir.Z,0,dir.X)
		local last=landing
		for step=1,4 do
			local point=ground(landing+dir*(step*1.55)+side*((step%2==0 and 1 or -1)*.55))
			line(last,point,.32*(1-step*.12),.065+step*.025);last=point
		end
	end
	task.delay(.065,function()
		spellGlow(landing,blue,5)
		local host=spellBurst(landing+Vector3.new(0,.3,0),"rbxasset://textures/particles/sparkles_main.dds",blue,18,.5,10)
		local light=Instance.new("PointLight");light.Color=blue;light.Range=15;light.Brightness=3;light.Parent=host;TweenService:Create(light,TweenInfo.new(.35),{Brightness=0}):Play()
		spellGlow(b,white,2.5)
	end)
end
local function iceShard(size,cf,color,lifetime)
	local p=Instance.new("WedgePart");p.Name="IceCrystal";p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Neon;p.Transparency=.15
	p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=fx;Debris:AddItem(p,lifetime or .7)
	return p
end
local function icePortal(cf,charge)
	local portal=Instance.new("Folder");portal.Name="IceCastingCircle";portal.Parent=fx
	local function glyph(size,localCF,color,delay)
		local p=Instance.new("Part");p.Name="FrostSigil";p.Size=size;p.CFrame=cf*localCF;p.Color=color;p.Material=Enum.Material.Neon;p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=portal
		task.delay(delay,function()if p.Parent then TweenService:Create(p,TweenInfo.new(.08),{Transparency=.18}):Play()end end)
	end
	for ring=1,2 do
		local count=ring==1 and 32 or 24
		local radius=ring==1 and 2.45 or 1.85
		for i=1,count do
			local a=(i-1)*math.pi*2/count
			local localCF=CFrame.new(math.cos(a)*radius,math.sin(a)*radius,0)*CFrame.Angles(0,0,a+math.pi/2)
			glyph(Vector3.new(math.pi*2*radius/count*.92,.055,.055),localCF,ring==1 and Color3.fromRGB(117,215,255)or Color3.fromRGB(213,251,255),(i-1)/count*charge*.7+(ring-1)*.05)
		end
	end
	for i=1,6 do
		local a=i*math.pi/3
		glyph(Vector3.new(.27,.27,.055),CFrame.new(math.cos(a)*2.95,math.sin(a)*2.95,0)*CFrame.Angles(0,0,a+math.pi/4),Color3.fromRGB(190,237,255),charge*.55)
	end
	for i=0,2 do glyph(Vector3.new(.055,2.6,.055),CFrame.Angles(0,0,i*math.pi/3),Color3.fromRGB(162,231,255),charge*.3)end
	spellGlow(cf.Position,Color3.fromRGB(134,218,255),2.4)
	return portal
end
local function iceProjectile(anchorName,portalCF,charge)
	if type(anchorName)~="string" or typeof(portalCF)~="CFrame" then return end
	local runtime=workspace:FindFirstChild("SummonerRuntime")
	local anchor=runtime and (runtime:FindFirstChild(anchorName) or runtime:WaitForChild(anchorName,2))
	if not anchor or not anchor.Parent then return end
	local portal=icePortal(portalCF,charge)
	local spear=Instance.new("Model");spear.Name="GlacialSpear";spear.Parent=fx
	local initial=anchor.CFrame
	local function piece(class,name,size,offset,color,material,transparency)
		local p=Instance.new(class);p.Name=name;p.Size=size;p.CFrame=initial*offset;p.Color=color;p.Material=material;p.Transparency=transparency;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=spear
		return p
	end
	local pivot=piece("Part","SpearPivot",Vector3.new(.05,.05,.05),CFrame.new(),Color3.new(1,1,1),Enum.Material.SmoothPlastic,1);spear.PrimaryPart=pivot
	-- Each triangular face is split at its altitude into two thin wedges.
	-- A closed diamond cross-section tapers to a real point at both ends.
	local function face(a,b,c,color)
		local ab,ac,bc=b-a,c-a,c-b
		local abd,acd,bcd=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
		if abd>acd and abd>bcd then c,a=a,c elseif acd>abd and acd>bcd then a,b=b,a end
		ab,ac,bc=b-a,c-a,c-b
		local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
		local height=math.abs(ab:Dot(up))
		local function half(v,axis,depth)
			if depth<.005 then return end
			piece("WedgePart","IceSpearFacet",Vector3.new(.025,height,depth),CFrame.fromMatrix((a+v)/2,axis,up,axis==right and back or -back),color,Enum.Material.Glass,.16).Reflectance=.08
		end
		half(b,right,math.abs(ab:Dot(back)));half(c,-right,math.abs(ac:Dot(back)))
	end
	local tip=Vector3.new(0,0,-6.5);local tail=Vector3.new(0,0,1.4)
	local ring={Vector3.new(.9,0,-2.2),Vector3.new(0,.9,-2.2),Vector3.new(-.9,0,-2.2),Vector3.new(0,-.9,-2.2)}
	local function edge(a,b)
		piece("Part","IceSpearRidge",Vector3.new(.045,.045,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),Color3.fromRGB(184,241,255),Enum.Material.Neon,.18)
	end
	for i=1,4 do
		local a,b=ring[i],ring[i%4+1]
		local color=i%2==0 and Color3.fromRGB(173,230,255) or Color3.fromRGB(75,162,230)
		face(tip,a,b,color);face(tail,b,a,color)
		edge(tip,a);edge(tail,a);edge(a,b)
	end
	local left=Instance.new("Attachment");left.Position=Vector3.new(-.6,0,0);left.Parent=pivot
	local right=Instance.new("Attachment");right.Position=Vector3.new(.6,0,0);right.Parent=pivot
	local trail=Instance.new("Trail");trail.Name="GlacialSpearTrail";trail.Attachment0=left;trail.Attachment1=right;trail.Enabled=false;trail.Lifetime=.25;trail.MinLength=.1;trail.Color=ColorSequence.new(Color3.fromRGB(220,252,255),Color3.fromRGB(109,177,255));trail.Transparency=NumberSequence.new(.25,1);trail.WidthScale=NumberSequence.new(.7,0);trail.LightEmission=.8;trail.Parent=pivot
	spear:ScaleTo(.12)
	local scale=Instance.new("NumberValue");scale.Value=.12;scale.Parent=spear
	local scaleConn=scale.Changed:Connect(function(value)if spear.Parent then spear:ScaleTo(value)end end)
	TweenService:Create(scale,TweenInfo.new(charge*.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Value=1}):Play()
	local launched=false
	local renderConn,destroyConn
	local function clear()
		if renderConn then renderConn:Disconnect()end;if destroyConn then destroyConn:Disconnect()end;scaleConn:Disconnect()
		if portal.Parent then portal:Destroy()end;if spear.Parent then spear:Destroy()end
	end
	destroyConn=anchor.Destroying:Connect(clear)
	renderConn=RunService.RenderStepped:Connect(function(dt)
		if not anchor.Parent then clear();return end
		spear:PivotTo(spear:GetPivot():Lerp(anchor.CFrame,1-math.exp(-dt*35)))
		if not launched and anchor:GetAttribute("Launched") then
			launched=true;trail.Enabled=true
			spellBurst(portalCF.Position,"rbxasset://textures/particles/sparkles_main.dds",Color3.fromRGB(191,242,255),14,.3,4)
			for _,p in ipairs(portal:GetChildren())do if p:IsA("BasePart")then TweenService:Create(p,TweenInfo.new(.25),{Transparency=1}):Play()end end
			Debris:AddItem(portal,.3)
		end
	end)
end
local function iceImpact(model,pos,duration)
	spellGlow(pos,Color3.fromRGB(145,223,255),4)
	runeCircle(pos,2.8,Color3.fromRGB(133,235,255),.7)
	local mist=spellBurst(pos,smokeTexture,Color3.fromRGB(149,211,240),7,1.5,3)
	local fog=mist:FindFirstChildOfClass("ParticleEmitter");fog.LightEmission=.25;fog.Size=NumberSequence.new(1.2,3.8);fog.Transparency=NumberSequence.new(.7,1)
	spellBurst(pos,"rbxasset://textures/particles/sparkles_main.dds",Color3.fromRGB(200,246,255),22,.4,8)
	shockwave(pos,3.8,Color3.fromRGB(166,238,255),false)
	for i=1,10 do
		local angle=i*math.pi*2/10
		local dir=Vector3.new(math.cos(angle),0,math.sin(angle))
		local p=iceShard(Vector3.new(.35,1.1+(i%3)*.25,.5),CFrame.new(pos+dir*.6)*CFrame.Angles(.2,angle,.3),i%2==0 and Color3.fromRGB(190,251,255) or Color3.fromRGB(109,181,255),.7)
		TweenService:Create(p,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=pos+dir*3.5+Vector3.new(0,.4,0),Transparency=1}):Play()
	end
	if typeof(model)=="Instance" and model.Parent then
		local old=model:FindFirstChild("SpellFreezeHighlight");if old then old:Destroy() end
		local h=Instance.new("Highlight");h.Name="SpellFreezeHighlight";h.Adornee=model;h.FillColor=Color3.fromRGB(109,207,255);h.OutlineColor=Color3.fromRGB(223,251,255);h.FillTransparency=.42;h.OutlineTransparency=.12;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=model
		local conn,destroyConn
		local function clear()
			if conn then conn:Disconnect() end;if destroyConn then destroyConn:Disconnect() end
			if h.Parent then h:Destroy() end
		end
		conn=model:GetAttributeChangedSignal("Frozen"):Connect(function()if not model:GetAttribute("Frozen") then clear() end end)
		destroyConn=model.Destroying:Connect(clear)
		-- Handles a late event arriving after the replicated frozen state has cleared.
		task.delay(duration+.2,function()if model.Parent and not model:GetAttribute("Frozen") then clear() end end)
	end
end
net.Effect.OnClientEvent:Connect(function(kind,a,b,c)
	if kind=="hit" then
		local p=visual(Vector3.new(.05,.05,.05),CFrame.new(a+Vector3.new(0,3,0)),palette.text); p.Transparency=1
		local billboard=make("BillboardGui",p,{Size=UDim2.fromOffset(70,32),AlwaysOnTop=true,Adornee=p})
		local number=label(billboard,tostring(b),UDim2.fromScale(1,1),nil,Enum.Font.GothamBold,palette.gold); number.TextSize=18
		TweenService:Create(p,TweenInfo.new(.55),{Position=p.Position+Vector3.new(0,2,0)}):Play(); TweenService:Create(number,TweenInfo.new(.55),{TextTransparency=1}):Play()
	elseif kind=="golemCharge" then chargeGolem(a,b)
	elseif kind=="golemHeavy" or kind=="golemLight" then groundImpact(a,b,kind=="golemHeavy",c)
	elseif kind=="dash" then dashEffect(a,b,c)
	elseif kind=="fire" then magicBolt(a,b,c)
	elseif kind=="fireWave" then
		fireWave(a,b,c)
	elseif kind=="lightning" then
		task.delay(math.min(.3,math.max(0,(c or 1)-1)*.045),function()lightningBolt(a,b,c)end)
	elseif kind=="iceCast" then iceProjectile(a,b,c)
	elseif kind=="iceHit" then iceImpact(a,b,c)
	end
end)
-- Roblox's standard camera supplies mouse orbit, wheel zoom and touch controls.
local function bindCamera(character)
	local humanoid=character:WaitForChild("Humanoid")
	local root=character:WaitForChild("HumanoidRootPart")
	if player.Character~=character then return end
	local camera=workspace.CurrentCamera
	player.CameraMode=Enum.CameraMode.Classic
	player.CameraMaxZoomDistance=85
	player.CameraMinZoomDistance=32
	camera.CameraSubject=humanoid
	camera.CameraType=Enum.CameraType.Custom
	camera.FieldOfView=65
	camera.CFrame=CFrame.lookAt(root.Position+Vector3.new(0,28,24),root.Position)
	task.delay(.4,function()
		if player.Character==character then player.CameraMinZoomDistance=10 end
	end)
end
player.CharacterAdded:Connect(function(character) task.spawn(bindCamera,character) end)
if player.Character then task.spawn(bindCamera,player.Character) end
net.Action:FireServer("ready")
print("[Summoner] HUD ready")

]====]; s.Parent=game.StarterPlayer.StarterPlayerScripts
print("Summoner Survival installed. Save your place and press Play.")
