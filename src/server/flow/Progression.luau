-- XP, offers, upgrades and the HUD state packet.
return function(deps)
	local world, states, gems, rng = deps.world, deps.states, deps.gems, deps.rng
	local block, rootOf, paused = deps.block, deps.rootOf, deps.paused
	local finishDash, update, clock = deps.finishDash, deps.update, deps.clock
	local spellOptions=deps.spellOptions
	local function need(s) return 5+(s.level-1)*3 end
	local labels={fire="화염탄",lightning="연쇄 번개",ice="빙결 얼음창",golem="골렘",meteor="메테오",blades="비전 결정",frost="서리 폭발",ward="수호 결계",missile="추적 마탄",skyLances="천공의 창"}
	local function choices(s)
		local pool={}
		for _,id in ipairs({"fire","lightning","ice","golem","meteor","blades","frost","ward","missile","skyLances"}) do
			local lv=s[id] or 0
			if lv<5 and (not s.loadout or id=="golem" or table.find(s.loadout,id)) then
				local description
				if id=="fire" then description="피해량 +8 · 폭발 범위 증가"
				elseif id=="lightning" then description=lv==0 and "주변 적을 연결하는 번개를 자동 발사" or "피해량과 연쇄 타격 수 증가"
				elseif id=="meteor" then description=lv==0 and "밀집한 적을 향해 운석 낙하 · 넓은 폭발" or "운석 피해 +18 · 범위 증가 · 대기시간 감소"
				elseif id=="blades" then description="다섯 결정 피해 증가 · 재충전 시간 감소"
				elseif id=="skyLances" then description="낙하 창 피해 증가 · 재사용 대기시간 감소"
				elseif id=="frost" then description="냉기 피해·범위·빙결 시간 증가"
				elseif id=="missile" then description="단일 대상 마탄 피해 증가 · 강화 시 발사 수 증가"
				elseif id=="ward" then description="보호막 흡수량 증가 · 재사용 시간 감소"
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
        local remaining=clock.phase=="boss" and math.floor(clock.bossElapsed) or clock.roundLength-math.floor(clock.elapsed)
        local b=clock.boss
		update:FireClient(s.player,{time=math.max(0,remaining),phase=clock.phase,lobby=s.lobby==true,queued=s.queued==true,loadout=s.loadout,spellOptions=s.lobby and spellOptions or nil,activeOptions=s.lobby and deps.activeOptions or nil,activeSkill=s.activeSkill or "fireWave",activeName=s.activeName or "화염 파동",lobbyMessage=s.lobbyMessage,shield=s.shield or 0,boss=b and {name=b.name,hp=math.max(0,b.hp),maxHp=b.maxHp,stage=b.phase,airborne=b.airborne} or nil,level=s.level,xp=s.xp,need=need(s),hp=h and math.ceil(h.Health) or 0,maxHp=h and h.MaxHealth or 100,
			kills=s.kills,fire=s.fire,lightning=s.lightning,ice=s.ice,meteor=s.meteor or 0,blades=s.blades or 0,frost=s.frost or 0,ward=s.ward or 0,missile=s.missile or 0,skyLances=s.skyLances or 0,golem=s.golem,offers=s.offers,over=s.over,result=s.result,cooldown=math.max(0,math.ceil(s.cooldown)),dashCooldown=math.ceil((s.dashCooldown or 0)*10)/10,golemCooldown=math.max(0,math.ceil(s.petHeavyCooldown or 0)),paused=paused()})
	end
	local function levelCheck(s)
		if s.over or s.offers or s.lobby then return end
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
		if s.over or s.lobby then return end
		if not s.offers or type(id)~="string" then return end
		local valid=false; for _,v in ipairs(s.offers) do if v.id==id then valid=true; break end end
		if not valid then return end
		if id=="vitality" then
			s.vitality+=1; local _,h=rootOf(s); if h then h.MaxHealth+=15; h.Health=math.min(h.MaxHealth,h.Health+30) end
		else s[id]=(s[id] or 0)+1 end
		s.offers=nil
		local _,h=rootOf(s); if h then h.WalkSpeed=22+s.agility*2 end
		levelCheck(s); sync(s)
	end
	local function collect(dt)
        for i=#gems,1,-1 do
            local gem=gems[i]
            local collector=gem.collector
            local r,h
            if collector and states[collector.player]==collector and not collector.offers then r,h=rootOf(collector) end
            if not r then
                collector=nil
                local best=math.huge
                for _,s in pairs(states) do
                    local candidate,humanoid=rootOf(s)
                    if candidate and not s.offers then
                        local delta=candidate.Position-gem.pos
                        local distance=Vector3.new(delta.X,0,delta.Z).Magnitude
                        if distance<18+s.magnet*3 and distance<best then
                            collector,r,h,best=s,candidate,humanoid,distance
                        end
                    end
                end
            end
            gem.collector=collector
            if collector then
                local delta=r.Position-gem.pos
                local distance=delta.Magnitude
                -- Stay attached once attracted; run speed and dashes cannot strand it.
                local travel=(math.max(36,h.WalkSpeed+12)+distance*2)*dt
                if distance<=3.5+travel then
                    gem.part:Destroy();table.remove(gems,i)
                    for _,s in pairs(states) do if rootOf(s) then s.xp+=1;levelCheck(s) end end
                else
                    gem.pos+=delta.Unit*travel
                    gem.part.Position=gem.pos
                end
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
