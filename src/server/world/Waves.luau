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
