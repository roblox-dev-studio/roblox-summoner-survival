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
