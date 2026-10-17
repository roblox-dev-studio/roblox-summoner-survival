-- Automatic spells, ice projectiles, summon AI and damage. No client-owned damage.
return function(deps)
	local world, enemies, rng = deps.world, deps.enemies, deps.rng
	local block, rootOf, paused = deps.block, deps.rootOf, deps.paused
	local effect, drop = deps.effect, deps.drop
	local iceShots = {}
	local nextIceShot = 0
	local areaSpells,activeSpells,missiles,crystals,skyLances
	-- Temporary visual preview: all golems show the final-tier presentation.
	-- Damage, fragment damage and extra damage hits still use the actual upgrade level.
	local PREVIEW_MAX_GOLEM_EFFECTS = true

	local function damage(e,amount,s)
		if e.hp<=0 then return end
		e.hp-=amount
		e.model:SetAttribute("HP",math.max(0,e.hp))
		effect:FireAllClients("hit",e.pos,amount)
		if e.hp<=0 then
			s.kills+=1
			if not e.isBoss then drop(e.pos);if e.elite then drop(e.pos+Vector3.new(1,0,0));drop(e.pos-Vector3.new(1,0,0))end; e.model:Destroy() end
		end
	end
	areaSpells=require(script.Parent.AreaSpells)({world=world,enemies=enemies,effect=effect,damage=damage})
	activeSpells=require(script.Parent.ActiveSpells)({world=world,enemies=enemies,effect=effect,damage=damage})
	missiles=require(script.Parent.HomingMissiles)({world=world,enemies=enemies,effect=effect,damage=damage,rootOf=rootOf})
	crystals=require(script.Parent.ArcaneCrystals)({world=world,enemies=enemies,effect=effect,damage=damage,rootOf=rootOf})
	skyLances=require(script.Parent.SkyLances)({world=world,enemies=enemies,effect=effect,damage=damage})
	local function nearest(pos,range)
		local found,dist=nil,range
		for _,e in ipairs(enemies) do if e.hp>0 then local d=(e.pos-pos).Magnitude; if d<dist then found,dist=e,d end end end
		return found
	end
	local function clearIceShots(source)
		missiles.Clear(source);crystals.Clear(source);skyLances.Clear(source)
		if source then areaSpells.Clear(source);activeSpells.Clear(source) end
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
						duration=target.isBoss and 0 or duration
						target.frozen=math.max(target.frozen or 0,duration)
						target.slow=math.max(target.slow,2+shot.level*.4)
						target.model:SetAttribute("Frozen",duration>0)
						damage(target,10+shot.level*8,shot.source)
						if target.hp>0 and not target.isBoss then
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
					if knock and knock>0 and not e.isBoss then
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
	local function requestWave(s,aim)
		if s.over or s.cooldown>0 or s.offers or paused() then return end
		local root=rootOf(s); if not root then return end
		local origin=root.Position
		local facing=root.CFrame.LookVector
        if aim~=nil then
            if typeof(aim)~="Vector3" or aim.X~=aim.X or aim.Z~=aim.Z or math.abs(aim.X)>10000 or math.abs(aim.Z)>10000 then return end
            facing=aim
        end
        local direction=Vector3.new(facing.X,0,facing.Z)
		if direction.Magnitude<.01 then direction=Vector3.new(0,0,-1) else direction=direction.Unit end
		if s.activeSkill and s.activeSkill~="fireWave" then return activeSpells.Request(s,origin,direction) end
		s.cooldown=7
		effect:FireAllClients("fireWave",origin,direction,30)
		for _,e in ipairs(enemies) do
			local delta=Vector3.new(e.pos.X-origin.X,0,e.pos.Z-origin.Z)
			local distance=delta.Magnitude
			if e.hp>0 and not e.airborne and distance<=30 and (distance<.1 or delta.Unit:Dot(direction)>=math.cos(math.rad(35))) then
				damage(e,40+s.fire*10,s)
				if e.hp>0 then
					if not e.isBoss then e.pos+=direction*5 end; e.slow=math.max(e.slow,.7)
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
			activeSpells.Step(s,dt)
			missiles.StepPlayer(s,r,dt)
			crystals.StepPlayer(s,r,dt)
			skyLances.Step(s,r,dt)
			areaSpells.Step(s,r,dt)
			s.fireClock-=dt; s.lightningClock-=dt; s.iceClock-=dt; s.golemClock-=dt
			local target=nearest(r.Position,46)
			if target and s.fire>0 and s.fireClock<=0 then
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
		StepProjectiles = function(dt)advanceIceSpears(dt);missiles.Step(dt);crystals.Step(dt)end,
		ClearProjectiles = clearIceShots,
		RequestWave = requestWave,
	}
end
