-- XP, offers, upgrades and the HUD state packet.
return function(deps)
	local world, states, gems, rng = deps.world, deps.states, deps.gems, deps.rng
	local block, rootOf, paused = deps.block, deps.rootOf, deps.paused
	local finishDash, update, clock = deps.finishDash, deps.update, deps.clock
	local spellOptions=deps.spellOptions
	-- Session recreates player state between runs. Never reuse an offer token here.
	local nextOfferRevision=0
	local function need(s) return 5+(s.level-1)*3 end
	local augments=deps.augments or require(script.Parent.Augments)
	local function choices(s)
        nextOfferRevision+=1
        s.offerRevision=nextOfferRevision
        local offers,odds=augments.Choices(s,rng)
        s.offerOdds=odds
        return offers
    end
	local function sync(s)
		local _,h=rootOf(s)
        local remaining=clock.phase=="boss" and math.floor(clock.bossElapsed) or clock.roundLength-math.floor(clock.elapsed)
        local b=clock.boss;local f=clock.fieldBoss
		update:FireClient(s.player,{time=math.max(0,remaining),phase=clock.phase,lobby=s.lobby==true,lobbyScores=s.lobby and deps.lobbyScores and deps.lobbyScores()or nil,queued=s.queued==true,bossTestQueued=s.bossTestQueued==true,bossTest=s.bossTest==true,fieldBossTestQueued=s.fieldBossTestQueued==true,fieldBossTest=s.fieldBossTest==true,fieldBoss=f and {name=f.name,hp=math.max(0,f.hp),maxHp=f.maxHp,action=f.action}or nil,loadout=s.loadout,spellOptions=s.lobby and spellOptions or nil,activeOptions=s.lobby and deps.activeOptions or nil,activeSkill=s.activeSkill or "iceRush",activeName=s.activeName or "빙하 쇄도",lobbyMessage=s.lobbyMessage,shield=s.shield or 0,boss=b and {name=b.name,hp=math.max(0,b.hp),maxHp=b.maxHp,stage=b.phase,airborne=b.airborne} or nil,level=s.level,xp=s.xp,need=need(s),hp=h and math.ceil(h.Health) or 0,maxHp=h and h.MaxHealth or 100,
			runResult=s.over and s.runResult or nil,lastRun=s.lobby and s.lastRun or nil,kills=s.kills,fire=s.fire,lightning=s.lightning,ice=s.ice,meteor=s.meteor or 0,blades=s.blades or 0,frost=s.frost or 0,ward=s.ward or 0,missile=s.missile or 0,skyLances=s.skyLances or 0,lightRing=s.lightRing or 0,golem=s.golem,offers=s.offers,offerRevision=s.offerRevision,luck=augments.Luck(s),offerOdds=s.offerOdds,augmentWeights=augments.Weights(s),augments=augments.Summary(s),rerolls=s.rerolls==nil and 2 or s.rerolls,over=s.over,result=s.result,cooldown=math.max(0,math.ceil(s.cooldown)),dashCooldown=math.ceil((s.dashCooldown or 0)*10)/10,golemCooldown=math.max(0,math.ceil(s.petHeavyCooldown or 0)),paused=paused()})
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
	local function choose(s,id,revision)
		if s.over or s.lobby then return end
		if not s.offers or type(id)~="string" or revision~=s.offerRevision then return end
		local valid=false; for _,v in ipairs(s.offers) do if v.id==id then valid=true; break end end
		if not valid then return end
		if not augments.Apply(s,id) then return end
		if id=="vitality" then
			 local _,h=rootOf(s); if h then h.MaxHealth+=15; h.Health=math.min(h.MaxHealth,h.Health+30) end
		elseif id=="recovery" or id=="overheal" then
            local _,h=rootOf(s);if h then h.Health=math.min(h.MaxHealth,h.Health+h.MaxHealth*(id=="recovery" and .35 or 1))end
        end
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
        Reroll = function(s,revision)
            if s.over or s.lobby or not s.offers or revision~=s.offerRevision then return end
            local remaining=s.rerolls==nil and 2 or s.rerolls
            if remaining<=0 then return end
            s.rerolls=remaining-1;s.offers=choices(s);sync(s)
        end,
        FieldBossReward = function(s)
            if s.fieldBossRewarded or s.bossTest or s.over or s.lobby then return end
            local _,h=rootOf(s);if not h then return end
            s.fieldBossRewarded=true;h.Health=math.min(h.MaxHealth,h.Health+h.MaxHealth*.2)
            -- Preserve any existing card and XP; the extra level waits behind that choice.
            s.xp+=need(s);levelCheck(s);sync(s)
        end,
		Sync = sync,
		Drop = drop,
		Choose = choose,
		Collect = collect,
		Need = need,
		LevelCheck = levelCheck,
	}
end
