-- Run in a NEW, empty Studio project's Command Bar, in edit mode.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before installing")
assert(not workspace:FindFirstChild("SummonerArena"), "SummonerArena already exists; installation cancelled")
assert(not game.ReplicatedStorage:FindFirstChild("SummonerNet"), "SummonerNet already exists; installation cancelled")
assert(not game.ServerScriptService:FindFirstChild("SummonerServer"), "SummonerServer already exists; installation cancelled")
assert(not game.StarterPlayer.StarterPlayerScripts:FindFirstChild("SummonerClient"), "SummonerClient already exists; installation cancelled");
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

-- Generated below. Edit src/ and entrypoints, then rebuild.
local function addModule(parent, path, source)
    for i=1,#path-1 do
        local folder=parent:FindFirstChild(path[i])
        if not folder then folder=Instance.new("Folder");folder.Name=path[i];folder.Parent=parent end
        parent=folder
    end
    local module=Instance.new("ModuleScript")
    module.Name=path[#path];module.Source=source;module.Parent=parent
end

do
local entry=Instance.new("Script")
entry.Name="SummonerServer"
entry.Source=[====[
-- Composition root. Feature behavior lives in src/server; see docs/ARCHITECTURE.md.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local modules = script:WaitForChild("Modules")
local net = RS:WaitForChild("SummonerNet")
Players.CharacterAutoLoads = false
local world = Instance.new("Folder")
world.Name = "SummonerRuntime"
world.Parent = workspace
local states, enemies, gems = {}, {}, {}
local rng = Random.new()
local clock = {elapsed = 0, roundLength = 180}
local actors = require(modules.shared.Actors)({world = world})
local players = require(modules.shared.PlayerState)({states = states})
local movement = require(modules.combat.Movement)({
    world = world, rootOf = players.RootOf, paused = players.Paused, effect = net.Effect,
})
local progression = require(modules.flow.Progression)({
    world = world, states = states, gems = gems, rng = rng, block = actors.Block,
    rootOf = players.RootOf, paused = players.Paused, finishDash = movement.FinishDash,
    update = net.State, clock = clock,
})
local combat = require(modules.combat.Combat)({
    world = world, enemies = enemies, rng = rng, block = actors.Block,
    rootOf = players.RootOf, paused = players.Paused, effect = net.Effect, drop = progression.Drop,
})
local waves = require(modules.world.Waves)({
    states = states, enemies = enemies, rng = rng, creature = actors.Create,
    rootOf = players.RootOf, roundLength = clock.roundLength,
})
local session = require(modules.flow.Session)({
    world = world, states = states, enemies = enemies, gems = gems, rng = rng,
    creature = actors.Create, finishDash = movement.FinishDash,
    clearIceShots = combat.ClearProjectiles, sync = progression.Sync,
    clock = clock, resetSpawn = waves.ResetSpawn,
})
net.Action.OnServerEvent:Connect(function(player,kind,id)
    local s = states[player]
    if not s then return end
    if kind == "ready" then progression.Sync(s); return end
    if kind == "restart" then if s.over then session.Restart() end; return end
    if s.over then return end
    if kind == "choose" then progression.Choose(s,id)
    elseif kind == "dash" then
        if movement.RequestDash(s,id) then progression.Sync(s) end
    elseif kind == "fireWave" then
        if combat.RequestWave(s) then progression.Sync(s) end
    end
end)
Players.PlayerAdded:Connect(function(p) task.spawn(session.AddPlayer,p) end)
Players.PlayerRemoving:Connect(session.RemovePlayer)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(session.AddPlayer,p) end

local tickClock, sendClock = 0, 0
RunService.Heartbeat:Connect(function(dt)
    tickClock += dt
    if tickClock < .05 then return end
    dt = math.min(tickClock,.15)
    tickClock = 0
    local alive = players.LiveCount()
    if alive > 0 and not players.Paused() then
        clock.elapsed += dt
        if clock.elapsed >= clock.roundLength then
            for _,s in pairs(states) do if not s.over then session.EndPlayer(s,"victory") end end
        end
        -- Keep the prototype's simulation order; changing it can change hits and XP timing.
        waves.Spawn(dt,alive,clock.elapsed)
        for _,s in pairs(states) do movement.Step(s,dt) end
        combat.StepProjectiles(dt)
        waves.Step(dt)
        for _,s in pairs(states) do
            local r = players.RootOf(s)
            if r then
                local flat = Vector3.new(r.Position.X,0,r.Position.Z)
                if flat.Magnitude > 82 then r.CFrame=CFrame.new(flat.Unit*81+Vector3.new(0,r.Position.Y,0)) end
                if r.Position.Y < -10 then session.EndPlayer(s,"defeat") end
                combat.StepPlayer(s,r,dt)
            end
        end
        progression.Collect(dt)
    end
    sendClock += dt
    if sendClock >= .2 then
        sendClock = 0
        for _,s in pairs(states) do progression.Sync(s) end
    end
end)
print("[Summoner] Survival server ready")
]====]
local modules=Instance.new("Folder");modules.Name="Modules";modules.Parent=entry
-- Source: src/server/combat/Combat.luau
addModule(modules,{"combat","Combat"},[====[
-- Automatic spells, ice projectiles, summon AI and damage. No client-owned damage.
return function(deps)
	local world, enemies, rng = deps.world, deps.enemies, deps.rng
	local block, rootOf, paused = deps.block, deps.rootOf, deps.paused
	local effect, drop = deps.effect, deps.drop
	local iceShots = {}
	local nextIceShot = 0
	-- Temporary visual preview: all golems show the final-tier presentation.
	-- Damage, fragment damage and extra damage hits still use the actual upgrade level.
	local PREVIEW_MAX_GOLEM_EFFECTS = true

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
	local function requestWave(s)
		if s.over or s.cooldown>0 or s.offers or paused() then return end
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
		return true
	end
	local function stepPlayer(s,r,dt)
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

	return {
		StepPlayer = stepPlayer,
		StepProjectiles = advanceIceSpears,
		ClearProjectiles = clearIceShots,
		RequestWave = requestWave,
	}
end
]====])
-- Source: src/server/combat/Movement.luau
addModule(modules,{"combat","Movement"},[====[
-- Server-authoritative dash and movement recovery.
return function(deps)
	local world, rootOf, paused, effect = deps.world, deps.rootOf, deps.paused, deps.effect
	local function finishDash(s)
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
	local function requestDash(s,id)
		if s.over or (s.dashCooldown or 0)>0 or s.offers or paused() then return end
		local root,h=rootOf(s);if not root then return end
		local facing=root.CFrame.LookVector
		if typeof(id)=="Vector3" and id.X==id.X and id.Z==id.Z and math.abs(id.X)<10000 and math.abs(id.Z)<10000 then facing=id end
		local direction=Vector3.new(facing.X,0,facing.Z)
		if direction.Magnitude<.01 then direction=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z) end
		if direction.Magnitude<.01 then direction=Vector3.new(0,0,-1) else direction=direction.Unit end
		s.dashCooldown=3;s.invulnerable=.28;s.dash={direction=direction,remaining=.23}
		h.WalkSpeed=0;h.AutoRotate=false
		pcall(function()root:SetNetworkOwner(nil)end)
		effect:FireAllClients("dash",s.player.Character,.23,direction)
		return true
	end

	return {
		FinishDash = finishDash,
		Step = advanceDash,
		RequestDash = requestDash,
	}
end
]====])
-- Source: src/server/flow/Progression.luau
addModule(modules,{"flow","Progression"},[====[
-- XP, offers, upgrades and the HUD state packet.
return function(deps)
	local world, states, gems, rng = deps.world, deps.states, deps.gems, deps.rng
	local block, rootOf, paused = deps.block, deps.rootOf, deps.paused
	local finishDash, update, clock = deps.finishDash, deps.update, deps.clock
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
		update:FireClient(s.player,{time=math.max(0,clock.roundLength-math.floor(clock.elapsed)),level=s.level,xp=s.xp,need=need(s),hp=h and math.ceil(h.Health) or 0,maxHp=h and h.MaxHealth or 100,
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
	local function choose(s,id)
		if s.over then return end
		if not s.offers or type(id)~="string" then return end
		local valid=false; for _,v in ipairs(s.offers) do if v.id==id then valid=true; break end end
		if not valid then return end
		if id=="vitality" then
			s.vitality+=1; local _,h=rootOf(s); if h then h.MaxHealth+=15; h.Health=math.min(h.MaxHealth,h.Health+30) end
		else s[id]+=1 end
		s.offers=nil
		local _,h=rootOf(s); if h then h.WalkSpeed=22+s.agility*2 end
		levelCheck(s); sync(s)
	end
	local function collect(dt)
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

	return {
		Sync = sync,
		Drop = drop,
		Choose = choose,
		Collect = collect,
		Need = need,
		LevelCheck = levelCheck,
	}
end
]====])
-- Source: src/server/flow/Session.luau
addModule(modules,{"flow","Session"},[====[
-- Join, death, victory and full-round restart.
return function(deps)
	local Players = game:GetService("Players")
	local world, states, enemies, gems, rng = deps.world, deps.states, deps.enemies, deps.gems, deps.rng
	local creature, finishDash, clearIceShots, sync = deps.creature, deps.finishDash, deps.clearIceShots, deps.sync
	local clock, resetSpawn = deps.clock, deps.resetSpawn
	local starting = false
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
		clearIceShots()
		clock.elapsed=0; resetSpawn()
		for _,p in ipairs(Players:GetPlayers()) do task.spawn(addPlayer,p) end
		starting=false
	end
	local function removePlayer(p)
		local s=states[p]; if s and s.pet then s.pet:Destroy() end; states[p]=nil
		if s then clearIceShots(s) end
		if next(states)==nil then world:ClearAllChildren(); table.clear(enemies); table.clear(gems); clock.elapsed=0 end
	end

	return {
		AddPlayer = addPlayer,
		RemovePlayer = removePlayer,
		EndPlayer = endPlayer,
		Restart = restart,
	}
end
]====])
-- Source: src/server/shared/Actors.luau
addModule(modules,{"shared","Actors"},[====[
-- Procedural actor geometry; shared by enemies and summons.
return function(deps)
	local world = deps.world
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

	return {
		Block = block,
		Create = creature,
	}
end
]====])
-- Source: src/server/shared/PlayerState.luau
addModule(modules,{"shared","PlayerState"},[====[
-- Read-only queries over the session state table.
return function(deps)
	local states = deps.states
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

	return {
		RootOf = rootOf,
		LiveCount = liveCount,
		Paused = paused,
	}
end
]====])
-- Source: src/server/world/Waves.luau
addModule(modules,{"world","Waves"},[====[
-- Enemy spawning, movement and contact damage.
return function(deps)
	local states, enemies, rng = deps.states, deps.enemies, deps.rng
	local creature, rootOf, roundLength = deps.creature, deps.rootOf, deps.roundLength
	local spawnClock, nextEnemy = 0, 0
	local function spawn(dt,alive,elapsed)
		spawnClock-=dt
		if spawnClock<=0 and #enemies<65 and elapsed<roundLength then
			spawnClock=math.max(.28,1.1-elapsed*.004)/math.max(1,alive*.65)
			local a=rng:NextNumber(0,math.pi*2); local pos=Vector3.new(math.cos(a)*77,2.8,math.sin(a)*77)
			nextEnemy+=1
			local m=creature("Shade_"..nextEnemy,Color3.fromRGB(82,69,105),false)
			m:PivotTo(CFrame.new(pos)); m:SetAttribute("HP",26+math.floor(elapsed/20)*7)
			table.insert(enemies,{model=m,pos=pos,hp=26+math.floor(elapsed/20)*7,speed=9+math.min(5,elapsed/35),hitClock=0,slow=0})
		end
	end
	local function step(dt)
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
	end
	local function resetSpawn() spawnClock=0 end

	return {
		Spawn = spawn,
		Step = step,
		ResetSpawn = resetSpawn,
	}
end
]====])
entry.Parent=game.ServerScriptService
end

do
local entry=Instance.new("LocalScript")
entry.Name="SummonerClient"
entry.Source=[====[
-- Composition root. Install the Modules children together with this script.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local net = RS:WaitForChild("SummonerNet")
local modules = script:WaitForChild("Modules")
local combat = modules:WaitForChild("combat")
local flow = modules:WaitForChild("flow")
local world = modules:WaitForChild("world")
local input = require(combat:WaitForChild("Input"))({player=player,net=net})
local hud = require(flow:WaitForChild("HUD"))({player=player,net=net,input=input})
require(combat:WaitForChild("Effects"))({player=player,net=net,gui=hud.Gui})
require(world:WaitForChild("Camera"))({player=player})
require(world:WaitForChild("CharacterMotion"))()
net.Action:FireServer("ready")
print("[Summoner] HUD ready")
]====]
local modules=Instance.new("Folder");modules.Name="Modules";modules.Parent=entry
-- Source: src/client/Theme.luau
addModule(modules,{"Theme"},[====[
local palette={bg=Color3.fromRGB(15,25,34),card=Color3.fromRGB(25,40,50),text=Color3.fromRGB(234,244,244),muted=Color3.fromRGB(155,182,188),mint=Color3.fromRGB(93,242,207),gold=Color3.fromRGB(255,196,103)}
local function make(class,parent,props)
	local obj=Instance.new(class); for k,v in pairs(props) do obj[k]=v end; obj.Parent=parent; return obj
end
local function round(obj,radius) make("UICorner",obj,{CornerRadius=UDim.new(0,radius or 12)}) end
local function stroke(obj,color) make("UIStroke",obj,{Color=color or Color3.fromRGB(57,82,91),Thickness=1}) end
local function label(parent,text,size,pos,font,color)
	return make("TextLabel",parent,{BackgroundTransparency=1,Text=text,Size=size,Position=pos or UDim2.new(),Font=font or Enum.Font.GothamMedium,TextColor3=color or palette.text,TextSize=16,TextWrapped=true})
end
return {Palette=palette, Make=make, Round=round, Stroke=stroke, Label=label}
]====])
-- Source: src/client/combat/Effects.luau
addModule(modules,{"combat","Effects"},[====[
-- Client-only spell and summon presentation; never awards damage or XP.
return function(deps)
	local Players = game:GetService("Players")
	local RS = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	local ContentProvider = game:GetService("ContentProvider")
	local Lighting = game:GetService("Lighting")
	local RunService = game:GetService("RunService")
	local player, net, gui = deps.player, deps.net, deps.gui
	local theme = require(script.Parent.Parent:WaitForChild("Theme"))
	local palette, make, label = theme.Palette, theme.Make, theme.Label
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

	return {
		Folder = fx,
	}
end
]====])
-- Source: src/client/combat/Input.luau
addModule(modules,{"combat","Input"},[====[
-- Keyboard and HUD actions share the same client requests.
return function(deps)
	local UIS = game:GetService("UserInputService")
	local player, net = deps.player, deps.net
	local function requestDash()
		local char=player.Character;local h=char and char:FindFirstChildOfClass("Humanoid");local root=char and char:FindFirstChild("HumanoidRootPart")
		if not h or not root then return end
		local direction=h.MoveDirection.Magnitude>.1 and h.MoveDirection or root.CFrame.LookVector
		net.Action:FireServer("dash",direction)
	end
	local function fireWave() net.Action:FireServer("fireWave") end
	UIS.InputBegan:Connect(function(input,processed)
		if processed then return end
		if input.KeyCode==Enum.KeyCode.Q then net.Action:FireServer("fireWave")
		elseif input.KeyCode==Enum.KeyCode.E then requestDash() end
	end)

	return {
		Dash = requestDash,
		FireWave = fireWave,
	}
end
]====])
-- Source: src/client/flow/HUD.luau
addModule(modules,{"flow","HUD"},[====[
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
]====])
-- Source: src/client/world/Camera.luau
addModule(modules,{"world","Camera"},[====[
-- Standard Roblox orbit camera setup.
return function(deps)
	local player = deps.player
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

	return {
	}
end
]====])
-- Source: src/client/world/CharacterMotion.luau
addModule(modules,{"world","CharacterMotion"},[====[
-- Reused CC0 R15 leg clips. Roblox Animate keeps ownership of the upper body.
-- Presentation only: no root displacement, jump physics or server state changes.
return function()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local folder = script.Parent:WaitForChild("clips")
	local clips = {
		walk = require(folder:WaitForChild("Walk_Carry_Loop")),
		jump = require(folder:WaitForChild("NinjaJump_Start")),
		air = require(folder:WaitForChild("NinjaJump_Idle_Loop")),
		land = require(folder:WaitForChild("NinjaJump_Land")),
	}
	local legs = {LeftHip=true,RightHip=true,LeftKnee=true,RightKnee=true,LeftAnkle=true,RightAnkle=true}
	local records = {}
	local function sample(clip, time)
		local t = clip.Loop and time % clip.Duration or math.clamp(time,0,clip.Duration)
		local frames = clip.Frames
		local index = math.clamp(math.floor(t*60)+1,1,#frames)
		local a, b = frames[index], frames[math.min(index+1,#frames)]
		local alpha = math.clamp((t-a.Time)/math.max(b.Time-a.Time,.00001),0,1)
		local pose = {}
		for name in pairs(legs) do pose[name] = a.Pose[name]:Lerp(b.Pose[name],alpha) end
		return pose
	end
	local function restore(record)
		for motor, transform in pairs(record.restore) do
			if motor.Parent then motor.Transform = transform end
		end
		table.clear(record.restore)
	end
	-- Restore the previous frame before Animator writes; prevents additive drift.
	local before = RunService.PreAnimation:Connect(function()
		for _, record in pairs(records) do restore(record) end
	end)
	local step = RunService.PreSimulation:Connect(function(dt)
		dt = math.min(dt,.1)
		local live = {}
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoid or not root or humanoid.RigType ~= Enum.HumanoidRigType.R15 then continue end
			live[character] = true
			local record = records[character]
			if not record then
				record = {motors={},restore={},phase=0,time=0,weight=0,mode="idle",wasAir=false,pose=nil}
				for _, child in ipairs(character:GetDescendants()) do
					if child:IsA("Motor6D") and legs[child.Name] then record.motors[child.Name] = child end
				end
				records[character] = record
			end
			local state = humanoid:GetState()
			local velocity = root.AssemblyLinearVelocity
			local speed = Vector3.new(velocity.X,0,velocity.Z).Magnitude
			local airborne = state==Enum.HumanoidStateType.Jumping or state==Enum.HumanoidStateType.Freefall
			local blocked = humanoid.Health<=0 or humanoid.WalkSpeed<=0 or humanoid.Sit or humanoid.PlatformStand
				or state==Enum.HumanoidStateType.Swimming or state==Enum.HumanoidStateType.Climbing
			local mode = "idle"
			if not blocked then
				if airborne then
					mode = (not record.wasAir or (record.mode=="jump" and record.time<.18)) and "jump" or "air"
				elseif record.wasAir or (record.mode=="land" and record.time<.2) then mode="land"
				elseif speed>1 and humanoid.AutoRotate then mode="walk" end
			end
			if mode~=record.mode then record.time=0;record.mode=mode end
			record.time+=dt;record.wasAir=airborne
			local target = clips[mode]
			if target then
				local time = record.time
				if mode=="walk" then
					record.phase+=dt*math.clamp(speed/7,.5,3.5);time=record.phase
				elseif mode=="jump" then time=math.min(time/.18,1)*target.Duration
				elseif mode=="land" then time=math.min(time/.2,1)*target.Duration end
				local pose=sample(target,time)
				if record.pose then for name,value in pairs(pose) do pose[name]=record.pose[name]:Lerp(value,1-math.exp(-dt*22)) end end
				record.pose=pose
			end
			record.weight+=( (target and 1 or 0)-record.weight)*(1-math.exp(-dt*18))
			if humanoid.Health<=0 then record.weight=0 end
			if record.pose and record.weight>.001 then
				for name,motor in pairs(record.motors) do
					if motor.Parent then record.restore[motor]=motor.Transform;motor.Transform=motor.Transform:Lerp(record.pose[name],record.weight) end
				end
			end
			character:SetAttribute("SummonerMotion",mode)
		end
		for character,record in pairs(records) do
			if not live[character] then restore(record);records[character]=nil end
		end
	end)
	return {Destroy=function()
		before:Disconnect();step:Disconnect()
		for character,record in pairs(records) do restore(record);character:SetAttribute("SummonerMotion",nil) end
		table.clear(records)
	end}
end
]====])
-- Source: src/client/world/clips/NinjaJump_Idle_Loop.luau
addModule(modules,{"world","clips","NinjaJump_Idle_Loop"},[====[
--!strict
-- Actual provider GLB retarget; fixed 1e-5 quantization, no new motion keys.
local joints={"Root","RightHip","RightKnee","RightAnkle","LeftHip","LeftKnee","LeftAnkle","Waist","LeftShoulder","LeftElbow","LeftWrist","RightShoulder","RightElbow","RightWrist","Neck"}
local rows={
{0,-13114,0,57800,-30741,20724,113426,23078,39199,-270710,23633,-10833,-58918,38739,22167,79803,-43507,-106119,-276744,15268,-5973,-38838,-83216,-8437,-162113,-11196,11812,-17861,40060,-4387,114911,64173,-86551,44040,20941,-14449,6298,25497,52220,-18700,-12629,23916,23019,23714,26849,57026,25949,1237},
{0,-13117,0,57789,-30744,20704,113003,22957,39182,-270344,23601,-10922,-58819,38767,22167,79557,-43384,-106191,-276639,14881,-5841,-38690,-82963,-8343,-161894,-11411,11889,-17993,40315,-4423,114857,64141,-86499,44040,20941,-14449,6347,25612,52095,-18776,-12413,23952,23019,23714,26849,56871,26115,1070},
{0,-13119,0,57778,-30747,20684,112581,22836,39165,-269978,23568,-11010,-58719,38794,22167,79311,-43262,-106263,-276533,14495,-5709,-38543,-82711,-8250,-161674,-11625,11966,-18125,40570,-4460,114803,64108,-86447,44040,20941,-14449,6396,25726,51969,-18852,-12196,23989,23019,23714,26849,56716,26281,903},
{0,-13127,0,57746,-30755,20626,112197,22734,39162,-269613,23502,-11083,-58639,38841,22172,79042,-43121,-106328,-276428,14032,-5545,-38374,-82421,-8148,-161438,-11864,12056,-18229,40781,-4527,114767,64054,-86404,44040,20941,-14449,6454,25861,51827,-18857,-11950,24023,23019,23714,26849,56535,26454,734},
{0,-13134,0,57714,-30763,20568,111813,22632,39159,-269249,23435,-11155,-58559,38888,22177,78773,-42979,-106392,-276322,13569,-5381,-38206,-82131,-8048,-161201,-12104,12147,-18332,40992,-4595,114731,63999,-86361,44040,20941,-14449,6512,25996,51684,-18861,-11704,24056,23019,23714,26849,56354,26628,566},
{0,-13146,0,57663,-30776,20474,111470,22550,39170,-268892,23339,-11211,-58499,38952,22186,78485,-42822,-106447,-276216,13040,-5188,-38021,-81808,-7941,-160949,-12365,12249,-18409,41163,-4692,114712,63924,-86327,44040,20941,-14449,6578,26149,51526,-18801,-11433,24085,23019,23714,26849,56149,26806,397},
{0,-13157,0,57612,-30789,20380,111127,22467,39181,-268534,23242,-11267,-58438,39016,22196,78198,-42664,-106502,-276109,12511,-4995,-37837,-81485,-7836,-160696,-12627,12351,-18486,41333,-4788,114693,63849,-86292,44040,20941,-14449,6643,26302,51368,-18741,-11162,24114,23019,23714,26849,55944,26985,228},
{0,-13173,0,57543,-30806,20254,110828,22404,39206,-268190,23119,-11306,-58395,39094,22208,77896,-42492,-106546,-276003,11924,-4777,-37639,-81135,-7728,-160431,-12908,12464,-18538,41464,-4912,114690,63754,-86266,44040,20941,-14449,6716,26470,51195,-18623,-10870,24138,23019,23714,26849,55718,27167,61},
{0,-13188,0,57474,-30822,20127,110530,22341,39231,-267845,22996,-11344,-58353,39173,22221,77595,-42320,-106590,-275895,11338,-4559,-37443,-80784,-7621,-160165,-13188,12578,-18589,41596,-5036,114686,63659,-86239,44040,20941,-14449,6789,26639,51021,-18506,-10578,24162,23018,23714,26849,55491,27351,-107},
{0,-13207,0,57388,-30842,19971,110278,22299,39269,-267518,22850,-11366,-58328,39265,22235,77284,-42137,-106622,-275786,10703,-4319,-37237,-80410,-7514,-159889,-13485,12702,-18617,41690,-5184,114697,63547,-86220,44040,20941,-14449,6868,26820,50835,-18337,-10269,24181,23019,23714,26849,55245,27537,-272},
{0,-13226,0,57303,-30862,19814,110027,22256,39308,-267191,22704,-11387,-58303,39357,22250,76973,-41953,-106653,-275676,10069,-4078,-37032,-80036,-7407,-159612,-13781,12826,-18644,41785,-5333,114708,63435,-86200,44040,20941,-14449,6947,27001,50648,-18168,-9961,24199,23019,23714,26849,55000,27723,-438},
{0,-13248,0,57202,-30884,19630,109824,22233,39360,-266887,22539,-11390,-58293,39460,22266,76656,-41759,-106671,-275566,9395,-3818,-36821,-79642,-7302,-159326,-14091,12959,-18649,41845,-5504,114732,63306,-86187,44040,20941,-14449,7031,27192,50450,-17956,-9640,24212,23019,23714,26849,54737,27911,-600},
{0,-13270,0,57102,-30906,19446,109622,22210,39411,-266583,22374,-11393,-58284,39563,22282,76340,-41566,-106689,-275454,8722,-3558,-36612,-79249,-7199,-159040,-14401,13094,-18654,41905,-5676,114755,63178,-86174,44040,20941,-14449,7116,27383,50251,-17743,-9319,24224,23019,23714,26849,54474,28100,-762},
{0,-13295,0,56988,-30929,19238,109471,22208,39475,-266308,22192,-11379,-58290,39676,22298,76022,-41365,-106693,-275341,8017,-3282,-36399,-78840,-7099,-158748,-14721,13235,-18639,41933,-5867,114791,63035,-86167,44040,20941,-14449,7205,27582,50042,-17493,-8990,24231,23019,23714,26849,54197,28289,-919},
{0,-13319,0,56874,-30952,19029,109321,22206,39540,-266032,22010,-11364,-58296,39789,22315,75705,-41164,-106696,-275227,7313,-3005,-36189,-78431,-7001,-158455,-15040,13378,-18623,41961,-6059,114827,62892,-86160,44040,20941,-14449,7295,27781,49832,-17244,-8661,24237,23018,23714,26849,53920,28478,-1077},
{0,-13346,0,56748,-30977,18799,109225,22224,39615,-265790,21813,-11331,-58315,39911,22332,75389,-40958,-106685,-275112,6586,-2716,-35978,-78012,-6908,-158158,-15367,13527,-18589,41958,-6269,114873,62736,-86158,44040,20941,-14449,7388,27985,49614,-16964,-8329,24237,23018,23714,26849,53630,28667,-1229},
{0,-13372,0,56622,-31001,18569,109129,22243,39691,-265548,21617,-11297,-58334,40033,22349,75074,-40753,-106673,-274995,5859,-2426,-35768,-77592,-6816,-157861,-15694,13677,-18554,41955,-6478,114920,62580,-86156,44040,20941,-14449,7481,28189,49395,-16683,-7997,24237,23019,23714,26849,53340,28856,-1380},
{0,-13400,0,56486,-31025,18320,109090,22281,39776,-265345,21408,-11245,-58365,40163,22365,74763,-40544,-106648,-274879,5116,-2127,-35561,-77165,-6730,-157561,-16025,13832,-18502,41924,-6704,114976,62413,-86159,44040,20941,-14449,7577,28396,49170,-16380,-7666,24231,23018,23714,26849,53040,29043,-1525},
{0,-13428,0,56349,-31049,18071,109052,22320,39862,-265142,21200,-11193,-58396,40293,22382,74453,-40335,-106621,-274760,4374,-1827,-35355,-76738,-6646,-157262,-16356,13988,-18451,41893,-6929,115032,62245,-86162,44040,20941,-14449,7674,28602,48944,-16076,-7335,24225,23019,23714,26849,52741,29231,-1670},
{0,-13458,0,56203,-31072,17805,109073,22380,39957,-264983,20981,-11122,-58438,40429,22398,74152,-40126,-106581,-274641,3624,-1520,-35154,-76307,-6570,-156962,-16688,14147,-18383,41836,-7167,115097,62068,-86169,44040,20941,-14449,7772,28810,48712,-15755,-7009,24213,23018,23714,26849,52433,29416,-1807},
{0,-13487,0,56057,-31095,17539,109093,22439,40051,-264824,20762,-11050,-58481,40566,22415,73850,-39917,-106540,-274520,2874,-1212,-34954,-75877,-6495,-156663,-17020,14308,-18316,41778,-7405,115161,61891,-86177,44040,20941,-14449,7870,29017,48481,-15435,-6683,24201,23019,23714,26849,52126,29601,-1944},
{0,-13517,0,55904,-31117,17260,109177,22519,40153,-264714,20533,-10960,-58533,40709,22430,73559,-39709,-106486,-274401,2123,-900,-34761,-75446,-6428,-156366,-17351,14471,-18235,41697,-7654,115234,61706,-86188,44040,20941,-14449,7970,29222,48246,-15104,-6367,24185,23019,23714,26849,51812,29781,-2072},
{0,-13546,0,55751,-31138,16981,109261,22600,40255,-264604,20305,-10869,-58586,40851,22446,73269,-39501,-106431,-274279,1372,-587,-34569,-75016,-6363,-156068,-17681,14636,-18154,41615,-7902,115306,61521,-86199,44040,20941,-14449,8070,29427,48011,-14773,-6051,24167,23019,23714,26849,51499,29962,-2200},
{0,-13577,0,55592,-31158,16691,109411,22701,40363,-264550,20069,-10759,-58648,41000,22461,72993,-39297,-106363,-274160,627,-274,-34385,-74589,-6308,-155776,-18008,14800,-18061,41512,-8159,115384,61329,-86213,44040,20941,-14449,8169,29628,47774,-14439,-5750,24146,23019,23714,26849,51183,30137,-2318},
{0,-13607,0,55432,-31177,16401,109561,22802,40470,-264495,19832,-10649,-58710,41148,22477,72716,-39093,-106295,-274039,-118,41,-34203,-74162,-6254,-155484,-18334,14966,-17969,41408,-8415,115463,61137,-86227,44040,20941,-14449,8269,29829,47537,-14104,-5449,24124,23019,23714,26849,50867,30313,-2436},
{0,-13637,0,55268,-31194,16104,109781,22925,40582,-264501,19587,-10519,-58782,41302,22492,72456,-38894,-106216,-273920,-852,354,-34030,-73742,-6209,-155199,-18654,15131,-17866,41285,-8677,115547,60941,-86245,44040,20941,-14449,8368,30024,47300,-13773,-5166,24100,23019,23714,26849,50549,30481,-2543},
{0,-13667,0,55104,-31210,15806,110001,23048,40693,-264506,19342,-10389,-58854,41456,22506,72195,-38696,-106136,-273800,-1585,668,-33858,-73322,-6166,-154913,-18973,15298,-17763,41161,-8939,115631,60744,-86262,44040,20941,-14449,8467,30218,47063,-13442,-4883,24075,23019,23714,26849,50232,30650,-2650},
{0,-13697,0,54938,-31223,15503,110296,23192,40805,-264578,19090,-10239,-58936,41616,22521,71953,-38505,-106047,-273684,-2301,977,-33697,-72913,-6133,-154638,-19282,15461,-17651,41020,-9203,115720,60544,-86283,44040,20941,-14449,8564,30404,46829,-13121,-4624,24048,23018,23714,26849,49916,30811,-2745},
{0,-13726,0,54771,-31235,15200,110590,23336,40918,-264648,18837,-10089,-59018,41775,22536,71710,-38315,-105957,-273566,-3017,1287,-33537,-72503,-6101,-154363,-19592,15625,-17540,40878,-9468,115809,60344,-86303,44040,20941,-14449,8661,30590,46595,-12800,-4365,24020,23019,23714,26849,49600,30972,-2840},
{0,-13755,0,54603,-31244,14894,110936,23495,41029,-264765,18577,-9925,-59107,41939,22550,71488,-38133,-105858,-273455,-3709,1590,-33389,-72106,-6081,-154100,-19889,15785,-17422,40721,-9732,115901,60143,-86325,44040,20941,-14449,8755,30766,46365,-12495,-4133,23992,23019,23714,26849,49288,31122,-2922},
{0,-13784,0,54434,-31252,14589,111282,23654,41140,-264882,18317,-9761,-59197,42104,22565,71265,-37952,-105760,-273341,-4402,1893,-33241,-71710,-6061,-153837,-20186,15946,-17304,40564,-9997,115994,59941,-86348,44040,20941,-14449,8850,30941,46136,-12191,-3901,23963,23019,23714,26849,48975,31274,-3004},
{0,-13812,0,54267,-31256,14284,111653,23818,41248,-265020,18051,-9591,-59289,42272,22577,71064,-37782,-105654,-273235,-5066,2187,-33107,-71330,-6052,-153589,-20468,16101,-17180,40394,-10259,116089,59740,-86372,44040,20941,-14449,8939,31104,45913,-11910,-3701,23935,23019,23714,26849,48668,31414,-3072},
{0,-13840,0,54099,-31260,13979,112023,23983,41355,-265157,17786,-9421,-59382,42440,22589,70863,-37612,-105549,-273128,-5730,2481,-32973,-70949,-6044,-153341,-20750,16256,-17057,40223,-10521,116184,59538,-86397,44040,20941,-14449,9029,31267,45690,-11628,-3501,23907,23018,23714,26849,48362,31554,-3140},
{0,-13866,0,53933,-31259,13677,112413,24152,41458,-265313,17516,-9246,-59477,42611,22600,70685,-37455,-105439,-273030,-6360,2763,-32854,-70588,-6047,-153111,-21014,16403,-16930,40042,-10779,116282,59339,-86424,44040,20941,-14449,9114,31415,45476,-11378,-3337,23880,23019,23714,26849,48063,31681,-3194},
{0,-13893,0,53767,-31257,13375,112803,24320,41560,-265469,17246,-9072,-59573,42782,22610,70506,-37298,-105329,-272930,-6991,3045,-32734,-70227,-6051,-152880,-21278,16551,-16803,39860,-11036,116379,59139,-86450,44040,20941,-14449,9199,31564,45262,-11127,-3174,23853,23019,23714,26849,47764,31809,-3248},
{0,-13918,0,53605,-31250,13079,113209,24491,41656,-265641,16974,-8895,-59670,42955,22617,70353,-37156,-105217,-272842,-7583,3311,-32629,-69888,-6067,-152671,-21523,16689,-16674,39669,-11286,116478,58943,-86479,44040,20941,-14449,9277,31695,45060,-10913,-3050,23829,23019,23714,26849,47476,31923,-3286},
{0,-13943,0,53442,-31243,12783,113614,24661,41752,-265813,16702,-8718,-59767,43129,22625,70199,-37014,-105105,-272753,-8175,3578,-32524,-69550,-6083,-152461,-21767,16828,-16545,39478,-11536,116577,58747,-86507,44040,20941,-14449,9355,31827,44857,-10699,-2927,23805,23019,23714,26849,47188,32036,-3324},
{0,-13967,0,53285,-31230,12496,114031,24832,41841,-265999,16430,-8539,-59865,43303,22630,70071,-36888,-104993,-272677,-8724,3826,-32435,-69236,-6110,-152274,-21988,16954,-16415,39280,-11777,116676,58555,-86537,44040,20941,-14449,9425,31940,44669,-10530,-2849,23785,23018,23714,26849,46912,32134,-3346},
{0,-13990,0,53128,-31216,12209,114447,25003,41929,-266185,16157,-8361,-59963,43478,22635,69942,-36762,-104880,-272600,-9274,4075,-32345,-68922,-6138,-152087,-22210,17081,-16286,39082,-12017,116775,58364,-86567,44040,20941,-14449,9495,32053,44480,-10360,-2770,23765,23019,23714,26849,46637,32232,-3368},
{0,-14011,0,52978,-31197,11934,114870,25171,42009,-266383,15885,-8184,-60061,43652,22636,69841,-36654,-104771,-272540,-9775,4302,-32272,-68635,-6178,-151926,-22406,17194,-16156,38880,-12245,116875,58180,-86599,44040,20941,-14449,9557,32145,44307,-10241,-2741,23750,23019,23714,26849,46376,32313,-3373},
{0,-14033,0,52828,-31177,11658,115293,25340,42088,-266581,15614,-8007,-60159,43827,22638,69740,-36546,-104661,-272478,-10276,4529,-32199,-68349,-6218,-151765,-22602,17308,-16028,38678,-12473,116974,57996,-86631,44040,20941,-14449,9618,32237,44134,-10122,-2711,23736,23019,23714,26849,46115,32394,-3378},
{0,-14052,0,52687,-31150,11397,115718,25505,42159,-266789,15346,-7832,-60255,44000,22635,69667,-36458,-104555,-272434,-10726,4732,-32142,-68094,-6270,-151632,-22770,17405,-15901,38473,-12687,117072,57820,-86664,44040,20941,-14449,9669,32307,43979,-10060,-2735,23727,23019,23714,26849,45872,32457,-3365},
{0,-14072,0,52546,-31123,11136,116142,25670,42229,-266996,15078,-7657,-60351,44173,22633,69594,-36370,-104450,-272389,-11175,4936,-32085,-67838,-6322,-151500,-22939,17503,-15774,38268,-12900,117171,57644,-86698,44040,20941,-14449,9721,32377,43824,-9999,-2759,23718,23019,23714,26849,45628,32519,-3353},
{0,-14089,0,52415,-31090,10892,116564,25829,42291,-267212,14816,-7486,-60445,44345,22626,69550,-36302,-104351,-272365,-11567,5112,-32046,-67616,-6386,-151398,-23077,17582,-15650,38063,-13097,117268,57479,-86733,44040,20941,-14449,9760,32422,43690,-9975,-2823,23714,23018,23714,26849,45404,32561,-3322},
{0,-14107,0,52284,-31056,10647,116985,25989,42351,-267427,14554,-7316,-60538,44516,22619,69506,-36235,-104253,-272340,-11959,5288,-32007,-67394,-6450,-151297,-23215,17662,-15527,37858,-13294,117365,57313,-86767,44040,20941,-14449,9800,32467,43555,-9951,-2888,23709,23019,23714,26849,45181,32603,-3291},
{0,-14122,0,52165,-31014,10423,117398,26141,42402,-267649,14301,-7151,-60628,44683,22607,69494,-36191,-104163,-272338,-12289,5433,-31986,-67208,-6526,-151230,-23320,17723,-15408,37656,-13473,117460,57160,-86804,44040,20941,-14449,9827,32486,43443,-9939,-2979,23705,23019,23714,26849,44979,32623,-3241},
{0,-14137,0,52047,-30973,10199,117811,26293,42452,-267870,14048,-6987,-60717,44851,22595,69481,-36146,-104074,-272335,-12619,5579,-31964,-67023,-6603,-151162,-23425,17783,-15289,37453,-13650,117556,57006,-86841,44040,20941,-14449,9854,32505,43330,-9927,-3070,23701,23019,23714,26849,44777,32643,-3191},
{0,-14149,0,51942,-30924,9997,118211,26435,42493,-268095,13806,-6830,-60800,45013,22577,69502,-36127,-103995,-272359,-12880,5690,-31963,-66878,-6692,-151142,-23486,17817,-15170,37243,-13806,117651,56867,-86882,44040,20941,-14449,9866,32492,43249,-9921,-3195,23697,23019,23714,26849,44606,32632,-3115},
{0,-14162,0,51837,-30875,9795,118610,26578,42534,-268320,13564,-6674,-60883,45176,22559,69524,-36108,-103917,-272383,-13141,5801,-31961,-66734,-6782,-151121,-23548,17850,-15052,37032,-13961,117747,56728,-86923,44040,20941,-14449,9877,32478,43167,-9914,-3320,23693,23019,23714,26849,44434,32621,-3039},
{0,-14172,0,51748,-30818,9619,118990,26709,42564,-268548,13338,-6526,-60958,45332,22535,69580,-36115,-103852,-272433,-13330,5875,-31981,-66632,-6885,-151156,-23559,17853,-14931,36809,-14090,117845,56606,-86970,44040,20941,-14449,9869,32429,43122,-9909,-3484,23688,23019,23714,26849,44299,32573,-2932},
{0,-14182,0,51659,-30761,9443,119371,26840,42594,-268775,13111,-6379,-61034,45488,22511,69635,-36123,-103786,-272484,-13518,5949,-32000,-66530,-6987,-151190,-23569,17855,-14810,36586,-14218,117942,56485,-87018,44040,20941,-14449,9862,32380,43078,-9903,-3648,23683,23019,23714,26849,44164,32525,-2824},
{0,-14190,0,51587,-30696,9294,119726,26959,42615,-269003,12903,-6243,-61099,45636,22479,69724,-36156,-103735,-272561,-13632,5987,-32040,-66471,-7103,-151276,-23531,17828,-14692,36359,-14320,118039,56381,-87070,44040,20941,-14449,9836,32294,43067,-9901,-3846,23677,23019,23714,26849,44064,32442,-2690},
{0,-14198,0,51515,-30630,9146,120082,27077,42636,-269230,12694,-6107,-61164,45784,22447,69813,-36188,-103684,-272637,-13747,6025,-32081,-66412,-7218,-151363,-23492,17800,-14573,36132,-14422,118136,56277,-87122,44040,20941,-14449,9811,32209,43056,-9899,-4044,23671,23019,23714,26849,43964,32359,-2555},
{0,-14202,0,51463,-30556,9028,120406,27181,42647,-269456,12508,-5984,-61217,45922,22408,69933,-36247,-103647,-272738,-13785,6025,-32143,-66395,-7347,-151497,-23406,17745,-14457,35902,-14499,118230,56193,-87178,44040,20941,-14449,9770,32093,43075,-9901,-4270,23664,23019,23714,26849,43898,32245,-2396},
{0,-14207,0,51410,-30482,8910,120731,27285,42658,-269682,12321,-5861,-61270,46060,22368,70054,-36305,-103611,-272838,-13824,6025,-32205,-66378,-7476,-151632,-23321,17689,-14340,35672,-14577,118324,56108,-87233,44040,20941,-14449,9729,31977,43094,-9903,-4497,23658,23019,23714,26849,43833,32130,-2238},
{0,-14209,0,51378,-30400,8826,121019,27373,42661,-269905,12161,-5753,-61308,46186,22319,70206,-36389,-103590,-272961,-13784,5988,-32291,-66404,-7617,-151812,-23189,17607,-14224,35436,-14634,118414,56045,-87290,44040,20941,-14449,9676,31838,43138,-9910,-4748,23650,23019,23714,26849,43801,31987,-2059},
{0,-14211,0,51346,-30317,8742,121307,27460,42663,-270127,12000,-5645,-61347,46313,22270,70357,-36473,-103569,-273084,-13744,5951,-32376,-66430,-7759,-151991,-23058,17526,-14107,35200,-14691,118503,55981,-87348,44040,20941,-14449,9623,31699,43182,-9917,-5000,23643,23018,23714,26849,43769,31843,-1880},
{0,-14210,0,51335,-30226,8691,121555,27531,42658,-270346,11869,-5552,-61369,46426,22211,70539,-36581,-103564,-273226,-13625,5877,-32485,-66499,-7914,-152212,-22883,17420,-13992,34961,-14730,118586,55939,-87406,44040,20941,-14449,9560,31539,43248,-9930,-5274,23634,23019,23714,26849,43770,31673,-1684},
{0,-14209,0,51323,-30135,8641,121803,27601,42652,-270564,11738,-5460,-61390,46539,22152,70722,-36690,-103559,-273369,-13506,5803,-32595,-66568,-8069,-152432,-22707,17314,-13877,34722,-14768,118669,55897,-87464,44040,20941,-14449,9496,31380,43313,-9943,-5547,23626,23019,23714,26849,43771,31504,-1488},
{0,-14206,0,51330,-30037,8623,122014,27656,42639,-270778,11637,-5383,-61396,46637,22085,70933,-36823,-103567,-273529,-13312,5695,-32728,-66678,-8236,-152690,-22491,17187,-13762,34481,-14788,118746,55879,-87524,44040,20941,-14449,9423,31201,43399,-9961,-5840,23617,23019,23714,26849,43803,31311,-1279},
{0,-14203,0,51337,-29939,8605,122225,27711,42626,-270991,11535,-5307,-61402,46736,22017,71145,-36955,-103575,-273689,-13117,5588,-32861,-66788,-8403,-152947,-22275,17061,-13648,34240,-14808,118822,55861,-87583,44040,20941,-14449,9351,31023,43485,-9980,-6134,23608,23019,23714,26849,43836,31119,-1069},
{0,-14198,0,51360,-29836,8616,122400,27751,42607,-271200,11462,-5245,-61394,46821,21943,71385,-37109,-103593,-273865,-12851,5449,-33015,-66937,-8579,-153235,-22023,16916,-13536,34000,-14810,118890,55868,-87643,44040,20941,-14449,9270,30828,43588,-10004,-6443,23597,23019,23714,26849,43899,30906,-849},
{0,-14192,0,51384,-29733,8627,122576,27791,42588,-271408,11389,-5183,-61385,46905,21868,71624,-37263,-103612,-274040,-12586,5311,-33170,-67086,-8756,-153523,-21771,16773,-13425,33759,-14813,118958,55876,-87703,44040,20941,-14449,9190,30633,43691,-10029,-6753,23587,23019,23714,26849,43963,30694,-629},
{0,-14185,0,51423,-29626,8666,122718,27818,42564,-271611,11344,-5135,-61364,46975,21788,71889,-37436,-103639,-274227,-12253,5144,-33345,-67271,-8940,-153838,-21487,16615,-13316,33523,-14799,119015,55911,-87761,44040,20941,-14449,9102,30424,43808,-10060,-7075,23576,23019,23714,26849,44056,30464,-402},
{0,-14177,0,51463,-29520,8706,122859,27845,42540,-271815,11300,-5087,-61343,47045,21707,72154,-37610,-103666,-274414,-11919,4979,-33521,-67457,-9125,-154153,-21202,16457,-13208,33286,-14785,119073,55945,-87820,44040,20941,-14449,9015,30215,43926,-10091,-7397,23564,23018,23714,26849,44149,30235,-174},
{0,-14167,0,51517,-29411,8771,122968,27859,42512,-272011,11283,-5053,-61310,47100,21622,72442,-37800,-103700,-274610,-11522,4787,-33715,-67677,-9317,-154489,-20890,16289,-13104,33056,-14756,119119,56008,-87877,44040,20941,-14449,8922,29993,44056,-10129,-7729,23552,23018,23714,26849,44270,29992,57},
{0,-14158,0,51571,-29302,8836,123077,27872,42483,-272208,11266,-5019,-61276,47155,21537,72731,-37991,-103732,-274806,-11124,4597,-33911,-67896,-9509,-154824,-20577,16121,-13000,32826,-14726,119165,56071,-87934,44040,20941,-14449,8830,29772,44185,-10167,-8060,23540,23019,23714,26849,44392,29749,289},
{0,-14146,0,51639,-29193,8926,123155,27874,42451,-272398,11277,-4999,-61232,47195,21448,73041,-38198,-103770,-275009,-10665,4383,-34124,-68149,-9706,-155177,-20241,15945,-12902,32605,-14682,119199,56160,-87988,44040,20941,-14449,8733,29541,44325,-10213,-8397,23527,23019,23714,26849,44541,29496,522},
{0,-14134,0,51706,-29083,9016,123233,27876,42419,-272588,11288,-4978,-61188,47234,21360,73352,-38404,-103806,-275211,-10206,4170,-34338,-68401,-9905,-155529,-19905,15770,-12804,32385,-14638,119234,56248,-88042,44040,20941,-14449,8636,29310,44465,-10260,-8735,23513,23019,23714,26849,44691,29243,756},
{0,-14121,0,51787,-28974,9130,123281,27867,42383,-272770,11327,-4970,-61134,47258,21269,73682,-38624,-103844,-275417,-9689,3937,-34569,-68684,-10106,-155893,-19549,15589,-12713,32176,-14580,119257,56360,-88094,44040,20941,-14449,8536,29071,44613,-10314,-9074,23499,23019,23714,26849,44866,28982,987},
{0,-14108,0,51867,-28865,9243,123328,27857,42347,-272952,11365,-4962,-61080,47282,21179,74012,-38844,-103882,-275622,-9172,3705,-34801,-68967,-10309,-156257,-19193,15410,-12621,31968,-14522,119280,56472,-88145,44040,20941,-14449,8437,28832,44760,-10369,-9414,23485,23019,23714,26849,45042,28722,1219},
{0,-14092,0,51959,-28758,9377,123348,27837,42309,-273126,11430,-4967,-61018,47289,21087,74360,-39075,-103920,-275828,-8602,3455,-35048,-69278,-10513,-156628,-18822,15227,-12538,31775,-14450,119292,56605,-88193,44040,20941,-14449,8335,28588,44913,-10433,-9752,23470,23019,23714,26849,45242,28458,1447},
{0,-14077,0,52050,-28651,9512,123367,27817,42270,-273300,11495,-4971,-60956,47296,20996,74708,-39306,-103956,-276033,-8031,3206,-35296,-69588,-10719,-156999,-18450,15046,-12455,31582,-14379,119304,56738,-88240,44040,20941,-14449,8234,28344,45066,-10497,-10090,23455,23019,23714,26849,45442,28195,1675},
{0,-14060,0,52152,-28547,9666,123360,27787,42229,-273464,11586,-4987,-60886,47287,20905,75072,-39545,-103991,-276237,-7411,2942,-35557,-69925,-10925,-157373,-18068,14864,-12381,31408,-14295,119305,56890,-88283,44040,20941,-14449,8132,28097,45224,-10570,-10423,23439,23019,23714,26849,45679,27930,1892},
{0,-14043,0,52254,-28443,9820,123352,27757,42187,-273629,11677,-5004,-60817,47278,20813,75435,-39785,-104025,-276439,-6791,2679,-35820,-70261,-11132,-157746,-17686,14683,-12307,31233,-14211,119306,57042,-88326,44040,20941,-14449,8030,27850,45381,-10643,-10756,23423,23019,23714,26849,45917,27667,2110},
{0,-14024,0,52366,-28343,9993,123319,27718,42144,-273783,11794,-5032,-60742,47252,20724,75810,-40031,-104055,-276637,-6126,2403,-36094,-70620,-11338,-158118,-17297,14504,-12244,31080,-14114,119295,57210,-88364,44040,20941,-14449,7928,27603,45542,-10727,-11081,23407,23019,23714,26849,46199,27406,2313},
{0,-14005,0,52477,-28244,10166,123285,27679,42100,-273937,11911,-5060,-60666,47225,20634,76186,-40277,-104085,-276833,-5461,2129,-36369,-70979,-11545,-158490,-16908,14327,-12181,30927,-14018,119285,57378,-88402,44040,20941,-14449,7827,27356,45702,-10811,-11406,23391,23019,23714,26849,46481,27146,2515},
{0,-13985,0,52596,-28150,10355,123229,27631,42054,-274081,12052,-5099,-60586,47182,20548,76570,-40527,-104109,-277024,-4758,1844,-36653,-71359,-11748,-158855,-16517,14153,-12129,30798,-13909,119263,57560,-88434,44040,20941,-14449,7726,27111,45863,-10905,-11720,23375,23019,23714,26849,46801,26892,2702},
{0,-13965,0,52715,-28057,10545,123172,27583,42008,-274224,12194,-5138,-60506,47138,20461,76955,-40776,-104133,-277211,-4053,1561,-36939,-71738,-11953,-159221,-16126,13980,-12078,30669,-13801,119241,57743,-88466,44040,20941,-14449,7627,26866,46025,-10999,-12033,23359,23019,23714,26849,47121,26640,2889},
{0,-13943,0,52843,-27985,10757,123109,27530,41956,-274356,12368,-5191,-60442,47063,20392,77336,-41022,-104152,-277388,-3308,1267,-37219,-72145,-12132,-159576,-15738,13812,-12043,30571,-13665,119209,57937,-88492,44040,20941,-14449,7528,26633,46201,-11105,-12330,23343,23018,23714,26849,47471,26397,3058},
{0,-13921,0,52972,-27912,10969,123046,27477,41904,-274488,12543,-5245,-60379,46987,20322,77717,-41268,-104170,-277563,-2562,974,-37500,-72552,-12313,-159931,-15350,13646,-12008,30472,-13529,119177,58131,-88518,44040,20941,-14449,7431,26399,46376,-11211,-12627,23327,23018,23714,26849,47822,26155,3229},
{0,-13898,0,53109,-27874,11207,122964,27415,41848,-274605,12762,-5318,-60322,46869,20281,78082,-41502,-104186,-277723,-1777,670,-37763,-72992,-12448,-160271,-14969,13487,-11992,30409,-13353,119135,58336,-88538,44040,20941,-14449,7335,26185,46577,-11330,-12904,23312,23019,23714,26849,48197,25926,3380},
{0,-13875,0,53247,-27835,11445,122881,27353,41792,-274722,12982,-5391,-60266,46751,20240,78447,-41737,-104201,-277879,-991,368,-38027,-73432,-12586,-160611,-14588,13329,-11977,30347,-13178,119093,58540,-88559,44040,20941,-14449,7240,25970,46778,-11448,-13182,23296,23019,23714,26849,48572,25698,3533},
{0,-13851,0,53392,-27827,11707,122789,27285,41731,-274824,13241,-5482,-60225,46594,20224,78793,-41959,-104213,-278019,-175,59,-38271,-73899,-12681,-160933,-14220,13179,-11982,30322,-12968,119041,58751,-88572,44040,20941,-14449,7149,25774,46998,-11580,-13435,23282,23019,23714,26849,48963,25486,3665},
{0,-13827,0,53538,-27818,11968,122697,27217,41670,-274926,13499,-5572,-60184,46437,20208,79140,-42181,-104224,-278157,642,-249,-38517,-74365,-12779,-161254,-13851,13030,-11987,30297,-12758,118988,58963,-88585,44040,20941,-14449,7057,25579,47218,-11711,-13689,23268,23019,23714,26849,49355,25276,3799},
{0,-13803,0,53689,-27837,12249,122594,27143,41604,-275013,13792,-5677,-60155,46245,20214,79464,-42388,-104233,-278275,1477,-561,-38743,-74850,-12837,-161554,-13500,12891,-12013,30312,-12519,118925,59179,-88589,44040,20941,-14449,6971,25403,47453,-11856,-13917,23256,23019,23714,26849,49756,25084,3911},
{0,-13778,0,53841,-27855,12530,122492,27070,41538,-275099,14085,-5783,-60127,46054,20220,79789,-42596,-104242,-278392,2312,-872,-38970,-75336,-12898,-161852,-13148,12752,-12039,30327,-12279,118861,59396,-88594,44040,20941,-14449,6884,25227,47687,-12001,-14144,23243,23019,23714,26849,50158,24894,4023},
{0,-13752,0,53997,-27897,12826,122379,26991,41469,-275170,14407,-5901,-60109,45832,20244,80089,-42787,-104249,-278488,3155,-1183,-39175,-75832,-12922,-162125,-12819,12625,-12087,30384,-12016,118786,59615,-88589,44040,20941,-14449,6803,25073,47931,-12159,-14342,23233,23019,23714,26849,50562,24726,4113},
{0,-13726,0,54153,-27939,13123,122266,26912,41400,-275240,14729,-6020,-60091,45611,20269,80388,-42978,-104256,-278582,3998,-1493,-39381,-76329,-12947,-162397,-12489,12498,-12135,30440,-11752,118711,59833,-88584,44040,20941,-14449,6723,24918,48175,-12317,-14540,23223,23019,23714,26849,50966,24559,4204},
{0,-13700,0,54312,-28002,13432,122143,26829,41328,-275293,15075,-6150,-60082,45364,20309,80659,-43151,-104263,-278656,4835,-1799,-39564,-76828,-12939,-162639,-12187,12382,-12206,30541,-11470,118623,60052,-88568,44040,20941,-14449,6648,24785,48424,-12488,-14705,23215,23019,23714,26849,51367,24417,4270},
{0,-13674,0,54471,-28064,13741,122020,26745,41255,-275345,15421,-6281,-60073,45117,20350,80930,-43325,-104270,-278727,5673,-2105,-39748,-77328,-12931,-162880,-11884,12268,-12277,30641,-11187,118536,60271,-88553,44040,20941,-14449,6574,24652,48672,-12660,-14871,23208,23018,23714,26849,51767,24276,4336},
{0,-13648,0,54631,-28144,14058,121885,26656,41180,-275380,15785,-6421,-60070,44850,20403,81168,-43479,-104279,-278778,6492,-2403,-39906,-77822,-12892,-163088,-11613,12165,-12372,30787,-10889,118436,60487,-88526,44040,20941,-14449,6507,24543,48919,-12846,-15000,23204,23018,23714,26849,52157,24164,4376},
{0,-13621,0,54792,-28224,14376,121751,26568,41105,-275415,16150,-6561,-60068,44583,20456,81407,-43633,-104288,-278826,7312,-2701,-40066,-78316,-12854,-163295,-11342,12064,-12468,30932,-10592,118337,60703,-88500,44040,20941,-14449,6441,24434,49167,-13031,-15130,23200,23018,23714,26849,52547,24051,4417},
{0,-13595,0,54952,-28318,14698,121605,26476,41028,-275432,16527,-6709,-60070,44300,20520,81609,-43767,-104300,-278853,8101,-2988,-40198,-78797,-12786,-163463,-11108,11975,-12588,31125,-10285,118225,60915,-88461,44040,20941,-14449,6383,24349,49408,-13230,-15222,23201,23019,23714,26849,52919,23970,4429},
{0,-13568,0,55112,-28411,15021,121460,26383,40951,-275448,16904,-6857,-60073,44018,20584,81811,-43900,-104313,-278878,8890,-3276,-40331,-79277,-12719,-163632,-10874,11887,-12709,31318,-9978,118113,61126,-88423,44040,20941,-14449,6325,24265,49650,-13430,-15313,23201,23019,23714,26849,53291,23889,4441},
{0,-13542,0,55271,-28516,15344,121302,26287,40873,-275446,17289,-7011,-60078,43725,20655,81974,-44012,-104332,-278882,9635,-3548,-40435,-79734,-12624,-163759,-10682,11814,-12855,31560,-9667,117989,61330,-88373,44040,20941,-14449,6276,24207,49881,-13643,-15364,23207,23019,23714,26849,53639,23842,4423},
{0,-13515,0,55430,-28621,15668,121145,26191,40794,-275444,17673,-7165,-60083,43432,20727,82136,-44124,-104351,-278885,10379,-3820,-40539,-80192,-12529,-163885,-10489,11740,-13002,31801,-9355,117866,61534,-88322,44040,20941,-14449,6227,24148,50111,-13856,-15414,23212,23019,23714,26849,53987,23795,4405},
{0,-13489,0,55585,-28734,15988,120976,26091,40715,-275422,18058,-7323,-60089,43135,20804,82256,-44213,-104378,-278867,11067,-4074,-40612,-80618,-12409,-163965,-10343,11683,-13176,32093,-9044,117730,61729,-88260,44040,20941,-14449,6189,24119,50326,-14084,-15420,23223,23018,23714,26849,54304,23784,4354},
{0,-13463,0,55741,-28847,16309,120807,25991,40636,-275401,18443,-7481,-60096,42838,20881,82376,-44302,-104405,-278848,11755,-4327,-40685,-81044,-12289,-164045,-10197,11625,-13351,32385,-8732,117595,61924,-88197,44040,20941,-14449,6151,24089,50540,-14311,-15426,23235,23019,23714,26849,54620,23773,4304},
{0,-13438,0,55891,-28965,16624,120626,25888,40556,-275360,18823,-7641,-60101,42541,20961,82450,-44367,-104442,-278809,12373,-4559,-40726,-81430,-12145,-164086,-10092,11580,-13545,32714,-8424,117452,62108,-88126,44040,20941,-14449,6122,24084,50738,-14547,-15396,23251,23019,23714,26849,54907,23792,4226},
{0,-13412,0,56042,-29082,16938,120446,25786,40477,-275319,19203,-7802,-60107,42244,21042,82524,-44433,-104480,-278769,12992,-4790,-40767,-81816,-12000,-164127,-9987,11536,-13741,33043,-8116,117309,62293,-88054,44040,20941,-14449,6093,24078,50936,-14783,-15366,23268,23019,23714,26849,55194,23811,4148},
{0,-13388,0,56186,-29202,17242,120253,25680,40398,-275259,19571,-7963,-60111,41953,21124,82550,-44474,-104529,-278711,13529,-4996,-40774,-82154,-11835,-164138,-9913,11502,-13948,33393,-7816,117164,62466,-87978,44040,20941,-14449,6071,24092,51119,-15019,-15310,23288,23018,23714,26849,55454,23851,4052},
{0,-13364,0,56330,-29322,17546,120060,25575,40319,-275198,19940,-8124,-60114,41663,21205,82577,-44515,-104579,-278651,14066,-5201,-40781,-82492,-11669,-164150,-9840,11468,-14156,33741,-7514,117019,62639,-87901,44040,20941,-14449,6050,24106,51302,-15255,-15255,23309,23019,23714,26849,55714,23890,3956},
{0,-13341,0,56466,-29442,17835,119856,25468,40242,-275119,20291,-8283,-60113,41383,21287,82553,-44531,-104641,-278575,14510,-5377,-40754,-82773,-11484,-164134,-9798,11444,-14372,34105,-7226,116874,62799,-87822,44040,20941,-14449,6035,24137,51467,-15489,-15176,23333,23019,23714,26849,55945,23949,3843},
{0,-13318,0,56602,-29561,18124,119651,25361,40164,-275039,20642,-8442,-60113,41104,21368,82529,-44547,-104704,-278497,14954,-5552,-40726,-83054,-11299,-164118,-9755,11420,-14590,34468,-6937,116729,62959,-87743,44040,20941,-14449,6021,24168,51633,-15723,-15098,23357,23018,23714,26849,56175,24007,3731},
{0,-13296,0,56728,-29676,18395,119404,25244,40089,-274918,20971,-8603,-60096,40842,21447,82459,-44540,-104778,-278405,15301,-5696,-40666,-83276,-11099,-164075,-9744,11407,-14812,34840,-6665,116586,63104,-87661,44040,20941,-14449,6014,24216,51777,-15952,-14998,23384,23019,23714,26849,56373,24083,3603},
{0,-13275,0,56855,-29792,18666,119156,25127,40013,-274796,21299,-8765,-60080,40579,21525,82388,-44532,-104853,-278312,15648,-5840,-40606,-83497,-10899,-164032,-9732,11393,-15035,35212,-6392,116443,63250,-87580,44040,20941,-14449,6006,24263,51922,-16181,-14898,23412,23019,23714,26849,56571,24158,3476},
{0,-13255,0,56970,-29901,18914,118844,24994,39939,-274616,21600,-8931,-60039,40340,21598,82278,-44504,-104938,-278209,15900,-5952,-40519,-83659,-10692,-163963,-9751,11390,-15259,35588,-6142,116305,63379,-87498,44040,20941,-14449,6006,24325,52042,-16402,-14779,23442,23019,23714,26849,56734,24250,3336},
{0,-13236,0,57085,-30010,19162,118532,24861,39866,-274435,21900,-9098,-59999,40101,21671,82167,-44476,-105022,-278106,16152,-6063,-40432,-83820,-10484,-163894,-9770,11387,-15485,35964,-5891,116166,63508,-87416,44040,20941,-14449,6006,24386,52162,-16624,-14660,23473,23019,23714,26849,56897,24341,3196},
{0,-13218,0,57187,-30110,19384,118168,24716,39794,-274205,22164,-9265,-59939,39891,21738,82023,-44430,-105114,-277995,16310,-6142,-40323,-83922,-10276,-163801,-9818,11394,-15708,36339,-5668,116035,63619,-87336,44040,20941,-14449,6013,24460,52255,-16836,-14524,23506,23019,23714,26849,57021,24446,3046},
{0,-13201,0,57289,-30210,19605,117803,24571,39723,-273974,22427,-9432,-59878,39681,21806,81879,-44383,-105205,-277885,16468,-6222,-40215,-84023,-10067,-163708,-9866,11402,-15933,36713,-5443,115903,63730,-87255,44040,20941,-14449,6020,24535,52347,-17047,-14388,23539,23018,23714,26849,57145,24552,2895},
{0,-13186,0,57376,-30298,19795,117390,24416,39655,-273699,22650,-9596,-59793,39505,21866,81706,-44320,-105301,-277770,16531,-6267,-40089,-84064,-9864,-163591,-9943,11420,-16151,37081,-5252,115779,63821,-87176,44040,20941,-14449,6034,24619,52409,-17247,-14236,23575,23019,23714,26849,57228,24670,2736},
{0,-13171,0,57464,-30386,19986,116976,24261,39587,-273424,22872,-9761,-59708,39329,21926,81533,-44257,-105397,-277655,16594,-6312,-39963,-84105,-9661,-163475,-10021,11438,-16371,37448,-5060,115656,63912,-87097,44040,20941,-14449,6048,24704,52471,-17446,-14085,23610,23019,23714,26849,57311,24789,2577},
{0,-13159,0,57535,-30460,20141,116545,24106,39525,-273117,23046,-9916,-59620,39190,21976,81337,-44180,-105494,-277538,16565,-6323,-39826,-84085,-9470,-163336,-10127,11468,-16580,37805,-4906,115543,63982,-87022,44040,20941,-14449,6069,24796,52499,-17631,-13919,23647,23019,23714,26849,57349,24919,2413},
{0,-13147,0,57605,-30533,20297,116114,23951,39462,-272809,23219,-10072,-59532,39052,22027,81141,-44103,-105590,-277421,16535,-6334,-39689,-84065,-9280,-163196,-10232,11497,-16791,38161,-4751,115429,64051,-86946,44040,20941,-14449,6090,24889,52527,-17816,-13754,23684,23019,23714,26849,57388,25049,2248},
{0,-13138,0,57658,-30589,20413,115668,23798,39407,-272475,23343,-10216,-59436,38955,22066,80928,-44014,-105685,-277305,16414,-6310,-39546,-83984,-9110,-163036,-10366,11538,-16987,38500,-4640,115329,64097,-86875,44040,20941,-14449,6118,24988,52518,-17983,-13576,23722,23019,23714,26849,57379,25190,2080},
{0,-13129,0,57711,-30645,20529,115221,23645,39351,-272141,23465,-10360,-59339,38858,22105,80716,-43924,-105779,-277189,16293,-6286,-39403,-83903,-8940,-162875,-10500,11578,-17184,38840,-4529,115228,64143,-86804,44040,20941,-14449,6145,25086,52508,-18151,-13399,23761,23018,23714,26849,57370,25330,1911},
{0,-13124,0,57744,-30681,20601,114770,23498,39307,-271788,23535,-10488,-59236,38805,22129,80491,-43824,-105869,-277075,16082,-6226,-39259,-83761,-8797,-162695,-10661,11630,-17364,39158,-4466,115141,64164,-86738,44040,20941,-14449,6180,25189,52458,-18299,-13211,23800,23019,23714,26849,57311,25481,1742},
{0,-13118,0,57777,-30716,20674,114318,23351,39262,-271436,23604,-10616,-59133,38752,22153,80266,-43724,-105958,-276962,15870,-6166,-39116,-83620,-8654,-162514,-10821,11683,-17544,39476,-4403,115054,64185,-86671,44040,20941,-14449,6215,25291,52408,-18447,-13023,23838,23018,23714,26849,57251,25631,1572},
{0,-13116,0,57788,-30729,20699,113872,23214,39231,-271073,23619,-10725,-59026,38746,22160,80035,-43616,-106038,-276853,15569,-6069,-38976,-83418,-8545,-162313,-11009,11747,-17702,39768,-4395,114982,64179,-86611,44040,20941,-14449,6256,25394,52314,-18573,-12826,23877,23019,23714,26849,57138,25790,1405},
{0,-13114,0,57800,-30741,20724,113426,23078,39199,-270710,23633,-10833,-58918,38739,22167,79803,-43507,-106119,-276744,15268,-5973,-38838,-83216,-8437,-162113,-11196,11812,-17861,40060,-4387,114911,64173,-86551,44040,20941,-14449,6298,25497,52220,-18700,-12629,23916,23019,23714,26849,57026,25949,1237},
}
local clip={Duration=2.0,Loop=true,Source="Quaternius original GLB",Role="NinjaJump_Idle_Loop",Frames={}}
for i,row in rows do
 local pose:{[string]:CFrame}={};for j,name in joints do local k=4+(j-1)*3;local c=CFrame.Angles(row[k]/100000,row[k+1]/100000,row[k+2]/100000);pose[name]=if name=="Root"then CFrame.new(row[1]/100000,row[2]/100000,row[3]/100000)*c else c end
 clip.Frames[i]={Time=math.min((i-1)/60,clip.Duration),Pose=pose}
end
return clip
]====])
-- Source: src/client/world/clips/NinjaJump_Land.luau
addModule(modules,{"world","clips","NinjaJump_Land"},[====[
--!strict
-- Actual provider GLB retarget; fixed 1e-5 quantization, no new motion keys.
local joints={"Root","RightHip","RightKnee","RightAnkle","LeftHip","LeftKnee","LeftAnkle","Waist","LeftShoulder","LeftElbow","LeftWrist","RightShoulder","RightElbow","RightWrist","Neck"}
local rows={
{0,-13114,0,57800,-30741,20724,113426,23078,39199,-270710,23633,-10833,-58918,38739,22167,79803,-43507,-106119,-276744,15268,-5973,-38838,-83216,-8437,-162113,-11196,11812,-17861,40060,-4387,114911,64173,-86551,44040,20941,-14449,6298,25497,52220,-18700,-12629,23916,23019,23714,26849,57026,25949,1237},
{0,-26527,0,49904,-30477,17506,101604,23417,45588,-259651,23011,-13807,-32332,44997,14425,87938,-44555,-98155,-266116,-91,1101,-25107,-65758,1628,-157202,-9542,10447,-13070,27313,-14675,116164,66516,-88731,44049,20869,-14455,8565,23122,51413,-16242,-11500,23826,23019,23714,26849,55773,23858,2569},
{0,-39939,0,42030,-29973,14324,89784,23021,51973,-248635,22074,-16687,-4571,49127,4896,96168,-45011,-90094,-254306,-14565,9851,-14866,-47551,7864,-152253,-7921,9097,-9422,14132,-23921,117506,68836,-90989,44057,20798,-14460,10812,20749,50583,-13786,-10374,23709,23019,23714,26849,54574,21719,3815},
{0,-65704,0,26755,-28555,8366,78869,23191,60782,-225530,23749,-29785,32972,44325,-11827,111303,-41192,-70308,-227949,-12809,15224,4369,-35675,14499,-141408,-5054,6268,-5399,-9676,-41075,117714,73313,-93389,44087,20540,-14480,14829,16499,49858,-7863,-7194,23380,23019,23714,26849,51809,18124,6442},
{0,-91469,0,11672,-26291,2731,67988,22427,69551,-202389,22452,-42934,68075,34530,-25095,125054,-34820,-51745,-201795,-9730,19939,22061,-22889,18454,-130433,-2349,3481,-3946,-34067,-57406,118081,77785,-95906,44117,20283,-14500,18808,12247,49035,-1940,-4040,22864,23019,23714,26849,49213,14346,8800},
{0,-115198,0,506,-24762,-917,68852,24643,74832,-197221,23233,-50061,86906,27677,-29532,139521,-32598,-41855,-193508,-5870,14391,32809,-18913,22202,-120316,-1049,1747,-4032,-49408,-66377,113723,81267,-94307,44175,19776,-14539,21138,10732,48139,5754,60,21972,23018,23714,26849,46180,12809,10081},
{0,-138927,0,-10550,-22851,-4353,69598,26900,80124,-192002,23652,-57231,105083,20165,-32508,153560,-29073,-32490,-185032,-2485,8552,43324,-14569,25473,-110162,134,17,-5281,-64745,-75935,109114,84695,-92419,44233,19270,-14577,23447,9217,47221,13491,4080,20767,23019,23714,26849,43183,11207,11295},
{0,-149532,0,-13565,-22714,-5034,79332,29793,76314,-201652,24665,-47991,109254,13116,-34309,164531,-30805,-30894,-192896,-2095,5829,43564,-14690,27900,-103246,135,8,-4267,-69405,-72349,100540,84199,-86236,44323,18450,-14637,23499,9163,44700,20415,9509,18908,23018,23714,26849,40387,11660,10812},
{0,-160136,0,-16578,-22556,-5710,89259,32312,72193,-211370,24806,-38680,113268,6002,-35801,175589,-32358,-29100,-200745,-1492,3145,43807,-14805,30329,-96329,135,-2,-3021,-74032,-68565,92092,83355,-80185,44413,17631,-14697,23550,9106,42180,27484,14796,16663,23019,23714,26849,37592,12111,10326},
{0,-164710,0,-18954,-22417,-6240,97064,32445,65867,-216463,22101,-31658,114911,-800,-36479,181873,-32883,-27778,-203935,-703,1407,43433,-14738,32777,-91008,135,-9,-1635,-77919,-64803,89466,81505,-77784,44538,16434,-14780,23829,9794,39495,33625,17669,14905,23019,23714,26849,35449,12447,9917},
{0,-169283,0,-21328,-22266,-6766,104858,32110,59552,-221320,19061,-24828,116511,-7612,-37047,188175,-33327,-26422,-207111,142,-304,43058,-14681,35226,-85688,134,-16,-9,-81764,-60824,86954,79614,-75500,44661,15238,-14861,24128,10472,36806,39850,20429,12961,23019,23714,26849,33307,12780,9506},
{0,-170033,0,-23153,-22142,-7168,106805,32919,59659,-222114,19335,-24769,116634,-7677,-37522,190902,-33462,-25803,-207701,515,-967,42856,-14437,37211,-83559,134,-19,1282,-85704,-58811,87968,78057,-75536,44817,13602,-14966,25114,13041,34374,43766,18963,13376,23019,23714,26849,32454,12931,9315},
{0,-170783,0,-24977,-22011,-7567,108756,33730,59749,-222908,19608,-24708,116756,-7742,-37998,193632,-33582,-25179,-208288,891,-1629,42650,-14198,39195,-81431,133,-22,2756,-89625,-56621,88965,76498,-75550,44970,11965,-15069,26168,15582,31906,47678,17514,13848,23018,23714,26849,31601,13082,9124},
{0,-168996,0,-26327,-21909,-7861,109533,34008,59707,-221702,19821,-25574,115955,-7565,-37754,193759,-33678,-25219,-207261,697,-1309,42691,-13836,40313,-82041,133,-21,3611,-93704,-56762,92610,75170,-77327,45147,9859,-15190,27933,19928,30136,50320,12966,16302,23019,23714,26849,32057,13112,9108},
{0,-167208,0,-27676,-21803,-8154,110310,34287,59662,-220493,20023,-26442,115153,-7391,-37509,193887,-33775,-25259,-206235,505,-988,42728,-13473,41430,-82652,133,-20,4519,-97783,-56841,96177,73797,-79015,45321,7753,-15307,29796,24239,28265,53060,8485,18864,23019,23714,26849,32513,13142,9092},
{0,-163703,0,-28614,-21727,-8356,110156,34139,59516,-217886,20066,-27947,113770,-7092,-36774,192208,-33818,-25732,-204085,-62,103,42865,-13067,41330,-84261,134,-18,4956,-101395,-57969,100421,71962,-81037,45495,5282,-15431,31863,29157,27260,56294,3497,21905,23019,23714,26849,33678,13157,9105},
{0,-160199,0,-29551,-21650,-8558,110002,33992,59371,-215279,20070,-29452,112385,-6803,-36034,190529,-33853,-26206,-201929,-605,1207,43003,-12661,41229,-85870,134,-16,5356,-105008,-59126,104548,70066,-82922,45666,2811,-15550,34019,34051,26123,59676,-1389,25104,23018,23714,26849,34843,13172,9118},
{0,-155537,0,-30134,-21601,-8683,109096,33490,59117,-211681,19764,-31337,110616,-6454,-35037,187647,-33711,-26873,-198906,-1203,2710,43073,-12288,40307,-88144,134,-13,5248,-108073,-61131,108884,67776,-84883,45816,115,-15664,36097,39123,25970,63370,-6356,28617,23019,23714,26849,36427,13174,9156},
{0,-150875,0,-30716,-21551,-8808,108191,32989,58860,-208093,19392,-33208,108843,-6123,-34035,184767,-33551,-27534,-195875,-1755,4231,43148,-11916,39386,-90419,135,-10,5013,-111133,-63256,113083,65424,-86681,45963,-2581,-15774,38233,44191,25688,67253,-11188,32327,23018,23714,26849,38010,13177,9195},
{0,-145456,0,-30991,-21527,-8867,106698,32208,58493,-203838,18610,-35229,106783,-5731,-32977,181103,-33153,-28225,-192138,-2119,5808,43029,-11625,38351,-93027,135,-6,4380,-113592,-65852,117100,62811,-88336,46076,-5364,-15872,39994,48965,26326,71180,-15692,36094,23019,23714,26849,39719,13170,9254},
{0,-140036,0,-31266,-21503,-8925,105206,31432,58115,-199607,17745,-37212,104720,-5361,-31911,177448,-32732,-28898,-188395,-2424,7396,42914,-11333,37317,-95634,135,-3,3568,-116039,-68623,120989,60147,-89833,46186,-8146,-15966,41771,53751,26874,75309,-20042,40069,23018,23714,26849,41429,13164,9313},
{0,-134155,0,-31276,-21502,-8927,103230,30428,57626,-194918,16442,-39191,102443,-4938,-30899,173322,-32071,-29495,-184113,-2461,8883,42534,-11128,36262,-98242,135,1,2665,-117877,-71280,124381,57411,-91011,46256,-10876,-16044,42970,57793,28064,79099,-23712,43728,23018,23714,26849,42971,13150,9389},
{0,-128274,0,-31286,-21501,-8930,101255,29434,57118,-190266,15050,-41102,100162,-4538,-29878,169209,-31387,-30061,-179831,-2434,10369,42157,-10920,35209,-100850,135,4,1599,-119701,-74100,127678,54643,-92060,46323,-13605,-16120,44145,61850,29217,83061,-27240,47563,23018,23714,26849,44513,13136,9465},
{0,-122157,0,-31069,-21520,-8883,98885,28265,56506,-185311,13246,-42901,97712,-4083,-28969,164798,-30504,-30512,-175114,-2134,11675,41484,-10793,34189,-103125,135,7,929,-120954,-76040,130224,52025,-92649,46352,-16144,-16179,44716,64780,30519,86187,-29816,50596,23019,23714,26849,45594,13118,9554},
{0,-116041,0,-30851,-21539,-8837,96516,27110,55867,-180400,11356,-44604,95259,-3651,-28049,160404,-29603,-30921,-170403,-1772,12965,40813,-10659,33171,-105399,135,10,172,-122200,-78068,132715,49395,-93154,46379,-18683,-16238,45252,67720,31822,89420,-32298,53736,23019,23714,26849,46676,13100,9643},
{0,-109866,0,-30439,-21575,-8749,93835,25834,55139,-175310,9116,-46125,92671,-3157,-27271,155824,-28556,-31208,-165340,-1169,14038,39843,-10595,32215,-107008,134,13,378,-122932,-78379,134231,47150,-93072,46375,-20894,-16280,45315,69215,32652,91253,-33627,55519,23019,23714,26849,47003,13080,9740},
{0,-103691,0,-30027,-21610,-8660,91154,24578,54379,-170264,6803,-47528,90081,-2684,-26481,151260,-27497,-31443,-160285,-512,15080,38874,-10523,31260,-108617,134,15,585,-123662,-78691,135732,44907,-92952,46371,-23105,-16323,45363,70714,33486,93120,-34926,57337,23019,23714,26849,47331,13060,9837},
{0,-97600,0,-29450,-21658,-8536,88201,23235,53541,-165086,4194,-48717,87372,-2139,-25847,146596,-26346,-31566,-154973,335,15895,37631,-10508,30378,-109228,134,16,2260,-123896,-76521,136021,43268,-92116,46349,-24852,-16352,45240,71000,33450,93605,-35254,57809,23018,23714,26849,46611,13042,9939},
{0,-91508,0,-28873,-21706,-8412,85247,21917,52664,-159943,1528,-49768,84661,-1611,-25199,141947,-25191,-31633,-149668,1224,16663,36387,-10482,29496,-109838,134,16,3961,-124119,-74326,136323,41631,-91280,46327,-26599,-16381,45118,71287,33413,94092,-35580,58283,23018,23714,26849,45891,13023,10040},
{0,-85615,0,-28157,-21764,-8258,82085,20554,51729,-154736,-1354,-50588,81856,-1002,-24714,137226,-23984,-31607,-144140,2257,17213,34889,-10502,28691,-109645,134,16,6754,-123884,-70243,135481,40842,-89957,46303,-27747,-16398,45015,70992,32718,93826,-35403,58024,23019,23714,26849,44357,13008,10143},
{0,-79722,0,-27442,-21822,-8103,78918,19220,50753,-149549,-4275,-51256,79048,-406,-24212,132518,-22779,-31523,-138616,3318,17706,33390,-10510,27884,-109452,134,16,9495,-123617,-66210,134653,40042,-88645,46279,-28894,-16415,44912,70695,32023,93561,-35225,57766,23018,23714,26849,42823,12993,10245},
{0,-74123,0,-26611,-21887,-7923,75573,17860,49715,-144297,-7368,-51695,76172,248,-23847,127778,-21559,-31365,-132930,4473,17993,31673,-10556,27151,-108894,134,15,12566,-122984,-61498,133168,39789,-87121,46269,-29307,-16421,44809,70092,30992,92897,-34774,57119,23019,23714,26849,40955,12986,10343},
{0,-68524,0,-25781,-21951,-7743,72221,16535,48634,-139045,-10480,-51972,73293,890,-23463,123048,-20347,-31148,-127244,5643,18215,29956,-10589,26417,-108337,134,14,15495,-122309,-56924,131689,39515,-85603,46259,-29720,-16427,44700,69487,29966,92237,-34319,56477,23019,23714,26849,39086,12977,10442},
{0,-63300,0,-24857,-22020,-7541,68732,15205,47491,-133747,-13711,-52022,70387,1553,-23182,118312,-19144,-30875,-121440,6865,18250,28055,-10651,25750,-107449,134,13,18522,-121291,-51992,129872,39294,-83831,46259,-29720,-16427,44562,68585,28670,91227,-33609,55494,23018,23714,26849,36954,12981,10532},
{0,-58075,0,-23933,-22087,-7339,65234,13916,46304,-128424,-16940,-51898,67479,2207,-22882,113583,-17955,-30545,-115631,8088,18214,26153,-10701,25082,-106561,134,12,21339,-120229,-47267,128062,39042,-82066,46259,-29720,-16427,44413,67681,27383,90227,-32890,54521,23018,23714,26849,34823,12983,10623},
{0,-53294,0,-22936,-22157,-7120,61639,12644,45064,-123072,-20238,-51549,64566,2876,-22677,108863,-16793,-30176,-109734,9330,18011,24097,-10774,24476,-105374,135,10,24048,-118868,-42473,125952,38815,-80089,46259,-29720,-16427,44200,66486,25899,88928,-31932,53258,23019,23714,26849,32501,13000,10701},
{0,-48512,0,-21938,-22226,-6901,58033,11416,43780,-117669,-23514,-51016,61652,3539,-22453,104148,-15649,-29752,-103827,10558,17735,22041,-10835,23869,-104188,135,9,26521,-117468,-37912,123849,38549,-78120,46259,-29720,-16427,43970,65290,24428,87646,-30958,52013,23019,23714,26849,30179,13017,10780},
{0,-44232,0,-20885,-22295,-6668,54361,10222,42450,-112244,-26815,-50260,58753,4210,-22316,99475,-14548,-29303,-97889,11773,17314,19871,-10915,23319,-102737,135,7,28781,-115835,-33469,121484,38281,-75985,46259,-29720,-16427,43642,63812,22831,86118,-29760,50528,23019,23714,26849,27741,13053,10842},
{0,-39952,0,-19831,-22363,-6435,50678,9078,41078,-106740,-30072,-49310,55852,4878,-22160,94804,-13468,-28804,-91936,12960,16821,17700,-10983,22767,-101286,135,5,30814,-114170,-29248,119130,37967,-73860,46259,-29720,-16427,43291,62333,21249,84613,-28541,49068,23018,23714,26849,25302,13087,10904},
{0,-36225,0,-18739,-22430,-6192,46977,7985,39678,-101257,-33296,-48151,53003,5549,-22086,90213,-12443,-28294,-86021,14106,16210,15462,-11067,22267,-99603,135,3,32597,-112248,-25154,116504,37606,-71563,46259,-29720,-16427,42814,60587,19610,82912,-27113,47419,23018,23714,26849,22821,13145,10943},
{0,-32499,0,-17646,-22495,-5949,43264,6945,38239,-95670,-36454,-46790,50153,6218,-21993,85622,-11442,-27738,-80089,15214,15531,13223,-11140,21766,-97921,135,0,34175,-110301,-21262,113892,37189,-69280,46259,-29720,-16427,42310,58840,17984,81243,-25658,45802,23018,23714,26849,20340,13202,10983},
{0,-29371,0,-16528,-22558,-5699,39590,5975,36801,-90177,-39512,-45252,47404,6885,-21978,81168,-10510,-27188,-74304,16251,14768,10978,-11226,21314,-96039,135,-2,35422,-108025,-17533,110996,36673,-66816,46259,-29720,-16427,41657,56845,16363,79425,-24014,44043,23018,23714,26849,17890,13286,10995},
{0,-26243,0,-15411,-22619,-5449,35905,5059,35329,-84561,-42487,-43512,44654,7551,-21944,76713,-9603,-26598,-68502,17242,13945,8733,-11302,20861,-94158,135,-5,36488,-105734,-13977,108120,36092,-64373,46259,-29720,-16427,40977,54852,14751,77644,-22339,42322,23018,23714,26849,15441,13370,11008},
{0,-23755,0,-14283,-22678,-5195,32341,4231,33908,-79191,-45276,-41673,42086,8210,-21984,72495,-8781,-26038,-63039,18129,13091,6582,-11389,20454,-92111,135,-7,37167,-103129,-10689,105002,35381,-61796,46259,-29720,-16427,40135,52635,13197,75760,-20495,40504,23018,23714,26849,13099,13483,10985},
{0,-21267,0,-13154,-22733,-4941,28767,3454,32459,-73690,-47970,-39642,39517,8870,-22006,68275,-7984,-25445,-57560,18968,12188,4430,-11466,20045,-90064,135,-10,37704,-100518,-7530,101912,34596,-59251,46259,-29720,-16427,39267,50424,11646,73918,-18619,38728,23018,23714,26849,10757,13597,10964},
{0,-19455,0,-12028,-22786,-4687,25441,2786,31153,-68732,-50363,-37682,37266,9518,-22100,64468,-7299,-24922,-52770,19659,11344,2543,-11552,19682,-87885,134,-13,37842,-97620,-4701,98627,33660,-56622,46259,-29720,-16427,38235,48018,10194,72012,-16599,36894,23019,23714,26849,8600,13743,10900},
{0,-17643,0,-10902,-22836,-4433,22107,2161,29826,-63654,-52666,-35561,35015,10167,-22178,60659,-6634,-24374,-47968,20310,10466,656,-11631,19318,-85706,134,-16,37881,-94724,-1952,95380,32643,-54036,46259,-29720,-16427,37179,45620,8738,70150,-14546,35105,23019,23714,26849,6442,13891,10837},
{0,-16540,0,-9790,-22883,-4181,19239,1669,28811,-59706,-54501,-33859,33326,10799,-22324,57579,-6126,-23968,-44494,20752,9801,-662,-11716,18998,-83427,134,-19,37538,-91578,437,91990,31460,-51422,46259,-29720,-16427,35969,43064,7412,68261,-12379,33292,23018,23714,26849,4548,14073,10722},
{0,-15438,0,-8677,-22927,-3928,16365,1206,27782,-55677,-56276,-32053,31637,11433,-22459,54498,-5631,-23546,-41014,21171,9120,-1980,-11797,18677,-81149,133,-22,37135,-88440,2792,88647,30195,-48860,46259,-29720,-16427,34736,40518,6073,66417,-10179,31526,23019,23714,26849,2655,14256,10609},
{0,-15075,0,-7589,-22967,-3681,14239,892,27306,-53613,-57389,-31188,30843,12046,-22658,52572,-5349,-23362,-39724,21311,8859,-2321,-11881,18401,-78804,133,-25,36391,-85098,4780,85216,28763,-46325,46259,-29720,-16427,33367,37854,4886,64575,-7898,29767,23019,23714,26849,1104,14476,10434},
{0,-14712,0,-6501,-23005,-3433,12112,589,26823,-51524,-58486,-30290,30050,12660,-22852,50647,-5070,-23172,-38432,21448,8595,-2662,-11964,18124,-76459,132,-28,35619,-81768,6773,81837,27250,-43852,46259,-29720,-16427,31980,35201,3678,62777,-5585,28052,23019,23714,26849,-445,14697,10259},
{0,-14726,0,-5448,-23039,-3192,10481,367,26697,-50714,-59185,-30046,29816,13252,-23075,49444,-4915,-23131,-38482,21426,8598,-2403,-12046,17874,-74081,131,-32,34558,-78285,8407,78427,25581,-41456,46259,-29720,-16427,30481,32474,2636,61009,-3225,26370,23019,23714,26849,-1569,14954,10012},
{0,-14740,0,-4395,-23071,-2952,8850,147,26568,-49898,-59881,-29794,29583,13845,-23297,48242,-4760,-23089,-38532,21403,8602,-2144,-12128,17624,-71703,130,-35,33492,-74817,10076,75073,23835,-39130,46259,-29720,-16427,28967,29758,1566,59282,-837,24731,23019,23714,26849,-2693,15210,9764},
{0,-14749,0,-3386,-23098,-2721,7269,-63,26420,-49052,-60576,-29509,29334,14417,-23514,47076,-4611,-23047,-38553,21385,8600,-1908,-12204,17382,-69325,130,-38,32199,-71255,11403,71741,21959,-36926,46259,-29720,-16427,27373,27012,666,57606,1562,23144,23019,23714,26849,-3275,15504,9425},
{0,-14758,0,-2377,-23124,-2490,5689,-272,26269,-48201,-61269,-29216,29085,14989,-23730,45910,-4462,-23003,-38573,21366,8597,-1673,-12281,17141,-66947,129,-41,30915,-67708,12785,68465,20013,-34795,46259,-29720,-16427,25766,24278,-268,55967,3986,21597,23019,23714,26849,-3855,15796,9084},
{0,-14762,0,-1421,-23146,-2270,4166,-470,26096,-47309,-61959,-28881,28815,15534,-23939,44792,-4321,-22961,-38567,21352,8590,-1462,-12352,16909,-64602,128,-44,29467,-64131,13850,65260,17974,-32822,46259,-29720,-16427,24115,21560,-1031,54398,6382,20120,23018,23714,26849,-4018,16102,8672},
{0,-14765,0,-465,-23166,-2051,2643,-665,25920,-46410,-62646,-28538,28546,16081,-24147,43674,-4179,-22916,-38562,21337,8583,-1250,-12423,16678,-62258,127,-47,28036,-60568,14982,62108,15874,-30922,46259,-29720,-16427,22452,18853,-1831,52862,8800,18678,23018,23714,26849,-4179,16404,8256},
{0,-14765,0,430,-23183,-1845,1203,-847,25734,-45512,-63314,-28175,28272,16596,-24346,42617,-4046,-22873,-38535,21325,8572,-1061,-12489,16459,-59979,125,-50,26504,-57041,15825,59073,13727,-29205,46259,-29720,-16427,20784,16209,-2468,51412,11152,17321,23019,23714,26849,-4083,16697,7798},
{0,-14765,0,1326,-23198,-1640,-238,-1026,25545,-44607,-63979,-27803,27999,17111,-24543,41560,-3913,-22829,-38509,21314,8561,-873,-12554,16240,-57701,124,-53,24992,-53527,16740,56083,11530,-27558,46259,-29720,-16427,19105,13574,-3143,49989,13522,15994,23019,23714,26849,-3986,16984,7337},
{0,-14761,0,2152,-23211,-1450,-1592,-1191,25343,-43688,-64624,-27404,27715,17591,-24730,40574,-3790,-22787,-38467,21305,8548,-706,-12614,16035,-55521,123,-55,23440,-50117,17396,53250,9342,-26108,46259,-29720,-16427,17459,11047,-3664,48665,15788,14763,23019,23714,26849,-3719,17249,6854},
{0,-14758,0,2979,-23222,-1259,-2947,-1352,25138,-42762,-65267,-26995,27431,18072,-24915,39588,-3667,-22744,-38425,21297,8534,-540,-12673,15830,-53342,122,-58,21907,-46718,18124,50455,7113,-24722,46259,-29720,-16427,15805,8527,-4222,47363,18070,13558,23018,23714,26849,-3451,17508,6367},
{0,-14752,0,3730,-23230,-1086,-4195,-1498,24930,-41858,-65874,-26578,27150,18512,-25088,38684,-3555,-22703,-38372,21291,8519,-395,-12726,15642,-51295,121,-60,20392,-43490,18626,47853,4951,-23536,46259,-29720,-16427,14223,6159,-4641,46171,20208,12458,23019,23714,26849,-3066,17737,5875},
{0,-14745,0,4481,-23238,-914,-5443,-1641,24720,-40946,-66479,-26152,26869,18953,-25259,37780,-3443,-22662,-38319,21285,8503,-250,-12779,15454,-49248,119,-63,18891,-40272,19194,45280,2760,-22407,46259,-29720,-16427,12632,3797,-5093,44998,22359,11379,23019,23714,26849,-2679,17960,5381},
{0,-14738,0,5150,-23243,-759,-6573,-1767,24511,-40067,-67041,-25726,26594,19350,-25415,36969,-3343,-22624,-38260,21281,8487,-126,-12826,15284,-47367,118,-65,17462,-37291,19568,42934,695,-21470,46259,-29720,-16427,11152,1629,-5422,43945,24331,10413,23019,23714,26849,-2212,18150,4897},
{0,-14730,0,5819,-23248,-605,-7703,-1890,24300,-39180,-67600,-25291,26320,19746,-25569,36158,-3244,-22586,-38201,21277,8472,-2,-12872,15114,-45485,117,-67,16044,-34318,20001,40608,-1391,-20582,46259,-29720,-16427,9665,-535,-5780,42905,26312,9464,23019,23714,26849,-1744,18334,4411},
{0,-14721,0,6400,-23251,-472,-8705,-1996,24093,-38339,-68109,-24864,26055,20094,-25707,35448,-3157,-22551,-38141,21275,8456,102,-12912,14965,-43803,116,-69,14745,-31647,20273,38543,-3291,-19871,46259,-29720,-16427,8325,-2466,-6031,41995,28078,8635,23019,23714,26849,-1225,18484,3952},
{0,-14713,0,6980,-23253,-338,-9706,-2100,23886,-37492,-68615,-24429,25790,20442,-25843,34739,-3070,-22517,-38081,21272,8440,206,-12952,14816,-42120,115,-71,13453,-28980,20593,36489,-5205,-19199,46259,-29720,-16427,6978,-4393,-6307,41095,29850,7819,23019,23714,26849,-706,18629,3490},
{0,-14704,0,7467,-23254,-226,-10558,-2185,23697,-36736,-69054,-24032,25552,20736,-25960,34141,-2997,-22487,-38025,21271,8426,291,-12985,14689,-40669,114,-73,12323,-26677,20785,34730,-6875,-18685,46259,-29720,-16427,5813,-6049,-6494,40333,31373,7131,23018,23714,26849,-166,18742,3070},
{0,-14695,0,7953,-23255,-114,-11410,-2269,23507,-35976,-69491,-23629,25315,21031,-26076,33543,-2925,-22457,-37969,21270,8412,376,-13018,14562,-39218,113,-74,11196,-24377,21012,32976,-8555,-18199,46259,-29720,-16427,4642,-7702,-6699,39578,32900,6451,23018,23714,26849,375,18850,2649},
{0,-14688,0,8340,-23255,-25,-12098,-2334,23344,-35331,-69851,-23280,25111,21267,-26170,33065,-2867,-22432,-37920,21269,8400,443,-13044,14460,-38032,112,-76,10268,-22496,21141,31550,-9938,-17848,46259,-29720,-16427,3685,-9049,-6832,38970,34144,5906,23018,23714,26849,902,18930,2286},
{0,-14680,0,8726,-23255,65,-12787,-2399,23180,-34682,-70210,-22926,24908,21504,-26264,32587,-2809,-22407,-37871,21269,8388,509,-13070,14358,-36846,111,-77,9342,-20618,21294,30127,-11326,-17515,46259,-29720,-16427,2724,-10393,-6977,38367,35390,5366,23018,23714,26849,1430,19005,1922},
{0,-14674,0,9009,-23255,130,-13296,-2445,23052,-34184,-70479,-22651,24751,21679,-26333,32236,-2767,-22389,-37833,21268,8379,557,-13088,14283,-35957,110,-78,8646,-19214,21377,29065,-12369,-17294,46259,-29720,-16427,2005,-11396,-7066,37921,36319,4968,23018,23714,26849,1900,19056,1633},
{0,-14668,0,9291,-23254,195,-13806,-2491,22924,-33683,-70748,-22373,24594,21853,-26402,31886,-2724,-22370,-37796,21268,8369,604,-13107,14207,-35069,109,-79,7951,-17811,21472,28005,-13415,-17083,46259,-29720,-16427,1285,-12397,-7162,37478,37250,4573,23019,23714,26849,2370,19105,1345},
{0,-14663,0,9463,-23254,234,-14122,-2518,22841,-33362,-70917,-22193,24493,21961,-26445,31671,-2699,-22359,-37772,21268,8364,633,-13118,14160,-34512,109,-80,7516,-16933,21519,27341,-14071,-16963,46259,-29720,-16427,834,-13022,-7213,37202,37832,4328,23019,23714,26849,2722,19132,1152},
{0,-14659,0,9636,-23254,274,-14437,-2546,22759,-33041,-71085,-22012,24392,22069,-26488,31457,-2673,-22348,-37748,21268,8358,663,-13130,14113,-33955,108,-80,7081,-16055,21570,26678,-14727,-16847,46259,-29720,-16427,383,-13647,-7267,36928,38414,4084,23018,23714,26849,3074,19159,960},
{0,-14658,0,9694,-23254,288,-14545,-2555,22730,-32929,-71143,-21948,24357,22106,-26503,31384,-2664,-22344,-37740,21268,8356,672,-13134,14097,-33761,108,-80,6931,-15752,21585,26449,-14955,-16809,46259,-29720,-16427,227,-13863,-7284,36833,38615,4000,23019,23714,26849,3218,19167,889},
{0,-14657,0,9753,-23253,301,-14653,-2564,22701,-32817,-71201,-21885,24322,22143,-26518,31310,-2655,-22340,-37731,21268,8354,682,-13137,14081,-33568,108,-81,6780,-15449,21601,26219,-15182,-16772,46259,-29720,-16427,71,-14079,-7302,36739,38817,3916,23019,23714,26849,3361,19176,818},
}
local clip={Duration=1.2666666666666666,Loop=false,Source="Quaternius original GLB",Role="NinjaJump_Land",Frames={}}
for i,row in rows do
 local pose:{[string]:CFrame}={};for j,name in joints do local k=4+(j-1)*3;local c=CFrame.Angles(row[k]/100000,row[k+1]/100000,row[k+2]/100000);pose[name]=if name=="Root"then CFrame.new(row[1]/100000,row[2]/100000,row[3]/100000)*c else c end
 clip.Frames[i]={Time=math.min((i-1)/60,clip.Duration),Pose=pose}
end
return clip
]====])
-- Source: src/client/world/clips/NinjaJump_Start.luau
addModule(modules,{"world","clips","NinjaJump_Start"},[====[
--!strict
-- Actual provider GLB retarget; fixed 1e-5 quantization, no new motion keys.
local joints={"Root","RightHip","RightKnee","RightAnkle","LeftHip","LeftKnee","LeftAnkle","Waist","LeftShoulder","LeftElbow","LeftWrist","RightShoulder","RightElbow","RightWrist","Neck"}
local rows={
{0,-138927,0,-10550,-22851,-4353,69598,26900,80124,-192002,23652,-57231,105083,20165,-32508,153560,-29073,-32490,-185032,-2485,8552,43324,-14569,25473,-101214,135,5,24430,-89606,-28418,102918,63249,-74414,46259,-29720,-16427,43903,50312,19132,73445,-18126,38273,49053,27731,12254,76912,14859,5664},
{0,-78579,0,33,-23176,-1937,26454,4924,51340,-117633,-33932,-60471,62626,21845,-29122,88131,-13824,-32292,-105630,10591,12444,19251,-14548,20715,-105198,-3972,3587,33779,-82164,-13945,91142,57487,-64204,46259,-29720,-16427,50527,44994,-1957,54385,-19373,32747,49052,27731,12254,93965,14931,-2494},
{0,-18232,0,10626,-23250,502,-20850,-2337,16198,-17001,-74279,-11557,20047,22009,-25321,23396,-1801,-22876,-24954,22494,5683,-4775,-13405,16104,-109058,-8040,7194,40641,-74317,-1232,80526,50822,-55208,46259,-29720,-16427,55701,39133,-22291,35256,-19566,27073,49052,27731,12254,110958,13185,-10347},
{0,-17536,0,21928,-23545,3654,-18766,-3285,24517,-53413,-62674,-32480,13970,25844,-20570,31199,-3514,-29614,-70562,16384,13164,-8621,-14873,17645,-111083,-7706,7891,29570,-59993,156,76776,43245,-46367,46298,-27855,-16399,44974,28800,-20176,15645,-15549,24625,49241,27108,12252,104532,13684,-10200},
{0,-16840,0,33237,-23492,6821,-16609,-4057,32857,-83569,-46431,-45966,7645,29387,-15535,38876,-5742,-36204,-115201,7686,17135,-12452,-16398,19131,-113108,-7360,8588,19478,-45699,3344,73870,35411,-38112,46337,-25989,-16371,34816,18218,-19075,-3751,-11142,23025,49430,26485,12252,98103,14194,-10032},
{0,-15615,0,41704,-23975,10064,-6012,-2618,37546,-112648,-27785,-49623,-10150,31323,-7217,45286,-8798,-45550,-153841,1326,14334,-21281,-26489,22709,-115156,-6186,9565,8008,-28002,-254,75174,27219,-26966,46353,-21315,-16282,25238,11346,-12055,-15232,-2756,24850,49870,25000,12263,86387,15337,-8768},
{0,-14389,0,50189,-24189,13341,4503,-692,42056,-140038,-8928,-47677,-28122,31815,1363,51403,-12433,-54714,-192661,-3507,9341,-30019,-36848,25442,-117204,-5008,10561,-2007,-9822,-1379,77371,19215,-15925,46365,-16641,-16193,16344,3904,-5514,-26877,5365,27625,50310,23514,12281,74643,16399,-7385},
{0,-13361,0,55590,-24786,16117,16838,1945,42122,-162670,1589,-42001,-34403,32830,4928,55576,-15942,-63319,-212979,-2159,4389,-25972,-44962,25151,-119752,-3694,11600,-9497,7328,-6309,78952,15894,-9667,46211,-10545,-16022,10588,1950,4619,-31840,11173,29814,50818,21741,12325,62208,17419,-5412},
{0,-12333,0,61014,-25236,18926,29183,4570,41864,-185993,10540,-34069,-40738,33629,8565,59454,-19791,-71825,-233203,157,-190,-21773,-53080,25227,-122298,-2391,12687,-16257,24881,-9801,80732,12678,-3386,46048,-4450,-15843,5011,-243,14682,-36972,16863,32310,51325,19967,12378,49739,18270,-3304},
{0,-11736,0,63937,-25804,20880,40900,6762,39895,-203395,14111,-28272,-42574,35403,10647,60581,-22148,-78005,-242060,2037,-1669,-21531,-57400,21575,-124723,-1498,13625,-20441,38479,-14112,80708,12755,-3528,45692,1660,-15586,1441,521,24508,-38079,18448,32944,51738,18481,12440,40135,18765,-1440},
{0,-11139,0,66876,-26316,22853,52677,8708,37679,-221059,16623,-21909,-44462,37141,12777,61563,-24570,-84193,-250893,4041,-2978,-21476,-61725,17827,-127145,-622,14604,-24381,52237,-17899,80685,12831,-3671,45320,7770,-15306,-2297,1247,34302,-39200,20025,33598,52151,16996,12508,30517,19127,492},
{0,-10873,0,68198,-26525,23669,59219,9774,36747,-229479,17182,-19231,-44869,38379,13694,60997,-25749,-88638,-253782,3596,-2506,-22937,-62901,13214,-130293,-810,15088,-26273,60340,-20942,82889,15312,-6505,44899,12474,-15029,-3785,2196,39786,-37739,17964,32748,52321,16373,12541,28816,19362,1207},
{0,-10607,0,69523,-26724,24488,65779,10778,35746,-237918,17516,-16514,-45291,39613,14621,60376,-26902,-93104,-256670,3137,-2047,-24476,-64022,8541,-133439,-1014,15580,-28092,68471,-23903,85172,17729,-9406,44462,17178,-14729,-5352,3143,45265,-36301,15890,31932,52491,15750,12576,27113,19584,1931},
{0,-10563,0,69734,-26701,24519,67737,11258,36042,-240477,17780,-15935,-45233,39819,15002,60463,-27773,-95577,-257822,3016,-1920,-25977,-64947,5528,-136326,-1795,15642,-28588,70614,-24428,87491,20235,-12593,44253,19060,-14591,-5281,3603,46964,-34173,12743,30763,52491,15750,12576,30124,19865,1737},
{0,-10520,0,69944,-26678,24550,69695,11743,36329,-243038,18030,-15349,-45176,40024,15384,60527,-28646,-98055,-258974,2894,-1795,-27523,-65836,2476,-139212,-2579,15685,-29086,72758,-24946,89902,22667,-15855,44040,20941,-14449,-5218,4064,48663,-32089,9571,29665,52491,15750,12576,33137,20139,1533},
{0,-10549,0,69812,-26718,24517,71889,12272,36577,-245364,18310,-14874,-45281,40175,15734,61246,-29320,-98837,-260077,3399,-2051,-27935,-66550,1463,-141507,-3247,15689,-29409,72805,-24069,91714,24670,-18693,44040,20941,-14449,-5126,4472,49915,-30338,6840,28781,52491,15750,12576,35542,20400,1360},
{0,-10579,0,69679,-26758,24483,74083,12807,36814,-247693,18579,-14393,-45387,40326,16083,61961,-29999,-99615,-261179,3907,-2300,-28358,-67260,440,-143802,-3916,15679,-29733,72851,-23191,93592,26622,-21583,44040,20941,-14449,-5039,4880,51168,-28614,4093,27946,52491,15750,12576,37948,20655,1181},
{0,-10631,0,69441,-26825,24426,76282,13344,37030,-249773,18836,-13980,-45655,40429,16414,62731,-30682,-100291,-262196,4430,-2542,-28785,-67969,-451,-145778,-4510,15639,-29839,72267,-22077,95093,28371,-24250,44040,20941,-14449,-4913,5300,52106,-27148,1716,27265,52491,15750,12576,40022,20897,1031},
{0,-10684,0,69202,-26893,24368,78481,13885,37234,-251855,19084,-13562,-45923,40531,16745,63499,-31371,-100963,-263211,4955,-2779,-29223,-68675,-1351,-147754,-5104,15589,-29937,71682,-20969,96650,30081,-26958,44040,20941,-14449,-4790,5720,53045,-25699,-670,26619,52491,15750,12576,42097,21136,875},
{0,-10748,0,68909,-26979,24295,80612,14414,37420,-253693,19318,-13204,-46317,40591,17057,64274,-32037,-101541,-264136,5488,-3006,-29663,-69369,-2134,-149545,-5644,15511,-29860,70724,-19816,97986,31716,-29573,44040,20941,-14449,-4621,6206,53753,-24431,-2786,26078,52389,15790,12615,43974,21362,748},
{0,-10812,0,68617,-27064,24221,82743,14946,37595,-255533,19545,-12842,-46712,40649,17370,65046,-32707,-102115,-265059,6023,-3229,-30112,-70061,-2926,-151337,-6183,15425,-29770,69767,-18671,99374,33316,-32226,44040,20941,-14449,-4454,6692,54461,-23174,-4907,25562,52287,15830,12655,45853,21584,616},
{0,-10884,0,68293,-27164,24136,84786,15462,37756,-257147,19757,-12533,-47212,40669,17665,65805,-33344,-102603,-265892,6558,-3442,-30558,-70735,-3610,-153009,-6678,15313,-29530,68550,-17553,100626,34895,-34840,44040,20941,-14449,-4241,7265,55001,-22054,-6817,25122,51996,15945,12768,47600,21796,512},
{0,-10955,0,67969,-27263,24051,86830,15980,37906,-258763,19964,-12220,-47713,40688,17960,66563,-33985,-103087,-266725,7095,-3650,-31013,-71407,-4302,-154682,-7172,15194,-29275,67334,-16442,101929,36442,-37491,44040,20941,-14449,-4029,7837,55541,-20941,-8731,24703,51704,16059,12882,49348,22004,404},
{0,-11030,0,67626,-27373,23957,88767,16476,38045,-260169,20159,-11955,-48290,40675,18236,67295,-34585,-103493,-267471,7623,-3845,-31459,-72056,-4893,-156271,-7627,15049,-28887,65923,-15390,103151,37992,-40129,44040,20941,-14449,-3774,8502,55959,-19937,-10470,24341,51242,16239,13065,51001,22203,324},
{0,-11106,0,67283,-27482,23863,90704,16975,38173,-261577,20351,-11688,-48868,40660,18512,68027,-35188,-103895,-268217,8152,-4037,-31912,-72704,-5491,-157861,-8081,14899,-28485,64514,-14343,104425,39512,-42804,44040,20941,-14449,-3520,9167,56376,-18937,-12213,23995,50780,16417,13248,52654,22399,239},
{0,-11184,0,66928,-27599,23762,92519,17447,38291,-262791,20531,-11464,-49496,40618,18768,68725,-35747,-104227,-268881,8664,-4216,-32349,-73325,-5995,-159389,-8499,14725,-27968,62952,-13370,105658,41043,-45477,44040,20941,-14449,-3226,9922,56707,-18027,-13809,23695,50168,16649,13495,54235,22586,182},
{0,-11261,0,66572,-27716,23660,94336,17921,38400,-264006,20709,-11238,-50123,40576,19025,69422,-36307,-104555,-269545,9177,-4391,-32792,-73944,-6505,-160919,-8916,14545,-27437,61394,-12398,106943,42544,-48189,44040,20941,-14449,-2933,10677,57037,-17119,-15408,23408,49555,16880,13743,55817,22772,121},
{0,-11341,0,66211,-27839,23553,96017,18364,38499,-265043,20877,-11052,-50773,40512,19262,70080,-36822,-104820,-270132,9663,-4551,-33213,-74533,-6926,-161369,-9151,14439,-27119,60521,-11905,107353,43641,-50064,44040,20941,-14449,-2691,11040,57197,-16796,-15978,23309,48812,17153,14051,56302,22950,87},
{0,-11420,0,65849,-27962,23446,97700,18809,38590,-266081,21043,-10864,-51423,40446,19498,70738,-37338,-105082,-270719,10150,-4708,-33640,-75120,-7352,-161819,-9386,14331,-26798,59650,-11412,107788,44731,-51953,44040,20941,-14449,-2449,11403,57356,-16474,-16549,23212,48068,17425,14360,56788,23127,51},
{0,-11499,0,65485,-28089,23334,99238,19220,38673,-266956,21201,-10712,-52072,40366,19715,71352,-37806,-105290,-271234,10604,-4849,-34039,-75673,-7695,-161838,-9540,14249,-26550,59012,-11091,107868,45671,-53505,44040,20941,-14449,-2206,11670,57406,-16407,-16667,23192,47213,17729,14724,56832,23296,38},
{0,-11578,0,65121,-28215,23222,100777,19631,38749,-267832,21357,-10559,-52721,40284,19931,71966,-38276,-105495,-271750,11058,-4988,-34443,-76224,-8043,-161858,-9694,14167,-26300,58375,-10769,107965,46609,-55066,44040,20941,-14449,-1963,11936,57457,-16340,-16786,23172,46357,18029,15090,56876,23465,25},
{0,-11657,0,64758,-28343,23107,102166,20006,38818,-268562,21504,-10438,-53346,40192,20127,72545,-38703,-105646,-272201,11480,-5114,-34823,-76739,-8313,-161826,-9822,14079,-26026,57704,-10464,108033,47535,-56588,44040,20941,-14449,-1693,12268,57444,-16336,-16793,23171,45411,18351,15505,56861,23625,31},
{0,-11736,0,64394,-28471,22992,103556,20382,38881,-269292,21651,-10315,-53971,40099,20323,73126,-39132,-105795,-272651,11902,-5237,-35207,-77253,-8588,-161795,-9950,13991,-25751,57033,-10159,108118,48460,-58118,44040,20941,-14449,-1421,12599,57431,-16332,-16799,23170,44462,18670,15923,56847,23785,37},
{0,-11814,0,64034,-28600,22875,104792,20719,38937,-269889,21789,-10222,-54557,40001,20500,73645,-39508,-105910,-273041,12272,-5341,-35547,-77727,-8791,-161758,-10061,13895,-25446,56312,-9857,108221,49381,-59636,44040,20941,-14449,-1124,13003,57366,-16365,-16741,23179,43444,18999,16383,56821,23936,60},
{0,-11891,0,63674,-28729,22757,106029,21057,38989,-270487,21926,-10128,-55141,39902,20676,74164,-39885,-106023,-273430,12643,-5444,-35889,-78200,-8996,-161721,-10172,13799,-25139,55591,-9554,108341,50299,-61163,44040,20941,-14449,-825,13406,57301,-16398,-16682,23189,42424,19324,16847,56795,24086,83},
{0,-11967,0,63320,-28856,22640,107114,21356,39035,-270968,22054,-10059,-55672,39803,20834,74634,-40217,-106103,-273765,12966,-5530,-36192,-78631,-9137,-161691,-10269,13697,-24808,54827,-9253,108494,51206,-62674,44040,20941,-14449,-505,13875,57190,-16459,-16575,23207,41355,19651,17345,56769,24227,119},
{0,-12043,0,62965,-28983,22521,108199,21656,39078,-271449,22183,-9989,-56202,39702,20990,75104,-40549,-106182,-274099,13288,-5614,-36497,-79062,-9280,-161662,-10365,13594,-24475,54063,-8951,108663,52111,-64194,44040,20941,-14449,-183,14342,57079,-16519,-16469,23225,40284,19973,17846,56744,24368,156},
{0,-12117,0,62620,-29107,22404,109138,21916,39115,-271827,22301,-9942,-56670,39604,21129,75524,-40839,-106233,-274383,13562,-5683,-36762,-79451,-9365,-161642,-10448,13487,-24122,53268,-8653,108871,52994,-65687,44040,20941,-14449,156,14865,56927,-16601,-16324,23250,39186,20288,18373,56724,24498,204},
{0,-12191,0,62274,-29231,22286,110077,22178,39150,-272206,22420,-9893,-57137,39506,21266,75945,-41129,-106284,-274668,13835,-5751,-37029,-79839,-9451,-161622,-10531,13380,-23768,52474,-8354,109094,53875,-67190,44040,20941,-14449,497,15386,56774,-16683,-16178,23275,38085,20598,18903,56704,24629,252},
{0,-12262,0,61939,-29352,22171,110877,22402,39180,-272495,22529,-9863,-57537,39414,21385,76318,-41378,-106313,-274907,14059,-5803,-37255,-80183,-9486,-161613,-10603,13270,-23401,51662,-8062,109353,54722,-68649,44040,20941,-14449,849,15951,56585,-16783,-16002,23305,36979,20894,19448,56691,24749,308},
{0,-12332,0,61604,-29471,22055,111678,22626,39208,-272785,22639,-9833,-57935,39321,21504,76691,-41628,-106341,-275147,14283,-5855,-37482,-80528,-9523,-161603,-10674,13160,-23032,50850,-7768,109628,55566,-70119,44040,20941,-14449,1205,16515,56396,-16883,-15826,23335,35870,21184,19997,56677,24869,365},
{0,-12400,0,61283,-29585,21943,112352,22816,39232,-273000,22738,-9818,-58265,39236,21605,77017,-41841,-106352,-275345,14459,-5893,-37670,-80829,-9516,-161604,-10734,13051,-22657,50034,-7486,109933,56367,-71529,44040,20941,-14449,1566,17111,56174,-16996,-15625,23370,34779,21455,20548,56671,24978,427},
{0,-12467,0,60962,-29699,21830,113027,23006,39255,-273215,22838,-9803,-58594,39152,21705,77344,-42054,-106362,-275544,14635,-5930,-37859,-81131,-9509,-161605,-10795,12941,-22281,49218,-7201,110253,57163,-72948,44040,20941,-14449,1930,17705,55952,-17110,-15424,23405,33686,21719,21102,56664,25087,489},
{0,-12531,0,60657,-29806,21723,113599,23168,39275,-273370,22927,-9799,-58864,39077,21787,77627,-42233,-106360,-275707,14767,-5955,-38011,-81390,-9468,-161616,-10845,12835,-21904,48412,-6932,110594,57905,-74288,44040,20941,-14449,2294,18320,55703,-17234,-15205,23443,32633,21960,21646,56665,25185,554},
{0,-12595,0,60352,-29913,21615,114171,23331,39293,-273525,23017,-9794,-59133,39002,21869,77910,-42413,-106358,-275870,14899,-5980,-38163,-81649,-9427,-161626,-10895,12728,-21527,47607,-6660,110948,58642,-75637,44040,20941,-14449,2661,18933,55453,-17358,-14987,23482,31579,22195,22193,56665,25282,619},
{0,-12654,0,60068,-30011,21515,114636,23463,39309,-273631,23098,-9799,-59329,38939,21932,78153,-42562,-106346,-276001,14992,-5994,-38280,-81867,-9359,-161645,-10937,12626,-21158,46827,-6408,111310,59315,-76885,44040,20941,-14449,3021,19552,55182,-17488,-14758,23523,30588,22403,22716,56672,25368,684},
{0,-12712,0,59783,-30109,21414,115102,23596,39324,-273738,23179,-9804,-59524,38875,21995,78395,-42711,-106333,-276132,15084,-6008,-38398,-82086,-9291,-161663,-10978,12525,-20788,46048,-6154,111683,59984,-78142,44040,20941,-14449,3384,20171,54910,-17617,-14529,23564,29596,22607,23241,56679,25454,750},
{0,-12766,0,59522,-30197,21322,115487,23706,39336,-273810,23251,-9814,-59660,38824,22040,78600,-42832,-106315,-276235,15143,-6013,-38485,-82265,-9206,-161689,-11011,12431,-20434,45309,-5922,112050,60578,-79276,44040,20941,-14449,3732,20781,54626,-17748,-14299,23605,28692,22781,23727,56693,25528,813},
{0,-12820,0,59261,-30285,21229,115872,23816,39348,-273882,23323,-9825,-59795,38773,22085,78805,-42954,-106296,-276338,15202,-6018,-38572,-82445,-9121,-161715,-11044,12337,-20079,44571,-5689,112427,61169,-80417,44040,20941,-14449,4083,21390,54340,-17879,-14068,23647,27786,22951,24214,56706,25602,876},
{0,-12867,0,59028,-30361,21147,116193,23908,39358,-273933,23387,-9837,-59876,38735,22111,78975,-43052,-106274,-276417,15233,-6017,-38632,-82587,-9028,-161747,-11070,12254,-19750,43894,-5484,112780,61676,-81411,44040,20941,-14449,4410,21973,54052,-18006,-13846,23688,26992,23091,24647,56726,25663,933},
{0,-12914,0,58796,-30437,21066,116515,24000,39367,-273985,23451,-9849,-59957,38697,22136,79144,-43150,-106251,-276495,15265,-6015,-38693,-82730,-8935,-161778,-11095,12170,-19421,43216,-5277,113141,62180,-82412,44040,20941,-14449,4739,22555,53763,-18132,-13624,23729,26197,23228,25081,56746,25725,991},
{0,-12954,0,58598,-30500,20997,116425,23972,39361,-273755,23501,-9932,-59894,38683,22148,79280,-43225,-106228,-276552,15277,-6010,-38732,-82837,-8843,-161815,-11115,12099,-19129,42621,-5103,113461,62592,-83241,44040,20941,-14449,5031,23088,53487,-18248,-13422,23766,25538,23336,25445,56772,25773,1041},
{0,-12994,0,58399,-30563,20927,116336,23944,39354,-273525,23550,-10016,-59831,38670,22159,79416,-43301,-106205,-276609,15288,-6004,-38770,-82945,-8752,-161852,-11134,12029,-18837,42026,-4928,113786,63001,-84075,44040,20941,-14449,5326,23621,53209,-18363,-13220,23804,24878,23441,25810,56798,25821,1090},
{0,-13026,0,58243,-30611,20874,115767,23774,39326,-272958,23580,-10184,-59631,38680,22163,79519,-43356,-106184,-276647,15287,-5997,-38792,-83021,-8673,-161893,-11149,11974,-18597,41539,-4791,114052,63310,-84714,44040,20941,-14449,5569,24077,52965,-18457,-13054,23835,24377,23517,26088,56830,25856,1129},
{0,-13057,0,58087,-30658,20820,115198,23605,39297,-272392,23610,-10353,-59430,38689,22167,79621,-43412,-106163,-276686,15287,-5990,-38814,-83096,-8593,-161934,-11163,11919,-18356,41053,-4653,114321,63618,-85355,44040,20941,-14449,5814,24531,52720,-18552,-12887,23867,23876,23592,26368,56862,25892,1168},
{0,-13078,0,57982,-30689,20785,114592,23424,39264,-271815,23620,-10518,-59251,38706,22168,79688,-43447,-106147,-276708,15281,-5984,-38824,-83141,-8537,-161978,-11173,11882,-18185,40710,-4560,114514,63817,-85776,44040,20941,-14449,5985,24866,52539,-18614,-12778,23887,23559,23638,26546,56900,25913,1193},
{0,-13099,0,57877,-30720,20750,113986,23244,39231,-271239,23630,-10683,-59071,38722,22168,79754,-43482,-106132,-276730,15275,-5978,-38833,-83186,-8480,-162021,-11183,11845,-18015,40367,-4467,114708,64014,-86198,44040,20941,-14449,6158,25201,52358,-18677,-12670,23908,23241,23683,26724,56938,25934,1219},
{0,-13107,0,57838,-30730,20737,113706,23161,39215,-270974,23632,-10758,-58995,38731,22168,79779,-43494,-106125,-276737,15272,-5975,-38835,-83201,-8459,-162067,-11190,11828,-17938,40214,-4427,114809,64094,-86375,44040,20941,-14449,6228,25349,52289,-18688,-12649,23912,23130,23698,26786,56982,25941,1228},
{0,-13114,0,57800,-30741,20724,113426,23078,39199,-270710,23633,-10833,-58918,38739,22167,79803,-43507,-106119,-276744,15268,-5973,-38838,-83216,-8437,-162113,-11196,11812,-17861,40060,-4387,114911,64173,-86551,44040,20941,-14449,6298,25497,52220,-18700,-12629,23916,23019,23714,26849,57026,25949,1237},
}
local clip={Duration=0.9666666666666667,Loop=false,Source="Quaternius original GLB",Role="NinjaJump_Start",Frames={}}
for i,row in rows do
 local pose:{[string]:CFrame}={};for j,name in joints do local k=4+(j-1)*3;local c=CFrame.Angles(row[k]/100000,row[k+1]/100000,row[k+2]/100000);pose[name]=if name=="Root"then CFrame.new(row[1]/100000,row[2]/100000,row[3]/100000)*c else c end
 clip.Frames[i]={Time=math.min((i-1)/60,clip.Duration),Pose=pose}
end
return clip
]====])
-- Source: src/client/world/clips/Walk_Carry_Loop.luau
addModule(modules,{"world","clips","Walk_Carry_Loop"},[====[
--!strict
-- Actual provider GLB retarget; fixed 1e-5 quantization, no new motion keys.
local joints={"Root","RightHip","RightKnee","RightAnkle","LeftHip","LeftKnee","LeftAnkle","Waist","LeftShoulder","LeftElbow","LeftWrist","RightShoulder","RightElbow","RightWrist","Neck"}
local rows={
{0,-41847,0,57025,2731,2574,-65744,2051,-5326,-63617,-860,-618,51093,-809,-4228,25003,-414,-4788,-79188,-794,-781,4976,-3289,989,-59621,5419,6039,39041,-68180,-10987,93303,65954,15596,33756,39611,-7476,39040,68180,11065,98096,-65391,-13198,33764,-39613,7502,61633,-7647,-5967},
{0,-43248,0,57025,2725,2564,-64341,1919,-5089,-66934,-833,-640,52162,-763,-4408,26042,-444,-4842,-83499,-381,-376,8237,-3764,630,-60363,5757,6366,39044,-68193,-10982,93133,66000,15594,33756,39611,-7476,39040,68180,11065,98191,-65414,-13207,33764,-39613,7502,61800,-8093,-5981},
{0,-44648,0,57025,2719,2554,-62939,1790,-4851,-70250,-805,-661,53231,-719,-4589,27082,-475,-4897,-87811,15,46,11496,-4250,286,-61106,6092,6694,39048,-68207,-10976,92962,66045,15591,33756,39611,-7476,39040,68180,11065,98285,-65436,-13217,33764,-39613,7502,61968,-8539,-5995},
{0,-45413,0,57024,2701,2525,-61690,1677,-4635,-73277,-774,-675,52670,-738,-4632,27241,-531,-5428,-90683,897,1210,14164,-5626,-296,-62063,6280,6894,39058,-68246,-10960,92817,66104,15605,33756,39611,-7476,39040,68180,11065,98236,-65469,-13211,33764,-39613,7502,61891,-8768,-5993},
{0,-46177,0,57024,2682,2496,-60440,1568,-4418,-76303,-743,-688,52109,-756,-4675,27399,-588,-5960,-93565,1744,2399,16825,-7017,-841,-63021,6465,7095,39068,-68286,-10944,92672,66162,15619,33756,39611,-7476,39040,68180,11065,98186,-65502,-13205,33764,-39613,7502,61815,-8997,-5992},
{0,-46407,0,57023,2653,2449,-59372,1465,-4201,-79046,-707,-690,50218,-792,-4618,26868,-648,-6751,-95387,2777,3975,19048,-8861,-1456,-64078,6572,7231,39084,-68349,-10918,92535,66223,15637,33756,39611,-7476,39040,68180,11065,98103,-65537,-13195,33764,-39613,7502,61657,-9119,-5969},
{0,-46636,0,57023,2623,2402,-58303,1365,-3982,-81789,-672,-692,48326,-828,-4561,26337,-704,-7544,-97225,3780,5571,21264,-10719,-2032,-65135,6677,7367,39101,-68413,-10893,92398,66284,15655,33756,39611,-7476,39040,68180,11065,98020,-65573,-13185,33764,-39613,7502,61500,-9241,-5947},
{0,-46422,0,57022,2583,2339,-57436,1269,-3754,-84272,-632,-682,45415,-842,-4426,25265,-733,-8338,-98237,4756,7165,23141,-12588,-2531,-66242,6715,7446,39123,-68498,-10858,92266,66346,15674,33756,39611,-7476,39040,68180,11065,97921,-65609,-13173,33764,-39613,7502,61298,-9276,-5900},
{0,-46208,0,57021,2543,2276,-56568,1174,-3524,-86756,-592,-670,42504,-860,-4293,24193,-753,-9133,-99265,5716,8769,25013,-14466,-2996,-67348,6751,7524,39145,-68584,-10823,92135,66407,15694,33756,39611,-7476,39040,68180,11065,97822,-65645,-13162,33764,-39613,7502,61096,-9311,-5853},
{0,-45544,0,57020,2493,2198,-55944,1080,-3277,-88896,-548,-645,38799,-825,-4104,22631,-720,-9653,-99442,6487,9978,26549,-15901,-3277,-68474,6713,7535,39173,-68690,-10779,92007,66469,15715,33756,39611,-7476,39040,68180,11065,97713,-65681,-13149,33764,-39613,7502,60861,-9250,-5777},
{0,-44879,0,57019,2443,2120,-55319,988,-3029,-91036,-505,-620,35094,-796,-3914,21069,-679,-10173,-99627,7256,11188,28085,-17340,-3537,-69600,6674,7545,39200,-68796,-10736,91880,66530,15736,33756,39611,-7476,39040,68180,11065,97605,-65717,-13137,33764,-39613,7502,60627,-9190,-5700},
{0,-43755,0,57018,2384,2029,-54911,894,-2758,-92818,-458,-579,30821,-695,-3692,19090,-577,-10158,-98918,7667,11630,29280,-17870,-3558,-70723,6534,7453,39233,-68920,-10684,91756,66591,15758,33756,39611,-7476,39040,68180,11065,97490,-65754,-13124,33764,-39613,7502,60364,-8996,-5580},
{0,-42632,0,57017,2325,1937,-54504,800,-2487,-94600,-411,-537,26548,-603,-3466,17110,-476,-10141,-98210,8082,12069,30475,-18400,-3572,-71845,6395,7359,39266,-69045,-10633,91632,66652,15779,33756,39611,-7476,39040,68180,11065,97376,-65790,-13111,33764,-39613,7502,60102,-8803,-5459},
{0,-41084,0,57016,2257,1834,-54210,701,-2190,-96087,-361,-482,21933,-431,-3233,14819,-322,-9087,-96535,7581,10950,31328,-16925,-3270,-72943,6154,7150,39303,-69186,-10575,91512,66712,15802,33756,39611,-7476,39040,68180,11065,97258,-65826,-13097,33764,-39613,7502,59810,-8471,-5283},
{0,-39537,0,57014,2189,1731,-53917,603,-1892,-97573,-312,-425,17318,-270,-2991,12525,-192,-8030,-94867,7062,9840,32174,-15449,-2980,-74041,5915,6939,39340,-69327,-10516,91392,66773,15824,33756,39611,-7476,39040,68180,11065,97139,-65863,-13084,33764,-39613,7502,59518,-8140,-5104},
{0,-37657,0,57011,2114,1617,-53525,496,-1567,-98917,-258,-355,12569,-34,-2768,9878,-68,-6332,-92362,5807,7743,32635,-12566,-2626,-75093,5658,6691,39382,-69483,-10452,91275,66832,15846,33756,39611,-7476,39040,68180,11065,97019,-65899,-13070,33764,-39613,7502,59183,-7784,-4891},
{0,-35777,0,57007,2038,1504,-53133,390,-1241,-100260,-206,-284,7820,190,-2533,7229,12,-4632,-89886,4500,5679,33084,-9681,-2287,-76144,5402,6441,39423,-69639,-10387,91157,66892,15869,33756,39611,-7476,39040,68180,11065,96899,-65935,-13056,33764,-39613,7502,58847,-7431,-4673},
{0,-33705,0,57006,1956,1381,-51431,268,-881,-102648,-147,-201,3124,478,-2344,4181,59,-3326,-86780,3494,4190,33150,-7485,-2165,-77128,5147,6172,39469,-69807,-10317,91043,66950,15891,33756,39611,-7476,39040,68180,11065,96778,-65971,-13043,33764,-39613,7502,58456,-7079,-4427},
{0,-31634,0,57006,1873,1258,-49729,153,-519,-105037,-91,-117,-1574,757,-2142,1133,67,-2019,-83690,2442,2733,33214,-5289,-2045,-78111,4894,5900,39514,-69976,-10246,90929,67009,15914,33756,39611,-7476,39040,68180,11065,96657,-66006,-13029,33764,-39613,7502,58063,-6731,-4176},
{0,-29535,0,57005,1784,1128,-46676,34,-123,-108390,-32,-10,-6324,1087,-2004,-2165,64,-1291,-80136,2036,2144,32983,-4306,-2102,-78982,4649,5615,39563,-70156,-10170,90819,67066,15937,33756,39611,-7476,39040,68180,11065,96536,-66041,-13015,33764,-39613,7502,57591,-6393,-3898},
{0,-27436,0,57005,1695,998,-43624,-73,277,-111744,24,98,-11075,1410,-1851,-5464,37,-563,-76584,1609,1570,32753,-3323,-2156,-79853,4405,5327,39612,-70335,-10095,90708,67123,15960,33756,39611,-7476,39040,68180,11065,96414,-66077,-13002,33764,-39613,7502,57119,-6059,-3616},
{0,-25455,0,57004,1601,862,-39827,-171,705,-115307,77,233,-16068,1764,-1772,-8899,-1,17,-72695,1317,1204,32310,-2631,-2267,-80538,4173,5026,39664,-70524,-10015,90600,67180,15982,33756,39611,-7476,39040,68180,11065,96294,-66111,-12988,33764,-39613,7502,56518,-5742,-3302},
{0,-23474,0,57003,1506,725,-36030,-253,1136,-118870,125,371,-21062,2114,-1676,-12334,-60,595,-68808,1011,850,31868,-1940,-2376,-81224,3943,4723,39716,-70713,-9935,90492,67236,16005,33756,39611,-7476,39040,68180,11065,96173,-66146,-12975,33764,-39613,7502,55916,-5429,-2985},
{0,-21714,0,57003,1407,584,-31897,-317,1578,-122167,166,531,-26023,2469,-1602,-15836,-126,1066,-64715,825,648,31282,-1484,-2516,-81546,3731,4403,39770,-70909,-9851,90388,67291,16027,33756,39611,-7476,39040,68180,11065,96054,-66180,-12962,33764,-39613,7502,55051,-5134,-2640},
{0,-19955,0,57002,1307,443,-27763,-363,2022,-125464,202,692,-30984,2821,-1511,-19337,-209,1534,-60623,631,453,30697,-1028,-2654,-81869,3520,4082,39825,-71105,-9767,90284,67345,16050,33756,39611,-7476,39040,68180,11065,95934,-66214,-12949,33764,-39613,7502,54184,-4845,-2290},
{0,-18475,0,57002,1203,299,-23558,-388,2457,-128293,230,867,-35419,3156,-1391,-22707,-296,1930,-56679,537,359,29930,-739,-2783,-81601,3331,3742,39882,-71307,-9681,90183,67399,16072,33756,39611,-7476,39040,68180,11065,95817,-66247,-12936,33764,-39613,7502,52912,-4571,-1924},
{0,-16995,0,57001,1099,155,-19352,-394,2892,-131123,253,1043,-39855,3487,-1256,-26077,-397,2323,-52736,440,269,29164,-450,-2909,-81333,3141,3402,39939,-71509,-9594,90082,67452,16094,33756,39611,-7476,39040,68180,11065,95699,-66281,-12923,33764,-39613,7502,51639,-4303,-1554},
{0,-15813,0,57001,992,9,-15190,-381,3308,-133389,269,1224,-43651,3793,-1112,-29084,-498,2674,-49373,418,237,28255,-258,-2990,-80727,2955,3054,39997,-71714,-9506,89984,67503,16116,33756,39611,-7476,39040,68180,11065,95584,-66313,-12910,33764,-39613,7502,50497,-4048,-1161},
{0,-14632,0,57000,885,-137,-11029,-351,3724,-135656,282,1406,-47448,4093,-956,-32092,-610,3022,-46011,395,206,27345,-65,-3070,-80122,2769,2709,40056,-71919,-9417,89887,67555,16138,33756,39611,-7476,39040,68180,11065,95469,-66345,-12898,33764,-39613,7502,49353,-3799,-763},
{0,-13747,0,57000,774,-283,-7014,-304,4113,-137301,292,1585,-50470,4364,-812,-34650,-721,3350,-43431,412,201,26451,85,-3104,-79332,2579,2363,40115,-72126,-9326,89794,67605,16159,33756,39611,-7476,39040,68180,11065,95357,-66377,-12885,33764,-39613,7502,48760,-3555,-340},
{0,-12861,0,56999,664,-429,-2998,-242,4499,-138946,299,1764,-53493,4629,-661,-37208,-840,3676,-40850,430,195,25556,236,-3136,-78542,2388,2019,40175,-72333,-9236,89700,67655,16181,33756,39611,-7476,39040,68180,11065,95245,-66408,-12873,33764,-39613,7502,48166,-3313,84},
{0,-12256,0,56999,552,-574,819,-168,4853,-140056,307,1935,-54807,4861,-582,-39242,-956,3992,-39218,456,197,24815,388,-3124,-77638,2190,1678,40235,-72540,-9145,89610,67702,16201,33756,39611,-7476,39040,68180,11065,95136,-66439,-12861,33764,-39613,7502,47795,-3064,513},
{0,-11650,0,56999,439,-719,4636,-81,5205,-141167,314,2106,-56122,5092,-500,-41276,-1077,4307,-37586,481,198,24074,540,-3112,-76734,1991,1339,40296,-72747,-9054,89521,67750,16222,33756,39611,-7476,39040,68180,11065,95028,-66469,-12850,33764,-39613,7502,47423,-2815,942},
{0,-11303,0,56998,325,-862,8220,13,5520,-141804,324,2263,-55155,5287,-541,-42750,-1190,4612,-36991,511,206,23583,696,-3056,-75755,1783,1005,40356,-72952,-8964,89436,67796,16242,33756,39611,-7476,39040,68180,11065,94924,-66498,-12838,33764,-39613,7502,47267,-2553,1369},
{0,-10956,0,56998,211,-1005,11804,118,5831,-142440,333,2420,-54188,5482,-584,-44224,-1307,4916,-36396,541,214,23093,852,-2999,-74778,1575,674,40417,-73157,-8873,89351,67841,16262,33756,39611,-7476,39040,68180,11065,94819,-66527,-12827,33764,-39613,7502,47109,-2290,1795},
{0,-10844,0,56998,97,-1143,15053,223,6101,-142509,350,2553,-51318,5629,-752,-45199,-1412,5206,-36738,578,230,22860,1006,-2899,-73752,1358,348,40477,-73359,-8783,89271,67885,16281,33756,39611,-7476,39040,68180,11065,94720,-66555,-12816,33764,-39613,7502,47144,-2011,2214},
{0,-10733,0,56998,-18,-1281,18302,336,6367,-142578,368,2686,-48448,5772,-925,-46173,-1519,5495,-37081,615,247,22626,1159,-2798,-72727,1139,25,40538,-73560,-8693,89190,67928,16301,33756,39611,-7476,39040,68180,11065,94620,-66582,-12806,33764,-39613,7502,47179,-1728,2631},
{0,-10797,0,56998,-133,-1414,21091,440,6584,-141958,400,2782,-44055,5842,-1209,-46828,-1612,5760,-38022,657,271,22535,1300,-2651,-71675,913,-291,40597,-73755,-8605,89116,67968,16319,33756,39611,-7476,39040,68180,11065,94526,-66609,-12796,33764,-39613,7502,47378,-1426,3036},
{0,-10862,0,56997,-247,-1547,23880,550,6798,-141337,433,2878,-39663,5900,-1495,-47482,-1708,6024,-38963,699,296,22444,1442,-2503,-70623,685,-605,40656,-73951,-8517,89041,68009,16337,33756,39611,-7476,39040,68180,11065,94433,-66635,-12786,33764,-39613,7502,47576,-1121,3437},
{0,-11072,0,56997,-361,-1674,26093,640,6950,-139944,482,2922,-34104,5850,-1857,-47968,-1787,6245,-40223,741,325,22411,1559,-2298,-69561,451,-913,40714,-74139,-8432,88971,68046,16354,33756,39611,-7476,39040,68180,11065,94345,-66659,-12776,33764,-39613,7502,47907,-795,3821},
{0,-11283,0,56997,-475,-1800,28307,733,7100,-138552,532,2965,-28545,5781,-2216,-48453,-1867,6465,-41482,783,354,22377,1676,-2094,-68499,215,-1217,40772,-74328,-8347,88902,68083,16371,33756,39611,-7476,39040,68180,11065,94258,-66683,-12767,33764,-39613,7502,48237,-465,4201},
{0,-11663,0,56998,-588,-1917,29865,797,7177,-136363,595,2946,-22151,5583,-2591,-48800,-1924,6622,-43020,822,387,22436,1756,-1822,-67443,-27,-1515,40827,-74507,-8265,88840,68117,16386,33756,39611,-7476,39040,68180,11065,94179,-66705,-12759,33764,-39613,7502,48668,-116,4558},
{0,-12044,0,56998,-701,-2035,31423,863,7253,-134175,658,2926,-15759,5362,-2953,-49148,-1982,6777,-44558,860,421,22494,1836,-1551,-66387,-270,-1810,40882,-74685,-8183,88777,68151,16402,33756,39611,-7476,39040,68180,11065,94099,-66727,-12750,33764,-39613,7502,49098,238,4911},
{0,-12624,0,57001,-811,-2143,32246,897,7282,-131150,731,2851,-8880,5051,-3286,-49404,-2023,6884,-46307,895,458,22668,1878,-1237,-65358,-517,-2098,40935,-74853,-8106,88722,68181,16415,33756,39611,-7476,39040,68180,11065,94029,-66746,-12743,33764,-39613,7502,49598,609,5237},
{0,-13205,0,57004,-922,-2251,33069,931,7310,-128125,802,2774,-2004,4718,-3597,-49661,-2064,6990,-48056,930,496,22841,1920,-924,-64328,-765,-2384,40988,-75021,-8029,88667,68211,16429,33756,39611,-7476,39040,68180,11065,93958,-66766,-12735,33764,-39613,7502,50096,983,5558},
{0,-14023,0,57005,-1030,-2347,33109,932,7309,-124232,878,2651,4996,4339,-3850,-49835,-2090,7056,-50014,961,538,23187,1926,-590,-63340,-1016,-2663,41036,-75176,-7958,88621,68236,16441,33756,39611,-7476,39040,68180,11065,93898,-66782,-12729,33764,-39613,7502,50636,1372,5847},
{0,-14842,0,57006,-1138,-2444,33148,934,7308,-120339,948,2525,11993,3942,-4076,-50008,-2117,7123,-51973,992,580,23533,1933,-255,-62353,-1268,-2939,41086,-75331,-7886,88575,68262,16453,33756,39611,-7476,39040,68180,11065,93838,-66799,-12723,33764,-39613,7502,51176,1765,6130},
{0,-15944,0,57007,-1242,-2528,32383,903,7288,-115578,1014,2363,18601,3549,-4225,-50130,-2131,7156,-54115,1018,626,24100,1906,84,-61435,-1521,-3210,41130,-75471,-7821,88538,68281,16462,33756,39611,-7476,39040,68180,11065,93791,-66812,-12718,33764,-39613,7502,51736,2166,6376},
{0,-17047,0,57008,-1347,-2611,31618,872,7266,-110817,1072,2198,25207,3147,-4347,-50251,-2146,7189,-56257,1044,673,24667,1881,424,-60519,-1774,-3478,41175,-75612,-7755,88502,68301,16471,33756,39611,-7476,39040,68180,11065,93744,-66825,-12713,33764,-39613,7502,52295,2571,6616},
{0,-18484,0,57009,-1447,-2681,30282,818,7227,-105581,1114,2018,30458,2821,-4382,-50322,-2150,7192,-58613,1065,723,25534,1826,755,-59713,-2025,-3741,41215,-75735,-7698,88478,68314,16477,33756,39611,-7476,39040,68180,11065,93713,-66833,-12710,33764,-39613,7502,52867,2976,6825},
{0,-19921,0,57010,-1547,-2751,28947,765,7187,-100346,1147,1837,35708,2493,-4399,-50393,-2154,7195,-60969,1086,774,26400,1774,1086,-58907,-2277,-4002,41255,-75859,-7640,88454,68327,16483,33756,39611,-7476,39040,68180,11065,93681,-66842,-12706,33764,-39613,7502,53438,3384,7028},
{0,-21738,0,57011,-1642,-2805,27391,703,7127,-95214,1159,1667,38557,2306,-4336,-50454,-2149,7171,-63500,1100,828,27612,1699,1397,-58283,-2521,-4259,41289,-75964,-7591,88445,68332,16486,33756,39611,-7476,39040,68180,11065,93670,-66845,-12705,33764,-39613,7502,54046,3786,7202},
{0,-23556,0,57012,-1738,-2859,25834,641,7065,-90082,1162,1497,41406,2120,-4268,-50515,-2144,7147,-66031,1113,882,28824,1627,1709,-57659,-2765,-4514,41323,-76069,-7541,88437,68337,16488,33756,39611,-7476,39040,68180,11065,93658,-66848,-12704,33764,-39613,7502,54653,4191,7370},
{0,-25756,0,57014,-1828,-2896,24501,586,6978,-85811,1149,1360,40893,2117,-4124,-50633,-2133,7097,-68637,1119,936,30395,1539,1991,-57371,-2993,-4770,41351,-76154,-7501,88447,68334,16487,33756,39611,-7476,39040,68180,11065,93658,-66847,-12704,33764,-39613,7502,55402,4581,7511},
{0,-27957,0,57015,-1917,-2932,23168,533,6891,-81541,1129,1224,40379,2113,-3980,-50752,-2123,7046,-71243,1124,991,31967,1456,2273,-57083,-3221,-5025,41378,-76239,-7461,88458,68331,16487,33756,39611,-7476,39040,68180,11065,93658,-66845,-12704,33764,-39613,7502,56151,4973,7646},
{0,-30427,0,57016,-2001,-2951,22510,501,6773,-78938,1104,1138,34394,2352,-3708,-51072,-2111,6968,-73644,1120,1037,33807,1366,2520,-57343,-3418,-5287,41399,-76302,-7431,88487,68322,16485,33756,39611,-7476,39040,68180,11065,93658,-66840,-12703,33764,-39613,7502,57207,5343,7755},
{0,-32897,0,57017,-2084,-2969,21852,470,6654,-76335,1076,1052,28407,2574,-3422,-51391,-2100,6891,-76046,1115,1083,35647,1280,2767,-57604,-3614,-5549,41420,-76365,-7401,88517,68313,16483,33756,39611,-7476,39040,68180,11065,93658,-66836,-12703,33764,-39613,7502,58262,5715,7858},
{0,-35338,0,57018,-2161,-2968,22144,469,6503,-75914,1051,1019,20190,2865,-3039,-52146,-2095,6784,-77718,1102,1107,37511,1198,2974,-58202,-3787,-5807,41432,-76405,-7383,88564,68299,16480,33756,39611,-7476,39040,68180,11065,93658,-66829,-12703,33764,-39613,7502,59366,6056,7932},
{0,-37779,0,57019,-2238,-2966,22435,468,6352,-75493,1026,987,11971,3125,-2633,-52902,-2090,6677,-79390,1088,1131,39375,1120,3183,-58800,-3959,-6066,41445,-76444,-7364,88610,68285,16478,33756,39611,-7476,39040,68180,11065,93658,-66822,-12702,33764,-39613,7502,60471,6399,8002},
{0,-39811,0,57020,-2306,-2943,23719,494,6167,-77356,1003,1002,8505,3240,-2332,-54316,-2097,6538,-79768,1069,1119,40967,1059,3348,-59583,-4123,-6302,41450,-76457,-7358,88672,68266,16474,33756,39611,-7476,39040,68180,11065,93659,-66812,-12702,33764,-39613,7502,61423,6704,8032},
{0,-41844,0,57021,-2375,-2920,25002,517,5981,-79219,979,1017,5039,3346,-2028,-55731,-2103,6400,-80146,1049,1108,42559,1000,3513,-60366,-4286,-6540,41454,-76471,-7351,88733,68247,16470,33756,39611,-7476,39040,68180,11065,93660,-66803,-12701,33764,-39613,7502,62375,7010,8060},
{0,-43245,0,57021,-2436,-2875,26072,558,6073,-83549,573,641,8244,3909,-1722,-54993,-2038,6280,-82266,1028,1133,43711,1081,3534,-61266,-4453,-6738,41450,-76457,-7358,88808,68225,16465,33756,39611,-7476,39040,68180,11065,93662,-66791,-12701,33764,-39613,7502,62758,7247,8059},
{0,-44645,0,57022,-2496,-2829,27143,600,6165,-87881,182,249,11449,4482,-1435,-54255,-1974,6159,-84386,1006,1157,44862,1163,3554,-62166,-4619,-6937,41445,-76444,-7364,88883,68202,16460,33756,39611,-7476,39040,68180,11065,93664,-66780,-12700,33764,-39613,7502,63142,7484,8058},
{0,-45410,0,57023,-2547,-2764,27383,661,6710,-90838,-696,-897,13985,5933,-888,-54106,-1934,6053,-85525,987,1162,45089,1366,3358,-63142,-4777,-7106,41432,-76405,-7383,88969,68176,16455,33756,39611,-7476,39040,68180,11065,93666,-66767,-12700,33764,-39613,7502,63195,7670,8034},
{0,-46174,0,57023,-2598,-2698,27623,724,7255,-93804,-1541,-2068,16515,7397,-377,-53957,-1895,5946,-86663,967,1167,45316,1569,3162,-64118,-4934,-7276,41420,-76365,-7401,89056,68149,16449,33756,39611,-7476,39040,68180,11065,93669,-66754,-12699,33764,-39613,7502,63248,7856,8010},
{0,-46403,0,57024,-2639,-2614,27223,788,8058,-95779,-2563,-3640,18538,9305,223,-54225,-1868,5833,-87200,948,1157,44708,1797,2823,-65143,-5068,-7421,41399,-76302,-7431,89152,68120,16442,33756,39611,-7476,39040,68180,11065,93673,-66739,-12699,33764,-39613,7502,63196,8003,7962},
{0,-46633,0,57024,-2679,-2530,26823,848,8861,-97769,-3554,-5232,20554,11225,785,-54492,-1840,5720,-87738,929,1147,44100,2028,2486,-66168,-5201,-7567,41378,-76239,-7461,89249,68090,16436,33756,39611,-7476,39040,68180,11065,93677,-66724,-12698,33764,-39613,7502,63144,8150,7916},
{0,-46419,0,57024,-2709,-2430,25912,881,9671,-98972,-4507,-6834,22157,13146,1292,-54999,-1811,5581,-88062,907,1127,42749,2198,2090,-67222,-5296,-7681,41351,-76154,-7501,89354,68058,16428,33756,39611,-7476,39040,68180,11065,93682,-66708,-12698,33764,-39613,7502,63039,8247,7848},
{0,-46205,0,57024,-2738,-2331,25000,907,10482,-100191,-5441,-8448,23755,15075,1770,-55507,-1781,5441,-88386,884,1107,41398,2374,1697,-68276,-5389,-7796,41323,-76069,-7541,89460,68025,16421,33756,39611,-7476,39040,68180,11065,93688,-66691,-12698,33764,-39613,7502,62934,8345,7780},
{0,-45540,0,57024,-2754,-2217,23642,879,11027,-100630,-6172,-9678,24969,16552,2081,-56087,-1738,5258,-88764,854,1078,39281,2437,1337,-69341,-5415,-7851,41289,-75964,-7591,89573,67990,16413,33756,39611,-7476,39040,68180,11065,93695,-66674,-12698,33764,-39613,7502,62795,8357,7686},
{0,-44875,0,57024,-2771,-2104,22284,844,11572,-101079,-6898,-10912,26181,18033,2374,-56668,-1694,5076,-89141,824,1050,37164,2509,979,-70406,-5440,-7905,41255,-75859,-7640,89686,67955,16405,33756,39611,-7476,39040,68180,11065,93702,-66656,-12697,33764,-39613,7502,62656,8370,7592},
{0,-43751,0,57024,-2767,-1984,20548,744,11590,-100706,-7260,-11385,27021,18594,2420,-57094,-1626,4838,-89836,784,1014,34196,2451,740,-71465,-5372,-7868,41215,-75735,-7698,89806,67918,16396,33756,39611,-7476,39040,68180,11065,93711,-66637,-12697,33764,-39613,7502,62488,8259,7462},
{0,-42628,0,57023,-2764,-1863,18812,643,11606,-100334,-7624,-11856,27861,19155,2462,-57520,-1557,4600,-90531,744,978,31228,2401,500,-72524,-5304,-7829,41175,-75612,-7755,89925,67880,16387,33756,39611,-7476,39040,68180,11065,93720,-66619,-12697,33764,-39613,7502,62321,8149,7332},
{0,-41080,0,57022,-2735,-1740,16812,480,10572,-99095,-7096,-10760,28361,17707,2100,-57503,-1456,4302,-91783,692,935,27240,2246,443,-73558,-5188,-7737,41130,-75471,-7821,90051,67841,16378,33756,39611,-7476,39040,68180,11065,93730,-66599,-12698,33764,-39613,7502,62117,7978,7172},
{0,-39533,0,57022,-2705,-1616,14810,337,9536,-97862,-6555,-9671,28855,16257,1747,-57485,-1355,4005,-93036,640,891,23252,2093,380,-74593,-5072,-7644,41086,-75331,-7886,90176,67801,16369,33756,39611,-7476,39040,68180,11065,93741,-66579,-12698,33764,-39613,7502,61913,7808,7011},
{0,-37653,0,57020,-2652,-1491,12499,186,7830,-95893,-5323,-7573,28978,13396,1214,-56679,-1218,3650,-95008,576,838,17938,1882,546,-75583,-4932,-7517,41037,-75176,-7958,90306,67760,16359,33756,39611,-7476,39040,68180,11065,93754,-66558,-12698,33764,-39613,7502,61662,7608,6825},
{0,-35773,0,57019,-2599,-1365,10185,75,6121,-93952,-4051,-5501,29085,10535,686,-55872,-1085,3293,-96980,513,783,12625,1663,700,-76572,-4793,-7389,40988,-75021,-8029,90436,67719,16349,33756,39611,-7476,39040,68180,11065,93767,-66537,-12699,33764,-39613,7502,61410,7409,6638},
{0,-33702,0,57016,-2525,-1238,7553,-5,4801,-91527,-3081,-4007,28833,8341,356,-53525,-914,2888,-100094,437,716,6613,1395,958,-77488,-4642,-7236,40935,-74853,-8106,90569,67676,16339,33756,39611,-7476,39040,68180,11065,93783,-66515,-12699,33764,-39613,7502,61093,7194,6429},
{0,-31631,0,57012,-2450,-1111,4920,-49,3480,-89118,-2075,-2538,28574,6149,22,-51178,-752,2479,-103208,363,647,602,1112,1199,-78404,-4491,-7080,40883,-74685,-8183,90703,67633,16329,33756,39611,-7476,39040,68180,11065,93798,-66493,-12700,33764,-39613,7502,60775,6981,6218},
{0,-29532,0,57011,-2357,-984,2109,-78,2752,-86395,-1686,-1961,28057,5144,-92,-47807,-581,2036,-106750,284,555,-5217,776,1380,-79211,-4335,-6902,40827,-74507,-8265,90839,67589,16318,33756,39611,-7476,39040,68180,11065,93816,-66470,-12701,33764,-39613,7502,60363,6759,5987},
{0,-27433,0,57010,-2263,-856,-702,-86,2023,-83675,-1282,-1395,27539,4141,-212,-44435,-424,1588,-110292,209,461,-11035,430,1541,-80018,-4180,-6723,40772,-74328,-8347,90975,67544,16307,33756,39611,-7476,39040,68180,11065,93834,-66447,-12702,33764,-39613,7502,59950,6539,5754},
{0,-25452,0,57009,-2153,-728,-3537,-81,1443,-80842,-1011,-1043,26887,3412,-278,-40614,-276,1119,-113699,136,339,-16553,52,1630,-80642,-4027,-6521,40714,-74139,-8432,91112,67499,16296,33756,39611,-7476,39040,68180,11065,93855,-66423,-12704,33764,-39613,7502,59384,6315,5503},
{0,-23472,0,57008,-2042,-600,-6372,-61,862,-78011,-729,-698,26235,2684,-348,-36793,-146,645,-117105,67,215,-22072,-330,1698,-81265,-3875,-6318,40656,-73951,-8517,91250,67453,16285,33756,39611,-7476,39040,68180,11065,93876,-66400,-12705,33764,-39613,7502,58819,6094,5249},
{0,-21713,0,57007,-1917,-473,-9146,-33,390,-75227,-565,-512,25541,2178,-385,-32754,-34,163,-120192,4,67,-27152,-722,1696,-81553,-3734,-6090,40597,-73755,-8605,91388,67407,16273,33756,39611,-7476,39040,68180,11065,93901,-66375,-12707,33764,-39613,7502,57967,5870,4979},
{0,-19954,0,57006,-1792,-345,-11920,8,-81,-72443,-397,-330,24846,1672,-426,-28714,59,-322,-123278,-53,-83,-32233,-1112,1675,-81840,-3594,-5862,40538,-73560,-8693,91527,67361,16262,33756,39611,-7476,39040,68180,11065,93925,-66351,-12709,33764,-39613,7502,57115,5651,4706},
{0,-18474,0,57005,-1654,-219,-14562,54,-480,-69854,-327,-257,24194,1335,-448,-24573,131,-802,-125981,-102,-251,-36732,-1492,1596,-81598,-3473,-5604,40477,-73359,-8783,91665,67314,16250,33756,39611,-7476,39040,68180,11065,93953,-66326,-12711,33764,-39613,7502,55818,5430,4419},
{0,-16994,0,57004,-1516,-93,-17204,110,-877,-67266,-255,-184,23543,997,-473,-20432,182,-1285,-128684,-147,-419,-41231,-1868,1500,-81357,-3352,-5347,40417,-73157,-8873,91803,67266,16238,33756,39611,-7476,39040,68180,11065,93980,-66301,-12714,33764,-39613,7502,54520,5215,4127},
{0,-15813,0,57003,-1368,31,-19684,170,-1231,-64947,-254,-176,22986,773,-491,-16269,211,-1749,-130969,-182,-599,-45011,-2218,1367,-80802,-3234,-5071,40356,-72952,-8964,91940,67219,16226,33756,39611,-7476,39040,68180,11065,94012,-66275,-12716,33764,-39613,7502,53066,4999,3823},
{0,-14631,0,57002,-1220,156,-22163,239,-1584,-62628,-254,-167,22429,549,-510,-12106,220,-2213,-133254,-213,-778,-48792,-2563,1220,-80248,-3116,-4796,40296,-72747,-9054,92077,67171,16214,33756,39611,-7476,39040,68180,11065,94043,-66249,-12719,33764,-39613,7502,51612,4789,3514},
{0,-13746,0,57001,-1063,278,-24456,311,-1916,-60639,-290,-185,22012,384,-531,-8007,209,-2647,-135076,-237,-961,-51720,-2875,1060,-79523,-2990,-4509,40235,-72540,-9145,92212,67123,16202,33756,39611,-7476,39040,68180,11065,94079,-66223,-12723,33764,-39613,7502,50395,4579,3195},
{0,-12861,0,57000,-907,400,-26749,391,-2246,-58651,-327,-202,21594,219,-553,-3908,180,-3081,-136899,-258,-1143,-54649,-3181,891,-78798,-2864,-4223,40175,-72333,-9236,92346,67075,16189,33756,39611,-7476,39040,68180,11065,94115,-66197,-12726,33764,-39613,7502,49178,4374,2873},
{0,-12256,0,57000,-745,518,-28858,475,-2567,-57001,-368,-221,21333,67,-581,53,134,-3474,-138250,-275,-1319,-55867,-3446,759,-77967,-2726,-3927,40115,-72126,-9326,92478,67026,16177,33756,39611,-7476,39040,68180,11065,94155,-66170,-12730,33764,-39613,7502,48713,4174,2523},
{0,-11650,0,56999,-582,637,-30968,566,-2887,-55350,-409,-239,21071,-85,-610,4015,72,-3865,-139601,-289,-1496,-57086,-3709,625,-77135,-2587,-3634,40056,-71919,-9417,92609,66978,16164,33756,39611,-7476,39040,68180,11065,94196,-66143,-12734,33764,-39613,7502,48247,3974,2173},
{0,-11303,0,56999,-416,752,-32892,659,-3198,-54053,-447,-254,20985,-230,-648,7753,0,-4207,-140443,-302,-1658,-56070,-3931,577,-76235,-2435,-3332,39997,-71714,-9506,92736,66930,16151,33756,39611,-7476,39040,68180,11065,94241,-66115,-12739,33764,-39613,7502,48146,3780,1762},
{0,-10957,0,56998,-250,867,-34816,758,-3506,-52757,-485,-269,20900,-375,-685,11492,-85,-4547,-141285,-314,-1820,-55055,-4153,532,-75335,-2281,-3033,39939,-71509,-9594,92863,66881,16138,33756,39611,-7476,39040,68180,11065,94287,-66088,-12744,33764,-39613,7502,48044,3584,1351},
{0,-10845,0,56998,-83,978,-36579,856,-3799,-51775,-520,-283,20983,-510,-735,14883,-173,-4832,-141515,-331,-1956,-52169,-4330,586,-74390,-2113,-2727,39882,-71307,-9681,92984,66833,16125,33756,39611,-7476,39040,68180,11065,94339,-66060,-12749,33764,-39613,7502,48133,3386,875},
{0,-10734,0,56998,85,1088,-38342,959,-4089,-50794,-556,-297,21066,-645,-784,18275,-269,-5113,-141745,-348,-2092,-49283,-4506,644,-73446,-1943,-2423,39825,-71106,-9767,93105,66785,16111,33756,39611,-7476,39040,68180,11065,94390,-66032,-12755,33764,-39613,7502,48222,3184,401},
{0,-10798,0,56998,252,1194,-40021,1060,-4354,-49984,-587,-308,21256,-765,-851,21175,-359,-5333,-141242,-374,-2190,-44888,-4621,798,-72476,-1757,-2112,39770,-70909,-9851,93218,66737,16098,33756,39611,-7476,39040,68180,11065,94448,-66004,-12761,33764,-39613,7502,48429,2958,-85},
{0,-10863,0,56998,418,1299,-41701,1166,-4617,-49173,-619,-319,21446,-884,-917,24074,-454,-5550,-140739,-402,-2288,-40493,-4730,956,-71505,-1569,-1804,39716,-70713,-9935,93332,66690,16084,33756,39611,-7476,39040,68180,11065,94506,-65976,-12768,33764,-39613,7502,48635,2728,-570},
{0,-11074,0,56998,582,1399,-43330,1264,-4839,-48473,-644,-328,21722,-983,-1011,26354,-532,-5698,-139429,-441,-2336,-34920,-4755,1186,-70525,-1365,-1490,39664,-70524,-10015,93437,66643,16070,33756,39611,-7476,39040,68180,11065,94572,-65948,-12775,33764,-39613,7502,48923,2458,-1018},
{0,-11284,0,56998,746,1499,-44959,1365,-5060,-47773,-670,-335,21997,-1082,-1105,28633,-613,-5845,-138119,-482,-2383,-29347,-4767,1416,-69545,-1160,-1178,39612,-70335,-10095,93541,66596,16056,33756,39611,-7476,39040,68180,11065,94637,-65919,-12783,33764,-39613,7502,49211,2184,-1464},
{0,-11665,0,56999,905,1592,-46514,1455,-5228,-47239,-690,-341,22397,-1154,-1234,30204,-668,-5923,-135995,-533,-2375,-22903,-4685,1678,-68569,-937,-860,39563,-70156,-10170,93636,66550,16041,33756,39611,-7476,39040,68180,11065,94711,-65891,-12792,33764,-39613,7502,49560,1870,-1870},
{0,-12045,0,57000,1064,1686,-48069,1546,-5395,-46706,-709,-346,22797,-1226,-1363,31774,-724,-5999,-133871,-583,-2365,-16459,-4587,1934,-67594,-712,-544,39514,-69976,-10246,93730,66504,16027,33756,39611,-7476,39040,68180,11065,94785,-65862,-12800,33764,-39613,7502,49907,1552,-2273},
{0,-12626,0,57000,1215,1772,-49516,1628,-5528,-46416,-726,-352,23370,-1278,-1507,32560,-753,-6036,-130919,-642,-2310,-9466,-4426,2195,-66639,-469,-222,39469,-69807,-10317,93811,66459,16011,33756,39611,-7476,39040,68180,11065,94869,-65833,-12810,33764,-39613,7502,50307,1196,-2640},
{0,-13207,0,57001,1366,1858,-50964,1711,-5659,-46126,-743,-358,23943,-1330,-1651,33346,-782,-6073,-127966,-699,-2253,-2475,-4248,2443,-65684,-225,98,39423,-69639,-10387,93892,66415,15996,33756,39611,-7476,39040,68180,11065,94953,-65804,-12821,33764,-39613,7502,50704,837,-3002},
{0,-14025,0,57005,1508,1937,-52265,1784,-5764,-46174,-759,-367,24750,-1364,-1800,33295,-782,-6087,-124183,-760,-2159,4727,-4033,2675,-64772,38,425,39382,-69483,-10452,93958,66372,15980,33756,39611,-7476,39040,68180,11065,95048,-65775,-12832,33764,-39613,7502,51150,442,-3331},
{0,-14844,0,57009,1650,2015,-53567,1858,-5868,-46223,-776,-376,25558,-1399,-1949,33244,-782,-6100,-120399,-817,-2063,11927,-3802,2891,-63860,303,749,39340,-69327,-10516,94024,66329,15964,33756,39611,-7476,39040,68180,11065,95144,-65747,-12844,33764,-39613,7502,51594,43,-3655},
{0,-15946,0,57011,1780,2086,-54671,1920,-5948,-46716,-794,-389,26665,-1415,-2097,32367,-755,-6099,-115815,-870,-1937,18829,-3560,3070,-63009,587,1081,39303,-69186,-10575,94072,66288,15947,33756,39611,-7476,39040,68180,11065,95253,-65718,-12858,33764,-39613,7502,52091,-389,-3949},
{0,-17048,0,57012,1911,2156,-55776,1982,-6028,-47210,-812,-403,27773,-1433,-2246,31491,-727,-6096,-111231,-917,-1809,25729,-3308,3232,-62159,874,1412,39266,-69045,-10633,94120,66248,15930,33756,39611,-7476,39040,68180,11065,95363,-65689,-12871,33764,-39613,7502,52586,-824,-4238},
{0,-18485,0,57014,2027,2217,-56659,2030,-6082,-48224,-831,-424,29237,-1432,-2392,30078,-682,-6077,-106229,-952,-1669,31297,-3094,3329,-61411,1181,1751,39233,-68920,-10684,94145,66210,15912,33756,39611,-7476,39040,68180,11065,95489,-65661,-12887,33764,-39613,7502,53148,-1292,-4499},
{0,-19923,0,57015,2143,2278,-57541,2078,-6136,-49238,-851,-445,30701,-1433,-2539,28664,-636,-6057,-101227,-979,-1528,36864,-2876,3414,-60663,1489,2089,39200,-68796,-10736,94171,66172,15893,33756,39611,-7476,39040,68180,11065,95616,-65632,-12903,33764,-39613,7502,53709,-1763,-4755},
{0,-21740,0,57017,2243,2330,-58198,2109,-6161,-50808,-871,-473,32558,-1413,-2683,27093,-584,-6013,-96324,-989,-1393,39958,-2749,3413,-60082,1819,2440,39173,-68690,-10779,94170,66137,15873,33756,39611,-7476,39040,68180,11065,95764,-65604,-12922,33764,-39613,7502,54376,-2268,-4978},
{0,-23557,0,57018,2343,2381,-58855,2140,-6186,-52378,-892,-502,34415,-1395,-2828,25522,-532,-5969,-91420,-993,-1258,43052,-2622,3409,-59501,2151,2789,39145,-68584,-10823,94169,66103,15852,33756,39611,-7476,39040,68180,11065,95913,-65576,-12941,33764,-39613,7502,55043,-2776,-5195},
{0,-25758,0,57020,2425,2423,-59375,2154,-6175,-54350,-909,-536,36607,-1355,-2973,24233,-487,-5894,-87259,-982,-1145,42604,-2627,3298,-59231,2501,3157,39123,-68498,-10858,94135,66073,15829,33756,39611,-7476,39040,68180,11065,96090,-65549,-12963,33764,-39613,7502,55924,-3318,-5375},
{0,-27959,0,57021,2506,2464,-59896,2168,-6164,-56323,-926,-570,38800,-1318,-3119,22944,-443,-5818,-83098,-967,-1033,42156,-2631,3187,-58961,2853,3525,39101,-68413,-10893,94101,66043,15806,33756,39611,-7476,39040,68180,11065,96268,-65522,-12986,33764,-39613,7502,56804,-3863,-5548},
{0,-30429,0,57022,2567,2494,-60446,2166,-6104,-58360,-934,-602,41163,-1256,-3272,22345,-417,-5703,-80371,-943,-955,35983,-2814,2894,-58961,3229,3918,39084,-68349,-10918,94026,66019,15779,33756,39611,-7476,39040,68180,11065,96486,-65497,-13013,33764,-39613,7502,57807,-4445,-5677},
{0,-32899,0,57023,2628,2524,-60997,2164,-6044,-60398,-941,-634,43527,-1198,-3426,21746,-392,-5587,-77643,-917,-877,29809,-2979,2591,-58962,3605,4311,39068,-68286,-10944,93952,65995,15752,33756,39611,-7476,39040,68180,11065,96704,-65471,-13040,33764,-39613,7502,58809,-5029,-5798},
{0,-35340,0,57024,2667,2543,-61882,2147,-5916,-61833,-933,-647,45703,-1113,-3600,22074,-389,-5422,-76865,-889,-837,21194,-3164,2159,-59030,4026,4726,39058,-68246,-10960,93824,65979,15718,33756,39611,-7476,39040,68180,11065,96988,-65449,-13074,33764,-39613,7502,59639,-5657,-5866},
{0,-37781,0,57024,2705,2562,-62766,2130,-5787,-63268,-924,-661,47879,-1031,-3777,22401,-386,-5256,-76087,-860,-796,12577,-3311,1712,-59099,4447,5141,39048,-68207,-10976,93697,65963,15685,33756,39611,-7476,39040,68180,11065,97271,-65426,-13109,33764,-39613,7502,60469,-6284,-5926},
{0,-39814,0,57025,2718,2568,-64255,2092,-5556,-63442,-892,-639,49486,-918,-4001,23702,-402,-5022,-77638,-827,-789,8777,-3307,1350,-59359,4933,5590,39044,-68193,-10982,93500,65959,15641,33756,39611,-7476,39040,68180,11065,97684,-65408,-13153,33764,-39613,7502,61051,-6966,-5949},
{0,-41847,0,57025,2731,2574,-65744,2051,-5326,-63617,-860,-618,51093,-809,-4228,25003,-414,-4788,-79188,-794,-781,4976,-3289,989,-59621,5419,6039,39041,-68180,-10987,93303,65954,15596,33756,39611,-7476,39040,68180,11065,98096,-65391,-13198,33764,-39613,7502,61633,-7647,-5967},
}
local clip={Duration=2.0,Loop=true,Source="Quaternius original GLB",Role="Walk_Carry_Loop",Frames={}}
for i,row in rows do
 local pose:{[string]:CFrame}={};for j,name in joints do local k=4+(j-1)*3;local c=CFrame.Angles(row[k]/100000,row[k+1]/100000,row[k+2]/100000);pose[name]=if name=="Root"then CFrame.new(row[1]/100000,row[2]/100000,row[3]/100000)*c else c end
 clip.Frames[i]={Time=math.min((i-1)/60,clip.Duration),Pose=pose}
end
return clip
]====])
entry.Parent=game.StarterPlayer.StarterPlayerScripts
end
print("Summoner Survival installed. Save your place and press Play.")
